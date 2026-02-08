variable "namespace"    { type = string default = "jenkins" }
variable "service_type" { type = string default = "LoadBalancer" }
variable "admin_password" { type = string sensitive = true }
