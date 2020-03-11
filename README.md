# Firepit

![Firepit Logo](./logo.jpg)


In order to increase confidence in automated deployments, infrastructure testing is required. _firepit_ provides a way to achieve this without the use of kitchen.



## Testing Overview for Infrastructure

There are three stages:

- Styling - The implementation of a tool such as Gruntwork means that a build service can fail more readily on styling checks. This is provided by Terraform natively with `terraform fmt -recursive -diff -check` which will result in an Exit Code 1 if the styling is not valid.

- Static Analysis. This is provided by Terraform natively with `terraform init -backend=false && terraform validate` which will result in an Exit Code 1 if the variables/types/etc. are not valid.

- Integration Testing. This is provided by Inspec, brought together with _firepit_, see below:

## Why not just use Kitchen

The industry standard is Kitchen, but unfortunately there is no way for Kitchen to pass an inspec target to the inspec provider (the `-t azure://` line in the [Inspec example](####Inspec) - thus, Kitchen runs inspec assuming an ssh transport:

```log
>>>>>> ------Exception-------
>>>>>> Class: Kitchen::ActionFailed
>>>>>> Message: 1 actions failed.
>>>>>>     Failed to complete #verify action: [Client error, can't connect to 'ssh' backend: You must provide a value for "host".] on default-azure
>>>>>> ----------------------
>>>>>> Please see .kitchen/logs/kitchen.log for more details
>>>>>> Also try running `kitchen diagnose --all` for configuration
```

AWS infrastructure testing sidesteps this with a dedicated `awsspec` provider, but such is not available at present for Azure.

## Installation

Prerequisites: Docker-CE, Terraform

### Install Ruby

Kitchen is entirely based in ruby, so this needs to be installed. For MacOS the command is `brew install ruby`

### Install Bundler

Kitchen requires a number of gems, these are most efficiently installed and managed using bundles, so run `gem install bundler`

### Install the kitchen Ruby gems via bundler

Run `bundle install` to install these gem bundles and their dependencies. If you want to know where the binaries are installed, run `bundle show X` to return the install path, normally the binaries are in `./bin/XXX` where XXX is the gem name. You may wish to add the relevant directory hosting inspec to your `$PATH` for simplicity.

## Authoring an InSpec profile for use with firepit

An example inspec profile is provided at `./firepit-example/`. In order to author your own, run `/usr/local/lib/ruby/gems/2.6.0/gems/inspec-3.9.3/bin/inspec init profile azure` where 'azure' is your profile name. This will create a default profile. Amend the `inspec.yml` file to include the following, noting the pinned inspec version:

```yml
inspec_version: '>= 3.9.3' # defaults to >v4
depends:
  - name: inspec-azure
    url: https://github.com/inspec/inspec-azure/archive/v1.9.2.tar.gz
supports:
  - platform: azure
```

And example control is as follows:

```ruby
control 'azurerm_virtual_machine' do
  describe azurerm_virtual_machine(resource_group: 'MyResourceGroup', name: 'firepit_example') do
    it                                { should exist }
    it                                { should have_monitoring_agent_installed }
    it                                { should_not have_endpoint_protection_installed([]) }
    it                                { should have_only_approved_extensions(['MicrosoftMonitoringAgent','LogAnalytics']) }
    its('type')                       { should eq 'Microsoft.Compute/virtualMachines' }
    its('installed_extensions_types') { should include('MicrosoftMonitoringAgent') }
    its('installed_extensions_names') { should include('LogAnalytics') }
  end
end
```

## Integrating with your pipeline

If it doesn't exist, add a `resources` top level block in your Azure DevOps pipeline, and a `repositories` sub-field. Add this repository as an entry, example below:

```yaml
resources:
  repositories:
  - repository: firepit
    type: github
    name: williamayerst/firepit
```

Call the file `templates/ado/job.yml@firepit` for a one-line integration with firepit in your build process.