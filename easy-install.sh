#!/usr/bin/env bash
# =============================================================================
#  Mirza Bot - Easy Installer                                MIRZA_EASY_INSTALLER
#
#  One script to install, update, repair, back up and remove Mirza Bot on a
#  fresh Ubuntu / Debian server - WITHOUT needing a domain name.
#
#  Quick start (as root):
#     bash <(curl -fsSL https://raw.githubusercontent.com/kiarash707/mirzabot.kia/main/easy-install.sh)
#
#  After the first run the same tool is available as the `mirzabot` command.
#  Run `mirzabot help` for every command and option.
# =============================================================================

INSTALLER_VERSION="1.0.0"

# --- defaults (everything can be overridden through the environment) ---------
REPO="${MIRZA_REPO:-kiarash707/mirzabot.kia}"
BRANCH="${MIRZA_BRANCH:-main}"
APP_DIR="${MIRZA_DIR:-/var/www/mirzabot}"
CONF_DIR="${MIRZA_CONF_DIR:-/etc/mirzabot}"
CONF_FILE="$CONF_DIR/installer.conf"
BACKUP_DIR="${MIRZA_BACKUP_DIR:-/var/backups/mirzabot}"
LOG_FILE="${MIRZA_LOG_FILE:-/var/log/mirzabot-installer.log}"
BIN_PATH="/usr/local/bin/mirzabot"
ACME_WEBROOT="/var/www/mirzabot-acme"
CERT_NAME="mirzabot"
CERT_DIR="/etc/letsencrypt/live/$CERT_NAME"
CERTBOT_VENV="/opt/mirzabot/certbot"
COMPOSER_BIN="/usr/local/bin/composer"
VHOST_HTTP="000-mirzabot"
VHOST_HTTPS="000-mirzabot-ssl"
PHP_TARGET="8.5"            # the bot refuses to run on anything older than PHP_MIN
PHP_MIN="8.5.12"
PHP_BIN="/usr/bin/php${PHP_TARGET}"
KEEP_UPDATE_BACKUPS=5

# --- runtime state ------------------------------------------------------------
CMD=""
EXTRA=()
OPT_TOKEN=""; OPT_ADMIN=""; OPT_DOMAIN=""; OPT_EMAIL=""; OPT_TAG=""; OPT_CERT_MODE=""; OPT_REPO=""; OPT_BRANCH=""
OPT_NO_DOMAIN=0; ASSUME_YES=0; FORCE=0; KEEP_DB=0; PURGE_STACK=0; NO_BACKUP=0; NO_COLOR_OPT=0
DB_ROOT_PASS="${MIRZA_DB_ROOT_PASS:-}"
TOKEN=""; ADMIN_ID=""; BOT_USERNAME=""
HOST=""; SERVER_IP=""; ACCESS_MODE=""; CERT_MODE=""
DB_NAME=""; DB_USER=""; DB_PASS=""
SRC_DIR=""; SRC_SHA=""; TMP_WORK=""
HAVE_TTY=0; TTY_DEV="/dev/tty"
STEP_NO=0; STEP_TOTAL=0
SPIN_PID=""; RULE_LINE=""

export DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a NEEDRESTART_SUSPEND=1 APT_LISTCHANGES_FRONTEND=none

# =============================================================================
#  UI helpers
# =============================================================================
setup_ui() {
    if [[ -t 1 && -z "${NO_COLOR:-}" && $NO_COLOR_OPT -eq 0 && "${TERM:-dumb}" != "dumb" ]]; then
        C_R=$'\033[31m'; C_G=$'\033[32m'; C_Y=$'\033[33m'; C_B=$'\033[34m'; C_C=$'\033[36m'
        C_D=$'\033[2m'; C_W=$'\033[1m'; C_N=$'\033[0m'
    else
        C_R=""; C_G=""; C_Y=""; C_B=""; C_C=""; C_D=""; C_W=""; C_N=""
    fi
    case "${LC_ALL:-${LC_CTYPE:-${LANG:-}}}" in
        *UTF-8*|*utf8*|*UTF8*)
            RULE_LINE="──────────────────────────────────────────────────────────────"
            SYM_OK="✔"; SYM_ERR="✖"; SYM_WARN="!"; SYM_DOT="•"
            SPIN_FRAMES=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏) ;;
        *)
            RULE_LINE="--------------------------------------------------------------"
            SYM_OK="+"; SYM_ERR="x"; SYM_WARN="!"; SYM_DOT="*"
            SPIN_FRAMES=('|' '/' '-' '\') ;;
    esac
    if [[ -r $TTY_DEV ]] && { : <"$TTY_DEV"; } 2>/dev/null; then HAVE_TTY=1; fi
}

log()       { { printf '[%s] %s\n' "$(date '+%F %T')" "$*" >>"$LOG_FILE"; } 2>/dev/null || true; }
msg_ok()    { printf '  %s%s%s %s\n' "$C_G" "$SYM_OK" "$C_N" "$*"; log "OK: $*"; }
msg_info()  { printf '  %s%s%s %s\n' "$C_C" "$SYM_DOT" "$C_N" "$*"; log "INFO: $*"; }
msg_warn()  { printf '  %s%s%s %s%s%s\n' "$C_Y" "$SYM_WARN" "$C_N" "$C_Y" "$*" "$C_N"; log "WARN: $*"; }
msg_err()   { printf '  %s%s%s %s%s%s\n' "$C_R" "$SYM_ERR" "$C_N" "$C_R" "$*" "$C_N" >&2; log "ERROR: $*"; }
die()       { msg_err "$*"; cleanup; exit 1; }
msg_kv()    { printf '  %s%-16s%s %s\n' "$C_D" "$1" "$C_N" "$2"; }
rule()      { printf '%s%s%s\n' "$C_D" "$RULE_LINE" "$C_N"; }

banner() {
    printf '\n%s' "$C_C"
    cat <<'EOF'
  __  __ _                  ____        _
 |  \/  (_)_ __ ______ _   | __ )  ___ | |_
 | |\/| | | '__|_  / _` |  |  _ \ / _ \| __|
 | |  | | | |   / / (_| |  | |_) | (_) | |_
 |_|  |_|_|_|  /___\__,_|  |____/ \___/ \__|
EOF
    printf '%s' "$C_N"
    printf '  %sEasy Installer v%s  -  no domain required%s\n' "$C_D" "$INSTALLER_VERSION" "$C_N"
    rule
}

step() {
    STEP_NO=$((STEP_NO + 1))
    printf '\n%s[%d/%d]%s %s%s%s\n' "$C_B" "$STEP_NO" "$STEP_TOTAL" "$C_N" "$C_W" "$1" "$C_N"
    log "=== STEP $STEP_NO/$STEP_TOTAL: $1"
}

spinner_stop() {
    if [[ -n $SPIN_PID ]]; then
        kill "$SPIN_PID" 2>/dev/null; wait "$SPIN_PID" 2>/dev/null; SPIN_PID=""
        [[ -t 1 ]] && printf '\r\033[2K'
    fi
}

# run_step "label" command [args...]  - runs quietly with a spinner, output goes to the log.
run_step() {
    local label=$1 rc start=$SECONDS off; shift
    log "--- $label"
    off=$(stat -c %s "$LOG_FILE" 2>/dev/null || echo 0)
    if [[ -t 1 ]]; then
        ( "$@" ) >>"$LOG_FILE" 2>&1 &
        local pid=$! i=0
        while kill -0 "$pid" 2>/dev/null; do
            printf '\r\033[2K  %s%s%s %s %s(%ds)%s' "$C_C" "${SPIN_FRAMES[i % ${#SPIN_FRAMES[@]}]}" "$C_N" "$label" "$C_D" $((SECONDS - start)) "$C_N"
            i=$((i + 1)); sleep 0.12
        done
        wait "$pid"; rc=$?
        printf '\r\033[2K'
    else
        printf '  ... %s\n' "$label"
        ( "$@" ) </dev/null >>"$LOG_FILE" 2>&1; rc=$?
    fi
    if [[ $rc -eq 0 ]]; then
        msg_ok "$label"
    else
        msg_err "$label (exit code $rc)"
        printf '%s' "$C_D"; tail -c +$((off + 1)) "$LOG_FILE" 2>/dev/null | tail -n 15 | sed 's/^/      | /'; printf '%s' "$C_N"
        printf '  %sFull log: %s%s\n' "$C_D" "$LOG_FILE" "$C_N"
    fi
    return $rc
}

cleanup() {
    spinner_stop
    [[ -n $TMP_WORK && -d $TMP_WORK ]] && rm -rf "$TMP_WORK"
    return 0
}
on_interrupt() { spinner_stop; printf '\n'; msg_warn "Interrupted. Run the same command again to continue - finished steps are skipped."; cleanup; exit 130; }

# ask VAR "Prompt" [default]   (reads from the terminal even when the script is piped)
ask() {
    local __var=$1 __prompt=$2 __def=${3:-} __ans=""
    if [[ $HAVE_TTY -eq 0 ]]; then printf -v "$__var" '%s' "$__def"; return 0; fi
    local hint=""; [[ -n $__def ]] && hint=" ${C_D}[${__def}]${C_N}"
    printf '  %s?%s %s%s: ' "$C_Y" "$C_N" "$__prompt" "$hint" >&2
    IFS= read -r __ans <"$TTY_DEV" || __ans=""
    __ans="${__ans#"${__ans%%[![:space:]]*}"}"; __ans="${__ans%"${__ans##*[![:space:]]}"}"
    printf -v "$__var" '%s' "${__ans:-$__def}"
}

# confirm "Question" [y|n]  -> 0 for yes
confirm() {
    local q=$1 def=${2:-y} ans
    [[ $ASSUME_YES -eq 1 ]] && return 0
    [[ $HAVE_TTY -eq 0 ]] && { [[ $def == y ]]; return; }
    local hint="Y/n"; [[ $def == n ]] && hint="y/N"
    printf '  %s?%s %s %s[%s]%s: ' "$C_Y" "$C_N" "$q" "$C_D" "$hint" "$C_N" >&2
    IFS= read -r ans <"$TTY_DEV" || ans=""
    ans=${ans:-$def}
    [[ $ans =~ ^[Yy]([Ee][Ss])?$ ]]
}

pause_key() { [[ $HAVE_TTY -eq 1 ]] || return 0; printf '\n  %sPress Enter to continue...%s' "$C_D" "$C_N" >&2; IFS= read -r _ <"$TTY_DEV" || true; }

self_url() { echo "https://raw.githubusercontent.com/${REPO}/${BRANCH}/easy-install.sh"; }

# =============================================================================
#  Generic helpers
# =============================================================================
need_root() { [[ $EUID -eq 0 ]] || die "Please run this script as root (try: sudo -i, then run it again)."; }
have() { command -v "$1" >/dev/null 2>&1; }
retry() { local n=$1 d=$2 i; shift 2; for ((i = 1; i <= n; i++)); do "$@" && return 0; [[ $i -lt $n ]] && sleep "$d"; done; return 1; }
rand_hex() { openssl rand -hex "$(($1 / 2))"; }
pkg_installed() { dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q 'install ok installed'; }
pkg_candidate() { apt-cache policy "$1" 2>/dev/null | awk '/Candidate:/{print $2; exit}'; }
human_bytes() { numfmt --to=iec --suffix=B "$1" 2>/dev/null || echo "$1 B"; }

valid_ipv4() {
    local ip=$1 o IFS=.
    [[ $ip =~ ^[0-9]{1,3}(\.[0-9]{1,3}){3}$ ]] || return 1
    for o in $ip; do ((10#$o <= 255)) || return 1; done
}
is_private_ipv4() {
    local a b; IFS=. read -r a b _ _ <<<"$1"
    ((a == 10 || a == 127 || (a == 172 && b >= 16 && b <= 31) || (a == 192 && b == 168) || (a == 169 && b == 254) || (a == 100 && b >= 64 && b <= 127)))
}
valid_domain() { [[ $1 =~ ^([A-Za-z0-9]([A-Za-z0-9-]{0,61}[A-Za-z0-9])?\.)+[A-Za-z]{2,63}$ ]]; }
valid_token() { [[ $1 =~ ^[0-9]{6,12}:[A-Za-z0-9_-]{30,60}$ ]]; }
valid_admin() { [[ $1 =~ ^[0-9]{5,15}$ ]]; }

# --- persistent installer settings (root only) ---------------------------------
conf_set() {
    mkdir -p "$CONF_DIR"; chmod 700 "$CONF_DIR"
    touch "$CONF_FILE"; chmod 600 "$CONF_FILE"
    sed -i "/^$1=/d" "$CONF_FILE"
    printf "%s='%s'\n" "$1" "$2" >>"$CONF_FILE"
}
conf_get() { [[ -f $CONF_FILE ]] || return 0; sed -n "s/^$1='\(.*\)'\$/\1/p" "$CONF_FILE" | tail -n1; }
conf_has() { [[ -n "$(conf_get "$1")" ]]; }

# --- values stored inside the bot's own config.php ---------------------------
cfg_get() { [[ -f $APP_DIR/config.php ]] && sed -n "s/^\\\$$1 = '\(.*\)';.*/\1/p" "$APP_DIR/config.php" | head -n1; }
cfg_set() { sed -i -E "s|^(\\\$$1 = ').*(';)|\\1$2\\2|" "$APP_DIR/config.php"; }

is_installed() { [[ "$(conf_get INSTALL_STATE)" == "complete" && -f $APP_DIR/config.php ]]; }

load_context() {
    APP_DIR="$(conf_get APP_DIR)"; APP_DIR="${APP_DIR:-${MIRZA_DIR:-/var/www/mirzabot}}"
    HOST="$(conf_get HOST)"; CERT_MODE="$(conf_get CERT_MODE)"; ACCESS_MODE="$(conf_get ACCESS_MODE)"
    DB_NAME="$(conf_get DB_NAME)"; DB_USER="$(conf_get DB_USER)"; DB_PASS="$(conf_get DB_PASS)"
    [[ -n $(conf_get REPO) && -z ${MIRZA_REPO:-} ]] && REPO="$(conf_get REPO)"
    [[ -n $(conf_get BRANCH) && -z ${MIRZA_BRANCH:-} ]] && BRANCH="$(conf_get BRANCH)"
    [[ -n $OPT_REPO ]] && REPO=$OPT_REPO
    [[ -n $OPT_BRANCH ]] && BRANCH=$OPT_BRANCH
    [[ -n $(conf_get PHP_VER) ]] && { PHP_TARGET="$(conf_get PHP_VER)"; PHP_BIN="/usr/bin/php${PHP_TARGET}"; }
    [[ -z $HOST ]] && HOST="$(cfg_get domainhosts)"
    [[ -z $DB_NAME ]] && DB_NAME="$(cfg_get dbname)"
    [[ -z $DB_USER ]] && DB_USER="$(cfg_get usernamedb)"
    [[ -z $DB_PASS ]] && DB_PASS="$(cfg_get passworddb)"
    return 0
}

require_installed() { is_installed || die "Mirza Bot is not installed on this server. Run: mirzabot install"; }

acquire_lock() {
    mkdir -p /var/lock 2>/dev/null
    exec 9>/var/lock/mirzabot-installer.lock
    flock -n 9 || die "Another mirzabot installer process is already running."
}

# =============================================================================
#  System checks
# =============================================================================
OS_ID=""; OS_VER=""; OS_CODENAME=""; OS_PRETTY=""
detect_os() {
    [[ -f /etc/os-release ]] || die "Cannot detect the operating system (/etc/os-release missing)."
    # shellcheck disable=SC1091
    OS_ID=$(. /etc/os-release; echo "${ID:-}")
    OS_VER=$(. /etc/os-release; echo "${VERSION_ID:-0}")
    OS_CODENAME=$(. /etc/os-release; echo "${UBUNTU_CODENAME:-${VERSION_CODENAME:-}}")
    OS_PRETTY=$(. /etc/os-release; echo "${PRETTY_NAME:-unknown}")
}

check_os() {
    detect_os
    local major=${OS_VER%%.*}
    case "$OS_ID" in
        ubuntu) ((major >= 22)) || die "Ubuntu 22.04 or newer is required (found $OS_PRETTY)." ;;
        debian) ((major >= 12)) || die "Debian 12 or newer is required (found $OS_PRETTY)." ;;
        *) if [[ $FORCE -eq 1 ]]; then msg_warn "Unsupported OS '$OS_PRETTY' - continuing because of --force."
           else die "Unsupported OS '$OS_PRETTY'. Use Ubuntu 22.04/24.04 or Debian 12/13 (or pass --force at your own risk)."; fi ;;
    esac
    case "$(uname -m)" in x86_64|aarch64|arm64) ;; *) die "Unsupported CPU architecture: $(uname -m)" ;; esac
    [[ -d /run/systemd/system ]] || die "systemd is required (containers without systemd are not supported)."
    msg_ok "System: $OS_PRETTY ($(uname -m))"
}

check_resources() {
    local mem_kb disk_kb
    mem_kb=$(awk '/MemTotal/{print $2}' /proc/meminfo)
    disk_kb=$(df -Pk /var 2>/dev/null | awk 'NR==2{print $4}')
    if [[ ${disk_kb:-0} -lt 2097152 ]]; then die "At least 2 GB of free disk space is needed on / (found $(human_bytes $((disk_kb * 1024))))."; fi
    if [[ ${mem_kb:-0} -lt 900000 ]]; then msg_warn "Low memory ($((mem_kb / 1024)) MB). A swap file will be created automatically."; fi
    msg_ok "Resources: $((mem_kb / 1024)) MB RAM, $(human_bytes $((disk_kb * 1024))) free disk"
}

check_network() {
    curl -fsS --max-time 10 -o /dev/null https://github.com 2>>"$LOG_FILE" \
        || die "Cannot reach github.com. Check the server's internet access / DNS."
    local code
    code=$(curl -sS --max-time 10 -o /dev/null -w '%{http_code}' https://api.telegram.org 2>>"$LOG_FILE")
    [[ $code =~ ^[1-5][0-9][0-9]$ && $code != 000 ]] \
        || die "Cannot reach api.telegram.org. Telegram is blocked from this server - use a server outside the filtered network."
    msg_ok "Network: GitHub and Telegram are reachable"
}

detect_public_ip() {
    [[ -n $SERVER_IP ]] && return 0
    local url ip
    for url in https://api.ipify.org https://ipv4.icanhazip.com https://checkip.amazonaws.com https://ifconfig.me/ip; do
        ip=$(curl -4fsS --max-time 6 "$url" 2>/dev/null | tr -d '[:space:]')
        if valid_ipv4 "$ip"; then SERVER_IP=$ip; break; fi
    done
    if [[ -z $SERVER_IP ]]; then
        ip=$(ip -4 route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="src"){print $(i+1); exit}}')
        valid_ipv4 "$ip" && SERVER_IP=$ip
    fi
    [[ -n $SERVER_IP ]] || die "Could not detect this server's public IPv4 address (IPv6-only servers are not supported)."
    if is_private_ipv4 "$SERVER_IP"; then
        die "This server only has a private IP ($SERVER_IP). A public IPv4 address is required so Telegram can reach the bot."
    fi
    if ! ip -4 -o addr show 2>/dev/null | grep -qw "$SERVER_IP"; then
        msg_warn "Public IP $SERVER_IP is NAT-ed (normal on some clouds). Make sure ports 80 and 443 are open in the provider firewall."
    fi
}

port_owner() { ss -H -ltnp "sport = :$1" 2>/dev/null | sed -n 's/.*users:(("\([^"]*\)".*/\1/p' | head -n1; }
check_ports() {
    local p owner
    for p in 80 443; do
        owner=$(port_owner "$p")
        if [[ -n $owner && $owner != apache2 ]]; then
            die "Port $p is already used by '$owner'. Stop/remove it first (e.g. systemctl disable --now $owner) and run the installer again."
        fi
    done
    msg_ok "Ports 80 and 443 are free for the bot"
}

check_clock() {
    local sync; sync=$(timedatectl show -p NTPSynchronized --value 2>/dev/null)
    if [[ $sync == no ]]; then
        msg_warn "System clock is not synchronised - enabling NTP (needed for valid SSL certificates)."
        timedatectl set-ntp true >>"$LOG_FILE" 2>&1 || true
    fi
}

ensure_swap() {
    local mem_kb; mem_kb=$(awk '/MemTotal/{print $2}' /proc/meminfo)
    [[ $mem_kb -lt 1500000 ]] || return 0
    [[ -z "$(swapon --show --noheadings 2>/dev/null)" ]] || return 0
    local size=2048 free_mb; free_mb=$(df -Pm / | awk 'NR==2{print $4}')
    [[ $free_mb -gt 6000 ]] || size=1024
    [[ -e /swapfile ]] && return 0
    { fallocate -l "${size}M" /swapfile || dd if=/dev/zero of=/swapfile bs=1M count="$size"; } \
        && chmod 600 /swapfile && mkswap /swapfile && swapon /swapfile \
        && { grep -q '^/swapfile' /etc/fstab || echo '/swapfile none swap sw 0 0' >>/etc/fstab; }
}

# =============================================================================
#  Packages
# =============================================================================
apt_update()  { retry 3 5 apt-get update -o DPkg::Lock::Timeout=300 -o Acquire::Retries=3; }
apt_install() { retry 3 8 apt-get install -y -o DPkg::Lock::Timeout=300 -o Acquire::Retries=3 -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold "$@"; }

install_base_tools() {
    apt_update || return 1
    apt_install ca-certificates curl wget gnupg lsb-release openssl jq unzip tar cron iproute2 procps util-linux \
        python3 python3-venv python3-pip logrotate
}

php_candidate_ok() {
    local cand; cand=$(pkg_candidate "php${PHP_TARGET}-cli")
    [[ -n $cand && $cand != "(none)" ]] || return 1
    [[ -n "$(pkg_candidate "libapache2-mod-php${PHP_TARGET}")" && "$(pkg_candidate "libapache2-mod-php${PHP_TARGET}")" != "(none)" ]] || return 1
    dpkg --compare-versions "${cand#*:}" ge "$PHP_MIN"
}

ppa_has_series() { curl -fsSL --max-time 15 -o /dev/null "https://ppa.launchpadcontent.net/ondrej/php/ubuntu/dists/$1/Release" 2>/dev/null; }

add_php_repo() {
    detect_os
    if [[ $OS_ID == ubuntu ]]; then
        have add-apt-repository || apt_install software-properties-common || return 1
        if ! ppa_has_series "$OS_CODENAME"; then
            echo "ondrej/php has no packages for '$OS_CODENAME'; relying on the distribution PHP."
            return 0
        fi
        LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php || return 1
    else
        curl -fsSL -o /tmp/debsuryorg-archive-keyring.deb https://packages.sury.org/debsuryorg-archive-keyring.deb || return 1
        dpkg -i /tmp/debsuryorg-archive-keyring.deb || return 1
        rm -f /tmp/debsuryorg-archive-keyring.deb
        echo "deb [signed-by=/usr/share/keyrings/debsuryorg-archive-keyring.gpg] https://packages.sury.org/php/ ${OS_CODENAME} main" \
            >/etc/apt/sources.list.d/php-sury.list
    fi
    apt_update
}

PHP_REQUIRED_EXT=(curl pdo pdo_mysql mbstring json openssl gd zip dom simplexml xml xmlwriter xmlreader fileinfo iconv ctype filter zlib session)

install_php() {
    if ! php_candidate_ok; then add_php_repo || return 1; fi
    php_candidate_ok || { echo "PHP ${PHP_MIN}+ is not available from the package sources on $OS_PRETTY (candidate: $(pkg_candidate "php${PHP_TARGET}-cli"))."; return 1; }
    local v=$PHP_TARGET
    apt_install "php${v}-cli" "php${v}-common" "libapache2-mod-php${v}" "php${v}-mysql" "php${v}-mbstring" "php${v}-zip" \
        "php${v}-gd" "php${v}-curl" "php${v}-intl" "php${v}-xml" "php${v}-bcmath" || return 1
    apt_install "php${v}-soap" >/dev/null 2>&1 || true
    local e missing=()
    for e in "${PHP_REQUIRED_EXT[@]}"; do "$PHP_BIN" -m 2>/dev/null | tr 'A-Z' 'a-z' | grep -qx "$e" || missing+=("$e"); done
    if ((${#missing[@]})); then echo "Missing PHP extensions: ${missing[*]}"; return 1; fi
    PHP_MIN_VER=$PHP_MIN "$PHP_BIN" -r 'exit(version_compare(PHP_VERSION, getenv("PHP_MIN_VER"), ">=") ? 0 : 1);' || { echo "Installed PHP is older than $PHP_MIN"; return 1; }
    update-alternatives --set php "$PHP_BIN" >/dev/null 2>&1 || true
}

write_php_ini() {
    local sapi f
    for sapi in apache2 cli; do
        [[ -d /etc/php/$PHP_TARGET/$sapi/conf.d ]] || continue
        f=/etc/php/$PHP_TARGET/$sapi/conf.d/99-mirzabot.ini
        cat >"$f" <<'EOF'
; Managed by the Mirza Bot easy installer
expose_php = Off
memory_limit = 512M
max_execution_time = 120
upload_max_filesize = 64M
post_max_size = 64M
opcache.enable = 1
opcache.validate_timestamps = 1
opcache.revalidate_freq = 10
EOF
    done
}

install_webstack() {
    apt_install apache2 || return 1
    if ! pkg_installed mysql-server && ! pkg_installed mariadb-server && ! pkg_installed mysql-community-server; then
        local c; c=$(pkg_candidate mysql-server)
        if [[ -n $c && $c != "(none)" ]]; then apt_install mysql-server || return 1
        else apt_install mariadb-server || return 1; fi
    fi
    local m
    for m in /etc/apache2/mods-enabled/php*.load; do
        [[ -e $m ]] || continue
        [[ $m == *"php${PHP_TARGET}.load" ]] || a2dismod "$(basename "$m" .load)" >/dev/null 2>&1 || true
    done
    a2dismod -f mpm_event mpm_worker >/dev/null 2>&1 || true
    a2enmod mpm_prefork "php${PHP_TARGET}" rewrite ssl headers >/dev/null || return 1
    write_php_ini
    cat >/etc/apache2/conf-available/mirzabot-security.conf <<'EOF'
# Managed by the Mirza Bot easy installer
ServerTokens Prod
ServerSignature Off
TraceEnable Off
EOF
    a2enconf mirzabot-security >/dev/null
    systemctl enable --now apache2 >/dev/null 2>&1
    db_service_enable
    systemctl restart apache2
}

db_service() {
    local s; for s in mysql mariadb; do systemctl cat "$s.service" >/dev/null 2>&1 && { echo "$s"; return; }; done
    echo mysql
}
db_service_enable() { local s; s=$(db_service); systemctl enable --now "$s" >/dev/null 2>&1; systemctl is-active --quiet "$s"; }

ensure_composer() {
    [[ -x $COMPOSER_BIN ]] && "$PHP_BIN" "$COMPOSER_BIN" --version >/dev/null 2>&1 && return 0
    local tmp; tmp=$(mktemp); local exp act
    if curl -fsSL --retry 3 -o "$tmp" https://getcomposer.org/download/latest-stable/composer.phar \
        && exp=$(curl -fsSL --retry 3 https://getcomposer.org/download/latest-stable/composer.phar.sha256sum | awk '{print $1}') \
        && act=$(sha256sum "$tmp" | awk '{print $1}') && [[ -n $exp && $exp == "$act" ]]; then
        :
    else
        echo "getcomposer.org unavailable or checksum mismatch - using the GitHub release instead."
        curl -fsSL --retry 3 -o "$tmp" https://github.com/composer/composer/releases/latest/download/composer.phar || { rm -f "$tmp"; return 1; }
    fi
    install -m 0755 "$tmp" "$COMPOSER_BIN"; rm -f "$tmp"
    "$PHP_BIN" "$COMPOSER_BIN" --version
}

composer_install() {
    local dir=$1
    ( cd "$dir" && COMPOSER_ALLOW_SUPERUSER=1 COMPOSER_HOME=/root/.composer COMPOSER_NO_INTERACTION=1 \
        retry 2 5 "$PHP_BIN" -d memory_limit=-1 "$COMPOSER_BIN" install --no-dev --prefer-dist --no-progress --optimize-autoloader ) || return 1
    [[ -f $dir/vendor/autoload.php ]]
}

# =============================================================================
#  Source code download
# =============================================================================
github_curl() {
    if [[ -n ${GITHUB_TOKEN:-} ]]; then curl -H "Authorization: Bearer $GITHUB_TOKEN" "$@"; else curl "$@"; fi
}

latest_sha() {
    github_curl -fsS --max-time 10 -H 'Accept: application/vnd.github.sha' "https://api.github.com/repos/${REPO}/commits/${OPT_TAG:-$BRANCH}" 2>/dev/null | tr -d '[:space:]'
}

prepare_tmp() { TMP_WORK=$(mktemp -d /tmp/mirzabot.XXXXXX); }
locate_src() { SRC_DIR=$(find "$TMP_WORK/src" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | head -n1); }

# NOTE: runs inside run_step (a subshell) - call prepare_tmp first and locate_src afterwards.
download_source() {
    local ref url
    if [[ -n $OPT_TAG ]]; then ref="refs/tags/$OPT_TAG"; else ref="refs/heads/$BRANCH"; fi
    if [[ -n ${GITHUB_TOKEN:-} ]]; then url="https://api.github.com/repos/${REPO}/tarball/${ref#refs/*/}"
    else url="https://codeload.github.com/${REPO}/tar.gz/${ref}"; fi
    github_curl -fSL --retry 3 --retry-delay 3 --connect-timeout 15 -o "$TMP_WORK/src.tar.gz" "$url" || return 1
    mkdir -p "$TMP_WORK/src" && tar -xzf "$TMP_WORK/src.tar.gz" -C "$TMP_WORK/src" || return 1
    locate_src
    [[ -n $SRC_DIR && -f $SRC_DIR/table.php && -f $SRC_DIR/index.php && -f $SRC_DIR/composer.json ]] \
        || { echo "Downloaded archive does not look like Mirza Bot"; return 1; }
    # The web installer blocks every request while it exists (see .htaccess) - the CLI installer replaces it.
    rm -rf "$SRC_DIR/install" "$SRC_DIR/.git" "$SRC_DIR/.github"
    echo "Downloaded $ref ($(du -sh "$SRC_DIR" | cut -f1))"
}

fix_permissions() {
    chown -R www-data:www-data "$APP_DIR"
    chmod -R u=rwX,go=rX "$APP_DIR"
    [[ -f $APP_DIR/config.php ]] && chmod 640 "$APP_DIR/config.php"
    return 0
}

# =============================================================================
#  Database
# =============================================================================
mysql_root()      { if [[ -n $DB_ROOT_PASS ]]; then MYSQL_PWD="$DB_ROOT_PASS" mysql -uroot "$@"; else mysql -uroot "$@"; fi; }
mysqldump_root()  { if [[ -n $DB_ROOT_PASS ]]; then MYSQL_PWD="$DB_ROOT_PASS" mysqldump -uroot "$@"; else mysqldump -uroot "$@"; fi; }
mysql_root_ok()   { mysql_root -e 'SELECT 1' >/dev/null 2>&1; }

ensure_db_root_access() {
    mysql_root_ok && return 0
    msg_warn "Cannot log in to the database server as root automatically."
    if [[ $HAVE_TTY -eq 1 ]]; then
        printf '  %s?%s Database root password (input hidden): ' "$C_Y" "$C_N" >&2
        IFS= read -rs DB_ROOT_PASS <"$TTY_DEV" || DB_ROOT_PASS=""; printf '\n' >&2
        mysql_root_ok && return 0
    fi
    die "Database root login failed. Re-run with MIRZA_DB_ROOT_PASS='your-root-password' set."
}

gen_db_credentials() {
    [[ -n $DB_NAME && -n $DB_USER && -n $DB_PASS ]] && return 0
    DB_NAME="mirza_$(rand_hex 6)"; DB_USER="mirza_$(rand_hex 6)"; DB_PASS="$(rand_hex 32)"
}

create_database() {
    mysql_root <<SQL
CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
ALTER USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
SQL
}

# =============================================================================
#  Telegram
# =============================================================================
# tg_call METHOD [curl args...]  - the token is passed through stdin so it never shows up in `ps`.
tg_call() {
    local method=$1; shift
    printf 'url = "https://api.telegram.org/bot%s/%s"\n' "$TOKEN" "$method" | curl -sS --max-time 25 --config - "$@"
}

validate_token_online() {
    local out ok
    out=$(tg_call getMe 2>>"$LOG_FILE") || return 1
    ok=$(jq -r '.ok // false' <<<"$out" 2>/dev/null)
    [[ $ok == true ]] || return 1
    BOT_USERNAME=$(jq -r '.result.username // empty' <<<"$out")
    return 0
}

webhook_info() { tg_call getWebhookInfo 2>/dev/null; }

# =============================================================================
#  Web server + SSL
# =============================================================================
resolve_ipv4() { getent ahostsv4 "$1" 2>/dev/null | awk '{print $1}' | sort -u; }

host_for_kind() {
    case "$1" in
        ip)    echo "$SERVER_IP" ;;
        sslip) echo "${SERVER_IP//./-}.sslip.io" ;;
        nip)   echo "${SERVER_IP//./-}.nip.io" ;;
        domain) echo "$OPT_DOMAIN" ;;
    esac
}

vhost_body() {  # vhost_body http|https
    local mode=$1
    cat <<EOF
    ServerName ${HOST}
    DocumentRoot ${APP_DIR}
    ServerAdmin webmaster@localhost
    ErrorLog \${APACHE_LOG_DIR}/mirzabot-error.log
    CustomLog \${APACHE_LOG_DIR}/mirzabot-access.log combined

    # Let's Encrypt HTTP-01 challenge + TLS self-test used by the installer
    Alias /.well-known/acme-challenge/ ${ACME_WEBROOT}/.well-known/acme-challenge/
    Alias /.well-known/mirzabot-probe ${ACME_WEBROOT}/probe
    <Directory "${ACME_WEBROOT}">
        Options None
        AllowOverride None
        Require all granted
    </Directory>

    <Directory "${APP_DIR}">
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    <DirectoryMatch "^${APP_DIR}/(vendor|\.git)(/|\$)">
        Require all denied
    </DirectoryMatch>
EOF
    if [[ $mode == http ]]; then
        if [[ $2 == redirect ]]; then cat <<EOF

    RewriteEngine On
    RewriteCond %{REQUEST_URI} !^/\.well-known/(acme-challenge/|mirzabot-probe)
    RewriteRule ^ https://${HOST}%{REQUEST_URI} [R=301,L]
EOF
        fi
    else
        cat <<EOF

    SSLEngine on
    SSLCertificateFile ${CERT_DIR}/fullchain.pem
    SSLCertificateKeyFile ${CERT_DIR}/privkey.pem
    SSLProtocol -all +TLSv1.2 +TLSv1.3
    SSLSessionTickets off
    Header always set X-Content-Type-Options "nosniff"
    Header always set Referrer-Policy "strict-origin-when-cross-origin"
EOF
        [[ $CERT_MODE == domain ]] && echo '    Header always set Strict-Transport-Security "max-age=31536000"'
    fi
}

write_vhosts() {  # write_vhosts http-only|full
    local mode=$1
    mkdir -p "$ACME_WEBROOT/.well-known/acme-challenge"
    echo ok >"$ACME_WEBROOT/probe"
    chmod -R 755 "$ACME_WEBROOT"
    {
        echo "# Managed by the Mirza Bot easy installer - do not edit (changes are overwritten)"
        echo "<VirtualHost *:80>"
        if [[ $mode == full ]]; then vhost_body http redirect; else vhost_body http plain; fi
        echo "</VirtualHost>"
    } >"/etc/apache2/sites-available/${VHOST_HTTP}.conf"
    if [[ $mode == full ]]; then
        {
            echo "# Managed by the Mirza Bot easy installer - do not edit (changes are overwritten)"
            echo "<VirtualHost *:443>"
            vhost_body https
            echo "</VirtualHost>"
        } >"/etc/apache2/sites-available/${VHOST_HTTPS}.conf"
    fi
    # Disable Apache's stock sites the first time, remember so we can restore them on removal.
    local s
    for s in 000-default default-ssl; do
        if [[ -e /etc/apache2/sites-enabled/$s.conf ]]; then
            a2dissite "$s" >/dev/null 2>&1 && conf_set "DISABLED_$(echo "$s" | tr -c 'A-Za-z0-9\n' '_')" 1
        fi
    done
    a2ensite "$VHOST_HTTP" >/dev/null
    if [[ $mode == full ]]; then a2ensite "$VHOST_HTTPS" >/dev/null; else a2dissite "$VHOST_HTTPS" >/dev/null 2>&1 || true; fi
    apache_reload
}

apache_reload() {
    if ! apachectl configtest >>"$LOG_FILE" 2>&1; then
        apachectl configtest 2>&1 | tail -n 5 | sed 's/^/      | /' >&2
        return 1
    fi
    systemctl reload apache2 >>"$LOG_FILE" 2>&1 || systemctl restart apache2 >>"$LOG_FILE" 2>&1
}

# --- certbot -------------------------------------------------------------------
CERTBOT=""
certbot_version() { "$CERTBOT" --version 2>/dev/null | awk '{print $2}'; }
certbot_supports_ip() { [[ -n $CERTBOT ]] && dpkg --compare-versions "$(certbot_version)" ge 5.4; }

install_certbot() {
    if [[ -x $CERTBOT_VENV/bin/certbot ]]; then CERTBOT="$CERTBOT_VENV/bin/certbot"; return 0; fi
    # Let's Encrypt IP-address certificates need certbot >= 5.4, newer than any distro package.
    if python3 -m venv "$CERTBOT_VENV" \
        && "$CERTBOT_VENV/bin/pip" install --disable-pip-version-check -q -U pip \
        && "$CERTBOT_VENV/bin/pip" install --disable-pip-version-check -q 'certbot>=5.4'; then
        CERTBOT="$CERTBOT_VENV/bin/certbot"; return 0
    fi
    echo "Could not install the latest certbot with pip - falling back to the distribution package."
    rm -rf "$CERTBOT_VENV"
    apt_install certbot || return 1
    CERTBOT=$(command -v certbot)
}

cert_covers() {  # cert_covers HOST -> certificate exists, is valid >1 day and names HOST
    local f=$CERT_DIR/fullchain.pem
    [[ -f $f ]] || return 1
    openssl x509 -in "$f" -noout -checkend 86400 >/dev/null 2>&1 || return 1
    local san; san=$(openssl x509 -in "$f" -noout -text 2>/dev/null | grep -A1 'Subject Alternative Name')
    if valid_ipv4 "$1"; then grep -q "IP Address:$1\b" <<<"$san"; else grep -q "DNS:$1\b" <<<"$san"; fi
}

issue_certificate() {  # issue_certificate KIND
    local kind=$1 args=()
    cert_covers "$HOST" && { echo "A valid certificate for $HOST already exists - reusing it."; return 0; }
    [[ -d /etc/letsencrypt/live/$CERT_NAME ]] && "$CERTBOT" delete --cert-name "$CERT_NAME" --non-interactive >/dev/null 2>&1
    args=(certonly --webroot -w "$ACME_WEBROOT" --cert-name "$CERT_NAME" --non-interactive --agree-tos --keep-until-expiring)
    if [[ -n $OPT_EMAIL ]]; then args+=(-m "$OPT_EMAIL"); else args+=(--register-unsafely-without-email); fi
    if [[ $kind == ip ]]; then args+=(--ip-address "$HOST" --required-profile shortlived)
    else args+=(-d "$HOST"); fi
    "$CERTBOT" "${args[@]}" && cert_covers "$HOST"
}

install_renewal() {
    mkdir -p /etc/letsencrypt/renewal-hooks/deploy
    cat >/etc/letsencrypt/renewal-hooks/deploy/mirzabot-reload.sh <<'EOF'
#!/bin/sh
# Managed by the Mirza Bot easy installer
systemctl reload apache2 >/dev/null 2>&1 || systemctl restart apache2
EOF
    chmod +x /etc/letsencrypt/renewal-hooks/deploy/mirzabot-reload.sh
    cat >/etc/systemd/system/mirzabot-cert-renew.service <<EOF
[Unit]
Description=Renew the Mirza Bot SSL certificate
After=network-online.target

[Service]
Type=oneshot
ExecStart=${CERTBOT} renew --quiet --cert-name ${CERT_NAME}
EOF
    cat >/etc/systemd/system/mirzabot-cert-renew.timer <<'EOF'
[Unit]
Description=Check Mirza Bot SSL certificate every 6 hours

[Timer]
OnCalendar=*-*-* 00/6:17:00
RandomizedDelaySec=900
Persistent=true

[Install]
WantedBy=timers.target
EOF
    systemctl daemon-reload
    systemctl enable --now mirzabot-cert-renew.timer >/dev/null 2>&1
}

# Ask Telegram to connect to a static file over HTTPS: proves DNS + port 443 + certificate chain.
probe_telegram_tls() {
    local out desc
    out=$(tg_call setWebhook -d "url=https://${HOST}/.well-known/mirzabot-probe" 2>>"$LOG_FILE") || { log "probe: curl failed"; return 1; }
    [[ $(jq -r '.ok // false' <<<"$out" 2>/dev/null) == true ]] && return 0
    desc=$(jq -r '.description // empty' <<<"$out" 2>/dev/null)
    log "probe: $desc"
    if grep -Eqi 'ssl|certificate|resolve|connect|timed out|handshake|verify' <<<"$desc"; then
        msg_warn "Telegram could not connect securely: ${desc}"
        return 1
    fi
    return 0   # any other answer means the TLS handshake itself worked
}

# Gets HTTPS working. Auto mode tries: IP certificate -> sslip.io -> nip.io. Domain mode uses the given domain.
setup_access() {
    local kinds=() kind
    if [[ -n $OPT_CERT_MODE ]]; then kinds=("$OPT_CERT_MODE")
    elif [[ $ACCESS_MODE == domain ]]; then kinds=(domain)
    else kinds=(ip sslip nip); fi
    install_certbot_step || return 1
    for kind in "${kinds[@]}"; do
        HOST=$(host_for_kind "$kind"); CERT_MODE=$kind
        [[ -n $HOST ]] || continue
        case "$kind" in
            ip)  if ! certbot_supports_ip; then msg_warn "certbot is too old for IP certificates - skipping."; continue; fi
                 msg_info "Trying a free Let's Encrypt certificate for the IP address ($HOST)" ;;
            sslip|nip)
                 msg_info "Trying the free hostname $HOST"
                 if ! resolve_ipv4 "$HOST" | grep -qx "$SERVER_IP"; then msg_warn "$HOST does not resolve to $SERVER_IP - skipping."; continue; fi ;;
            domain) msg_info "Requesting a certificate for $HOST" ;;
        esac
        write_vhosts http-only || { msg_err "Apache refused the HTTP virtual host."; return 1; }
        if ! run_step "Requesting SSL certificate for $HOST" issue_certificate "$kind"; then
            [[ $kind == domain ]] && return 1
            continue
        fi
        write_vhosts full || { msg_err "Apache refused the HTTPS virtual host."; return 1; }
        if probe_telegram_tls; then
            msg_ok "Telegram can reach https://$HOST"
            conf_set HOST "$HOST"; conf_set CERT_MODE "$CERT_MODE"; conf_set ACCESS_MODE "$ACCESS_MODE"
            install_renewal
            return 0
        fi
        msg_warn "Telegram rejected the connection for $HOST."
        [[ $kind == domain ]] && return 1
    done
    return 1
}
locate_certbot() { CERTBOT=""; if [[ -x $CERTBOT_VENV/bin/certbot ]]; then CERTBOT="$CERTBOT_VENV/bin/certbot"; else CERTBOT=$(command -v certbot || true); fi; [[ -n $CERTBOT ]]; }
install_certbot_step() {
    locate_certbot && return 0
    run_step "Installing certbot (Let's Encrypt client)" install_certbot || return 1
    locate_certbot
}

explain_access_failure() {
    cat >&2 <<EOF

  ${C_R}HTTPS could not be set up.${C_N} Most common causes:
    1) Ports 80 and 443 are blocked - open them in the provider's firewall/security group.
    2) Let's Encrypt rate limits (shared sslip.io / nip.io names are busy at times) - retry in an hour,
       or use your own domain:  mirzabot install --domain bot.example.com
    3) The domain does not point to this server (A record -> ${SERVER_IP}).
  Details: ${LOG_FILE}
EOF
}

# =============================================================================
#  Config, cron, firewall
# =============================================================================
render_config() {
    local tpl=$SRC_DIR/config.php dest=$APP_DIR/config.php
    [[ -f $tpl ]] && grep -q '{API_KEY}' "$tpl" || { echo "config.php template not found in the source"; return 1; }
    sed -e "s|{database_url}|localhost|" -e "s|{database_name}|$DB_NAME|" -e "s|{username_db}|$DB_USER|" \
        -e "s|{password_db}|$DB_PASS|" -e "s|{API_KEY}|$TOKEN|" -e "s|{admin_number}|$ADMIN_ID|" \
        -e "s|{domain_name}|$HOST|" -e "s|{username_bot}|$BOT_USERNAME|" "$tpl" >"$dest.new" || return 1
    if grep -Eq '\{(database_url|database_name|username_db|password_db|API_KEY|admin_number|domain_name|username_bot)\}' "$dest.new"; then rm -f "$dest.new"; echo "Unreplaced placeholders left in config.php"; return 1; fi
    "$PHP_BIN" -l "$dest.new" >/dev/null || { rm -f "$dest.new"; echo "Generated config.php has a syntax error"; return 1; }
    mv -f "$dest.new" "$dest"
    chown www-data:www-data "$dest"; chmod 640 "$dest"
}

run_as_www() { ( cd "$APP_DIR" && runuser -u www-data -- "$@" ); }

init_tables() { ( cd "$APP_DIR" && timeout 600 runuser -u www-data -- "$PHP_BIN" table.php ); }

install_cron() {
    local line cb=/usr/bin/crontab cur
    [[ -x $cb ]] || cb=$(command -v crontab) || return 1
    line=$(run_as_www "$PHP_BIN" -r 'require "'"$APP_DIR"'/cronbot/jobs.php"; echo mirza_cron_dispatcher_command($argv[1]);' "$HOST" 2>/dev/null)
    [[ $line == '* * * * *'* ]] || line="* * * * * $PHP_BIN $APP_DIR/cronbot/run.php >/dev/null 2>&1"
    [[ -f /etc/cron.allow ]] && ! grep -qx www-data /etc/cron.allow && echo www-data >>/etc/cron.allow
    [[ -f /etc/cron.deny ]] && sed -i '/^www-data$/d' /etc/cron.deny
    cur=$("$cb" -u www-data -l 2>/dev/null | grep -vF "/cronbot/" || true)
    { [[ -n $cur ]] && printf '%s\n' "$cur"; printf '%s\n' "$line"; } | "$cb" -u www-data - || return 1
    systemctl enable --now cron >/dev/null 2>&1 || systemctl enable --now crond >/dev/null 2>&1 || true
    "$cb" -u www-data -l 2>/dev/null | grep -qF "cronbot/run.php"
}

remove_cron() {
    local cb; cb=$(command -v crontab) || return 0
    local u cur
    for u in www-data root; do
        cur=$("$cb" -u "$u" -l 2>/dev/null) || continue
        grep -qF "/cronbot/" <<<"$cur" || continue
        grep -vF "/cronbot/" <<<"$cur" | "$cb" -u "$u" - 2>/dev/null || "$cb" -u "$u" -r 2>/dev/null || true
    done
}

setup_firewall() {
    have ufw || return 0
    ufw status 2>/dev/null | grep -q '^Status: active' || return 0
    ufw allow 80/tcp >/dev/null && ufw allow 443/tcp >/dev/null
}

install_self() {
    local src=""
    if [[ -n $SRC_DIR && -f $SRC_DIR/easy-install.sh ]]; then src=$SRC_DIR/easy-install.sh
    elif [[ -f ${BASH_SOURCE[0]:-} && ${BASH_SOURCE[0]} != /dev/fd/* ]]; then src=${BASH_SOURCE[0]}; fi
    if [[ -z $src ]]; then
        src=$(mktemp); curl -fsSL --max-time 30 -o "$src" "$(self_url)" || { rm -f "$src"; return 1; }
    fi
    bash -n "$src" && grep -q 'MIRZA_EASY_INSTALLER' "$src" || return 1
    [[ $(readlink -f "$src") == "$(readlink -f "$BIN_PATH" 2>/dev/null)" ]] || install -m 0755 "$src" "$BIN_PATH"
}

setup_logrotate() {
    cat >/etc/logrotate.d/mirzabot <<EOF
${LOG_FILE} {
    monthly
    rotate 3
    compress
    missingok
    notifempty
}
EOF
}

# =============================================================================
#  Health / summary helpers
# =============================================================================
local_https_code() { curl -ksS --max-time 15 -o /dev/null -w '%{http_code}' -H "Host: ${HOST}" "https://127.0.0.1/" 2>/dev/null; }

health_check() {
    local code; code=$(local_https_code)
    if [[ $code =~ ^[1-4][0-9][0-9]$ ]]; then msg_ok "Web server answers over HTTPS (HTTP $code)"; return 0; fi
    msg_err "Web server did not answer correctly over HTTPS (got '${code:-none}'). See: tail -n 50 /var/log/apache2/mirzabot-error.log"
    return 1
}

verify_webhook() {
    local info url err cnt
    info=$(webhook_info) || return 1
    url=$(jq -r '.result.url // empty' <<<"$info")
    err=$(jq -r '.result.last_error_message // empty' <<<"$info")
    cnt=$(jq -r '.result.pending_update_count // 0' <<<"$info")
    if [[ $url == "https://${HOST}/"* ]]; then
        msg_ok "Webhook is set: https://${HOST}/index.php?secret=***"
        [[ -n $err ]] && msg_warn "Telegram reported: $err ($cnt pending updates)"
        return 0
    fi
    msg_warn "Webhook URL is '${url:-empty}' - repairing"
    return 1
}

cert_days_left() {
    [[ -f $CERT_DIR/fullchain.pem ]] || { echo "-"; return; }
    local end; end=$(openssl x509 -in "$CERT_DIR/fullchain.pem" -noout -enddate 2>/dev/null | cut -d= -f2)
    [[ -n $end ]] || { echo "-"; return; }
    echo $((($(date -d "$end" +%s) - $(date +%s)) / 86400))
}

# =============================================================================
#  Backup / restore
# =============================================================================
BACKUP_PATH=""
backup_prepare() {  # backup_prepare LABEL -> sets BACKUP_PATH (call in the main shell, then run_step do_backup)
    BACKUP_PATH="$BACKUP_DIR/${1:-manual}-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_PATH"; chmod 700 "$BACKUP_DIR" "$BACKUP_PATH"
}

do_backup() {
    local dir=$BACKUP_PATH
    mysqldump_root --single-transaction --routines --triggers --default-character-set=utf8mb4 "$DB_NAME" 2>>"$LOG_FILE" | gzip -9 >"$dir/database.sql.gz"
    [[ ${PIPESTATUS[0]} -eq 0 && -s $dir/database.sql.gz ]] || { echo "Database dump failed"; return 1; }
    [[ -f $APP_DIR/config.php ]] && cp -a "$APP_DIR/config.php" "$dir/config.php"
    tar -czf "$dir/app-files.tar.gz" -C "$(dirname "$APP_DIR")" "$(basename "$APP_DIR")" 2>>"$LOG_FILE" || { echo "Archiving files failed"; return 1; }
    [[ -f $CONF_FILE ]] && cp -a "$CONF_FILE" "$dir/installer.conf"
    printf 'created=%s\nbot_version=%s\nhost=%s\n' "$(date -Is)" "$(cat "$APP_DIR/version" 2>/dev/null)" "$HOST" >"$dir/info.txt"
    chmod -R go-rwx "$dir"
}

prune_backups() {
    local keep=$1 prefix=$2
    # shellcheck disable=SC2012
    ls -1dt "$BACKUP_DIR/${prefix}"-* 2>/dev/null | tail -n +$((keep + 1)) | xargs -r rm -rf
}

list_backups() { ls -1dt "$BACKUP_DIR"/*/ 2>/dev/null | sed 's:/$::'; }

restore_database_file() {
    local f=$1
    [[ -f $f ]] || { echo "File not found: $f"; return 1; }
    mysql_root -e "DROP DATABASE IF EXISTS \`$DB_NAME\`; CREATE DATABASE \`$DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" || return 1
    if [[ $f == *.gz ]]; then gunzip -c "$f" | mysql_root --default-character-set=utf8mb4 "$DB_NAME"
    else mysql_root --default-character-set=utf8mb4 "$DB_NAME" <"$f"; fi
}

# =============================================================================
#  Commands: install
# =============================================================================
collect_install_info() {
    printf '\n  %sWe need two things from you: the bot token and your numeric Telegram ID.%s\n' "$C_D" "$C_N"
    printf '  %sToken: create a bot with @BotFather -> /newbot. ID: send /start to @userinfobot.%s\n\n' "$C_D" "$C_N"

    TOKEN=${OPT_TOKEN:-$TOKEN}
    while true; do
        [[ -z $TOKEN ]] && { [[ $HAVE_TTY -eq 1 ]] && ask TOKEN "Telegram bot token (from @BotFather)" || die "Missing --token."; }
        if ! valid_token "$TOKEN"; then msg_err "That does not look like a bot token (expected 123456789:AA...)."; TOKEN=""; OPT_TOKEN=""; [[ $HAVE_TTY -eq 1 ]] || exit 1; continue; fi
        if validate_token_online; then msg_ok "Token accepted - bot is @${BOT_USERNAME}"; break; fi
        msg_err "Telegram rejected this token (revoked or mistyped)."
        TOKEN=""; OPT_TOKEN=""; [[ $HAVE_TTY -eq 1 ]] || exit 1
    done

    ADMIN_ID=${OPT_ADMIN:-$ADMIN_ID}
    while true; do
        [[ -z $ADMIN_ID ]] && { [[ $HAVE_TTY -eq 1 ]] && ask ADMIN_ID "Your numeric Telegram ID (admin)" || die "Missing --admin."; }
        valid_admin "$ADMIN_ID" && break
        msg_err "The admin ID must be a number (get it from @userinfobot)."
        ADMIN_ID=""; OPT_ADMIN=""; [[ $HAVE_TTY -eq 1 ]] || exit 1
    done
    msg_ok "Admin ID: $ADMIN_ID"

    detect_public_ip
    if [[ -n $OPT_DOMAIN ]]; then ACCESS_MODE=domain
    elif [[ $OPT_NO_DOMAIN -eq 1 || $HAVE_TTY -eq 0 ]]; then ACCESS_MODE=auto
    else
        printf '\n  How should the bot be reachable?\n'
        printf '    %s1)%s Automatic - no domain needed %s(recommended)%s\n' "$C_W" "$C_N" "$C_G" "$C_N"
        printf '       %sUses a free trusted SSL certificate for %s%s\n' "$C_D" "$SERVER_IP" "$C_N"
        printf '    %s2)%s I have my own domain\n' "$C_W" "$C_N"
        local choice; ask choice "Choose" "1"
        if [[ $choice == 2 ]]; then ACCESS_MODE=domain; else ACCESS_MODE=auto; fi
    fi
    if [[ $ACCESS_MODE == domain ]]; then
        OPT_DOMAIN=$(echo "$OPT_DOMAIN" | tr 'A-Z' 'a-z')
        while true; do
            [[ -z $OPT_DOMAIN ]] && { [[ $HAVE_TTY -eq 1 ]] && ask OPT_DOMAIN "Domain name (e.g. bot.example.com)" || die "Missing --domain."; OPT_DOMAIN=$(echo "$OPT_DOMAIN" | tr 'A-Z' 'a-z'); }
            OPT_DOMAIN=${OPT_DOMAIN#http://}; OPT_DOMAIN=${OPT_DOMAIN#https://}; OPT_DOMAIN=${OPT_DOMAIN%%/*}
            valid_domain "$OPT_DOMAIN" && break
            msg_err "Invalid domain name."; OPT_DOMAIN=""; [[ $HAVE_TTY -eq 1 ]] || exit 1
        done
        if ! resolve_ipv4 "$OPT_DOMAIN" | grep -qx "$SERVER_IP"; then
            msg_warn "$OPT_DOMAIN does not resolve to this server ($SERVER_IP) yet. Create an A record: $OPT_DOMAIN -> $SERVER_IP"
            msg_warn "(Behind Cloudflare's proxy this check fails - that is fine if the record is proxied to this server.)"
            confirm "Continue anyway?" n || die "Aborted. Fix the DNS record and run the installer again."
        else
            msg_ok "Domain $OPT_DOMAIN points to this server"
        fi
    fi
}

cmd_install() {
    need_root; acquire_lock
    load_context
    if is_installed && [[ $FORCE -eq 0 ]]; then
        die "Mirza Bot is already installed. Use 'mirzabot update', or 'mirzabot remove' first."
    fi
    if [[ -d /var/www/html/mirzaprobotconfig && $FORCE -eq 0 ]] && ! is_installed; then
        die "A Mirza Bot installed by the classic install.sh was found in /var/www/html/mirzaprobotconfig. Do not mix both installers: remove it first (bash install.sh -> Remove) or use a clean server."
    fi
    STEP_TOTAL=11; STEP_NO=0
    [[ $APP_DIR == /*/* && $APP_DIR != *[[:space:]]* && $APP_DIR != *..* ]] || die "Unsafe install path: $APP_DIR"
    banner
    step "Checking your server"
    check_os; check_resources; check_clock; check_network; detect_public_ip
    msg_ok "Public IP: $SERVER_IP"
    check_ports

    step "Bot details"
    collect_install_info
    printf '\n'; rule
    msg_kv "Bot" "@${BOT_USERNAME}"; msg_kv "Admin ID" "$ADMIN_ID"
    msg_kv "Address" "$([[ $ACCESS_MODE == domain ]] && echo "$OPT_DOMAIN" || echo "automatic (no domain) - $SERVER_IP")"
    msg_kv "Install path" "$APP_DIR"; msg_kv "Source" "${REPO}@${OPT_TAG:-$BRANCH}"
    rule
    confirm "Start the installation?" y || die "Cancelled."
    : >"$LOG_FILE"; chmod 600 "$LOG_FILE"; log "install started, installer $INSTALLER_VERSION"
    conf_set INSTALL_STATE "in-progress"; conf_set APP_DIR "$APP_DIR"; conf_set REPO "$REPO"
    conf_set BRANCH "$BRANCH"; conf_set PHP_VER "$PHP_TARGET"; conf_set ACCESS_MODE "$ACCESS_MODE"
    local p
    for p in apache2:PRE_APACHE mysql-server:PRE_MYSQL mariadb-server:PRE_MARIADB "php${PHP_TARGET}-cli:PRE_PHP"; do
        conf_has "${p#*:}" || conf_set "${p#*:}" "$(pkg_installed "${p%%:*}" && echo 1 || echo 0)"
    done
    local other_sites="" f
    for f in /etc/apache2/sites-enabled/*.conf; do
        [[ -e $f ]] || continue
        case "$(basename "$f")" in 000-default.conf|default-ssl.conf|000-mirzabot.conf|000-mirzabot-ssl.conf) ;; *) other_sites+="$(basename "$f")"$'\n' ;; esac
    done
    if [[ -n $other_sites ]]; then
        msg_warn "Apache already hosts other sites ($(echo "$other_sites" | tr '\n' ' ')). Mirza's PHP ${PHP_TARGET} will be used by Apache for all of them."
        confirm "Continue?" n || die "Cancelled."
    fi

    step "Preparing the system"
    run_step "Adding swap space (low memory server)" ensure_swap || true
    run_step "Updating package lists and installing base tools" install_base_tools || die "Base tools could not be installed."

    step "Installing PHP ${PHP_TARGET}"
    run_step "Installing PHP ${PHP_TARGET} and the extensions Mirza needs" install_php || die "PHP ${PHP_MIN}+ installation failed."
    msg_ok "PHP $("$PHP_BIN" -r 'echo PHP_VERSION;')"

    step "Installing Apache and the database server"
    run_step "Installing Apache + MySQL" install_webstack || die "Web stack installation failed."
    ensure_db_root_access
    msg_ok "Database server: $(db_service)"

    step "Downloading Mirza Bot"
    prepare_tmp
    run_step "Downloading ${REPO} (${OPT_TAG:-$BRANCH})" download_source || die "Could not download the bot source."
    locate_src
    SRC_SHA=$(latest_sha); conf_set INSTALLED_SHA "$SRC_SHA"
    run_step "Installing Composer" ensure_composer || die "Composer installation failed."
    run_step "Installing PHP libraries (composer install)" composer_install "$SRC_DIR" || die "composer install failed."
    run_step "Copying files to $APP_DIR" bash -c "rm -rf '$APP_DIR' && mkdir -p '$APP_DIR' && cp -a '$SRC_DIR/.' '$APP_DIR/'" || die "Copy failed."
    fix_permissions

    step "Creating the database"
    gen_db_credentials
    conf_set DB_NAME "$DB_NAME"; conf_set DB_USER "$DB_USER"; conf_set DB_PASS "$DB_PASS"
    run_step "Creating database and a dedicated user" create_database || die "Database creation failed."

    step "Setting up HTTPS (no domain needed)"
    if ! setup_access; then explain_access_failure; die "Installation stopped: HTTPS is not working."; fi
    msg_ok "Bot address: https://$HOST"

    step "Configuring the bot"
    run_step "Writing config.php" render_config || die "Could not write config.php."
    run_step "Creating database tables and registering the webhook" init_tables || die "table.php failed - see $LOG_FILE"
    verify_webhook || { init_tables >>"$LOG_FILE" 2>&1; verify_webhook || msg_warn "Webhook not confirmed yet - run 'mirzabot webhook fix' later."; }

    step "Background jobs, firewall and services"
    run_step "Registering cron jobs for the bot" install_cron || msg_warn "Cron registration failed - the bot will try again by itself."
    run_step "Opening ports 80/443 in the firewall (if ufw is active)" setup_firewall || true
    run_step "Installing the 'mirzabot' command" install_self || msg_warn "Could not install the mirzabot command."
    setup_logrotate
    fix_permissions
    conf_set INSTALLED_AT "$(date -Is)"; conf_set INSTALL_STATE "complete"

    step "Final checks"
    health_check || true
    local msg_out
    msg_out=$(tg_call sendMessage -d "chat_id=${ADMIN_ID}" --data-urlencode "text=✅ Mirza Bot is installed and running. Send /start to open the admin panel." 2>/dev/null)
    if [[ $(jq -r '.ok // false' <<<"$msg_out" 2>/dev/null) == true ]]; then msg_ok "Sent a confirmation message to the admin on Telegram"
    else msg_warn "Could not message the admin yet - open @${BOT_USERNAME} and press Start first."; fi
    print_summary
    cleanup
}

print_summary() {
    printf '\n'; rule
    printf '  %s%s Mirza Bot is installed!%s\n' "$C_G" "$SYM_OK" "$C_N"; rule
    msg_kv "Bot" "https://t.me/${BOT_USERNAME}"
    msg_kv "Next step" "Open the bot, press Start, then send /start"
    msg_kv "Address" "https://${HOST}"
    msg_kv "Admin ID" "$ADMIN_ID"
    msg_kv "Bot files" "$APP_DIR"
    msg_kv "Database" "$DB_NAME  (user: $DB_USER)"
    msg_kv "DB password" "$DB_PASS"
    msg_kv "Saved in" "$CONF_FILE (root only)"
    msg_kv "Install log" "$LOG_FILE"
    rule
    printf '  %sManage it any time with:%s\n' "$C_W" "$C_N"
    printf '    %smirzabot%s            interactive menu\n' "$C_C" "$C_N"
    printf '    %smirzabot status%s     health check\n' "$C_C" "$C_N"
    printf '    %smirzabot update%s     update to the latest version\n' "$C_C" "$C_N"
    printf '    %smirzabot backup%s     back up database + files\n' "$C_C" "$C_N"
    printf '    %smirzabot remove%s     uninstall\n' "$C_C" "$C_N"
    if [[ $CERT_MODE == ip ]]; then
        printf '\n  %sNote:%s Let'"'"'s Encrypt IP certificates last ~6 days and renew automatically (timer: mirzabot-cert-renew.timer).\n' "$C_Y" "$C_N"
    fi
    printf '\n'
}

# =============================================================================
#  Commands: update
# =============================================================================
# Replace the program files with SRC_DIR while keeping everything that belongs to the user:
# config.php, storage/, language overrides, every vpnbot instance and error logs.
sync_sources() {
    local stash rel d name f keep=() i
    stash=$(mktemp -d "$(dirname "$APP_DIR")/.mirzabot-stash.XXXXXX") || return 1
    keep=(config.php storage lang/override api/hash.txt cronbot/.run.lock)
    for d in "$APP_DIR"/vpnbot/*/; do
        [[ -d $d ]] || continue; name=$(basename "$d")
        [[ $name == Default || $name == update ]] && continue
        keep+=("vpnbot/$name")
    done
    while IFS= read -r -d '' f; do keep+=("${f#"$APP_DIR"/}"); done < <(find "$APP_DIR" -name error_log -type f -not -path '*/vendor/*' -print0 2>/dev/null)
    local stashed=()
    for rel in "${keep[@]}"; do
        [[ -e $APP_DIR/$rel ]] || continue
        mkdir -p "$stash/$(dirname "$rel")" && mv "$APP_DIR/$rel" "$stash/$rel" || { echo "could not stash $rel"; return 1; }
        stashed+=("$rel")
    done
    find "$APP_DIR" -mindepth 1 -maxdepth 1 -exec rm -rf {} + || return 1
    cp -a "$SRC_DIR/." "$APP_DIR/" || return 1
    for ((i = 0; i < ${#stashed[@]}; i++)); do
        rel=${stashed[i]}
        rm -rf "${APP_DIR:?}/$rel"
        mkdir -p "$APP_DIR/$(dirname "$rel")" && mv "$stash/$rel" "$APP_DIR/$rel" || { echo "could not restore $rel (kept in $stash)"; return 1; }
    done
    rm -rf "$stash"
}

rollback_files() {
    local tarball=$1 parent; parent=$(dirname "$APP_DIR")
    [[ -f $tarball ]] || return 1
    rm -rf "$APP_DIR.failed" && mv "$APP_DIR" "$APP_DIR.failed" \
        && tar -xzf "$tarball" -C "$parent" && rm -rf "$APP_DIR.failed"
}

cmd_update() {
    need_root; acquire_lock; load_context; require_installed
    STEP_TOTAL=7; STEP_NO=0; banner
    : >>"$LOG_FILE"; chmod 600 "$LOG_FILE"
    TOKEN=$(cfg_get APIKEY); ADMIN_ID=$(cfg_get adminnumber)

    step "Checking for a new version"
    check_network
    local local_sha remote_sha cur_ver REMOTE_VER
    local_sha=$(conf_get INSTALLED_SHA); remote_sha=$(latest_sha); cur_ver=$(cat "$APP_DIR/version" 2>/dev/null)
    REMOTE_VER=$(curl -fsS --max-time 8 "https://raw.githubusercontent.com/${REPO}/${OPT_TAG:-$BRANCH}/version" 2>/dev/null | tr -d '[:space:]')
    msg_kv "Installed" "version ${cur_ver:-?}  ${local_sha:0:9}"
    msg_kv "Available" "version ${REMOTE_VER:-?}  ${remote_sha:0:9}"
    if [[ -n $remote_sha && $remote_sha == "$local_sha" && $FORCE -eq 0 ]]; then
        msg_ok "You already have the latest version. (Use --force to reinstall it.)"
        return 0
    fi
    confirm "Update now? A full backup is made first and rolled back automatically on failure." y || die "Cancelled."

    step "Backing up"
    ensure_db_root_access
    backup_prepare update
    run_step "Backing up database and files" do_backup || die "Backup failed - nothing was changed."
    msg_kv "Backup" "$BACKUP_PATH"
    prune_backups "$KEEP_UPDATE_BACKUPS" update

    step "Downloading the new version"
    prepare_tmp
    run_step "Downloading ${REPO} (${OPT_TAG:-$BRANCH})" download_source || die "Download failed - nothing was changed."
    locate_src
    run_step "Preparing Composer" ensure_composer || die "Composer problem - nothing was changed."
    run_step "Installing PHP libraries (composer install)" composer_install "$SRC_DIR" || die "composer install failed - nothing was changed."

    step "Applying the update"
    if ! run_step "Replacing program files (your data is kept)" sync_sources; then
        msg_warn "Update failed - restoring the previous files"
        rollback_files "$BACKUP_PATH/app-files.tar.gz" && msg_ok "Previous files restored" || msg_err "Automatic restore failed. Backup: $BACKUP_PATH"
        die "Update aborted."
    fi
    fix_permissions

    step "Migrating the database"
    if ! run_step "Applying database migrations and refreshing the webhook" init_tables; then
        msg_warn "Migration failed - restoring the previous program files"
        rollback_files "$BACKUP_PATH/app-files.tar.gz" && msg_ok "Previous files restored"
        msg_info "If the bot misbehaves, restore the database too:  mirzabot restore $BACKUP_PATH"
        die "Update aborted."
    fi

    step "Refreshing services"
    run_step "Refreshing PHP settings" write_php_ini || true
    run_step "Refreshing cron jobs" install_cron || msg_warn "Cron registration failed."
    run_step "Reloading Apache" apache_reload || msg_warn "Apache reload failed."
    run_step "Updating the mirzabot command" install_self || true
    [[ -z $OPT_TAG ]] && conf_set BRANCH "$BRANCH"
    conf_set INSTALLED_SHA "${remote_sha:-$local_sha}"; conf_set UPDATED_AT "$(date -Is)"

    step "Final checks"
    health_check || true
    verify_webhook || msg_warn "Run 'mirzabot webhook fix' if the bot does not respond."
    msg_kv "Version" "$(cat "$APP_DIR/version" 2>/dev/null)"
    printf '\n  %s%s Update complete.%s\n\n' "$C_G" "$SYM_OK" "$C_N"
    cleanup
}

# =============================================================================
#  Commands: remove
# =============================================================================
others_dbs() {
    mysql_root -N -e "SHOW DATABASES" 2>/dev/null | grep -vE '^(information_schema|mysql|performance_schema|sys)$' | grep -vx "$DB_NAME" || true
}

cmd_remove() {
    need_root; acquire_lock; load_context
    [[ -f $CONF_FILE || -d $APP_DIR ]] || die "Mirza Bot does not appear to be installed here."
    banner
    printf '  %sThis will remove:%s\n' "$C_W" "$C_N"
    printf '    %s the bot files in %s\n' "$SYM_DOT" "$APP_DIR"
    [[ $KEEP_DB -eq 1 ]] && printf '    %s (database %s is KEPT)\n' "$SYM_DOT" "${DB_NAME:-?}" || printf '    %s the database %s and its user\n' "$SYM_DOT" "${DB_NAME:-?}"
    printf '    %s cron jobs, Apache site, SSL certificate and renewal timer\n' "$SYM_DOT"
    printf '    %s the Telegram webhook (the bot stops answering)\n' "$SYM_DOT"
    [[ $PURGE_STACK -eq 1 ]] && printf '    %s Apache/PHP/MySQL packages that this installer added\n' "$SYM_DOT"
    printf '\n'
    if [[ $ASSUME_YES -eq 0 ]]; then
        [[ $HAVE_TTY -eq 1 ]] || die "Not interactive - pass --yes to confirm removal."
        local word; ask word "Type DELETE to confirm"
        [[ $word == DELETE ]] || die "Cancelled - nothing was removed."
    fi
    : >>"$LOG_FILE"
    TOKEN=$(cfg_get APIKEY)

    if [[ $NO_BACKUP -eq 0 && -d $APP_DIR && -n $DB_NAME ]] && mysql_root_ok; then
        if confirm "Create a final backup before deleting?" y; then
            local keep_dir=$BACKUP_DIR; BACKUP_DIR="/root/mirzabot-final-backup"
            backup_prepare final
            run_step "Creating the final backup" do_backup && msg_kv "Backup saved" "$BACKUP_PATH" || msg_warn "Backup failed."
            BACKUP_DIR=$keep_dir
        fi
    fi

    [[ -n $TOKEN ]] && run_step "Removing the Telegram webhook" tg_call deleteWebhook || true
    run_step "Removing cron jobs" remove_cron || true
    run_step "Removing Apache site" bash -c "
        a2dissite $VHOST_HTTP $VHOST_HTTPS >/dev/null 2>&1; rm -f /etc/apache2/sites-available/$VHOST_HTTP.conf /etc/apache2/sites-available/$VHOST_HTTPS.conf
        a2disconf mirzabot-security >/dev/null 2>&1; rm -f /etc/apache2/conf-available/mirzabot-security.conf
        [ \"$(conf_get DISABLED_000_default)\" = 1 ] && a2ensite 000-default >/dev/null 2>&1
        [ \"$(conf_get DISABLED_default_ssl)\" = 1 ] && a2ensite default-ssl >/dev/null 2>&1
        rm -f /etc/php/*/*/conf.d/99-mirzabot.ini
        systemctl reload apache2 >/dev/null 2>&1; true" || true
    run_step "Removing SSL certificate and renewal timer" bash -c "
        systemctl disable --now mirzabot-cert-renew.timer >/dev/null 2>&1
        rm -f /etc/systemd/system/mirzabot-cert-renew.* /etc/letsencrypt/renewal-hooks/deploy/mirzabot-reload.sh; systemctl daemon-reload
        [ -x '$CERTBOT_VENV/bin/certbot' ] && '$CERTBOT_VENV/bin/certbot' delete --cert-name $CERT_NAME --non-interactive >/dev/null 2>&1
        command -v certbot >/dev/null && certbot delete --cert-name $CERT_NAME --non-interactive >/dev/null 2>&1
        rm -rf /opt/mirzabot '$ACME_WEBROOT'; true" || true

    if [[ $KEEP_DB -eq 0 && -n $DB_NAME ]] && mysql_root_ok; then
        run_step "Dropping the database and its user" mysql_root -e "DROP DATABASE IF EXISTS \`$DB_NAME\`; DROP USER IF EXISTS '$DB_USER'@'localhost'; FLUSH PRIVILEGES;" || true
    fi
    [[ -d $APP_DIR && $APP_DIR != / && ${#APP_DIR} -gt 8 ]] && run_step "Deleting bot files" rm -rf "$APP_DIR"

    if [[ $PURGE_STACK -eq 1 ]]; then
        purge_stack
    fi
    local pre_conf_dir=$CONF_DIR
    rm -rf "$pre_conf_dir" /etc/logrotate.d/mirzabot /etc/apache2/sites-available/*mirzabot* 2>/dev/null
    rm -f "$BIN_PATH"
    printf '\n  %s%s Mirza Bot has been removed.%s\n' "$C_G" "$SYM_OK" "$C_N"
    [[ -d /root/mirzabot-final-backup ]] && msg_kv "Final backup" "/root/mirzabot-final-backup"
    msg_kv "Other backups" "$BACKUP_DIR (not deleted)"
    printf '\n'
    cleanup
}

purge_stack() {
    local pkgs=()
    [[ "$(conf_get PRE_APACHE)" == 0 ]] && pkgs+=(apache2 'libapache2-mod-php*')
    [[ "$(conf_get PRE_PHP)" == 0 ]] && pkgs+=('php8.5*')
    if [[ -n $(others_dbs) ]]; then
        msg_warn "The database server holds other databases - keeping it."
    else
        [[ "$(conf_get PRE_MYSQL)" == 0 && $(pkg_installed mysql-server && echo 1) == 1 ]] && pkgs+=('mysql-server*' 'mysql-client*' 'mysql-common')
        [[ "$(conf_get PRE_MARIADB)" == 0 && $(pkg_installed mariadb-server && echo 1) == 1 ]] && pkgs+=('mariadb-server*' 'mariadb-client*')
    fi
    ((${#pkgs[@]})) || { msg_info "Nothing to purge - those packages existed before the installer."; return 0; }
    msg_warn "Purging: ${pkgs[*]}"
    run_step "Removing packages" bash -c "apt-get purge -y ${pkgs[*]} && apt-get autoremove -y" || true
}

# =============================================================================
#  Commands: status, backup, restore, ssl, webhook, logs, reconfigure
# =============================================================================
svc_state() { systemctl is-active --quiet "$1" 2>/dev/null && printf '%srunning%s' "$C_G" "$C_N" || printf '%sstopped%s' "$C_R" "$C_N"; }

cmd_status() {
    need_root; load_context; require_installed; banner
    TOKEN=$(cfg_get APIKEY)
    printf '  %sBot%s\n' "$C_W" "$C_N"
    msg_kv "Username" "@$(cfg_get usernamebot)"; msg_kv "Version" "$(cat "$APP_DIR/version" 2>/dev/null)  ${C_D}($(conf_get INSTALLED_SHA | cut -c1-9))${C_N}"
    msg_kv "Address" "https://$HOST"; msg_kv "Path" "$APP_DIR"; msg_kv "Installed" "$(conf_get INSTALLED_AT)"
    printf '\n  %sServices%s\n' "$C_W" "$C_N"
    msg_kv "Apache" "$(svc_state apache2)"; msg_kv "Database" "$(svc_state "$(db_service)")"; msg_kv "Cron" "$(svc_state cron)"
    msg_kv "PHP" "$("$PHP_BIN" -r 'echo PHP_VERSION;' 2>/dev/null || echo missing)  ${C_D}(needs ${PHP_MIN}+)${C_N}"
    if /usr/bin/crontab -u www-data -l 2>/dev/null | grep -qF cronbot/run.php; then msg_kv "Cron job" "${C_G}registered${C_N}"
    else msg_kv "Cron job" "${C_R}missing${C_N}  (fix: mirzabot update --force)"; fi
    printf '\n  %sSSL%s\n' "$C_W" "$C_N"
    local d; d=$(cert_days_left)
    if [[ $d == - ]]; then msg_kv "Certificate" "${C_R}not found${C_N}"
    elif ((d < 2)); then msg_kv "Certificate" "${C_Y}${d} day(s) left${C_N}  ($CERT_MODE) - run: mirzabot ssl renew"
    else msg_kv "Certificate" "${C_G}${d} days left${C_N}  ($CERT_MODE)"; fi
    msg_kv "Auto-renew" "$(systemctl is-active mirzabot-cert-renew.timer 2>/dev/null)"
    printf '\n  %sTelegram webhook%s\n' "$C_W" "$C_N"
    local info; info=$(webhook_info)
    if [[ -n $info ]]; then
        msg_kv "URL" "$(jq -r '.result.url // "none"' <<<"$info" | sed 's/secret=[^&]*/secret=***/')"
        msg_kv "Pending" "$(jq -r '.result.pending_update_count // 0' <<<"$info")"
        local e; e=$(jq -r '.result.last_error_message // empty' <<<"$info")
        [[ -n $e ]] && msg_kv "Last error" "${C_Y}${e}${C_N}"
    else msg_kv "Webhook" "${C_R}could not query Telegram${C_N}"; fi
    printf '\n  %sHealth%s\n' "$C_W" "$C_N"
    health_check || true
    msg_kv "Disk free" "$(df -h / | awk 'NR==2{print $4}')"
    printf '\n'
}

cmd_backup() {
    need_root; acquire_lock; load_context; require_installed
    ensure_db_root_access
    backup_prepare manual
    run_step "Creating backup" do_backup || die "Backup failed."
    msg_kv "Saved to" "$BACKUP_PATH"
    msg_kv "Size" "$(du -sh "$BACKUP_PATH" | cut -f1)"
    printf '  %sCopy it off the server, e.g.: scp -r root@%s:%s .%s\n\n' "$C_D" "$HOST" "$BACKUP_PATH" "$C_N"
}

cmd_restore() {
    need_root; acquire_lock; load_context; require_installed
    ensure_db_root_access
    local target=${EXTRA[0]:-} list
    if [[ -z $target ]]; then
        list=$(list_backups)
        [[ -n $list ]] || die "No backups found in $BACKUP_DIR. Pass a path: mirzabot restore /path/to/backup-or-dump.sql.gz"
        printf '  Available backups:\n'; local i=0 b; local arr=()
        while IFS= read -r b; do i=$((i + 1)); arr+=("$b"); printf '    %s%d)%s %s %s(%s)%s\n' "$C_W" "$i" "$C_N" "$(basename "$b")" "$C_D" "$(du -sh "$b" | cut -f1)" "$C_N"; done <<<"$list"
        [[ $HAVE_TTY -eq 1 ]] || die "Specify which backup to restore."
        local n; ask n "Number to restore" "1"
        [[ $n =~ ^[0-9]+$ ]] && ((n >= 1 && n <= ${#arr[@]})) || die "Invalid choice."
        target=${arr[n - 1]}
    fi
    local sqlfile=""
    if [[ -d $target ]]; then sqlfile=$target/database.sql.gz; else sqlfile=$target; fi
    [[ -f $sqlfile ]] || die "No database dump found at: $sqlfile"
    msg_warn "The CURRENT database '$DB_NAME' will be replaced by: $sqlfile"
    confirm "Continue?" n || die "Cancelled."
    backup_prepare before-restore
    run_step "Safety backup of the current state" do_backup || die "Could not create a safety backup - aborting."
    msg_kv "Safety backup" "$BACKUP_PATH"
    run_step "Restoring the database" restore_database_file "$sqlfile" || die "Restore failed. Your previous data is in $BACKUP_PATH"
    if [[ -d $target && -f $target/app-files.tar.gz ]] && confirm "Also restore the program files and config.php from this backup?" n; then
        run_step "Restoring files" rollback_files "$target/app-files.tar.gz" || msg_warn "File restore failed."
        fix_permissions
    fi
    run_step "Refreshing tables and webhook" init_tables || msg_warn "Run 'mirzabot webhook fix'."
    printf '\n  %s%s Restore complete.%s\n\n' "$C_G" "$SYM_OK" "$C_N"
}

cmd_ssl() {
    need_root; load_context; require_installed
    CERTBOT="$CERTBOT_VENV/bin/certbot"; [[ -x $CERTBOT ]] || CERTBOT=$(command -v certbot || true)
    local d; d=$(cert_days_left)
    msg_kv "Host" "$HOST"; msg_kv "Mode" "$CERT_MODE"; msg_kv "Days left" "$d"
    msg_kv "Timer" "$(systemctl is-active mirzabot-cert-renew.timer 2>/dev/null)"
    if [[ ${EXTRA[0]:-} == renew ]]; then
        [[ -n $CERTBOT ]] || die "certbot not found."
        run_step "Renewing the certificate now" "$CERTBOT" renew --cert-name "$CERT_NAME" --force-renewal || die "Renewal failed (see $LOG_FILE). Rate limits? Try again later."
        run_step "Reloading Apache" apache_reload
        msg_kv "Days left" "$(cert_days_left)"
    else
        printf '\n  %sForce a renewal with:%s mirzabot ssl renew\n' "$C_D" "$C_N"
    fi
    printf '\n'
}

cmd_webhook() {
    need_root; load_context; require_installed
    TOKEN=$(cfg_get APIKEY)
    if [[ ${EXTRA[0]:-} == fix ]]; then
        run_step "Re-registering the webhook (table.php)" init_tables || die "table.php failed - see $LOG_FILE"
    fi
    local info; info=$(webhook_info) || die "Could not reach Telegram."
    jq '.result | .url |= sub("secret=[^&]*"; "secret=***")' <<<"$info"
    [[ ${EXTRA[0]:-} == fix ]] || printf '\n  %sRepair with:%s mirzabot webhook fix\n' "$C_D" "$C_N"
}

cmd_logs() {
    need_root; load_context
    local which=${EXTRA[0]:-}
    if [[ -z $which && $HAVE_TTY -eq 1 ]]; then
        printf '    1) Bot errors (error_log)\n    2) Apache errors\n    3) Installer log\n'
        local c; ask c "Choose" "1"; case $c in 2) which=apache ;; 3) which=install ;; *) which=app ;; esac
    fi
    case ${which:-app} in
        apache)  tail -n 80 -f /var/log/apache2/mirzabot-error.log ;;
        install) tail -n 80 -f "$LOG_FILE" ;;
        *)       [[ -f $APP_DIR/error_log ]] && tail -n 80 -f "$APP_DIR/error_log" || msg_info "No bot errors logged (error_log does not exist) - that is good." ;;
    esac
}

cmd_reconfigure() {
    need_root; acquire_lock; load_context; require_installed
    TOKEN=$(cfg_get APIKEY); ADMIN_ID=$(cfg_get adminnumber)
    local choice=${EXTRA[0]:-}
    if [[ -z $choice ]]; then
        [[ $HAVE_TTY -eq 1 ]] || die "Usage: mirzabot reconfigure token|admin|address"
        printf '  1) Change the bot token\n  2) Change the admin ID\n  3) Change the address (domain / automatic)\n  4) Show current settings\n'
        ask choice "Choose" ""
        case $choice in 1) choice="token" ;; 2) choice="admin" ;; 3) choice="address" ;; 4) choice="show" ;; esac
    fi
    case $choice in
        token)
            local new=$OPT_TOKEN old=$TOKEN
            while true; do
                [[ -z $new ]] && { ask new "New bot token"; }
                valid_token "$new" || { msg_err "Invalid token format."; new=""; [[ $HAVE_TTY -eq 1 ]] || exit 1; continue; }
                TOKEN=$new; validate_token_online && break
                msg_err "Telegram rejected this token."; TOKEN=$old; new=""; [[ $HAVE_TTY -eq 1 ]] || exit 1
            done
            tg_call deleteWebhook >/dev/null 2>&1 || true
            cfg_set APIKEY "$new"; cfg_set usernamebot "$BOT_USERNAME"
            run_step "Registering the webhook for @$BOT_USERNAME" init_tables || die "table.php failed."
            verify_webhook || true ;;
        admin)
            local a=$OPT_ADMIN
            while ! valid_admin "$a"; do ask a "New admin numeric ID"; valid_admin "$a" || msg_err "Must be a number."; [[ $HAVE_TTY -eq 1 ]] || exit 1; done
            cfg_set adminnumber "$a"
            msg_ok "adminnumber updated in config.php"
            msg_info "Admins are stored in the bot's database too - add or remove them from the bot's admin panel." ;;
        address)
            check_network; detect_public_ip
            if [[ -n $OPT_DOMAIN ]]; then ACCESS_MODE=domain
            elif [[ $OPT_NO_DOMAIN -eq 1 ]]; then ACCESS_MODE=auto
            else
                local c; printf '  1) Automatic (no domain)\n  2) Use a domain\n'; ask c "Choose" "1"
                if [[ $c == 2 ]]; then ACCESS_MODE=domain; ask OPT_DOMAIN "Domain name"; OPT_DOMAIN=$(tr 'A-Z' 'a-z' <<<"$OPT_DOMAIN")
                else ACCESS_MODE=auto; fi
            fi
            [[ $ACCESS_MODE == domain ]] && { valid_domain "$OPT_DOMAIN" || die "Invalid domain."; }
            setup_access || { explain_access_failure; die "Address change failed."; }
            cfg_set domainhosts "$HOST"
            run_step "Re-registering the webhook" init_tables || die "table.php failed."
            run_step "Updating cron jobs" install_cron || true
            verify_webhook || true
            msg_ok "New address: https://$HOST" ;;
        show)
            msg_kv "Bot" "@$(cfg_get usernamebot)"; msg_kv "Token" "$(cfg_get APIKEY | cut -c1-10)..."
            msg_kv "Admin ID" "$(cfg_get adminnumber)"; msg_kv "Address" "https://$(cfg_get domainhosts)"
            msg_kv "Database" "$(cfg_get dbname)" ;;
        *) die "Unknown option '$choice'. Use: token | admin | address | show" ;;
    esac
}

# =============================================================================
#  Menu, help, argument parsing
# =============================================================================
cmd_self_update() {
    need_root
    local tmp; tmp=$(mktemp)
    curl -fsSL --max-time 30 -o "$tmp" "$(self_url)" || { rm -f "$tmp"; die "Could not download $SELF_URL"; }
    bash -n "$tmp" && grep -q MIRZA_EASY_INSTALLER "$tmp" || { rm -f "$tmp"; die "Downloaded script failed validation."; }
    install -m 0755 "$tmp" "$BIN_PATH"; rm -f "$tmp"
    msg_ok "Installer updated: $("$BIN_PATH" version)"
}

show_help() {
    cat <<EOF
Mirza Bot Easy Installer v${INSTALLER_VERSION}

USAGE
  mirzabot [command] [options]        (no command opens the interactive menu)

COMMANDS
  install              Install the bot (no domain needed)
  update               Update to the latest version (automatic backup + rollback)
  remove               Remove the bot (asks for confirmation)
  status               Health check: services, SSL, webhook, cron
  backup               Back up database + files to ${BACKUP_DIR}
  restore [path]       Restore a backup (database, optionally files)
  reconfigure [what]   Change token | admin | address
  ssl [renew]          Show / force-renew the SSL certificate
  webhook [fix]        Show / repair the Telegram webhook
  logs [app|apache|install]
  self-update          Update this installer script
  version, help

OPTIONS
  --token TOKEN        Telegram bot token
  --admin ID           Numeric Telegram ID of the main admin
  --domain NAME        Use your own domain (default: automatic, no domain)
  --no-domain          Force automatic mode
  --email ADDRESS      E-mail for Let's Encrypt expiry notices (optional)
  --branch NAME        Install/update from this branch (default: ${BRANCH})
  --tag NAME           Install/update a specific release tag
  --repo OWNER/NAME    Use another GitHub repository (default: ${REPO})
  --keep-db            remove: keep the database
  --purge-stack        remove: also purge Apache/PHP/MySQL that this installer added
  --no-backup          remove: skip the final backup
  -y, --yes            Do not ask questions (use defaults)
  --force              Reinstall / ignore OS check / update even if up to date
  --no-color

EXAMPLES
  mirzabot install
  mirzabot install --token 123456:ABC... --admin 11111111 --yes
  mirzabot install --token 123456:ABC... --admin 11111111 --domain bot.example.com
  mirzabot update
  mirzabot remove --yes --keep-db

ENVIRONMENT
  MIRZA_DB_ROOT_PASS   Database root password (only if root has one)
  GITHUB_TOKEN         For private repositories
EOF
}

installed_banner_info() {
    if is_installed; then
        printf '  %sStatus:%s %sinstalled%s  %s%s  v%s%s\n' "$C_D" "$C_N" "$C_G" "$C_N" "$C_D" "https://$HOST" "$(cat "$APP_DIR/version" 2>/dev/null)" "$C_N"
    else
        printf '  %sStatus:%s %snot installed%s\n' "$C_D" "$C_N" "$C_Y" "$C_N"
    fi
}

show_menu() {
    while true; do
        load_context; clear 2>/dev/null; banner; installed_banner_info
        cat <<EOF

    ${C_W}1)${C_N} Install Mirza Bot
    ${C_W}2)${C_N} Update
    ${C_W}3)${C_N} Remove
    ${C_W}4)${C_N} Status & health check
    ${C_W}5)${C_N} Backup
    ${C_W}6)${C_N} Restore a backup
    ${C_W}7)${C_N} Settings  (token / admin / address)
    ${C_W}8)${C_N} SSL certificate
    ${C_W}9)${C_N} Repair Telegram webhook
    ${C_W}10)${C_N} View logs
    ${C_W}0)${C_N} Exit

EOF
        local c; ask c "Select an option" ""
        EXTRA=()
        case $c in
            1) ( cmd_install ) ;; 2) ( cmd_update ) ;; 3) ( cmd_remove ) ;; 4) ( cmd_status ) ;;
            5) ( cmd_backup ) ;; 6) ( cmd_restore ) ;; 7) ( cmd_reconfigure ) ;; 8) ( cmd_ssl ) ;;
            9) EXTRA=(fix); ( cmd_webhook ) ;; 10) ( cmd_logs ) ;;
            0|q|Q|exit) printf '\n'; return 0 ;;
            *) msg_warn "Invalid option." ;;
        esac
        pause_key
    done
}

parse_args() {
    local args=() a
    for a in "$@"; do
        if [[ $a == --*=* ]]; then args+=("${a%%=*}" "${a#*=}"); else args+=("$a"); fi
    done
    set -- "${args[@]+"${args[@]}"}"
    while (($#)); do
        case $1 in
            install|update|remove|uninstall|status|backup|restore|reconfigure|settings|ssl|webhook|logs|menu|self-update|help|version|doctor)
                if [[ -z $CMD ]]; then CMD=$1; else EXTRA+=("$1"); fi ;;
            --token)   OPT_TOKEN=${2:-}; shift ;;
            --admin)   OPT_ADMIN=${2:-}; shift ;;
            --domain)  OPT_DOMAIN=${2:-}; shift ;;
            --no-domain) OPT_NO_DOMAIN=1 ;;
            --email)   OPT_EMAIL=${2:-}; shift ;;
            --branch)  OPT_BRANCH=${2:-main}; BRANCH=$OPT_BRANCH; shift ;;
            --tag|--version) OPT_TAG=${2:-}; shift ;;
            --repo)    OPT_REPO=${2:-$REPO}; REPO=$OPT_REPO; shift ;;
            --cert-mode) OPT_CERT_MODE=${2:-}; shift ;;
            --keep-db) KEEP_DB=1 ;;
            --purge-stack) PURGE_STACK=1 ;;
            --no-backup) NO_BACKUP=1 ;;
            -y|--yes)  ASSUME_YES=1 ;;
            --force)   FORCE=1 ;;
            --no-color) NO_COLOR_OPT=1 ;;
            -h|--help) CMD=help ;;
            -*) printf 'Unknown option: %s (try: mirzabot help)\n' "$1" >&2; exit 2 ;;
            *)  EXTRA+=("$1") ;;
        esac
        shift
    done
    [[ $CMD == uninstall ]] && CMD=remove
    [[ $CMD == settings ]] && CMD=reconfigure
    [[ $CMD == doctor ]] && CMD=status
    return 0
}

main() {
    set -u
    parse_args "$@"
    if locale -a 2>/dev/null | grep -qi '^c\.utf-\?8$'; then export LANG=C.UTF-8 LC_ALL=C.UTF-8; fi
    setup_ui
    trap on_interrupt INT TERM
    trap cleanup EXIT
    case ${CMD:-menu} in
        help)       show_help ;;
        version)    echo "mirzabot easy-installer $INSTALLER_VERSION" ;;
        install)    cmd_install ;;
        update)     cmd_update ;;
        remove)     cmd_remove ;;
        status)     cmd_status ;;
        backup)     cmd_backup ;;
        restore)    cmd_restore ;;
        reconfigure) cmd_reconfigure ;;
        ssl)        cmd_ssl ;;
        webhook)    cmd_webhook ;;
        logs)       cmd_logs ;;
        self-update) cmd_self_update ;;
        menu)       need_root; mkdir -p "$(dirname "$LOG_FILE")"
                    if [[ $HAVE_TTY -eq 0 ]]; then show_help; exit 0; fi
                    show_menu ;;
        *)          show_help; exit 2 ;;
    esac
}

# Everything above is only function definitions, so a truncated download can never run half a script.
[[ -n ${MIRZA_SOURCE_ONLY:-} ]] || main "$@"
