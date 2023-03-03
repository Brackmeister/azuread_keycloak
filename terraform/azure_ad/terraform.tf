terraform {
    required_providers {
        azuread = {
            source  = "hashicorp/azuread"
            version = "~> 2.15.0"
        }
    }
}

provider "azuread" {
    tenant_id = var.aad_tenant_id
}
