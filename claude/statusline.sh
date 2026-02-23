#!/usr/bin/env bash
set -euo pipefail

data=$(cat)

get() { echo "$data" | jq -r "$1 // empty"; }

model=$(get '.model.display_name')
ctx=$(get '.context_window.used_percentage')
project_dir=$(get '.workspace.project_dir')
cwd=$(get '.workspace.current_dir')
agent=$(get '.agent.name')

# Tokyo Night palette
orange='\033[38;2;255;158;100m'
red='\033[38;2;247;118;142m'
green='\033[38;2;115;218;202m'
blue='\033[38;2;122;162;247m'
magenta='\033[38;2;187;154;247m'
pistachio='\033[38;2;158;206;106m'
gold='\033[38;2;221;177;95m'
dim='\033[38;2;100;110;140m'
reset='\033[0m'

out=""

# Model
if [[ -n "$model" ]]; then
  out+="${orange}${model}${reset}"
fi

# Context usage
if [[ -n "$ctx" ]]; then
  ctx_int=${ctx%.*}
  out+=" ${dim}│${reset} ${red}ctx ${ctx_int}%${reset}"
fi

# Project / directory
dirname=""
if [[ -n "$project_dir" ]]; then
  dirname=$(basename "$project_dir")
elif [[ -n "$cwd" ]]; then
  dirname=$(basename "$cwd")
fi
if [[ -n "$dirname" ]]; then
  out+=" ${green}➜${reset}  ${blue}${dirname}${reset}"
fi

# Git branch
if [[ -n "$project_dir" ]] && command -v git &>/dev/null; then
  branch=$(git -C "$project_dir" rev-parse --abbrev-ref HEAD 2>/dev/null || true)
  if [[ -n "$branch" ]]; then
    out+=" ${gold}git(${magenta}${branch}${gold})${reset}"
  fi
fi

# Agent name
if [[ -n "$agent" ]]; then
  out+=" ${dim}│${reset} ${pistachio}➜ ${agent}${reset}"
fi

echo -e "$out"
