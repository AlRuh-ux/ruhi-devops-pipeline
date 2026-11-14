# Changelog

## [Unreleased]

### Planned
- Patch the 3 HIGH `libxslt` findings reported by Trivy (fixed version 1.1.43-r4 is available).
- Migrate from Ingress to Gateway API (the AWS Load Balancer Controller v3 supports it).
- Pin the base image and the EKS version; move Terraform state to a remote backend with locking.

## [1.3.0] - 2026-11-14

### Fixed
- **Scan stage:** Jenkins runs inside a container, so mounting its workspace into the scanner showed an empty folder. The image archive is now copied into the scanner container with `docker cp`.
- **Deploy stage:** the pipeline now runs `aws eks update-kubeconfig` before `helm upgrade`, so it always targets the current EKS cluster.
- **Teardown:** added a 5-minute `time_sleep` after the app release so the load balancer controller can delete the load balancer and security groups it created before the VPC is removed.

### Added
- Evidence screenshots in `docs/images/` and an evidence-based README.

### Verification (live test)
- `terraform apply` from scratch: 29 resources managed by Terraform.
- Controller and app pods Running; Application Load Balancer active; app reachable through the ALB.
- Jenkins build #3: Source, Build, Scan, Test and Deploy all passed in 1 min 14 s. Deployed image tag 3.
- Trivy: 0 CRITICAL, 3 HIGH (`libxslt`, fix available).
- `terraform destroy` completed.

## [1.2.0] - 2026-11-13

### Added
- Jenkins `Scan` stage: scans the built image with Trivy and fails the pipeline on fixable CRITICAL vulnerabilities (HIGH and CRITICAL are reported).

### Security
- Trivy is pinned to an exact version (0.69.3), never `latest`. In March 2026 the Trivy release and its `latest` image tag were compromised in a supply chain attack, and 0.69.3 is the last release confirmed clean in the official advisory.
- The image is scanned from an archive, so the Docker socket is never mounted into the scanner container.

### Verification
- Run in Jenkins and passing as part of build #3 (see 1.3.0).

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
- Applied to a live cluster on 2026-11-14 (see 1.3.0).

## [1.0.0] - Initial release
- Terraform: VPC, subnets, EKS, worker nodes, VPC endpoints
- Docker image pushed to ECR
- Helm chart deployed to EKS
- NGINX Ingress + AWS Load Balancer
- Jenkins pipeline: Source, Build, Test, Deploy
