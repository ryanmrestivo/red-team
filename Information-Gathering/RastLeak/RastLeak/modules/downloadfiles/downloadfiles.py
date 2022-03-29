#!/usr/bin/env python
# -*- coding: utf-8 -*-

#Libraries
import xlsxwriter
import json
#Analyze metadata pdf
import PyPDF2
from PyPDF2 import PdfFileReader
#Analyze metadata docx
import docx
import datetime
import wget
import os
from modules.createdir import *
#Global var's
metadata_files=[]
meta_author_array = []
meta_creator_array = []
meta_producer_array = []

#Count's

count_pdf = 0
count_word =0
count_others = 0

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
	global count_pdf
	global count_word
	global count_word
	try:
	#Verify the ext to know the type of the file to diference of the analysis
		ext=filename.lower().rsplit(".",1)[-1]
		if ext =="pdf" or ext == "PDF":
			count_pdf += 1
			#call the function analyze metadata pdf
			Analyze_Metadata_pdf(filename)
		elif ((ext =="doc") or (ext=="docx")):
			count_word += 1
			Analyze_Metadata_doc(filename)
		else:
			count_word += 1
			print "\nIt can't obtain the metadata. Skip the next!\n"
	except Exception as e:
		print e
####### FUNCTION DOWNLOADFILES ######
def Display_Export_Metadata(data,output,target):
	try:
		print "-----------------------------------------------"
		print "METADATA RESULTS BY CATEGORY"
		print "\n################################################\n"
		total_indexed =int(count_pdf + count_word + count_others)
		print "Documents indexed found: "+ str(total_indexed)
		print "\n PDF files: " + str(count_pdf)
		print "\n DOC/x files: " + str(count_word)
		print "\n Others files: " + str(count_others)
		print "\nUsers - Documents Author"
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
		if (output == "js"):
			print "Exporting the results in a metadata-json"
			with open("metadata.json", 'w') as f:
				json.dump(data, f)
		#excel
		if (output =="xl"):
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
			os.system ('mv metadata.xlsx /'+target)
	except Exception as e:
		print str(e)

####### FUNCTION DOWNLOADFILES ######
def Downloadfiles(urls_metadata,output,target):
	path = None
	try:
		filename = None
		print "\nDo you like downloading these files to analyze metadata(Y/N)?"
		#Convert to lower the input
		resp = raw_input().lower()
		if (resp == 'n'):
			print "Exiting"
			exit(1)
		if ((resp != 'y') and (resp != 'n')):
			print "The option is not valided. Please, try again it"
		if (resp =='y'):
			print "Indicate the location where you want to keep the files downloaded.by default in the target folder",
			path = raw_input()
			#path = createdir.CreateDir(target)
			for url in urls_metadata:
				filename = wget.download(url,str(path))
				Analyze_Metadata(filename)
			Display_Export_Metadata(metadata_files,output,target)
			if count_pdf > 1:
				os.system('mv *pdf '+ str(target))
			if count_word > 1:
				os.system('mv *doc '+ str(target))
				os.system('mv *docx '+ str(target))
			if count_others > 1:
				os.system('mv *xlsx '+ str(target))
				os.system('mv *ppt '+ str(target))
	except Exception as e:
		print str(e)