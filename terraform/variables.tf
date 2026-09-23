variable "location" {
  description = "Azure region where the resources will be created"
  type        = string
  default     = "australiasoutheast"
}

variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
}

variable "acr_name" {
  description = "Globally unique name of the Azure Container Registry"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9]+$", var.acr_name))
    error_message = "The ACR name must contain only alphanumeric characters."
  }
}

variable "app_name" {
  description = "Name of the Azure Linux Web App (must be globally unique)"
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9][A-Za-z0-9-]{0,58}[A-Za-z0-9]$", var.app_name))
    error_message = "app_name must be 2-60 characters, alphanumeric and hyphens only, and cannot start or end with a hyphen."
  }
}

variable "service_plan_name" {
  description = "Name of the Azure App Service Plan"
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9]([A-Za-z0-9-]{0,38}[A-Za-z0-9])?$", var.service_plan_name))
    error_message = "service_plan_name must be 1-40 characters, alphanumeric and hyphens only, and cannot start or end with a hyphen."
  }
}

variable "service_plan_sku" {
  description = "SKU for the Azure App Service Plan (e.g. B1, P1v3)"
  type        = string
  default     = "B1"
}

variable "app_port" {
  description = "Port the containerised app listens on inside the Web App"
  type        = string
  default     = "3000"
}

variable "environment" {
  description = "Environment name applied to resource tags"
  type        = string
  default     = "development"
}

variable "kubernetes_version" {
  default = "1.36.1"
}

variable "tags" {
  description = "Tags applied to Azure resources"
  type        = map(string)

  default = {
    Project   = "Student Platform"
    ManagedBy = "Terraform"
    Practical = "HD"
  }
}
