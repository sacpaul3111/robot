"""
EDS Lookup Library for Robot Framework
Provides hostname-based configuration lookup from EDS_Itential_DRAFT_v0.01.xlsx
"""

import pandas as pd
import os
import re
from robot.api.logger import info, warn, error


class EDSLookup:
    """Library to lookup server configuration from EDS sheet based on hostname"""

    def __init__(self):
        self.eds_file = None
        self.server_data = None
        self._load_eds_data()

    def _load_eds_data(self):
        """Load EDS sheet data"""
        try:
            # Look for EDS file in the robotframework root directory
            current_dir = os.path.dirname(os.path.abspath(__file__))
            robotframework_root = os.path.dirname(current_dir)
            self.eds_file = os.path.join(robotframework_root, "EDS_Itential_DRAFT_v0.01.xlsx")

            if os.path.exists(self.eds_file):
                # Read the Server Requirements sheet
                self.server_data = pd.read_excel(self.eds_file, sheet_name="Server Requirements")
                info(f"Loaded EDS data from {self.eds_file}")
                info(f"Available columns: {list(self.server_data.columns)}")
            else:
                error(f"EDS file not found at {self.eds_file}")
                raise FileNotFoundError(f"EDS file not found: {self.eds_file}")
        except Exception as e:
            error(f"Error loading EDS data: {str(e)}")
            raise

    def lookup_server_config(self, hostname):
        """Lookup server configuration from EDS sheet based on hostname"""
        if self.server_data is None:
            raise RuntimeError("EDS sheet not available - cannot proceed with validation")

        try:
            # Use correct column name from EDS file "Server Name"
            hostname_col = "Server Name"

            if hostname_col not in self.server_data.columns:
                available_cols = list(self.server_data.columns)
                info(f"Available columns: {available_cols}")
                raise ValueError(f"Column '{hostname_col}' not found in EDS sheet")

            # Find exact hostname match
            mask = self.server_data[hostname_col].astype(str) == hostname
            matching_rows = self.server_data[mask]

            if matching_rows.empty:
                available_hostnames = self.server_data[hostname_col].dropna().tolist()
                error(f"Hostname '{hostname}' not found in EDS sheet")
                info(f"Available hostnames: {available_hostnames}")
                raise ValueError(f"CRITICAL: Hostname '{hostname}' not found in EDS sheet. Cannot proceed with validation.")

            row = matching_rows.iloc[0]
            info(f"Found matching row for hostname '{hostname}'")

            # Extract configuration using actual EDS column names
            # All extractions use safe method - returns 'N/A' if column doesn't exist or is empty
            config = {
                # Network Configuration
                'ip': self._extract_ip(row),
                'subnet': self._extract_safe(row, 'Subnet', 'N/A'),
                'mask': self._extract_safe(row, 'Mask', 'N/A'),
                'gateway': self._extract_safe(row, 'Gateway', 'N/A'),
                'cname': self._extract_safe(row, 'CNAME', 'N/A'),
                'domain': self._extract_safe(row, 'DOMAIN', 'N/A'),
                'vlan_number': self._extract_safe(row, 'VLAN Number', 'N/A'),
                'vlan_id': self._extract_safe(row, 'VLAN ID (Description of VLAN)', 'N/A'),
                'teaming_bonding': self._extract_safe(row, 'Teaming Bonding (Y/N)', 'N/A'),

                # Server Configuration
                'host_description': self._extract_safe(row, 'Host Description', 'N/A'),
                'cluster_name': self._extract_safe(row, 'Cluster Name', 'N/A'),
                'container_type': self._extract_safe(row, 'Container Type', 'N/A'),
                'type': self._extract_safe(row, 'Type', 'N/A'),
                'purpose': self._extract_safe(row, 'Purpose', 'N/A'),
                'classification': self._extract_safe(row, 'Classification', 'N/A'),
                'site': self._extract_safe(row, 'Site', 'N/A'),
                'environment': self._extract_safe(row, 'Environment', 'N/A'),
                'trust_level': self._extract_safe(row, 'Trust Level', 'N/A'),
                'os_type': self._extract_safe(row, 'OS Type', 'N/A'),

                # Hardware Configuration
                'cpu_cores': self._extract_safe(row, 'Number of CPU Cores (recom)', 'N/A'),
                'ram': self._extract_safe(row, 'RAM', 'N/A'),

                # Storage Configuration
                'storage_type': self._extract_safe(row, 'Storage Type', 'N/A'),
                'storage_total_tb': self._extract_safe(row, 'Storage Total TB', 'N/A'),
                'drive_volume_group': self._extract_safe(row, 'Drive or Volume Group', 'N/A'),
                'file_system': self._extract_safe(row, 'Files System', 'N/A'),
                'logical_volume_partition': self._extract_safe(row, 'Logical Volume Name/Partition (Mounted On)', 'N/A'),
                'storage_allocation_gb': self._extract_safe(row, 'Storage Allocation (GB)', 'N/A'),
                'recommended_storage_gb': self._extract_safe(row, 'Recommended Storage Allocation (GB)', 'N/A'),
                'drive_purpose': self._extract_safe(row, 'Drive Purpose', 'N/A'),

                # Additional fields that may or may not exist in EDS
                'vxrail_cluster': self._extract_safe(row, 'VxRail Cluster', 'N/A'),
                'vcenter_host': self._extract_safe(row, 'vCenter Host', 'N/A'),
                'vm_hardware_version': self._extract_safe(row, 'VM Hardware Version', 'N/A'),
                'vm_memory_reservation': self._extract_safe(row, 'VM Memory Reservation', 'N/A'),
                'vm_cpu_reservation': self._extract_safe(row, 'VM CPU Reservation', 'N/A')
            }

            info(f"EDS configuration for {hostname}: {config}")
            return config

        except ValueError:
            raise
        except Exception as e:
            error(f"Error looking up configuration for {hostname}: {str(e)}")
            raise RuntimeError(f"Failed to lookup configuration: {str(e)}")

    def _extract_ip(self, row):
        """Extract IP address from EDS row"""
        try:
            ip_col = "IP Assignment"  # Correct column name from EDS
            
            if ip_col in row.index and pd.notna(row[ip_col]):
                ip_value = str(row[ip_col])
                ip_match = re.search(r'(\d+\.\d+\.\d+\.\d+)', ip_value)
                if ip_match:
                    extracted_ip = ip_match.group(1)
                    info(f"Extracted IP from EDS: {extracted_ip}")
                    return extracted_ip

            raise ValueError(f"IP address not found in EDS column '{ip_col}'")
        except Exception as e:
            raise ValueError(f"Failed to extract IP address from EDS: {str(e)}")

    def _extract_subnet(self, row):
        """Extract subnet from EDS row"""
        try:
            subnet_col = "Subnet"
            if subnet_col in row.index and pd.notna(row[subnet_col]):
                subnet_value = str(row[subnet_col])
                info(f"Extracted subnet from EDS: {subnet_value}")
                return subnet_value
            raise ValueError(f"Subnet not found in EDS column '{subnet_col}'")
        except Exception as e:
            raise ValueError(f"Failed to extract subnet from EDS: {str(e)}")

    def _extract_mask(self, row):
        """Extract subnet mask from EDS row"""
        try:
            mask_col = "Mask"
            if mask_col in row.index and pd.notna(row[mask_col]):
                mask_value = str(row[mask_col])
                info(f"Extracted mask from EDS: {mask_value}")
                return mask_value
            raise ValueError(f"Subnet mask not found in EDS column '{mask_col}'")
        except Exception as e:
            raise ValueError(f"Failed to extract subnet mask from EDS: {str(e)}")

    def _extract_gateway(self, row):
        """Extract gateway from EDS row"""
        try:
            gateway_col = "Gateway"
            if gateway_col in row.index and pd.notna(row[gateway_col]):
                gateway_value = str(row[gateway_col])
                info(f"Extracted gateway from EDS: {gateway_value}")
                return gateway_value
            raise ValueError(f"Gateway not found in EDS column '{gateway_col}'")
        except Exception as e:
            raise ValueError(f"Failed to extract gateway from EDS: {str(e)}")

    def _extract_cname(self, row):
        """Extract CNAME from EDS row"""
        try:
            cname_col = "CNAME"
            if cname_col in row.index and pd.notna(row[cname_col]):
                cname_value = str(row[cname_col])
                info(f"Extracted CNAME from EDS: {cname_value}")
                return cname_value
            raise ValueError(f"CNAME not found in EDS column '{cname_col}'")
        except Exception as e:
            raise ValueError(f"Failed to extract CNAME from EDS: {str(e)}")

    def _extract_domain(self, row):
        """Extract domain from EDS row"""
        try:
            domain_col = "DOMAIN"
            if domain_col in row.index and pd.notna(row[domain_col]):
                domain_value = str(row[domain_col])
                info(f"Extracted domain from EDS: {domain_value}")
                return domain_value
            raise ValueError(f"Domain not found in EDS column '{domain_col}'")
        except Exception as e:
            raise ValueError(f"Failed to extract domain from EDS: {str(e)}")

    def _extract_cpu_cores(self, row):
        """Extract CPU cores from EDS row"""
        try:
            cpu_col = "Number of CPU Cores (recom)"
            if cpu_col in row.index and pd.notna(row[cpu_col]):
                cpu_value = str(row[cpu_col])
                info(f"Extracted CPU cores from EDS: {cpu_value}")
                return cpu_value
            raise ValueError(f"CPU cores not found in EDS column '{cpu_col}'")
        except Exception as e:
            raise ValueError(f"Failed to extract CPU cores from EDS: {str(e)}")

    def _extract_ram(self, row):
        """Extract RAM from EDS row"""
        try:
            ram_col = "RAM"
            if ram_col in row.index and pd.notna(row[ram_col]):
                ram_value = str(row[ram_col])
                info(f"Extracted RAM from EDS: {ram_value}")
                return ram_value
            raise ValueError(f"RAM not found in EDS column '{ram_col}'")
        except Exception as e:
            raise ValueError(f"Failed to extract RAM from EDS: {str(e)}")

    def _extract_storage_type(self, row):
        """Extract storage type from EDS row"""
        try:
            storage_col = "Storage Type"
            if storage_col in row.index and pd.notna(row[storage_col]):
                storage_value = str(row[storage_col])
                info(f"Extracted storage type from EDS: {storage_value}")
                return storage_value
            raise ValueError(f"Storage type not found in EDS column '{storage_col}'")
        except Exception as e:
            raise ValueError(f"Failed to extract storage type from EDS: {str(e)}")

    def _extract_storage_total_tb(self, row):
        """Extract total storage TB from EDS row"""
        try:
            storage_col = "Storage Total TB"
            if storage_col in row.index and pd.notna(row[storage_col]):
                storage_value = str(row[storage_col])
                info(f"Extracted storage total TB from EDS: {storage_value}")
                return storage_value
            raise ValueError(f"Storage total TB not found in EDS column '{storage_col}'")
        except Exception as e:
            raise ValueError(f"Failed to extract storage total TB from EDS: {str(e)}")

    def _extract_drive_volume_group(self, row):
        """Extract drive/volume group from EDS row"""
        try:
            drive_col = "Drive or Volume Group"
            if drive_col in row.index and pd.notna(row[drive_col]):
                drive_value = str(row[drive_col])
                info(f"Extracted drive/volume group from EDS: {drive_value}")
                return drive_value
            raise ValueError(f"Drive/volume group not found in EDS column '{drive_col}'")
        except Exception as e:
            raise ValueError(f"Failed to extract drive/volume group from EDS: {str(e)}")

    def _extract_file_system(self, row):
        """Extract file system from EDS row"""
        try:
            fs_col = "Files System"
            if fs_col in row.index and pd.notna(row[fs_col]):
                fs_value = str(row[fs_col])
                info(f"Extracted file system from EDS: {fs_value}")
                return fs_value
            raise ValueError(f"File system not found in EDS column '{fs_col}'")
        except Exception as e:
            raise ValueError(f"Failed to extract file system from EDS: {str(e)}")

    def _extract_logical_volume_partition(self, row):
        """Extract logical volume/partition from EDS row"""
        try:
            lv_col = "Logical Volume Name/Partition (Mounted On)"
            if lv_col in row.index and pd.notna(row[lv_col]):
                lv_value = str(row[lv_col])
                info(f"Extracted logical volume/partition from EDS: {lv_value}")
                return lv_value
            raise ValueError(f"Logical volume/partition not found in EDS column '{lv_col}'")
        except Exception as e:
            raise ValueError(f"Failed to extract logical volume/partition from EDS: {str(e)}")

    def _extract_storage_allocation_gb(self, row):
        """Extract storage allocation GB from EDS row"""
        try:
            alloc_col = "Storage Allocation (GB)"
            if alloc_col in row.index and pd.notna(row[alloc_col]):
                alloc_value = str(row[alloc_col])
                info(f"Extracted storage allocation GB from EDS: {alloc_value}")
                return alloc_value
            raise ValueError(f"Storage allocation GB not found in EDS column '{alloc_col}'")
        except Exception as e:
            raise ValueError(f"Failed to extract storage allocation GB from EDS: {str(e)}")

    def _extract_recommended_storage_gb(self, row):
        """Extract recommended storage allocation GB from EDS row"""
        try:
            rec_col = "Recommended Storage Allocation (GB)"
            if rec_col in row.index and pd.notna(row[rec_col]):
                rec_value = str(row[rec_col])
                info(f"Extracted recommended storage allocation GB from EDS: {rec_value}")
                return rec_value
            raise ValueError(f"Recommended storage allocation GB not found in EDS column '{rec_col}'")
        except Exception as e:
            raise ValueError(f"Failed to extract recommended storage allocation GB from EDS: {str(e)}")

    def _extract_drive_purpose(self, row):
        """Extract drive purpose from EDS row"""
        try:
            purpose_col = "Drive Purpose"
            if purpose_col in row.index and pd.notna(row[purpose_col]):
                purpose_value = str(row[purpose_col])
                info(f"Extracted drive purpose from EDS: {purpose_value}")
                return purpose_value
            raise ValueError(f"Drive purpose not found in EDS column '{purpose_col}'")
        except Exception as e:
            raise ValueError(f"Failed to extract drive purpose from EDS: {str(e)}")

    def _extract_os_type(self, row):
        """Extract OS type from EDS row"""
        try:
            os_col = "OS Type"
            if os_col in row.index and pd.notna(row[os_col]):
                os_value = str(row[os_col])
                info(f"Extracted OS type from EDS: {os_value}")
                return os_value
            raise ValueError(f"OS type not found in EDS column '{os_col}'")
        except Exception as e:
            raise ValueError(f"Failed to extract OS type from EDS: {str(e)}")

    def _extract_safe(self, row, column_name, default='N/A'):
        """Safely extract a value from EDS row, returning default if not found"""
        try:
            if column_name in row.index and pd.notna(row[column_name]):
                value = str(row[column_name])
                info(f"Extracted {column_name} from EDS: {value}")
                return value
            info(f"{column_name} not found in EDS, using default: {default}")
            return default
        except Exception as e:
            warn(f"Error extracting {column_name} from EDS: {str(e)}, using default: {default}")
            return default