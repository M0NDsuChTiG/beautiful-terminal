#!/bin/bash
set -euo pipefail

BASEDIR=$(dirname "$(readlink -f "$0")")
REQUIRE_SUDO=true

echo "🚀 Beautiful Terminal — установка"

# --- Определение пакетного менеджера ---
detect_pm() {
    if command -v apt &>/dev/null; then
        PM="apt"
        INSTALL_CMD="sudo apt update && sudo apt install -y"
        PACKAGES="zsh grc git curl whois jq mtr-tiny bind9-host grepcidr tealdeer lsd bat fzf btop fd-find zoxide kmon fastfetch duf micro procs lazygit"
    elif command -v pacman &>/dev/null; then
        PM="pacman"
        INSTALL_CMD="sudo pacman -S --noconfirm"
        PACKAGES="zsh grc git curl whois jq mtr bind grepcidr tealdeer lsd bat fzf btop fd zoxide kmon fastfetch duf micro procs lazygit"
    elif command -v dnf &>/dev/null; then
        PM="dnf"
        INSTALL_CMD="sudo dnf install -y"
        PACKAGES="zsh grc git curl whois jq mtr bind-utils grepcidr tealdeer lsd bat fzf btop fd-find zoxide kmon fastfetch duf micro procs lazygit"
    elif command -v zypper &>/dev/null; then
        PM="zypper"
        INSTALL_CMD="sudo zypper install -y"
        PACKAGES="zsh grc git curl whois jq mtr bind-utils grepcidr tealdeer lsd bat fzf btop fd zoxide kmon fastfetch duf micro procs lazygit"
    elif command -v brew &>/dev/null; then
        PM="brew"
        INSTALL_CMD="brew install"
        PACKAGES="zsh grc git curl whois jq mtr bind-utils grepcidr tealdeer lsd bat fzf btop fd zoxide kmon fastfetch duf micro procs lazygit"
        REQUIRE_SUDO=false
    else
        echo "❌ Не удалось определить пакетный менеджер (apt/pacman/dnf/zypper/brew)."
        echo "   Установите зависимости вручную и запустите скрипт снова."
        exit 1
    fi
    echo "   Обнаружен: $PM"
}

# --- Проверка sudo, если нужен ---
check_sudo() {
    if [ "$REQUIRE_SUDO" = true ]; then
        if ! sudo -n true 2>/dev/null; then
            echo "🔑 Требуется sudo. Введите пароль:"
            sudo -v
        fi
    fi
}

# --- Установка системных пакетов (идемпотентно) ---
install_packages() {
    echo "📦 Установка зависимостей..."
    if [ "$PM" = "apt" ]; then
        sudo apt update
        # Устанавливаем только недостающие пакеты
        local missing=()
        for pkg in $PACKAGES; do
            if ! dpkg -s "$pkg" &>/dev/null; then
                missing+=("$pkg")
            fi
        done
        if [ ${#missing[@]} -gt 0 ]; then
            sudo apt install -y "${missing[@]}"
        else
            echo "   Все пакеты уже установлены."
        fi
    elif [ "$PM" = "pacman" ]; then
        for pkg in $PACKAGES; do
            if ! pacman -Qi "$pkg" &>/dev/null 2>&1; then
                sudo pacman -S --noconfirm "$pkg"
            fi
        done
    else
        eval "$INSTALL_CMD $PACKAGES"
    fi
}

# --- Симлинки для bat/batcat и fd/fdfind (Debian) ---
ensure_symlinks() {
    if [ "$PM" = "apt" ]; then
        if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
            mkdir -p "$HOME/.local/bin"
            ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
            echo "   symlink: batcat → ~/.local/bin/bat"
        fi
        if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
            mkdir -p "$HOME/.local/bin"
            ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
            echo "   symlink: fdfind → ~/.local/bin/fd"
        fi
    fi
}

# --- Oh My Zsh (безопасная загрузка) ---
install_omz() {
    if [ -d "$HOME/.oh-my-zsh" ]; then
        echo "💾 Oh My Zsh уже установлен."
        return
    fi
    echo "💾 Установка Oh My Zsh..."
    local tmpfile
    tmpfile=$(mktemp)
    if curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -o "$tmpfile"; then
        sh "$tmpfile" "" --unattended
        rm -f "$tmpfile"
    else
        echo "⚠️  Не удалось загрузить install.sh Oh My Zsh. Пропускаем."
    fi
}

# --- Плагины из бандла ---
copy_plugins() {
    local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    echo "🔌 Копирование плагинов..."
    mkdir -p "$zsh_custom/plugins"
    for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
        if [ -d "$BASEDIR/plugins/$plugin" ] && [ ! -d "$zsh_custom/plugins/$plugin" ]; then
            cp -r "$BASEDIR/plugins/$plugin" "$zsh_custom/plugins/"
        fi
    done
}

# --- ASN-утилита ---
install_asn() {
    if [ -f /usr/local/bin/asn ]; then
        echo "🛡️  ASN уже установлен."
        return
    fi
    echo "🛡️  Установка утилиты ASN..."
    sudo cp "$BASEDIR/bin/asn" /usr/local/bin/asn
    sudo chmod +x /usr/local/bin/asn
}

# --- .zshrc ---
apply_zshrc() {
    echo "⚙️  Применение .zshrc..."
    if [ -f "$BASEDIR/zshrc_template" ]; then
        cp "$BASEDIR/zshrc_template" "$HOME/.zshrc"
    else
        echo "⚠️  zshrc_template не найден. Пропускаем."
    fi
}

# --- Смена шелла ---
switch_shell() {
    local zsh_path
    zsh_path=$(command -v zsh || true)
    if [ -z "$zsh_path" ]; then
        echo "⚠️  Zsh не установлен. Пропускаем смену оболочки."
        return
    fi
    if [ "$SHELL" != "$zsh_path" ]; then
        echo "🔄 Смена оболочки на Zsh..."
        if ! grep -q "$zsh_path" /etc/shells; then
            echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
        fi
        sudo chsh -s "$zsh_path" "$USER"
    fi
}

# --- tldr cache ---
update_tldr() {
    if command -v tldr &>/dev/null; then
        echo "📚 Обновление кэша tldr..."
        tldr --update 2>/dev/null || true
    fi
}

# --- Главная ---
main() {
    detect_pm
    check_sudo
    install_packages
    ensure_symlinks
    install_omz
    copy_plugins
    install_asn
    apply_zshrc
    switch_shell
    update_tldr

    echo ""
    echo "✅ ГОТОВО! Всё установлено."
    echo "🔄 Перезапустите терминал или выполните: zsh"
}

main
