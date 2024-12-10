#!/bin/bash

# Check if a JSON file is provided as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <path_to_json_file>"
  exit 1
fi

# API URL
API_URL="https://newbackend-0xek.onrender.com/api/agency/register"

# Path to your JSON file (provided as an argument)
JSON_FILE="$1"

# Check if the JSON file exists
if [ ! -f "$JSON_FILE" ]; then
  echo "File $JSON_FILE not found!"
  exit 1
fi

# Loop through each object in the JSON file and send a POST request using curl
jq -c '.[]' "$JSON_FILE" | while read -r agency; do
  # Extract individual fields using jq
  agencyName=$(echo "$agency" | jq -r '.agencyName')
  MonumentName=$(echo "$agency" | jq -r '.MonumentName')
  email=$(echo "$agency" | jq -r '.email')
  password=$(echo "$agency" | jq -r '.password')
  desc=$(echo "$agency" | jq -r '.desc')
  contactNumber=$(echo "$agency" | jq -r '.contactNumber')
  ticketPrice=$(echo "$agency" | jq -r '.ticketPrice')
  MonumentLogo=$(echo "$agency" | jq -r '.MonumentLogo')
  city=$(echo "$agency" | jq -r '.city')
  state=$(echo "$agency" | jq -r '.state')
  pincode=$(echo "$agency" | jq -r '.pincode')
  imageUrl=$(echo "$agency" | jq -r '.imageUrl | @csv')
  iframe=$(echo "$agency" | jq -r '.iframe')

  # Prepare JSON data to send in the POST request
  json_data=$(jq -n \
    --arg agencyName "$agencyName" \
    --arg MonumentName "$MonumentName" \
    --arg email "$email" \
    --arg password "$password" \
    --arg desc "$desc" \
    --arg contactNumber "$contactNumber" \
    --arg ticketPrice "$ticketPrice" \
    --arg MonumentLogo "$MonumentLogo" \
    --arg city "$city" \
    --arg state "$state" \
    --arg pincode "$pincode" \
    --arg imageUrl "$imageUrl" \
    --arg iframe "$iframe" \
    '{
      agencyName: $agencyName,
      MonumentName: $MonumentName,
      email: $email,
      password: $password,
      desc: $desc,
      contactNumber: $contactNumber,
      ticketPrice: $ticketPrice | tonumber,
      MonumentLogo: $MonumentLogo,
      city: $city,
      state: $state,
      pincode: $pincode,
      imageUrl: ($imageUrl | split(",") | map(gsub("\""; ""))),
      iframe: $iframe
    }')

  # Make the POST request using curl
  response=$(curl --location "$API_URL" \
    --header 'Content-Type: application/json' \
    --data-raw "$json_data")

  # Print response from the API
  echo "Response for $agencyName: $response"
done
