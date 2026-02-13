# Dotfiles

[English](README_EN.md)

个人配置文件。

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
