#!/bin/bash

# Ubuntu Security Analysis Workstation Setup Script
# This script sets up an Ubuntu desktop for security analysis and malware investigation
# Run this script as root or with sudo privileges
# Tested on Ubuntu 22.04 LTS

# Exit on any error
set -e

echo "[+] Starting security workstation setup..."

# Function to print status messages
print_status() {
    echo "[+] $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Update system first
print_status "Updating system packages..."
apt update && apt upgrade -y

# Install essential system utilities
print_status "Installing essential utilities..."
apt install -y \
    git \
    curl \
    wget \
    vim \
    net-tools \
    htop \
    tmux \
    build-essential \
    python3-pip \
    python3-dev \
    python3-venv \
    libssl-dev \
    libffi-dev \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev \
    docker.io \
    docker-compose

# Enable Docker service
print_status "Enabling Docker service..."
systemctl enable docker
systemctl start docker

# Install Network Analysis Tools
print_status "Installing network analysis tools..."
apt install -y \
    wireshark \
    tcpdump \
    nmap \
    netcat \
    tshark \
    traceroute \
    whois \
    dns-utils

# Install Forensics Tools
print_status "Installing forensic analysis tools..."
apt install -y \
    autopsy \
    sleuthkit \
    volatility \
    foremost \
    scalpel \
    binwalk \
    bulk-extractor \
    ddrescue \
    testdisk

# Install Malware Analysis Tools
print_status "Installing malware analysis tools..."
apt install -y \
    radare2 \
    gdb \
    ltrace \
    strace \
    checksec \
    yara

# Install Python security packages
print_status "Installing Python security packages..."
pip3 install --upgrade \
    pip \
    pwntools \
    requests \
    scapy \
    pyshark \
    yara-python \
    volatility3 \
    oletools

# Setup directories
print_status "Creating workspace directories..."
mkdir -p ~/security/{malware,forensics,network,tools}

# Install VSCode
print_status "Installing Visual Studio Code..."
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg
install -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/trusted.gpg.d/
echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list
apt update
apt install -y code

# Install Ghidra
print_status "Installing Ghidra..."
GHIDRA_VERSION="10.3.3"
GHIDRA_DATE="20230829"
wget https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_${GHIDRA_VERSION}_build/ghidra_${GHIDRA_VERSION}_PUBLIC_${GHIDRA_DATE}.zip -O /tmp/ghidra.zip
unzip /tmp/ghidra.zip -d /opt
ln -s /opt/ghidra_${GHIDRA_VERSION}_PUBLIC/ghidraRun /usr/local/bin/ghidra

# Setup Sandbox environment
print_status "Setting up sandbox environment..."
cat > /etc/docker/daemon.json <<EOF
{
    "userns-remap": "default",
    "storage-driver": "overlay2"
}
EOF

# Create analysis user
print_status "Creating dedicated analysis user..."
useradd -m -s /bin/bash analyst
usermod -aG docker analyst

# Setup firewall
print_status "Configuring basic firewall..."
ufw enable
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow http
ufw allow https

# Create convenient aliases
print_status "Setting up convenience aliases..."
cat >> /home/analyst/.bashrc <<'EOF'
# Security Analysis Aliases
alias tcpdump='tcpdump -n'
alias strings='strings -a'
alias xxd='xxd -g 1'
alias hexdump='hexdump -C'
alias hosts='sudo vim /etc/hosts'
alias listening='netstat -tunlp'
alias connections='netstat -tunapl'
alias processes='ps auxf'
EOF

# Setup file monitoring
print_status "Setting up file integrity monitoring..."
apt install -y aide
aideinit

# Create sandbox script
cat > /home/analyst/create_sandbox.sh <<'EOF'
#!/bin/bash
docker run -d \
    --name malware_sandbox \
    --network none \
    --memory 2g \
    --cpus 1 \
    --storage-opt size=10g \
    ubuntu:latest \
    tail -f /dev/null
EOF
chmod +x /home/analyst/create_sandbox.sh

print_status "Installation complete! Please reboot your system."

# Print final instructions
cat << "EOF"
==============================================
Security Workstation Setup Complete!

Next steps:
1. Reboot your system
2. Configure Wireshark for non-root users
3. Set up your analysis VM in VirtualBox
4. Configure VSCode with security extensions
5. Test all installed tools

Remember to:
- Keep your system updated
- Use separate networks for analysis
- Always work with malware in isolated environments
- Maintain proper backups

For malware analysis, always use the provided sandbox
script or dedicated VMs.
==============================================
EOF
