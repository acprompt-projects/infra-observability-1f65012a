resource "docker_image" "otel_collector" {
  name         = "otel/opentelemetry-collector-contrib:0.96.0"
  keep_locally = true
}

resource "docker_container" "otel_collector" {
  name  = "otel-collector"
  image = docker_image.otel_collector.image_id

  ports {
    internal = 4317
    external = var.otlp_grpc_port
    protocol = "tcp"
  }

  ports {
    internal = 4318
    external = var.otlp_http_port
    protocol = "tcp"
  }

  ports {
    internal = 8889
    external = var.prometheus_export_port
    protocol = "tcp"
  }

  ports {
    internal = 13133
    external = var.health_check_port
    protocol = "tcp"
  }

  upload {
    file = "/etc/otelcol-contrib/config.yaml"
    content = templatefile(
      "${path.module}/otel-collector-config.yaml",
      {
        loki_endpoint   = var.loki_endpoint
        jaeger_endpoint = var.jaeger_endpoint
      }
    )
  }

  networks_advanced {
    name = var.observability_network
  }

  env = [
    "GOMEMLIMIT=512MiB",
  ]

  restart = "unless-stopped"

  labels {
    label = "app.kubernetes.io/name"
    value = "otel-collector"
  }

  labels {
    label = "app.kubernetes.io/component"
    value = "observability"
  }

  healthcheck {
    test         = ["CMD", "wget", "--spider", "-q", "http://localhost:13133/"]
    interval     = "10s"
    timeout      = "5s"
    retries      = 3
    start_period = "10s"
  }

  resources {
    limits {
      memory = "768"
    }
  }
}