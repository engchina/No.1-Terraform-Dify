variable "availability_domain" {
  default = "bxtG:AP-TOKYO-1-AD-1"
}

variable "compartment_ocid" {
  default = ""
}

variable "adb_name" {
  default = "AIDIFYADB"
}

variable "adb_password" {
  default = ""
}

variable "license_model" {
  default = ""
}

variable "instance_display_name" {
  default = "AIDIFY_INSTANCE"
}

variable "instance_shape" {
  default = "VM.Standard.E4.Flex"
}

variable "instance_flex_shape_ocpus" {
  default = 2
}

variable "instance_flex_shape_memory" {
  default = 16
}

variable "instance_boot_volume_size" {
  default = 100
}

variable "instance_boot_volume_vpus" {
  default = 20
}

variable "instance_image_source_id" {
  default = "ocid1.image.oc1.ap-osaka-1.aaaaaaaakubn2okgusevio3dcanojxysaeod42dkey2tilbr7bfvkiconb6q"
}

variable "subnet_ai_subnet_id" {
  default = ""
}

variable "ssh_authorized_keys" {
  default = ""
}

variable "bucket_name" {
  default = "dify-bucket"
}

variable "bucket_namespace" {
  default = ""
}
