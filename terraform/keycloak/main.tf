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
  name_id_policy_format         = "Persistent"

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

resource "keycloak_openid_client" "frontend" {
  realm_id  = keycloak_realm.realm.id
  client_id = "frontend"

  enabled               = true
  access_type           = "PUBLIC"
  standard_flow_enabled = true
  valid_redirect_uris   = [
    "https://oauth.pstmn.io/v1/callback",
    "${var.keycloak_baseurl}/realms/${keycloak_realm.realm.realm}/*"
  ]
  login_theme = "keycloak"
}