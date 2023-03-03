resource "keycloak_realm" "realm" {
  realm   = "user_facing"
  enabled = true

  login_theme   = "keycloak"
  account_theme = "keycloak"
  admin_theme   = "keycloak"
  email_theme   = "keycloak"
}

resource "keycloak_saml_identity_provider" "azure_ad" {
  realm        = keycloak_realm.realm.id
  alias        = "azure-ad"
  display_name = "Azure AD"

  entity_id                  = "spn:${var.aad_app_id}"
  single_sign_on_service_url = "https://login.microsoftonline.com/${var.aad_tenant_id}/saml2"
  single_logout_service_url  = "https://login.microsoftonline.com/${var.aad_tenant_id}/saml2"

  sync_mode                     = "FORCE"
  authn_context_comparison_type = "exact"
  name_id_policy_format         = "Email"

  hide_on_login_page            = false
  store_token                   = true
  add_read_token_role_on_create = true
  backchannel_supported         = true
  post_binding_response         = true
  post_binding_logout           = true
  post_binding_authn_request    = true
  trust_email                   = true
  force_authn                   = true
}

resource "keycloak_custom_identity_provider_mapper" "saml_attribute_mapper" {
  for_each = {
    "email"     = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"
    "username"  = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"
    "firstName" = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname"
    "lastName"  = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname"
  }

  realm                    = keycloak_realm.realm.id
  name                     = "attribute-${each.key}-mapper"
  identity_provider_alias  = keycloak_saml_identity_provider.azure_ad.id
  identity_provider_mapper = "saml-user-attribute-idp-mapper"

  extra_config = {
    syncMode         = "INHERIT"
    "attribute.name" = each.value
    "user.attribute" = each.key
  }
}

data "keycloak_openid_client" "broker" {
  realm_id  = keycloak_realm.realm.id
  client_id = "broker"
}

data "keycloak_role" "broker__read_token" {
  realm_id  = keycloak_realm.realm.id
  client_id = data.keycloak_openid_client.broker.id
  name      = "read-token"
}

resource "keycloak_openid_client" "frontend" {
  realm_id  = keycloak_realm.realm.id
  client_id = "frontend"

  full_scope_allowed    = false
  enabled               = true
  access_type           = "PUBLIC"
  standard_flow_enabled = true
  valid_redirect_uris   = [
    "https://oauth.pstmn.io/v1/callback",
    "${var.keycloak_baseurl}/realms/${keycloak_realm.realm.realm}/*"
  ]
}

resource "keycloak_generic_role_mapper" "broker_to_frontend_role_mapper" {
  realm_id  = keycloak_realm.realm.id
  client_id = keycloak_openid_client.frontend.id
  role_id   = data.keycloak_role.broker__read_token.id
}

resource "keycloak_role" "test_role" {
  for_each = {
    "test-role" = "Test role from Azure AD"
  }

  realm_id    = keycloak_realm.realm.id
  name        = each.key
  description = each.value
}

resource "keycloak_custom_identity_provider_mapper" "saml_role_mapper" {
  for_each = {
    "test-role" = "http://schemas.microsoft.com/ws/2008/06/identity/claims/role"
  }

  realm                    = keycloak_realm.realm.id
  name                     = "role-${each.key}-mapper"
  identity_provider_alias  = keycloak_saml_identity_provider.azure_ad.id
  identity_provider_mapper = "saml-role-idp-mapper"

  extra_config = {
    syncMode          = "INHERIT"
    "attribute.name"  = each.value
    "attribute.value" = each.key
    role              = each.key
  }
}
