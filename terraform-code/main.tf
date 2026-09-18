terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

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

resource "aws_vpc" "ruhi_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "ruhi-eks-vpc"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_internet_gateway" "ruhi_igw" {
  vpc_id = aws_vpc.ruhi_vpc.id

  tags = {
    Name = "ruhi-igw"
  }
}

resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.ruhi_vpc.id
  cidr_block              = "10.0.${count.index}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "ruhi-public-subnet-${count.index}"
  }
}

r