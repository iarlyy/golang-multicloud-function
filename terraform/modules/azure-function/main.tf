data "local_file" "function" {
  count    = var.create ? 1 : 0
  filename = var.dist_file
}

resource "azurerm_resource_group" "rg" {
  count    = var.create ? 1 : 0
  name     = var.name
  location = var.region
}

resource "azurerm_storage_account" "function_assets" {
  count                    = var.create ? 1 : 0
  location                 = azurerm_resource_group.rg[0].location
  resource_group_name      = azurerm_resource_group.rg[0].name
  name                     = "${var.name}assets"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "function_sc" {
  count                 = var.create ? 1 : 0
  name                  = "${var.name}-sc"
  storage_account_name  = azurerm_storage_account.function_assets[0].name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "function_blob" {
  count                  = var.create ? 1 : 0
  name                   = "${filesha256(data.local_file.function[0].filename)}.zip"
  storage_account_name   = azurerm_storage_account.function_assets[0].name
  storage_container_name = azurerm_storage_container.function_sc[0].name
  type                   = "Block"
  source                 = data.local_file.function[0].filename
}

data "azurerm_storage_account_blob_container_sas" "function_blob_container_sas" {
  count             = var.create ? 1 : 0
  connection_string = azurerm_storage_account.function_assets[0].primary_connection_string
  container_name    = azurerm_storage_container.function_sc[0].name

  start  = "2021-01-01T00:00:00Z"
  expiry = "2022-01-01T00:00:00Z"

  permissions {
    read   = true
    add    = false
    create = false
    write  = false
    delete = false
    list   = false
  }
}

resource "azurerm_app_service_plan" "sp" {
  count               = var.create ? 1 : 0
  location            = azurerm_resource_group.rg[0].location
  resource_group_name = azurerm_resource_group.rg[0].name
  name                = "${var.name}-sp"
  kind                = "functionapp"
  reserved            = true

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "this" {
  count                      = var.create ? 1 : 0
  name                       = var.name
  location                   = azurerm_resource_group.rg[0].location
  resource_group_name        = azurerm_resource_group.rg[0].name
  app_service_plan_id        = azurerm_app_service_plan.sp[0].id
  storage_account_name       = azurerm_storage_account.function_assets[0].name
  storage_account_access_key = azurerm_storage_account.function_assets[0].primary_access_key
  version                    = "~3"
  os_type                    = "linux"
  https_only                 = true

  site_config {
    use_32_bit_worker_process = false
  }

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "Custom"
    FUNCTION_APP_EDIT_MODE   = "readonly"
    HASH                     = base64encode(filesha256(data.local_file.function[0].filename))
    WEBSITE_RUN_FROM_PACKAGE = "https://${azurerm_storage_account.function_assets[0].name}.blob.core.windows.net/${azurerm_storage_container.function_sc[0].name}/${azurerm_storage_blob.function_blob[0].name}${data.azurerm_storage_account_blob_container_sas.function_blob_container_sas[0].sas}",
    #AzureWebJobsStorage         = azurerm_storage_account.function_assets[0].primary_connection_string
    AzureWebJobsDisableHomepage = "true",
  }

  depends_on = [
    azurerm_app_service_plan.sp
  ]
}
