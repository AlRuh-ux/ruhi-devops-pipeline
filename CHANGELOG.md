# Changelog

## [Unreleased]

### Planned
- Migrate from ingress-nginx to Gateway API. Reason: ingress-nginx was retired by Kubernetes SIG Network in March 2026 and no longer receives security fixes.
- Add container image vulnerability scanning to the Jenkins pipeline.

## [1.0.0] - Initial release
- Terraform: VPC, subnets, EKS, worker nodes, VPC endpoints
- Docker image pushed to ECR
- Helm chart deployed to EKS
- NGINX Ingress + AWS Load Balancer
- Jenkins pipeline: Source, Build, Test, Deploy
