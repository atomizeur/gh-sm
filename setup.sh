# Atomizeur
# Sept. 20, 2025
# Setup/install ghpm (GitHub Package Manager)
#!/bin/bash

# Check for .github directory in home folder
echo "Creating .github directory in home folder if it doesn't exist..."
if grep -q "gitdir" /home/$USER/.github; then
  echo ".github already exists, skipping..."
else
  echo ".github does not exist, creating..."
  mkdir /home/$USER/.github
fi

# Install dependencies
echo "Installing dependencies..."
sudo apt-get update
sudo apt-get install -y curl git jq make cmake ninja-build build-essential gettext fakeroot devscripts python3-pip python3-setuptools python3-wheel

# Create ghpm alias
# Check if alias already exists in .bashrc
if grep -q "alias ghpm=" /home/$USER/.bashrc; then
  echo "ghpm alias already exists in .bashrc, skipping..."
else
  echo "Creating ghpm alias in .bashrc..."
  echo "alias ghpm='bash /home/$USER/shell/ghpm/ghpm.sh'" >>/home/$USER/.bashrc
fi
