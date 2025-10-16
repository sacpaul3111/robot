"""
Backup Validator Library for Robot Framework
Provides validation logic for backup configuration compliance - Test-15
"""

from datetime import datetime, timedelta
from robot.api.logger import info, warn, error


class BackupValidator:
    """Library for validating backup configuration and compliance"""

    ROBOT_LIBRARY_SCOPE = 'GLOBAL'

    def __init__(self):
        pass

    def validate_backup_policy_applied(self, policy_data, vm_criticality=None):
        """
        Validate that backup policies are properly applied to all VMs

        Args:
            policy_data: List of backup policy configurations
            vm_criticality: Dictionary mapping VM names to criticality levels

        Returns:
            dict: Validation results with violations list
        """
        try:
            info("Validating backup policy application")

            violations = []

            for policy in policy_data:
                vm_name = policy.get('vm_name', 'Unknown')
                policy_applied = policy.get('policy_applied', False)
                policy_name = policy.get('policy_name', 'None')

                # Check if policy is applied
                if not policy_applied or policy_name == 'None':
                    violations.append({
                        'vm_name': vm_name,
                        'reason': 'No backup policy applied to VM',
                        'severity': 'critical'
                    })

            results = {
                'violations': violations,
                'total_vms': len(policy_data),
                'violations_count': len(violations)
            }

            if violations:
                warn(f"Backup policy validation found {len(violations)} violations")
            else:
                info("Backup policy validation passed - all VMs have policies applied")

            return results

        except Exception as e:
            error(f"Error validating backup policy: {str(e)}")
            raise

    def validate_schedule_alignment_with_rpo(self, schedule_data, rpo_requirements, vm_criticality):
        """
        Validate that backup schedules align with RPO requirements

        Args:
            schedule_data: List of backup schedule settings
            rpo_requirements: Dictionary of RPO requirements by criticality
            vm_criticality: Dictionary mapping VM names to criticality levels

        Returns:
            dict: Validation results with RPO violations list
        """
        try:
            info("Validating backup schedule alignment with RPO requirements")

            rpo_violations = []

            for schedule in schedule_data:
                vm_name = schedule.get('vm_name', 'Unknown')
                rpo_hours = schedule.get('rpo_hours', 999)
                enabled = schedule.get('enabled', False)

                # Get required RPO for this VM
                criticality = vm_criticality.get(vm_name, 'medium')
                required_rpo = rpo_requirements.get(criticality, 24)

                # Check if schedule is enabled
                if not enabled:
                    rpo_violations.append({
                        'vm_name': vm_name,
                        'reason': 'Backup schedule is disabled',
                        'current_rpo': 'N/A',
                        'required_rpo': required_rpo,
                        'severity': 'critical'
                    })
                    continue

                # Check if RPO meets requirements
                if rpo_hours > required_rpo:
                    rpo_violations.append({
                        'vm_name': vm_name,
                        'current_rpo': rpo_hours,
                        'required_rpo': required_rpo,
                        'criticality': criticality,
                        'reason': f'RPO ({rpo_hours}h) exceeds requirement ({required_rpo}h) for {criticality} VM',
                        'severity': 'warning'
                    })

            results = {
                'rpo_violations': rpo_violations,
                'total_vms': len(schedule_data),
                'violations_count': len(rpo_violations)
            }

            if rpo_violations:
                warn(f"RPO validation found {len(rpo_violations)} violations")
            else:
                info("RPO validation passed - all VMs meet RPO requirements")

            return results

        except Exception as e:
            error(f"Error validating RPO alignment: {str(e)}")
            raise

    def validate_retention_settings_compliance(self, retention_data, min_daily_retention, min_weekly_retention, min_monthly_retention=3):
        """
        Validate that retention settings meet compliance requirements

        Args:
            retention_data: List of retention policy settings
            min_daily_retention: Minimum required daily retention in days
            min_weekly_retention: Minimum required weekly retention in weeks
            min_monthly_retention: Minimum required monthly retention in months

        Returns:
            dict: Validation results with violations list
        """
        try:
            info(f"Validating retention settings compliance (Daily: {min_daily_retention}d, "
                 f"Weekly: {min_weekly_retention}w, Monthly: {min_monthly_retention}m)")

            violations = []

            for retention in retention_data:
                vm_name = retention.get('vm_name', 'Unknown')
                daily_retention = retention.get('daily_retention', 0)
                weekly_retention = retention.get('weekly_retention', 0)
                monthly_retention = retention.get('monthly_retention', 0)

                # Check daily retention
                if daily_retention < min_daily_retention:
                    violations.append({
                        'vm_name': vm_name,
                        'policy': 'daily',
                        'current': daily_retention,
                        'required': min_daily_retention,
                        'reason': f'Daily retention ({daily_retention}d) below minimum ({min_daily_retention}d)',
                        'severity': 'warning'
                    })

                # Check weekly retention
                if weekly_retention < min_weekly_retention:
                    violations.append({
                        'vm_name': vm_name,
                        'policy': 'weekly',
                        'current': weekly_retention,
                        'required': min_weekly_retention,
                        'reason': f'Weekly retention ({weekly_retention}w) below minimum ({min_weekly_retention}w)',
                        'severity': 'warning'
                    })

                # Check monthly retention
                if monthly_retention < min_monthly_retention:
                    violations.append({
                        'vm_name': vm_name,
                        'policy': 'monthly',
                        'current': monthly_retention,
                        'required': min_monthly_retention,
                        'reason': f'Monthly retention ({monthly_retention}m) below minimum ({min_monthly_retention}m)',
                        'severity': 'warning'
                    })

            results = {
                'violations': violations,
                'total_vms': len(retention_data),
                'violations_count': len(violations)
            }

            if violations:
                warn(f"Retention validation found {len(violations)} violations")
            else:
                info("Retention validation passed - all VMs meet retention requirements")

            return results

        except Exception as e:
            error(f"Error validating retention settings: {str(e)}")
            raise

    def validate_recent_job_completion_status(self, job_status):
        """
        Validate that recent backup jobs completed successfully

        Args:
            job_status: List of recent backup job statuses

        Returns:
            dict: Validation results with failed jobs list
        """
        try:
            info("Validating recent backup job completion status")

            failed_jobs = []

            for job in job_status:
                vm_name = job.get('vm_name', 'Unknown')
                status = job.get('status', 'Unknown')
                end_time = job.get('end_time', 'Unknown')

                # Check if job failed
                if status.lower() not in ['success', 'successful', 'completed']:
                    failed_jobs.append({
                        'vm_name': vm_name,
                        'job_id': job.get('job_id', 'Unknown'),
                        'status': status,
                        'end_time': end_time,
                        'error_message': job.get('error_message', 'No error message available'),
                        'reason': f'Backup job status: {status}',
                        'severity': 'critical'
                    })

            results = {
                'failed_jobs': failed_jobs,
                'total_jobs': len(job_status),
                'failed_count': len(failed_jobs)
            }

            if failed_jobs:
                warn(f"Job status validation found {len(failed_jobs)} failed jobs")
            else:
                info("Job status validation passed - all recent jobs completed successfully")

            return results

        except Exception as e:
            error(f"Error validating job completion status: {str(e)}")
            raise

    def validate_backup_recency(self, timestamp_data, max_backup_age_hours):
        """
        Validate that backups are recent and not stale

        Args:
            timestamp_data: List of latest backup timestamps
            max_backup_age_hours: Maximum allowed backup age in hours

        Returns:
            dict: Validation results with stale backups list
        """
        try:
            info(f"Validating backup recency (max age: {max_backup_age_hours}h)")

            stale_backups = []
            current_time = datetime.now()

            for timestamp in timestamp_data:
                vm_name = timestamp.get('vm_name', 'Unknown')
                last_backup_time = timestamp.get('last_backup_time', '')

                # Parse timestamp
                try:
                    if isinstance(last_backup_time, str):
                        backup_dt = datetime.fromisoformat(last_backup_time.replace('Z', '+00:00'))
                    else:
                        backup_dt = last_backup_time

                    # Calculate age
                    age_delta = current_time - backup_dt.replace(tzinfo=None)
                    age_hours = age_delta.total_seconds() / 3600

                    # Check if backup is stale
                    if age_hours > max_backup_age_hours:
                        stale_backups.append({
                            'vm_name': vm_name,
                            'last_backup_time': last_backup_time,
                            'age_hours': round(age_hours, 2),
                            'max_age_hours': max_backup_age_hours,
                            'reason': f'Backup is {round(age_hours, 2)}h old, exceeds maximum ({max_backup_age_hours}h)',
                            'severity': 'warning'
                        })

                except Exception as e:
                    warn(f"Error parsing timestamp for {vm_name}: {str(e)}")
                    stale_backups.append({
                        'vm_name': vm_name,
                        'last_backup_time': 'Unknown',
                        'age_hours': 'Unknown',
                        'reason': 'Unable to determine backup age',
                        'severity': 'critical'
                    })

            results = {
                'stale_backups': stale_backups,
                'total_vms': len(timestamp_data),
                'stale_count': len(stale_backups)
            }

            if stale_backups:
                warn(f"Backup recency validation found {len(stale_backups)} stale backups")
            else:
                info("Backup recency validation passed - all backups are current")

            return results

        except Exception as e:
            error(f"Error validating backup recency: {str(e)}")
            raise

    def validate_offsite_replication_configuration(self, replication_data, offsite_required_vms):
        """
        Validate that offsite replication is properly configured

        Args:
            replication_data: List of offsite replication statuses
            offsite_required_vms: List of VMs that require offsite replication

        Returns:
            dict: Validation results with violations list
        """
        try:
            info(f"Validating offsite replication configuration for {len(offsite_required_vms)} critical VMs")

            violations = []

            for replication in replication_data:
                vm_name = replication.get('vm_name', 'Unknown')
                offsite_enabled = replication.get('offsite_enabled', False)
                offsite_target = replication.get('offsite_target', 'None')
                replication_status = replication.get('replication_status', 'Unknown')

                # Check if VM requires offsite replication
                if vm_name in offsite_required_vms:
                    # Check if offsite is enabled
                    if not offsite_enabled:
                        violations.append({
                            'vm_name': vm_name,
                            'reason': 'Offsite replication not enabled for critical VM',
                            'severity': 'critical'
                        })
                    # Check if offsite target is configured
                    elif offsite_target == 'None' or not offsite_target:
                        violations.append({
                            'vm_name': vm_name,
                            'reason': 'Offsite replication enabled but no target configured',
                            'severity': 'critical'
                        })
                    # Check if replication is successful
                    elif replication_status.lower() not in ['success', 'successful', 'completed']:
                        violations.append({
                            'vm_name': vm_name,
                            'offsite_target': offsite_target,
                            'status': replication_status,
                            'reason': f'Offsite replication status: {replication_status}',
                            'severity': 'warning'
                        })

            results = {
                'violations': violations,
                'total_vms': len(replication_data),
                'violations_count': len(violations)
            }

            if violations:
                warn(f"Offsite replication validation found {len(violations)} violations")
            else:
                info("Offsite replication validation passed - all critical VMs have offsite protection")

            return results

        except Exception as e:
            error(f"Error validating offsite replication: {str(e)}")
            raise
