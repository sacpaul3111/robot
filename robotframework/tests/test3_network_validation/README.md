# 🤖 Test Cases - Test-3

## 🌐 Hostname Validation Test Suite

### 📋 **Test Overview**
This folder contains Test-3 hostname validation suite that validates server configurations against EDS_Itential_DRAFT_v0.01.xlsx requirements. The hostname is parsed by Itential when calling the Robot test case.

### 📁 **Test Files**
- **`network_validation.robot`** - Main hostname and network validation test suite
- **`variables.resource`** - Configuration variables including target hostname from Itential
- **`network_keywords.resource`** - Custom keywords for network testing

### 🚀 **How to Run**

```bash
# From the robotframework root directory:
cd tests/test3

# Run with default hostname (alhxvdvitap01)
robot --outputdir ../../results/results_test3/html_reports --name "Hostname Validation Test-3" network_validation.robot

# Run with hostname from Itential workflow (variable override)
robot --variable TARGET_HOSTNAME:your_hostname --variable TARGET_IP:your_ip --outputdir ../../results/results_test3/html_reports network_validation.robot

# This generates:
# ../../results/results_test3/html_reports/log.html     - Detailed execution log
# ../../results/results_test3/html_reports/report.html  - Interactive test report
# ../../results/results_test3/html_reports/output.xml   - Machine-readable results
```

### 📊 **Test Categories**

#### **Critical Tests:**
1. **🔧 Hostname Validation**
   - Tags: `critical`, `hostname`, `compliance`, `itential`
   - Validates hostname matches EDS_Itential_DRAFT requirements

2. **🌐 IP Address Validation**
   - Tags: `critical`, `networking`, `ip`, `compliance`
   - Validates IP address configuration (Expected: 10.26.216.107)

3. **🌍 Subnet Validation**
   - Tags: `critical`, `networking`, `subnet`, `compliance`
   - Validates subnet configuration (Expected: 10.26.216.0/24)

4. **🛣️ Gateway Validation**
   - Tags: `critical`, `networking`, `gateway`, `compliance`
   - Validates default gateway configuration (Expected: 10.26.216.4)

5. **🌐 DNS Name Validation**
   - Tags: `critical`, `dns`, `hostname`, `compliance`
   - Validates DNS name configuration (Expected CNAME: alhxvdvitap01, Domain: gnscet.com)

#### **Normal Tests:**
6. **📈 NTP Configuration Validation**
   - Tags: `normal`, `time`, `ntp`, `configuration`
   - Validates Network Time Protocol configuration and synchronization

### 🎯 **Test Features**
- **✅ Hostname Compliance**: Validates against EDS_Itential_DRAFT_v0.01.xlsx specs
- **🔄 Itential Integration**: Supports hostname variables from Itential workflow
- **📊 Network Validation**: IP, subnet, gateway, DNS name, and NTP verification
- **🎨 Enhanced Reporting**: Emoji-enhanced console output and executive summaries
- **📈 Real-time Statistics**: Live test counters during execution
- **🌐 DNS Validation**: Validates CNAME and domain configuration

### 📋 **Default Target Configuration**
Based on EDS_Itential_DRAFT_v0.01.xlsx for `alhxvdvitap01`:
- **Hostname**: alhxvdvitap01
- **IP Address**: 10.26.216.107
- **Subnet**: 10.26.216.0/24 (255.255.255.0)
- **Gateway**: 10.26.216.4
- **CNAME**: alhxvdvitap01
- **Domain**: gnscet.com
- **Environment**: Development QA
- **OS**: RHEL 9.6
- **Purpose**: Itential All-In-One automation platform

### 🔄 **Itential Workflow Integration**
The test supports variable override from Itential workflows:
```bash
# Example: Override hostname and DNS from Itential
robot --variable TARGET_HOSTNAME:new_hostname \
      --variable TARGET_IP:10.26.216.108 \
      --variable TARGET_GATEWAY:10.26.216.4 \
      --variable TARGET_CNAME:new_hostname \
      --variable TARGET_DOMAIN:gnscet.com \
      network_validation.robot
```

### 📁 **Results Location**
Test results are stored in: `../../results/results_test3/`
- Executive summaries in `reports/` folder
- Raw data in `data/` folder
- HTML reports generated when running tests

### 🌟 **Expected Results**
Tests may fail if current system doesn't match EDS_Itential_DRAFT requirements:
- Hostname validation against expected naming convention
- IP address matches expected configuration
- Subnet and gateway properly configured
- DNS name (CNAME/Domain) matches expected values
- NTP service running and synchronized