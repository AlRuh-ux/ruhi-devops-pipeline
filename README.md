# End-to-End DevOps Pipeline on AWS

Hands-on cloud deployment project: infrastructure as code, containerization, Kubernetes on EKS, and a Jenkins CI/CD pipeline, built from scratch.

> The deployed workload is the open-source 2048 game. It is intentionally unmodified: the project is about the platform around the app, not the app.

## Skills Demonstrated

| Area | What I built | Tools |
|---|---|---|
| Infrastructure as Code | VPC, subnets, EKS cluster, worker nodes, VPC endpoints, IAM roles | Terraform |
| Containerization | Image build and push to a private registry | Docker, AWS ECR |
| Private networking | ECR/S3 traffic kept off the public internet via VPC endpoints | AWS VPC Endpoints |
| Kubernetes delivery | Versioned, repeatable releases | Helm, EKS |
| Traffic exposure | Internet traffic routed to the app through an AWS Application Load Balancer | AWS Load Balancer Controller, Kubernetes Ingress |
| CI/CD | 5-stage pipeline with credentials stored in Jenkins, not in code | Jenkins |
| Security practices | Least-privilege IAM, EKS Pod Identity for the controller, image vulnerability scan in the pipeline, pinned scanner version, no root account usage, no hardcoded secrets | AWS IAM, Trivy |

## Architecture

```
GitHub -> Jenkins -> Docker build -> ECR -> helm upgrade -> EKS
                                                             |
                           Internet -> AWS ALB -> Ingress -> Service -> Pods
```

## Pipeline Stages

1. **Source**: pull the latest code from GitHub
2. **Build**: build the Docker image, authenticate to ECR, push the image
3. **Scan**: scan the image with Trivy (pinned version); fail on fixable CRITICAL vulnerabilities
4. **Test**: run the image in a temporary container and verify it serves the expected content
5. **Deploy**: `helm upgrade` against the live EKS cluster with the new image

## Repository Layout

```
.
├── Dockerfile          # nginx serving static files
├── Jenkinsfile         # CI/CD pipeline definition
├── terraform-code/
│   ├── main.tf         # VPC, subnets, EKS, node group, VPC endpoints
│   ├── lbc.tf          # IAM role and Pod Identity for the load balancer controller
│   ├── helm.tf         # AWS Load Balancer Controller and app releases
│   └── iam-policy-lbc.json   # official controller IAM policy (v3.6.3)
├── helm/ruhi-2048/     # Helm chart
└── index.html, js/, style/   # the sample app
```

## Known Limitations and Next Steps

I treat these as a live engineering backlog. Changes land on branches and are recorded in [CHANGELOG.md](CHANGELOG.md).

- [x] **Ingress migration:** replaced the retired ingress-nginx controller (maintenance ended March 2026) with the AWS Load Balancer Controller v3.6.3. Validated with `terraform validate` and `helm template`; not yet applied to a live cluster.
- [x] **Vulnerability scanning:** added a Trivy scan stage to the Jenkins pipeline. Pinned to an exact version because of the March 2026 Trivy supply chain compromise. Not yet run in Jenkins.
- [ ] **Gateway API:** move from Ingress to Gateway API, which the Kubernetes project recommends as the successor.
- [ ] **Pin versions:** pin the base image and EKS version.
- [ ] **Remote Terraform state** with locking.

## Credits

The 2048 game is by [Gabriele Cirulli](http://gabrielecirulli.com) ([original repo](https://github.com/gabrielecirulli/2048)), MIT licensed.
