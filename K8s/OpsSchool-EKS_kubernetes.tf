terraform {
  required_version = ">= 0.12.0"
}

provider "aws" {
  version = ">= 2.28.1"
  region  = var.aws_region
}

#Chen addition:
variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

//provider "aws" {
//    region = var.aws_region
//}

provider "random" {
  version = "~> 2.1"
}

provider "local" {
  version = "~> 1.2"
}

provider "null" {
  version = "~> 2.1"
}

provider "template" {
  version = "~> 2.1"
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.10"
}

data "aws_availability_zones" "available" {
}

locals {
  cluster_name = "opsSchool-eks-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

# CIDR will be "My IP" \ all Ips from which you need to access the worker nodes
resource "aws_security_group" "worker_group_mgmt_one" {
  name_prefix = "worker_group_mgmt_one"
  vpc_id      = "vpc-0149b055f01ae0624"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "141.226.12.31/32",
      "172.31.16.0/20",
      "172.31.64.0/18",
      "172.31.128.0/18",
      "172.31.192.0/18"
    ]
  }
}


module "eks" {
  source = "terraform-aws-modules/eks/aws"
  cluster_name = local.cluster_name
  #TODO Ssbnet id
  subnets = [
    "subnet-02bfe55da7ad09c04",
    "subnet-072e6c483e49cc943",
    "subnet-0326fe4a6a39ef99d",
    "subnet-07e85d9e87d2d94c0"]

  #Chen addition:
  kubeconfig_aws_authenticator_env_variables = {
    AWS_PROFILE = "default"
  }

  tags = {
    Environment = "test"
    GithubRepo = "terraform-aws-eks"
    GithubOrg = "terraform-aws-modules"
  }

  vpc_id = "vpc-0149b055f01ae0624"

  worker_groups = [
    {
      name = "worker-group-1"
      instance_type = "t2.small"
      additional_userdata = "echo foo bar"
      asg_desired_capacity = 2
      additional_security_group_ids = [
        aws_security_group.worker_group_mgmt_one.id]
    },
    {
      name = "worker-group-2"
      instance_type = "t2.micro"
      additional_userdata = "echo foo bar"
      additional_security_group_ids = [
        aws_security_group.worker_group_mgmt_one.id]
      asg_desired_capacity = 1
    }
  ]
}