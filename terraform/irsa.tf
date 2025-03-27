# Get EKS cluster details
data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_name

  depends_on = [ module.eks ]
}

# Get OIDC provider details
data "aws_iam_openid_connect_provider" "eks" {
  url = module.eks.cluster_oidc_issuer_url

  depends_on = [ module.eks ]
}

# IAM Role for ArgoCD with IRSA
resource "aws_iam_role" "argocd_irsa" {
  name = "argocd-irsa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = data.aws_iam_openid_connect_provider.eks.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${data.aws_iam_openid_connect_provider.eks.url}:sub" = "system:serviceaccount:argocd:argocd-service-account"
        }
      }
    }]
  })

  # Optional: Add tags for better resource management
  tags = {
    Name        = "argocd-irsa-role"
    Environment = "production"
  }
}

# IAM Policy to allow ArgoCD access to S3
resource "aws_iam_policy" "s3_access" {
  name        = "argocd-s3-access"
  description = "Allows ArgoCD to access S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject"
      ]
      Resource = [
        "arn:aws:s3:::your-bucket-name",
        "arn:aws:s3:::your-bucket-name/*"
      ]
    }]
  })
}

# Attach the policy to the IAM role
resource "aws_iam_role_policy_attachment" "argocd_s3_attach" {
  role       = aws_iam_role.argocd_irsa.name
  policy_arn = aws_iam_policy.s3_access.arn
}