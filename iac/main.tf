############################################################################
############################ BUCKETS AND LAYERS ############################
############################################################################

# Creating our Datalake as S3 Bucket
resource "aws_s3_bucket" "datalake-desafio" {

  bucket = "${var.bucket_function}-${var.bucket_name}-${var.bucket_environment}"
  acl    = "private"

}

# Creating Datalake Bronze Layer
resource "aws_s3_object" "datalake-bronze-layer" {

  bucket = aws_s3_bucket.datalake-desafio.id
  key    = "bronze-layer/"
  acl    = "private"
}

# Creating Datalake Silver Layer
resource "aws_s3_object" "datalake-silver-layer" {

  bucket = aws_s3_bucket.datalake-desafio.id
  key    = "silver-layer/"
  acl    = "private"

}

# Criando nossa gold-layer
resource "aws_s3_object" "datalake-gold-layer" {

  bucket = aws_s3_bucket.datalake-desafio.id
  key    = "golden-layer/"
  acl    = "private"

}

############################################################################
############################# GLUE CRAWLER ROLE ############################
############################################################################

# Creating Role to allow crawlers on Datalake
resource "aws_iam_role" "glue-crawler-datalake-role" {
  name               = "glue-crawler-datalake-role"
  assume_role_policy = <<EOF
	{
	"Version": "2012-10-17",
	"Statement": [
		{
		"Action": "sts:AssumeRole",
		"Principal": {
			"Service": "glue.amazonaws.com"
		},
		"Effect": "Allow",
		"Sid": ""
		}
	]
	}
EOF
}

# Attaching Managed Policy "AWS Glue Service Role" with our Role 
resource "aws_iam_role_policy_attachment" "crawler-with-glue-service-role" {
  role       = aws_iam_role.glue-crawler-datalake-role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

# Creating Policy to read and write Silver Layer on Datalake
resource "aws_iam_policy" "read-write-datalake-silver-layer" {
  name = "read-write-datalake-silver-layer"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:GetObject",
            "s3:PutObject"
          ],
          "Resource" : [
            "arn:aws:s3:::igti-bootcamp-desafio-desafio/silver-layer*"
          ]
        }
      ]
    }
  )
}

# Attaching read and write Customer Managed Policy with our role
resource "aws_iam_role_policy_attachment" "crawler-with-read-write-datalake-silver-layer" {
  role       = aws_iam_role.glue-crawler-datalake-role.id
  policy_arn = aws_iam_policy.read-write-datalake-silver-layer.arn
}

# Creating Policy to read and write Gold Layer on Datalake
resource "aws_iam_policy" "read-write-datalake-gold-layer" {
  name = "read-write-datalake-gold-layer"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:GetObject",
            "s3:PutObject"
          ],
          "Resource" : [
            "arn:aws:s3:::igti-bootcamp-desafio-desafio/gold-layer*"
          ]
        }
      ]
    }
  )
}

# Attaching read and write Customer Managed Policy with our role
resource "aws_iam_role_policy_attachment" "crawler-with-read-write-datalake-gold-layer" {
  role       = aws_iam_role.glue-crawler-datalake-role.id
  policy_arn = aws_iam_policy.read-write-datalake-gold-layer.arn
}

############################################################################
########################### GLUE CATALOG DATABASE ##########################
############################################################################

# Creating Glue Catalog Database to Datalake Silver Layer 
resource "aws_glue_catalog_database" "glue-catalog-db-datalake-silver-layer" {
  name = "glue-catalog-db-datalake-silver-layer"
}

# Creating Glue Catalog Database to Datalake Gold Layer
resource "aws_glue_catalog_database" "glue-catalog-db-datalake-gold-layer" {
  name = "glue-catalog-db-datalake-gold-layer"
}

############################################################################
############################### GLUE CRAWLERS ##############################
############################################################################

# Creating Glue Crawler: Silver Layer Crawler
resource "aws_glue_crawler" "datalake-silver-layer-crawler" {

	name = "datalake-silver-layer-crawler"
	database_name = aws_glue_catalog_database.glue-catalog-db-datalake-silver-layer.name
	role = aws_iam_role.glue-crawler-datalake-role.arn
	
	s3_target {
		path = aws_s3_object.datalake-silver-layer.id
	}
}

# Creating Glue Crawler: Gold Layer Crawler
resource "aws_glue_crawler" "datalake-gold-layer-crawler" {
	name = "datalake-gold-layer-crawler"
	database_name = aws_glue_catalog_database.glue-catalog-db-datalake-gold-layer.name
	role = aws_iam_role.glue-crawler-datalake-role.arn
	
	s3_target {
		path = aws_s3_object.datalake-gold-layer.id
	}
}

############################################################################
############################################################################
############################################################################






