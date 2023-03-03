variable "keycloak_baseurl" {
  description = "Base URL to the keycloak instance"
  type        = string
  sensitive   = true
}

variable "admin_user" {
  description = "Username of the keycloak admin"
  type        = string
  sensitive   = true
}

variable "admin_password" {
  description = "Password of the keycloak admin"
  type        = string
  sensitive   = true
}

variable "aad_tenant_id" {
  description = "Tenant ID for Azure AD"
  type        = string
  sensitive   = true
}

variable "aad_app_id" {
  description = "App ID for Azure AD"
  type        = string
  sensitive   = true
}
