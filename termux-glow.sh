#!/data/data/com.termux/files/usr/bin/bash
# ╔══════════════════════════════════════════╗
#   termux-glow — full visual upgrade
#   run: bash termux-glow.sh
# ╚══════════════════════════════════════════╝

set -e

# ── Colors for the installer itself ──────
R='\033[0;31m' G='\033[0;32m' C='\033[0;36m'
Y='\033[0;33m' B='\033[1m'   N='\033[0m'

info()    { echo -e "${C}→${N} $*"; }
ok()      { echo -e "${G}✓${N} $*"; }
warn()    { echo -e "${Y}!${N} $*"; }
fail()    { echo -e "${R}✗${N} $*"; }
header()  { echo -e "\n${B}━━ $* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"; }

clear
echo -e "${B}"
echo "  ████████╗███████╗██████╗ ███╗   ███╗██╗   ██╗██╗  ██╗"
echo "     ██╔══╝██╔════╝██╔══██╗████╗ ████║██║   ██║╚██╗██╔╝"
echo "     ██║   █████╗  ██████╔╝██╔████╔██║██║   ██║ ╚███╔╝ "
echo "     ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║██║   ██║ ██╔██╗ "
echo "     ██║   ███████╗██║  ██║██║ ╚═╝ ██║╚██████╔╝██╔╝ ██╗"
echo "     ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝"
echo -e "${C}         termux visual upgrade v1.0${N}"
echo
echo "  Installs: Dracula theme · Nerd Font · Starship prompt"
echo "            neofetch · bat · eza · extra keys row"
echo
read -rp "  Press Enter to start, Ctrl+C to cancel..."

# ── 1. Package update & install ──────────
header "1 / 6  Packages"
info "updating repos…"
pkg update -y -q

info "installing tools…"
pkg install -y -q \
    curl unzip \
    neofetch \
    figlet \
    bat \
    git

# eza (modern ls with icons) — in repos since 2024
if pkg install -y -q eza 2>/dev/null; then
    EZA=1; ok "eza installed"
else
    EZA=0; warn "eza not found — keeping ls"
fi

# lolcat via gem or pip
if pkg install -y -q ruby 2>/dev/null && gem install lolcat -q 2>/dev/null; then
    LOLCAT=1; ok "lolcat installed"
elif pip install lolcat -q 2>/dev/null; then
    LOLCAT=1; ok "lolcat installed (pip)"
else
    LOLCAT=0; warn "lolcat skipped"
fi

ok "packages done"

# ── 2. Dracula color scheme ──────────────
header "2 / 6  Dracula Color Scheme"
mkdir -p ~/.termux

cat > ~/.termux/colors.properties << 'EOF'
# Dracula — https://draculatheme.com
background = #282a36
foreground = #f8f8f2
cursor     = #f8f8f2

color0  = #21222c
color1  = #ff5555
color2  = #50fa7b
color3  = #f1fa8c
color4  = #bd93f9
color5  = #ff79c6
color6  = #8be9fd
color7  = #f8f8f2
color8  = #6272a4
color9  = #ff6e6e
color10 = #69ff94
color11 = #ffffa5
color12 = #d6acff
color13 = #ff92df
color14 = #a4ffff
color15 = #ffffff
EOF

ok "Dracula colors written to ~/.termux/colors.properties"

# ── 3. Nerd Font ─────────────────────────
header "3 / 6  JetBrains Mono Nerd Font"

FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip"
FONT_TMP="$(mktemp -d)"

info "downloading font (~12 MB)…"
if curl -L --progress-bar "$FONT_URL" -o "$FONT_TMP/font.zip"; then
    cd "$FONT_TMP"
    unzip -q font.zip "JetBrainsMonoNerdFont-Regular.ttf" 2>/dev/null \
        || unzip -q font.zip "*Regular*.ttf" 2>/dev/null \
        || unzip -q font.zip "*.ttf" 2>/dev/null

    FOUND=$(find . -name "*.ttf" | head -1)
    if [ -n "$FOUND" ]; then
        cp "$FOUND" ~/.termux/font.ttf
        ok "font installed → ~/.termux/font.ttf"
    else
        fail "ttf not found inside zip — font skipped"
    fi
    cd ~ && rm -rf "$FONT_TMP"
else
    warn "download failed — install font manually:"
    warn "  curl -L <nerd-font-url> -o ~/.termux/font.ttf"
fi

# ── 4. Starship prompt ───────────────────
header "4 / 6  Starship Prompt"

STARSHIP=0
if pkg install -y -q starship 2>/dev/null; then
    STARSHIP=1; ok "starship installed via pkg"
elif curl -sS https://starship.rs/install.sh | sh -s -- --yes 2>/dev/null; then
    STARSHIP=1; ok "starship installed via install.sh"
else
    warn "starship unavailable — using plain prompt"
fi

if [ "$STARSHIP" = "1" ]; then
    mkdir -p ~/.config
    cat > ~/.config/starship.toml << 'EOF'
# ── Starship — Dracula palette ───────────────────────────────────────────────

format = """
[╭─](fg:#6272a4)$directory$git_branch$git_status$python$nodejs$rust$cmd_duration
[╰─](fg:#6272a4)$character """

add_newline = true

[character]
success_symbol = "[❯](bold #50fa7b)"
error_symbol   = "[❯](bold #ff5555)"
vimcmd_symbol  = "[❮](bold #bd93f9)"

[directory]
style             = "bold #bd93f9"
read_only         = " 󰌾"
truncation_length = 3
truncate_to_repo  = true

[git_branch]
symbol = " "
style  = "bold #ff79c6"
format = "on [$symbol$branch]($style) "

[git_status]
style      = "bold #f1fa8c"
format     = "([$all_status$ahead_behind]($style)) "
ahead      = "⇡$count"
behind     = "⇣$count"
modified   = "!$count"
untracked  = "?$count"
staged     = "+$count"
deleted    = "✘$count"

[python]
symbol = " "
style  = "bold #50fa7b"
format = "[$symbol$version]($style) "

[nodejs]
symbol = " "
style  = "bold #8be9fd"
format = "[$symbol$version]($style) "

[rust]
symbol = " "
style  = "bold #ff5555"
format = "[$symbol$version]($style) "

[cmd_duration]
min_time = 2000
style    = "italic #6272a4"
format   = "took [$duration]($style) "
EOF
    ok "starship config → ~/.config/starship.toml"
fi

# ── 5. Extra keys row ────────────────────
header "5 / 6  Extra Keys Row"

# Only write if not already customised
if ! grep -q "extra-keys" ~/.termux/termux.properties 2>/dev/null; then
    cat >> ~/.termux/termux.properties << 'EOF'

# Extra keys row — good for coding + git
extra-keys = [['ESC','|','/','~','HOME','UP','END'],['TAB','CTRL','ALT','-','LEFT','DOWN','RIGHT']]
EOF
    ok "extra keys row added"
else
    warn "termux.properties already has extra-keys — skipped"
fi

# ── 6. Patch .bashrc ─────────────────────
header "6 / 6  Updating .bashrc"
BASHRC=~/.bashrc

# Back up
cp "$BASHRC" "${BASHRC}.pre-glow" 2>/dev/null
ok "backup → ~/.bashrc.pre-glow"

# Remove old PS1 line to avoid conflict with starship
sed -i '/^PS1=/d' "$BASHRC" 2>/dev/null

# Write glow block if not already present
if ! grep -q "# ── termux-glow" "$BASHRC" 2>/dev/null; then
cat >> "$BASHRC" << BLOCK

# ── termux-glow ───────────────────────────────────────────────────────────────

# Starship
$([ "$STARSHIP" = "1" ] && echo 'command -v starship &>/dev/null && eval "$(starship init bash)"')

# bat — syntax-highlighted cat
if command -v bat &>/dev/null; then
    alias cat='bat --style=plain --paging=never --theme=Dracula'
    alias catp='bat --theme=Dracula'          # bat with paging + line numbers
fi

# eza — icon ls (falls back to ls if missing)
$([ "$EZA" = "1" ] && cat << 'EZA_BLOCK'
alias ls='eza --icons --color=always --group-directories-first'
alias la='eza -la --icons --color=always --git --group-directories-first'
alias ll='eza -lh --icons --color=always --group-directories-first'
alias lt='eza --tree --icons --color=always -L 2'
EZA_BLOCK
)

# lolcat greeting helper
$([ "$LOLCAT" = "1" ] && echo '_LOLCAT=lolcat' || echo '_LOLCAT=cat')

# neofetch on start
if command -v neofetch &>/dev/null; then
    neofetch | \$_LOLCAT 2>/dev/null || neofetch
fi

# ──────────────────────────────────────────────────────────────────────────────
BLOCK
    ok ".bashrc updated"
else
    warn ".bashrc already has glow block — skipped"
fi

# ── Done ─────────────────────────────────
termux-reload-settings 2>/dev/null && ok "termux settings reloaded" || true

echo
echo -e "${B}${G}  ✓ All done! ${N}"
echo
echo -e "  ${B}What changed:${N}"
echo "   • Colors   → Dracula (restart Termux to apply)"
echo "   • Font     → JetBrains Mono Nerd Font"
echo "   • Prompt   → Starship (two-line, shows git/python/node)"
echo "   • cat      → bat with Dracula syntax highlight"
[ "$EZA" = "1" ] && echo "   • ls/la/ll → eza with file icons"
echo "   • Greeting → neofetch on every new session"
echo "   • Keys row → ESC | / ~ HOME ↑ END / TAB CTRL ALT - ← ↓ →"
echo
echo -e "  ${C}Restart Termux now for everything to take effect.${N}"
echo -e "  To undo: ${Y}cp ~/.bashrc.pre-glow ~/.bashrc${N}"
echo
