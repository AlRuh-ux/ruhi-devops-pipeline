provider "kubernetes" {
  host                   = aws_eks_cluster.ruhi_eks.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.ruhi_eks.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.ruhi_eks.name, "--region", "us-east-1"]
  }
}

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.ruhi_eks.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.ruhi_eks.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.ruhi_eks.name, "--region", "us-east-1"]
    }
  }
}

# Replaces the retired ingress-nginx controller (maintenance ended March 2026).
# The AWS Load Balancer Controller creates an AWS Application Load Balancer for the Ingress.
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "3.6.3"
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = aws_eks_cluster.ruhi_eks.name
  }

  set {
    name  = "region"
    value = "us-east-1"
  }

  set {
    name  = "vpcId"
    value = aws_vpc.ruhi_vpc.id
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  depends_on = [
    aws_eks_node_group.ruhi_node_group,
    aws_eks_addon.pod_identity_agent,
    aws_eks_pod_identity_association.lbc,
  ]
}

# The controller creates the load balancer and its security groups itself, so Terraform does not
# track them. On destroy, the app (and its Ingress) is removed first. This pause then keeps the
# controller running while it deletes its load balancer and security groups, and only after that
# does Terraform remove the controller and the VPC. Nothing happens on create (no delay).
resource "time_sleep" "wait_for_alb_cleanup" {
  destroy_duration = "5m"

  depends_on = [helm_release.aws_load_balancer_controller]
}

resource "helm_release" "ruhi_2048" {
  name             = "ruhi-2048"
  chart            = "../helm/ruhi-2048"
  namespace        = "ruhi-2048"
  create_namespace = true

  depends_on = [time_sleep.wait_for_alb_cleanup]
}
