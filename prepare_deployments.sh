#!/bin/bash

# Check if workflow is triggered by workflow_dispatch; then process all .txt files
if [[ "$1" == "workflow_dispatch" ]]; then
  files=()
  for file in modules/*.txt; do
    if [[ $file == *.txt ]]; then
      gist_url=$(sed -n '3p' "$file")
      gist_id=${gist_url##*/}
      files+=("{\"file_path\": \"$file\", \"gist_id\": \"$gist_id\"}")
    fi
  done
  # Join the array elements with commas
  json_array=$(IFS=,; echo "${files[*]}")
  echo "matrix={\"include\": [$json_array]}" >> "$GITHUB_OUTPUT"
else
  # Process only changed .txt files for pull_request or push events
  files=()
  for file in $(git diff --name-only HEAD^ HEAD | grep '^modules/.*\.txt$'); do
    if [[ -f "$file" ]]; then
      gist_url=$(sed -n '3p' "$file")
      gist_id=${gist_url##*/}
      files+=("{\"file_path\": \"$file\", \"gist_id\": \"$gist_id\"}")
    fi
  done
  # Join the array elements with commas
  json_array=$(IFS=,; echo "${files[*]}")
  echo "matrix={\"include\": [$json_array]}" >> "$GITHUB_OUTPUT"
fi