provider "aws" {
  region     = "ca-central-1"
  access_key = "AKIAVXAV74VIOQ4DUK3G"                     #"${{secrets.AWS_ACCESS_KEY}}"
  secret_key = "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" #"${{secrets.AWS_SECRET_KEY}}"
}
