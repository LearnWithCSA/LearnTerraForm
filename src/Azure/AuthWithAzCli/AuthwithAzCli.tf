# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
      azapi = {
      source = "Azure/azapi"
      version = "0.4.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}

}

resource "azurerm_resource_group" "example" {
  name     = "${var.prefix}-resources"
  location = var.location
}

resource "azurerm_mssql_server" "example" {
  name                         = "${var.prefix}-server-primary"
  resource_group_name          = azurerm_resource_group.example.name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}

resource "azurerm_mssql_database" "example" {
  name      = "${var.prefix}-db-primary"
  server_id = azurerm_mssql_server.example.id
}

resource "azurerm_eventhub_namespace" "example" {
  name                = "${var.prefix}-EHN"
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "Standard"
}

resource "azurerm_eventhub" "example" {
  name                = "${var.prefix}-EH"
  namespace_name      = azurerm_eventhub_namespace.example.name
  resource_group_name = azurerm_resource_group.example.name
  partition_count     = 2
  message_retention   = 1
}

resource "azurerm_eventhub_namespace_authorization_rule" "example" {
  name                = "${var.prefix}EHRule"
  namespace_name      = azurerm_eventhub_namespace.example.name
  resource_group_name = azurerm_resource_group.example.name
  listen              = true
  send                = true
  manage              = true
}

resource "azurerm_monitor_diagnostic_setting" "example" {
  name                           = "${var.prefix}-DS"
  target_resource_id             = azurerm_mssql_database.example.id
  eventhub_authorization_rule_id = azurerm_eventhub_namespace_authorization_rule.example.id
  eventhub_name                  = azurerm_eventhub.example.name

  log {
    category = "SQLSecurityAuditEvents"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = false
    }
  }

  lifecycle {
    ignore_changes = [log, metric]
  }
}

resource "azurerm_mssql_database_extended_auditing_policy" "example" {
  database_id            = azurerm_mssql_database.example.id
  log_monitoring_enabled = true
}

resource "azurerm_mssql_server_extended_auditing_policy" "example" {
  server_id              = azurerm_mssql_server.example.id
  log_monitoring_enabled = true
}

resource "azapi_resource" "symbolicname" {
  type = "Microsoft.Sql/servers/extendedAuditingSettings@2021-11-01-preview"
  name = "default"
  parent_id = "/subscriptions/0e6e9ede-e794-4d39-bd16-cdc402faee39/resourceGroups/terrasql-resources/providers/Microsoft.Sql/servers/terrasql-server-primary"
  body = jsonencode({
    properties = {
      auditActionsAndGroups = [
        "SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP","FAILED_DATABASE_AUTHENTICATION_GROUP","BATCH_COMPLETED_GROUP"
      ]
      isAzureMonitorTargetEnabled = true
      isDevopsAuditEnabled = false
      isManagedIdentityInUse = false
      predicateExpression = "application_name='blabla' or application_name ='DataGrip'"
      queueDelayMs = 10
      retentionDays = 100
      state = "Enabled"
      storageAccountSubscriptionId = "00000000-0000-0000-0000-000000000000"

    }
  })
}