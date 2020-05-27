data "local_file" "azure-manifest" {
    filename = "azure-manifest.json"
}

data "local_file" "aws-manifest" {
    filename = "aws-manifest.json"
}

locals {
   aws_json = jsondecode(file("aws-manifest.json"))
   aws_build = element(tolist(local.aws_json.builds),0)
}

//output "test" {
//    value = data.aws-manifest.builds.artifact_id
//}
output "testtem" {
    value = local.aws_build
}
