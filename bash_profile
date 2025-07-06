# ~/.bash_profile

# 🧠 Source .bashrc if it exists (for aliases, prompt, etc.)
if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
fi

# 🛠️ Ensure ~/.local/bin is in PATH (for Oh My Posh and other tools)
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# 🖥️ Optional: Show system info on login
if [ -x "$(command -v lsb_release)" ]; then
    echo "Welcome to $(lsb_release -ds)"
elif [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "Welcome to $PRETTY_NAME"
fi

# 🕒 Optional: Show login time
echo "Logged in at: $(date)"

# 📁 Optional: Jump to your workspace or dotfiles directory
# cd ~/dotfiles
