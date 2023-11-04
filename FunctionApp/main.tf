resource "azurerm_resource_group" "funcdeploy" {
  name     = "rg-${var.prefix}-function"
  location = var.location
}

resource "azurerm_storage_account" "funcdeploy" {
  name                     = "${var.prefix}storage"
  resource_group_name      = azurerm_resource_group.funcdeploy.name
  location                 = azurerm_resource_group.funcdeploy.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "funcdeploy" {
  name                  = "contents"
  storage_account_name  = azurerm_storage_account.funcdeploy.name
  container_access_type = "private"
}

data "archive_file" "function" {
  type        = "zip"
  source_dir  = "${path.module}/FunctionApp/CRUDAPI/"
  output_path = "${path.module}/functions.zip"
}

resource "azurerm_storage_account" "storage_account_functionApp_function" {
  name                     = "${var.prefix}storagefunction"
  resource_group_name      = azurerm_resource_group.funcdeploy.name
  location                 = azurerm_resource_group.funcdeploy.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "storage_container_function" {
  name                  = "function-releases"
  storage_account_name  = azurerm_storage_account.storage_account_functionApp_function.name
}

resource "azurerm_storage_blob" "storage_blob_function" {
  name                   = "functions-${substr(data.archive_file.function.output_md5,0,6)}.zip"
  storage_account_name   = azurerm_storage_account.storage_account_functionApp_function.name
  storage_container_name = azurerm_storage_container.storage_container_function.name
  type                   = "Block"
  content_md5            = data.archive_file.function.output_md5
  source                 = "${path.module}/functions.zip"
}

resource "azurerm_application_insights" "funcdeploy" {
  name                = "${var.prefix}-appinsights"
  location            = azurerm_resource_group.funcdeploy.location
  resource_group_name = azurerm_resource_group.funcdeploy.name
  application_type    = "web"

  tags = {
    "hidden-link:${azurerm_resource_group.funcdeploy.id}/providers/Microsoft.Web/sites/${var.prefix}func" = "Resource"
  }

}

resource "azurerm_app_service_plan" "funcdeploy" {
  name                = "${var.prefix}-functions-consumption-asp"
  location            = azurerm_resource_group.funcdeploy.location
  resource_group_name = azurerm_resource_group.funcdeploy.name
  kind                = "FunctionApp"
  reserved            = true

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "funcdeploy" {
  name                       = "${var.prefix}func"
  location                   = azurerm_resource_group.funcdeploy.location
  resource_group_name        = azurerm_resource_group.funcdeploy.name
  app_service_plan_id        = azurerm_app_service_plan.funcdeploy.id
  storage_account_name       = azurerm_storage_account.funcdeploy.name
  storage_account_access_key = azurerm_storage_account.funcdeploy.primary_access_key
  https_only                 = true
  version                    = "~4"
  os_type                    = "linux"
  app_settings = {
      "FUNCTIONS_WORKER_RUNTIME" = "python"
      "WEBSITE_RUN_FROM_PACKAGE"   = azurerm_storage_blob.storage_blob_function.url
      "APPINSIGHTS_INSTRUMENTATIONKEY" = "${azurerm_application_insights.funcdeploy.instrumentation_key}"
      "APPLICATIONINSIGHTS_CONNECTION_STRING" = "InstrumentationKey=${azurerm_application_insights.funcdeploy.instrumentation_key};IngestionEndpoint=https://japaneast-0.in.applicationinsights.azure.com/"
  }

  site_config {
        linux_fx_version= "Python|3.8"        
        ftps_state = "Disabled"
    }

  identity {
    type = "SystemAssigned"
   }
}

resource "azurerm_role_assignment" "role_assignment_storage" {
  scope                            = azurerm_storage_account.storage_account_function.id
  role_definition_name             = "Storage Blob Data Contributor"
  principal_id                     = azurerm_function_app.funcdeploy.identity.0.principal_id
  skip_service_principal_aad_check = true
}