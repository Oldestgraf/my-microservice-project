variable "cluster_name" {
  type = string
}

variable "kubernetes_version" {
  type = string
  default = "1.29"
}

variable "vpc_id" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "instance_types" {
  type = list(string)
  default = ["t3.medium"]
}

variable "node_group_desired_size" {
  type = number
  default = 2
}

variable "node_group_min_size" {
  type = number
  default = 2
}

variable "node_group_max_size" {
  type = number
  default = 6
}
