#!/bin/bash

##############################################################################
# User Management & Lockdown Script
# Works on Rocky Linux and Debian-based systems
# Locks all users with UID >= 1000 except 'Captain', 'etc', and 'whiteteam'
# Promotes 'etc' user to sudo/wheel privileges
##############################################################################

set -euo pipefail

# Colors for outputs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}[ERROR]${NC} This script must be run as root"
   exit 1
fi

# Detect distro
detect_distro() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS=$ID
    else
        echo -e "${RED}[ERROR]${NC} Cannot detect operating system"
        exit 1
    fi
}

# Get the appropriate sudo/wheel group based on distro
get_privilege_group() {
    case "$OS" in
        rocky|rhel|centos)
            echo "wheel"
            ;;
        debian|ubuntu)
            echo "sudo"
            ;;
        *)
            echo "sudo"
            ;;
    esac
}

# Ensure 'etc' user exists or create it
ensure_etc_user() {
    if ! id "etc" &>/dev/null; then
        echo -e "${YELLOW}[*]${NC} Creating 'etc' user..."
        useradd -m -s /bin/bash -u 999 -G "$(get_privilege_group)" etc || true
    fi
}

# Add etc user to privilege group if not already there
promote_etc_user() {
    local priv_group=$(get_privilege_group)
    echo -e "${YELLOW}[*]${NC} Promoting 'etc' user to ${priv_group} group..."
    
    if id "etc" &>/dev/null; then
        usermod -a -G "$priv_group" etc
        echo -e "${GREEN}[+]${NC} 'etc' user added to $priv_group group"
    fi
}

# Lock users with UID >= 1000 (except Captain and etc)
lock_regular_users() {
    echo -e "${YELLOW}[*]${NC} Locking regular users (UID >= 1000)..."
    
    while IFS=: read -r username password uid gid gecos home shell; do
        # Skip system users (UID < 1000) and our protected users
        if [[ $uid -lt 1000 ]] || [[ "$username" == "Captain" ]] || [[ "$username" == "etc" ]] || [[ "$username" == "whiteteam" ]]; then
            continue
        fi
        
        echo -e "${YELLOW}[*]${NC} Processing user: $username (UID: $uid)"
        
        # Lock the account
        usermod -L "$username" 2>/dev/null || true
        echo -e "${GREEN}[+]${NC}   Locked account"
        
        # Set shell to nologin
        usermod -s /usr/sbin/nologin "$username" 2>/dev/null || true
        echo -e "${GREEN}[+]${NC}   Shell set to /usr/sbin/nologin"
        
        # Expire the password to force change on next login (if somehow unlocked)
        passwd -e "$username" 2>/dev/null || true
        echo -e "${GREEN}[+]${NC}   Password expired"
    done < /etc/passwd
}

# Verify locks
verify_locks() {
    echo -e "${YELLOW}[*]${NC} Verifying lockdown..."
    echo ""
    echo "=== Locked Users (UID >= 1000) ==="
    while IFS=: read -r username password uid gid gecos home shell; do
        if [[ $uid -lt 1000 ]] || [[ "$username" == "Captain" ]] || [[ "$username" == "etc" ]] || [[ "$username" == "whiteteam" ]]; then
            continue
        fi
        # Check if account is locked (password field starts with !)
        if [[ "$password" == !* ]]; then
            echo -e "${GREEN}[LOCKED]${NC} $username (UID: $uid) | Shell: $shell"
        else
            echo -e "${RED}[UNLOCKED]${NC} $username (UID: $uid) - FAILED!"
        fi
    done < /etc/passwd
    
    echo ""
    echo "=== Protected Users ==="
    for protected_user in "Captain" "etc" "whiteteam"; do
        if id "$protected_user" &>/dev/null; then
            user_shell=$(getent passwd "$protected_user" | cut -d: -f7)
            user_uid=$(id -u "$protected_user")
            echo -e "${GREEN}[PROTECTED]${NC} $protected_user (UID: $user_uid) | Shell: $user_shell"
        fi
    done
    
    echo ""
    echo "=== 'etc' User Group Memberships ==="
    if id "etc" &>/dev/null; then
        groups etc
    fi
}

# Main execution
main() {
    echo -e "${YELLOW}========================================${NC}"
    echo -e "${YELLOW}  User Management & Lockdown Script${NC}"
    echo -e "${YELLOW}========================================${NC}"
    echo ""
    
    detect_distro
    echo -e "${GREEN}[+]${NC} Detected OS: $OS"
    
    local priv_group=$(get_privilege_group)
    echo -e "${GREEN}[+]${NC} Privilege group for this distro: $priv_group"
    echo ""
    
    ensure_etc_user
    promote_etc_user
    lock_regular_users
    verify_locks
    
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  User lockdown complete!${NC}"
    echo -e "${GREEN}========================================${NC}"
}

main "$@"
