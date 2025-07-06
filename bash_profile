# ~/.bash_profile

# 🧠 Source .bashrc if it exists (for aliases, prompt, etc.)
if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
fi

# ️ Optional: Show system info on login
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
