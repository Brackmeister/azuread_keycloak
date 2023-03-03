data "azuread_client_config" "current" {}

resource "azuread_application" "keycloak" {
  display_name = "Keycloak"

  owners = [
    var.aad_admin_id
  ]

  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000"

    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d" # https://graph.microsoft.com/User.Read
      type = "Scope"
    }
  }

  web {
    redirect_uris = [
      "${var.keycloak_baseurl}/realms/user_facing/broker/azure-ad/endpoint",
    ]

    implicit_grant {
      access_token_issuance_enabled = false
      id_token_issuance_enabled     = false
    }
  }
}
