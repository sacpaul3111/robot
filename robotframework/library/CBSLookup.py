"""
CBS Lookup Library for Robot Framework
Provides hostname-based configuration lookup from CBS_Itential_DRAFT_v0.01.xlsx
"""

import pandas as pd
import os
from robot.api.logger import info, warn


class CBSLookup:
    """Library to lookup server configuration from CBS sheet based on hostname"""

    def __init__(self):
        self.cbs_file = None
        self.server_data = None
        self._load_cbs_data()

    def _load_cbs_data(self):
        """Load CBS sheet data"""
        try:
            # Look for CBS file in the robotframework root directory
            current_dir = os.path.dirname(os.path.abspath(__file__))
            robotframework_root = os.path.dirname(current_dir)
            self.cbs_file = os.path.join(robotframework_root, "CBS_Itential_DRAFT_v0.01.xlsx")

            if os.path.exists(self.cbs_file):
                # Read the Server Requirements sheet
                self.server_data = pd.read_excel(self.cbs_file, sheet_name="Server Requirements")
                info(f"Loaded CBS data from {self.cbs_file}")
            else:
                warn(f"CBS file not found at {self.cbs_file}")
                self.server_data = None
        except Exception as e:
            warn(f"Error loading CBS data: {str(e)}")
            self.server_data = None

    def lookup_server_config(self, hostname):
        """
        Lookup server configuration from CBS sheet based on hostname

        Args:
            hostname (str): The server hostname to lookup

        Returns:
            dict: Configuration dictionary with IP, subnet, gateway, cname, domain
        """
        if self.server_data is None:
            # Return default values if CBS sheet not available
            warn("CBS sheet not available, using default values")
            return self._get_default_config(hostname)

        try:
            # Find row with matching hostname in 'Use PSC Server Naming Convention...' column
            hostname_col = "Use PSC Server Naming Convention to provide the Server Name"

            # Look for the hostname in the data
            mask = self.server_data[hostname_col].astype(str).str.contains(hostname, na=False)
            matching_rows = self.server_data[mask]

            if not matching_rows.empty:
                row = matching_rows.iloc[0]

                # Extract configuration from the matching row
                config = {
                    'ip': self._extract_ip(row),
                    'subnet': self._extract_subnet(row),
                    'mask': self._extract_mask(row),
                    'gateway': self._extract_gateway(row),
                    'cname': self._extract_cname(row),
                    'domain': self._extract_domain(row)
                }

                info(f"Found configuration for {hostname}: {config}")
                return config
            else:
                warn(f"No configuration found for hostname: {hostname}")
                return self._get_default_config(hostname)

        except Exception as e:
            warn(f"Error looking up configuration for {hostname}: {str(e)}")
            return self._get_default_config(hostname)

    def _extract_ip(self, row):
        """Extract IP address from row"""
        try:
            ip_col = "IP Assignments"
            ip_value = row[ip_col]
            if pd.notna(ip_value):
                # Extract IP address from the cell (may contain additional text)
                import re
                ip_match = re.search(r'(\d+\.\d+\.\d+\.\d+)', str(ip_value))
                if ip_match:
                    return ip_match.group(1)
            return "10.26.216.107"  # Default from alhxvdvitap01
        except:
            return "10.26.216.107"

    def _extract_subnet(self, row):
        """Extract subnet from row"""
        try:
            subnet_col = "Subnet"
            subnet_value = row[subnet_col]
            if pd.notna(subnet_value):
                return str(subnet_value)
            return "10.26.216.0/24"  # Default
        except:
            return "10.26.216.0/24"

    def _extract_mask(self, row):
        """Extract subnet mask from row"""
        try:
            mask_col = "Mask"
            mask_value = row[mask_col]
            if pd.notna(mask_value):
                return str(mask_value)
            return "255.255.255.0"  # Default
        except:
            return "255.255.255.0"

    def _extract_gateway(self, row):
        """Extract gateway from row"""
        try:
            gateway_col = "Gateway"
            gateway_value = row[gateway_col]
            if pd.notna(gateway_value):
                return str(gateway_value)
            return "10.26.216.4"  # Default from alhxvdvitap01
        except:
            return "10.26.216.4"

    def _extract_cname(self, row):
        """Extract CNAME from row"""
        try:
            cname_col = "CNAME"
            cname_value = row[cname_col]
            if pd.notna(cname_value):
                return str(cname_value)
            # Fallback to hostname column
            hostname_col = "Use PSC Server Naming Convention to provide the Server Name"
            hostname_value = row[hostname_col]
            if pd.notna(hostname_value):
                return str(hostname_value)
            return "unknown"
        except:
            return "unknown"

    def _extract_domain(self, row):
        """Extract domain from row"""
        try:
            domain_col = "DOMAIN"
            domain_value = row[domain_col]
            if pd.notna(domain_value):
                return str(domain_value)
            return "gnscet.com"  # Default
        except:
            return "gnscet.com"

    def _get_default_config(self, hostname):
        """Return default configuration when lookup fails"""
        return {
            'ip': "10.26.216.107",
            'subnet': "10.26.216.0/24",
            'mask': "255.255.255.0",
            'gateway': "10.26.216.4",
            'cname': hostname,
            'domain': "gnscet.com"
        }