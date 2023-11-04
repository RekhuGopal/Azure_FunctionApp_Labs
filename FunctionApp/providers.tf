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
    time = {
      source  = "hashicorp/time"
      version = "0.9.1"
    }
  }
  backend "remote" {
		hostname = "app.terraform.io"
		organization = "CloudQuickLabs"

		workspaces {
			name = "AzureAKSLabs"
		}
	}
}

provider "azurerm" {
  features {}
}