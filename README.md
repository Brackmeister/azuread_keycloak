# Production keycloak with Azure AD as IDP

Inspired by https://docs.virtimo.net/bpc-docs/latest/core/admin/identity_provider/idp_keycloak_microsoft.html

## Setup

Create an `.env` file and enter the following variable exports:

```
export TF_VAR_keycloak_baseurl=
export TF_VAR_admin_user=
export TF_VAR_admin_password=

export TF_VAR_aad_tenant_id=
export TF_VAR_aad_admin_id=
export TF_VAR_aad_app_id=
```

Then `source .env` before running terraform.

## Getting the Azure AD ID Token

1. Create a new request in Postman, GET ${TF_VAR_keycloak_baseurl}/realms/user_facing/broker/idp/token
2. Setup OAuth 2.0 token for this request with these settings
    - Grant Type: Authorization Code
    - Callback URL: https://oauth.pstmn.io/v1/callback
    - Auth URL: ${TF_VAR_keycloak_baseurl}/realms/user_facing/protocol/openid-connect/auth
    - Access Token URL: ${TF_VAR_keycloak_baseurl}/realms/user_facing/protocol/openid-connect/token
    - Client ID: frontend
3. Get a token
    1. Click "Get New Access Token" in Postman
    2. In the window that opens click the "Azure AD" button below "Or sign in with"
    3. Log in with the desired user in Azure AD
4. Use this token to execute the request to get the original id_token of the identity provider
    1. Click "Proceed" after successful login
    2. Click "Use Token" after selecting the new token
    3. Click "Send" on the actual request

The important settings of the IDP in keycloak to get the id_token from the original IDP are

```
resource "keycloak_saml_identity_provider" "azure_ad" {
  ...
  store_token                   = true
  add_read_token_role_on_create = true
}
resource "keycloak_generic_role_mapper" "broker_to_frontend_role_mapper" {
  realm_id  = keycloak_realm.realm.id
  client_id = keycloak_openid_client.frontend.id
  role_id   = data.keycloak_role.broker__read_token.id
}
```
