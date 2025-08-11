data "oci_objectstorage_namespace" "tenant_namespace" {
  compartment_id = var.compartment_ocid
}

resource "oci_objectstorage_bucket" "dify_bucket" {
  compartment_id = var.compartment_ocid
  name           = var.bucket_name
  namespace      = data.oci_objectstorage_namespace.tenant_namespace.namespace
}

resource "null_resource" "bucket_cleanup" {
  triggers = {
    bucket_name = oci_objectstorage_bucket.dify_bucket.name
    namespace   = oci_objectstorage_bucket.dify_bucket.namespace
  }

  provisioner "local-exec" {
    when    = destroy
    command = "oci os object bulk-delete --bucket-name ${self.triggers.bucket_name} --namespace ${self.triggers.namespace} --force || true"
  }

  depends_on = [oci_objectstorage_bucket.dify_bucket]
}
