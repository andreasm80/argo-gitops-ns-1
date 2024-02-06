This should contain all the files for managing TKC clusters and their corresponding apps in the respective vSphere Namespace
A common ArgoCD folder for the ArgoCD instance in this namespace

In my environment ArgoCD is deployed as vSphere pods in a specific vSphere Namespace. See here: https://github.com/papivot/argocd-gitops-tanzu  With ArgoCD the intentions are deploying and managing TKC clusters in this namespace and also the corresponding applications that should run on the respectivce TKC clusters.
So for this to work there will be two places the yamls needs to be applied: In the vSphere namespace ArgoCD itself is running in (eg. confimaps related to ArgoCD) then in-cluster apply for the apps/services etc that I will deploy inside the tkc cluster. 

Below is the folder structure I am using. Each TKC cluster gets its own folder with corresponding subfolder for unique settings pr cluster. Then I have a tkc-cluster-template folder that is being used to create the corresponding argocd yaml to deploy my tkc-cluster based on the settings I am being prompted for. Then it will create a dedicated folder for this specific cluster, eg. tkc-cluster-1, tkc-cluster-2, tkc-cluster-3 etc..

```bash

.
├── README.md
├── setup-cluster.sh
├── argocd
│   ├── argo-tkc-cluster-1-deployment.yaml
│   ├── argo-tkc-cluster-2-deployment.yaml
│   └── projects
│       └── myproject.yaml
├── tkc-cluster-template
│   ├── antrea-config-1.yaml
│   ├── kustomization.yaml
│   ├── tkgs-cluster-class-noaz-2.yaml
│   ├── argocd-tkc-1-base-app-env-3.yaml
│   ├── argocd-tkc-1-base-app-cm-5.yaml
│   └── applications
│       ├── gatekeeper-tkc-1
│       │   ├── create-ns.yaml
│       │   ├── gatekeeper.yaml
│       │   ├── kustomization.ya
│       │   └── mutation-psa-policy.yaml
│       └── foundational
│           ├── ako
│           │   ├── ako-inject-secret-5.yaml
│           │   ├── ako-secret-role-2.yaml
│           │   ├── ako-secret-rolebinding-3.yaml
│           │   ├── ako-secret-sa-1.yaml
│           │   ├── kustomization.yaml
│           │   └── tkc-pv-pvc-4.yaml
│           └── repos
│               ├── argocd-ako-repo.yaml
│               └── argocd-nfs-repo.yaml
├── tkc-cluster-1
│   ├── antrea-config-1.yaml
│   ├── kustomization.yaml 
│   ├── tkgs-cluster-class-noaz-2.yaml
│   ├── argocd-tkc-1-base-app-env-3.yaml
│   ├── argocd-tkc-1-base-app-cm-5.yaml
│   └── applications
│       ├── gatekeeper-tkc-1
│       │   ├── create-ns.yaml
│       │   ├── gatekeeper.yaml
│       │   ├── kustomization.ya
│       │   └── mutation-psa-policy.yaml
│       └── foundational
│           ├── ako
│           │   ├── ako-inject-secret-5.yaml
│           │   ├── ako-secret-role-2.yaml
│           │   ├── ako-secret-rolebinding-3.yaml
│           │   ├── ako-secret-sa-1.yaml
│           │   ├── kustomization.yaml
│           │   └── tkc-pv-pvc-4.yaml
│           └── repos
│               ├── argocd-ako-repo.yaml
│               └── argocd-nfs-repo.yaml
```
