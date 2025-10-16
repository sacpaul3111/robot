"""
Datastore Validator Library for Robot Framework
Provides validation logic for datastore configuration compliance - Test-9
"""

from robot.api.logger import info, warn, error


class DatastoreValidator:
    """Library for validating datastore configuration and compliance"""

    ROBOT_LIBRARY_SCOPE = 'GLOBAL'

    def __init__(self):
        pass

    def datastore_validator_validate_vm_placement(self, vm_assignments, cluster_name):
        """
        Validate VM datastore placement against cluster standards

        Args:
            vm_assignments: List of VM datastore assignments
            cluster_name: Name of the cluster

        Returns:
            dict: Validation results with violations list
        """
        try:
            info(f"Validating VM datastore placement for cluster: {cluster_name}")

            violations = []

            for vm in vm_assignments:
                vm_name = vm.get('vm_name', 'Unknown')
                datastores = vm.get('datastores', [])

                # Validate VM has at least one datastore
                if not datastores or len(datastores) == 0:
                    violations.append({
                        'vm_name': vm_name,
                        'reason': 'VM has no datastores assigned',
                        'severity': 'critical'
                    })
                    continue

                # Check for inaccessible datastores
                for ds in datastores:
                    ds_name = ds.get('name', 'Unknown')
                    ds_type = ds.get('type', 'Unknown')

                    # Validate datastore type is supported
                    if ds_type not in ['VMFS', 'NFS', 'VSAN', 'vSAN', 'VVol']:
                        violations.append({
                            'vm_name': vm_name,
                            'datastore': ds_name,
                            'reason': f'Unsupported datastore type: {ds_type}',
                            'severity': 'warning'
                        })

            results = {
                'violations': violations,
                'total_vms': len(vm_assignments),
                'violations_count': len(violations)
            }

            if violations:
                warn(f"VM placement validation found {len(violations)} violations")
            else:
                info("VM placement validation passed - no violations found")

            return results

        except Exception as e:
            error(f"Error validating VM placement: {str(e)}")
            raise

    def datastore_validator_validate_capacity(self, capacity_data, min_free_capacity_percent):
        """
        Validate datastores have sufficient available capacity

        Args:
            capacity_data: List of datastore capacity information
            min_free_capacity_percent: Minimum required free capacity percentage

        Returns:
            dict: Validation results with warnings list
        """
        try:
            info(f"Validating datastore capacity (minimum free: {min_free_capacity_percent}%)")

            warnings = []

            for ds in capacity_data:
                ds_name = ds.get('name', 'Unknown')
                free_percent = ds.get('free_percent', 0)
                free_gb = ds.get('free_gb', 0)
                total_gb = ds.get('total_gb', 0)
                accessible = ds.get('accessible', True)

                # Check if datastore is accessible
                if not accessible:
                    warnings.append({
                        'name': ds_name,
                        'reason': 'Datastore is not accessible',
                        'free_percent': 0,
                        'severity': 'critical'
                    })
                    continue

                # Check if free capacity is below threshold
                if free_percent < min_free_capacity_percent:
                    warnings.append({
                        'name': ds_name,
                        'free_percent': free_percent,
                        'free_gb': free_gb,
                        'total_gb': total_gb,
                        'reason': f'Free capacity ({free_percent}%) below threshold ({min_free_capacity_percent}%)',
                        'severity': 'warning'
                    })

            results = {
                'warnings': warnings,
                'total_datastores': len(capacity_data),
                'warnings_count': len(warnings)
            }

            if warnings:
                warn(f"Capacity validation found {len(warnings)} warnings")
            else:
                info("Capacity validation passed - all datastores have sufficient free space")

            return results

        except Exception as e:
            error(f"Error validating capacity: {str(e)}")
            raise

    def datastore_validator_validate_performance_tiers(self, vm_assignments, performance_tiers, vm_app_categories):
        """
        Validate VMs are on appropriate performance tiers

        Args:
            vm_assignments: List of VM datastore assignments
            performance_tiers: List of datastore performance tier information
            vm_app_categories: Dictionary mapping VM application categories to required tiers

        Returns:
            dict: Validation results with mismatches list
        """
        try:
            info("Validating VM performance tier assignments")

            mismatches = []

            # Create datastore tier lookup
            ds_tier_map = {}
            for tier in performance_tiers:
                ds_tier_map[tier['name']] = tier['performance_tier']

            # Validate each VM
            for vm in vm_assignments:
                vm_name = vm.get('vm_name', 'Unknown')
                datastores = vm.get('datastores', [])

                # Determine required tier based on VM naming convention
                required_tier = self._determine_required_tier(vm_name, vm_app_categories)

                # Check if VM is on correct performance tier
                for ds in datastores:
                    ds_name = ds.get('name', 'Unknown')
                    current_tier = ds_tier_map.get(ds_name, 'UNKNOWN')

                    # Only flag if there's a clear mismatch
                    if required_tier != 'UNKNOWN' and current_tier != required_tier:
                        # Allow high-performance VMs on any tier (they can run on standard)
                        # But don't allow standard VMs on archive tier
                        if not (required_tier == 'HIGH_PERFORMANCE' and current_tier == 'STANDARD_PERFORMANCE'):
                            if not (required_tier == 'STANDARD_PERFORMANCE' and current_tier == 'HIGH_PERFORMANCE'):
                                if current_tier == 'ARCHIVE' and required_tier != 'ARCHIVE':
                                    mismatches.append({
                                        'vm_name': vm_name,
                                        'datastore': ds_name,
                                        'current_tier': current_tier,
                                        'required_tier': required_tier,
                                        'reason': f'VM requires {required_tier} but is on {current_tier}'
                                    })

            results = {
                'mismatches': mismatches,
                'total_vms': len(vm_assignments),
                'mismatches_count': len(mismatches)
            }

            if mismatches:
                warn(f"Performance tier validation found {len(mismatches)} mismatches")
            else:
                info("Performance tier validation passed - all VMs on appropriate tiers")

            return results

        except Exception as e:
            error(f"Error validating performance tiers: {str(e)}")
            raise

    def datastore_validator_validate_subscription(self, subscription_data, max_subscription_ratio):
        """
        Validate datastore subscription ratios

        Args:
            subscription_data: List of datastore subscription information
            max_subscription_ratio: Maximum allowed subscription ratio

        Returns:
            dict: Validation results with oversubscribed list
        """
        try:
            info(f"Validating datastore subscription ratios (max: {max_subscription_ratio}:1)")

            oversubscribed = []

            for ds in subscription_data:
                ds_name = ds.get('name', 'Unknown')
                subscription_ratio = ds.get('subscription_ratio', 0)
                provisioned_gb = ds.get('provisioned_gb', 0)
                capacity_gb = ds.get('capacity_gb', 0)

                # Check if subscription ratio exceeds maximum
                if subscription_ratio > max_subscription_ratio:
                    oversubscribed.append({
                        'name': ds_name,
                        'ratio': subscription_ratio,
                        'provisioned_gb': provisioned_gb,
                        'capacity_gb': capacity_gb,
                        'max_ratio': max_subscription_ratio,
                        'reason': f'Subscription ratio ({subscription_ratio}:1) exceeds maximum ({max_subscription_ratio}:1)'
                    })

            results = {
                'oversubscribed': oversubscribed,
                'total_datastores': len(subscription_data),
                'oversubscribed_count': len(oversubscribed)
            }

            if oversubscribed:
                warn(f"Subscription validation found {len(oversubscribed)} oversubscribed datastores")
            else:
                info("Subscription validation passed - all datastores within limits")

            return results

        except Exception as e:
            error(f"Error validating subscription: {str(e)}")
            raise

    # Helper methods
    def _determine_required_tier(self, vm_name, vm_app_categories):
        """
        Determine required performance tier based on VM name

        Args:
            vm_name: Name of the VM
            vm_app_categories: Dictionary mapping app types to tiers

        Returns:
            str: Required performance tier
        """
        vm_name_lower = vm_name.lower()

        # Check VM name for application type indicators
        for app_type, tier in vm_app_categories.items():
            if app_type in vm_name_lower:
                return tier

        # Default to STANDARD_PERFORMANCE if no specific requirement
        return 'STANDARD_PERFORMANCE'
