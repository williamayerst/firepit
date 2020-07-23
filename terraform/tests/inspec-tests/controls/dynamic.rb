##########################################################################################
# Initialise Tests
##########################################################################################
require 'json'

title 'Azure Infrastructure Tests'

##########################################################################################
# Parse and load the vars.tf.json file 
##########################################################################################
# Parse and load our terraform variable file into hash table called vars
content = File.read('../example/vars.tf.json')

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

##########################################################################################
# Run InSpec Tests
##########################################################################################

control 'azurerm_infrastructure' do

  impact 1.0
  title 'Check the properties of the resources' 
  desc 'A set of tests to ensure the infrastructure is built to the correct properties'

  # Start the tests
  describe azurerm_resource_groups do
      its('names') { should include resource_group_name }
    end

end

##########################################################################################