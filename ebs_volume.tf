// resource "aws_iam_role_policy" "mount_ebs_volumes" {
//   name   = "mount-ebs-volumes"
//   role   = aws_iam_role.instance_role.id
//   policy = data.aws_iam_policy_document.mount_ebs_volumes.json
// }

// data "aws_iam_policy_document" "mount_ebs_volumes" {
//   statement {
//     effect = "Allow"

//     actions = [
//       "ec2:DescribeVolume*",
//       "ec2:AttachVolume",
//       "ec2:DetachVolume",
//     ]
//     resources = ["*"]
//   }
// }

// resource "aws_ebs_volume" "mysql" {
//   availability_zone = aws_instance.nomad-client[0].availability_zone
//   size              = 40
// }

resource "aws_iam_instance_profile" "instance_profile" {
  name_prefix = var.prefix
  role        = aws_iam_role.instance_role.name
}

resource "aws_iam_role" "instance_role" {
  name_prefix        = var.prefix
  assume_role_policy = data.aws_iam_policy_document.instance_role.json
}

data "aws_iam_policy_document" "instance_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "sharing_volumes" {
  name   = "sharing_volumes"
  role   = aws_iam_role.instance_role.id
  policy = data.aws_iam_policy_document.sharing_volumes.json
}

data "aws_iam_policy_document" "sharing_volumes" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:DescribeVolume*",
      "ec2:AttachVolume",
      "ec2:DetachVolume",
      "ec2:DescribeInstances",
      "ec2:DescribeTags",
      ]
     resources = ["*"]
  }
}

// resource "aws_iam_role_policy" "auto_discover_cluster" {
//   name   = "auto-discover-cluster"
//   role   = aws_iam_role.instance_role.id
//   policy = data.aws_iam_policy_document.auto_discover_cluster.json
// }

// data "aws_iam_policy_document" "auto_discover_cluster" {
//   statement {
//     effect = "Allow"

//     actions = [
//       "ec2:DescribeInstances",
//       "ec2:DescribeTags",
//       "autoscaling:DescribeAutoScalingGroups",
//     ]

//     resources = ["*"]
//   }
// }