# ADOffline

## Summary

Most penetration testers, or those engaged in simulated attacks or red team activities, will understand the value of reconnisance. On large corporate networks, this will involve a fair amount of Active Directory querying. There are some exceptionally powerful tools built into Empire, PowerTools and Metasploit, but these all rely on an active connection to a domain controller.

This tool combines the flexibility of SQL with the raw detail in Active Directory by parsing the raw LDAP output from Active Directory and inserting it into a SQLite database. This can then be used to explore user and group membership and download all computer information.

There is a huge amount of information stored in LDAP; this tool does not seek to recover it all, but instead should help with planning attacks or identifying high value target users without needing to constantly query AD.

It is work in progress; all commits/PRs/support welcome. 

_AT THE MOMENT, THIS IS BETA CODE_. 
It has not been fully tested but has been used successfully on various targeted attacks and engagements.

## Benefits

* Allows enumeration of users, computers (including hostname, OS etc) and groups; these are all derived from users.
* Parses flags (e.g. sAMAccountType, userAccountControl) for intuitive searching.
* Easy to enumerate basic and nested group membership.

## Drawbacks

* Will take a while to parse a large LDIF file. During testing, it took 30 minutes to parse a large domain containing roughly 100,000 users, groups and computers.
* Reqires a large data exchange with the domain controller which may be noticed. For example, the domain above generated a 400Mb LDAP file, although this was generated in approximately 4 minutes.
* Does not currently consider foreign groups (i.e. from trusts).

## Usage

This assumes that you have low privilege (e.g. standard user) access to a domain and that you are able to connect to TCP/389 (LDAP) on a domain controller. On an internal penetration test, you can access a domain controller directly but, on a simulated attack or red team, use a port forward or SOCKS proxy or equivalent.

1. Use ldapsearch to download the Active Directory structure. At the current time of writing, the script only parses the 'user' object class; this will have the effect of parsing all users, groups and computers on the domain.
2. ldapsearch will generate an LDIF file which is an ASCII text file containing the AD structure. Import this into a SQLite database using adoffline.py.
3. Query the SQLite database using a command line tool or a front end.

## Efficiency

The current version is not complete; there are several efficiency improvements to be made and features to be added. It currently:

* Stores users, groups and computers
* Calculates nested groups for users only

This was tested on a real client domain with approximately 100,000 individual users, groups and computers. It took approximately 30 minutes to parse the 7 million lines in the original LDIF file to generate the database and another half an hour to work out the nested groups on a laptop (single threaded).

```
$ ldapsearch -h <ip> -x -D <username> -w <password> -b <base DN> -E pr=1000/noprompt -o ldif-wrap=no > client.ldif
...

$ ls -lah client.ldif
-rw-r--r--  1 stuart  users   391M Jan 21 08:18 client.ldif

$ python adoffline.py client.ldif
AD LDAP to SQLite Offline Parser
Stuart Morgan (@ukstufus) <stuart.morgan@mwrinfosecurity.com>

[31/Jan/16 23:31:52] Creating database: /tmp/tmpBQXkFH.20160131233152.ad-ldap.db
[31/Jan/16 23:31:52] Reading LDIF...done
[31/Jan/16 23:31:53] Parsing LDIF...
  Reading line 7001808/7001808 (100%)
[31/Jan/16 23:59:24] Calculating chain of ancestry (nested groups)...
  Processed user 27385/27385 (100%)
[01/Feb/16 00:27:35] Completed

        Users: 27385
       Groups: 38334
    Computers: 29142
 Associations: 2102885
 
$ ls -lah /tmp/tmpBQXkFH.20160131233152.ad-ldap.db
-rw-r--r--  1 stuart  wheel   1.0G Feb  1 00:27 /tmp/tmpBQXkFH.20160131233152.ad-ldap.db
```

The database size for the above example was 1GB which is perfectly manageable.

## Database Structure

A user, group and computer is, in essence, the same thing as far as LDAP is concerned. There are some attributes that do not make sense if you are not a computer (e.g. operatingSystem) but at a high level, each of these records is considered as a user at heart. However, there are a number of SQL views that can be used to offer easy identification of computers, groups and users in a more intuitive manner.

### LDAP Fields Captured

The table below shows the LDAP attributes that ADOffline currently identifies and parses. Note that in some cases, the description is based on the believed general usage of the attribute; there may be circumstances where an organisation uses this field for a different reason. 

The actual fields in the database are covered later; this is because the fields below are sometimes parsed and interpreted in order to make their meaning clearer. 

Attribute | Purpose
------------| -------
objectClass | The type of object.
dn | The distinguished name, used as a unique identifier.
title | The job title of an individual.
cn | The name that represents an object. This is usually the name of the user, computer or group.
givenName | Contains the given name (first name) of the user.
sn | Surname
description | This is a free-text field which is usually used to store comments relating to this user, computer or group. Sometimes it can have useful information such as default passwords, the purpose of the user or an explanation of how to interact with them. By default, Ben Campbell's metasploit POST module (post/windows/gather/enum_ad_user_comments) works by searching the description field for 'pass' although this is configurable.
instanceType | This is described by Microsoft as "A bitfield that dictates how the object is instantiated on a particular server. The value of this attribute can differ on different replicas even if the replicas are in sync.". Generally speaking, it seems to be 4.
displayName | Usually the full name of the user
member | Groups can have zero or more 'member' attributes; this indicates that the DN specified is a member of that group.
memberOf | Groups, users and computers can have zero or more 'memberOf' attributes; this indicates that the current DN is a member of the DN specified.
name | Seems to be the same as displayName most of the time
dNSHostName | For computers, it is the DNS hostname of the computer.
userAccountControl | Flags that control the behaviour of the user account. See https://msdn.microsoft.com/en-us/library/windows/desktop/ms680832%28v=vs.85%29.aspx for a description, but ADOffline parses them to make them easier to search for.
badPwdCount | The number of times the user tried to log on to the account using an incorrect password. A value of 0 indicates that the value is unknown. See https://technet.microsoft.com/en-us/library/cc775412%28WS.10%29.aspx for a description; it appears that this is maintained on a per-DC basis and is reset (on the specific DC) when there is a successful login. 
primaryGroupID | The PrimaryGroupID attribute on a user or group object holds the RID of the primary group. Therefore, the user can be considered to be a member of this group even if no 'member' or 'memberOf' attributes are present.
adminCount | Indicates that a given object has had its ACLs changed to a more secure value by the system because it was a member of one of the administrative groups (directly or transitively). Basically, anyone with adminCount=1 is or was a privileged user of some sort.
objectSid | The SID 
sAMAccountName | The username (the logon name used to support clients and servers running earlier versions of the operating system.)
sAMAccountType | This attribute contains information about every account type object. This is parsed by ADOffline.
objectCategory | "An object class name used to group objects of this or derived classes."
operatingSystem | The named operating system; only relevant to computers for obvious reasons.
operatingSystemVersion | The version of the operating system.
operatingSystemServicePack | The identifier of the latest service pack installed
managedBy | The distinguished name of the user that is assigned to manage this object. Useful as a starting point when looking for managed groups with additional permissions.
info | One of the general fields available in AD. Sometimes used to store interesting information relating to a user/group/computer.
department | The department to which the user belongs.
company | The name of the company.
homeDirectory | The default home directory location which is mapped to the user's home directory. Useful to identify file servers quickly on the network, but be mindful of DFS (i.e. \\domain\home\user vs \\fileserver\home\user).
userPrincipalName | Usually the user's e-mail address.
manager | The user's manager; useful for generating organisational charts. Note that this is different from the 'managedBy' attribute; the manager seems to be for display/organisation chart purposes only.
mail | Another field that contains the user's e-mail address.
groupType | Contains a set of flags that define the type and scope of a group object. 

### The Database Tables

Internally, the database has two tables which are created automatically using the statements below.

```
CREATE TABLE raw_users ('objectClass','dn','title', 'cn','sn','description','instanceType','displayName','name','dNSHostName','userAccountControl','badPwdCount','primaryGroupID','adminCount','objectSid','sid','rid','sAMAccountName','sAMAccountType', 'objectCategory','operatingSystem','operatingSystemServicePack','operatingSystemVersion','managedBy','givenName','info','department','company','homeDirectory','userPrincipalName','manager','mail','groupType');

CREATE TABLE raw_memberof ('dn_group' TEXT NOT NULL,'dn_member' TEXT NOT NULL, PRIMARY KEY('dn_group','dn_member'));
```

The first table (raw_users) holds the basic information retrieved from LDAP as discussed in the table above. The second table stores any DNs referenced by a member or memberOf attribute. For example, if UserA and UserB are members of GroupX, raw_memberof will contain:

dn_group | dn_member
---|---
GroupX | UserA
GroupX | UserB

(in reality, it will contain DNs rather than usernames, but this illustrates the point). The idea is that the raw_memberof table can be joined with the raw_users table to be able to determine who is a member of what.

### The Database Views

In order to make this easier to interact with, a number of views; a view is essentially a table which is generated at runtime from a SQL query. 

Name | Purpose
---|---
view_raw_users | This view (which can be treated as a table for the purposes of querying) shows the contents of the raw_users table, but also adds a number of additional columns to split up the userAccountControl and sAMAccountType values. For example, you could search for ADS_UF_LOCKOUT=1 instead of (userAccountControl&00000010).
view_groups | This will effectively display the contents of the view above, restricting the results to groups only, and adding in the groupType parameter parsing. In effect, this can be used to list all stored information about all groups.
view_users | Displays the contents of the view_raw_users table, but only shows users (rather than groups and computers).
view_computers | As above, but only shows computers.
view_groupmembers | This uses the raw_memberof table to (internally) join the users table with itself. The effect is being able to search by all attributes on a group or its members. The group fields are denoted by the prefix group_ and the member fields are denoted by the prefix member_. For example, 'SELECT member_cn FROM view_groupmembers where group_cn = "Domain Admins"' would display all members of the Domain Admins group, taking into account nested groups.
view_activegroupusers | This restricts the output of view_groupmembers to users who are not locked and not disabled. The same query as above, but only returning names of users who are active would be 'select member_cn from view_activegroupusers where group_cn = "Domain Admins"'

This probably looks quite confusing and inefficient, and both are true. However, designing it this way does make it very powerful; it enables almost any sensible search to be performed offline which is of particular use during simulated attacks because you can identify high value accounts completely offline, and get a good idea of the internals of the target domain without running repeated queries.

I would encourage you to take the time to get used to this. I have provided a description of each of the fields available in the database below and, below that, some examples of common queries.

### The Database Fields

The fields available from the views are shown below.

Name | Purpose
---|---
objectClass | The type of object.
dn | The distinguished name (and primary key).
title | The job title of an individual.
cn | The name that represents an object. This is usually the name of the user, computer or group.
givenName | Contains the given name (first name) of the user.
sn | Surname
description | This is a free-text field which is usually used to store comments relating to this user, computer or group. Sometimes it can have useful information such as default passwords, the purpose of the user or an explanation of how to interact with them. By default, Ben Campbell's metasploit POST module (post/windows/gather/enum_ad_user_comments) works by searching the description field for 'pass' although this is configurable.
instanceType | This is described by Microsoft as "A bitfield that dictates how the object is instantiated on a particular server. The value of this attribute can differ on different replicas even if the replicas are in sync.". Generally speaking, it seems to be 4.
displayName | Usually the full name of the user
member | Groups can have zero or more 'member' attributes; this indicates that the DN specified is a member of that group.
memberOf | Groups, users and computers can have zero or more 'memberOf' attributes; this indicates that the current DN is a member of the DN specified.
name | Seems to be the same as displayName most of the time
dNSHostName | For computers, it is the DNS hostname of the computer.
userAccountControl | Flags that control the behaviour of the user account. See https://msdn.microsoft.com/en-us/library/windows/desktop/ms680832%28v=vs.85%29.aspx for a description, but ADOffline parses them to make them easier to search for.
badPwdCount | The number of times the user tried to log on to the account using an incorrect password. A value of 0 indicates that the value is unknown. See https://technet.microsoft.com/en-us/library/cc775412%28WS.10%29.aspx for a description; it appears that this is maintained on a per-DC basis and is reset (on the specific DC) when there is a successful login. 
primaryGroupID | The PrimaryGroupID attribute on a user or group object holds the RID of the primary group. Therefore, the user can be considered to be a member of this group even if no 'member' or 'memberOf' attributes are present.
adminCount | Indicates that a given object has had its ACLs changed to a more secure value by the system because it was a member of one of the administrative groups (directly or transitively). Basically, anyone with adminCount=1 is or was a privileged user of some sort.
objectSid | The SID in binary form, converted to base64.
sid | The SID expressed in expanded numeric form (e.g. S-1-5-21-xxxxxxxxxx-500)
rid | The RID (i.e. the last part of the SID)
sAMAccountName | The username (the logon name used to support clients and servers running earlier versions of the operating system.)
sAMAccountType | This attribute contains information about every account type object. This is parsed by ADOffline.
objectCategory | "An object class name used to group objects of this or derived classes."
operatingSystem | The named operating system; only relevant to computers for obvious reasons.
operatingSystemVersion | The version of the operating system.
operatingSystemServicePack | The identifier of the latest service pack installed
managedBy | The distinguished name of the user that is assigned to manage this object. Useful as a starting point when looking for managed groups with additional permissions.
info | One of the general fields available in AD. Sometimes used to store interesting information relating to a user/group/computer.
department | The department to which the user belongs.
company | The name of the company.
homeDirectory | The default home directory location which is mapped to the user's home directory. Useful to identify file servers quickly on the network, but be mindful of DFS (i.e. \\domain\home\user vs \\fileserver\home\user).
userPrincipalName | Usually the user's e-mail address.
manager | The user's manager; useful for generating organisational charts. Note that this is different from the 'managedBy' attribute; the manager seems to be for display/organisation chart purposes only.
mail | Another field that contains the user's e-mail address.
groupType | Contains a set of flags that define the type and scope of a group object. 
ADS_UF_SCRIPT  | If 1, the logon script is executed.
ADS_UF_ACCOUNTDISABLE  | If 1, the user account is disabled.
ADS_UF_HOMEDIR_REQUIRED  | If 1, the home directory is required.
ADS_UF_LOCKOUT | If 1, the account is currently locked out.
ADS_UF_PASSWD_NOTREQD  | If 1, no password is required.
ADS_UF_PASSWD_CANT_CHANGE  | If 1, the user cannot change the password. 
ADS_UF_ENCRYPTED_TEXT_PASSWORD_ALLOWED | If 1, the user can send an encrypted password.
ADS_UF_TEMP_DUPLICATE_ACCOUNT  | If 1, this is an account for users whose primary account is in another domain. This account provides user access to this domain, but not to any domain that trusts this domain. Also known as a local user account.
ADS_UF_NORMAL_ACCOUNT  | If 1, this is a default account type that represents a typical user.
ADS_UF_INTERDOMAIN_TRUST_ACCOUNT | If 1, this is a permit to trust account for a system domain that trusts other domains.
ADS_UF_WORKSTATION_TRUST_ACCOUNT | If 1, this is a computer account for a computer that is a member of this domain.
ADS_UF_SERVER_TRUST_ACCOUNT  | If 1, this is a computer account for a system backup domain controller that is a member of this domain.
ADS_UF_DONT_EXPIRE_PASSWD  | If 1, the password for this account will never expire.
ADS_UF_MNS_LOGON_ACCOUNT | If 1, this is an MNS logon account.
ADS_UF_SMARTCARD_REQUIRED  | If 1, the user must log on using a smart card.
ADS_UF_TRUSTED_FOR_DELEGATION  | If 1, the service account (user or computer account), under which a service runs, is trusted for Kerberos delegation. Any such service can impersonate a client requesting the service.
ADS_UF_NOT_DELEGATED | If 1, the security context of the user will not be delegated to a service even if the service account is set as trusted for Kerberos delegation.
ADS_UF_USE_DES_KEY_ONLY  | If 1, restrict this principal to use only Data Encryption Standard (DES) encryption types for keys.
ADS_UF_DONT_REQUIRE_PREAUTH  | If 1, this account does not require Kerberos pre-authentication for logon.
ADS_UF_PASSWORD_EXPIRED  | If 1, the user password has expired. This flag is created by the system using data from the Pwd-Last-Set attribute and the domain policy.
ADS_UF_TRUSTED_TO_AUTHENTICATE_FOR_DELEGATION  | If 1, the account is enabled for delegation. This is a security-sensitive setting; accounts with this option enabled should be strictly controlled. This setting enables a service running under the account to assume a client identity and authenticate as that user to other remote servers on the network.
SAM_DOMAIN_OBJECT | See https://msdn.microsoft.com/en-us/library/windows/desktop/ms679637%28v=vs.85%29.aspx. If 1, this flag is set.
SAM_GROUP_OBJECT | If 1, this flag is set (sAMAccountType attribute).
SAM_NON_SECURITY_GROUP_OBJECT | If 1, this flag is set (sAMAccountType attribute).
SAM_ALIAS_OBJECT | If 1, this flag is set (sAMAccountType attribute).
SAM_NON_SECURITY_ALIAS_OBJECT | If 1, this flag is set (sAMAccountType attribute).
SAM_USER_OBJECT | If 1, this flag is set (sAMAccountType attribute).
SAM_NORMAL_USER_ACCOUNT | If 1, this flag is set (sAMAccountType attribute).
SAM_MACHINE_ACCOUNT | If 1, this flag is set (sAMAccountType attribute).
SAM_TRUST_ACCOUNT | If 1, this flag is set (sAMAccountType attribute).
SAM_APP_BASIC_GROUP | If 1, this flag is set (sAMAccountType attribute).
SAM_APP_QUERY_GROUP | If 1, this flag is set (sAMAccountType attribute).
SAM_ACCOUNT_TYPE_MAX | If 1, this flag is set (sAMAccountType attribute).
GT_GROUP_CREATED_BY_SYSTEM | If 1, this is a group that is created by the system.
GT_GROUP_SCOPE_GLOBAL  | If 1, this is a group with global scope.
GT_GROUP_SCOPE_LOCAL  | If 1, this is a group with domain local scope.
GT_GROUP_SCOPE_UNIVERSAL  | If 1, this is a group with universal scope.
GT_GROUP_SAM_APP_BASIC  | If 1, this specifies an APP_BASIC group for Windows Server Authorisation Manager.
GT_GROUP_SAM_APP_QUERY  | If 1, this specifies an APP_QUERY group for Windows Server Authorisation Manager.
GT_GROUP_SECURITY  | If 1, this specifies a security group.
GT_GROUP_DISTRIBUTION | If 1, this specifies a distribution group (this is the inverse of the security group GT_GROUP_SECURITY). I have included it so that distribution groups can be identified more easily.

## Examples

Show active members of the Domain Admins group:
```
sqlite> select member_cn from view_activegroupusers where group_cn = "Domain Admins";
```

Show the effective groups that 'Stufus' is a member of:
```
sqlite> select group_cn from view_activegroupusers where member_cn = "Stufus";
```

Write a list of computer hostnames and operating system information (sorted by OS) to a CSV file:
```
sqlite> .mode csv
sqlite> .once hosts.csv
sqlite> select cn,dNSHostName,operatingSystem,operatingSystemVersion,operatingSystemServicePack from view_computers order by operatingSystem,operatingSystemVersion,operatingSystemServicePack;
```

Display a list of users who have 'pass' somewhere in their description or info fields:
```
sqlite> select cn,description,info FROM view_users WHERE (description LIKE '%pass%' OR info LIKE '%pass%');
```

Display a list of users who have something in their description or info fields:
```
sqlite> select cn,description,info FROM view_users WHERE (description IS NOT NULL or info IS NOT NULL);
```

Display a list of computers which have something in their description or info fields:
```
sqlite> select cn,description,info FROM view_computers WHERE (description IS NOT NULL or info IS NOT NULL);
```

Display the number of computers running each of the operating systems used in the target's estate:
```
sqlite> select count(dn),operatingSystem FROM view_computers where ADS_UF_ACCOUNTDISABLE=0 and ADS_UF_LOCKOUT=0 GROUP BY operatingSystem;
```

Display all of the Windows XP or Windows 2000 hosts, along with their description:
```
sqlite> select dnsHostName,description,info,operatingSystem from view_computers where operatingSystem LIKE '%Windows%2000%' OR operatingSystem LIKE '%Windows%XP%';
```

# Further Reading

https://labs.mwrinfosecurity.com/blog/offline-querying-of-active-directory/
