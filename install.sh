#!/bin/bash

# Путь к текущей папке скрипта
BASEDIR=$(dirname "$(readlink -f "$0")")

echo "🚀 Начинаем локальную установку красивого терминала..."

# 1. Установка системных зависимостей
echo "📦 Установка зависимостей (нужен sudo)..."
sudo apt update
sudo apt install -y zsh grc git curl whois jq mtr-tiny bind9-host grepcidr

# 2. Установка Oh My Zsh (если еще нет)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "💾 Устанавливаем Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# 3. Копирование плагинов из папки проекта
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
echo "🔌 Копируем плагины..."
mkdir -p "$ZSH_CUSTOM/plugins"
cp -r "$BASEDIR/plugins/zsh-autosuggestions" "$ZSH_CUSTOM/plugins/"
cp -r "$BASEDIR/plugins/zsh-syntax-highlighting" "$ZSH_CUSTOM/plugins/"

# 4. Установка скрипта ASN
echo "🛡️ Установка утилиты ASN..."
sudo cp "$BASEDIR/bin/asn" /usr/local/bin/asn
sudo chmod +x /usr/local/bin/asn

# 5. Настройка .zshrc
echo "⚙️ Применяем конфигурацию .zshrc..."
cp "$BASEDIR/zshrc_template" ~/.zshrc

# 6. Смена оболочки
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "🔄 Меняем оболочку на Zsh..."
    sudo chsh -s $(which zsh) $USER
fi

echo "✅ ГОТОВО! Всё установлено из локальных файлов проекта."
echo "🔄 Пожалуйста, перезапустите терминал или введите 'zsh'."
