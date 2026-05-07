#!/bin/bash
# Upload instructions for ibus-quick-classic-suggestion
# =====================================================
# Step 1: Create a new repository on GitHub
#   - Go to https://github.com/new
#   - Repository name: ibus-quick-classic-suggestion
#   - Description: Enhanced 聯想字 (Association/Suggestion) for IBus Quick Classic
#   - Public
#   - Do NOT initialize with README (we already have one)
#   - Click "Create repository"
#
# Step 2: Run the commands below (replace YOUR_USERNAME):

cd ~/apps/ibus

git commit -m "Initial release: Traditional Chinese 聯想字 for ibus-table-quick-classic"

git branch -M main

# >>> Replace YOUR_USERNAME below with your GitHub username <<<
git remote add origin https://github.com/denverjen/ibus-quick-classic-suggestion.git

git push -u origin main

echo ""
echo "Done! Your repo is now at:"
echo "  https://github.com/denverjen/ibus-quick-classic-suggestion"
