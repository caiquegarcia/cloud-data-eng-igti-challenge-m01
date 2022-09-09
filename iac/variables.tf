variable "bucket_environment" {
  default = "development"
}

variable "bucket_name" {
  default = "desafio-igti-caique-garcia"
}

variable "bucket_function" {
  default = "datalake"
}

variable "etl-script-bronze-to-silver" {
  default = "glue-job-etl-bronze-to-silver.py"
}

variable "etl-script-silver-to-gold" {
  default = "glue-job-etl-silver-to-gold.py"
}