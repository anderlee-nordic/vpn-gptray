#!/usr/bin/env bash
set -euo pipefail

# --------------- CONFIG --------------
PY_SCRIPT="vpn_gptray"
BASH_SCRIPT="vpn_gp"
INSTALL_DIR="/opt/vpn_gputil"
PY_LINK="/usr/local/bin/${PY_SCRIPT}"
BASH_LINK="/usr/local/bin/${BASH_SCRIPT}"
CONFIG_DIR="$(eval echo ~${SUDO_USER:-$USER})/.config/vpn-gptray"
CONFIG_FILE="${CONFIG_DIR}/config.txt"
# --------------------------------------

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check GlobalProtect CLI exists in PATH
if ! which globalprotect >/dev/null 2>&1; then
  echo -e "${RED}Error: globalprotect not found in PATH. Install GlobalProtect CLI first.${NC}" >&2
  exit 1
fi

if [[ $EUID -ne 0 ]]; then
  echo -e "${YELLOW}Please run as root: sudo $0${NC}"
  exit 1
fi

# Install dependencies
apt-get update
apt-get install -y python3-gi
apt-get install -y gir1.2-ayatanaappindicator3-0.1

mkdir -p "${INSTALL_DIR}"

# Copy and preserve permissions/timestamps
install -p "${PY_SCRIPT}" "${INSTALL_DIR}/"
install -p "${BASH_SCRIPT}" "${INSTALL_DIR}/"
ln -sfn "${INSTALL_DIR}/${PY_SCRIPT}" "${PY_LINK}"
ln -sfn "${INSTALL_DIR}/${BASH_SCRIPT}" "${BASH_LINK}"

# Config file
mkdir -p "${CONFIG_DIR}"
if [[ ! -f "${CONFIG_FILE}" ]]; then
  cat > "${CONFIG_FILE}" << 'EOF'
PORTAL=vpn.nordicsemi.no
EOF
fi

# Transfer ownership to user
chown -R "$USER:$USER" "${CONFIG_DIR}"

echo -e "${GREEN}${BASH_SCRIPT} and ${PY_SCRIPT} have been installed at: '${INSTALL_DIR}'${NC}"
echo -e "${GREEN}Config file: '${CONFIG_FILE}'${NC}"
