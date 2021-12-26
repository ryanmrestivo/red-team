# targeted recon using dorks


# directory listing test
| Type | Desc |
|:---:|:---:|
| site:target.com intext:dir + "last modified" -pdf | - |
| site:target.com intitle:index.of | - |


# configuration files 
| Type | Desc |
|:---:|:---:|
| site:target.com ext:xml OR ext:conf OR ext:cnf OR ext:reg OR ext:inf OR ext:rdp OR ext:cfg OR ext:txt OR ext:ora OR ext:ini | - |

# database files 
| Type | Desc |
|:---:|:---:|
| site:target.com ext:sql OR ext:dbf OR ext:mdb | - |

# log and backup files 
| Type | Desc |
|:---:|:---:|
| site:target.com ext:bkf OR ext:bkp OR ext:bak OR ext:old OR ext:backup OR ext:log  | - |

# login Portals 
| Type | Desc |
|:---:|:---:|
| site:target.com inurl:login  | - |

# SQL errors
| Type | Desc |
|:---:|:---:|
| site:target.com intext:"sql syntax near" OR intext:"incorrect syntax near" OR intext:"unexpected end of SQL command" OR intext:"Warning: mysql_connect()" OR intext:"Warning: mysql_query()" OR intext:"Warning: pg_connect()"  | - |

# public documents 
| Type | Desc |
|:---:|:---:|
| site:target.com ext:doc OR ext:docx OR ext:odt OR ext:pdf OR ext:rtf OR ext:sxw OR ext:psw OR ext:ppt OR ext:pptx OR ext:pps OR ext:csv  | - |


# google drive / docs
| Type | Desc |
|:---:|:---:|
| intitle:- Google Docs ‘keyword’ | index public docs |
| allinurl: drive.google.com/open?id= | index drive |
| site:https://docs.google.com/forms responses + names| obtain mass email |


# dropbox
| Type | Desc |
|:---:|:---:|
| intitle:index.of.dropbox  (e.g. intitle:index.of.dropbox allintext:leak) | index dropbox |
| site:dl.dropbox.com | index dropbox links |


# start.me
| Type | Desc |
|:---:|:---:|
| start.me | site:*.start.me keyword | leak | sources | OSINT.. etc  |


# Potential exposed leaked data / comapny exposed portals shares.etc (project management frameworks)


# Trello - index boards / public / users / files / info
| Type | Desc |
|:---:|:---:|
| trello | site:trello.com inurl:/b/ intext:OSINT  |


# Taiga.io - index boards / public / users / files / projects
| Type | Desc |
|:---:|:---:|
| taiga | site:taiga.io inurl:project keyword  |


# GitLab - like github, index public repos with keys or sensitive data
| Type | Desc |
|:---:|:---:|
| in gitlab | site:gitlab.com keyword intext:details  |
| gitlab.*.* | site:gitlab.*.* keyword -site:gitlab.com  |


# Bitbucket - like github, index public repos with keys or sensitive data
| Type | Desc |
|:---:|:---:|
| bitbucket | site:bitbucket.*.* keyword |


# Loomio.org - index boards / public / users / teams / files / projects
| Type | Desc |
|:---:|:---:|
| loomio | site:loomio.org -inurl:/d/ inurl:/g/ keyword |


# Jira - comapny portals using jira with option to register and view internal data
| Type | Desc |
|:---:|:---:|
| jira | site:jira.*.* intext:Sign up  |
can be costumized for specific comapny name like jira.target.com or just subdomain enum
create acc >  view available data / files / users / etc.


