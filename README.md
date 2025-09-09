# 📘 Cloud Platform Preparation Guide for VectorMPP

> Prepare AWS, GCP, or Azure cloud environments to run VectorMPP in Kubernetes.

---

## Overview

Before installing VectorMPP on a Kubernetes cluster, two key preparations must be completed:

1. **Cloud Credentials Setup**
2. **Kubernetes Cluster Provisioning**

We provide a **single public GitHub repository** containing Terraform configurations organized by platform:

```text
vectormpp-cloud-prep/
├── README.md          # (this file)
├── airline-sample-data/        # sample data which can be preloaded
├── aws/
│   ├── credentials/            # IAM roles & policies
│   ├── cluster/                # EKS setup (reference)
│   ├── post.sh                 # post actions
│   └── README.md               # AWS-specific instructions
├── gcp/
│   ├── credentials/            # service accounts & roles
│   ├── cluster/                # GKE setup (reference)
│   ├── yaml/storageclass.yaml  # Customized gcp filestore storage class
│   └── README.md               # GCP-specific instructions
└── azure/
    ├── credentials/            # Azure AD roles & identities
    ├── cluster/                # AKS setup (reference)
    ├── yaml/storageclass.yaml  # Customized Azure file storage class
    └── README.md               # Azure-specific instructions
```

> ⚠️  **Note:** Not everything in these folders is mandatory.  
> Some resources are **critical and required**, while others are **examples or optional**, depending on your cloud setup.  
> The **critical components** for each cloud provider are clearly marked in the platform-specific doc or annotated in the **Terraform code comments**.  
> Remote Terraform backends are not preconfigured — recommended for production.

---

## Requirements

- A cloud account (AWS, GCP, or Azure)
- CLI tools:
  - Cloud CLI (`aws`, `gcloud`, or `az`)
  - `terraform`
  - `kubectl`
  - `helm`

---

## General Workflow

1. Clone this repository:

   ```bash
   git clone https://github.com/ActianCorp/vectormpp-cloud-prep.git
   cd vectormpp-cloud-prep
   ```

2. Choose your platform:

   - [AWS instructions](./aws/README.md)
   - [GCP instructions](./gcp/README.md)
   - [Azure instructions](./azure/README.md)

3. Follow the steps to:

   - Set up required credentials
   - Provision a Kubernetes cluster (or adapt to your own)

4. Proceed to the main VectorMPP installation guide once your environment is ready.

---

## Airline Sample Data (Optional)

VectorMPP can optionally preload a **sample airline dataset** for demonstration and testing purposes.  
This data is stored in [`airline-sample-data/`](./airline-sample-data/) and is based on the U.S. DOT **Bureau of Transportation Statistics On-Time Performance** dataset.

### When to prepare this data

If you enable the **sample data preload** feature in VectorMPP, you must first download and upload the data to your cloud object storage (S3, GCS, or Azure Blob).

### How to prepare

1. **Generate the sample data locally**
   ```bash
   cd airline-sample-data
   chmod +x download.sh
   ./download.sh
   ```
   This downloads **2018 monthly flight performance data** from BTS into `airline-sample-data/data/`.

2. **Verify the data (optional but recommended)**
   ```bash
   python3 verify.py
   ```
   If everything matches the lookup tables, you should see **all green** output.

3. **Upload the prepared data** to your cloud storage:
   - **AWS** → S3 bucket  
     ```bash
     aws s3 cp data/ s3://<your-sample-data-bucket>/ --recursive
     ```
   - **GCP** → GCS bucket  
     ```bash
     gsutil -m cp -r data/* gs://<your-sample-data-bucket>/
     ```
   - **Azure** → Blob container  
     ```bash
     az storage blob upload-batch -d <container-name> -s data/
     ```

4. **Configure VectorMPP** to point to the location of your uploaded sample data when enabling preload.

---
