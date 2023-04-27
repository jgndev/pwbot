provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "jgn_apps_rg" {
  name     = "jgn-apps-rg"
  location = "centralus"
}

resource "azurerm_service_plan" "jgn_apps_sp" {
  name                = "jgn-pwbot-asp"
  location            = azurerm_resource_group.jgn_apps_rg.location
  resource_group_name = azurerm_resource_group.jgn_apps_rg.name
  sku_name            = "F1"
  os_type             = "Linux"
}

resource "azurerm_linux_web_app" "jgn_pwbot_app" {
  name                = "jgn-pwbot-app"
  location            = azurerm_resource_group.jgn_apps_rg.location
  resource_group_name = azurerm_resource_group.jgn_apps_rg.name
  service_plan_id     = azurerm_service_plan.jgn_apps_sp.id


  site_config {
    always_on = false

    application_stack {
      node_version = "18-lts"
    }
  }

  app_settings = {
    "REACT_APP_API_URL" = "https://ok1nscb8e2.execute-api.us-east-1.amazonaws.com/prod/passwords/"
  }
}

resource "azurerm_app_service_source_control" "jgn_pwbot_app" {
  app_id   = azurerm_linux_web_app.jgn_pwbot_app.id
  repo_url = "https://github.com/jgnovakdev/password-generator-frontend.git"
  branch   = "main"
}

output "site_url" {
  value = "https://${azurerm_linux_web_app.jgn_pwbot_app.default_hostname}"
}

