# Ruhi's End-to-End DevOps Pipeline on AWS

An end-to-end DevOps pipeline project, built from scratch, covering the full journey from Infrastructure as Code to a fully automated CI/CD deployment.

**App deployed:** 2048 (a static web game — see credits below) — containerized and deployed as the workload running through this pipeline.

\---

## What This Project Demonstrates

* **Infrastructure as Code:** AWS VPC, subnets, EKS cluster, and worker nodes — all provisioned via Terraform
* **Containerization:** Docker image built and pushed to AWS ECR (Elastic Container Registry)
* **Private networking:** VPC Interface/Gateway Endpoints for ECR and S3, keeping registry traffic off the public internet
* **Kubernetes deployment:** Helm chart deploying the app to EKS
* **Networking \& exposure:** NGINX Ingress Controller + AWS Load Balancer, routing real internet traffic to the app
* **CI/CD automation:** Jenkins pipeline with 4 stages — Source → Build → Test → Deploy — using securely stored credentials (Jenkins Credentials store, not hardcoded secrets)

## Tech Stack

|Layer|Tool|
|-|-|
|Cloud Provider|AWS|
|Infrastructure as Code|Terraform|
|Container Runtime|Docker|
|Container Registry|AWS ECR|
|Orchestration|Kubernetes (AWS EKS)|
|Package Manager|Helm|
|Ingress / Load Balancing|NGINX Ingress Controller + AWS Load Balancer|
|CI/CD|Jenkins|
|Version Control|Git / GitHub|

## Repository Layout

```
.
├── Dockerfile                  → builds the app container (nginx serving static files)
├── Jenkinsfile                 → 4-stage CI/CD pipeline definition
├── terraform-code/
│   └── main.tf                 → VPC, subnets, EKS cluster, worker nodes, VPC endpoints
├── helm/
│   └── ruhi-2048/               → Helm chart for deploying the app to EKS
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
├── index.html, js/, style/     → the app itself (2048 game)
```

## Pipeline Stages (Jenkinsfile)

1. **Source** — pulls the latest code from this GitHub repo
2. **Build** — builds the Docker image, authenticates to ECR, pushes the image
3. **Test** — runs the built image in a temporary container and verifies it actually serves the expected content (a real smoke test, not just a health ping)
4. **Deploy** — runs `helm upgrade` against the live EKS cluster with the newly built image

## Status

✅ Complete — full pipeline runs end-to-end successfully (Source → Build → Test → Deploy, all passing)

## Roadmap (completed)

* \[x] Local tooling setup (Git, Docker, kubectl, Terraform, Helm)
* \[x] AWS account + IAM setup (least-privilege access, no root usage)
* \[x] Terraform: VPC, subnets, EKS cluster, worker nodes
* \[x] Docker image built and pushed to ECR
* \[x] VPC Endpoints for private ECR/S3 access
* \[x] Helm chart deployment to EKS
* \[x] NGINX Ingress + AWS Load Balancer
* \[x] Jenkins CI/CD pipeline (4 stages, secure credentials)

\---

## Credits (original app)

This project deploys **2048**, a small clone of [1024](https://play.google.com/store/apps/details?id=com.veewo.a1024), based on [Saming's 2048](http://saming.fr/p/2048/) (also a clone), originally created by [Gabriele Cirulli](http://gabrielecirulli.com). The game itself is unmodified — this project's focus is the infrastructure and deployment pipeline around it, not the game's code.

Original repository: https://github.com/gabrielecirulli/2048
Licensed under the [MIT license](./LICENSE.txt).



