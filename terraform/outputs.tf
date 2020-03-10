output "rg-name" {
  value = azurerm_resource_group.rg.name
}

output "nsg-name" {
  value = azurerm_network_security_group.nsg.name
}
