---
Tags:
- cw.Azure
- cw.Azure - TSG
- Confidentiality:Internal
---
[**Tags**](/Tags): [Azure](/Tags/Azure)  [Azure - TSG](/Tags/Azure-%2D-TSG)  [Azure Container Service](/Tags/Azure-Container-Service) 

## Symptoms

Unable to connect to Kubernetes Cluster Windows/Linux Deployment.  
Using:  
az acs kubernetes get-credentials --resource-group=\<cluster-resource-group\> --name=\<cluster-name\>  

``` 
 Authentication failed.
 Traceback (most recent call last):
 File '/Users/guesslin/lib/azure-cli/lib/python2.7/site-packages/azure/cli/main.py', line 37, in main
   cmd_result = APPLICATION.execute(args)
 File '/Users/guesslin/lib/azure-cli/lib/python2.7/site-packages/azure/cli/core/application.py', line 157, in execute
   result = expanded_arg.func(params)
 File '/Users/guesslin/lib/azure-cli/lib/python2.7/site-packages/azure/cli/core/commands/__init__.py', line 343, in _execute_command
   raise ex
 AuthenticationException: Authentication failed.
```

## Resolution

1\. In this case, customer did not save the private key to local.

2\. For az acs kubernetes get-credentials to work properly, private key need to be specified ( default directory is \~/.ssh/id\_rsa)
