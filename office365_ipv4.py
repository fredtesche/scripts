### This script will grab an xml file of Microsoft Office365 IPs from https://support.office.com/en-us/article/Office-365-URLs-and-IP-address-ranges-8548a211-3fe7-47cb-abb1-355ea5aa88a2
### Then it will format the IPv4 addresses into a format that a Cisco router likes. Or reformat the output for something else.
###
### This script requires urllib2, ipaddress, filecmp, colorama, and lxml.
###
### No warranty implied, do whatever you want with this script blah blah blah...
### Fred Tesche 2018 fred@fakecomputermusic.com

import urllib2
import ipaddress
import filecmp
from colorama import Fore, Back, Style
from lxml import etree

url = 'https://support.content.office.net/en-us/static/O365IPAddresses.xml'

def getFile(url):
  try:
    return urllib2.urlopen(url).read()
	except urllib2.HTTPError, e:
		print(Fore.RED +"Error " + str(e.code) + Style.RESET_ALL + " when trying to access " + Fore.GREEN + url + Style.RESET_ALL)
		quit()
	except urllib2.URLError, e:
		print e.args
		print(Fore.RED +"Error " + str(e.args) + Style.RESET_ALL + " when trying to access " + Fore.GREEN + url + Style.RESET_ALL)
		quit()

# Open the xml file
xmldata = getFile(url)

# Parse the XML file
doc = etree.fromstring(xmldata)
btags = doc.xpath("//products/product/addresslist[@type='IPv4']/address")
print("object-group network Office365_IPs")
for b in btags:
	cidr = unicode(b.text)
	address = ipaddress.ip_network(cidr).network_address
	netmask = ipaddress.ip_network(cidr).netmask
	address = str(address)
	netmask = str(netmask)
	print("network-object " + address + " " + netmask)
quit()

