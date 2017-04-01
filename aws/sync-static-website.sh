#!/bin/sh

set -x

for i in "$@"
do
case $i in
  --domain=*)
    DOMAIN="${i#*=}"; shift;
  ;;
  --source=*)
    SOURCE="${i#*=}"; shift;
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

#install minifier if needed!
if [ -z `which html-minifier` ]; then
  npm install -g html-minifier
  if [ -z `which html-minifier` ]; then
    echo "html-minifier cannot be installed"
    exit 1
  fi
fi


#public/index.html: HTML document, UTF-8 Unicode text
#public/index.html: gzip compressed data, was "index.html", \
#from Unix, last modified: Tue Nov 22 16:43:35 2016, max compression
IS_COMPRESSED=$(file "${SOURCE}/index.html" | grep 'gzip')

# do not re-compress
if [ -z "${IS_COMPRESSED}" ]; then
  echo "compressing source path"
  set -e # be sure everything is OK with minification & gzip-ing

  # minify
    HTMLS=$(find ${SOURCE} -name '*.html')
    for FILE in ${HTMLS};
    do
      echo "minify ${FILE}"
      html-minifier --collapse-whitespace --remove-tag-whitespace "${FILE}" | sponge "${FILE}"
    done

  # gzip files
  find ${SOURCE} -type f | xargs gzip -9
  # rename .*.gz .*
  find ${SOURCE} -type f -name '*.gz' | \
    while read f; do mv "$f" "${f%.gz}"; done

  set +e
fi

# sync files
# html: no cache
aws s3 sync \
  --content-encoding gzip \
  --exclude "*" --include "*.html" \
  "${SOURCE}" "s3://${DOMAIN}"
# xml: no cache
aws s3 sync \
  --content-encoding gzip \
  --exclude "*" --include "*.xml" \
  --content-type "application/xml" \
  "${SOURCE}" "s3://${DOMAIN}"

# rest of files ensure cache!
aws s3 sync \
  --content-encoding gzip \
  --cache-control "max-age=2592000" --acl "public-read" --sse "AES256" \
  --exclude "*.html" --exclude "*.xml" \
  "${SOURCE}" "s3://${DOMAIN}"
