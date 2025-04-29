terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0.0"
    }
  }
  required_version = ">= 0.14.9"
}

variable "suscription_id" {
    type = string
    description = "Azure subscription id"
}

variable "sqladmin_username" {
    type = string
    description = "Administrator username for server"
}

variable "sqladmin_password" {
    type = string
    description = "Administrator password for server"
}

provider "azurerm" {
  features {}
  subscription_id = var.suscription_id
}

# Generate a random integer to create a globally unique name
resource "random_integer" "ri" {
  min = 100
  max = 999
}

# Create the resource group
resource "azurerm_resource_group" "rg" {
  name     = "upt-arg-${random_integer.ri.result}"
  location = "Brazil South"
}

resource "azurerm_mssql_server" "sqlsrv" {
  name                         = "upt-dbs-${random_integer.ri.result}"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = var.sqladmin_username
  administrator_login_password = var.sqladmin_password
}

resource "azurerm_mssql_firewall_rule" "sqlaccessrule" {
  name             = "PublicAccess"
  server_id        = azurerm_mssql_server.sqlsrv.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}

resource "azurerm_mssql_database" "sqldb" {
  name      = "BaseEmpleados"
  server_id = azurerm_mssql_server.sqlsrv.id
  sku_name = "Basic"
}