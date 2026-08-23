variable "otlp_grpc_port" {
  description = "Host port for OTLP gRPC receiver"
  type        = number
  default     = 4317
}

variable "otlp_http_port" {
  description = "Host port for OTLP HTTP receiver"
  type        = number
  default     = 4318
}

variable "prometheus_export_port" {
  description = "Host port for Prometheus exporter"
  type        = number
  default     = 8889
}

variable "health_check_port" {
  description = "Host port for health check extension"
  type        = number
  default     = 13133
}

variable "loki_endpoint" {
  description = "Loki push endpoint URL"
  type        = string
  default     = "http://loki:3100/loki/api/v1/push"
}

variable "jaeger_endpoint" {
  description = "Jaeger OTLP gRPC endpoint"
  type        = string
  default     = "jaeger:4317"
}

variable "observability_network" {
  description = "Docker network name for observability stack"
  type        = string
  default     = "observability"
}