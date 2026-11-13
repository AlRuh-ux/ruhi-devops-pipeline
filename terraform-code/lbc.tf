# Permissions for the AWS Load Balancer Controller (EKS Pod Identity)

resource "aws_eks_addon" "pod_identity_agent" {
  cluster_name = aws_eks_cluster.ruhi_eks.name
  addon_name   = "eks-pod-identity-agent"

  depends_on = [aws_eks_node_group.ruhi_node_group]
}

resource "aws_iam_policy" "lbc" {
  name   = "ruhi-AWSLoadBalancerControllerIAMPolicy"
  policy = file("${path.module}/iam-policy-lbc.json")
}

resource "aws_iam_role" "lbc" {
  name = "ruhi-eks-lbc-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "pods.eks.amazonaws.com" }
      Action    = ["sts:AssumeRole", "sts:TagSession"]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lbc" {
  role       = aws_iam_role.lbc.name
  policy_arn = aws_iam_policy.lbc.arn
}

resource "aws_eks_pod_identity_association" "lbc" {
  cluster_name    = aws_eks_cluster.ruhi_eks.name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn        = aws_iam_role.lbc.arn
}
