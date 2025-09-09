variable "project" {
  type = string
}

variable "region" {
  type = string
  default = "europe-west3"
}

variable "sampledata_bucket" {
  type = string
  default = "vectormpp-sample-data"
}

variable "sa_cluster_creator_name" {
  type = string
  default = "vectormpp-cluster-creator"
}

variable "sa_data_plane_name" {
  type = string
  default = "vectormpp-data-plane"
}

variable "sa_sample_data_reader_name" {
  type = string
  default = "vectormpp-sample-data-reader"
}
