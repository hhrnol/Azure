terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.41.0"
    }
  }
  backend "azurerm" {
    subscription_id = "910df4d8-c3bf-498e-8ddd-8511324d8bd7"
    resource_group_name  = "RG-tfstate-01"
    storage_account_name = "tfstate011346785992"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
  
}


provider "azurerm" {
  features {
    resource_group {
       prevent_deletion_if_contains_resources = false
    }
  }
}

resource "random_integer" "ri" {
  min = 10000
  max = 99999
}


resource "azurerm_resource_group" "rg" {
  name     = "myResourceGroup-${random_integer.ri.result}"
  location = "West Europe"
}

resource "azurerm_application_insights" "rg" {
  name                = "webapp-asp-${random_integer.ri.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
}


resource "azurerm_service_plan" "appserviceplan" {
  name                = "webapp-asp-${random_integer.ri.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Windows"
  sku_name            = "F1"
}


resource "azurerm_windows_web_app" "webapp" {
  name                  = "webapp-${random_integer.ri.result}"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  service_plan_id       = azurerm_service_plan.appserviceplan.id
  https_only            = true
  site_config { 
  application_stack {
  current_stack = "node"
  node_version = "~18"
  }
    always_on = false
	minimum_tls_version = "1.2"
  }
  
}

output "webapp_name" {
  value = "${azurerm_windows_web_app.webapp.name}"
}
