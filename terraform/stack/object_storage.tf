# Provider for home region
provider "oci" {
  alias  = "home_region"
  region = var.home_region
}

# Get namespace in home region
data "oci_objectstorage_namespace" "tenant_namespace" {
  provider       = oci.home_region
  compartment_id = var.compartment_ocid
}

# Create bucket in home region
resource "oci_objectstorage_bucket" "dify_bucket" {
  provider       = oci.home_region
  compartment_id = var.compartment_ocid
  name           = var.bucket_name
  namespace      = data.oci_objectstorage_namespace.tenant_namespace.namespace
  
  # Optional: Disable versioning to make cleanup easier
  versioning = "Disabled"
}

# Bucket cleanup resource
resource "null_resource" "bucket_cleanup" {
  depends_on = [oci_objectstorage_bucket.dify_bucket]

  triggers = {
    bucket_name = oci_objectstorage_bucket.dify_bucket.name
    namespace   = oci_objectstorage_bucket.dify_bucket.namespace
    home_region = var.home_region
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
      echo "Starting bucket cleanup process..."
      BUCKET_NAME="${self.triggers.bucket_name}"
      NAMESPACE="${self.triggers.namespace}"
      REGION="${self.triggers.home_region}"
      
      # Check if bucket exists before cleanup
      if oci os bucket get --bucket-name "$BUCKET_NAME" --namespace "$NAMESPACE" --region "$REGION" >/dev/null 2>&1; then
        echo "Bucket exists, proceeding with object cleanup..."
        
        # Bulk delete all objects
        oci os object bulk-delete \
          --bucket-name "$BUCKET_NAME" \
          --namespace "$NAMESPACE" \
          --region "$REGION" \
          --force || true
        
        echo "✅ Bucket cleanup completed"
      else
        echo "ℹ️  Bucket does not exist or is not accessible, skipping cleanup"
      fi
    EOT
  }
}