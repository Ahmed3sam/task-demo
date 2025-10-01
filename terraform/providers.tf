terraform {
  required_version = ">=1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
  # Backend configuration 
  # backend "azurerm" {
  #   resource_group_name  = "aks-private-backend-rg"
  #   storage_account_name = "tfstatece6gqe4q"
  #   container_name       = "tfstate"
  #   key                  = "aks-private.terraform.tfstate"
  #   use_azuread_auth     = true
  # }
}

provider "azurerm" {
  features {}
}
