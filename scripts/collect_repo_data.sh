#!/bin/bash

# List of repositories to analyze
REPOS=(
  "AleoHQ/leo"
  "AleoHQ/snarkOS"
  "AleoHQ/snarkVM"
  "solana-labs/solana"
  "solana-labs/solana-program-library"
  "starkware-libs/cairo"
  "matter-labs/zksync-era"
  "scroll-tech/scroll"
  "AztecProtocol/aztec-packages"
  "MinaProtocol/mina"
)

# Create directory for raw data
mkdir -p data/raw

# Collect repository data
for repo in "${REPOS[@]}"; do
  echo "Processing $repo..."
  
  # Get basic repository data
  curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/repos/$repo" > "data/raw/$(echo $repo | tr '/' '_')_repo.json"
  
  # Get contributor data
  curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/repos/$repo/contributors?per_page=100" > "data/raw/$(echo $repo | tr '/' '_')_contributors.json"
  
  # Get commit activity
  curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/repos/$repo/stats/commit_activity" > "data/raw/$(echo $repo | tr '/' '_')_commit_activity.json"
  
  # Get participation stats
  curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/repos/$repo/stats/participation" > "data/raw/$(echo $repo | tr '/' '_')_participation.json"
  
  # Avoid rate limiting
  sleep 2
done

echo "Data collection complete!"
