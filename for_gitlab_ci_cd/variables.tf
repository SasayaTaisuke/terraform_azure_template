# EnvVar for ServicePrincipal
variable ARM_TENANT_ID {}
variable ARM_CLIENT_ID {}
variable ARM_CLIENT_SECRET {}
variable ARM_SUBSCRIPTION_ID {}

variable "suffix" {}
# # EnvVar for RG
variable "resource_group_name" {
  default = "rg-set-gitlab-ci-cd"
}
variable "location" {
  default = "japaneast"
}
variable "virtual_nw_name" {
  default = "virtual-nw"
}

variable "virtual_nw_address_space" {
  default = "10.0.0.0/16"
}

variable "subnet_name" {
  default = "subnet"
}


variable "public_ip_name" {
  default = "public-ip"
}

variable "security_group" {
  default = "security-group"
}

variable "network_interface_name" {
  default = "network-interface"
}

variable "NIC_name" {
  default = "NIC"
}

variable "VM_name" {
  default = "VM" 
}

variable "VM_size" {
  default = "Standard_B2S"
}

variable "os_disk_name" {
  default = "os-disk"
}

variable "os_disk_size" {
}

variable "computer_name" {
  default = "computer"
}

variable "product_user" {
}

variable "admin_password" {
}


# タグ情報
variable tags_def {
  default = {
    user      = "TaisukeSasaya"
    project     = "for-template"
  }
}

# 各種パラメータ 
variable region {}


# # 対象ソースイメージ関連情報
# variable publisher {
# }
# variable offer {
# }
# variable sku {
# }
# variable vminage_version {
# }

variable source_image_id {}
