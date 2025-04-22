#!/bin/bash

# Process collected data
mkdir -p data/processed

# Create a CSV for repository metrics
echo "Repository,Stars,Forks,Contributors,Open_Issues,Language,Created_At,Updated_At" > data/processed/repository_metrics.csv

# Process each repository
for repo_file in data/raw/*_repo.json; do
  repo_name=$(echo $repo_file | sed 's|data/raw/||' | sed 's|_repo.json||' | tr '_' '/')
  
  # Extract key metrics using jq (if installed)
  if command -v jq >/dev/null 2>&1; then
    stars=$(jq '.stargazers_count' $repo_file)
    forks=$(jq '.forks_count' $repo_file)
    open_issues=$(jq '.open_issues_count' $repo_file)
    language=$(jq -r '.language' $repo_file)
    created_at=$(jq -r '.created_at' $repo_file)
    updated_at=$(jq -r '.updated_at' $repo_file)
    
    # Count contributors
    contrib_file="data/raw/$(echo $repo_name | tr '/' '_')_contributors.json"
    if [ -f "$contrib_file" ]; then
      contributors=$(jq '. | length' $contrib_file)
    else
      contributors="N/A"
    fi
    
    # Append to CSV
    echo "$repo_name,$stars,$forks,$contributors,$open_issues,$language,$created_at,$updated_at" >> data/processed/repository_metrics.csv
  else
    echo "jq is not installed. Please install jq for JSON processing."
    exit 1
  fi
done

echo "Analysis complete! Results saved in data/processed/"

