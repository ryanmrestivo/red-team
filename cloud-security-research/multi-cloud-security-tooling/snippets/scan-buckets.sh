# List all buckets with regular AWS CLI and dump in JSON file
aws s3api list-buckets > buckets-data.json

# Read JSON, and let JQ create new file with newline-delimited flat bucket name list
cat buckets-data.json | jq '.Buckets[].Name' -r > buckets.txt

# Scan buckets from flat list
# Need to modify source code first, since the "include-closed" option is blocked out-of-the-box
python3 s3scanner.py --include-closed --out-file buckets.txt --dump names.txt