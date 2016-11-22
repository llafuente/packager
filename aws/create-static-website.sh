#!/bin/sh

set -ex

PROTOCOL="http"
CLOUDFRONT=""

for i in "$@"
do
case $i in
  --domain=*)
    DOMAIN="${i#*=}"; shift;
  ;;
  --source=*)
    SOURCE="${i#*=}"; shift;
  ;;
  --protocol=*)
    PROTOCOL="${i#*=}"; shift;
  ;;
  --cloudfront)
    CLOUDFRONT="yes";
  ;;
  *)
    # unknown option
  ;;
esac
done


if [ -z ${SOURCE} ]; then
  echo "--source is required"
  echo "KO"
  exit 1
fi

if [ -z ${DOMAIN} ]; then
  echo "--domain is required"
  echo "KO"
  exit 1
fi

# full list: "AllowedMethods": ["GET", "PUT", "POST", "DELETE"]
tee /tmp/cors.json <<EOF >/dev/null
{
  "CORSRules": [
    {
      "AllowedOrigins": ["*"],
      "AllowedHeaders": ["*"],
      "AllowedMethods": ["GET"]
    }
  ]
}
EOF

# if your are going to use cloudfront, maybe consider using:
#"Condition": {
#  "StringEquals": {
#    "aws:UserAgent": "Amazon CloudFront"
#  }
#}

tee /tmp/policy.json <<EOF >/dev/null
{
   "Statement": [
      {
         "Effect": "Allow",
         "Principal": "*",
         "Action": [
           "s3:GetObject"
          ],
         "Resource": "arn:aws:s3:::${DOMAIN}/*"
      },
      {
         "Effect": "Allow",
         "Principal": "*",
         "Action": [
           "s3:ListBucket"
          ],
         "Resource": "arn:aws:s3:::${DOMAIN}"
      }
   ]
}
EOF

tee /tmp/www.policy.json <<EOF >/dev/null
{
   "Statement": [
      {
         "Effect": "Allow",
         "Principal": "*",
         "Action": [
           "s3:GetObject"
          ],
         "Resource": "arn:aws:s3:::www.${DOMAIN}/*"
      },
      {
         "Effect": "Allow",
         "Principal": "*",
         "Action": [
           "s3:ListBucket"
          ],
         "Resource": "arn:aws:s3:::www.${DOMAIN}"
      }
   ]
}
EOF

tee /tmp/website.json <<EOF >/dev/null
{
  "IndexDocument": {
    "Suffix": "index.html"
  },
  "ErrorDocument": {
    "Key": "404.html"
  },
  "RoutingRules": [
    {
      "Condition": {
        "HttpErrorCodeReturnedEquals": "404"
      },
      "Redirect": {
        "HostName": "${DOMAIN}",
        "ReplaceKeyPrefixWith": "#/"
      }
    }
  ]
}
EOF

# create bucket, cors, policy & website
aws s3 mb "s3://${DOMAIN}"
aws s3api put-bucket-cors --bucket ${DOMAIN} \
  --cors-configuration file:///tmp/cors.json
aws s3api put-bucket-policy --bucket ${DOMAIN} \
  --policy file:///tmp/policy.json
aws s3api put-bucket-website --bucket ${DOMAIN} \
  --website-configuration file:///tmp/website.json

./sync-static-website.sh --source=${SOURCE} --domain=${DOMAIN}

# create a dummy website for www.${DOMAIN}, redirect everything to non-www
aws s3 mb "s3://www.${DOMAIN}"
aws s3api put-bucket-policy --bucket "www.${DOMAIN}" \
  --policy file:///tmp/www.policy.json
aws s3api put-bucket-cors --bucket "www.${DOMAIN}" \
  --cors-configuration file:///tmp/cors.json

tee /tmp/www.website.json <<EOF >/dev/null
{
  "RedirectAllRequestsTo" : {
    "HostName" : "${DOMAIN}",
    "Protocol" : "${PROTOCOL}"
  }
}
EOF

aws s3api put-bucket-website --bucket "www.${DOMAIN}" \
  --website-configuration file:///tmp/www.website.json

REGION=$(aws s3api get-bucket-location --bucket ${DOMAIN} \
  --query 'LocationConstraint' --output text)

echo "s3 domain: http://${DOMAIN}.s3-website.${REGION}.amazonaws.com"

# couldfront

if [ ! -z ${CLOUDFRONT} ]; then

  tee /tmp/couldfront.json <<EOF >/dev/null
{
    "Comment": "",
    "CacheBehaviors": {
        "Quantity": 0
    },
    "Logging": {
        "Bucket": "",
        "Prefix": "",
        "Enabled": false,
        "IncludeCookies": false
    },
    "WebACLId": "",
    "Origins": {
        "Items": [
            {
                "S3OriginConfig": {
                    "OriginAccessIdentity": ""
                },
                "OriginPath": "",
                "CustomHeaders": {
                    "Quantity": 0
                },
                "Id": "S3-${DOMAIN}",
                "DomainName": "${DOMAIN}.s3.amazonaws.com"
            }
        ],
        "Quantity": 1
    },
    "DefaultRootObject": "/index.html",
    "PriceClass": "PriceClass_100",
    "Enabled": true,
    "DefaultCacheBehavior": {
        "TrustedSigners": {
            "Enabled": false,
            "Quantity": 0
        },
        "TargetOriginId": "S3-${DOMAIN}",
        "ViewerProtocolPolicy": "allow-all",
        "ForwardedValues": {
            "Headers": {
                "Quantity": 0
            },
            "Cookies": {
                "Forward": "none"
            },
            "QueryStringCacheKeys": {
                "Quantity": 0
            },
            "QueryString": false
        },
        "MaxTTL": 31536000,
        "SmoothStreaming": false,
        "DefaultTTL": 86400,
        "AllowedMethods": {
            "Items": [
                "HEAD",
                "GET"
            ],
            "CachedMethods": {
                "Items": [
                    "HEAD",
                    "GET"
                ],
                "Quantity": 2
            },
            "Quantity": 2
        },
        "MinTTL": 0,
        "Compress": false
    },
    "CallerReference": "1479735850029",
    "ViewerCertificate": {
        "CloudFrontDefaultCertificate": true,
        "MinimumProtocolVersion": "SSLv3",
        "CertificateSource": "cloudfront"
    },
    "CustomErrorResponses": {
        "Quantity": 0
    },
    "HttpVersion": "http2",
    "Restrictions": {
        "GeoRestriction": {
            "RestrictionType": "none",
            "Quantity": 0
        }
    },
    "Aliases": {
        "Quantity": 0
    }
}
EOF

  DISTRIBUTION_ID=$(aws cloudfront create-distribution \
    --origin-domain-name "${DOMAIN}.s3.amazonaws.com" \
    --default-root-object index.html
    --query 'Id' --text)

  CLOUDFRONT_DOMAIN=$(aws cloudfront get-distribution \
    --id ${DISTRIBUTION_ID} --query 'Distribution.DomainName')

  echo "cloudfront domain: ${CLOUDFRONT_DOMAIN}"
  echo "NOTE! Now you have to wait a lot for cloudfront to be ready!"

fi
