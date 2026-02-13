#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# ============ Software definitions ============
# Format: "src(relative to dotfiles)|target_path"

claude_items() {
  cat <<'LIST'
claude/CLAUDE.md|~/.claude/CLAUDE.md
claude/settings.json|~/.claude/settings.json
claude/hook_scripts|~/.claude/hook_scripts
claude/skills|~/.claude/skills
claude/template|~/.claude/template
claude/interface|~/.claude/interface
LIST
}

nvim_items() {
  cat <<'LIST'
nvim|~/.config/nvim
LIST
}

ohmyzsh_items() {
  cat <<'LIST'
oh-my-zsh/aliases.zsh|~/.oh-my-zsh/custom/aliases.zsh
LIST
}

opencode_items() {
  cat <<'LIST'
opencode/opencode.json|~/.config/opencode/opencode.json
opencode/AGENTS.md|~/.config/opencode/AGENTS.md
claude/skills|~/.config/opencode/skills
LIST
}

# ============ Registry ============
SOFTWARES=("claude" "nvim" "oh-my-zsh" "opencode")
FUNCTIONS=("claude_items" "nvim_items" "ohmyzsh_items" "opencode_items")

# ============ Link helper ============
link_item() {
  local src="$DOTFILES_DIR/$1"
  local dst="${2/#\~/$HOME}"

  if [ ! -e "$src" ]; then
    echo "  [skip] $1 (source not found)"
    return
  fi

  mkdir -p "$(dirname "$dst")"

  if [ -L "$dst" ]; then
    rm "$dst"
  elif [ -e "$dst" ]; then
    local backup="$(dirname "$dst")/.$(basename "$dst").bak.$(date +%Y%m%d%H%M%S)"
    mv "$dst" "$backup"
    echo "  [backup] $dst -> $backup"
  fi

  ln -s "$src" "$dst"
  echo "  [link] $dst -> $src"
}

install_software() {
  local name="$1" func="$2"
  echo ""
  echo ">>> Installing $name"
  while IFS='|' read -r src dst; do
    link_item "$src" "$dst"
  done < <("$func")

  # Make scripts executable
  if [ "$name" = "claude" ]; then
    chmod +x "$DOTFILES_DIR/claude/claude/hook_scripts/"*.sh 2>/dev/null || true
  fi
  echo ">>> $name done"
}

# ============ Menu ============
echo "=============================="
echo "  Dotfiles Installer"
echo "=============================="
echo ""
echo "Available:"
for i in "${!SOFTWARES[@]}"; do
  echo "  $((i+1)). ${SOFTWARES[$i]}"
done
echo "  a. Install all"
echo "  q. Quit"
echo ""
read -p "Choose (numbers/a/q, space-separated): " -a choices

for choice in "${choices[@]}"; do
  case "$choice" in
    q) exit 0 ;;
    a)
      for i in "${!SOFTWARES[@]}"; do
        install_software "${SOFTWARES[$i]}" "${FUNCTIONS[$i]}"
      done
      break
      ;;
    [0-9]*)
      idx=$((choice-1))
      if [ "$idx" -ge 0 ] && [ "$idx" -lt "${#SOFTWARES[@]}" ]; then
        install_software "${SOFTWARES[$idx]}" "${FUNCTIONS[$idx]}"
      else
        echo "Invalid: $choice"
      fi
      ;;
    *) echo "Invalid: $choice" ;;
  esac
done

echo ""
echo "Done."
