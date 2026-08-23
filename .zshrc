# PATH
export PATH="/Users/$USER/.local/bin:$PATH"

# Aliases
alias reload="source $HOME/.zshrc"
alias zshconfig="$EDITOR ~/.zshrc"
alias cleardd="rm -rf $HOME/Library/Developer/Xcode/DerivedData"

# starship
eval "$(starship init zsh)"
