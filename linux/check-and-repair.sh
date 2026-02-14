#!/bin/bash
# Package integrity checker and auto-repair script
# Usage: ./check-and-repair.sh [package_name]

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${error}Error: This script must be run as root${reset}"
    exit 1
fi

# Detect low-level package manager
if command -v rpm &> /dev/null; then
    VERIFY_COMMAND="rpm -V"
    INSTALL_CMD="${PKG_MAN} reinstall -y"
elif command -v dpkg &> /dev/null; then
    VERIFY_COMMAND="dpkg -V"
    INSTALL_CMD="${PKG_MAN} install --reinstall -y"
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

check_package() {
    echo "Running: $VERIFY_COMMAND $PACKAGE"
    if $VERIFY_COMMAND "$PACKAGE" 2>&1 | tee ./data-files/verify-packages.txt | grep -q .; then
        echo -e "${error}[!] Package verification FAILED - files modified:${reset}"
        cat ./data-files/verify-packages.txt
        return 1
    else
        echo -e "${info}[✓] Package verification PASSED${reset}"
        return 0
    fi
}

reinstall_package() {
    echo ""
    echo -e "${warn}[!] Reinstalling package: $PACKAGE${reset}"
    
    if [ "$PKG_MGR" = "rpm" ]; then
        $INSTALL_CMD "$PACKAGE"
    else
        $INSTALL_CMD "$PACKAGE"
    fi
    
    if [ $? -eq 0 ]; then
        echo -e "${info}[✓] Package reinstalled successfully${reset}"
        
        # Verify again after reinstall
        echo ""
        echo "=== Post-Reinstall Verification ==="
        check_package
    else
        echo -e "${error}[!] Package reinstallation FAILED${reset}"
        exit 1
    fi
}

# Main execution
echo "=== Verifying Login Shells ==="
if ! check_package; then
    reinstall_package
fi

echo ""
echo "=== Complete ==="