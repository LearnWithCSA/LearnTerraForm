# How to run the config

1. Run `Terraform init`
1. run `Terraform plan -var="location=westeu" -var="prefix=TerraSql"`
1. Run `terraform apply -var="location=westeu" -var="prefix=TerraSql"`