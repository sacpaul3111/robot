"""
CBS Lookup Library for Robot Framework
Provides hostname-based configuration lookup from CBS_Itential_DRAFT_v0.01.xlsx
"""

import pandas as pd
import os
import re
from robot.api.logger import info, warn, error


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
                info(f"Available columns: {list(self.server_data.columns)}")
            else:
                error(f"CBS file not found at {self.cbs_file}")
                raise FileNotFoundError(f"CBS file not found: {self.cbs_file}")
        except Exception as e:
            error(f"Error loading CBS data: {str(e)}")
            raise

    def lookup_server_config(self, hostname):
        """Lookup server configuration from CBS sheet based on hostname"""
        if self.server_data is None:
            raise RuntimeError("CBS sheet not available - cannot proceed with validation")

        try:
            # Use correct column name from CBS file "Server Name" 
            hostname_col = "Server Name"
            
            if hostname_col not in self.server_data.columns:
                available_cols = list(self.server_data.columns)
                info(f"Available columns: {available_cols}")
                raise ValueError(f"Column '{hostname_col}' not found in CBS sheet")

            # Find exact hostname match
            mask = self.server_data[hostname_col].astype(str) == hostname
            matching_rows = self.server_data[mask]

            if matching_rows.empty:
                available_hostnames = self.server_data[hostname_col].dropna().tolist()
                error(f"Hostname '{hostname}' not found in CBS sheet")
                info(f"Available hostnames: {available_hostnames}")
                raise ValueError(f"CRITICAL: Hostname '{hostname}' not found in CBS sheet. Cannot proceed with validation.")

            row = matching_rows.iloc[0]
            info(f"Found matching row for hostname '{hostname}'")

            # Extract configuration using correct column names from CBS
            config = {
                'ip': self._extract_ip(row),
                'subnet': self._extract_subnet(row),
                'mask': self._extract_mask(row),
                'gateway': self._extract_gateway(row),
                'cname': self._extract_cname(row),
                'domain': self._extract_domain(row)
            }

            info(f"CBS configuration for {hostname}: {config}")
            return config

        except ValueError:
            raise
        except Exception as e:
            error(f"Error looking up configuration for {hostname}: {str(e)}")
            raise RuntimeError(f"Failed to lookup configuration: {str(e)}")

    def _extract_ip(self, row):
        """Extract IP address from CBS row"""
        try:
            ip_col = "IP Assignment"  # Correct column name from CBS
            
            if ip_col in row.index and pd.notna(row[ip_col]):
                ip_value = str(row[ip_col])
                ip_match = re.search(r'(\d+\.\d+\.\d+\.\d+)', ip_value)
                if ip_match:
                    extracted_ip = ip_match.group(1)
                    info(f"Extracted IP from CBS: {extracted_ip}")
                    return extracted_ip
            
            raise ValueError(f"IP address not found in CBS column '{ip_col}'")
        except Exception as e:
            raise ValueError(f"Failed to extract IP address from CBS: {str(e)}")

    def _extract_subnet(self, row):
        """Extract subnet from CBS row"""
        try:
            subnet_col = "Subnet"
            if subnet_col in row.index and pd.notna(row[subnet_col]):
                subnet_value = str(row[subnet_col])
                info(f"Extracted subnet from CBS: {subnet_value}")
                return subnet_value
            raise ValueError(f"Subnet not found in CBS column '{subnet_col}'")
        except Exception as e:
            raise ValueError(f"Failed to extract subnet from CBS: {str(e)}")

    def _extract_mask(self, row):
        """Extract subnet mask from CBS row"""
        try:
            mask_col = "Mask"
            if mask_col in row.index and pd.notna(row[mask_col]):
                mask_value = str(row[mask_col])
                info(f"Extracted mask from CBS: {mask_value}")
                return mask_value
            raise ValueError(f"Subnet mask not found in CBS column '{mask_col}'")
        except Exception as e:
            raise ValueError(f"Failed to extract subnet mask from CBS: {str(e)}")

    def _extract_gateway(self, row):
        """Extract gateway from CBS row"""
        try:
            gateway_col = "Gateway"
            if gateway_col in row.index and pd.notna(row[gateway_col]):
                gateway_value = str(row[gateway_col])
                info(f"Extracted gateway from CBS: {gateway_value}")
                return gateway_value
            raise ValueError(f"Gateway not found in CBS column '{gateway_col}'")
        except Exception as e:
            raise ValueError(f"Failed to extract gateway from CBS: {str(e)}")

    def _extract_cname(self, row):
        """Extract CNAME from CBS row"""
        try:
            cname_col = "CNAME"
            if cname_col in row.index and pd.notna(row[cname_col]):
                cname_value = str(row[cname_col])
                info(f"Extracted CNAME from CBS: {cname_value}")
                return cname_value
            raise ValueError(f"CNAME not found in CBS column '{cname_col}'")
        except Exception as e:
            raise ValueError(f"Failed to extract CNAME from CBS: {str(e)}")

    def _extract_domain(self, row):
        """Extract domain from CBS row"""
        try:
            domain_col = "DOMAIN"
            if domain_col in row.index and pd.notna(row[domain_col]):
                domain_value = str(row[domain_col])
                info(f"Extracted domain from CBS: {domain_value}")
                return domain_value
            raise ValueError(f"Domain not found in CBS column '{domain_col}'")
        except Exception as e:
            raise ValueError(f"Failed to extract domain from CBS: {str(e)}")
