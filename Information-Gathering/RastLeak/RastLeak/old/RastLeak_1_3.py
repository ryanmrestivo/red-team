import requests
from requests.packages.urllib3.exceptions import InsecureRequestWarning
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)
#Disable warning by SSL certificate
import ssl
ssl._create_default_https_context = ssl._create_unverified_context
import wget
#Libraries to export results
import xlsxwriter
import json
from urlparse import urlparse
from bs4 import BeautifulSoup
import optparse
#Analyze metadata pdf
import PyPDF2
from PyPDF2 import PdfFileReader
#Analyze metadata docx
import docx
import datetime
#Parser arguments
import argparse
from argparse import RawTextHelpFormatter
# encoding=utf8
import sys
reload(sys)
sys.setdefaultencoding('utf8')
#define global vars
dork=["site:","-site:","filetype:","intitle:","intext:"]
urls = []
urls_clean = []
urls_final =[]
delete_bing=["microsoft","msn","bing"]
option = 0
metadata_files=[]
meta_author_array = []
meta_creator_array = []
meta_producer_array = []

####### FUNCTION CREATE A DORK ######
#********************************************************#
#Define and design the dork
def DesignDork( num,file_ext):
	iteration=0
	initial=1
	count_bing=9
	try:
		while (iteration < num):
			#WAITING A DORK IN BING
			iteration = iteration +1
			if initial==1:
				print "\nSearching possible leak information...\n"
				initial = 0
				#First search in Bing
				SearchBing = "https://www.bing.com/search?q="+dork[0]+target+" ("+dork[2]+"pdf+OR+"+dork[2]+"doc)&go=Buscar"
			else:
				#Bring the next Bing results - 50 in each page
				SearchBing=SearchBing + "&first="+str(count_bing)+"&FORM=PORE"
				count_bing=count_bing+50
			SendRequest(SearchBing)
	except:
		pass
#********************************************************#
####### FUNCTION SEND REQUEST TO BING ######
#Doing the request to search
def SendRequest(dork):
	#Verify if the resource is avaiable by HTTP or HTTPS
	try:
		#Requests
		#Timeout to verify if the resource is available and verify to ignore SSL certificate
		response=requests.get(dork,allow_redirects=True, timeout=10,verify=False)	
	except:
		print "\nError connection to server!" + response.url,
	pass	
	content = response.text	
	#PARSER HTML
	#normalize a called with parameters
	parser_html(file_ext,content)
#********************************************************#
####### FUNCTION PARSER HTML ######
#Definition and treatment of the parameters
def parser_html(type,content):
	i = 0
	soup = BeautifulSoup(content, 'html.parser')
	for link in soup.find_all('a'):
		try:
			if (urlparse(link.get('href'))!='' and urlparse(link.get('href'))[1].strip()!=''):	
				#if file_ext == 1: -> Display the domains where the files are found.
				if type == 1:
					urls.append(urlparse(link.get('href'))[1]) #domain
				else: # file_ext == 2 -> ofimatic files: pdf, doc,docx,xls,....
					urls.append(link.get('href'))
		except Exception as e:
			#print(e)
			pass
	try:
		#Delete duplicates
		[urls_clean.append(i) for i in urls if not i in urls_clean] 
	except:
		pass
	try:
		#Delete not domains belongs to target
		for value in urls_clean:
			if (value.find(delete_bing[0])  == -1):
				if (value.find(delete_bing[1])  == -1):
					if (value.find(delete_bing[2])  == -1):
						urls_final.append(value)
	except:
		pass
####### FUNCTION DOWNLOADFILES ######
def ExportResults(data):
	with open ('output.json','w') as f:
			json.dump(data,f)
####### FUNCTION AnalyzeMetadata pdf ######
def Analyze_Metadata_pdf(filename):
####### FUNCTION AnalyzeMetadata ######
	pdfFile = PdfFileReader(file(filename, 'rb'))
	metadata = pdfFile.getDocumentInfo()
	print ' - Document: ' + str(filename)
	for meta in metadata:
		value=(metadata[meta])
		print ' - ' + meta + ':' + metadata[meta]
		if meta == "/Author":
			if value not in meta_author_array:
				meta_author_array.append(value)
		elif meta =="/Producer":
			if value not in meta_producer_array:
				meta_producer_array.append(value)
		elif meta == "/Creator":
			if value not in meta_creator_array:
				meta_creator_array.append(value)
	#Group the different arrays in one with all metadata
	metadata_files.append(meta_author_array)
	metadata_files.append(meta_producer_array)
	metadata_files.append(meta_creator_array)
	#print metadata_files
####### FUNCTION AnalyzeMetadata doc ######
def Analyze_Metadata_doc(fileName):
	#Open file
	docxFile = docx.Document(file(fileName,'rb'))
	#Get the structure
	docxInfo= docxFile.core_properties
	#Print the metadata which it wants to display
	attribute = ["author", "category", "comments", "content_status", 
	    "created", "identifier", "keywords", "language", 
	    "last_modified_by", "last_printed", "modified", 
	    "revision", "subject", "title", "version"]
	#run the list in a for loop to print the value of each metadata
	print ' - Document: ' + str(fileName)
	for meta in attribute:
	    metadata = getattr(docxInfo,meta)
	    value = metadata([meta])
	    if metadata:
	    	if meta =="/Author":
	    		if value not in meta_author_array:
	    			meta_author_array.append(value)
			elif meta == "/Producer":
				if value not in meta_producer_array:
					meta_producer_array.append(value)
			elif meta =="/Creator":
				if value not in meta_creator_array:
					meta_creator_array.append(value)
	        #Separate the values unicode and time date
	        if isinstance(metadata, unicode): 
	            print " \n\t" + str(meta)+": " + str(metadata)
	        elif isinstance(metadata, datetime.datetime):
	            print " \n\t" + str(meta)+": " + str(metadata)

####### FUNCTION CATEGORY FILE TO EXTRACT METADATA ######
def Analyze_Metadata(filename):
	#Verify the ext to know the type of the file to diference of the analysis
	ext=filename.lower().rsplit(".",1)[-1]
	if ext =="pdf":
		#call the function analyze metadata pdf
		Analyze_Metadata_pdf(filename)
	elif ((ext =="doc") or (ext=="docx")):
		Analyze_Metadata_doc(filename)
	else:
		print "\nIt can't obtain the metadata. Skip the next!\n"

####### FUNCTION DOWNLOADFILES ######
def Display_Export_Metadata(data,output):
	try:
		print "-----------------------------------------------"
		print "METADATA RESULTS BY CATEGORY"
		print "\n################################################\n"
		print "Users - Documents Author"
		for user in data[0]:
			print "	" + str(user).encode('utf8')
		print "\n##################################################\n"
		print "Producer"
		#print "Producer"+ str(data[1])
		for producer in data[1]:
			print "\t " + str(producer).encode('utf8')
		print "\n################################################\n"
		#print "Creator"+ str(data[2])
		print "Creator"
		for creator in data[2]:
			print "	" + str(creator).encode('utf8')
		print "\n################################################\n"
		print "-----------------------------------------------"
		# Start from the first cell. Rows and columns are zero indexed.
		row = 0
		col = 0
		#json
		if (output == 1):
			print "Exporting the results in a metadata-json"
			with open("metadata.json", 'w') as f:
				json.dump(data, f)
		#excel
		if (output ==2):
			print "Exporting the results in an excel"
			# Create a workbook and add a worksheet.
			workbook = xlsxwriter.Workbook('metatada.xlsx')
			worksheet = workbook.add_worksheet()
			worksheet.write(row, col, "Users")
			worksheet.write(row, col+1, "Producer")
			worksheet.write(row, col+2, "Creator")
			row+=1
			# Iterate over the data and write it out row by row.
			for users in meta_author_array:
				col = 0
				worksheet.write(row, col, users)
				row += 1
			#update row
			row=1
			for producer in meta_producer_array:
				col = 1
				worksheet.write(row, col, producer)
				row += 1
			#update row
			row=1
			for creator in meta_creator_array:
				col = 2
				worksheet.write(row, col, creator)
				row += 1
			#close the excel
			workbook.close()	
	except Exception as e:
		print str(e)

####### FUNCTION DOWNLOADFILES ######
def Downloadfiles(urls_metadata,output):
	try:
		print "\nDo you like downloading these files to analyze metadata(Y/N)?"
		#Convert to lower the input
		resp = raw_input().lower()
		if (resp == 'n'):
			print "Exiting"
			exit(1)
		if ((resp != 'y') and (resp != 'n')):
			print "The option is not valided. Please, try again it"
		if (resp =='y'):
			print "Indicate the location where you want to keep the files downloaded",
			path = raw_input()
			try:
				for url in urls_metadata:
					try:
						filename = wget.download(url,path)
						Analyze_Metadata(filename)
					except:
						pass
				Display_Export_Metadata(metadata_files,output)
			except:
				pass
	except Exception as e:
		print str(e)
#********************************************************#
#Definition and treatment of the parameters
def ShowResults(newlist,num_files,target,output):
	print "Files in the target "+target+" are:\n"
	print "Files indexed:", len (urls_final)
	for i in urls_final:
		if i not in newlist:
			newlist.append(i)
			print i		
	#verify if the user wants to export results
	if output == 'Y':
		#Only it can enter if -j is put in the execution
		ExportResults(newlist)
	#Call to function to download the files		
	Downloadfiles(newlist,output)
#MAIN
parser = argparse.ArgumentParser(description='This script searchs files indexed in the main searches of a domain to detect a possible leak information', formatter_class=RawTextHelpFormatter)
parser.add_argument('-d','--domain', help="The domain which it wants to search",required=False)
parser.add_argument('-n','--search', help="Indicate the number of the search which you want to do",required=True)
parser.add_argument('-e','--ext', help='Indicate the option of display:\n\t1-Searching the domains where these files are found\n\t2-Searching ofimatic files\n\n', required=True)
parser.add_argument('-f','--export', help="Indicate the type of format to export results.\n\t1.json (by default)\n\t2.xlsx",required=False)
args = parser.parse_args()
print "  _____           _   _                _    "
print " |  __ \         | | | |              | |   "
print"  | |__) |__ _ ___| |_| |     ___  __ _| | __"
print"  |  _  // _` / __| __| |    / _ \/ _` | |/ /"
print"  | | \ \ (_| \__ \ |_| |___|  __/ (_| |   < "
print"  |_|  \_\__,_|___/\__|______\___|\__,_|_|\_\""
print "\n"
print """** Tool to automatic leak information using Bing Hacking
** Version 1.3
** Author: Ignacio Brihuega Rodriguez a.k.a N4xh4ck5
** DISCLAMER This tool was developed for educational goals. 
** The author is not responsible for using to others goals.
** A high power, carries a high responsibility!"""
num_files=0
N = int (args.search)
target=args.domain
file_ext= int(args.ext)
output = (int) (args.export)
if output is None:
	export=1
if ((output != 1) and (output !=2)):
	print "The export is not valid"
	exit(1)
#Call design the dork
try:
	num_files = DesignDork(N,file_ext)
except: 
	pass
newlist=[]
#Called the function to display the results
ShowResults(newlist,num_files,target,output)
