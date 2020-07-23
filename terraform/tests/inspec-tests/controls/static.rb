resource_group = 'firepit-example'

describe azurerm_resource_groups do
    its('names') { should include resource_group }
  end
