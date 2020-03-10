resource_group = 'ecmkitchenrgpcieuw'

control 'azure_network_security_group' do
  describe azure_network_security_group(resource_group: resource_group, name: 'nsg') do
    it                            { should exist }
    its('type')                   { should eq 'Microsoft.Network/networkSecurityGroups' }
    its('security_rules')         { should_not be_empty }
    its('default_security_rules') { should_not be_empty }
    it                            { should_not allow_rdp_from_internet }
    it                            { should_not allow_ssh_from_internet }
  end
end

