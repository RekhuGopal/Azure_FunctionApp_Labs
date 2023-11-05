resource "azurerm_resource_group" "example" {
  name     = "example-group"
  location = var.location
}

resource "azurerm_storage_account" "example" {
  name                     = "${var.prefix}exama"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "example" {
  name                = "example-service-plan"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  os_type             = "Linux"
  sku_name            = "S1"
}

data "archive_file" "function" {
  type        = "zip"
  source_dir  = "${path.module}/CRUDAPI/"
  output_path = "${path.module}/function.zip"
}

resource "azurerm_application_insights" "funcdeploy" {
  name                = "${var.prefix}-appinsights"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  application_type    = "web"

  tags = {
    "hidden-link:${azurerm_resource_group.example.id}/providers/Microsoft.Web/sites/${var.prefix}func" = "Resource"
  }

}


resource "azurerm_linux_function_app" "example" {
  name                = "cloudquicklabs-func-app2"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  service_plan_id     = azurerm_service_plan.example.id

  storage_account_name       = azurerm_storage_account.example.name
  storage_account_access_key = azurerm_storage_account.example.primary_access_key

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "python"
    WEBSITE_WORKER_INDEX = "1"
    FUNCTIONS_EXTENSION_VERSION = "~4"
    SCM_DO_BUILD_DURING_DEPLOYMENT = "1"
    APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.funcdeploy.instrumentation_key
  }

  site_config {
    application_stack {
      python_version = "3.9"
    }
    cors {
      allowed_origins     = ["https://portal.azure.com"]
      support_credentials = true
    }
  }
}

/*
resource "azurerm_function_app_function" "example" {
  name            = "demofunc2"
  function_app_id = azurerm_linux_function_app.example.id
  language        = "Python"
  file {
    name    = "function_app.py"
    content = file("CRUDAPI/function_app.py")
  }
  file {
    name    = "host.json"
    content = file("CRUDAPI/host.json")
  }
  file {
    name    = "requirements.txt"
    content = file("CRUDAPI/requirements.txt")
  }
  test_data = jsonencode({
    "name" = "Azure"
  })
  config_json = jsonencode({
    "bindings" = [
      {
        "authLevel" = "function"
        "direction" = "in"
        "methods" = [
          "get",
          "post",
        ]
        "name" = "req"
        "type" = "httpTrigger"
      },
      {
        "direction" = "out"
        "name"      = "$return"
        "type"      = "http"
      },
    ]
  })
}
*/