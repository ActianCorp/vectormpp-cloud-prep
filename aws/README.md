# ☁️  VectorMPP – AWS Cloud Setup

This guide explains how to prepare your AWS environment for installing VectorMPP in an EKS cluster.

---

## 📌 Contents

- [1. Overview](#1-overview)
- [2. Preparing a GCS Bucket for Sample Data (Optional)](#2-preparing-a-gcs-bucket-for-sample-data-optional)
- [3. Credential Setup](#3-credential-setup)
- [4. EKS Cluster Provisioning](#4-eks-cluster-provisioning)
- [5. Post-Cluster: Trust Policy Update](#5-post-cluster-trust-policy-update)
- [6. Validation](#6-validation)

---

## 1. Overview

Terraform files are structured into two folders:

```text
aws/
├── credentials/   # IAM roles and optional cluster user
├── cluster/       # VPC, subnets, EKS, EFS, add-ons
└── README.md      # AWS-specific instructions
```

Some components are **required**, others are **optional** or customizable.

---

## 2. Preparing an S3 Bucket for Sample Data (Optional)

If you plan to enable the **sample data preload** feature in VectorMPP, you need to store the prepared  
[Airline Sample Data](../airline-sample-data/README.md) in an Amazon S3 bucket so it can be accessed by the cluster.

### Steps

1. **Create an S3 bucket** (replace `<AWS-SAMPLE-BUCKET>` with a globally unique bucket name and `<AWS-REGION>` with your AWS region):
   ```bash
   aws s3 mb s3://<AWS-SAMPLE-BUCKET> --region <AWS-REGION>
   ```

2. **Prepare the airline sample data locally** by following the instructions in  
   [`airline-sample-data/README.md`](../airline-sample-data/README.md).

3. **Upload the sample data files** to the S3 bucket:
   ```bash
   aws s3 cp ../airline-sample-data/data/ s3://<AWS-SAMPLE-BUCKET>/ --recursive
   ```

---

## 3. Credential Setup

### ✅ Must-Have (if using sample data preload)

If you want to enable the **sample data preload** feature — which preloads sample data into the warehouse to let users experiment quickly — you **must deploy** the following resources (defined in `iam-sampledata.tf`):

- `aws_iam_role.AVSampleDataBucketAssumeRole`
- `aws_iam_policy.AVSampleDataReadObjectAccessPolicy`
- Associated role policy attachments

These roles allow access to your sample data S3 bucket and are used by your warehouses to retrieve sample data.

> ⚠️  **Note:**  
> The role name `AVSampleDataBucketAssumeRole` **must not be changed**. It is hardcoded into the application logic.  

If you are **not using sample data**, `iam-sampledata.tf` can be removed and ignored.

#### ✅ Optional: Dedicated IAM user (`vectormpp-cluster-creator`)

The file also provisions an IAM user named `vectormpp-cluster-creator` and attaches a set of IAM policies:

- Full access to EKS (`eks:*`)
- Full access to EC2, VPC, and EFS
- Read/write permissions for S3 (including bucket wildcards)
- IAM and OpenID Connect permissions
- Minimal autoscaling inspection access

This user is **optional**. Use it if:

- You want to create a **dedicated user with scoped-down permissions** for cluster creation.
- You do **not** want to use your own AWS admin account.

If you're using your own AWS user or CI/CD with elevated permissions, you can skip creating this user entirely.

### ▶️ Run

```bash
cd credentials
terraform init
terraform apply -var region=<AWS-REGION> -var sample_bucket_name=<AWS-SAMPLE-BUCKET>
```

> 💡 Configure a remote backend for Terraform state (e.g. terraform app or S3).

---

## 4. EKS Cluster Provisioning

The Terraform code in the AWS `cluster/` folder provides a reference implementation for creating an EKS cluster along with recommended networking and add-on configurations.  
This setup is **mostly optional**, but **some components are critical** for VectorMPP to function correctly.

```
cd cluster
terraform init
terraform apply -var cluster_name=<CLUSTER-NAME> -var region=<AWS-REGION> -var cluster_version=<K8S-VERSION> -var min_node_count=<MINIMUM-NODE-NUMBER> -var max_node_count=<MAXIMUM-NODE-NUMBER> -var node_type=<GCE-NODE-TYPE> -var 'az_map=<AZ-MAP>'
```
### 📍 Availability Zone Mapping (az_map)

The `az_map` input is a required variable that maps AWS AZ IDs to AZ names.

This is used to exclude known unsupported Availability Zones for EKS control planes.  
Each AWS region has different mappings, and zone names are not consistent across accounts — but zone IDs are.

You can generate the map using:

```bash
AZ_MAP=$(aws ec2 describe-availability-zones --region <AWS-REGION> --query "AvailabilityZones[*].{ID:ZoneId, Name:ZoneName}" --output json | jq -c 'map({(."ID"): .Name}) | add')
```
Output would be like:
```json
{"euc1-az2":"eu-central-1a","euc1-az3":"eu-central-1b","euc1-az1":"eu-central-1c"}
```

### ✅ Components Examples

- **EKS control plane and node group** (defined in `eks.tf` and `nodes.tf`)
- **Private and public subnets across 3 Availability Zones** (in `network.tf`)
- **VPC with internet and NAT gateways** (also in `network.tf`)
- **EKS add-ons:**
  - `vpc-cni`
  - `coredns`
  - `kube-proxy`
  - `aws-ebs-csi-driver`
  - `aws-efs-csi-driver`

> 💡 If your organization uses existing VPCs or subnets, you can use this setup as a reference only.

## 5. Post-Cluster: Trust Policy Update

After the EKS cluster is created, you must perform a **one-time trust policy update** to allow the data plane role created in terraform code to assume the IAM role used for accessing sample data.

This is necessary only if you intend to enable the **sample data preload** feature.

### ✅ Steps

1. **Identify your EKS data plane role ARN.**  
    By default, this role is named: `arn:aws:iam::<your-account-id>:role/<your-cluster-name>-data-plane`
3. **Check if the data plane role is already listed** in the trust policy of role `AVSampleDataBucketAssumeRol`.
4. **If not**, add the EKS data plane role ARN to the list of trusted principals.

The logic has been implemented inside script named `post.sh`:
```
./post.sh <CLUSTER-NAME> add_to_trust_policy
```

#### 📝 Why This Matters

The `AVSampleDataBucketAssumeRole` IAM role allows workloads to read from a designated S3 bucket containing sample data.  
In order for VectorMPP DataPlane to access it, they must be **explicitly trusted** via the role’s `AssumeRolePolicyDocument`.

Without this step, the sample data preload process will fail due to **access denial errors**.

> 💡 This step is only required if the **sample data preload feature** is enabled.


---

## 6. Validation
```bash
aws configure --profile <PROFILE-NAME> set aws_access_key_id "<KEY>"
aws configure --profile <PROFILE-NAME> set aws_secret_access_key "<SECRET>"
aws configure --profile <PROFILE-NAME> set region <REGION>
aws eks update-kubeconfig --region <REGION> --name <CLUSTER-NAME> --profile <PROFILE-NAME>

kubectl get nodes
kubectl get serviceaccount --all-namespaces
kubectl get svc
```
