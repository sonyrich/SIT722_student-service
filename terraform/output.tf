output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.rg.name
}

output "acr_name" {
  description = "Name of the Azure Container Registry"
  value       = azurerm_container_registry.acr.name
}

output "acr_login_server" {
  description = "Login server of the Azure Container Registry"
  value       = azurerm_container_registry.acr.login_server
}

output "production_url" {
  value = "https://${azurerm_linux_web_app.app.default_hostname}"
}

output "staging_url" {
  value = "https://${azurerm_linux_web_app_slot.staging.default_hostname}"
}
