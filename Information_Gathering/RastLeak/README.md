# RastLeak

Tool to automatic leak information using Hacking with engine searches (Google and Bing).

# How to install

<pre> git clone https://github.com/n4xh4ck5/RastLeak.git </pre>

Install dependencies with pip:

<pre> pip install -r requirements.txt </pre>

To install wget:

<pre>sudo pip install wget </pre>


# Version

The last stable version is 2.2

# Usage

<pre>

python rastleak.py -h

usage: rastleak.py [-h] -d DOMAIN [-v VERSION] -o OPTION -n SEARCH -e EXT
                   [-f EXPORT]

This script searchs files indexed in the main searches of a domain to detect a possible leak information

optional arguments:

  -h, --help            show this help message and exit
  
  -d DOMAIN, --domain DOMAIN
  
                        The domain which it wants to search
                        
  -v VERSION, --version VERSION
  
                        Display the version (v=yes)
                        
  -o OPTION, --option OPTION
  
                        Indicate the option of search
                        	1.Searching leak information into the target
                        	2.Searching leak information outside target
  -n SEARCH, --search SEARCH
  
                        Indicate the number of the search which you want to do
 
 -e EXT, --ext EXT     Indicate the option of display:
 
                        	1-Searching the domains where these files are found
                        	2-Searching ofimatic files
                        
  -f EXPORT, --export EXPORT
  
                        Export the results in a file (Y/N)
                         Format available:
                        	1.json
                        	2.xlsx
</pre>
                          
# Author

Ignacio Brihuega Rodríguez aka n4xh4ck5

Twitter: @n4xh4ck5

Web: fwhibbit.es

# Disclamer

The use of this tool is your responsability. I hereby disclaim any responsibility for actions taken with this tool.                          
                                                  
