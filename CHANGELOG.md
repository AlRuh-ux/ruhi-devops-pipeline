# Changelog

## [Unreleased]

### Planned
- Migrate from Ingress to Gateway API (the AWS Load Balancer Controller v3 supports it).
- Run the pipeline end to end and a test `terraform apply` on a live cluster, then update the verification notes below.

## [1.2.0] - 2026-11-13

### Added
- Jenkins `Scan` stage: scans the built image with Trivy and fails the pipeline on fixable CRITICAL vulnerabilities (HIGH and CRITICAL are reported).

### Security
- Trivy is pinned to an exact version (0.69.3), never `latest`. In March 2026 the Trivy release and its `latest` image tag were compromised in a supply chain attack, and 0.69.3 is the last release confirmed clean in the official advisory.
- The image is scanned from a tar file, so the Docker socket is never mounted into the scanner container.

### Verification
- Jenkinsfile change not yet run in Jenkins. This entry will be updated after the first pipeline run.

## [1.1.0] - 2026-11-13

### Changed
- Replaced the ingress-nginx controller with the AWS Load Balancer Controller (Helm chart 3.6.3).
  **Why:** the Kubernetes project retired ingress-nginx in March 2026, so it no longer receives releases or security fixes.
- Helm chart: ingress class changed from `nginx` to `alb`, with ALB annotations (internet-facing, IP targets). Removed the placeholder `ruhi-2048.local` host so the load balancer answers on its own address.

### Added
- Terraform `lbc.tf`: EKS Pod Identity add-on, IAM role and policy (official v3.6.3 policy) for the controller.
- Public subnet tags required for load balancer discovery.

### Removed
- Unrelated Tetris Helm release from Terraform, so the repo deploys only what it contains.

### Verification
- `terraform validate` and `helm template` pass.
- Not yet applied to a live cluster. This entry will be updated after a test deployment.

## [1.0.0] - Initial release
- Terraform: VPC, subnets, EKS, worker nodes, VPC endpoints
- Docker image pushed to ECR
- Helm chart deployed to EKS
- NGINX Ingress + AWS Load Balancer
- Jenkins pipeline: Source, Build, Test, Deploy
