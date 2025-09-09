variable "resource_group_name" {
  type = string
}

variable "user_assigned_managed_identity_name" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type = string
}

variable "min_node_count" {
  type = number
}

variable "max_node_count" {
  type = number
}

variable "node_type" {
  type = string
}

variable "location_display_name" {
  type = string
}
