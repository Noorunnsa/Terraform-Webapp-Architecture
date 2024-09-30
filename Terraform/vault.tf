
#Get the metadata of the secret from the AWS Secrets Manager (Eg:ID, name)
data "aws_secretsmanager_secret" "vault_token_metadata" {
  provider = aws.mumbai
  name      = "vault-token"
}

#Use the ID from the previous data block to fetch the actual secret value
data "aws_secretsmanager_secret_version" "vault_token" {
  provider  = aws.mumbai
  secret_id = data.aws_secretsmanager_secret.vault_token_metadata.id
}


#Define vault provider and pass the token through aws secrets manager
provider "vault" {
  address = "http://127.0.0.1:8200"
  token   = jsondecode(data.aws_secretsmanager_secret_version.vault_token.secret_string)["vault-token"]
}

#Retrieve the ami id stored in the vault
data "vault_generic_secret" "ami_id" {
  path = "secret/ami_id"
}

#Retrieve the VPC Cidr stored in the vault
data "vault_generic_secret" "vpc_cidr" {
  path = "secret/vpc_cidr"
}

#Retrieve the instance type stored in the vault
data "vault_generic_secret" "instance_type" {
  path = "secret/instance_type"
}