# DevOps Assignment test for UNIT COMPANY LIMITED

## Content

- Terraform script to create a VPC with public and private subnets in AWS also with script for create an EKS cluster and node group to test ArgoCD if needed.
- ArgoCD configuration to deploy a simple nodejs application.
- Simple nodejs application to test GitOps including a simple express server and a Dockerfile to build the image.
- Github action workflow to build the Docker image and push it to AWS public ECR repository then automatically update the ArgoCD deployment configuration to let ArgoCD rollout the new version of the application.

## Setup

### If you want to test full operation on EKS cluster, you need to provision the cluster before.

- Provision the VPC and EKS cluster using given terraform script. **I hope you have setup your AWS credentials and have access to the AWS account before running the script.**
  ```bash
  $ cd terraform
  $ terraform init
  $ terraform apply -auto-approve
  ```
- After provisioning the cluster, you need to update your kubeconfig file to access the EKS cluster. You can do this by running the following command:
  ```bash
  $ aws eks --region ap-southeast-1 update-kubeconfig --name my-eks-cluster
  ```
  **If everything is working fine, you should be able to access the EKS cluster using kubectl command, Howevery, If you can't access the cluster, please check your cluster configuration is allow your credentials to access the cluster.**
- Install ArgoCD on the EKS cluster using the following command:
  ```bash
  $ kubectl create namespace argocd
  $ kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
  ```
  - After installing ArgoCD, you should do port-forward to access the ArgoCD UI. You can do this by running the following command:
  ```bash
    $ kubectl port-forward svc/argocd-server -n argocd 8080:443
  ```
  - then you can access the ArgoCD UI at `https://localhost:8080` username is `admin` and password is randomly generated which you can get by running the following command:
  ```bash
    # for linux and macOS
    $ kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d && echo
    # for windows
    $ kubectl get secret argocd-initial-admin-secret -n argocd
    # then copy the password from the output and paste it some decoder tool to decode it then use it to login to ArgoCD UI.
  ```
- If you can access ArgoCD UI now you need to setup the ArgoCD application to deploy the simple nodejs applicaltion.
  - All configuration are already provided in the `argo-config` folder.
  - Firstly, you need to apply new application configuration for ArgoCD by applying the `application.yaml` file. You can do this by running the following command:
  ```bash
  $ kubectl apply -f argo-config/application.yaml
  ```
  - After applying, you should be able to see the new application in the ArgoCD UI. If it syncs successfully, you should be able to access the application at `http://<load-balancer-ip>:3000` where `<load-balancer-ip>` is the public IP of the load balancer created by the EKS cluster.

### If you want to test the application on your local machine like a local docker desktop or minikube, you can do it by following the steps below.

- Skip the terraform script step.
- Following steps like above.

## What does it works?

- All of these setups are working for demonstration of Gitops and CI/CD pipeline.
- The operation start when you create new tag in the repository with correct format like `v1.0.0` then the github action workflow will be triggered to build the docker image and push it to AWS ECR public repository then update the ArgoCD application configuration to let ArgoCD rollout the new version of the application.

## Note

**Everything in this repository is base on my current knowledge and experience at the time of wrtiting this. I hope everyone can understand easily and I open to any feedback and suggestion.**

## Key to improvement

- taging strategy: Need to be tagged when completed gitflow and not manually tagging. It should be automatically tagged when the workflow is completed.
- versioned tagging strategy: It should be automatically updated not manually tagging.
- terraform sctipt and ArgoCD configuration that provide can't be used for production because, It pretty basic and need to be improved.

## Key takeaway

- If you understand what I did you will learn the same thing as I did.
