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

provider "google" {
  credentials = "${file(var.credentials_path)}"
  project     = "${var.project_id}"
  version     = "~> 2.7.0"
}

provider "google-beta" {
  credentials = "${file(var.credentials_path)}"
  project     = "${var.project_id}"
  version     = "~> 2.7.0"
}

resource "google_compute_network" "default" {
  name                    = "${var.network_prefix}"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "group1" {
  name                     = "${var.network_prefix}-group1"
  ip_cidr_range            = "10.126.0.0/20"
  network                  = "${google_compute_network.default.self_link}"
  region                   = "${var.group1_region}"
  private_ip_google_access = true
}

# Router and Cloud NAT are required for installing packages from repos (apache, php etc)
resource "google_compute_router" "group1" {
  name    = "${var.network_prefix}-gw-group1"
  network = "${google_compute_network.default.self_link}"
  region  = "${var.group1_region}"
}

module "cloud-nat-group1" {
  source     = "../terraform-google-cloud-nat/"
  router     = "${google_compute_router.group1.name}"
  project_id = "${var.project_id}"
  region     = "${var.group1_region}"
  name       = "${var.network_prefix}-cloud-nat-group1"
}

resource "google_compute_subnetwork" "group2" {
  name                     = "${var.network_prefix}-group2"
  ip_cidr_range            = "10.127.0.0/20"
  network                  = "${google_compute_network.default.self_link}"
  region                   = "${var.group2_region}"
  private_ip_google_access = true
}

# Router and Cloud NAT are required for installing packages from repos (apache, php etc)
resource "google_compute_router" "group2" {
  name    = "${var.network_prefix}-gw-group2"
  network = "${google_compute_network.default.self_link}"
  region  = "${var.group2_region}"
}

module "cloud-nat-group2" {
  source     = "../terraform-google-cloud-nat/"
  router     = "${google_compute_router.group2.name}"
  project_id = "${var.project_id}"
  region     = "${var.group2_region}"
  name       = "${var.network_prefix}-cloud-nat-group2"
}

# Router and Cloud NAT are required for installing packages from repos (apache, php etc)
resource "google_compute_router" "group3" {
  name    = "${var.network_prefix}-gw-group3"
  network = "${google_compute_network.default.self_link}"
  region  = "${var.group3_region}"
}

module "cloud-nat-group3" {
  source     = "../terraform-google-cloud-nat/"
  router     = "${google_compute_router.group3.name}"
  project_id = "${var.project_id}"
  region     = "${var.group3_region}"
  name       = "${var.network_prefix}-cloud-nat-group3"
}

resource "google_compute_subnetwork" "group3" {
  name                     = "${var.network_prefix}-group3"
  ip_cidr_range            = "10.128.0.0/20"
  network                  = "${google_compute_network.default.self_link}"
  region                   = "${var.group3_region}"
  private_ip_google_access = true
}

module "gce-lb-http" {
  source            = "../terraform-google-lb-http"
  name              = "${var.network_prefix}"
  project           = "${var.project_id}"
  target_tags       = [
    "${var.network_prefix}-group1",
    "${module.cloud-nat-group1.router_name}",
    "${var.network_prefix}-group2",
    "${module.cloud-nat-group2.router_name}",
    "${var.network_prefix}-group3",
    "${module.cloud-nat-group3.router_name}"]
  firewall_networks = [
    "${google_compute_network.default.name}"]

  backends = {
    "0" = [
      {
        group                        = "${module.mig1.instance_group}"
        balancing_mode               = null
        capacity_scaler              = null
        description                  = null
        max_connections              = null
        max_connections_per_instance = null
        max_rate                     = null
        max_rate_per_instance        = null
        max_utilization              = null
      },
      {
        group                        = "${module.mig2.instance_group}"
        balancing_mode               = null
        capacity_scaler              = null
        description                  = null
        max_connections              = null
        max_connections_per_instance = null
        max_rate                     = null
        max_rate_per_instance        = null
        max_utilization              = null
      },
      {
        group                        = "${module.mig3.instance_group}"
        balancing_mode               = null
        capacity_scaler              = null
        description                  = null
        max_connections              = null
        max_connections_per_instance = null
        max_rate                     = null
        max_rate_per_instance        = null
        max_utilization              = null
      },
    ]
  }

  backend_params = [
    // health check path, port name, port number, timeout seconds.
    "/,http,80,10",
  ]
}
