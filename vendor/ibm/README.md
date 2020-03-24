kcdt on ibm cloud
=================

### prereqs

In your kubernetes cluster enable block storage to support your volume claims.
https://cloud.ibm.com/docs/containers?topic=containers-block_storage 

### install

```
$ kubectl apply -f ibmcloud.yaml
```