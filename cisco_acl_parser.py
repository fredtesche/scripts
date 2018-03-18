import os
import ipaddress

acl = [
    'access-list dmz_access_in extended',
    'access-list friends_access_in extended',
    'access-list enemies_access_in extended',
    'access-list servers_access_in extended',
    'access-list cameras_access_in extended',
    'access-list lan_access_in extended',
    'access-list wan_access_in extended'
]

permit = [
	'deny',
	'permit'
]

svc_object_type = [
	'icmp',
	'icmp6',
    'ip',
    'object',
	'object-group',
	'tcp',
	'udp'
]

net_object_type = [	
    'any',
    'any4',
    'any6',
    'host',
    'interface',
    'object',
    'object-group'
]

operator = [
    'lt',
    'gt',
    'eq',
    'neq',
    'range'
]

valid_lines = []
invalid_lines = []
orig_list = []

inputfolder = "/path/to/folder/"
processingfolder = "/path/to/folder/"

#tcp 1-65535
#udp 0-65535

process_file()

def process_files():
    # Shuffle some files around
    for file in os.listdir(inputfolder):
        if file.startswith("verify-"):
            filepath = os.path.abspath(os.path.join(inputfolder, file))
            newfilepath = os.path.abspath(os.path.join(processingfolder, file))
            os.rename(filepath, newfilepath)

            # Open the file, remove whitespace, ignore comments #, fill an array with the lines we will check
            with open(newfilepath) as file:
                lines = file.read().splitlines()
                lines = filter(None, lines)
                for line in lines:
                    if not line.startswith('#'):
                        orig_list.append(line)

            for i, line in enumerate(orig_list):
                line = validate(line, acl, "Invalid ACL.")
                line = validate(line, permit, "Permit/Deny not specified.")
                line = validate_svc_object(line, svc_object_type, "Invalid protocol")
                line = validate_net_object(line, net_object_type, "Invalid source")
                line = validate_net_object(line, net_object_type, "Invalid destination")
                line = validate(line, operator, "Invalid operator.")
                
                
				# If any line returned anything, it is invalid
                # Otherwise, it is valid
                if line: invalid_lines.append(orig_list[i])
                elif not line: valid_lines.append(orig_list[i])
                

            print("")
            print("Original:")
            for p in orig_list: print("* " + p)
            print("")
            print("Valid:")
            for p in valid_lines: print("* " + p)
            print("")
            print("Invalid:")
            for p in invalid_lines: print("* " + p)
            print("")


def validate(line, val_list, error):
    if line.startswith(tuple(val_list)):
        for p in val_list:
            if line.startswith(p):
                line = line[len(p):].strip()
                break
    else: line = error
    return line

def validate_svc_object(line, val_list, error):
    if line.startswith(tuple(val_list)):
        for p in val_list:
            if line.startswith(p):
                line = line[len(p):].strip()
                break
    else: line = error
    return line

def validate_net_object(line, val_list, error):
    if line.startswith(tuple(val_list)):
        for p in val_list:
            if line.startswith("object-group"):
                firstword = line.strip()
                firstword = line.split(' ')[0] # Extract the first word
                if firstword == "object-group":
                    line = line[len(firstword):].strip()
                    if line:
                        line = line[len(line.split(' ')[0]):].strip() # Split out the next word, whatever it is
                        return line
                    elif not line:
                        line = error+ ": Object-group not specified."
                        return line
                else: line = error
                return line    
            elif line.startswith("object"):
                firstword = line.strip()
                firstword = line.split(' ')[0] # Extract the first word
                if firstword == "object":
                    line = line[len(firstword):].strip()
                    if line:
                        line = line[len(line.split(' ')[0]):].strip() # Split out the next word, whatever it is
                        return line
                    elif not line:
                        line = error + ": Object not specified."
                        return line
                else: line = error
                return line        
            elif line.startswith("host"):
                firstword = line.strip()
                firstword = line.split(' ')[0] # Extract the first word
                if firstword == "host":
                    if line: #If there's anything left to chomp
                        line = line[len(line.split(' ')[0]):].strip() # Split out the next word, whatever it is
                        address = line.strip()
                        address = line.split(' ')[0] # Extract the first word
                        try:
                            address = unicode(address)
                            address = ipaddress.ip_address(address) # Check if it is a valid IP 
                            address = str(address)
                            line = line[len(address):].strip()
                            return line
                        except:
                            line = error + ": IP address invalid."
                            return line
                    else: line = error + ": No IP address."
                    return line
                else: line = error
                return line
            elif line.startswith(p):
                line = line[len(p):].strip()
                break
    elif not line.startswith(tuple(val_list)): # Then it's probably a network
        address = line.strip()
        address = line.split(' ')[0] # Extract the first word
        if line: #If there's anything left to chomp
            line = line[len(line.split(' ')[0]):].strip() # Split out the next word, whatever it is
            netmask = line.strip()
            netmask = line.split(' ')[0] # Extract the first word
            try:
                address = unicode(address)
                netmask = unicode(netmask)
                check = ipaddress.ip_network(address + '/' + netmask) # Check if it is a valid network
                line = line[len(line.split(' ')[0]):].strip() # Split out the next word, whatever it is
                return line
            except:
                line = error + ": IP network address invalid."
                return line
        else: line = error + ": No netmask."
        return line # Funtion is not returning the next thing to be processes. it is eating everything.
    else: line = error
    return line