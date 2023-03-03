terraform {
    required_providers {
        azuread = {
            source  = "hashicorp/azuread"
            version = "~> 2.34.1"
        }
    }
}

provider "azuread" {
    tenant_id = var.aad_tenant_id
}
