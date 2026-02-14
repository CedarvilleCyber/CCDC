#!/bin/bash
# Package integrity checker and auto-repair script
# Usage: ./check-and-repair.sh [package_name]

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${error}Error: This script must be run as root${NC}"
    exit 1
fi

# Detect package manager
if command -v rpm &> /dev/null; then
    PKG_MGR="rpm"
    INSTALL_CMD="yum reinstall -y"
elif command -v dpkg &> /dev/null; then
    PKG_MGR="dpkg"
    INSTALL_CMD="apt-get install --reinstall -y"
else
    echo -e "${error}Error: No supported package manager found${reset}"
    exit 1
fi

# Package to check (default: util-linux)
PACKAGE="${1:-util-linux}"

echo "=== Package Integrity Checker ==="
echo "Checking package: $PACKAGE"
echo "Package manager: $PKG_MGR"
echo ""

# Function to check RPM-based systems
check_rpm() {
    echo "Running: rpm -V $PACKAGE"
    if rpm -V "$PACKAGE" 2>&1 | tee /tmp/rpm_verify.txt | grep -q .; then
        echo -e "${error}[!] Package verification FAILED - files modified:${NC}"
        cat /tmp/rpm_verify.txt
        return 1
    else
        echo -e "${info}[✓] Package verification PASSED${NC}"
        return 0
    fi
}

# Function to check Debian-based systems
check_debian() {
    # Install debsums if not present
    if ! command -v debsums &> /dev/null; then
        echo -e "${warn}Installing debsums...${NC}"
        apt-get update -qq
        apt-get install -y debsums
    fi
    
    echo "Running: debsums $PACKAGE"
    if debsums "$PACKAGE" 2>&1 | tee /tmp/debsums_verify.txt | grep -i "FAILED\|changed"; then
        echo -e "${error}[!] Package verification FAILED - files modified:${NC}"
        cat /tmp/debsums_verify.txt
        return 1
    else
        echo -e "${info}[✓] Package verification PASSED${NC}"
        return 0
    fi
}

# Function to reinstall package
reinstall_package() {
    echo ""
    echo -e "${warn}[!] Reinstalling package: $PACKAGE${NC}"
    
    if [ "$PKG_MGR" = "rpm" ]; then
        $INSTALL_CMD "$PACKAGE"
    else
        $INSTALL_CMD "$PACKAGE"
    fi
    
    if [ $? -eq 0 ]; then
        echo -e "${info}[✓] Package reinstalled successfully${NC}"
        
        # Verify again after reinstall
        echo ""
        echo "=== Post-Reinstall Verification ==="
        if [ "$PKG_MGR" = "rpm" ]; then
            check_rpm
        else
            check_debian
        fi
    else
        echo -e "${error}[!] Package reinstallation FAILED${NC}"
        exit 1
    fi
}

# Main execution
echo "=== Verifying Login Shells ==="
if [ "$PKG_MGR" = "rpm" ]; then
    if ! check_rpm; then
        reinstall_package
    fi
else
    if ! check_debian; then
        reinstall_package
    fi
fi

echo ""
echo "=== Complete ==="