variable "resource_group_name" {
  type        = string
  default     = "VectorMPP"
}

variable "cluster_creator_name" {
  type        = string
  default     = "VectorMPP-Cluster-Creator"
}

variable "sample_data_reader_name" {
  type        = string
  default     = "vectormpp-sample-data"
}

variable "user_assigned_id_name" {
  type        = string
  default     = "data-plane-user-assigned-id"
}

variable "sample_data_storage_account_name" {
  type        = string
  default     = "vectormpp"
}

variable "sample_data_storage_container_name" {
  type        = string
  default     = "sample-data"
}

