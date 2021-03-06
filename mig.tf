/*
 * Copyright 2019 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


data "template_file" "group-startup-script" {
  template = "${file(format("%s/gceme.sh.tpl", path.module))}"

  vars = {
    PROXY_PATH = ""
  }
}

module "mig1_template" {
  source               = "../terraform-google-vm/modules/instance_template"
  network              = "${google_compute_network.default.self_link}"
  subnetwork           = "${google_compute_subnetwork.group1.self_link}"
  service_account      = "${var.service_account}"
  name_prefix          = "${var.network_prefix}-group1"
  startup_script       = "${data.template_file.group-startup-script.rendered}"
  source_image_family  = "ubuntu-1804-lts"
  source_image_project = "ubuntu-os-cloud"
  tags                 = [
    "${var.network_prefix}-group1",
    "${module.cloud-nat-group1.router_name}"]
}

module "mig1" {
  source            = "../terraform-google-vm/modules/mig"
  instance_template = "${module.mig1_template.self_link}"
  region            = "${var.group1_region}"
  hostname          = "${var.network_prefix}-group1"
  target_size       = var.group1_size >= 0 ? var.group1_size : var.target_size
  named_ports       = [
    {
      name = "http",
      port = 80
    }]
  network           = "${google_compute_network.default.self_link}"
  subnetwork        = "${google_compute_subnetwork.group1.self_link}"
}

module "mig2_template" {
  source          = "../terraform-google-vm/modules/instance_template"
  network         = "${google_compute_network.default.self_link}"
  subnetwork      = "${google_compute_subnetwork.group2.self_link}"
  service_account = "${var.service_account}"
  name_prefix     = "${var.network_prefix}-group2"
  startup_script  = "${data.template_file.group-startup-script.rendered}"
  tags            = [
    "${var.network_prefix}-group2",
    "${module.cloud-nat-group2.router_name}"]
}

module "mig2" {
  source            = "../terraform-google-vm/modules/mig"
  instance_template = "${module.mig2_template.self_link}"
  region            = "${var.group2_region}"
  hostname          = "${var.network_prefix}-group2"
  #target_size       = "${var.target_size}"
  target_size       = var.group2_size >= 0? var.group2_size : var.target_size
  named_ports       = [
    {
      name = "http",
      port = 80
    }]
  network           = "${google_compute_network.default.self_link}"
  subnetwork        = "${google_compute_subnetwork.group2.self_link}"
}

module "mig3_template" {
  source          = "../terraform-google-vm/modules/instance_template"
  network         = "${google_compute_network.default.self_link}"
  subnetwork      = "${google_compute_subnetwork.group3.self_link}"
  service_account = "${var.service_account}"
  name_prefix     = "${var.network_prefix}-group3"
  startup_script  = "${data.template_file.group-startup-script.rendered}"
  tags            = [
    "${var.network_prefix}-group3",
    "${module.cloud-nat-group3.router_name}"]
}

module "mig3" {
  source            = "../terraform-google-vm/modules/mig"
  instance_template = "${module.mig3_template.self_link}"
  region            = "${var.group3_region}"
  hostname          = "${var.network_prefix}-group3"
  #target_size       = "${var.target_size}"
  target_size       = var.group3_size >= 0? var.group3_size : var.target_size
  named_ports       = [
    {
      name = "http",
      port = 80
    }]
  network           = "${google_compute_network.default.self_link}"
  subnetwork        = "${google_compute_subnetwork.group3.self_link}"
}
