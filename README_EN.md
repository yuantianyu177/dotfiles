# Dotfiles

[中文](README.md)

Personal dotfiles.

## Usage

```bash
git clone https://github.com/yuantianyu177/dotfiles.git
cd dotfiles
./install.sh
```

## Add New Config

1. Add `xxx_items()` function in `install.sh`
2. Add to `SOFTWARES` and `FUNCTIONS` arrays
3. Create config directory

## Structure

```
dotfiles/
├── claude/       # Claude Code config
├── nvim/         # Neovim config
├── oh-my-zsh/    # Oh-My-Zsh config
├── opencode/     # Opencode config
└── install.sh    # Install script
```
