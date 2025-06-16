
output "ram_alarms" {
  description = "Map of created RAM alarms with their configurations"
  value = {
    for k, alarm in aws_cloudwatch_metric_alarm.memory_alarm : k => {
      alarm_name  = alarm.alarm_name
      alarm_arn   = alarm.arn
      instance_id = alarm.dimensions.InstanceId
      threshold   = alarm.threshold
      metric_name = alarm.metric_name
      namespace   = alarm.namespace
    }
  }
}

output "ram_alarm_names" {
  description = "List of created RAM alarm names"
  value       = [for alarm in aws_cloudwatch_metric_alarm.memory_alarm : alarm.alarm_name]
}

output "alarm_count" {
  description = "Total number of RAM alarms created"
  value       = length(aws_cloudwatch_metric_alarm.memory_alarm)
}