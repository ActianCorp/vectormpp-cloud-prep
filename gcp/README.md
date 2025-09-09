# ☁️ VectorMPP – GCP Cloud Setup

This guide explains how to prepare your Google Cloud environment for installing VectorMPP in a GKE cluster.

---

## 📌 Contents

- [1. Overview](#1-overview)
- [2. Preparing a GCS Bucket for Sample Data (Optional)](#2-preparing-a-gcs-bucket-for-sample-data-optional)
- [3. Credential Setup](#3-credential-setup)
- [4. GKE Cluster Provisioning](#4-gke-cluster-provisioning)
- [5. Validation](#5-validation)
- [6. Post-Cluster Step: Configure Filestore StorageClass](#6-post-cluster-step-configure-filestore-storageclass)

---

## 1. Overview

Terraform files are structured into two folders:

```
gcp/
├── credentials/   # GCP service accounts, IAM bindings
├── cluster/       # GKE cluster and networking setup
└── README.md      # AWS-specific instructions
```

Some components are **required**, others are **optional** or customizable depending on your environment.

---

## 2. Preparing a GCS Bucket for Sample Data (Optional)

If you plan to enable the **sample data preload** feature in VectorMPP, you need to store the prepared
[Airline Sample Data](../airline-sample-data/README.md) in a Google Cloud Storage bucket so it can be accessed by the cluster.

### Steps

1. **Create a GCS bucket** (replace `<YOUR_BUCKET>` with a globally unique bucket name):
   ```bash
   gsutil mb -p <YOUR_PROJECT_ID> -c STANDARD -l <REGION> gs://<YOUR_BUCKET>/
   ```

2. **Prepare the airline sample data locally** by following the instructions in
   [`airline-sample-data/README.md`](../airline-sample-data/README.md).

3. **Upload the sample data files** to the GCS bucket:
   ```bash
   gsutil -m cp -r ../airline-sample-data/data/* gs://<YOUR_BUCKET>/
   ```

---

## 3. Credential Setup

> This step provisions service accounts and roles required by VectorMPP and its workloads.

### ✅ Must-Have: Sample Data Reader

If you plan to enable **sample data preload** (recommended for demo or test environments), deploy the following:

- **Service Account:** `vectormpp-sample-data-reader`
- **Role:** `roles/storage.objectViewer` on your `sampledata_bucket`

This service account allows VectorMPP warehouse workloads to access sample data from the specified GCS bucket.

> ⚠️ The target bucket name must be passed via the `sampledata_bucket` variable.

### ✅ Must-Have: Data Plane Service Account

This account is used by VectorMPP component DataPlane to create and manage GCS buckets and service accounts:

- **Service Account:** `vectormpp-data-plane`
- **Roles:**
  - `roles/storage.admin`
  - `roles/iam.serviceAccountAdmin`
  - `roles/storage.hmacKeyAdmin`

> ⚠️ The Kubernetes service account used by VectorMPP is hardcoded as:  
> `vectormpp-dataplane/agent`  
> The Workload Identity binding must not be changed.

### ➕ Optional: Cluster Creator Account

You can also provision a **dedicated cluster creator** service account (`vectormpp-cluster-creator`) with permissions to:

- Create and manage GKE clusters
- Access required GCP services

This is optional — if you're using your own admin account, skip this.

### Required Variables

- `project`: GCP project ID
- `region`: Deployment region (default: `europe-west3`)
- `sampledata_bucket`: Airline Sample Data Bucket (default: `vectormpp-sample-data`)
- `sa_cluster_creator_name`: The name of cluster-creator service account (default: `vectormpp-cluster-creator`)
- `sa_data_plane_name`: The name of data-plane service account (default: `vectormpp-data-plane`)
- `sa_sample_data_reader_name`: The name of sample-data-reader service account (default: `vectormpp-sample-data-reader`)

> 💡 Configure a remote backend for Terraform state (e.g. terraform app, S3 or GCS).

### ▶️ Run

```bash
cd credentials
terraform init
terraform apply -var project=<GCP-PROJECT> -var region=<REGION> -var sampledata_bucket=<SAMPLE-DATA-BUCKET-NAME> -var sa_cluster_creator_name=<CLUSTER-CREATOR-SA-NAME> -var sa_data_plane_name=<DATAPLANE-SA-NAME> -var sa_sample_data_reader_name=<SAMPLEDATA-READER-SA-NAME>
```

---

## 4. GKE Cluster Provisioning

> Cluster provisioning is provided as a reference. You may reuse your existing VPC or GKE setup.

The Terraform module provisions:

- A VPC and subnet
- A GKE cluster with workload identity enabled
- A node pool using a dedicated service account

### Required Variables

- `project`: GCP project ID
- `cluster_name`: Name of the GKE cluster
- `region`: Deployment region (default: `europe-west3`)
- `cluster_location`: GKE location (can be zone or region) (default: `europe-west3`)
- `node_location`: Zone where node pool runs (default: `europe-west3-a`)
- `min_node_count` / `max_node_count`: Autoscaling limits (default: `3`/`3`)
- `node_type`: Machine type (default: `e2-standard-32`)

### ▶️ Run

```bash
cd cluster
terraform init
terraform apply -var project=<GCP-PROJECT> -var cluster_name=<GKE-CLUSTER-NAME> -var region=<REGION> -var cluster_location=<GKE-LOCATION> -var node_location=<GKE-NODE-LOCATION> -var min_node_count=<GKE-MIN-NODE-COUNT> -var max_node_count=<GKE-MAX-NODE-COUNT> -var node_type=<GKE-NODE-TYPE>
```

> ⚠️ The cluster will be created in a new VPC and subnet by default. You may customize networking to use existing infrastructure.

---

## 5. Validation

```bash
gcloud container clusters get-credentials --region=<REGION> --project=<GCP-PROJECT> <GKE-CLUSTER-NAME>
kubectl get nodes
kubectl get serviceaccount --all-namespaces
kubectl get svc
```

---

## 6. Post-Cluster Step: Configure Filestore StorageClass

To use Google Filestore (NFS) with VectorMPP, you must create a custom StorageClass with your VPC specified.

Replace the `<VPC-NAME>` with your actual VPC name in `yaml/storageclass.yaml` file, then:

```bash
kubectl apply -f yaml/storageclass.yaml
```

> ⚠️  Without this step, PersistentVolumeClaims (PVCs) that rely on this class will fail to bind.

## 🔗 Next Step

Once your GCP credentials and cluster are set up, proceed to the [VectorMPP Kubernetes installation guide](#) to continue.

---

