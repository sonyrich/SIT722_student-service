location            = "australiasoutheast"
resource_group_name = "sonyng-hd-rg"

# Replace with a unique name for your Azure Container Registry 
acr_name = "sonyrichstudentacr"

# Replace with a globally unique name for your Azure Web App
app_name          = "app-student-service-sony"
service_plan_name = "plan-student-service"
service_plan_sku  = "S1"

environment = "development"

tags = {
  Project     = "Student Platform"
  ManagedBy   = "Terraform"
  Practical   = "HD"
  Environment = "Development"
}
