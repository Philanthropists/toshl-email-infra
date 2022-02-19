# Toshl Email Autosync Terraform Infrastructure

This is a personal project aimed at automating email processing from bank statements when
there is no API available to synchronize it to Toshl. Any other uses are not its main purpose.

## TODOs

- [x] Build Lambda function from Docker container
  - [x] Add ECR module to upload docker images into AWS from local machine
  - [x] Change Lambda function to use latest image from ECR on every execution
