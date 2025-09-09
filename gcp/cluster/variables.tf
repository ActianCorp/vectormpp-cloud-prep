variable "project" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "region" {
  type = string
  default = "europe-west3"
}

variable "cluster_location" {
  type = string
  default = "europe-west3"
}

variable "node_location" {
  type = string
  default = "europe-west3-a"
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
  default = "e2-standard-32"
}
