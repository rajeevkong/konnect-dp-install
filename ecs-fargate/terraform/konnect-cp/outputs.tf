
output "control_plane_endpoint" {
  value = konnect_gateway_control_plane.tfdemo.config.control_plane_endpoint
}

output "telemetry_endpoint" {
  value = konnect_gateway_control_plane.tfdemo.config.telemetry_endpoint
}
output "control_plane_id" {
  value = konnect_gateway_control_plane.tfdemo.id
}
