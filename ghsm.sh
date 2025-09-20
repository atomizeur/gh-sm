# atomizeur
# Sept. 20, 2025
# GH-SM - GitHub Source (Code) Manager
# A simple script to search, clone, build, and install GitHub repositories.

#!/bin/bash

read -p "Enter search term for GitHub repositories: " search

# Search GitHub for repos (get top 10 results)
curl -s "https://api.github.com/search/repositories?q=$search&per_page=10" | jq '.items[] | {name: .full_name, url: .clone_url, desc: .description}' >results.json

if [ ! -s results.json ]; then
  echo "No repositories found."
  exit 1
fi

echo "Checking if Linux program..."

# Filter repos whose README contains 'Linux'
jq -c '.' results.json | while read repo; do
  name=$(echo "$repo" | jq -r '.name')
  url=$(echo "$repo" | jq -r '.url')
  desc=$(echo "$repo" | jq -r '.desc')

  # Fetch README (raw content)
  readme=$(curl -s "https://api.github.com/repos/$name/readme" | jq -r '.content' | base64 --decode 2>/dev/null)

  if echo "$readme" | grep -iq 'sudo'; then
    echo "$name: $desc"
  fi
done

read -p "Enter the full repo name to clone (atomizeur/ghpm): " repo_name

repo_url=$(jq -r "select(.name==\"$repo_name\") | .url" results.json)
if [ -z "$repo_url" ]; then
  echo "Repository not found in the list."
  exit 1
fi

read -p "Proceed to clone and build $repo_name? (y/n): " confirm
if [[ "$confirm" != "y" ]]; then
  echo "Aborting."
  exit 0
fi

# Remove existing repo with same name
if [ -d "/home/$USER/.github/${repo_name#*/}" ]; then
  rm -rf "/home/$USER/.github/${repo_name#*/}"
fi

# Clone the repo
cd /home/$USER/.github
git clone "$repo_url"
cd "${repo_name#*/}" || exit 1

# Detect build system
if [ -f "setup.py" ] || [ -f "pyproject.toml" ]; then
  echo "Detected Python project."
  if [ -f "requirements.txt" ]; then
    echo "Installing Python requirements from requirements.txt..."
    pip3 install --user -r requirements.txt
  fi
  if [ -f "pyproject.toml" ]; then
    echo "Installing via pip (pyproject.toml detected)..."
    pip3 install --user .
  else
    echo "Installing via setup.py..."
    sudo python3 setup.py install
  fi
elif [ -f "Cargo.toml" ]; then
  # Rust project detected!
  if ! command -v cargo >/dev/null 2>&1; then
    echo "Rust's cargo tool is not installed. Please install Rust: https://rustup.rs/"
    exit 1
  fi
  echo "Detected Rust project."
  echo "Building and installing with cargo..."
  cargo install --path .
elif [ -f "Makefile" ]; then
  echo "Building with make..."
  make && sudo make install
elif [ -f "CMakeLists.txt" ]; then
  mkdir -p build && cd build
  cmake .. && make && sudo make install
elif [ -f "meson.build" ]; then
  meson setup build && ninja -C build && sudo ninja -C build install
else
  echo "Unknown build system. Please build manually."
fi
