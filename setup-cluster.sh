#!/bin/bash

# Prompt for the cluster name
echo "What is the cluster name?"
read cluster_name

# Prompt for the vSphere Namespace Name
echo "What is the vSphere Namespace Name?"
read vsphere_namespace

# New prompts for AKO configuration
echo "What is the path to your NSX Tier-1 router for AKO configuration - (full path eg \"/infra/tier-1s/tier-x\")"
read nsx_t1_router

echo "What is the VIP network name configured in Avi?"
read vip_network_name

echo "What is the VIP network cidr?"
read vip_network_cidr

# Validate input for default ingress controller
while true; do
    echo "Do you want AKO to be the default ingress controller? true/false"
    read default_ing_controller
    if [[ "$default_ing_controller" == "true" || "$default_ing_controller" == "false" ]]; then
        break
    else
        echo "Invalid input. Please type 'true' or 'false'."
    fi
done

echo "What is the Service Engine Group name"
read se_group_name

echo "What is the Cloud name in Avi you want to use?"
read cloud_name

echo "What is the controller IP/DNS?"
read controller_host

# Define the path for the argocd-nfs-repo.yaml file in the applications/foundational/repos directory
argocd_nfs_repo_path="./${cluster_name}/applications/foundational/repos/argocd-nfs-repo.yaml"

# Define the path for the argocd-ako-repo.yaml file in the applications/foundational/repos directory
argocd_ako_repo_path="./${cluster_name}/applications/foundational/repos/argocd-ako-repo.yaml"

# Define original and new paths for the applications/gatekeeper-tkc-1 folder within the newly created cluster directory
original_gatekeeper_path="./${cluster_name}/applications/gatekeeper-tkc-1"
new_gatekeeper_path="./${cluster_name}/applications/gatekeeper-${cluster_name}"


# Define the source and destination directories
src_dir="tkc-cluster-template"
dest_dir="${cluster_name}"

# Copy the tkc-cluster-template directory to a new directory with the cluster name
cp -r "$src_dir" "$dest_dir"

# Define the original path for the argocd-tkc-deploy.yaml file in the argocd folder at root level
original_argocd_tkc_deploy_path="./argocd/argocd-tkc-deploy.yaml"

# Define the new file name and path within the same argocd folder
new_argocd_tkc_deploy_file="argo-${cluster_name}-deployment.yaml"
new_argocd_tkc_deploy_path="./argocd/${new_argocd_tkc_deploy_file}"

# Define paths to the YAML files in the new directory
antrea_config_path="${dest_dir}/antrea-config-1.yaml"
argocd_tkc_base_app_env_path="${dest_dir}/argocd-tkc-base-app-env-3.yaml"
tkgs_cluster_class_path="${dest_dir}/tkgs-cluster-class-2.yaml"
argocd_tkc_base_app_cm_path="${dest_dir}/argocd-tkc-base-app-cm-5.yaml"

# Function to perform sed operations based on OS type
perform_sed() {
    local sed_cmd=$1
    local file_path=$2

    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "$sed_cmd" "$file_path"
    else
        sed -i "$sed_cmd" "$file_path"
    fi
}

# Update antrea-config-1.yaml
if [ -f "$antrea_config_path" ]; then
    perform_sed "s/name: tkc-cluster-1-antrea-package/name: ${cluster_name}-antrea-package/" "$antrea_config_path"
    perform_sed "s/namespace: ns-1/namespace: ${vsphere_namespace}/" "$antrea_config_path"
    echo "Updated antrea-config-1.yaml"
fi

# Update argocd-tkc-base-app-env-3.yaml
if [ -f "$argocd_tkc_base_app_env_path" ]; then
    perform_sed "s/name: argocd-tkc-1-base-app-env/name: argocd-${cluster_name}-base-app-env/" "$argocd_tkc_base_app_env_path"
    perform_sed "s/value: \"tkc-cluster-1\"/value: \"${cluster_name}\"/" "$argocd_tkc_base_app_env_path"
    perform_sed "s/name: argocd-tkc-post/name: argocd-${cluster_name}-post/" "$argocd_tkc_base_app_env_path"
    perform_sed "s/name: argocd-tkc-1-base-app-configmap/name: argocd-${cluster_name}-base-app-configmap/" "$argocd_tkc_base_app_env_path"
    echo "Updated argocd-tkc-base-app-env-3.yaml"
fi

# Update tkgs-cluster-class-2.yaml
if [ -f "$tkgs_cluster_class_path" ]; then
    perform_sed "s/name: tkc-cluster-1/name: ${cluster_name}/" "$tkgs_cluster_class_path"
    perform_sed "s/namespace: ns-1/namespace: ${vsphere_namespace}/" "$tkgs_cluster_class_path"
    echo "Updated tkgs-cluster-class-2.yaml"
fi

# Update argocd-tkc-base-app-cm-5.yaml
if [ -f "$argocd_tkc_base_app_cm_path" ]; then
    perform_sed "s/app.kubernetes.io\/name: argocd-tkc-1-base-app-configmap/app.kubernetes.io\/name: argocd-${cluster_name}-base-app-configmap/" "$argocd_tkc_base_app_cm_path"
    perform_sed "s/name: argocd-tkc-1-base-app-configmap/name: argocd-${cluster_name}-base-app-configmap/" "$argocd_tkc_base_app_cm_path"
    # Update all path instances containing 'tkc-cluster-1'
    perform_sed "s/tkc-cluster-1\/applications\/gatekeeper-tkc-1/${cluster_name}\/applications\/gatekeeper-${cluster_name}/" "$argocd_tkc_base_app_cm_path"
    perform_sed "s/tkc-cluster-1\/applications\/foundational\/ako/${cluster_name}\/applications\/foundational\/ako/" "$argocd_tkc_base_app_cm_path"
    perform_sed "s/clusterName: 'tkc-cluster-1'/clusterName: '${cluster_name}'/" "$argocd_tkc_base_app_cm_path"
    perform_sed "s|nsxtT1LR: '/infra/tier-1s/tier-1'|nsxtT1LR: '${nsx_t1_router}'|" "$argocd_tkc_base_app_cm_path"
    perform_sed "s|- networkName: 'vip-l7'|- networkName: '${vip_network_name}'|" "$argocd_tkc_base_app_cm_path"
    perform_sed "s|cidr: '10.141.1.0/24'|cidr: '${vip_network_cidr}'|" "$argocd_tkc_base_app_cm_path"
    perform_sed "s|defaultIngController: 'true'|defaultIngController: '${default_ing_controller}'|" "$argocd_tkc_base_app_cm_path"
    perform_sed "s|serviceEngineGroupName: 'domain-c1006:5de34cdc-8b14-46a3-b1c9-b627d574cdf0'|serviceEngineGroupName: '${se_group_name}'|" "$argocd_tkc_base_app_cm_path"
    perform_sed "s|cloudName: nsx-t|cloudName: '${cloud_name}'|" "$argocd_tkc_base_app_cm_path"
    perform_sed "s|controllerHost: '172.18.5.51'|controllerHost: '${controller_host}'|" "$argocd_tkc_base_app_cm_path"
    echo "Updated argocd-tkc-base-app-cm-5.yaml including AKO configuration"
fi

# Copy and rename argocd-tkc-deploy.yaml within the same argocd folder
if [ -f "$original_argocd_tkc_deploy_path" ]; then
    cp "$original_argocd_tkc_deploy_path" "$new_argocd_tkc_deploy_path"
    # Update the new deployment file with the cluster name and namespace
    perform_sed "s/name: tkc-deploy/name: ${cluster_name}-deploy/" "$new_argocd_tkc_deploy_path"
    perform_sed "s|path: tkc-cluster-1|path: ${cluster_name}|" "$new_argocd_tkc_deploy_path"
    perform_sed "s/namespace: ns-1/namespace: ${vsphere_namespace}/" "$new_argocd_tkc_deploy_path"
    echo "Created and updated ${new_argocd_tkc_deploy_file} based on cluster name and namespace inputs in the 'argocd' folder."
else
    echo "Error: The original argocd-tkc-deploy.yaml file does not exist in the 'argocd' directory."
fi

# Rename the applications/gatekeeper-tkc-1 folder within the new cluster directory
if [ -d "$original_gatekeeper_path" ]; then
    mv "$original_gatekeeper_path" "$new_gatekeeper_path"
    echo "Renamed gatekeeper folder to gatekeeper-${cluster_name} within the '${cluster_name}/applications' directory."
else
    echo "Error: The original gatekeeper folder does not exist in the '${cluster_name}/applications' directory."
fi

# Update argocd-ako-repo.yaml file with the new name
if [ -f "$argocd_ako_repo_path" ]; then
    perform_sed "s/name: avi-ako-helm-repo/name: avi-ako-helm-repo-${cluster_name}/" "$argocd_ako_repo_path"
    perform_sed "s/namespace: ns-1/namespace: ${vsphere_namespace}/" "$argocd_ako_repo_path"
    echo "Updated the name field in argocd-ako-repo.yaml to avi-ako-helm-repo-${cluster_name}."
else
    echo "Error: The argocd-ako-repo.yaml file does not exist in the '/applications/foundational/repos' directory."
fi

# Update argocd-nfs-repo.yaml file with the new name
if [ -f "$argocd_nfs_repo_path" ]; then
    perform_sed "s/name: nfs-helm-repo/name: nfs-helm-repo-${cluster_name}/" "$argocd_nfs_repo_path"
    perform_sed "s/namespace: ns-1/namespace: ${vsphere_namespace}/" "$argocd_nfs_repo_path"
    echo "Updated the name field in argocd-nfs-repo.yaml to nfs-helm-repo-${cluster_name}."
else
    echo "Error: The argocd-nfs-repo.yaml file does not exist in the '/applications/foundational/repos' directory."
fi
