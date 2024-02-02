This should contain all the files for managing TKC clusters and their corresponding apps in the respective vSphere Namespace
A common ArgoCD folder for the ArgoCD instance in this namespace

In my environment ArgoCD is deployed as vSphere pods in a specific vSphere pods. See here: https://github.com/papivot/argocd-gitops-tanzu  With ArgoCD the intentions are deploying and managing TKC clusters in this namespace and also the corresponding applications that should run on the respectivce TKC clusters.
So for this to work there will be two places the yamls needs to be applied: In the namespace ArgoCD itself is running (eg. confimaps related to ArgoCD) then in-cluster apply for the apps/services etc that I will deploy inside the tkc cluster. 

```bash

.
├── README.md
├── argocd
│   ├── applications
│   │   ├── app1.yaml
│   │   └── app2.yaml
│   └── projects
│       └── myproject.yaml
├── cluster-1
│   ├── cluster-readiness
│   │   └── pre-sync-hook-job.yaml
│   └── services
│       ├── foundational
│       │   ├── 01-namespace.yaml
│       │   ├── 02-database
│       │   │   ├── deployment.yaml
│       │   │   └── service.yaml
│       │   └── 03-message-queue
│       │       ├── deployment.yaml
│       │       └── service.yaml
│       └── applications
│           ├── app1
│           │   ├── deployment.yaml
│           │   └── service.yaml
│           └── app2
│               ├── deployment.yaml
│               └── service.yaml
```
