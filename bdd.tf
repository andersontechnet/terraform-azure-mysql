resource "random_id" "mysql_name" {
  byte_length = 9
}

resource "random_string" "mysql_pwd" {
  length  = 9
  special = true
}

resource "random_string" "mysql_login" {
  length  = 8
  special = false
  number  = false
  upper   = false
  lower   = true
}

locals {
  common_tags = {
    environment = "${var.environment}"
    project     = "${var.project}"
    owner       = "${var.owner}"
  }

  extra_tags = {
    support = "${var.support}"
  }
}

resource "azurerm_resource_group" "rgwp" {
  name     = "${var.website}.com"
  location = "${var.ARM_REGION}"
  tags     = "${merge(local.common_tags, local.extra_tags)}"
}

resource "azurerm_mysql_server" "mysqlserv" {
  name                = "${var.db_server}"
  location            = "${azurerm_resource_group.rgwp.location}"
  resource_group_name = "${azurerm_resource_group.rgwp.name}"
  tags                = "${merge(local.common_tags, local.extra_tags)}"

  sku {
    name     = "B_Gen5_1"
    capacity = 1
    tier     = "Basic"
    family   = "Gen5"
  }

  storage_profile {
    storage_mb            = 5120
    backup_retention_days = 7
    geo_redundant_backup  = "Disabled"
  }

  administrator_login          = "${random_string.mysql_login.result}"
  administrator_login_password = "${random_string.mysql_pwd.result}"
  version                      = "5.7"
  ssl_enforcement              = "disabled"
}

resource "azurerm_mysql_database" "mysqldb" {
  name                = "${var.db_name}"
  resource_group_name = "${azurerm_resource_group.rgwp.name}"
  server_name         = "${azurerm_mysql_server.mysqlserv.name}"
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

resource "azurerm_mysql_firewall_rule" "terraFWRULE" {
  name                = "office"
  resource_group_name = "${azurerm_resource_group.rgwp.name}"
  server_name         = "${azurerm_mysql_server.mysqlserv.name}"
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}
