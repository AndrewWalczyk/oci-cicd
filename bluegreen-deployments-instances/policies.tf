## Copyright (c) 2022, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_identity_group" "devops" {
  provider       = oci.home_region
  name           = "${var.app_name}_group${random_id.tag.hex}"
  description    = "group created for devops"
  compartment_id = var.tenancy_ocid
}

resource "oci_identity_user" "devopsuser" {
  #Required
  provider       = oci.home_region
  compartment_id = var.tenancy_ocid
  description    = "user for devops"
  name           = "devops-user-${random_id.tag.hex}"
}

resource "oci_identity_user_group_membership" "usergroupmem1" {
  depends_on = [oci_identity_group.devops]
  provider   = oci.home_region
  group_id   = oci_identity_group.devops.id
  user_id    = oci_identity_user.devopsuser.id
}

resource "oci_identity_dynamic_group" "devopsgroup1" {
  provider       = oci.home_region
  name           = "${var.app_name}_devopsdygroup${random_id.tag.hex}"
  description    = "DevOps  pipeline dynamic group"
  compartment_id = var.tenancy_ocid
  matching_rule  = "Any {ALL {resource.type = 'devopsdeploypipeline', resource.compartment.id = '${var.compartment_ocid}'},ALL {resource.type = 'devopsrepository', resource.compartment.id = '${var.compartment_ocid}'},ALL {resource.type = 'devopsbuildpipeline',resource.compartment.id = '${var.compartment_ocid}'}}"
}


resource "oci_identity_dynamic_group" "runcmddynamicgroup" {
  provider       = oci.home_region
  name           = "${var.app_name}_runcmddygroup${random_id.tag.hex}"
  description    = "run_cmd Pipeline Dynamic Group"
  compartment_id = var.tenancy_ocid
  matching_rule  = "All {instance.id = '${oci_core_instance.compute_instance_blue.id}',instance.id = '${oci_core_instance.compute_instance_green.id}'}"
}


resource "oci_identity_policy" "devopspolicy" {
  provider       = oci.home_region
  name           = "${var.app_name}_devops-policies${random_id.tag.hex}"
  description    = "policy created for devops"
  compartment_id = var.compartment_ocid

  statements = [
    "Allow group Administrators to manage devops-family in compartment id ${var.compartment_ocid}",
    "Allow group Administrators to manage all-artifacts in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.devopsgroup1.name} to manage all-resources in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.devopsgroup1.name} to manage repos in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.devopsgroup1.name} to read secret-family in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.devopsgroup1.name} to manage devops-family in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.devopsgroup1.name} to manage generic-artifacts in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.devopsgroup1.name} to use ons-topics in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.devopsgroup1.name} to use instance-agent-command-execution-family in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.devopsgroup1.name} to read generic-artifacts in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.devopsgroup1.name} to read all-artifacts in compartment id ${var.compartment_ocid}",
     
  ]
}
