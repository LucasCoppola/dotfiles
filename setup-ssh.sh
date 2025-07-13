#!/bin/bash

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
   echo "🔑 Setting up SSH key..."
   
   read -p "Enter your email for SSH key: " email
   
   ssh-keygen -t ed25519 -C "$email" -f "$HOME/.ssh/id_ed25519" -N ""
   
   eval "$(ssh-agent -s)"
   ssh-add ~/.ssh/id_ed25519
   
   echo "📋 Add this key to GitHub:"
   echo "----------------------------------------"
   cat ~/.ssh/id_ed25519.pub
   echo "----------------------------------------"
   echo "Go to: https://github.com/settings/ssh/new"
   echo "Press Enter after adding the key to GitHub..."
   read
   
   echo "🔍 Testing GitHub connection..."
   if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
       echo "✅ SSH connection to GitHub successful"
   else
       echo "❌ SSH connection failed. Please check your key setup."
       exit 1
   fi
else
   echo "✅ SSH key already exists"
fi

echo "🎉 SSH setup complete!"
