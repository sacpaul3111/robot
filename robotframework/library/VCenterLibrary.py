"""
VCenter Library for Robot Framework - Datastore Operations
Provides vCenter connectivity and datastore management for Test-9
"""

from pyVim.connect import SmartConnect, Disconnect
from pyVmomi import vim
import ssl
import atexit
from robot.api.logger import info, warn, error


class VCenterLibrary:
    """Library for vCenter datastore operations and VM management"""

    ROBOT_LIBRARY_SCOPE = 'GLOBAL'

    def __init__(self):
        self.service_instance = None
        self.content = None
        self.connection = None

    def vcenter_connect(self, vcenter_host, username, password, port=443, verify_ssl=False):
        """
        Connect to vCenter server

        Args:
            vcenter_host: vCenter server hostname or IP
            username: vCenter username
            password: vCenter password
            port: vCenter port (default: 443)
            verify_ssl: Whether to verify SSL certificate (default: False)

        Returns:
            connection: Connection object/identifier
        """
        try:
            info(f"Connecting to vCenter: {vcenter_host}")

            # Validate inputs
            if not username:
                raise ValueError("vCenter username not provided")
            if not password:
                raise ValueError("vCenter password not provided")
            if not vcenter_host:
                raise ValueError("vCenter host not provided")

            # Create SSL context
            if not verify_ssl:
                ssl_context = ssl._create_unverified_context()
            else:
                ssl_context = ssl.create_default_context()

            # Connect to vCenter
            self.service_instance = SmartConnect(
                host=vcenter_host,
                user=username,
                pwd=password,
                port=int(port),
                sslContext=ssl_context
            )

            if not self.service_instance:
                raise RuntimeError("Failed to connect to vCenter")

            # Register disconnect at exit
            atexit.register(Disconnect, self.service_instance)

            # Get content
            self.content = self.service_instance.RetrieveContent()

            # Store connection identifier
            self.connection = {
                'host': vcenter_host,
                'service_instance': self.service_instance,
                'content': self.content
            }

            info(f"Successfully connected to vCenter: {vcenter_host}")

            return self.connection

        except Exception as e:
            error(f"Failed to connect to vCenter {vcenter_host}: {str(e)}")
            raise RuntimeError(f"vCenter connection failed: {str(e)}")

    def vcenter_disconnect(self, connection):
        """Disconnect from vCenter"""
        try:
            if connection and connection.get('service_instance'):
                Disconnect(connection['service_instance'])
                info("Disconnected from vCenter")
                self.service_instance = None
                self.content = None
                self.connection = None
        except Exception as e:
            warn(f"Error disconnecting from vCenter: {str(e)}")

    def vcenter_verify_connection(self, connection):
        """
        Verify vCenter connection is active

        Args:
            connection: Connection object

        Returns:
            bool: True if connection is active
        """
        try:
            if not connection or not connection.get('content'):
                return False

            # Try to access content to verify connection
            _ = connection['content'].about.fullName
            return True
        except Exception as e:
            warn(f"Connection verification failed: {str(e)}")
            return False

    def vcenter_find_host_in_cluster(self, connection, cluster_name, host_name):
        """
        Find an ESXi host within a cluster

        Args:
            connection: vCenter connection object
            cluster_name: Name of the cluster
            host_name: Name of the host to find

        Returns:
            bool: True if host found in cluster
        """
        try:
            content = connection['content']

            # Find the cluster
            cluster = self._find_cluster_by_name(content, cluster_name)
            if not cluster:
                error(f"Cluster '{cluster_name}' not found")
                return False

            # Search for host in cluster
            for host in cluster.host:
                if host.name == host_name or host_name in host.name:
                    info(f"Host '{host_name}' found in cluster '{cluster_name}'")
                    return True

            warn(f"Host '{host_name}' not found in cluster '{cluster_name}'")
            return False

        except Exception as e:
            error(f"Error finding host in cluster: {str(e)}")
            return False

    def vcenter_get_vm_datastore_assignments(self, connection, host_name):
        """
        Get VM to datastore assignments for a specific host

        Args:
            connection: vCenter connection object
            host_name: Name of the ESXi host

        Returns:
            list: List of VM datastore assignments
        """
        try:
            content = connection['content']
            assignments = []

            # Find the host
            host = self._find_host_by_name(content, host_name)
            if not host:
                error(f"Host '{host_name}' not found")
                return assignments

            # Get all VMs on this host
            for vm in host.vm:
                if vm.config:
                    vm_info = {
                        'vm_name': vm.name,
                        'datastores': [],
                        'power_state': str(vm.runtime.powerState)
                    }

                    # Get datastores for this VM
                    if vm.datastore:
                        for ds in vm.datastore:
                            vm_info['datastores'].append({
                                'name': ds.name,
                                'type': ds.summary.type if hasattr(ds.summary, 'type') else 'Unknown'
                            })

                    assignments.append(vm_info)
                    info(f"VM: {vm.name} - Datastores: {[ds['name'] for ds in vm_info['datastores']]}")

            return assignments

        except Exception as e:
            error(f"Error getting VM datastore assignments: {str(e)}")
            return []

    def vcenter_get_datastore_capacity(self, connection, host_name):
        """
        Get capacity information for datastores on a host

        Args:
            connection: vCenter connection object
            host_name: Name of the ESXi host

        Returns:
            list: List of datastore capacity information
        """
        try:
            content = connection['content']
            capacity_data = []

            # Find the host
            host = self._find_host_by_name(content, host_name)
            if not host:
                error(f"Host '{host_name}' not found")
                return capacity_data

            # Get datastores for this host
            for ds in host.datastore:
                capacity_gb = round(ds.summary.capacity / (1024**3), 2)
                free_gb = round(ds.summary.freeSpace / (1024**3), 2)
                used_gb = capacity_gb - free_gb
                used_percent = round((used_gb / capacity_gb) * 100, 2) if capacity_gb > 0 else 0
                free_percent = round((free_gb / capacity_gb) * 100, 2) if capacity_gb > 0 else 0

                ds_info = {
                    'name': ds.name,
                    'type': ds.summary.type,
                    'total_gb': capacity_gb,
                    'free_gb': free_gb,
                    'used_gb': used_gb,
                    'used_percent': used_percent,
                    'free_percent': free_percent,
                    'accessible': ds.summary.accessible
                }

                capacity_data.append(ds_info)
                info(f"Datastore: {ds.name} - Total: {capacity_gb}GB, Free: {free_gb}GB ({free_percent}%)")

            return capacity_data

        except Exception as e:
            error(f"Error getting datastore capacity: {str(e)}")
            return []

    def vcenter_get_datastore_performance_tiers(self, connection, host_name):
        """
        Get performance tier classification for datastores

        Args:
            connection: vCenter connection object
            host_name: Name of the ESXi host

        Returns:
            list: List of datastore performance tier information
        """
        try:
            content = connection['content']
            performance_data = []

            # Find the host
            host = self._find_host_by_name(content, host_name)
            if not host:
                error(f"Host '{host_name}' not found")
                return performance_data

            # Get datastores and classify by performance tier
            for ds in host.datastore:
                storage_type = ds.summary.type

                # Determine performance tier based on storage type and name
                performance_tier = self._classify_performance_tier(ds.name, storage_type)

                tier_info = {
                    'name': ds.name,
                    'storage_type': storage_type,
                    'performance_tier': performance_tier
                }

                performance_data.append(tier_info)
                info(f"Datastore: {ds.name} - Type: {storage_type}, Tier: {performance_tier}")

            return performance_data

        except Exception as e:
            error(f"Error getting datastore performance tiers: {str(e)}")
            return []

    def vcenter_get_datastore_subscription_levels(self, connection, host_name):
        """
        Get subscription levels and overprovisioning ratios for datastores

        Args:
            connection: vCenter connection object
            host_name: Name of the ESXi host

        Returns:
            list: List of datastore subscription information
        """
        try:
            content = connection['content']
            subscription_data = []

            # Find the host
            host = self._find_host_by_name(content, host_name)
            if not host:
                error(f"Host '{host_name}' not found")
                return subscription_data

            # Calculate subscription for each datastore
            for ds in host.datastore:
                capacity_gb = round(ds.summary.capacity / (1024**3), 2)

                # Calculate provisioned space from all VMs using this datastore
                provisioned_gb = 0
                if hasattr(ds, 'vm'):
                    for vm in ds.vm:
                        if vm.config:
                            # Sum all virtual disk capacities
                            for device in vm.config.hardware.device:
                                if isinstance(device, vim.vm.device.VirtualDisk):
                                    provisioned_gb += round(device.capacityInBytes / (1024**3), 2)

                # Calculate subscription ratio
                subscription_ratio = round(provisioned_gb / capacity_gb, 2) if capacity_gb > 0 else 0

                sub_info = {
                    'name': ds.name,
                    'capacity_gb': capacity_gb,
                    'provisioned_gb': provisioned_gb,
                    'subscription_ratio': subscription_ratio
                }

                subscription_data.append(sub_info)
                info(f"Datastore: {ds.name} - Provisioned: {provisioned_gb}GB, Ratio: {subscription_ratio}:1")

            return subscription_data

        except Exception as e:
            error(f"Error getting datastore subscription levels: {str(e)}")
            return []

    def vcenter_capture_host_screenshot(self, connection, host_name, screenshot_path):
        """
        Capture screenshot of host configuration (placeholder - requires web UI automation)

        Args:
            connection: vCenter connection object
            host_name: Name of the ESXi host
            screenshot_path: Path to save screenshot

        Returns:
            str: Path to saved screenshot
        """
        try:
            # This is a placeholder - actual screenshot capture would require
            # Selenium WebDriver or similar to capture vCenter web UI

            warn("Screenshot capture requires web UI automation - generating placeholder")

            # Create a placeholder file
            with open(screenshot_path, 'w') as f:
                f.write(f"Screenshot placeholder for host: {host_name}\n")
                f.write(f"vCenter: {connection['host']}\n")
                f.write("Note: Actual screenshot capture requires Selenium WebDriver integration\n")

            info(f"Placeholder screenshot created: {screenshot_path}")
            return screenshot_path

        except Exception as e:
            error(f"Error capturing screenshot: {str(e)}")
            raise

    # Helper methods
    def _find_cluster_by_name(self, content, cluster_name):
        """Find a cluster by name"""
        container = content.viewManager.CreateContainerView(
            content.rootFolder,
            [vim.ClusterComputeResource],
            True
        )

        for cluster in container.view:
            if cluster.name == cluster_name:
                container.Destroy()
                return cluster

        container.Destroy()
        return None

    def _find_host_by_name(self, content, host_name):
        """Find a host by name"""
        container = content.viewManager.CreateContainerView(
            content.rootFolder,
            [vim.HostSystem],
            True
        )

        for host in container.view:
            if host.name == host_name or host_name in host.name:
                container.Destroy()
                return host

        container.Destroy()
        return None

    def _classify_performance_tier(self, datastore_name, storage_type):
        """Classify datastore performance tier based on name and type"""
        name_lower = datastore_name.lower()

        # Check for high performance indicators
        if any(x in name_lower for x in ['ssd', 'nvme', 'flash', 'high', 'tier1']):
            return 'HIGH_PERFORMANCE'

        # Check for archive indicators
        if any(x in name_lower for x in ['archive', 'backup', 'tier3', 'slow']):
            return 'ARCHIVE'

        # Default to standard
        return 'STANDARD_PERFORMANCE'
