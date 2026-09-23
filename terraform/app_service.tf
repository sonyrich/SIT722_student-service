resource "azurerm_linux_web_app" "app" {
  name                = var.app_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.plan.id

  identity {
    type = "SystemAssigned"
  }

  site_config {
    container_registry_use_managed_identity = true

    application_stack {
      docker_image_name   = "student-service:latest"
      docker_registry_url = "https://${azurerm_container_registry.acr.login_server}"
    }
  }

  app_settings = {
    "WEBSITES_PORT" = var.app_port
  }

  tags = merge(
    var.tags,
    {
      Environment = var.environment
    }
  )
}

resource "azurerm_linux_web_app_slot" "staging" {
  name           = "staging"
  app_service_id = azurerm_linux_web_app.app.id

  identity {
    type = "SystemAssigned"
  }

  site_config {
    container_registry_use_managed_identity = true

    application_stack {
      docker_image_name   = "student-service:latest"
      docker_registry_url = "https://${azurerm_container_registry.acr.login_server}"
    }
  }

  app_settings = {
    "WEBSITES_PORT" = var.app_port
  }

  tags = merge(
    var.tags,
    {
      Environment = var.environment
    }
  )
}

resource "azurerm_role_assignment" "app_acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_linux_web_app.app.identity[0].principal_id
}

resource "azurerm_role_assignment" "staging_acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_linux_web_app_slot.staging.identity[0].principal_id
}
