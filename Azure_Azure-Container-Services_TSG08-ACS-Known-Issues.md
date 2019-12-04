---
Tags:
- Confidentiality:Internal
- cw.Azure - TSG
- cw.Azure Container Service
---
[**Tags**](/Tags): [Azure](/Tags/Azure)  [Azure - TSG](/Tags/Azure-%2D-TSG)  [Azure Container Service](/Tags/Azure-Container-Service) 

## Summary

We will update the table with the information what we have seen in cases this year.

## Instruction

<table>
<colgroup>
<col style="width: 20%" />
<col style="width: 20%" />
<col style="width: 20%" />
<col style="width: 20%" />
<col style="width: 20%" />
</colgroup>
<thead>
<tr class="header">
<th>Sr. No</th>
<th>Issue</th>
<th>Symptom</th>
<th>Troubleshooting Steps</th>
<th>Solution</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="vertical-align:top">117091216319178,<br />
117091516343983,<br />
117091816354697,<br />
117091816352236<br />
</td>
<td style="vertical-align:top">Heapster
<p>pod crashes frequently.</p></td>
<td style="vertical-align:top">Heapster
<p>pod kept terminating and restarting</p></td>
<td style="vertical-align:top">Review heapster deployment
<p>file under add-on manager /etc/kubernetes/addons/kube-heapster-deployment.yaml</p></td>
<td style="vertical-align:top">Add line "addonmanager.kubernetes.io/mode:,EnsureExists" after line 18 in /etc/kubernetes/addons/kube-heapster-deployment.yaml.,New deployment (starting from,Sep. 20) does not have this issue.</td>
</tr>
<tr class="even">
<td style="vertical-align:top"><br />
</td>
<td style="vertical-align:top">Security vulnerability in the Kubernetes DNS server</td>
<td style="vertical-align:top">There was a security vulnerability in the Kubernetes DNS server announced:
<p>https://groups.google.com/forum/#!topic/kubernetes-dev/QWIzhD3JhhE</p></td>
<td style="vertical-align:top">The vulnerability is remotely executable from _within_ a cluster, but not from the general internet. Thus, given that the DNS server is inside a user's project and shielded from the Internet, users are not vulnerable to external attacks.</td>
<td style="vertical-align:top">Nonetheless, users likely want to upgrade their DNS servers to the latest version. To do this they need to do the following:
<p>* ssh into the master(s)</p>
<p>* edit '/etc/kubernetes/addons/kube-dns-deployment.yaml'</p>
<p>* find the container named 'dnsmasq'</p>
<p>* change the image from whatever it was to 'gcrio.azureedge.net/google_containers/k8s-dns-dnsmasq-nanny-amd64:1.14.5'</p>
<p>That should cause the DNS server to update.</p>
<p>They can validate with:</p>
<p>kubectl get pods --namespace kube-system -o jsonpath='{.items[*].spec.containers[?(@.name=="dnsmasq")].image}'</p>
<p>That should print:</p>
<p>gcrio.azureedge.net/google_containers/k8s-dns-dnsmasq-nanny-amd64:1.14.5</p>
<p>I should also say that once we release managed Kubernetes in ~1 month, this story will get _alot_ better.</p></td>
</tr>
<tr class="odd">
<td style="vertical-align:top"><br />
</td>
<td style="vertical-align:top"></td>
<td style="vertical-align:top"></td>
<td style="vertical-align:top"></td>
<td style="vertical-align:top"></td>
</tr>
<tr class="even">
<td style="vertical-align:top"><br />
</td>
<td style="vertical-align:top"></td>
<td style="vertical-align:top"></td>
<td style="vertical-align:top"></td>
<td style="vertical-align:top"></td>
</tr>
<tr class="odd">
<td style="vertical-align:top"><br />
</td>
<td style="vertical-align:top"></td>
<td style="vertical-align:top"></td>
<td style="vertical-align:top"></td>
<td style="vertical-align:top"></td>
</tr>
<tr class="even">
<td style="vertical-align:top"><br />
</td>
<td style="vertical-align:top"></td>
<td style="vertical-align:top"></td>
<td style="vertical-align:top"></td>
<td style="vertical-align:top"></td>
</tr>
<tr class="odd">
<td style="vertical-align:top"><br />
</td>
<td style="vertical-align:top"></td>
<td style="vertical-align:top"></td>
<td style="vertical-align:top"></td>
<td style="vertical-align:top"></td>
</tr>
<tr class="even">
<td style="vertical-align:top"><br />
</td>
<td style="vertical-align:top"></td>
<td style="vertical-align:top"></td>
<td style="vertical-align:top"></td>
<td style="vertical-align:top"></td>
</tr>
<tr class="odd">
<td style="vertical-align:top"><br />
</td>
<td style="vertical-align:top"></td>
<td style="vertical-align:top"></td>
<td style="vertical-align:top"></td>
<td style="vertical-align:top"></td>
</tr>
</tbody>
</table>
