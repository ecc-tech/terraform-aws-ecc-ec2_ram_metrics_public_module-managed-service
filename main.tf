locals {
  ram_alarm_configs = merge([
    for inst in var.instances : {
      for threshold in var.ram_thresholds :
      "${inst.instance_id}-${threshold}" => {
        instance_id = inst.instance_id
        os_type     = inst.os_type
        threshold   = threshold
      }
    }
  ]...)



  metric_config = {
    linux = {
      metric_name = "mem_used_percent"
      namespace   = "CWAgent"
    }
    windows = {
      metric_name = "Memory % Committed Bytes In Use"
      namespace   = "CWAgent"
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "memory_alarm" {
  for_each = local.ram_alarm_configs

  alarm_name          = "Memory-${each.value.instance_id}-${each.value.threshold}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = local.metric_config[each.value.os_type].metric_name
  namespace           = local.metric_config[each.value.os_type].namespace
  period              = 300
  statistic           = "Average"
  threshold           = each.value.threshold

  alarm_description = "Memory usage alarm for ${each.value.os_type} instance above ${each.value.threshold}%"

  dimensions = {
    InstanceId   = each.value.instance_id
    ImageId      = data.aws_instance.instance_details[each.value.instance_id].ami
    InstanceType = data.aws_instance.instance_details[each.value.instance_id].instance_type
    # Add objectname for Windows memory metrics
    objectname = each.value.os_type == "windows" ? "Memory" : null
  }

  treat_missing_data = "notBreaching"
  actions_enabled    = true
  alarm_actions      = var.sns_topic_arns
}
data "aws_instance" "instance_details" {
  for_each    = { for inst in var.instances : inst.instance_id => inst }
  instance_id = each.key
}

