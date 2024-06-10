# Terraform version
terraform {
  required_version = ">= 1.6.6"
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.89.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.51.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.1"
    }
  }
}