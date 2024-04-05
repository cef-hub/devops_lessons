provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_role" "eks_cluster_role_skruhlik" {
  name = "eks_cluster_role_skruhlik"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action    = "sts:AssumeRole"
      },
    ]
  })
}

resource "aws_eks_cluster" "skruhlik_eks_cluster" {
  name     = "skruhlik_eks_cluster"
  role_arn = aws_iam_role.eks_cluster_role_skruhlik.arn

  vpc_config {
    subnet_ids = ["subnet-07c2f05d5f20031b7", "subnet-054c1db783b328393"] 
    security_group_ids = ["sg-02bed5840a3b6210f"] 
  }

  tags = {
    Environment = "skruhlik_dev"
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachment_skruhlik" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role_skruhlik.name
}

resource "aws_iam_role_policy_attachment" "eks_node_policy_attachment_skruhlik" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_cluster_role_skruhlik.name
}

resource "aws_eks_node_group" "skruhlik_node_group" {
  cluster_name    = aws_eks_cluster.skruhlik_eks_cluster.name
  node_group_name = "skruhlik_node_group"

  node_role_arn    = aws_iam_role.eks_node_role_skruhlik.arn

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  subnet_ids = ["subnet-07c2f05d5f20031b7" , "subnet-054c1db783b328393"] 
  instance_types = ["t3.small"]

  tags = {
    Environment = "skruhlik_dev"
  }
}

resource "aws_iam_role" "eks_node_role_skruhlik" {
  name = "eks_node_role_skruhlik"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action    = "sts:AssumeRole"
      },
    ]
  })
}


resource "aws_iam_role_policy_attachment" "eks_node_instance_profile_attachment_skruhlik" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role_skruhlik.name
}

resource "aws_iam_instance_profile" "eks_node_instance_profile_skruhlik" {
  name = "eks_node_instance_profile_skruhlik"
  role = aws_iam_role.eks_node_role_skruhlik.name
}
