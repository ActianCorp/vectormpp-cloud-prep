variable "region" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type = string
  default = "1.30"
}

variable "min_node_count" {
  type = number
  default = 3
}

variable "max_node_count" {
  type = number
  default = 3
}

variable "node_type" {
  type = string
  default = "m5.8xlarge"
}

variable "az_map" {
  type = map(string)
}
