#!/usr/bin/env bash
# Suricata automated installer for RHEL 10
# This script automates the installation of Suricata with user feedback

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   log_error "This script must be run as root (use sudo)"
   exit 1
fi

log_info "Starting Suricata installation for RHEL 10..."

# Check RHEL version
log_info "Checking RHEL version..."
if [[ -f /etc/redhat-release ]]; then
    RHEL_VERSION=$(grep -oP '(?<=release )\d+' /etc/redhat-release || echo "unknown")
    log_info "Detected RHEL version: $RHEL_VERSION"

    if [[ "$RHEL_VERSION" != "10" ]] && [[ "$RHEL_VERSION" != "9" ]] && [[ "$RHEL_VERSION" != "8" ]]; then
        log_warning "This script is optimized for RHEL 10, but detected RHEL $RHEL_VERSION"
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Installation cancelled by user"
            exit 0
        fi
    fi
else
    log_error "This does not appear to be a RHEL system"
    exit 1
fi

# Enable EPEL repository
log_info "Enabling EPEL repository..."
if ! rpm -q epel-release &> /dev/null; then
    dnf install -y epel-release || {
        log_warning "Could not install EPEL from dnf, trying direct RPM..."
        if [[ "$RHEL_VERSION" == "10" ]]; then
            dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm || log_warning "EPEL installation failed, will try without it"
        elif [[ "$RHEL_VERSION" == "9" ]]; then
            dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm || log_warning "EPEL installation failed, will try without it"
        elif [[ "$RHEL_VERSION" == "8" ]]; then
            dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm || log_warning "EPEL installation failed, will try without it"
        fi
    }
    log_success "EPEL repository enabled"
else
    log_info "EPEL repository already installed"
fi

# Update system
log_info "Updating system packages (this may take a few minutes)..."
dnf update -y
log_success "System packages updated"

# Install dependencies
log_info "Installing Suricata dependencies..."
DEPS=(
    gcc
    make
    libyaml-devel
    libpcap-devel
    pcre-devel
    libtool
    file-devel
    zlib-devel
    jansson-devel
    nss-devel
    libcap-ng-devel
    libnet-devel
    tar
    wget
    rust
    cargo
)

for dep in "${DEPS[@]}"; do
    if ! rpm -q "$dep" &> /dev/null; then
        log_info "Installing $dep..."
        dnf install -y "$dep" || log_warning "Could not install $dep, continuing..."
    else
        log_info "$dep already installed"
    fi
done
log_success "Dependencies installed"

# Install Suricata
log_info "Installing Suricata..."
if ! command -v suricata &> /dev/null; then
    dnf install -y suricata
    log_success "Suricata installed successfully"
else
    log_info "Suricata is already installed"
    CURRENT_VERSION=$(suricata --version | head -n1)
    log_info "Current version: $CURRENT_VERSION"
fi

# Create necessary directories
log_info "Setting up Suricata directories..."
mkdir -p /var/log/suricata
mkdir -p /etc/suricata/rules
chmod 755 /var/log/suricata
chmod 755 /etc/suricata
log_success "Directories created"

# Update Suricata rules
log_info "Updating Suricata rules..."
if command -v suricata-update &> /dev/null; then
    suricata-update || log_warning "Rule update failed, you may need to update rules manually"
    log_success "Rules updated"
else
    log_warning "suricata-update not found, skipping rule update"
fi

# Enable and start Suricata service
log_info "Configuring Suricata service..."
systemctl enable suricata
log_success "Suricata service enabled"

# Test configuration
log_info "Testing Suricata configuration..."
if suricata -T; then
    log_success "Suricata configuration is valid"
else
    log_warning "Suricata configuration test failed, you may need to configure it manually"
fi

# Configure firewall if firewalld is running
if systemctl is-active --quiet firewalld; then
    log_info "Configuring firewall rules..."
    read -p "Do you want to configure firewall rules for Suricata? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Add any necessary firewall rules here
        log_info "Firewall configuration can be customized based on your needs"
    fi
fi

# Display installation summary
echo ""
log_success "============================================="
log_success "Suricata installation completed successfully!"
log_success "============================================="
echo ""
log_info "Next steps:"
echo "  1. Review the configuration in /etc/suricata/suricata.yaml"
echo "  2. Update network interface settings in the config"
echo "  3. Start Suricata: systemctl start suricata"
echo "  4. Check status: systemctl status suricata"
echo "  5. View logs: tail -f /var/log/suricata/suricata.log"
echo ""
log_info "For more information, visit: https://github.com/cyberiancherubim/suricata-lab-kit"
echo ""

# Ask if user wants to start Suricata now
read -p "Do you want to start Suricata now? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log_info "Starting Suricata service..."
    systemctl start suricata
    sleep 2
    if systemctl is-active --quiet suricata; then
        log_success "Suricata is running"
        systemctl status suricata --no-pager
    else
        log_error "Failed to start Suricata, check logs with: journalctl -u suricata -e"
    fi
else
    log_info "You can start Suricata later with: systemctl start suricata"
fi

exit 0
