/*
provider "azurerm" {
    version = "~>1.22"
}
*/

terraform {
  backend "azurerm" {
    storage_account_name  = "poccfstorek8s"
    container_name        = "terrablob"
    key                   = "cfazurek8s-management.tfstate"
  }
}