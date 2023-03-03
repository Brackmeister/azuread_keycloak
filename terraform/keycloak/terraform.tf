terraform {
    required_providers {
        keycloak = {
            source = "mrparkers/keycloak"
            version = ">= 4.0.0"
        }
    }
}

provider "keycloak" {
    client_id     = "admin-cli"
    username      = var.admin_user
    password      = var.admin_password
    url           = var.keycloak_baseurl
}
