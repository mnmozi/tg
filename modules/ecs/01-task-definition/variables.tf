variable "region" {
  type        = string
  description = "The AWS region to deploy the resources in."
}
variable "environment" {
  type        = string
  description = "The AWS region to deploy the resources in."
}

variable "images_repos" {
  type        = list(string)
  description = "List of ECR repository names."
}

variable "container_names" {
  type        = list(string)
  description = "List of container names."
}

variable "owner" {
  type    = string
  default = null
}

variable "iam_task_policy_identifier" {
  type    = string
  default = null
}

variable "iam_task_role_identifier" {
  type    = string
  default = null
}

variable "iam_execution_role_name" {
  type    = string
  default = null
}

variable "iam_execution_policy_identifier" {
  type    = string
  default = null
}

variable "linked_execution_policies" {
  description = "Additional policies to attach to the IAM role"
  type        = map(string)
  default     = {}
}

variable "linked_task_policies" {
  description = "Additional policies to attach to the IAM role"
  type        = map(string)
  default     = {}
}

variable "service_name" {
  type    = string
  default = null
}

variable "cpus" {
  type        = map(number)
  description = "A map of container names to their respective CPU values."
}

variable "memories" {
  type        = map(number)
  description = "A map of container names to their respective memory values."
}

variable "containers_port" {
  type        = map(number)
  description = "A map of container names to their respective container ports."
  default     = {}
}

variable "hosts_port" {
  type        = map(number)
  description = "A map of container names to their respective host ports."
  default     = {}
}

variable "required_tags" {
  type = object({
    project   = string
    component = string
  })
  description = "Required tags for all resources, project, component, and criticality."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags to apply to all resources."
}

variable "environment_variables" {
  type = map(list(object({
    name  = string
    value = string
  })))
  description = "A map where each key is a container name, and the value is a list of environment variable objects."
  default     = {}
}

variable "secrets_names" {
  type        = map(string)
  description = "A map of secret names in AWS Secrets Manager to retrieve data from."
}
variable "commands" {
  type    = map(list(string))
  default = {}
}

# variable "secrets" {
#   type        = map(list(string))
#   description = "A map where each key is a container name, and the value is a list of secret names."
# }

variable "custom_execution_statements" {
  type = list(object({
    Effect   = string
    Action   = list(string)
    Resource = list(string)
  }))
  default     = []
  description = "Additional custom policy statements to include for the execution role."
}

variable "log_drivers" {
  type        = map(string)
  default     = {}
  description = "A map of container names to their respective log drivers."
}

variable "custom_task_role_statements" {
  type = list(object({
    Effect   = string
    Action   = list(string)
    Resource = list(string)
  }))
  default     = []
  description = "Additional custom policy statements to include for the task role."
}

variable "requires_compatibilities" {
  type        = set(string)
  default     = ["FARGATE", "EC2"]
  description = "The launch types required for the ECS task (e.g., FARGATE or EC2)."
}

variable "cpu_architecture" {
  type        = string
  default     = "X86_64"
  description = "The CPU architecture for the ECS task definition (e.g., X86_64 or ARM64)."
}
