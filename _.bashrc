bind 'set enable-bracketed-paste off' 2>/dev/null

GREEN='\[\e[32m\]'
CYAN='\[\e[36m\]'
YELLOW='\[\e[33m\]'
RESET='\[\e[0m\]'
PS1="${GREEN}\u${RESET}@${CYAN}\h${RESET}:${YELLOW}\w${RESET}\$ "

alias r='source ~/.bashrc && echo "reloaded"'

alias upd='pkg update'
alias upg='pkg upgrade'
alias ins='pkg install'
alias rem='pkg uninstall'
alias srch='pkg search'
alias pkgs='pkg list-installed'

t() { termux-setup-storage && echo "storage ready"; }

alias home='cd ~'
alias dl='cd ~/storage/shared/Download'
alias dc='cd ~/storage/shared/DCIM'
alias sh='cd ~/storage/shared'
alias p='cd ~/storage/shared/python'
alias docs='cd ~/storage/shared/Documents'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias cls='clear'
alias ls='ls --color=auto'
alias la='ls -la --color=auto'
alias ll='ls -lh --color=auto'
alias lt='ls -lhtr --color=auto'
alias lz='ls -lhSr --color=auto'

alias gs='git status'
alias ga='git add .'
alias gaa='git add --all'
alias gc='git commit -m'
alias gp='git push'
alias gl='git log --oneline --graph --decorate -15'
alias gd='git diff'
alias gb='git branch'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gpull='git pull'
alias gst='git stash'
alias gstp='git stash pop'

alias py='python'
alias py3='python3'
alias js='node'
alias rb='ruby'
alias lua='lua5.4'

alias myip='curl -s https://api.ipify.org && echo'
alias ports='ss -tulnp'
alias ping='ping -c 4'

alias df='df -h'
alias du='du -sh'
alias free='free -h'
alias top='htop 2>/dev/null || top'
alias ps='ps aux'

alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

mkf() {
    if [ -z "$1" ]; then echo "usage: mkf <dirname>"; return 1; fi
    mkdir -p "$1" && cd "$1" && echo "→ $(pwd)"
}

run() {
    if [ -z "$1" ]; then echo "usage: run <file>"; return 1; fi
    if [ ! -f "$1" ]; then echo "file not found: $1"; return 1; fi
    case "$1" in
        *.py)   python "$1" ;;
        *.js)   node "$1" ;;
        *.rb)   ruby "$1" ;;
        *.sh)   bash "$1" ;;
        *.lua)  lua "$1" ;;
        *.php)  php "$1" ;;
        *.pl)   perl "$1" ;;
        *)      echo "no runner for: ${1##*.}" ;;
    esac
}

extract() {
    if [ ! -f "$1" ]; then echo "file not found: $1"; return 1; fi
    case "$1" in
        *.tar.gz|*.tgz)  tar xzf "$1" ;;
        *.tar.bz2|*.tbz) tar xjf "$1" ;;
        *.tar.xz)        tar xJf "$1" ;;
        *.tar)           tar xf "$1" ;;
        *.zip)           unzip "$1" ;;
        *.gz)            gunzip "$1" ;;
        *.bz2)           bunzip2 "$1" ;;
        *.7z)            7z x "$1" ;;
        *)               echo "unknown format: $1" ;;
    esac
}

note() {
    local NOTE_FILE=~/notes.txt
    if [ -z "$1" ]; then
        cat "$NOTE_FILE" 2>/dev/null || echo "(no notes yet)"
    else
        echo "[$(date '+%Y-%m-%d %H:%M')] $*" >> "$NOTE_FILE"
        echo "saved."
    fi
}

showpath() { echo "$PATH" | tr ':' '\n'; }

# Download shortcut (uses curl or wget, whichever is available)
get() {
    if [ -z "$1" ]; then echo "usage: get <url>"; return 1; fi
    if command -v curl &>/dev/null; then
        curl -LO "$1"
    elif command -v wget &>/dev/null; then
        wget "$1"
    else
        echo "install curl or wget first"
    fi
}

server() {
    local port="${1:-8080}"
    echo "serving $(pwd) on :$port"
    python -m http.server "$port"
}

echo "Termux ready  —  $(date '+%a %b %d %H:%M')"
