# Dotfiles

个人配置文件管理，通过符号链接部署到系统。

## 使用

```bash
git clone https://github.com/yuantianyu177/dotfiles.git
cd dotfiles
./install.sh
```

## 添加新配置

1. 在 `install.sh` 添加 `xxx_items()` 函数
2. 加入 `SOFTWARES` 和 `FUNCTIONS` 数组
3. 创建对应配置目录

## 目录结构

```
dotfiles/
├── claude/       # Claude Code 配置
├── nvim/         # Neovim 配置
├── oh-my-zsh/    # Oh-My-Zsh 配置
├── opencode/     # Opencode 配置
└── install.sh    # 安装脚本
```

---

# Dotfiles (English)

Personal dotfiles managed with symbolic links.

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
