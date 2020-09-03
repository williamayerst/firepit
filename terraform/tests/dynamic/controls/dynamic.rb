##########################################################################################
# Initialise Tests
##########################################################################################
require 'json'

title 'Azure Infrastructure Tests'

##########################################################################################
# Parse and load the vars.tf.json file 
##########################################################################################
# Parse and load our terraform variable file into hash table called vars
content = File.read('../vars.tf.json')

# Convert this to a hashtable
vars = JSON.parse(content)
varfile = vars['variable']

# Function to search through the hashtable
def get_element(hash, index)
	hash.find { |value|
		! value[index].nil?
	}[index][0]["default"]
end


##########################################################################################
# Query Terraform Var File for Resource Names
##########################################################################################

resource_group_name = get_element(varfile, 'resource_group_name')
nsg_name = get_element(varfile, 'nsg_name')

##########################################################################################
# Run InSpec Tests
##########################################################################################

control 'dynamic_rg_config' do

  impact 1.0
  title 'Check the properties of the resources' 
  desc 'A set of dynamic tests to ensure the infrastructure is built to the correct properties'

  # Start the tests
  describe azurerm_resource_groups do
      its('names') { should include resource_group_name }
    end
end

control 'dynamic_nsg_config' do

  impact 1.0
  title 'Check the properties of the NSGs' 
  desc 'A set of dynamic tests to ensure the NSG is built to the correct properties'

  describe azurerm_network_security_group(resource_group: resource_group_name, name: nsg_name) do
    it                            { should exist }
    its('type')                   { should eq 'Microsoft.Network/networkSecurityGroups' }
    its('security_rules')         { should_not be_empty }
    its('default_security_rules') { should_not be_empty }
    it                            { should_not allow_rdp_from_internet }
    it                            { should_not allow_ssh_from_internet }
  end
end


##########################################################################################



