# ⏰ Test-7: Time Configuration Validation

## 📋 Overview
Test-7 validates that target servers have the correct timezone configuration (Pacific/Los Angeles) and NTP synchronization using ntpx.domain.com.

## 🎯 Test Case
**Set time zone (Pacific, Los Angeles) and configure NTP using ntpx.domain.com**

## 🔍 Process Flow
1. **Connect to Target** - Establish SSH connection to target machine based on hostname lookup from EDS
2. **Collect Time Configuration** - Execute time-related commands (timedatectl, chronyc, hwclock) to gather timezone, NTP server, and synchronization data
3. **Validate Time Settings** - Compare collected data against requirements:
   - Timezone: Pacific/Los Angeles (America/Los_Angeles)
   - NTP Server: ntpx.domain.com
   - Chrony Service: Active and running
   - Synchronization: Enabled and functioning

## ✅ Validation Checks

### Critical Tests
- **Connect to Target Server** - Verify SSH connection is established
- **Collect Time Configuration Data** - Gather timedatectl, chrony sources, tracking, and service status
- **Validate Timezone Setting** - Ensure timezone is set to Pacific/Los Angeles
- **Validate Chrony Service Status** - Verify chrony service is active and running
- **Validate NTP Server Configuration** - Confirm ntpx.domain.com is configured as NTP server
- **Validate Time Synchronization Status** - Check that system clock is synchronized

### Normal Tests
- **Comprehensive Time Configuration Validation** - Full validation of all time settings
- **Hardware Clock Verification** - Verify hardware clock configuration
- **NTP Source Analysis** - Analyze NTP source details and statistics
- **Clock Drift Monitoring** - Monitor clock drift and synchronization accuracy

## 📊 Commands Executed

```bash
# Timezone and time configuration
timedatectl
date
cat /etc/timezone
ls -l /etc/localtime

# Chrony service and NTP
systemctl status chronyd
chronyc sources -v
chronyc tracking
chronyc sourcestats

# Hardware clock
hwclock --show
```

## 📁 Output Files
All test results are saved to:
- **Results Directory**: `results/test7/`
- **Data Collection**: `results/test7/data/`
- **Screenshots/Evidence**: `results/test7/screenshots/`

### Generated Files
- `time_configuration_<timestamp>.txt` - Complete time configuration data
- `time_validation_summary_<timestamp>.txt` - Validation results summary
- `ntp_source_analysis_<timestamp>.txt` - Detailed NTP source analysis
- `Test7_Time_Configuration_Executive_Summary.txt` - Executive summary report

## 🚀 Running the Test

### Prerequisites
- SSH access to target server
- Target hostname configured in `settings.resource`
- EDS sheet with IP assignment for target hostname

### Execute Test
```bash
# Run from robotframework root directory
robot -d results/test7 tests/test7_time_configuration_validation/time_configuration_validation.robot

# Run specific test
robot -d results/test7 -t "Critical - Validate Timezone Setting" tests/test7_time_configuration_validation/time_configuration_validation.robot

# Run with specific hostname
robot -d results/test7 -v TARGET_HOSTNAME:server01 tests/test7_time_configuration_validation/time_configuration_validation.robot
```

## 📋 Expected Configuration

| Setting | Expected Value |
|---------|---------------|
| **Timezone** | America/Los_Angeles (Pacific/Los Angeles) |
| **NTP Server** | ntpx.domain.com |
| **Time Service** | Chrony (active) |
| **Synchronization** | Enabled |

## 🎯 Success Criteria
✅ Timezone set to Pacific/Los Angeles
✅ Chrony service active and running
✅ NTP server ntpx.domain.com configured
✅ System clock synchronized
✅ All time configuration data collected and logged

## 📝 Notes
- No EDS validation required for time configuration (independent of EDS sheet)
- Test validates actual server configuration matches expected Pacific timezone and NTP settings
- Valid values must exist for timezone, chrony status, NTP server, and synchronization
- Clock drift and offset metrics are collected for monitoring purposes