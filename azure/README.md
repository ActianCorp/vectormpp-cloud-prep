# ☁️  VectorMPP – Azure Cloud Setup

This guide explains how to prepare your Microsoft Azure environment for installing VectorMPP in an AKS cluster.

---

## 📌 Contents

- [1. Overview](#1-overview)
- [2. Preparing a GCS Bucket for Sample Data (Optional)](#2-preparing-a-gcs-bucket-for-sample-data-optional)
- [3. Credential Setup](#3-credential-setup)
- [4. AKS Cluster Provisioning](#4-aks-cluster-provisioning)
- [5. Validation](#5-validation)
- [6. Apply Required StorageClass](#6-apply-required-storageclass)
- [7. Next Steps](#7-next-steps)

---

## 1. Overview

This folder contains Azure-related configuration and resources:

```
azure/
├── credentials/                # Azure AD applications, role assignments, identities
├── cluster/                    # AKS setup, virtual network, federated identity
├── yaml/storageclass.yaml      # Customized Azure file storage class
└── README.md                   # Azure-specific instructions
```
Some components are **required**, others are **optional** depending on how you integrate AKS with your environment.

**Prerequisite**:
An Azure resource group must exist before proceeding. If you don’t have one, create it with:

```bash
az group create --name <RESOURCE-GROUP> --location <your-region>
```

---

## 2. Preparing an S3 Bucket for Sample Data (Optional)

If you plan to enable the **sample data preload** feature in VectorMPP, you need to store the prepared  
[Airline Sample Data](../airline-sample-data/README.md) in an blob container so it can be accessed by the cluster.

### Steps

1. you must have an existing Azure **Storage Account** and **Blob Container** set up with sample data. To create them manually:
   ```bash
   az storage account create --name <STORAGE-ACCOUNT-NAME> --resource-group <RESOURCE-GROUP> --sku Standard_LRS --kind StorageV2 --hns
   az storage container create --name <CONTAINER-NAME> --account-name <STORAGE-ACCOUNT-NAME>
   ```

2. **Prepare the airline sample data locally** by following the instructions in  
   [`airline-sample-data/README.md`](../airline-sample-data/README.md).

3. **Upload the sample data files** to the blob container:
   ```bash
   az storage blob upload-batch --source ../airline-sample-data/data/ --destination <CONTAINER-NAME> --account-name <STORAGE-ACCOUNT-NAME>
   ```

---

## 3. Credential Setup

> This step provisions Azure AD applications, service principals, managed identities, and role assignments required for VectorMPP to operate securely.

### ✅ Must-Have: Sample Data Access

To enable **sample data preload** from Azure Blob Storage, the following components are created:

- **Azure AD Application**
- **Service Principal** linked to that application
- **Role Assignment:**
  - `Storage Blob Data Reader` on the target container

> ⚠️  These are required for VectorMPP Warehouses to read from the sample data container.

### ✅ Must-Have: Workload Managed Identity

This identity is used by the **VectorMPP Data Plane** component to interact with Azure services.

- **User Assigned Managed Identity**
- **Role Assignments:**
  - `Storage Account Contributor`
  - `Reader` (for resource discovery, etc.)

These roles are scoped to the specified resource group.

### ➕ Optional: Cluster Creator Identity

You can create a **dedicated service principal** for provisioning AKS clusters and managing resources:

- **Azure AD Application:**
- **Service Principal**
- **Role Assignments:**
  - `Contributor` on resource group
  - `Reader` on subscription
  - `Network Contributor` on resource group

This is optional — useful for CI/CD pipelines or to avoid using your own admin identity.

---

### ▶️  Run

```bash
cd credentials
terraform init
export ARM_SUBSCRIPTION_ID=<AZURE-SUBSCRIPTION-ID>
terraform apply -var resource_group_name=<RESOURCE-GROUP> -var sample_data_storage_account_name=<SAMPLE-DATA-STORAGE-ACCOUNT-NAME> -var sample_data_storage_container_name=<SAMPLE-DATA-CONTAINER-NAME> -var sample_data_reader_name=<SAMPLE-DATA-READER-NAME> -var user_assigned_id_name=<DATA-PLANE-UAID-NAME> -var cluster_creator_name=<CLUSTER-CREATOR-NAME>
```

> 💡 Configure a remote backend (e.g., Azure Blob Storage) for storing Terraform state securely.

---

## 4. AKS Cluster Provisioning

The `cluster` folder contains Terraform code to provision:

- An AKS cluster with system-assigned identity and Workload Identity enabled
- A virtual network and subnet for AKS
- A federated identity credential to link AKS workloads with the user-assigned managed identity

### ✅ Required

This configuration enables AKS workloads in namespace `vectormpp-dataplane` and service account `agent` to assume the managed identity via federated identity binding.

> ⚠️  The subject `system:serviceaccount:vectormpp-dataplane:agent` is hardcoded in VectorMPP — do not change it.

### ▶️ Run

```bash
cd cluster
terraform init
terraform apply -var cluster_name=<CLUSTER-NAME> -var cluster_version=<CLUSTER-VERSION> -var min_node_count=<MIN-NODE-COUNT> -var max_node_count=<MAX-NODE-COUNT> -var node_type=<NODE-TYPE> -var resource_group_name=<RESOURCE-GROUP> -var location_display_name=<REGION-NAME> -var user_assigned_managed_identity_name=<DATA-PLANE-UAID-NAME>
```

---

## 5. Validation

```bash
az login --service-principal -u <AZURE_AKS_CLIENT_ID> -p <AZURE_AKS_CLIENT_SECRET> --tenant <ARM_TENANT_ID>
az account set --subscription <ARM_SUBSCRIPTION_ID>
az aks get-credentials --resource-group <AZURE_RESOURCE_GROUP> --name <CLUSTER_NAME>

kubectl get nodes
kubectl get serviceaccount --all-namespaces
kubectl get svc
```

---

## 6. Apply Required StorageClass

After the AKS cluster is created, apply a required custom `StorageClass`.

### 📄 File:
`yaml/storageclass.yaml`

### ▶️ Apply it:

```bash
az aks get-credentials --resource-group <RESOURCE-GROUP> --name <CLUSTER-NAME>
kubectl apply -f yaml/storageclass.yaml
```

> ⚠️  Required for VectorMPP. Must not change:
> - `uid=1000`
> - `gid=3000`

This storage class uses Azure File Premium via CSI.

---

## 7. Next Steps

Once credentials, the cluster, and the required `StorageClass` are ready, proceed to the [VectorMPP Kubernetes installation guide](#).
