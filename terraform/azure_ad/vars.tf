variable "aad_tenant_id" {
  description = "Tenant ID for Azure AD"
  type        = string
  sensitive   = true
}

variable "aad_admin_id" {
  description = "Object ID of the admin user in Azure AD"
  type        = string
  sensitive   = true
}

variable "keycloak_baseurl" {
  description = "Base URL to the keycloak instance"
  type        = string
  sensitive   = true
}
