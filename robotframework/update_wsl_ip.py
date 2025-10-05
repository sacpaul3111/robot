"""
Update EDS Excel sheet with WSL IP address for local testing
"""
import pandas as pd
import sys
import os

# Set UTF-8 encoding for Windows console
if os.name == 'nt':
    import codecs
    sys.stdout = codecs.getwriter('utf-8')(sys.stdout.buffer, 'strict')
    sys.stderr = codecs.getwriter('utf-8')(sys.stderr.buffer, 'strict')

# Configuration
EDS_FILE = "EDS_Itential_DRAFT_v0.01.xlsx"
HOSTNAME = "alhxvdvitap01"
WSL_IP = "172.30.16.186"

try:
    # Read the Excel file
    print(f"📖 Reading {EDS_FILE}...")
    df = pd.read_excel(EDS_FILE, sheet_name="Server Requirements")

    print(f"📊 Available columns: {list(df.columns)}")
    print(f"\n🔍 Looking for hostname: {HOSTNAME}")

    # Check if hostname exists
    if 'Server Name' in df.columns:
        mask = df['Server Name'].astype(str) == HOSTNAME

        if mask.any():
            # Update existing row
            print(f"✅ Found existing entry for {HOSTNAME}")
            current_ip = df.loc[mask, 'IP Assignment'].values[0] if 'IP Assignment' in df.columns else 'N/A'
            print(f"📍 Current IP: {current_ip}")
            print(f"📍 New IP: {WSL_IP}")

            if 'IP Assignment' in df.columns:
                df.loc[mask, 'IP Assignment'] = WSL_IP
                print(f"✅ Updated IP to {WSL_IP}")
            else:
                print("❌ 'IP Assignment' column not found")
                sys.exit(1)
        else:
            # Add new row for WSL testing
            print(f"⚠️  Hostname {HOSTNAME} not found. Adding new entry...")
            new_row = {
                'Server Name': HOSTNAME,
                'IP Assignment': WSL_IP,
                'Subnet': '172.30.16.0/20',
                'Mask': '255.255.240.0',
                'Gateway': '172.30.16.1',
                'CNAME': HOSTNAME,
                'DOMAIN': 'local',
                'OS Type': 'Linux'
            }
            # Add missing columns with empty values
            for col in df.columns:
                if col not in new_row:
                    new_row[col] = ''

            df = pd.concat([df, pd.DataFrame([new_row])], ignore_index=True)
            print(f"✅ Added new entry for {HOSTNAME}")
    else:
        print("❌ 'Server Name' column not found in Excel sheet")
        sys.exit(1)

    # Save the updated Excel file
    print(f"\n💾 Saving updated file...")
    df.to_excel(EDS_FILE, sheet_name="Server Requirements", index=False)
    print(f"✅ Successfully updated {EDS_FILE}")
    print(f"\n📋 Updated configuration for {HOSTNAME}:")
    print(f"   IP: {WSL_IP}")

except FileNotFoundError:
    print(f"❌ Error: {EDS_FILE} not found")
    sys.exit(1)
except Exception as e:
    print(f"❌ Error: {str(e)}")
    import traceback
    traceback.print_exc()
    sys.exit(1)
