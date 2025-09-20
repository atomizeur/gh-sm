# Atomizeur
# Sept. 20, 2025
# Setup/install GH-SM (GitHub Source (Code) Manager)
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

# Create ghsm alias
# Check if alias already exists in .bashrc
if grep -q "alias ghsm=" /home/$USER/.bashrc; then
  echo "ghsm alias already exists in .bashrc, skipping..."
else
  echo "Creating ghsm alias in .bashrc..."
  echo "alias ghsm='bash /home/$USER/shell/ghsm/ghsm.sh'" >>/home/$USER/.bashrc
fi
