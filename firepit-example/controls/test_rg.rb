require 'rhcl'
main_terraform = Rhcl.parse(File.open('vault.tf'))
rg_name = main_terraform['resource']['azurerm_key_vault']['resource_group_name']
rg_location = main_terraform['resource']['azurerm_key_vault']['location']
vault_name = main_terraform['resource']['azurerm_key_vault']['name']
puts_test = "test"

puts "start"
puts puts_test
puts rg_name
puts rg_location
puts vault_name
puts "end"

describe azurerm_key_vault(resource_group: (rg_name.to_s), vault_name: (vault_name.to_s)) do
      it            { should exist }
      its('location')   { should eq(rg_location.to_s) }
    end

