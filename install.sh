#!/usr/bin/env bash
# Beautiful Terminal — устойчивый установщик
# Поддержка: apt (Debian/Ubuntu/Kali/Parrot), pacman (Arch/Manjaro),
#            dnf (Fedora/RHEL), zypper (openSUSE), brew (macOS)
# Идемпотентный: уже установленное не ломает, отсутствующее в репо — пропуск.

set -u
# Не используем set -e глобально: ошибки пакетов не должны рвать весь скрипт

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${HOME:-/root}"
OS_TYPE="$(uname -s)"
ARCH="$(uname -m)"
PM=""
REQUIRE_SUDO=true
FAILED_PKGS=()
SKIPPED_PKGS=()
INSTALLED_OK=()

# ---------------------------------------------------------------------------
# Утилиты
# ---------------------------------------------------------------------------

log()  { printf '%s\n' "$*"; }
ok()   { printf '   ✅ %s\n' "$*"; }
warn() { printf '   ⚠️  %s\n' "$*"; }
err()  { printf '   ❌ %s\n' "$*"; }

run_root() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  else
    sudo "$@"
  fi
}

have() { command -v "$1" &>/dev/null; }

ensure_local_bin() {
  mkdir -p "$HOME_DIR/.local/bin"
  case ":$PATH:" in
    *":$HOME_DIR/.local/bin:"*) ;;
    *) export PATH="$HOME_DIR/.local/bin:$PATH" ;;
  esac
}

# Куда класть бинарники без root-предпочтения
bin_target_dir() {
  if [ -w /usr/local/bin ] 2>/dev/null || [ "$(id -u)" -eq 0 ]; then
    echo /usr/local/bin
  else
    ensure_local_bin
    echo "$HOME_DIR/.local/bin"
  fi
}

install_bin() {
  # install_bin <src> <name>
  local src="$1" name="$2" dest
  dest="$(bin_target_dir)/$name"
  if [ -w "$(dirname "$dest")" ]; then
    cp "$src" "$dest"
    chmod +x "$dest"
  else
    run_root cp "$src" "$dest"
    run_root chmod +x "$dest"
  fi
}

# ---------------------------------------------------------------------------
# Архитектура для GitHub Releases
# ---------------------------------------------------------------------------

github_arch() {
  case "$ARCH" in
    x86_64|amd64)  echo "x86_64" ;;
    aarch64|arm64) echo "aarch64" ;;
    armv7l)        echo "armv7" ;;
    *)             echo "unknown" ;;
  esac
}

github_arch_alt() {
  # альтернативные имена в релизах
  case "$ARCH" in
    x86_64|amd64)  echo "amd64" ;;
    aarch64|arm64) echo "arm64" ;;
    *)             echo "unknown" ;;
  esac
}

# ---------------------------------------------------------------------------
# Определение пакетного менеджера
# ---------------------------------------------------------------------------

detect_pm() {
  if have apt-get || have apt; then
    PM="apt"
  elif have pacman; then
    PM="pacman"
  elif have dnf; then
    PM="dnf"
  elif have zypper; then
    PM="zypper"
  elif have brew; then
    PM="brew"
    REQUIRE_SUDO=false
  else
    err "Не найден пакетный менеджер (apt/pacman/dnf/zypper/brew)"
    log "Установите git, curl, zsh вручную и перезапустите."
    exit 1
  fi
  log "   Обнаружен: $PM  |  OS: $OS_TYPE  |  Arch: $ARCH"
}

check_sudo() {
  if [ "$REQUIRE_SUDO" = true ] && [ "$(id -u)" -ne 0 ]; then
    if ! sudo -n true 2>/dev/null; then
      log "🔑 Нужен sudo. Введите пароль:"
      sudo -v || { err "sudo недоступен"; exit 1; }
    fi
    # держим sudo живым
    (while true; do sudo -n true; sleep 50; done) &>/dev/null &
    SUDO_KEEPALIVE_PID=$!
    trap 'kill $SUDO_KEEPALIVE_PID 2>/dev/null || true' EXIT
  fi
}

# ---------------------------------------------------------------------------
# Списки пакетов по PM (только то, что реально есть в репозиториях)
# ---------------------------------------------------------------------------

packages_for_pm() {
  case "$PM" in
    apt)
      # Debian/Ubuntu/Kali/Parrot — имена как в репозиториях
      echo "zsh git curl wget tar unzip ca-certificates jq whois xclip grc"
      echo "fzf bat btop duf micro zoxide fd-find"
      # опциональные / могут отсутствовать на старых релизах
      echo "tealdeer lsd fastfetch lazygit procs kmon grepcidr mtr-tiny bind9-host"
      ;;
    pacman)
      echo "zsh git curl wget tar unzip ca-certificates jq whois xclip grc"
      echo "fzf bat btop duf micro zoxide fd"
      echo "tealdeer lsd fastfetch lazygit procs kmon grepcidr mtr bind"
      ;;
    dnf)
      echo "zsh git curl wget tar unzip ca-certificates jq whois xclip grc"
      echo "fzf bat btop duf micro zoxide fd-find"
      echo "tealdeer lsd fastfetch lazygit procs kmon mtr bind-utils"
      ;;
    zypper)
      echo "zsh git curl wget tar unzip ca-certificates jq whois xclip grc"
      echo "fzf bat btop duf micro zoxide fd"
      echo "tealdeer lsd fastfetch lazygit procs kmon mtr bind-utils"
      ;;
    brew)
      # kmon — только Linux, не ставим
      echo "zsh git curl wget jq whois grc"
      echo "fzf bat btop duf micro zoxide fd"
      echo "tealdeer lsd fastfetch lazygit procs mtr"
      ;;
  esac
}

package_available() {
  local pkg="$1"
  case "$PM" in
    apt)    apt-cache show "$pkg" &>/dev/null ;;
    pacman) pacman -Si "$pkg" &>/dev/null ;;
    dnf)    dnf list --available "$pkg" &>/dev/null 2>&1 || dnf info "$pkg" &>/dev/null 2>&1 ;;
    zypper) zypper se -x -t package "$pkg" 2>/dev/null | grep -q "$pkg" ;;
    brew)   brew info "$pkg" &>/dev/null ;;
    *)      return 1 ;;
  esac
}

package_installed() {
  local pkg="$1"
  case "$PM" in
    apt)    dpkg -s "$pkg" &>/dev/null ;;
    pacman) pacman -Qi "$pkg" &>/dev/null ;;
    dnf)    rpm -q "$pkg" &>/dev/null ;;
    zypper) rpm -q "$pkg" &>/dev/null ;;
    brew)   brew list "$pkg" &>/dev/null ;;
    *)      return 1 ;;
  esac
}

install_one_pkg() {
  local pkg="$1"
  case "$PM" in
    apt)    run_root apt-get install -y -qq "$pkg" ;;
    pacman) run_root pacman -S --noconfirm --needed "$pkg" ;;
    dnf)    run_root dnf install -y -q "$pkg" ;;
    zypper) run_root zypper install -y -n "$pkg" ;;
    brew)   brew install "$pkg" ;;
  esac
}

install_packages() {
  log "📦 Установка системных пакетов..."

  if [ "$PM" = "apt" ]; then
    export DEBIAN_FRONTEND=noninteractive
    run_root apt-get update -y -qq || warn "apt update не удался (продолжаем)"
  elif [ "$PM" = "pacman" ]; then
    # На свежем Arch sync-БД пустая, без неё pacman -Si/-S не находят пакеты
    run_root pacman -Sy --noconfirm || warn "pacman -Sy не удался (продолжаем)"
  fi

  local pkg
  for pkg in $(packages_for_pm | tr '\n' ' '); do
    [ -z "$pkg" ] && continue
    if package_installed "$pkg"; then
      ok "$pkg (уже есть)"
      INSTALLED_OK+=("$pkg")
      continue
    fi
    if ! package_available "$pkg"; then
      warn "нет в репозитории: $pkg — пропуск"
      SKIPPED_PKGS+=("$pkg")
      continue
    fi
    if install_one_pkg "$pkg"; then
      ok "$pkg"
      INSTALLED_OK+=("$pkg")
    else
      warn "не удалось установить: $pkg"
      FAILED_PKGS+=("$pkg")
    fi
  done
}

# ---------------------------------------------------------------------------
# Симлинки Debian: batcat→bat, fdfind→fd
# ---------------------------------------------------------------------------

ensure_symlinks() {
  ensure_local_bin
  if have batcat && ! have bat; then
    ln -sf "$(command -v batcat)" "$HOME_DIR/.local/bin/bat"
    ok "symlink batcat → ~/.local/bin/bat"
  fi
  if have fdfind && ! have fd; then
    ln -sf "$(command -v fdfind)" "$HOME_DIR/.local/bin/fd"
    ok "symlink fdfind → ~/.local/bin/fd"
  fi
  # на некоторых системах bat ставится как batcat только
  if have bat && ! have batcat; then
    true
  fi
}

# ---------------------------------------------------------------------------
# GitHub Releases fallback
# ---------------------------------------------------------------------------

install_from_github() {
  local cmd_name="$1"
  local github_repo="$2"
  shift 2
  local patterns=("$@")

  if have "$cmd_name"; then
    return 0
  fi

  log "⬇️  $cmd_name из GitHub ($github_repo)..."

  if ! have curl; then
    warn "curl нет — пропуск $cmd_name"
    return 1
  fi

  local api_json tmp_dir dl_url archive_file
  api_json="$(curl -fsSL --max-time 30 "https://api.github.com/repos/${github_repo}/releases/latest" 2>/dev/null)" || {
    warn "GitHub API недоступен для $cmd_name"
    return 1
  }

  dl_url=""
  local p
  for p in "${patterns[@]}"; do
    # отбрасываем файлы контрольных сумм и подписей: иначе для kmon/tealdeer/lazygit
    # первым может совпасть .sha256/.sha512/.sig/checksums.txt вместо бинарника
    dl_url="$(printf '%s' "$api_json" \
      | grep -oE "https://[^\"]+/download/[^\"]+" \
      | grep -viE '\.(sha256|sha512|sig|asc|sum)$|checksums\.txt' \
      | grep -iE "$p" | head -n1)" || true
    [ -n "$dl_url" ] && break
  done

  if [ -z "$dl_url" ]; then
    warn "релиз не найден для $cmd_name (patterns: ${patterns[*]})"
    return 1
  fi

  tmp_dir="$(mktemp -d)"
  archive_file="$tmp_dir/pkg"
  if ! curl -fsSL --max-time 120 "$dl_url" -o "$archive_file"; then
    warn "скачивание не удалось: $cmd_name"
    rm -rf "$tmp_dir"
    return 1
  fi

  local extracted=""
  case "$dl_url" in
    *.deb)
      if [ "$PM" = "apt" ]; then
        run_root dpkg -i "$archive_file" &>/dev/null || run_root apt-get install -f -y -qq &>/dev/null || true
        extracted="deb"
      fi
      ;;
    *.rpm)
      if [ "$PM" = "dnf" ] || [ "$PM" = "zypper" ]; then
        run_root rpm -Uvh "$archive_file" &>/dev/null || true
        extracted="rpm"
      fi
      ;;
    *.tar.gz|*.tgz)
      tar -xzf "$archive_file" -C "$tmp_dir" 2>/dev/null || true
      extracted="$(find "$tmp_dir" -type f -name "$cmd_name" 2>/dev/null | head -n1)"
      ;;
    *.zip)
      if have unzip; then
        unzip -q "$archive_file" -d "$tmp_dir" 2>/dev/null || true
      fi
      extracted="$(find "$tmp_dir" -type f -name "$cmd_name" 2>/dev/null | head -n1)"
      ;;
    *)
      # сырой бинарник
      chmod +x "$archive_file"
      extracted="$archive_file"
      ;;
  esac

  if [ -n "$extracted" ] && [ "$extracted" != "deb" ] && [ "$extracted" != "rpm" ] && [ -f "$extracted" ]; then
    install_bin "$extracted" "$cmd_name"
  fi

  rm -rf "$tmp_dir"

  if have "$cmd_name"; then
    ok "$cmd_name установлен"
    return 0
  fi
  warn "$cmd_name не удалось установить из GitHub"
  return 1
}

install_missing_cli() {
  log "⚡ Fallback: CLI с GitHub Releases (если нет в системе)..."

  local ga gaa gav
  ga="$(github_arch)"
  gaa="$(github_arch_alt)"
  # fastfetch называет armv7l-ассет именно "armv7l" (с буквой l),
  # тогда как остальные проекты используют "armv7"
  if [ "$ARCH" = "armv7l" ]; then gav="armv7l"; else gav="$ga"; fi

  # Паттерны URL выбираем ПО ОС: в релизах большинства утилит лежат
  # ассеты сразу для всех платформ, и единый список не годится —
  # на macOS первым совпал бы linux-бинарь.
  # ВАЖНО: паттерны заякорены на архитектуру (${ga}/${gaa}/${gav}),
  # потому что в списке ассетов aarch64 сплошь и рядом идёт РАНЬШЕ x86_64,
  # и рыхлый паттерн вроде "lsd-.*-apple-darwin" скачал бы не тот бинарь.
  if [ "$OS_TYPE" = "Darwin" ]; then

    # fastfetch — fastfetch-macos-{amd64,aarch64}.tar.gz (zip — запасной)
    if ! have fastfetch; then
      install_from_github "fastfetch" "fastfetch-cli/fastfetch" \
        "fastfetch-macos-${gaa}\\.tar\\.gz" \
        "fastfetch-macos-${ga}\\.tar\\.gz" \
        "fastfetch-macos-${gaa}\\.zip" \
        "fastfetch-macos-${ga}\\.zip" || true
    fi

    if ! have lsd; then
      install_from_github "lsd" "lsd-rs/lsd" \
        "lsd-.*-${ga}-apple-darwin\\.tar\\.gz" || true
    fi

    if ! have lazygit; then
      install_from_github "lazygit" "jesseduffield/lazygit" \
        "darwin_${ga}\\.tar\\.gz" "darwin_${gaa}\\.tar\\.gz" || true
    fi

    # tealdeer → tldr (репо переехало на tealdeer-rs/tealdeer)
    if ! have tldr && ! have tealdeer; then
      install_from_github "tldr" "tealdeer-rs/tealdeer" "tealdeer-macos-${ga}" || true
    fi

    if ! have procs; then
      install_from_github "procs" "dalance/procs" \
        "procs-.*-${ga}-mac\\.zip" || true
    fi

    # kmon — только Linux, здесь пропуск
    if ! have zoxide; then
      install_from_github "zoxide" "ajeetdsouza/zoxide" \
        "${ga}-apple-darwin\\.tar\\.gz" || true
    fi

  else

    # fastfetch linux — fastfetch-linux-{amd64,aarch64,armv7l}.tar.gz.
    # Формат пакета выбираем по PM: .deb ставится только на apt, .rpm — на
    # dnf/zypper. Без этого на Fedora первым совпал бы .deb-ассет (он есть
    # в релизе) и .rpm никогда бы не попробовался.
    if ! have fastfetch; then
      local ff_pats=()
      case "$PM" in
        apt)
          ff_pats=(
            "fastfetch-linux-${gaa}\\.tar\\.gz"
            "fastfetch-linux-${ga}\\.tar\\.gz"
            "fastfetch-linux-${gav}\\.tar\\.gz"
            "fastfetch-linux-${gaa}\\.deb"
            "fastfetch-linux-${ga}\\.deb"
            "fastfetch-linux-${gav}\\.deb"
          )
          ;;
        dnf|zypper)
          ff_pats=(
            "fastfetch-linux-${gaa}\\.tar\\.gz"
            "fastfetch-linux-${ga}\\.tar\\.gz"
            "fastfetch-linux-${gav}\\.tar\\.gz"
            "fastfetch-linux-${gaa}\\.rpm"
            "fastfetch-linux-${ga}\\.rpm"
            "fastfetch-linux-${gav}\\.rpm"
          )
          ;;
        *)
          ff_pats=(
            "fastfetch-linux-${gaa}\\.tar\\.gz"
            "fastfetch-linux-${ga}\\.tar\\.gz"
            "fastfetch-linux-${gav}\\.tar\\.gz"
          )
          ;;
      esac
      install_from_github "fastfetch" "fastfetch-cli/fastfetch" "${ff_pats[@]}" || true
    fi

    if ! have lsd; then
      install_from_github "lsd" "lsd-rs/lsd" \
        "${ga}-unknown-linux-musl\\.tar\\.gz" \
        "${ga}-unknown-linux-gnu\\.tar\\.gz" || true
    fi

    if ! have lazygit; then
      install_from_github "lazygit" "jesseduffield/lazygit" \
        "linux_${ga}\\.tar\\.gz" "linux_${gaa}\\.tar\\.gz" || true
    fi

    # tealdeer → tldr; для armv7 имя включает суффикс musleabihf
    if ! have tldr && ! have tealdeer; then
      install_from_github "tldr" "tealdeer-rs/tealdeer" \
        "tealdeer-linux-${ga}-musl" "tealdeer-linux-${ga}-gnu" \
        "tealdeer-linux-${ga}-musleabihf" || true
    fi

    if ! have procs; then
      install_from_github "procs" "dalance/procs" \
        "procs-.*-${ga}-linux\\.zip" || true
    fi

    # kmon — в релизах только x86_64
    if ! have kmon; then
      if [ "$ga" = "x86_64" ]; then
        install_from_github "kmon" "orhun/kmon" \
          "${ga}-unknown-linux-gnu\\.tar\\.gz" "${ga}-unknown-linux-musl\\.tar\\.gz" || true
      else
        warn "kmon: сборок для $ga нет (только x86_64) — пропуск"
      fi
    fi

    if ! have zoxide; then
      install_from_github "zoxide" "ajeetdsouza/zoxide" \
        "${ga}-unknown-linux-musl\\.tar\\.gz" \
        "zoxide-.*-${ga}-unknown-linux-.*" || true
    fi

  fi
}

# ---------------------------------------------------------------------------
# Oh My Zsh + плагины
# ---------------------------------------------------------------------------

install_omz() {
  if [ -d "$HOME_DIR/.oh-my-zsh" ]; then
    ok "Oh My Zsh уже установлен"
    return 0
  fi
  log "💾 Установка Oh My Zsh..."
  local tmpfile
  tmpfile="$(mktemp)"
  if curl -fsSL --max-time 60 \
      "https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh" \
      -o "$tmpfile"; then
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh "$tmpfile" --unattended || warn "Oh My Zsh install вернул ошибку"
    rm -f "$tmpfile"
  else
    warn "не удалось скачать Oh My Zsh installer"
    rm -f "$tmpfile"
    return 1
  fi
  if [ -d "$HOME_DIR/.oh-my-zsh" ]; then
    ok "Oh My Zsh"
  else
    warn "Oh My Zsh не появился"
  fi
}

install_plugins() {
  local zsh_custom="${ZSH_CUSTOM:-$HOME_DIR/.oh-my-zsh/custom}"
  mkdir -p "$zsh_custom/plugins"

  log "🔌 Плагины Zsh..."

  # из бандла
  if [ -d "$SCRIPT_DIR/plugins" ]; then
    local p
    for p in zsh-autosuggestions zsh-syntax-highlighting; do
      if [ -d "$SCRIPT_DIR/plugins/$p" ] && [ ! -d "$zsh_custom/plugins/$p" ]; then
        cp -a "$SCRIPT_DIR/plugins/$p" "$zsh_custom/plugins/"
        ok "скопирован $p из бандла"
      fi
    done
  fi

  # fallback — clone
  if [ ! -d "$zsh_custom/plugins/zsh-autosuggestions" ]; then
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions \
      "$zsh_custom/plugins/zsh-autosuggestions" &>/dev/null && ok "zsh-autosuggestions" \
      || warn "не удалось клонировать zsh-autosuggestions"
  fi
  if [ ! -d "$zsh_custom/plugins/zsh-syntax-highlighting" ]; then
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting \
      "$zsh_custom/plugins/zsh-syntax-highlighting" &>/dev/null && ok "zsh-syntax-highlighting" \
      || warn "не удалось клонировать zsh-syntax-highlighting"
  fi
}

# ---------------------------------------------------------------------------
# ASN
# ---------------------------------------------------------------------------

install_asn() {
  if [ ! -f "$SCRIPT_DIR/bin/asn" ]; then
    warn "bin/asn не найден в бандле"
    return 0
  fi
  if have asn; then
    ok "asn уже в PATH"
    return 0
  fi
  log "🛡️  Установка ASN..."
  install_bin "$SCRIPT_DIR/bin/asn" "asn"
  if have asn; then
    ok "asn"
  else
    warn "asn не попал в PATH"
  fi
}

# ---------------------------------------------------------------------------
# .zshrc
# ---------------------------------------------------------------------------

apply_zshrc() {
  if [ ! -f "$SCRIPT_DIR/zshrc_template" ]; then
    warn "zshrc_template не найден — пропускаем"
    return 0
  fi
  log "⚙️  Применение .zshrc..."
  if [ -f "$HOME_DIR/.zshrc" ]; then
    local bak="$HOME_DIR/.zshrc.bak.$(date +%Y%m%d-%H%M%S)"
    cp "$HOME_DIR/.zshrc" "$bak"
    ok "бэкап → $bak"
  fi
  cp "$SCRIPT_DIR/zshrc_template" "$HOME_DIR/.zshrc"

  # гарантируем ~/.local/bin в PATH внутри .zshrc.
  # Проверяем только активную строку export PATH=…: в шаблоне есть
  # закомментированный `# export PATH=…$HOME/.local/bin…`, который не должен
  # блокировать вставку (раньше grep по подстроке давал ложное срабатывание).
  if ! grep -qE '^[^#]*export[[:space:]]+PATH=.*\.local/bin' "$HOME_DIR/.zshrc" 2>/dev/null; then
    # sed -i.bak: на macOS нет флага -i без аргумента, поэтому пробуем сначала
    # файловый вариант, а при неудаче пересобираем файл через временный.
    if sed -i.bak '1i\
export PATH="$HOME/.local/bin:/usr/local/bin:$PATH"
' "$HOME_DIR/.zshrc" 2>/dev/null; then
      rm -f "$HOME_DIR/.zshrc.bak"
    else
      { printf 'export PATH="$HOME/.local/bin:/usr/local/bin:$PATH"\n'; cat "$HOME_DIR/.zshrc"; } \
        > "$HOME_DIR/.zshrc.tmp" && mv "$HOME_DIR/.zshrc.tmp" "$HOME_DIR/.zshrc"
    fi
  fi
  ok ".zshrc обновлён"
}

# ---------------------------------------------------------------------------
# Смена оболочки
# ---------------------------------------------------------------------------

switch_shell() {
  local zsh_path
  zsh_path="$(command -v zsh || true)"
  if [ -z "$zsh_path" ]; then
    warn "zsh не установлен — смена оболочки пропущена"
    return 0
  fi

  if [ "${SHELL:-}" = "$zsh_path" ]; then
    ok "оболочка уже zsh"
    return 0
  fi

  log "🔄 Смена оболочки на zsh..."

  if [ -f /etc/shells ] && ! grep -qxF "$zsh_path" /etc/shells 2>/dev/null; then
    echo "$zsh_path" | run_root tee -a /etc/shells >/dev/null || true
  fi

  if chsh -s "$zsh_path" "${USER:-$(id -un)}" 2>/dev/null; then
    ok "chsh → $zsh_path"
  elif run_root chsh -s "$zsh_path" "${USER:-$(id -un)}" 2>/dev/null; then
    ok "chsh (sudo) → $zsh_path"
  else
    warn "chsh не удался — смените оболочку вручную: chsh -s $(command -v zsh)"
  fi
}

# ---------------------------------------------------------------------------
# tldr cache
# ---------------------------------------------------------------------------

update_tldr() {
  if have tldr; then
    log "📚 Обновление кэша tldr..."
    tldr --update &>/dev/null || tldr -u &>/dev/null || true
  fi
}

# ---------------------------------------------------------------------------
# Итоговый отчёт
# ---------------------------------------------------------------------------

final_report() {
  log ""
  log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  log "📋 Проверка утилит"
  log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  local cmd status missing=0
  for cmd in zsh git curl lsd bat fzf btop zoxide fastfetch lazygit tldr duf micro procs fd grc asn; do
    # tealdeer может быть как tldr
    if [ "$cmd" = "tldr" ] && ! have tldr && have tealdeer; then
      ok "tldr (tealdeer)"
      continue
    fi
    if [ "$cmd" = "fd" ] && ! have fd && have fdfind; then
      ok "fd (fdfind)"
      continue
    fi
    if [ "$cmd" = "bat" ] && ! have bat && have batcat; then
      ok "bat (batcat)"
      continue
    fi
    if have "$cmd"; then
      ok "$cmd"
    else
      err "$cmd — нет"
      missing=$((missing + 1))
    fi
  done

  if [ "$OS_TYPE" = "Linux" ]; then
    if have kmon; then ok "kmon"; else warn "kmon — нет (опционально)"; fi
  fi

  log ""
  if [ ${#SKIPPED_PKGS[@]} -gt 0 ]; then
    log "Пропущены (нет в репо): ${SKIPPED_PKGS[*]}"
  fi
  if [ ${#FAILED_PKGS[@]} -gt 0 ]; then
    log "Ошибки установки: ${FAILED_PKGS[*]}"
  fi

  log ""
  if [ "$missing" -eq 0 ]; then
    log "✅ ГОТОВО. Все основные утилиты на месте."
  else
    log "⚠️  ГОТОВО с пропусками ($missing утилит нет)."
    log "   Это нормально на минимальных/старых репозиториях."
  fi
  log "🔄 Откройте новый терминал или выполните: exec zsh -l"
  log ""
}

# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------

main() {
  log "🚀 Beautiful Terminal — установка"
  log ""

  detect_pm
  check_sudo
  ensure_local_bin
  install_packages
  ensure_symlinks
  install_missing_cli
  install_omz
  install_plugins
  install_asn
  apply_zshrc
  switch_shell
  update_tldr
  final_report
}

main "$@"
