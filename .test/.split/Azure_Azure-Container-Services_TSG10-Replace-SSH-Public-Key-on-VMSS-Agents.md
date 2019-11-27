---
Tags:
- cw.Azure
- cw.Azure - TSG
- cw.Azure Container Service
---
[**Tags**](/Tags): [Azure](/Tags/Azure)  [Azure - TSG](/Tags/Azure-%2D-TSG)  [Azure Container Service](/Tags/Azure-Container-Service) 

[[_TOC_]]

### Overview

This TSG is intended to give the steps necessary to replace the public ssh-key for an existing user, or add a new user to the instances of a Virtual Machine Scaleset.

::: Confidentiality:Internal


### Level

Intermediate
:::

::: Confidentiality:Internal
### Prerequisite

Azure CLI 2.x needs to be installed on an existing local PC, or use Azure Cloud Shell instead
:::

### Additional Docu

More details about the VMAccessExtension are available on the github [page](https://github.com/Azure/azure-linux-extensions/tree/master/VMAccess)

### Steps To Do

#### Find out the name of the VMSS that needs to be modified

    az vmss list --resource-group <rg-name> --query [*].name --output table

i.e.

> az vmss list --resource-group dcos1 --query \[\*\].name --output table

> Result

> \---------------------------------

> dcos-agent-private-E3102829-vmss0

> dcos-agent-public-E3102829-vmss0

*Please note down the name of the VMSS you need to alter. In the sample above two VMSS names are returned.*

*We assume that only the public agents (dcos-agent-public-E3102829-vmss0) need to be altered*

::: Confidentiality:Internal
#### Create The new SSH-Public Key

On an existing Linux VM, or on Azure cloud Shell, create a new a new ssh-key pair

i.e.

    ssh-keygen -f admin-N "" -C admin

This creates a new ssh-key pair for the user 'newuser' without a passphrase the keys are store in the file admin and admin.pub

### Update the existing user with a new ssh-public-key

To update the existing ssh-public-key for an existing user it is required to create a special JSON file first

The content of the JSON file is the following

> {

> "username": "currentusername",

> "ssh\_key": "contentofsshkey"

> }

In order to update the existing ssh-public-key with the new previously created create a file, i.e. newkey.json, like this one

> {

> "username": "admin",

> "ssh\_key": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDYNgKGdXyr+6VFbf8gsklApnqkJSap20vr0cAVqVNHcEvukI2hnQhVGZMoxPSo1Li8i0WyUFIJGO

> \+ZME8hH/jafn3LLXQhnXJBcAOtPmPvQg6Izi2s/ir749Nh3YbDfxgU/s/Wx805XlN9Ei8yIFlK/4hM3EENodAGSNLI9CuELGIfWgaA4pdA/SanekR54k71

> UcQUafu1gt211JGe1i5QjJkt5pIiiw8Qbk8eBsbAkNNLO1is4euiMrMLbKdxWLBHK9HVfXXUAJH6BhxEz2l3TccX+JHbGrdjWuPdsoBff2bxXX1X2TbPWwx

> PcxJ5TB5jA00ohNZyxNMGZFlJA5hl"

> }

`Note: The ssh_key property shows linebreakes which do not exists of course, they are only inserted to increase the readability!`

After preparation of the newkey.json file the modification get applied to the VMSS-Agents. To do this tow further stesp need to be executed.

#### Apply

> az vmss extension set --name VMAccessForLinux --publisher Microsoft.OSTCExtensions --version 1.4 --resource-group \<rg-name\> --vmss-name \<VMSS-name\_from\_the\_first\_step\> --protected-settings newkey.json

i.e.

    az vmss extension set --name VMAccessForLinux --publisher Microsoft.OSTCExtensions  --version 1.4 --resource-group dcos1--vmss-name dcos-agent-public-E3102829-vmss0 --protected-settings newkey.json

:::

#### Commit

The last and final steps is to 'commit' the modifications. Without this step the intended modification is not applied\!

> az vmss update-instances --resource-group \<rg-name\>--name \<VMSS-name\_from\_the\_first\_step\> --instance-ids "\*"

The option '--instance-ids' controls on what agent-node the commit has to be performed. Usually all agents are intended to be updated. In that case use the asterisk.

i.e.

``` 
   az vmss update-instances --resource-group dcos1 --name dcos-agent-public-E3102829-vmss0 --instance-ids "*"
```

After these steps it is now possible to login with the new ssh-private-key which get verified with the added/changed ssh-public-key.

*The same steps described can also be used to add a new user to each of the VMSS nodes. Which means in case the user 'admin' does not exists it is created and gets sudo rights granted.*





