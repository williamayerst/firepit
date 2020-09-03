resource_group_name = 'firepit-example'
nsg_name = 'firepit-example-nsg'

##########################################################################################
# Run InSpec Tests
##########################################################################################

control 'static_rg_config' do

  impact 1.0
  title 'Check the properties of the resource groups' 
  desc 'A set of static tests to ensure the RG is built to the correct config'

  # Start the tests
  describe azurerm_resource_groups do
      its('names') { should include resource_group_name }
    end
end

control 'static_nsg_config' do

  impact 1.0
  title 'Check the properties of the NSGs' 
  desc 'A set of static tests to ensure the NSG is built to the correct properties'

  describe azurerm_network_security_group(resource_group: resource_group_name, name: nsg_name) do
    it                            { should exist }
    its('type')                   { should eq 'Microsoft.Network/networkSecurityGroups' }
    its('security_rules')         { should_not be_empty }
    its('default_security_rules') { should_not be_empty }
    # it                            { should_not allow_rdp_from_internet }
    # it                            { should_not allow_ssh_from_internet }
  end
end


##########################################################################################
