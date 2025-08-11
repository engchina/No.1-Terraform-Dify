output "bucket_name" {
  description = "The name of the created object storage bucket"
  value       = oci_objectstorage_bucket.dify_bucket.name
}

output "autonomous_data_warehouse_admin_password" {
    value = var.adb_password
}

output "autonomous_data_warehouse_high_connection_string" {
  value = lookup(
    oci_database_autonomous_database.generated_database_autonomous_database.connection_strings[0].all_connection_strings,
    "HIGH",
    "unavailable",
  )
}

output "ssh_to_instance" {
  description = "convenient command to ssh to the instance"
  value       = "ssh -o ServerAliveInterval=10 ubuntu@${oci_core_instance.generated_oci_core_instance.public_ip}"
}

output "application_url" {
  description = "convenient url to access the application"
  value       = "http://${oci_core_instance.generated_oci_core_instance.public_ip}:8080"
}

output "adb_dsn" {
  description = "ADB DSN for connection"
  value       = "${lower(var.adb_name)}_high"
}

output "wallet_file_location" {
  description = "Location of the wallet file"
  value       = "${path.module}/wallet.zip"
}
