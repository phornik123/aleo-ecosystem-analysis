#!/bin/bash

# Define ecosystems with their repositories
declare -A ecosystems
ecosystems["Aleo"]="AleoHQ_leo AleoHQ_snarkOS AleoHQ_snarkVM"
ecosystems["Solana"]="solana-labs_solana solana-labs_solana-program-library"
ecosystems["zkSync"]="matter-labs_zksync-era"
ecosystems["Starknet"]="starkware-libs_cairo"
ecosystems["Scroll"]="scroll-tech_scroll"
ecosystems["Aztec"]="AztecProtocol_aztec-packages"
ecosystems["Mina"]="MinaProtocol_mina"

# Create output directory
mkdir -p data/processed

# Create a file to store contributor data by ecosystem
echo "Ecosystem,Contributor,Repos" > data/processed/ecosystem_contributors.csv

# Process each ecosystem
for ecosystem in "${!ecosystems[@]}"; do
  echo "Processing $ecosystem ecosystem..."
  
  # Get unique contributors across all repos in this ecosystem
  all_contributors=""
  
  for repo in ${ecosystems[$ecosystem]}; do
    contrib_file="data/raw/${repo}_contributors.json"
    
    if [ -f "$contrib_file" ]; then
      # Extract contributor logins from JSON
      repo_contributors=$(grep -o '"login": "[^"]*"' "$contrib_file" | cut -d'"' -f4)
      all_contributors="$all_contributors $repo_contributors"
    fi
  done
  
  # Process unique contributors
  for contributor in $(echo "$all_contributors" | tr ' ' '\n' | sort -u); do
    if [ ! -z "$contributor" ]; then
      echo "$ecosystem,$contributor,1" >> data/processed/ecosystem_contributors.csv
    fi
  done
done

# Create overlap analysis
echo "Ecosystem1,Ecosystem2,Common_Contributors,Ecosystem1_Total,Ecosystem2_Total,Overlap_Percentage" > data/processed/ecosystem_overlap.csv

# Calculate ecosystem overlaps
for eco1 in "${!ecosystems[@]}"; do
  for eco2 in "${!ecosystems[@]}"; do
    # Skip self-comparisons
    if [ "$eco1" != "$eco2" ]; then
      # Get contributors for each ecosystem
      eco1_contribs=$(grep "^$eco1," data/processed/ecosystem_contributors.csv | cut -d',' -f2)
      eco2_contribs=$(grep "^$eco2," data/processed/ecosystem_contributors.csv | cut -d',' -f2)
      
      # Count unique contributors
      eco1_count=$(echo "$eco1_contribs" | wc -l)
      eco2_count=$(echo "$eco2_contribs" | wc -l)
      
      # Find common contributors
      common_contribs=$(echo "$eco1_contribs $eco2_contribs" | tr ' ' '\n' | sort | uniq -d)
      common_count=$(echo "$common_contribs" | grep -v "^$" | wc -l)
      
      # Calculate overlap percentage
      if [ $eco1_count -le $eco2_count ]; then
        smaller=$eco1_count
      else
        smaller=$eco2_count
      fi
      
      if [ $smaller -gt 0 ]; then
        # Fixed to use bash arithmetic instead of bc
        overlap_pct=$(( (common_count * 100) / smaller ))
      else
        overlap_pct=0
      fi
      
      # Write to CSV
      echo "$eco1,$eco2,$common_count,$eco1_count,$eco2_count,$overlap_pct" >> data/processed/ecosystem_overlap.csv
    fi
  done
done

echo "Ecosystem overlap analysis complete! Results in data/processed/ecosystem_overlap.csv"
