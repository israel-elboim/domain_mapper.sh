# Domain Mapper v2.0



## 🔍 Overview

Domain Mapper is a comprehensive bash-based penetration testing tool that automates network scanning, enumeration, and exploitation tasks. Designed for security professionals and ethical hackers.

## ✨ Features

- **Three Scan Modes**: Scanning, Enumeration, Exploitation
- **Multiple Difficulty Levels**: Basic, Intermediate, Advanced
- **Guided Wizard Mode**: Perfect for beginners
- **Automated Logging**: Text logs + PDF reports
- **Domain Controller Discovery**: DHCP & DNS enumeration
- **SMB Analysis**: Share enumeration, user extraction, vulnerability scanning
- **Password Attacks**: Spraying, brute force, Kerberoasting
- **Progress Tracking**: Real-time progress with visual indicators

## 🛠️ Required Tools

```bash
nmap crackmapexec rpcclient smbclient hydra enum4linux
impacket-getTGT nslookup dhclient
```

## 🚀 Quick Start

1. **Make executable:**
   ```bash
   chmod +x domain_mapper.sh
   ```

2. **Run the tool:**
   ```bash
   sudo ./domain_mapper.sh
   ```

3. **Choose your mode:**
   - **Wizard Mode**: Guided setup for beginners
   - **Manual Mode**: Full configuration control

## 📋 Usage Examples

### Basic Network Scan
```bash
# Single IP
192.168.1.10

# Multiple IPs  
192.168.1.10 192.168.1.20 192.168.1.30

# CIDR Range
192.168.1.0/24
```

### Domain Enumeration
- **Domain**: `COMPANY.LOCAL`
- **Username**: `administrator` or `user@domain.com`
- **Password**: Single password or wordlist file

## 📊 Scan Levels

| Level | Description | Use Case |
|-------|-------------|----------|
| **Basic** | Quick scan with essential checks | Initial reconnaissance |
| **Intermediate** | Detailed service enumeration | Standard penetration testing |
| **Advanced** | Comprehensive scan with full enumeration | In-depth security assessment |

## 🎯 Scan Purposes

### 🔍 Scanning
- Network discovery
- Port scanning (TCP/UDP)
- Service identification

### 📈 Enumeration  
- SMB share enumeration
- User and group extraction
- Domain controller discovery
- Password policy analysis

### ⚡ Exploitation
- Vulnerability scanning
- Password spraying attacks
- Kerberoasting
- Hash extraction

## 📝 Output

- **Real-time display**: Colored output with progress tracking
- **Text logs**: Detailed scan results with timestamps
- **PDF reports**: Professional documentation format

## ⚠️ Disclaimer

**FOR EDUCATIONAL AND AUTHORIZED TESTING ONLY**

This tool is intended for:
- Learning cybersecurity concepts
- Authorized penetration testing
- Security assessments with proper permission

**DO NOT USE** on systems you don't own or lack explicit authorization to test.

## 📄 License

Educational use only. Use responsibly and ethically.

---

*Domain Mapper v2.0 - Complete Network Assessment Tool*
