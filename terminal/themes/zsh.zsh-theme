# Oh My Zsh theme - converted from zsh.omp.json
# Tokyo Night color palette

# True color definitions
typeset -g _tn_red=$'\e[38;2;247;118;142m'
typeset -g _tn_green=$'\e[38;2;115;218;202m'
typeset -g _tn_blue=$'\e[38;2;122;162;247m'
typeset -g _tn_magenta=$'\e[38;2;187;154;247m'
typeset -g _tn_yellow=$'\e[38;2;224;175;104m'
typeset -g _tn_pistachio=$'\e[38;2;158;206;106m'
typeset -g _tn_gold=$'\e[38;2;221;177;95m'
typeset -g _tn_reset=$'\e[0m'

# Git prompt configuration
ZSH_THEME_GIT_PROMPT_PREFIX="%{${_tn_gold}%} git(%{${_tn_magenta}%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{${_tn_gold}%})%{${_tn_reset}%}"
ZSH_THEME_GIT_PROMPT_DIRTY=""
ZSH_THEME_GIT_PROMPT_CLEAN=""

PROMPT='%{${_tn_red}%}@%n%{${_tn_reset}%} %{${_tn_green}%}➜%{${_tn_reset}%}  %{${_tn_blue}%}%1~%{${_tn_reset}%}$(git_prompt_info)%(?.. %{${_tn_yellow}%}'$'\uf119''%{${_tn_reset}%})
%{${_tn_pistachio}%}❯%{${_tn_reset}%} '
