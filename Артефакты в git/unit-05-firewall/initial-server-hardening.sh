#!/usr/bin/env bash
#
# initial-server-hardening.sh
# Базовый hardening Ubuntu-сервера
# Применяет пункты 1-8 из чек-листа
#
# Использование: sudo ./initial-server-hardening.sh <username>
# Пример:        sudo ./initial-server-hardening.sh evgeniy
#

set -euo pipefail

#═══════════════════════════════════════════════════════════
# ЦВЕТА И ЛОГИРОВАНИЕ
#═══════════════════════════════════════════════════════════

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()  { echo -e "${BLUE}[INFO]${NC}  $1"; }
log_ok()    { echo -e "${GREEN}[OK]${NC}    $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }

log_section() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════${NC}"
}

#═══════════════════════════════════════════════════════════
# ПРОВЕРКИ ПЕРЕД ЗАПУСКОМ
#═══════════════════════════════════════════════════════════

if [[ $EUID -ne 0 ]]; then
    log_error "Скрипт должен запускаться через sudo"
    exit 1
fi

if [[ $# -lt 1 ]]; then
    log_error "Использование: sudo $0 <username>"
    log_error "Пример:        sudo $0 evgeniy"
    exit 1
fi

USERNAME="$1"

if ! id "$USERNAME" &>/dev/null; then
    log_error "Пользователь '$USERNAME' не существует"
    log_error "Создай его сначала: sudo adduser $USERNAME"
    exit 1
fi

# Логирование в файл + консоль
LOG_FILE="/var/log/hardening-$(date +%Y%m%d-%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

log_info "Начинаю hardening для пользователя: $USERNAME"
log_info "Лог сохраняется в: $LOG_FILE"

# Обновление списков пакетов
log_info "Обновление apt cache..."
apt-get update -qq

#═══════════════════════════════════════════════════════════
# ПУНКТ 1: NON-ROOT USER + SUDO
#═══════════════════════════════════════════════════════════

log_section "1. Non-root user + sudo"

if id -nG "$USERNAME" | grep -qw sudo; then
    log_ok "Пользователь $USERNAME уже в группе sudo"
else
    usermod -aG sudo "$USERNAME"
    log_ok "Пользователь $USERNAME добавлен в группу sudo"
fi

log_info "Проверка sudo-прав:"
sudo -u "$USERNAME" sudo -n -l 2>&1 | head -5 || log_warn "Не удалось проверить sudo для $USERNAME"

#═══════════════════════════════════════════════════════════
# ПУНКТ 2: SSH HARDENING
#═══════════════════════════════════════════════════════════

log_section "2. SSH: ключи, no password, no root"

SSHD_CONFIG="/etc/ssh/sshd_config"

# Проверка: установлен ли SSH-сервер
if ! command -v sshd &>/dev/null; then
    log_warn "SSH-сервер не установлен, устанавливаю..."
    DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server
    log_ok "openssh-server установлен"
fi

# Проверка: работает ли сервис
if ! systemctl is-active ssh &>/dev/null && ! systemctl is-active sshd &>/dev/null; then
    log_warn "SSH-сервис не запущен, запускаю..."
    systemctl enable --now ssh 2>/dev/null || systemctl enable --now sshd
fi

# Проверка: существует ли конфиг
if [[ ! -f "$SSHD_CONFIG" ]]; then
    log_error "Конфиг $SSHD_CONFIG не найден даже после установки"
    exit 1
fi

log_ok "SSH-сервер установлен и работает"

# ... дальше идёт бэкап и настройка ...
SSHD_BACKUP="${SSHD_CONFIG}.backup.$(date +%Y%m%d-%H%M%S)"

# Проверка, что у пользователя есть SSH-ключи
USER_HOME=$(getent passwd "$USERNAME" | cut -d: -f6)
AUTHORIZED_KEYS="${USER_HOME}/.ssh/authorized_keys"

if [[ ! -f "$AUTHORIZED_KEYS" ]] || [[ ! -s "$AUTHORIZED_KEYS" ]]; then
    log_error "У пользователя $USERNAME НЕТ SSH-ключей в $AUTHORIZED_KEYS"
    log_error "Добавь ключ перед запуском скрипта!"
    log_error "Пример: ssh-copy-id $USERNAME@server-ip"
    exit 1
fi
log_ok "SSH-ключи у $USERNAME найдены"

# Бэкап
cp "$SSHD_CONFIG" "$SSHD_BACKUP"
log_ok "Бэкап SSH-конфига: $SSHD_BACKUP"

# Функция идемпотентной установки параметра в sshd_config
set_sshd_option() {
    local key="$1"
    local value="$2"

    if grep -qE "^#?\s*${key}\s+" "$SSHD_CONFIG"; then
        sed -i "s|^#\?\s*${key}\s\+.*|${key} ${value}|" "$SSHD_CONFIG"
    else
        echo "${key} ${value}" >> "$SSHD_CONFIG"
    fi
    log_ok "SSH: ${key} = ${value}"
}

set_sshd_option "PermitRootLogin"           "no"
set_sshd_option "PasswordAuthentication"    "no"
set_sshd_option "PubkeyAuthentication"      "yes"
set_sshd_option "MaxAuthTries"              "3"
set_sshd_option "ClientAliveInterval"       "300"
set_sshd_option "ClientAliveCountMax"       "2"
set_sshd_option "X11Forwarding"             "no"

# Критично: проверка синтаксиса ПЕРЕД перезагрузкой
if sshd -t; then
    log_ok "Синтаксис sshd_config корректен"
    systemctl reload sshd
    log_ok "SSH перезагружен"
else
    log_error "Синтаксис sshd_config СЛОМАН, восстанавливаю бэкап"
    cp "$SSHD_BACKUP" "$SSHD_CONFIG"
    systemctl reload sshd
    exit 1
fi

log_warn "ВАЖНО: проверь SSH из НОВОГО окна ДО закрытия текущего!"

#═══════════════════════════════════════════════════════════
# ПУНКТ 3: АВТОМАТИЧЕСКИЕ ОБНОВЛЕНИЯ БЕЗОПАСНОСТИ
#═══════════════════════════════════════════════════════════

log_section "3. Автообновления безопасности"

DEBIAN_FRONTEND=noninteractive apt-get install -y unattended-upgrades apt-listchanges
log_ok "unattended-upgrades установлен"

# Вывод инфы по тому, что должно обновляться
log_info "Проверка Allowed-Origins в 50unattended-upgrades:"
grep -A 5 "Allowed-Origins" /etc/apt/apt.conf.d/50unattended-upgrades | grep -v "^//" | head -10
log_warn "По умолчанию активны только -security обновления. Это ок для production."
log_warn "Если хочешь ставить и -updates автоматически — раскомментируй строку в файле."

cat > /etc/apt/apt.conf.d/20auto-upgrades <<EOF
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Download-Upgradeable-Packages "1";
EOF
log_ok "Автообновления настроены (только security)"

log_info "Проверка (dry-run):"
unattended-upgrade -d --dry-run 2>&1 | tail -3 || log_warn "dry-run вернул предупреждения"

#═══════════════════════════════════════════════════════════
# ПУНКТ 4: ФАЙРВОЛ UFW
#═══════════════════════════════════════════════════════════

log_section "4. Файрвол UFW"

DEBIAN_FRONTEND=noninteractive apt-get install -y ufw
log_ok "UFW установлен"

# Политики по умолчанию
ufw default deny incoming >/dev/null
ufw default allow outgoing >/dev/null
ufw default deny routed >/dev/null

# КРИТИЧНО: сначала разрешить SSH!
SSH_PORT=$(grep -Ei '^Port [0-9]+' "$SSHD_CONFIG" | awk '{print $2}' | head -1) # извлечение порта из конфига
SSH_PORT="${SSH_PORT:-22}"
ufw allow "${SSH_PORT}/tcp"
log_ok "OpenSSH разрешён"

# Если нужны веб-порты — раскомментируй:
# ufw allow 80/tcp >/dev/null
# ufw allow 443/tcp >/dev/null

# Включаем (--force чтобы не спрашивал)
ufw --force enable >/dev/null
log_ok "UFW включён"

log_info "Статус UFW:"
ufw status verbose

#═══════════════════════════════════════════════════════════
# ПУНКТ 5: FAIL2BAN
#═══════════════════════════════════════════════════════════

log_section "5. Fail2ban"

DEBIAN_FRONTEND=noninteractive apt-get install -y fail2ban
log_ok "Fail2ban установлен"

# Локальный конфиг — не трогаем jail.conf!
cat > /etc/fail2ban/jail.local <<EOF
[DEFAULT]
bantime  = 1h
findtime = 10m
maxretry = 5
banaction = ufw

[sshd]
enabled = true
EOF
log_ok "jail.local создан"

systemctl enable --now fail2ban >/dev/null
systemctl restart fail2ban

sleep 2  # даём демону подняться
log_info "Статус fail2ban:"
fail2ban-client status sshd || log_warn "Fail2ban ещё не готов"

#═══════════════════════════════════════════════════════════
# ПУНКТ 6: ОТКЛЮЧЕНИЕ ЛИШНИХ СЕРВИСОВ
#═══════════════════════════════════════════════════════════

log_section "6. Отключение неиспользуемых сервисов"

SERVICES_TO_DISABLE=(
    "avahi-daemon"
    "cups"
    "bluetooth"
    "ModemManager"
)

for service in "${SERVICES_TO_DISABLE[@]}"; do
    if systemctl list-unit-files "${service}.service" &>/dev/null; then
        if systemctl is-active "${service}" &>/dev/null; then
            if systemctl disable --now "${service}" 2>/dev/null; then
                log_ok "Отключён: $service"
            else
                log_warn "Не удалось отключить: $service"
            fi
        else
            log_ok "Уже отключён: $service"
        fi
    else
        log_info "Не установлен: $service (пропуск)"
    fi
done

log_info "Порты, слушающие наружу:"
ss -tlnp | grep -v '127\.0\.0\.1\|::1' || true

#═══════════════════════════════════════════════════════════
# ПУНКТ 7: АУДИТ (auditd)
#═══════════════════════════════════════════════════════════

log_section "7. Аудит (auditd)"

DEBIAN_FRONTEND=noninteractive apt-get install -y auditd audispd-plugins
log_ok "auditd установлен"

cat > /etc/audit/rules.d/hardening.rules <<EOF
# Критичные файлы
-w /etc/passwd -p wa -k passwd_changes
-w /etc/shadow -p wa -k shadow_changes
-w /etc/group -p wa -k group_changes
-w /etc/sudoers -p wa -k sudoers_changes
-w /etc/sudoers.d/ -p wa -k sudoers_changes
-w /etc/ssh/sshd_config -p wa -k sshd_config
-w /var/log/auth.log -p wa -k auth_log

# Запуски с правами root
-a always,exit -F arch=b64 -S execve -F euid=0 -k root_commands
EOF
log_ok "Правила аудита созданы"

systemctl enable --now auditd >/dev/null
augenrules --load >/dev/null
log_ok "Правила загружены"

#═══════════════════════════════════════════════════════════
# ПУНКТ 8: ETCKEEPER — /etc в git
#═══════════════════════════════════════════════════════════

log_section "8. etckeeper — /etc в git"

if command -v etckeeper &>/dev/null; then
    log_ok "etckeeper уже установлен"
else
    DEBIAN_FRONTEND=noninteractive apt-get install -y etckeeper
    log_ok "etckeeper установлен"
fi

if [[ ! -d /etc/.git ]]; then
    etckeeper init
    etckeeper commit "Initial commit by hardening script"
    log_ok "etckeeper инициализирован"
else
    log_ok "etckeeper уже инициализирован"
    etckeeper commit "State after hardening script" 2>/dev/null \
        || log_info "Нет изменений для коммита"
fi

#═══════════════════════════════════════════════════════════
# ФИНАЛЬНЫЙ ОТЧЁТ
#═══════════════════════════════════════════════════════════

log_section "✅ HARDENING ЗАВЕРШЁН"

echo ""
log_info "Применённые пункты:"
echo "  ✓ Non-root пользователь: $USERNAME с sudo"
echo "  ✓ SSH: ключи, no password, no root"
echo "  ✓ Автообновления безопасности"
echo "  ✓ UFW настроен и включён"
echo "  ✓ Fail2ban защищает SSH"
echo "  ✓ Лишние сервисы отключены"
echo "  ✓ auditd отслеживает критичные файлы"
echo "  ✓ /etc под контролем git через etckeeper"

echo ""
log_warn "СЛЕДУЮЩИЕ ШАГИ:"
echo "  1. Проверь SSH-доступ из НОВОГО окна ПРЕЖДЕ чем закрыть текущее!"
echo "  2. Убедись, что можешь sudo от $USERNAME"
echo "  3. Настрой бэкапы (пункт 10 чек-листа)"
echo "  4. Пройди audit через Lynis: sudo apt install lynis && sudo lynis audit system"

echo ""
log_info "Полный лог: $LOG_FILE"
