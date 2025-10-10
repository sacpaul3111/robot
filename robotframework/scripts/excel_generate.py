import pandas as pd
from openpyxl import Workbook
from openpyxl.utils.dataframe import dataframe_to_rows
from datetime import datetime

def create_itential_xlsx(output_filename='CBS_Itential_DRAFT_recreated.xlsx'):
    """
    Creates an Excel file with Itential infrastructure data matching the attached template
    """
    
    # Create Excel writer object
    with pd.ExcelWriter(output_filename, engine='openpyxl') as writer:
        
        # Sheet 1: Change History
        change_history_data = {
            'Version': ['0.1', '0.2', '0.3', '0.4', '0.5', '1', '1.1', '1.2', '1.3', '1.4', '2'],
            'Date Modified': ['2024-10-16', '', '', '', '', '', '', '', '', '', ''],
            'Authors': ['R. Stalzer', '', '', '', '', '', '', '', '', '', ''],
            'Reasons for Change': ['Initial Draft', '', '', '', '', 'Approved TDRC Baseline', 
                                 'As-Built Update', '', '', '', 'Final Approved Version'],
            'Reviewed By': ['W. Choi', '', '', '', '', '', '', '', '', '', '']
        }
        df_change = pd.DataFrame(change_history_data)
        df_change.to_excel(writer, sheet_name='Change History', index=False, startrow=2)
        
        # Add header for Change History
        worksheet = writer.sheets['Change History']
        worksheet['A1'] = 'Template Version:'
        worksheet['C1'] = '1.0'
        
        # Sheet 2: Hardware Requirements (simplified structure)
        hardware_headers = ['Item #', 'Device ID', 'Serial Number', 'Component Name (Host Name)', 
                          'Component Description', 'Model Number', 'Make Number', 
                          'Grid Data Center Location', 'Environment', 'Cell/IDF ROW Type',
                          'Rack Number', 'Rack U Level Lower', 'Rack U Level Upper', 
                          'Classification', 'Security Zone NERC/Non-NERC', 'Trust Level',
                          'VXRAIL Node Version', 'ESXi Version', 'CPU Model / Clock Speed',
                          'Number of CPU Sockets', 'Number of CPU Core Per Socket', 
                          'Total CPU Cores Per Host', 'RAM (TB)', 'Storage Total (TB)',
                          'Storage Usable (TB)', 'RAID Configuration', 'Storage Total (TB)',
                          'Storage Usable (TB)', 'RAID Configuration']
        
        hardware_data = {col: [''] * 3 for col in hardware_headers}
        hardware_data['Component Description'][0] = 'N/A … this solution is completely virtualized.'
        
        df_hardware = pd.DataFrame(hardware_data)
        df_hardware.to_excel(writer, sheet_name='Hardware Requirements', index=False)
        
        # Sheet 3: Server Requirements (main infrastructure data)
        server_data = create_server_requirements_data()
        df_servers = pd.DataFrame(server_data)
        df_servers.to_excel(writer, sheet_name='Server Requirements', index=False)
        
        # Sheet 4: F5 GTM-LTM
        f5_gtm_ltm_data = create_f5_gtm_ltm_data()
        df_f5_gtm_ltm = pd.DataFrame(f5_gtm_ltm_data)
        df_f5_gtm_ltm.to_excel(writer, sheet_name='F5 GTM-LTM (Optional)', index=False)
        
        # Sheet 5: F5 GTM
        f5_gtm_data = {
            'GTM Alias': ['psc3pa.glbi.sce.com'],
            'Cname': ['psc3pa.sce.com'],
            'Port': ['80, 443'],
            'Members': ['LEXVPSC303 172.25.194.57\nLEXVPSC304 172.25.194.58'],
            'HealthCheck': ['HTTP GET /f5healthcheck.html\nResponse String: Alive'],
            'Environment': ['PROD'],
            'Load Balancing': ['Round Robin'],
            'Purpose': ['Portal Authoring'],
            'Comments': ['']
        }
        df_f5_gtm = pd.DataFrame(f5_gtm_data)
        df_f5_gtm.to_excel(writer, sheet_name='F5 GTM - Optional', index=False)
        
        # Sheet 6: Client Considerations
        client_data = {
            'Requirement': ['Physical Workstation Considerations', 
                          'Provide any known requirement for workstation refresh or other impacts.',
                          'Provide any non-standard image requirements.',
                          'Citrix VDI',
                          'Identify new applications to be on-boarded.',
                          'Identify user base requirements (total user, concurrent user).',
                          'Identify NAT\'d IP or SNIP configuration needs.'],
            'Comments': [''] * 7
        }
        df_client = pd.DataFrame(client_data)
        df_client.to_excel(writer, sheet_name='Client Considerations', index=False)
        
        # Sheet 7: Database Considerations
        db_data = {
            'Component Name': ['alhwvqaedssqlXX', ''],
            'Type': ['VM', 'VM'],
            'Function': ['Example 1 RDBMS', 'Example 2 RDBMS'],
            'DB Ports Assignment': ['1984', '1994'],
            'Service Account(s)': ['$MSSQLSVC', '$MSSQLSVC'],
            'Named Instance': ['qedsexam001', 'qedsexam002'],
            'CNAME for DB': ['sqlqedsexam001', 'sqlqedsexam002'],
            'Maps To': ['TBD', 'TBD'],
            'DB Version': ['MS SQL Server 2017 Cumulative Update 21 (CU21), Developer Edition', '']
        }
        df_db = pd.DataFrame(db_data)
        df_db.to_excel(writer, sheet_name='Database Considerations', index=False, startrow=2)
        
    print(f"Excel file '{output_filename}' has been created successfully!")
    return output_filename

def create_server_requirements_data():
    """Creates the server requirements data for Itential infrastructure"""
    
    # Define the Itential servers configuration
    servers = [
        # Development servers
        {'name': 'alhxvdvitap01', 'type': 'Itential All-In-One', 'env': 'Dev within QA', 
         'ip': '10.29.144.26', 'cpu': 8, 'ram': 16, 'storage': 0.465},
        {'name': 'alhxvdvitag01', 'type': 'Itential All-In-One', 'env': 'Dev within QA',
         'ip': '10.26.216.108', 'cpu': 8, 'ram': 16, 'storage': 0.465},
        
        # QA/Staging servers
        {'name': 'alhxvqaitiap01', 'type': 'Itential Automation Platform', 'env': 'QA (Staging)',
         'ip': '10.26.216.112', 'cpu': 16, 'ram': 64, 'storage': 0.14},
        {'name': 'alhxvqaitiap02', 'type': 'Itential Automation Platform', 'env': 'QA (Staging)',
         'ip': '10.26.216.113', 'cpu': 16, 'ram': 64, 'storage': 0.14},
        {'name': 'alhxvqaitred01', 'type': 'Itential Redis', 'env': 'QA (Staging)',
         'ip': '10.26.216.114', 'cpu': 4, 'ram': 4, 'storage': 0.09},
        {'name': 'alhxvqaitred02', 'type': 'Itential Redis', 'env': 'QA (Staging)',
         'ip': '10.26.216.115', 'cpu': 4, 'ram': 4, 'storage': 0.09},
        {'name': 'alhxvqaitred03', 'type': 'Itential Redis', 'env': 'QA (Staging)',
         'ip': '10.26.216.116', 'cpu': 4, 'ram': 4, 'storage': 0.09},
        {'name': 'alhxvqaitmdb01', 'type': 'Itential MongoDB', 'env': 'QA (Staging)',
         'ip': '10.26.216.117', 'cpu': 16, 'ram': 128, 'storage': 1.04},
        {'name': 'alhxvqaitmdb02', 'type': 'Itential MongoDB', 'env': 'QA (Staging)',
         'ip': '10.26.216.118', 'cpu': 16, 'ram': 128, 'storage': 1.04},
        {'name': 'alhxvqaitmdb03', 'type': 'Itential MongoDB', 'env': 'QA (Staging)',
         'ip': '10.26.216.119', 'cpu': 16, 'ram': 128, 'storage': 1.04},
        {'name': 'alhxvqaitag01', 'type': 'Itential Automation Gateway', 'env': 'QA (Staging)',
         'ip': '10.26.216.121', 'cpu': 8, 'ram': 32, 'storage': 0.09},
        {'name': 'alhxvqaitag02', 'type': 'Itential Automation Gateway', 'env': 'QA (Staging)',
         'ip': '10.26.216.122', 'cpu': 8, 'ram': 32, 'storage': 0.09},
        
        # Production NERC servers
        {'name': 'alhxvpritiap01', 'type': 'Itential Automation Platform', 'env': 'PROD',
         'ip': '10.26.6.???', 'cpu': 16, 'ram': 64, 'storage': 0.24},
        {'name': 'alhxvpritiap02', 'type': 'Itential Automation Platform', 'env': 'PROD',
         'ip': '10.26.6.???', 'cpu': 16, 'ram': 64, 'storage': 0.24},
    ]
    
    # Build the data structure
    data = {
        'Host Description': [],
        'Cluster Name': [],
        'Container Type': [],
        'Server Name': [],
        'Type': [],
        'Purpose': [],
        'Classification': [],
        'Site': [],
        'Environment': [],
        'Trust Level': [],
        'OS Type': [],
        'Number of CPU Cores (recom)': [],
        'RAM': [],
        'Storage Type': [],
        'Storage Total TB': [],
        'Drive or Volume Group': [],
        'Files System': [],
        'Logical Volume Name/Partition (Mounted On)': [],
        'Storage Allocation (GB)': [],
        'Recommended Storage Allocation (GB)': [],
        'Drive Purpose': [],
        'VLAN Number': [],
        'VLAN ID (Description of VLAN)': [],
        'Subnet': [],
        'Mask': [],
        'Gateway': [],
        'Teaming Bonding (Y/N)': [],
        'Description': [],
        'CNAME': [],
        'DOMAIN': [],
        'IP Assignment': []
    }
    
    # Populate data for each server
    for server in servers:
        data['Host Description'].append('VxRail QA Non-NERC Common Services Linux')
        data['Cluster Name'].append('alhqanncc03 (Linux)')
        data['Container Type'].append('')
        data['Server Name'].append(server['name'])
        data['Type'].append('VM')
        data['Purpose'].append(server['type'])
        data['Classification'].append('NERC' if 'PROD' in server['env'] else 'Non-NERC')
        data['Site'].append('GDCA')
        data['Environment'].append(server['env'])
        data['Trust Level'].append('TL3')
        data['OS Type'].append('RHEL 9.6')
        data['Number of CPU Cores (recom)'].append(server['cpu'])
        data['RAM'].append(server['ram'])
        data['Storage Type'].append('VSAN')
        data['Storage Total TB'].append(server['storage'])
        data['Drive or Volume Group'].append('rootvg:')
        data['Files System'].append('/dev/mapper/rootvg-rootlv')
        data['Logical Volume Name/Partition (Mounted On)'].append('/')
        data['Storage Allocation (GB)'].append(20)
        data['Recommended Storage Allocation (GB)'].append(20)
        data['Drive Purpose'].append('OS')
        data['VLAN Number'].append(216 if 'QA' in server['env'] else 6)
        data['VLAN ID (Description of VLAN)'].append('ALH QAS MGMT TOOLS LAN' if 'QA' in server['env'] else 'ALH NERC MGMT TOOLS LAN')
        data['Subnet'].append('10.29.144.0/24' if 'QA' in server['env'] else '10.26.6.0/24')
        data['Mask'].append('255.255.255.0')
        data['Gateway'].append('10.29.144.4' if 'QA' in server['env'] else '10.26.6.4')
        data['Teaming Bonding (Y/N)'].append('')
        data['Description'].append(f"GDCA {server['env']} {server['type']}")
        data['CNAME'].append(server['name'])
        data['DOMAIN'].append('gnscet.com' if 'QA' in server['env'] else 'gnsce.com')
        data['IP Assignment'].append(server['ip'])
    
    return data

def create_f5_gtm_ltm_data():
    """Creates F5 GTM-LTM configuration data"""
    
    data = {
        'GTM Alias': ['iap-vip.gcsce.com', '', 'iap-vip.gcscet.com', '',
                     'iap-vip.gcsn.gcsce.com', '', 'iap-vip.gcsnt.gcscet.com', ''],
        'GTM': ['', '', '', '', '', '', '', ''],
        'Cname': ['itential.gnsce.com', '', 'itential.gnscet.com', '', '', '', '', ''],
        'Port': ['3443/https\n3000/http'] * 8,
        'LTM': ['iap-vip-adc.gcsce.com', '', 'iap-vip-adc.gcscet.com', '',
               'iap-vip-ioc.gcsce.com', '', 'iap-vip-ioc.gcscet.com', ''],
        'VIP': ['10.26.151.235', '', '10.26.237.205', '',
               '10.27.151.235', '', '10.27.237.205', ''],
        'VIPs Name': [''] * 8,
        'Node Members': ['alhxvpritiap01', 'alhxvpritiap02', 'alhxvqaitiap01', 'alhxvqaitiap02',
                        'irvxvpritiap01', 'irvxvpritiap02', 'irvxvqaitiap01', 'irvxvqaitiap02'],
        'HealthCheck': [''] * 8,
        'iRules': [''] * 8,
        'Environment': ['Prod', 'Prod', 'QA', 'QA', 'Prod', 'Prod', 'QA', 'QA'],
        'Load Balancing': [''] * 8,
        'Persistence': [''] * 8,
        'SNAT': [''] * 8,
        'Acceleration': [''] * 8,
        'Optimization': [''] * 8,
        'Compression': [''] * 8,
        'Purpose': [''] * 8,
        'Release': ['', '', '', '', 'FUTURE', 'FUTURE', 'FUTURE', 'FUTURE'],
        'Comment': [''] * 8
    }
    
    return data

# Main execution
if __name__ == "__main__":
    # Create the Excel file
    output_file = create_itential_xlsx()
    print(f"\nFile created: {output_file}")
    print("\nThis script recreates the Itential infrastructure spreadsheet with:")
    print("- Change History tracking")
    print("- Hardware Requirements (virtualized environment)")
    print("- Server Requirements for Dev, QA, and Prod environments")
    print("- F5 Load Balancer configurations")
    print("- Client and Database considerations")
