# End-to-End DevOps Pipeline on AWS

Hands-on cloud deployment project: infrastructure as code, containerization, Kubernetes on EKS, and a Jenkins CI/CD pipeline, built from scratch.

> The deployed workload is the open-source 2048 game. It is intentionally unmodified: the project is about the platform around the app, not the app.

## Skills Demonstrated

| Area | What I built | Tools |
|---|---|---|
| Infrastructure as Code | VPC, subnets, EKS cluster, worker nodes, VPC endpoints | Terraform |
| Containerization | Image build and push to a private registry | Docker, AWS ECR |
| Private networking | ECR/S3 traffic kept off the public internet via VPC endpoints | AWS VPC Endpoints |
| Kubernetes delivery | Versioned, repeatable releases | Helm, EKS |
| Traffic exposure | Internet traffic routed to the app through a load balancer | NGINX Ingress, AWS Load Balancer |
| CI/CD | 4-stage pipeline with credentials stored in Jenkins, not in code | Jenkins |
| Security practices | Least-privilege IAM, no root account usage, no hardcoded secrets | AWS IAM |

## Architecture

```
GitHub -> Jenkins -> Docker build -> ECR -> helm upgrade -> EKS
                                                             |
                              Internet -> AWS LB -> Ingress -> Service -> Pods
```

(Add a diagram image here when you have one: `docs/architecture.png`.)

## Pipeline Stages

1. **Source**: pull the latest code from GitHub
2. **Build**: build the Docker image, authenticate to ECR, push the image
3. **Test**: run the image in a temporary container and verify it serves the expected content
4. **Deploy**: `helm upgrade` against the live EKS cluster with the new image

## Repository Layout

```
.
├── Dockerfile          # nginx serving static files
├── Jenkinsfile         # CI/CD pipeline definition
├── terraform-code/     # VPC, EKS, node group, VPC endpoints
├── helm/ruhi-2048/     # Helm chart
└── index.html, js/, style/   # the sample app
```

## Known Limitations and Next Steps

I treat these as a live engineering backlog. Changes land on branches and are recorded in [CHANGELOG.md](CHANGELOG.md).

- [ ] **Ingress migration:** the Kubernetes community ingress-nginx controller was retired in March 2026 (no further releases or security fixes). Plan: migrate to Gateway API (or the AWS Load Balancer Controller) on a feature branch.
- [ ] **Vulnerability scanning:** add an image and dependency scan stage (e.g. Trivy) to the Jenkins pipeline and fix findings on a branch.
- [ ] **Pin versions:** pin base image and Helm chart versions.
- [ ] **Remote Terraform state** with locking.

## Credits

The 2048 game is by [Gabriele Cirulli](http://gabrielecirulli.com) ([original repo](https://github.com/gabrielecirulli/2048)), MIT licensed.
