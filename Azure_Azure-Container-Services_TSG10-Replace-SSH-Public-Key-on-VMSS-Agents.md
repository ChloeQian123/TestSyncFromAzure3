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
