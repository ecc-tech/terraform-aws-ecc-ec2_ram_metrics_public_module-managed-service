variable "ram_thresholds" {
  description = "List of RAM thresholds to create alarms for"
  type        = list(number)
  default     = [70, 80, 90]
}

variable "instances" {
  description = "Map of instances with attributes like instance_id, os_type, and threshold."
  type = list(object({
    instance_id = string
    os_type     = string
  }))
}

variable "sns_topic_arns" {
  description = "List of SNS topic ARNs for alarm actions."
  type        = list(string)
}
