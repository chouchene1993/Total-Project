locals {

  resource_group_tags = {
    Environment     = data.azurerm_resource_group.rg.tags["Environment"]
    ApplicationName = data.azurerm_resource_group.rg.tags["ApplicationName"]
    ApplicationCode = data.azurerm_resource_group.rg.tags["ApplicationCode"]
    Branch          = data.azurerm_resource_group.rg.tags["Branch"]
    Exploitation    = data.azurerm_resource_group.rg.tags["Exploitation"]
    SecurityLevel   = data.azurerm_resource_group.rg.tags["SecurityLevel"]
  }
  l_cloud_code    = "az"
  mssql_server_name = format("%ssq%s%s%s", local.l_cloud_code, local.resource_group_tags["Environment"], local.resource_group_tags["ApplicationCode"], "01")
  mssql_db_name     = format("%sdb%s%s%s", local.l_cloud_code, local.resource_group_tags["Environment"], local.resource_group_tags["ApplicationCode"], "01")

}

### SQL Database ##########

resource "azurerm_mssql_database" "azdmssqlrtmb01" {

  name                = local.mssql_db_name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  server_name         = local.mssql_server_name
  tags                = data.azurerm_resource_group.rg.tags
}

### SQL Server ####

resource "azurerm_mssql_server" "azmssqlsrtmb01" {

  name                = local.mssql_server_name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  version             = "12.0"

  administrator_login          = "mssqladmin"
  administrator_login_password = random_password.admin_password.result
  tags                         = data.azurerm_resource_group.rg.tags
}

resource "random_password" "admin_password" {
  length           = 30
  special          = true
  override_special = "_%?!#()-[]<>*@="
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
}

resource "azurerm_key_vault_secret" "save_admin_secret_into_a_key_vault" {
  key_vault_id = data.azurerm_key_vault.kv.id
  name         = "RTMB-SQL-PASSWORD"
  value        = random_password.admin_password.result
}



resource "azurerm_key_vault_secret" "save_mssql_server_connection_string_password_into_a_key_vault" {
  key_vault_id = data.azurerm_key_vault.kv.id
  name         = "RTMB-SQL-CONN-ODBC"
  value        = format("Driver={ODBC Driver 17 for SQL Server};Server=tcp:%s.database.windows.net,1433;Database=%s;Uid=%s;Pwd=%s;Encrypt=yes;TrustServerCertificate=no;", local.sql_server_name, local.sql_db_name, azurerm_sql_server.azsqlsrtmb01.administrator_login, random_password.admin_password.result)

}


resource "azurerm_key_vault_secret" "rtmb-mssqldb-name" {
  key_vault_id = data.azurerm_key_vault.kv.id
  name         = "RTMB-SQL-DATABASE"
  value        = azurerm_mssql_database.azdmssqlrtmb01.name
}


resource "azurerm_key_vault_secret" "mssql_db_username" {
  key_vault_id = data.azurerm_key_vault.kv.id
  name         = "RTMB-SQL-USERNAME"
  value        = azurerm_mssql_server.azmssqlsrtmb01.administrator_login
}


resource "azurerm_mssql_firewall_rule" "fr1" {
  name                = "fr1"
  resource_group_name = data.azurerm_resource_group.rg.name
  server_name         = azurerm_mssql_server.azmssqlsrtmb01.name
  start_ip_address    = "52.174.138.4"
  end_ip_address      = "52.174.138.4"
}



