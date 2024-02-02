This should contain all the files for managing TKC clusters and their corresponding apps in the respective vSphere Namespace
A common ArgoCD folder for the ArgoCD instance in this namespace

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
