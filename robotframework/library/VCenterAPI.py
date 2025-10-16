"""
VCenter API Library for Robot Framework
Provides vCenter API interactions for VM validation and configuration queries
"""

from pyVim.connect import SmartConnect, Disconnect
from pyVmomi import vim
import ssl
import atexit
from robot.api.logger import info, warn, error


class VCenterAPI:
    """Library to interact with VMware vCenter API for VM validation"""

    ROBOT_LIBRARY_SCOPE = 'GLOBAL'

    def __init__(self):
        self.service_instance = None
        self.content = None
        self.session_id = None

    def connect_to_vcenter(self, vcenter_host, username, password, port=443, verify_ssl=False):
        """
        Connect to vCenter API and establish a session

        Args:
            vcenter_host: vCenter server hostname or IP
            username: vCenter username
            password: vCenter password
            port: vCenter port (default: 443)
            verify_ssl: Whether to verify SSL certificate (default: False)

        Returns:
            session_id: Session identifier string
        """
        try:
            info(f"Connecting to vCenter: {vcenter_host}")

            # Validate inputs
            if not username or username == 'N/A':
                raise ValueError("vCenter username not provided")
            if not password or password == 'N/A':
                raise ValueError("vCenter password not provided")
            if not vcenter_host or vcenter_host == 'N/A':
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
                raise RuntimeError("Failed to connect to vCenter - no service instance returned")

            # Register disconnect at exit
            atexit.register(Disconnect, self.service_instance)

            # Get content
            self.content = self.service_instance.RetrieveContent()

            # Generate session ID
            self.session_id = self.service_instance.content.sessionManager.currentSession.key

            info(f"Successfully connected to vCenter: {vcenter_host}")
            info(f"Session ID: {self.session_id}")

            return self.session_id

        except Exception as e:
            error(f"Failed to connect to vCenter {vcenter_host}: {str(e)}")
            raise RuntimeError(f"vCenter connection failed: {str(e)}")

    def disconnect_from_vcenter(self):
        """Disconnect from vCenter API session"""
        try:
            if self.service_instance:
                Disconnect(self.service_instance)
                info("Disconnected from vCenter API")
                self.service_instance = None
                self.content = None
                self.session_id = None
        except Exception as e:
            warn(f"Error disconnecting from vCenter: {str(e)}")

    def get_vm_comprehensive_details(self, vm_name):
        """
        Get comprehensive VM configuration details from vCenter

        Args:
            vm_name: Name of the VM to query

        Returns:
            dict: Comprehensive VM details including cluster, CPU, memory, network, disk
        """
        try:
            if not self.service_instance or not self.content:
                raise RuntimeError("Not connected to vCenter - call Connect To VCenter first")

            info(f"Searching for VM: {vm_name}")

            # Find the VM
            vm = self._get_vm_by_name(vm_name)

            if not vm:
                raise ValueError(f"VM '{vm_name}' not found in vCenter")

            info(f"Found VM: {vm_name}")

            # Collect comprehensive details
            vm_details = {
                'name': vm.name,
                'cluster_placement': self._get_cluster_placement(vm),
                'configuration': self._get_vm_configuration(vm),
                'network_adapters': self._get_network_adapters(vm),
                'disk_configuration': self._get_disk_configuration(vm)
            }

            info(f"Successfully collected comprehensive details for VM: {vm_name}")

            return vm_details

        except Exception as e:
            error(f"Failed to get VM details for {vm_name}: {str(e)}")
            raise RuntimeError(f"Failed to retrieve VM details: {str(e)}")

    def _get_vm_by_name(self, vm_name):
        """Find a VM by name in vCenter inventory"""
        container = self.content.viewManager.CreateContainerView(
            self.content.rootFolder,
            [vim.VirtualMachine],
            True
        )

        for vm in container.view:
            if vm.name == vm_name:
                container.Destroy()
                return vm

        container.Destroy()
        return None

    def _get_cluster_placement(self, vm):
        """Get cluster placement information for VM"""
        try:
            cluster_info = {
                'cluster_name': 'N/A',
                'cluster_id': 'N/A',
                'host_name': 'N/A'
            }

            # Get host
            if vm.runtime.host:
                cluster_info['host_name'] = vm.runtime.host.name
                info(f"VM Host: {cluster_info['host_name']}")

                # Get cluster from host
                if hasattr(vm.runtime.host, 'parent') and vm.runtime.host.parent:
                    if isinstance(vm.runtime.host.parent, vim.ClusterComputeResource):
                        cluster = vm.runtime.host.parent
                        cluster_info['cluster_name'] = cluster.name
                        cluster_info['cluster_id'] = cluster._moId
                        info(f"VM Cluster: {cluster_info['cluster_name']}")

            return cluster_info

        except Exception as e:
            warn(f"Error getting cluster placement: {str(e)}")
            return {
                'cluster_name': 'N/A',
                'cluster_id': 'N/A',
                'host_name': 'N/A'
            }

    def _get_vm_configuration(self, vm):
        """Get VM hardware configuration"""
        try:
            config = vm.config

            configuration = {
                'cpu_count': config.hardware.numCPU,
                'cores_per_socket': config.hardware.numCoresPerSocket,
                'memory_size_mb': config.hardware.memoryMB,
                'memory_size_gb': round(config.hardware.memoryMB / 1024, 2),
                'hardware_version': config.version
            }

            info(f"CPU: {configuration['cpu_count']} cores ({configuration['cores_per_socket']} per socket)")
            info(f"Memory: {configuration['memory_size_gb']} GB")
            info(f"Hardware Version: {configuration['hardware_version']}")

            return configuration

        except Exception as e:
            error(f"Error getting VM configuration: {str(e)}")
            raise

    def _get_network_adapters(self, vm):
        """Get VM network adapter configuration"""
        try:
            adapters = []

            for device in vm.config.hardware.device:
                if isinstance(device, vim.vm.device.VirtualEthernetCard):
                    # Get network name
                    network_name = 'Unknown'
                    if hasattr(device, 'backing'):
                        if hasattr(device.backing, 'network') and device.backing.network:
                            network_name = device.backing.network.name
                        elif hasattr(device.backing, 'port') and hasattr(device.backing.port, 'portgroupKey'):
                            # Distributed port group
                            network_name = device.backing.port.portgroupKey

                    adapter_info = {
                        'label': device.deviceInfo.label,
                        'type': type(device).__name__.replace('Virtual', ''),
                        'network_name': network_name,
                        'mac_address': device.macAddress if hasattr(device, 'macAddress') else 'N/A'
                    }

                    adapters.append(adapter_info)
                    info(f"Network Adapter: {adapter_info['label']} - {adapter_info['type']} on {adapter_info['network_name']}")

            return adapters

        except Exception as e:
            warn(f"Error getting network adapters: {str(e)}")
            return []

    def _get_disk_configuration(self, vm):
        """Get VM disk configuration"""
        try:
            disks = []

            for device in vm.config.hardware.device:
                if isinstance(device, vim.vm.device.VirtualDisk):
                    # Get disk capacity in GB
                    capacity_bytes = device.capacityInBytes if hasattr(device, 'capacityInBytes') else device.capacityInKB * 1024
                    capacity_gb = round(capacity_bytes / (1024**3), 2)

                    # Determine disk type
                    disk_type = 'Unknown'
                    if hasattr(device.backing, 'thinProvisioned'):
                        disk_type = 'Thin Provisioned' if device.backing.thinProvisioned else 'Thick Provisioned'

                    disk_info = {
                        'label': device.deviceInfo.label,
                        'capacity_gb': capacity_gb,
                        'type': disk_type
                    }

                    disks.append(disk_info)
                    info(f"Disk: {disk_info['label']} - {disk_info['capacity_gb']} GB ({disk_info['type']})")

            return disks

        except Exception as e:
            warn(f"Error getting disk configuration: {str(e)}")
            return []
