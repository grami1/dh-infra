# dh-infra

dh-infra is an infrastructure part of the [Dihome project](https://github.com/grami1/dihome). It contains terraform configuration for
AWS services.

## How to run
1. Select terraform module that will be changed  
    ``cd ec2``
2. Create a var-file with variable values in the module directory (e.g. aws_region.tfvars). 
Required variables are defined in variables.tf
3. Run terraform init  
    ``terraform init``
4. Run terraform plan  
    ``terraform plan -var-file=aws_region.tfvars -out=tfplan-aws_region``
5. Double-check the changes that will be applied after plan
6. Run terraform apply
    ``terraform apply tfplan-aws_region``