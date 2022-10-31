URL="www.example.com"
OUTPUT="/tmp/website_status"

# probably shouldn't store in tmp in practice
ORIGINAL="/tmp/sample1_website"
NEW="/tmp/sample2_website"


if [ ! -f $ORIGINAL ]; then
  # file not found, so create it
  curl -s -o $ORIGINAL $URL
fi

curl -s -o $NEW $URL

if diff $ORIGINAL $NEW >> $OUTPUT; then
  echo "Website checked but not changed $(date)" >> $OUTPUT
else
  echo "Website changed $(date)" >> $OUTPUT
fi
 