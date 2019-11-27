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
### Prerequisite

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

i.e.

``` 
   az vmss update-instances --resource-group dcos1 --name dcos-agent-public-E3102829-vmss0 --instance-ids "*"
```

After these steps it is now possible to login with the new ssh-private-key which get verified with the added/changed ssh-public-key.

*The same steps described can also be used to add a new user to each of the VMSS nodes. Which means in case the user 'admin' does not exists it is created and gets sudo rights granted.*
