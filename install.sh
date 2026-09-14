#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${HOME:-/root}"

echo "🚀 Beautiful Terminal — установка"

# 1. Менеджер пакетов
PKG_MANAGER=""
if command -v apt-get &>/dev/null; then
    PKG_MANAGER="apt"
elif command -v pacman &>/dev/null; then
    PKG_MANAGER="pacman"
elif command -v dnf &>/dev/null; then
    PKG_MANAGER="dnf"
fi
echo "   Обнаружен: ${PKG_MANAGER:-нет}"

# 2. Установка базовых пакетов apt
echo "📦 Установка базовых зависимостей..."
if [ "$PKG_MANAGER" = "apt" ]; then
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -y
    apt-get install -y curl wget git zsh tar unzip fzf jq bat btop duf fd-find micro whois xclip zoxide grc grepcidr ca-certificates || true
    
    mkdir -p "$HOME_DIR/.local/bin"
    if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
        ln -sf "$(which batcat)" /usr/local/bin/bat 2>/dev/null || ln -sf "$(which batcat)" "$HOME_DIR/.local/bin/bat"
        echo "   symlink: batcat → bat"
    fi
    if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
        ln -sf "$(which fdfind)" /usr/local/bin/fd 2>/dev/null || ln -sf "$(which fdfind)" "$HOME_DIR/.local/bin/fd"
        echo "   symlink: fdfind → fd"
    fi
fi

# 3. Универсальный установщик бинарников с GitHub Releases
install_from_github() {
    local cmd_name="$1"
    local github_repo="$2"
    local file_pattern="$3"

    if command -v "$cmd_name" &>/dev/null; then
        return 0
    fi

    echo "⬇️  Установка $cmd_name из GitHub ($github_repo)..."
    local tmp_dir
    tmp_dir=$(mktemp -d)

    local dl_url
    dl_url=$(curl -s "https://api.github.com/repos/${github_repo}/releases/latest" | \
        grep -i "browser_download_url" | grep -E "${file_pattern}" | cut -d '"' -f 4 | head -n 1)

    if [ -z "$dl_url" ]; then
        echo "   ⚠️ Не найден релиз для $cmd_name"
        rm -rf "$tmp_dir"
        return 1
    fi

    local archive_file="${tmp_dir}/pkg"
    curl -sL "$dl_url" -o "$archive_file"

    if [[ "$dl_url" == *.deb ]]; then
        dpkg -i "$archive_file" &>/dev/null || apt-get install -f -y &>/dev/null
    elif [[ "$dl_url" == *.tar.gz || "$dl_url" == *.tgz ]]; then
        tar -xzf "$archive_file" -C "$tmp_dir"
        find "$tmp_dir" -type f -name "$cmd_name" -exec mv {} /usr/local/bin/ \;
    elif [[ "$dl_url" == *.zip ]]; then
        unzip -q "$archive_file" -d "$tmp_dir"
        find "$tmp_dir" -type f -name "$cmd_name" -exec mv {} /usr/local/bin/ \;
    else
        chmod +x "$archive_file"
        mv "$archive_file" "/usr/local/bin/${cmd_name}"
    fi

    chmod +x "/usr/local/bin/${cmd_name}" 2>/dev/null || true
    rm -rf "$tmp_dir"
    echo "   ✅ $cmd_name установлен!"
}

# 4. Установка недостающих утилит
echo "⚡ Установка современных CLI-утилит..."

# Fastfetch
if ! command -v fastfetch &>/dev/null; then
    install_from_github "fastfetch" "fastfetch-cli/fastfetch" "linux-amd64.deb" || true
fi

# LSD
if ! command -v lsd &>/dev/null; then
    install_from_github "lsd" "lsd-rs/lsd" "x86_64-unknown-linux-musl.tar.gz" || true
fi

# Lazygit
if ! command -v lazygit &>/dev/null; then
    install_from_github "lazygit" "jesseduffield/lazygit" "Linux_x86_64.tar.gz" || true
fi

# Tealdeer (tldr)
if ! command -v tldr &>/dev/null; then
    install_from_github "tldr" "dbrgn/tealdeer" "tealdeer-linux-x86_64-musl" || true
fi

# Procs
if ! command -v procs &>/dev/null; then
    install_from_github "procs" "dalance/procs" "x86_64-linux.zip" || true
fi

# Kmon
if ! command -v kmon &>/dev/null; then
    install_from_github "kmon" "orhun/kmon" "x86_64-unknown-linux-gnu.tar.gz" || true
fi

# 5. Oh My Zsh
if [ ! -d "$HOME_DIR/.oh-my-zsh" ]; then
    echo "💾 Установка Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "💾 Oh My Zsh уже установлен."
fi

# Плагины
if [ -d "$SCRIPT_DIR/plugins" ]; then
    echo "🔌 Копирование плагинов..."
    mkdir -p "$HOME_DIR/.oh-my-zsh/custom/plugins"
    cp -r "$SCRIPT_DIR"/plugins/* "$HOME_DIR/.oh-my-zsh/custom/plugins/" 2>/dev/null || true
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME_DIR/.oh-my-zsh/custom}"
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions" 2>/dev/null || true
fi
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" 2>/dev/null || true
fi

# 6. ASN
if [ -f "$SCRIPT_DIR/bin/asn" ]; then
    echo "🛡️  Установка утилиты ASN..."
    cp "$SCRIPT_DIR/bin/asn" /usr/local/bin/asn
    chmod +x /usr/local/bin/asn
fi

# 7. Применение .zshrc
if [ -f "$SCRIPT_DIR/zshrc_template" ]; then
    echo "⚙️  Применение .zshrc..."
    if [ -f "$HOME_DIR/.zshrc" ]; then
        cp "$HOME_DIR/.zshrc" "$HOME_DIR/.zshrc.bak.$(date +%Y%m%d-%H%M%S)"
    fi
    cp "$SCRIPT_DIR/zshrc_template" "$HOME_DIR/.zshrc"
fi

# 8. Смена оболочки
echo "🔄 Смена оболочки на Zsh..."
if [ "$SHELL" != "$(which zsh)" ]; then
    chsh -s "$(which zsh)" 2>/dev/null || true
fi

echo ""
echo "✅ ГОТОВО! Всё установлено без ошибок."
echo ""

if [ -n "$ZSH_VERSION" ]; then
    source "$HOME_DIR/.zshrc"
else
    exec zsh -l
fi
