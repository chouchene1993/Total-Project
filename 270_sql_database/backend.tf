terraform {
  backend "azurerm" {
<<<<<<< HEAD
=======

    resource_group_name  = "azrgd-rtmassbalance-01"
    storage_account_name = "azstdrtmb01"
    container_name       = "azctdrtmb03"
    key                  = "d-270_sql_database.tfstate"
>>>>>>> main
  }
}