---
Tags:
- Confidentiality:Internal
- cw.Azure - TSG
- cw.Azure Container Service
---
[**Tags**](/Tags): [Azure](/Tags/Azure)  [Azure - TSG](/Tags/Azure-%2D-TSG)  [Azure Container Service](/Tags/Azure-Container-Service) 

## Summary

Collect general logs for Kubernetes troubleshooting

## Instruction

Collect the logs below and upload to Workspace for further analysis.

On Master   

<div>

1\. curl ifconfig.co  

2\. sudo cat /etc/\*release\*  
3\. sudo cat /var/log/azure/cluster-provision.log  
4\. sudo docker version  
5\. sudo docker ps  
6\. sudo journalctl -u kubelet --no-pager  
7\. kubectl version  
8\. kubectl get nodes -o yaml  
9\. kubectl describe nodes  
10\. kubectl get pods --all-namespaces  
11\. kubectl get services --all-namespaces  

</div>

 
On Agent   

<div>

1\. curl ifconfig.co  

2\. sudo cat /etc/\*release\*  
3\. sudo cat /var/log/azure/cluster-provision.log  
4\. sudo docker version  
5\. sudo docker ps  
6\. sudo journalctl -u kubelet --no-pager  

</div>
