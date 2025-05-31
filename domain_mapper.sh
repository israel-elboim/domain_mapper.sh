#!/bin/bash

# ------------------------------
# Domain Mapper v2
# By: israel elboim
# Description: Network scanning, enumeration and exploitation automation tool
# ------------------------------

# ====== COLORS ======
GREEN='\033[1;32m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
MAGENTA='\033[1;35m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# ====== BANNER FUNCTION ======
show_banner() {
    clear
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                      ║"
    echo "║  ██████╗  ██████╗ ███╗   ███╗ █████╗ ██╗███╗   ██╗                 ║"
    echo "║  ██╔══██╗██╔═══██╗████╗ ████║██╔══██╗██║████╗  ██║                 ║"
    echo "║  ██║  ██║██║   ██║██╔████╔██║███████║██║██╔██╗ ██║                 ║"
    echo "║  ██║  ██║██║   ██║██║╚██╔╝██║██╔══██║██║██║╚██╗██║                 ║"
    echo "║  ██████╔╝╚██████╔╝██║ ╚═╝ ██║██║  ██║██║██║ ╚████║                 ║"
    echo "║  ╚═════╝  ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝                 ║"
    echo "║                                                                      ║"
    echo "║      ███╗   ███╗ █████╗ ██████╗ ██████╗ ███████╗██████╗             ║"
    echo "║      ████╗ ████║██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗            ║"
    echo "║      ██╔████╔██║███████║██████╔╝██████╔╝█████╗  ██████╔╝            ║"
    echo "║      ██║╚██╔╝██║██╔══██║██╔═══╝ ██╔═══╝ ██╔══╝  ██╔══██╗            ║"
    echo "║      ██║ ╚═╝ ██║██║  ██║██║     ██║     ███████╗██║  ██║            ║"
    echo "║      ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝     ╚══════╝╚═╝  ╚═╝            ║"
    echo "║                                                                      ║"
    echo -e "║${WHITE}                    Version 2.0 - By israel elboim${CYAN}                    ║"
    echo -e "║${YELLOW}              Network Scanning & Enumeration Tool${CYAN}                   ║"
    echo "║                                                                      ║"
    echo "╚══════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    # System info
    echo -e "${BLUE}┌─ System Information ────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│${WHITE} Hostname: ${GREEN}$(hostname)${NC}$(printf "%*s" $((40-${#$(hostname)})) "")${BLUE}│${NC}"
    echo -e "${BLUE}│${WHITE} User:     ${YELLOW}$(whoami)${NC}$(printf "%*s" $((40-${#$(whoami)})) "")${BLUE}│${NC}"
    echo -e "${BLUE}│${WHITE} Date:     ${CYAN}$(date +'%Y-%m-%d %H:%M:%S')${NC}$(printf "%*s" $((21)) "")${BLUE}│${NC}"
    echo -e "${BLUE}└──────────────────────────────────────────────────────────────┘${NC}"
    echo ""
    
    # Loading animation
    echo -e "${YELLOW}Initializing Domain Mapper"
    for i in {1..3}; do
        sleep 0.3
        echo -n "."
    done
    echo -e " ${GREEN}✓${NC}"
    echo ""
}

# ====== VALIDATION FUNCTIONS ======

validate_ip() {
    local ip=$1
    local IFS='.'
    read -r -a octets <<< "$ip"

    if [[ ${#octets[@]} -ne 4 ]]; then
        return 1
    fi

    for octet in "${octets[@]}"; do
        if ! [[ "$octet" =~ ^[0-9]+$ ]]; then
            return 1
        fi
        if (( octet < 0 || octet > 255 )); then
            return 1
        fi
    done

    return 0
}

validate_cidr() {
    local cidr=$1
    local ip part prefix

    if [[ ! "$cidr" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+$ ]]; then
        return 1
    fi

    if command -v ipcalc &>/dev/null; then
        ipcalc "$cidr" &>/dev/null
        return $?
    fi

    ip=${cidr%%/*}
    prefix=${cidr##*/}

    if ! validate_ip "$ip"; then
        return 1
    fi

    if ! [[ "$prefix" =~ ^[0-9]+$ ]]; then
        return 1
    fi

    if (( prefix < 0 || prefix > 32 )); then
        return 1
    fi

    return 0
}

# ====== CALL BANNER ======
show_banner

# ====== CHECK REQUIRED TOOLS ======
echo -e "${BLUE}[*] Checking required tools...${NC}"
required_tools=(nmap crackmapexec rpcclient smbclient nslookup dhclient)
missing_tools=()

for tool in "${required_tools[@]}"; do
    if command -v "$tool" &>/dev/null; then
        echo -e "${GREEN}  ✓ $tool${NC}"
    else
        echo -e "${RED}  ✗ $tool${NC}"
        missing_tools+=("$tool")
    fi
done

if (( ${#missing_tools[@]} )); then
    echo -e "${RED}[!] Warning: Missing tool(s): ${missing_tools[*]}${NC}"
    echo -e "${YELLOW}[*] Some functionality may not work properly depending on the scan type.${NC}"
else
    echo -e "${GREEN}[+] All required tools are available!${NC}"
fi
echo ""

# ====== LOGGING SETUP ======
setup_logging() {
    echo -e "${BLUE}Do you want to save scan results to a log file? (y/n):${NC}"
    read -r ENABLE_LOGGING
    
    if [[ "$ENABLE_LOGGING" =~ ^[Yy]$ ]]; then
        LOGFILE="scan_$(date +%F_%H-%M-%S).log"
        echo -e "${GREEN}[+] Logging enabled: $LOGFILE${NC}"
        
        {
            echo "╔═══════════════════════════════════════════════════════════════╗"
            echo "║                  DOMAIN MAPPER v2.0 - SCAN LOG               ║"
            echo "╠═══════════════════════════════════════════════════════════════╣"
            echo "║ Date:     $(date)"
            echo "║ Operator: $(whoami)"
            echo "║ System:   $(uname -a)"
            echo "║ Hostname: $(hostname)"
            echo "╚═══════════════════════════════════════════════════════════════╝"
            echo ""
        } > "$LOGFILE"
    else
        LOGFILE=""
        echo -e "${YELLOW}[*] Running without log file${NC}"
    fi
}

# ====== GET SCAN TYPE ======
get_scan_details() {
    echo -e "${CYAN}╔═══════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}            SCAN CONFIGURATION             ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}Choose the purpose of the scan:${NC}"
    echo -e "${WHITE} [1]${NC} Scanning     - No credentials needed"
    echo -e "${WHITE} [2]${NC} Enumeration  - Credentials optional (better with AD user/domain)"
    echo -e "${WHITE} [3]${NC} Exploitation - Requires AD Username and Password"
    echo ""
    
    select PURPOSE in "Scanning" "Enumeration" "Exploitation"; do
        [[ -n "$PURPOSE" ]] && break
        echo -e "${RED}Invalid selection. Try again.${NC}"
    done

    echo -e "${BLUE}Choose $PURPOSE level:${NC}"
    echo -e "${WHITE} [1]${NC} Basic        - Quick scan"
    echo -e "${WHITE} [2]${NC} Intermediate - Detailed scan"  
    echo -e "${WHITE} [3]${NC} Advanced     - Comprehensive scan"
    echo ""
    
    select SCAN_LEVEL in "Basic" "Intermediate" "Advanced"; do
        [[ -n "$SCAN_LEVEL" ]] && break
        echo -e "${RED}Invalid selection. Try again.${NC}"
    done

    # הוספת פרטי הסריקה ללוג
    if [[ -n "$LOGFILE" ]]; then
        {
            echo ">>> SCAN CONFIGURATION:"
            echo "Purpose: $PURPOSE"
            echo "Level: $SCAN_LEVEL"
            echo "Timestamp: $(date)"
            echo "----------------------------------------"
        } >> "$LOGFILE"
    fi

    echo -e "${GREEN}[+] Configuration: $PURPOSE - $SCAN_LEVEL${NC}"
    
    case $PURPOSE in
        Enumeration)
            echo -e "${YELLOW}[!] Enumeration may require AD credentials for detailed results${NC}"
            echo -e "${BLUE}Perform anonymous scan? (y/n):${NC}"
            read ANON_SCAN
            ;;
        Exploitation)
            echo -e "${RED}[!] Exploitation requires valid AD credentials${NC}"
            ;;
    esac
}

# ====== GET USER INPUT ======
get_user_input() {
    echo -e "${BLUE}Enter target(s) – can be a single IP, multiple IPs (space-separated), or CIDR (e.g. 192.168.1.0/24):${NC}"
    read -r TARGET
    TARGET=$(echo "$TARGET" | xargs)

    if [[ -z "$TARGET" ]]; then
        echo -e "${RED}Target cannot be empty.${NC}"
        exit 1
    fi

    # Validation per target
    for t in $TARGET; do
        if [[ "$t" == */* ]]; then
            if ! validate_cidr "$t"; then
                echo -e "${RED}Invalid CIDR: $t${NC}"
                exit 1
            fi
        else
            if ! validate_ip "$t"; then
                echo -e "${RED}Invalid IP address: $t${NC}"
                exit 1
            fi
        fi
    done

    echo -e "${YELLOW}[*] Targets selected: $TARGET${NC}"

    if [[ "$PURPOSE" == "Enumeration" && "$ANON_SCAN" != "y" ]] || [[ "$PURPOSE" == "Exploitation" ]]; then
        read -p "Enter Domain Name: " DOMAIN
        read -p "Enter AD Username: " AD_USER
        if [[ -z "$AD_USER" ]]; then
            echo -e "${RED}AD Username cannot be empty.${NC}"
            exit 1
        fi

        echo -e "${BLUE}Do you want to enter a single password or use a password list?${NC}"
        select PASS_OPTION in "Single Password" "Password List"; do
            [[ -n "$PASS_OPTION" ]] && break
            echo -e "${RED}Invalid selection. Try again.${NC}"
        done

        if [[ "$PASS_OPTION" == "Single Password" ]]; then
            read -s -p "Enter AD Password: " AD_PASS
            echo ""
        else
            read -p "Enter password list (default: rockyou.txt): " PASSWORD_FILE
            PASSWORD_FILE=${PASSWORD_FILE:-rockyou.txt}
            if [[ ! -f "$PASSWORD_FILE" ]]; then
                echo -e "${RED}Password list not found: $PASSWORD_FILE${NC}"
                exit 1
            fi
        fi
    elif [[ "$PURPOSE" == "Enumeration" && "$ANON_SCAN" == "y" ]]; then
        echo -e "${YELLOW}[*] Proceeding with anonymous enumeration...${NC}"
    fi
}

# ====== RUN SCAN WITH OPTIONAL LOGGING ======
run_and_log() {
    # הצגת הפקודה (עם הסתרת סיסמאות)
    local cmd_display="$*"
    cmd_display=$(echo "$cmd_display" | sed 's/-p [^[:space:]]*/[REDACTED]/g')
    
    echo -e "${YELLOW}[*] Running: $cmd_display${NC}"
    
    if [[ -n "$LOGFILE" ]]; then
        # כתיבה ללוג עם הסתרת סיסמאות
        echo -e "\n>>> Command: $cmd_display" >> "$LOGFILE"
        echo ">>> Timestamp: $(date)" >> "$LOGFILE"
        
        # הרצת הפקודה עם tee (מסך + לוג)
        if "$@" | tee -a "$LOGFILE"; then
            echo -e "${GREEN}[✓] Command completed successfully${NC}"
            echo ">>> Status: SUCCESS" >> "$LOGFILE"
        else
            local exit_code=$?
            echo -e "${RED}[✗] Command failed (exit code: $exit_code)${NC}"
            echo ">>> Status: FAILED (exit code: $exit_code)" >> "$LOGFILE"
            return $exit_code
        fi
        echo "---" >> "$LOGFILE"
    else
        # הרצה בלי לוג (רק מסך)
        if "$@"; then
            echo -e "${GREEN}[✓] Command completed successfully${NC}"
        else
            local exit_code=$?
            echo -e "${RED}[✗] Command failed (exit code: $exit_code)${NC}"
            return $exit_code
        fi
    fi
}

# ====== SCANNING ======
perform_scan() {
    echo -e "${GREEN}[+] Performing $SCAN_LEVEL scan on $TARGET...${NC}"
    case $SCAN_LEVEL in
        Basic) run_and_log nmap -Pn "$TARGET";;
        Intermediate) run_and_log nmap -Pn -p- "$TARGET";;
        Advanced) run_and_log nmap -Pn -p- -sU "$TARGET";;
    esac
}

# ====== ENUMERATION ======
perform_enumeration() {
    echo -e "${GREEN}[+] Enumerating $TARGET with $SCAN_LEVEL level...${NC}"
    case $SCAN_LEVEL in
        Basic)
            run_and_log nmap -sV "$TARGET"
            echo "Finding Domain Controller IP..."
            nslookup "$DOMAIN" | grep Address | tail -n 1
            echo "Finding DHCP Server IP..."
            dhclient -v 2>&1 | grep 'bound to' | awk '{print $3}'
            ;;
        Intermediate)
            run_and_log nmap -sV -p 21,22,139,445,3389 "$TARGET"
            if [[ "$ANON_SCAN" == "y" ]]; then
                run_and_log smbclient -L "\\$TARGET" -N
            else
                run_and_log smbclient -L "\\$DOMAIN" -N
            fi
            run_and_log nmap --script smb-os-discovery,smb-enum-shares,smb-enum-users "$TARGET"
            ;;
        Advanced)
            if [[ "$ANON_SCAN" == "y" ]]; then
                run_and_log crackmapexec smb "$TARGET" --shares
                run_and_log crackmapexec smb "$TARGET" --users
            elif [[ -n "$AD_PASS" ]]; then
                run_and_log crackmapexec smb "$TARGET" -u "$AD_USER" -p "$AD_PASS" --users
                run_and_log crackmapexec smb "$TARGET" -u "$AD_USER" -p "$AD_PASS" --groups
                run_and_log crackmapexec smb "$TARGET" -u "$AD_USER" -p "$AD_PASS" --shares
                for cmd in querydominfo enumdomusers enumdomgroups querydispinfo "queryuser $AD_USER"; do
                    run_and_log rpcclient -U "$AD_USER%$AD_PASS" "$TARGET" -c "$cmd"
                done
            elif [[ -n "$PASSWORD_FILE" ]]; then
                run_and_log crackmapexec smb "$TARGET" -u "$AD_USER" -p "$PASSWORD_FILE" --users
                run_and_log crackmapexec smb "$TARGET" -u "$AD_USER" -p "$PASSWORD_FILE" --groups
                run_and_log crackmapexec smb "$TARGET" -u "$AD_USER" -p "$PASSWORD_FILE" --shares
            else
                run_and_log crackmapexec smb "$TARGET" -u "$AD_USER" --users
                run_and_log crackmapexec smb "$TARGET" -u "$AD_USER" --groups
                run_and_log crackmapexec smb "$TARGET" -u "$AD_USER" --shares
            fi
            ;;
    esac
}

# ====== EXPLOITATION ======
perform_exploitation() {
    echo -e "${GREEN}[+] Exploiting $TARGET with $SCAN_LEVEL level...${NC}"
    case $SCAN_LEVEL in
        Basic)
            run_and_log nmap --script vuln "$TARGET";;
        Intermediate)
            if [[ -n "$PASSWORD_FILE" ]]; then
                run_and_log crackmapexec smb "$TARGET" -u "$AD_USER" -p "$PASSWORD_FILE" --pass-pol
            elif [[ -n "$AD_PASS" ]]; then
                run_and_log crackmapexec smb "$TARGET" -u "$AD_USER" -p "$AD_PASS" --pass-pol
            fi
            ;;
        Advanced)
            if [[ -n "$AD_PASS" ]]; then
                run_and_log impacket-getTGT "$AD_USER:$AD_PASS" -dc-ip "$TARGET"
                echo -e "${GREEN}[+] Kerberos ticket extracted.${NC}"
            fi
            ;;
    esac
}

# ====== MAIN EXECUTION ======
setup_logging

while true; do
    get_scan_details
    get_user_input

    case $PURPOSE in
        Scanning) perform_scan;;
        Enumeration) perform_enumeration;;
        Exploitation) perform_exploitation;;
    esac

    echo ""
    if [[ -n "$LOGFILE" ]]; then
        echo -e "${GREEN}[+] Results saved to: $LOGFILE${NC}"
    fi
    
    read -p "Would you like to run another scan? (y/n): " AGAIN
    [[ "$AGAIN" != "y" ]] && break
    echo ""
done

if [[ -n "$LOGFILE" ]]; then
    echo -e "${BLUE}[*] Final log file: $LOGFILE${NC}"
fi

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════╗"
echo "║                    SCAN COMPLETED                        ║"
echo "║              Thank you for using Domain Mapper!         ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "${NC}"
