output "archive_hash" {
  value       = data.archive_file.zip.output_base64sha256
  description = "archive hash value"
}