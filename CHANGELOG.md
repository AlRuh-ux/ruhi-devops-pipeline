# Changelog

## [1.3.0] - 2026-11-14

### Added
- Evidence screenshots in `docs/images/` and an evidence-based README, from a full live test: `terraform apply`, Jenkins build #3 (Source, Build, Scan, Test and Deploy all passed), app reachable through the load balancer, and `terraform destroy` completed.
- A 5-minute pause (`time_sleep`) in Terraform so the load balancer controller can delete the load balancer and security groups it created before the VPC is removed on destroy.

### Changed
- Scan stage: the image archive is now copied into the scanner container with `docker cp`. Jenkins runs in a container, so mounting its workspace into the scanner showed an empty folder.
- Deploy stage: runs `aws eks update-kubeconfig` before `helm upgrade`, so the pipeline always targets the current EKS cluster.

## [1.2.0] - 2026-11-13

### Added
- Jenkins `Scan` stage: scans the built image with Trivy, reports HIGH and CRITICAL findings, and fails the pipeline on fixable CRITICAL ones.
- Trivy is pinned to an exact version (0.69.3), never `latest`. In March 2026 the Trivy release and its `latest` image tag were compromised in a supply chain attack, and 0.69.3 is the last release confirmed clean in the official advisory.
- The image is scanned from an archive, so the Docker socket is never mounted into the scanner container.

## [1.1.0] - 2026-11-13

### Added
- Terraform `lbc.tf`: EKS Pod Identity add-on, IAM role and policy (official v3.6.3 policy) for the load balancer controller.
- Public subnet tags required for load balancer discovery.

### Changed
- Replaced the ingress-nginx controller with the AWS Load Balancer Controller (Helm chart 3.6.3). The Kubernetes project retired ingress-nginx in March 2026, so it no longer receives releases or security fixes.
- Helm chart: ingress class changed from `nginx` to `alb`, with ALB annotations (internet-facing, IP targets).

### Removed
- The placeholder `ruhi-2048.local` host, so the load balancer answers on its own address.
- The unrelated Tetris Helm release from Terraform, so the repo deploys only what it contains.

## [1.0.0] - Initial release
- Terraform: VPC, subnets, EKS, worker nodes, VPC endpoints
- Docker image pushed to ECR
- Helm chart deployed to EKS
- NGINX Ingress and AWS load balancer
- Jenkins pipeline: Source, Build, Test, Deploy
