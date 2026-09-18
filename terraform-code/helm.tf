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

resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true

  depends_on = [aws_eks_node_group.ruhi_node_group]
}

resource "helm_release" "ruhi_2048" {
  name             = "ruhi-2048"
  chart            = "../helm/ruhi-2048"
  namespace        = "ruhi-2048"
  create_namespace = true

  depends_on = [helm_release.ingress_nginx]
}

resource "helm_release" "my_tetris_game" {
  name             = "my-tetris-game"
  chart            = "../../ruhi-tetris-docker-k8s/helm/my-tetris-game"
  namespace        = "my-tetris"
  create_namespace = true

  depends_on = [helm_release.ingress_nginx]
}