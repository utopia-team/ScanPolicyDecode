#!/usr/bin/env python3
import sys, os, re

oc_list = {'1': "OC_SCAN_FILE_SYSTEM_LOCK",
		   '2': "OC_SCAN_DEVICE_LOCK",
		   '256': "OC_SCAN_ALLOW_FS_APFS",
		   '512': "OC_SCAN_ALLOW_FS_HFS",
		   '1024': "OC_SCAN_ALLOW_FS_ESP",
		   '2048': "OC_SCAN_ALLOW_FS_NTFS",
		   '4096': "OC_SCAN_ALLOW_FS_LINUX_ROOT",
		   '8192': "OC_SCAN_ALLOW_FS_LINUX_DATA",
		   '16384': "OC_SCAN_ALLOW_FS_XBOOTLDR",
		   '65536': "OC_SCAN_ALLOW_DEVICE_SATA",
		   '131072': "OC_SCAN_ALLOW_DEVICE_SASEX",
		   '262144': "OC_SCAN_ALLOW_DEVICE_SCSI",
		   '524288': "OC_SCAN_ALLOW_DEVICE_NVME",
		   '1048576': "OC_SCAN_ALLOW_DEVICE_ATAPI",
		   '2097152': "OC_SCAN_ALLOW_DEVICE_USB",
		   '4194304': "OC_SCAN_ALLOW_DEVICE_FIREWIRE",
		   '8388608': "OC_SCAN_ALLOW_DEVICE_SDCARD",
		   '16777216': "OC_SCAN_ALLOW_DEVICE_PCI"
}


def cls():
  	os.system('cls' if os.name=='nt' else 'clear')

def grab(prompt = ""):
	if sys.version_info >= (3, 0):
		return input(prompt)
	else:
		return str(raw_input(prompt))

def _check_hex(hex_string):
	# Remove 0x/0X
	hex_string = hex_string.replace("0x", "").replace("0X", "")
	hex_string = re.sub(r'[^0-9A-Fa-f]+', '', hex_string)
	return hex_string

def hex_to_dec(hex_string):
	hex_string = _check_hex(hex_string)
	if not len(hex_string):
		return None
	try:
		dec = int(hex_string, 16)
	except:
		return None
	return dec

def hex_to_vals(hex_string):
	# Convert the hex to decimal string - then start with a reversed list
	# and find out which values we have enabled
	dec = hex_to_dec(hex_string)
	if not dec:
		return []
	has = []
	for key in sorted(oc_list, key=lambda x:int(x), reverse=True):
		if int(key) <= dec:
			has.append(oc_list[str(key)])
			dec -= int(key)
	return has

def main():
	cls()
	print("# ScanPolicyDecode #")
	print("")
	print("1. Hex To Values")
	print("2. Values to Hex")
	print("")
	print("Q. Quit")
	print("")
	menu = grab("Please select an option:  ").lower()
	if not len(menu):
		return
	if menu == "q":
		exit()
	elif menu == "1":
		h_to_v()
	elif menu == "2":
		v_to_h()
	return
	
def h_to_v():
	cls()
	print("# ScanPolicy Hex To Values #")
	print("")
	while True:
		h = grab("Please type a ScanPolicy value in hex (m for main menu):  ")
		if not h:
			continue
		if h.lower() == "m":
			return
		elif h.lower() == "q":
			exit()
		has = hex_to_vals(h)
		if not len(has):
			print("\nNo values found.\n")
		else:
			nl = '\n' #che porcata sta cosa, ma vabbe, thx python
			print(f"""{nl}Active values:{nl}{nl}{nl.join(has)}{nl}""")

def v_to_h():
	# Create a dict with all values unchecked
	toggle_dict = []
	for x in sorted(oc_list, key=lambda x:int(x)):
		toggle_dict.append({"value":int(x),"enabled":False,"name":oc_list[x]})
	while True:
		cls()
		print("# ScanPolicy Values To Hex #")
		print("")
		# Print them out
		for x,y in enumerate(toggle_dict,1):
			print(f"""[{"#" if y["enabled"] else " "}] {x}. {y["name"]} - {hex(y["value"])}""")
		print("")
		# Add the values of the enabled together
		curr = 0
		for x in toggle_dict:
			if not x["enabled"]:
				continue
			curr += x["value"]
		print(f"Current:  {hex(curr)} / {curr}")
		print("")
		print("A. Select All")
		print("N. Select None")
		print("M. Main Menu")
		print("Q. Quit")
		print("")
		print("Select options to toggle with comma-delimited lists (eg. 1,2,3,4,5)")
		print("")
		menu = grab("Please make your selection:  ").lower()
		if not len(menu):
			continue
		if menu == "m":
			return
		elif menu == "q":
			exit()
		elif menu == "a":
			for x in toggle_dict:
				x["enabled"] = True
			continue
		elif menu == "n":
			for x in toggle_dict:
				x["enabled"] = False
			continue
		# Should be numbers
		try:
			nums = [int(x) for x in menu.replace(" ","").split(",")]
			for x in nums:
				if x < 1 or x > len(toggle_dict):
					# Out of bounds - skip
					continue
				toggle_dict[x-1]["enabled"] ^= True
		except:
			continue

while True:
	main()
