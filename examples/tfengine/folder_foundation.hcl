# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# {{$recipes := "../../templates/tfengine/recipes"}}

data = {
  parent_type           = "folder"
  parent_id             = "12345678"
  billing_account       = "000-000-000"

  # Default locations for resources. Can be overridden in individual templates.
  bigquery_location = "us-east1"
  cloud_sql_region  = "us-central1"
  compute_region    = "us-central1"
  storage_location  = "us-central1"
}

template "devops" {
  recipe_path = "{{$recipes}}/devops.hcl"
  data = {
    # TODO(user): Uncomment and re-run the engine after generated bootstrap module has been deployed.
    # Run `terraform init` in the bootstrap module to backup its state to GCS.
    # bootstrap_gcs_backend = true

    project_id   = "example-devops"
    state_bucket = "example-terraform-state"
    admins_group = "example-folder-admins@example.com"
    project_owners = [
      "group:example-devops-owners@example.com",
    ]

    cicd = {
      github = {
        owner = "GoogleCloudPlatform"
        name  = "example"
      }
      branch_regex                  = "^master$"
      terraform_root                = "terraform"
      enable_continuous_deployment  = true
      enable_triggers               = true
      build_viewers = [
        "group:example-cicd-viewers@example.com",
      ]
    }
  }
}

template "audit" {
  recipe_path = "{{$recipes}}/audit.hcl"
  output_path = "./live"
  data = {
    project_id     = "example-audit"
    dataset_name   = "1yr_org_audit_logs"
    bucket_name    = "7yr-org-audit-logs"
    auditors_group = "example-auditors@example.com"
  }
}

template "monitor" {
  recipe_path = "{{$recipes}}/monitor.hcl"
  output_path = "./live"
  data = {
    project_id = "example-monitor"
    domain     = "example.com"
  }
}

# Top level prod folder.
template "folder_prod" {
  recipe_path = "{{$recipes}}/folder.hcl"
  output_path = "./live/prod"
  data = {
    display_name = "prod"
  }
}

# Prod folder for team 1.
template "folder_team1" {
  recipe_path = "{{$recipes}}/folder.hcl"
  output_path = "./live/prod/team1"
  data = {
    parent_type                  = "folder"
    add_parent_folder_dependency = true
    display_name                 = "team1"
  }
}
