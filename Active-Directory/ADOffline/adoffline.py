#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# ADOffline - AD LDAP Schema to SQLite Database
# Stuart Morgan (@ukstufus) <stuart.morgan@mwrinfosecurity.com>
#
import pprint
import base64
import time
import struct
import tempfile
import sqlite3
import re
import sys
import os

# This function looks for "x: y" in an LDIF
# file and effectively splits them up using a regex
def match_param(line,param):
    var = None

    # These ones have two ::'s, presuambly to signify that
    # they are base64 encoded
    if param in ['objectSid','sIDHistory','objectGUID']:
        var = re.match('^'+param+'::\s+(.+?)\s*$', line.strip())
    else:
        # Everything else should be key: value, not key:: value
        var = re.match('^'+param+':\s+(.+?)\s*$', line.strip())

    if var != None:
        return var.group(1).strip()

    return None

# This updates the dict (if it doesn't already exist)
# with a name/value pair (and adds it to a list)
def update_struct(struct,name,val):
    if val==None:
        return False

    if not name in struct:
        struct[name] = []
    struct[name].append(val)
    return True

# This function processes the completed struct. For example,
# we have just seen a new 'dn' and therefore must have finished 
# the last block
def process_struct(struct,sql):

    # If there isn't a DN in there, we aren't interested
    if not 'dn' in struct or not 'objectClass' in struct: 
        return

    if 'user' in struct['objectClass'] or 'group' in struct['objectClass']:
        insert_into_db(struct,sql)

    return

def banner():
    sys.stdout.write("\n")
    sys.stdout.write("       .mMMMMMm.             MMm    M   WW   W   WW   RRRRR\n")
    sys.stdout.write("      mMMMMMMMMMMM.           MM   MM    W   W   W    R   R\n")
    sys.stdout.write("     /MMMM-    -MM.           MM   MM    W   W   W    R   R\n")
    sys.stdout.write("    /MMM.    _  \/  ^         M M M M     W W W W     RRRR\n")
    sys.stdout.write("    |M.    aRRr    /W|        M M M M     W W W W     R  R\n")
    sys.stdout.write("    \/  .. ^^^   wWWW|        M  M  M      W   W      R   R\n")
    sys.stdout.write("       /WW\.  .wWWWW/         M  M  M      W   W      R    R\n")
    sys.stdout.write("       |WWWWWWWWWWW/\n")
    sys.stdout.write("         .WWWWWW.          ADOffline - Convert AD LDAP to SQL\n")
    sys.stdout.write("                        stuart.morgan@mwrinfosecurity.com | @ukstufus\n")
    sys.stdout.write("\n")
    sys.stdout.flush()

# Build the SQL database schema
def build_db_schema(sql):
    
    c = sql.cursor()

    # Create the tables
    c.execute('''CREATE TABLE raw_users
                 ('objectClass','dn','title', 'comment', 'cn','sn','description','instanceType','displayName','name','dNSHostName','userAccountControl','badPwdCount','primaryGroupID','adminCount','objectSid','sid','rid','sAMAccountName','sAMAccountType',
                 'objectCategory','operatingSystem','operatingSystemServicePack','operatingSystemVersion','managedBy','givenName','info','department','company','homeDirectory','userPrincipalName',
                 'manager','mail','groupType')''') 
    c.execute("CREATE TABLE raw_memberof ('dn_group' TEXT NOT NULL,'dn_member' TEXT NOT NULL, PRIMARY KEY('dn_group','dn_member'))")

    sql.commit()
    return
 
# Add indexes to the schema
def fix_db_indices(sql):
    
    c = sql.cursor()

    # Create the indicies
    c.execute("CREATE UNIQUE INDEX raw_users_dn on raw_users (dn)")
    c.execute("CREATE INDEX raw_users_cn on raw_users (cn)")
    c.execute("CREATE INDEX raw_users_dnshostname on raw_users (objectClass,dNSHostName)")
    c.execute("CREATE INDEX raw_users_samaccountname on raw_users (objectClass,sAMAccountName)")
    c.execute("CREATE UNIQUE INDEX raw_memberof_user_group on raw_memberof('dn_member','dn_group')")

    sql.commit()
    return

# Create the database views (bitwise expansion etc)
def create_views(sql):
    
    c = sql.cursor()

    # Generate the main view with calculated fields
    c.execute('''CREATE VIEW view_raw_users AS select objectClass, dn, title, comment, cn, sn, description, instanceType, displayName, name, dNSHostName, userAccountControl, badPwdCount, primaryGroupID, adminCount, objectSid, sid, rid, sAMAccountName, sAMAccountType, objectCategory, managedBy, givenName, info, department, company, homeDirectory, userPrincipalName, manager, mail, operatingSystem, operatingSystemVersion, operatingSystemServicePack, groupType,
     (CASE (userAccountControl&0x00000001) WHEN (0x00000001) THEN 1 ELSE 0 END) AS ADS_UF_SCRIPT,
     (CASE (userAccountControl&0x00000002) WHEN (0x00000002) THEN 1 ELSE 0 END) AS ADS_UF_ACCOUNTDISABLE,
	 (CASE (userAccountControl&0x00000008) WHEN (0x00000008) THEN 1 ELSE 0 END) AS ADS_UF_HOMEDIR_REQUIRED,
	 (CASE (userAccountControl&0x00000010) WHEN (0x00000010) THEN 1 ELSE 0 END) AS ADS_UF_LOCKOUT,
	 (CASE (userAccountControl&0x00000020) WHEN (0x00000020) THEN 1 ELSE 0 END) AS ADS_UF_PASSWD_NOTREQD,
	 (CASE (userAccountControl&0x00000040) WHEN (0x00000040) THEN 1 ELSE 0 END) AS ADS_UF_PASSWD_CANT_CHANGE,
	 (CASE (userAccountControl&0x00000080) WHEN (0x00000080) THEN 1 ELSE 0 END) AS ADS_UF_ENCRYPTED_TEXT_PASSWORD_ALLOWED,
	 (CASE (userAccountControl&0x00000100) WHEN (0x00000100) THEN 1 ELSE 0 END) AS ADS_UF_TEMP_DUPLICATE_ACCOUNT,
	 (CASE (userAccountControl&0x00000200) WHEN (0x00000200) THEN 1 ELSE 0 END) AS ADS_UF_NORMAL_ACCOUNT,
	 (CASE (userAccountControl&0x00000800) WHEN (0x00000800) THEN 1 ELSE 0 END) AS ADS_UF_INTERDOMAIN_TRUST_ACCOUNT,
	 (CASE (userAccountControl&0x00001000) WHEN (0x00001000) THEN 1 ELSE 0 END) AS ADS_UF_WORKSTATION_TRUST_ACCOUNT,
	 (CASE (userAccountControl&0x00002000) WHEN (0x00002000) THEN 1 ELSE 0 END) AS ADS_UF_SERVER_TRUST_ACCOUNT,
	 (CASE (userAccountControl&0x00010000) WHEN (0x00010000) THEN 1 ELSE 0 END) AS ADS_UF_DONT_EXPIRE_PASSWD,
	 (CASE (userAccountControl&0x00020000) WHEN (0x00020000) THEN 1 ELSE 0 END) AS ADS_UF_MNS_LOGON_ACCOUNT,
	 (CASE (userAccountControl&0x00040000) WHEN (0x00040000) THEN 1 ELSE 0 END) AS ADS_UF_SMARTCARD_REQUIRED,
	 (CASE (userAccountControl&0x00080000) WHEN (0x00080000) THEN 1 ELSE 0 END) AS ADS_UF_TRUSTED_FOR_DELEGATION,
	 (CASE (userAccountControl&0x00100000) WHEN (0x00100000) THEN 1 ELSE 0 END) AS ADS_UF_NOT_DELEGATED,
	 (CASE (userAccountControl&0x00200000) WHEN (0x00200000) THEN 1 ELSE 0 END) AS ADS_UF_USE_DES_KEY_ONLY,
	 (CASE (userAccountControl&0x00400000) WHEN (0x00400000) THEN 1 ELSE 0 END) AS ADS_UF_DONT_REQUIRE_PREAUTH,
	 (CASE (userAccountControl&0x00800000) WHEN (0x00800000) THEN 1 ELSE 0 END) AS ADS_UF_PASSWORD_EXPIRED,
	 (CASE (userAccountControl&0x01000000) WHEN (0x01000000) THEN 1 ELSE 0 END) AS ADS_UF_TRUSTED_TO_AUTHENTICATE_FOR_DELEGATION,
	 CASE WHEN (sAMAccountType==0) THEN 1 ELSE 0 END AS SAM_DOMAIN_OBJECT,
	 CASE WHEN (sAMAccountType==0x10000000) THEN 1 ELSE 0 END AS SAM_GROUP_OBJECT,
	 CASE WHEN (sAMAccountType==0x10000001) THEN 1 ELSE 0 END AS SAM_NON_SECURITY_GROUP_OBJECT,
	 CASE WHEN (sAMAccountType==0x20000000) THEN 1 ELSE 0 END AS SAM_ALIAS_OBJECT,
	 CASE WHEN (sAMAccountType==0x20000001) THEN 1 ELSE 0 END AS SAM_NON_SECURITY_ALIAS_OBJECT,
	 CASE WHEN (sAMAccountType==0x30000000) THEN 1 ELSE 0 END AS SAM_NORMAL_USER_ACCOUNT,
	 CASE WHEN (sAMAccountType==0x30000001) THEN 1 ELSE 0 END AS SAM_MACHINE_ACCOUNT,
	 CASE WHEN (sAMAccountType==0x30000002) THEN 1 ELSE 0 END AS SAM_TRUST_ACCOUNT,
	 CASE WHEN (sAMAccountType==0x40000000) THEN 1 ELSE 0 END AS SAM_APP_BASIC_GROUP,
	 CASE WHEN (sAMAccountType==0x40000001) THEN 1 ELSE 0 END AS SAM_APP_QUERY_GROUP,
	 CASE WHEN (sAMAccountType==0x7fffffff) THEN 1 ELSE 0 END AS SAM_ACCOUNT_TYPE_MAX FROM raw_users''')

    # Add additional fields to the group one
    c.execute('''CREATE VIEW view_groups AS select view_raw_users.*,
     (CASE (groupType&0x00000001) WHEN (0x00000001) THEN 1 ELSE 0 END) AS GROUP_CREATED_BY_SYSTEM,
     (CASE (groupType&0x00000002) WHEN (0x00000002) THEN 1 ELSE 0 END) AS GROUP_SCOPE_GLOBAL,
     (CASE (groupType&0x00000004) WHEN (0x00000004) THEN 1 ELSE 0 END) AS GROUP_SCOPE_LOCAL,
     (CASE (groupType&0x00000008) WHEN (0x00000008) THEN 1 ELSE 0 END) AS GROUP_SCOPE_UNIVERSAL,
     (CASE (groupType&0x00000010) WHEN (0x00000010) THEN 1 ELSE 0 END) AS GROUP_SAM_APP_BASIC,
     (CASE (groupType&0x00000020) WHEN (0x00000020) THEN 1 ELSE 0 END) AS GROUP_SAM_APP_QUERY,
     (CASE (groupType&0x80000000) WHEN (0x80000000) THEN 1 ELSE 0 END) AS GROUP_SECURITY,
     (CASE (groupType&0x80000000) WHEN (0x80000000) THEN 0 ELSE 1 END) AS GROUP_DISTRIBUTION FROM view_raw_users WHERE objectClass = 'group' ''')

    # Create the user and computer views. In effect it is the same table though.
    c.execute("CREATE VIEW view_users AS select view_raw_users.* FROM view_raw_users WHERE objectClass = 'user'")
    c.execute("CREATE VIEW view_computers AS select view_raw_users.* FROM view_raw_users WHERE objectClass = 'computer'")

    # Create the merged table
    c.execute('''CREATE VIEW view_groupmembers AS select g.objectClass as group_objectClass, g.dn as group_dn, g.comment as group_comment, g.title as group_title, g.cn as group_cn, g.sn as group_sn, g.description as group_description, g.instanceType as group_instanceType, g.displayName as group_displayName, g.name as group_name, g.dNSHostName as group_dNSHostName, g.userAccountControl as group_userAccountControl, g.badPwdCount as group_badPwdCount, g.primaryGroupID as group_primaryGroupID, g.adminCount as group_adminCount, g.objectSid as group_objectSid, g.sid as group_sid, g.rid as group_rid, g.sAMAccountName as group_sAMAccountName, g.sAMAccountType as group_sAMAccountType, g.objectCategory as group_objectCategory, g.managedBy as group_managedBy, g.givenName as group_givenName, g.info as group_info, g.department as group_department, g.company as group_company, g.homeDirectory as group_homeDirectory, g.userPrincipalName as group_userPrincipalName, g.manager as group_manager, g.mail as group_mail, g.groupType as group_groupType, g.ADS_UF_SCRIPT as group_ADS_UF_SCRIPT,
	g.ADS_UF_ACCOUNTDISABLE AS group_ADS_UF_ACCOUNTDISABLE,
	g.ADS_UF_HOMEDIR_REQUIRED AS group_ADS_UF_HOMEDIR_REQUIRED,
	g.ADS_UF_LOCKOUT AS group_ADS_UF_LOCKOUT,
	g.ADS_UF_PASSWD_NOTREQD AS group_ADS_UF_PASSWD_NOTREQD,
	g.ADS_UF_PASSWD_CANT_CHANGE AS group_ADS_UF_PASSWD_CANT_CHANGE,
	g.ADS_UF_ENCRYPTED_TEXT_PASSWORD_ALLOWED AS group_ADS_UF_ENCRYPTED_TEXT_PASSWORD_ALLOWED,
	g.ADS_UF_TEMP_DUPLICATE_ACCOUNT AS group_ADS_UF_TEMP_DUPLICATE_ACCOUNT,
	g.ADS_UF_NORMAL_ACCOUNT AS group_ADS_UF_NORMAL_ACCOUNT,
	g.ADS_UF_INTERDOMAIN_TRUST_ACCOUNT AS group_ADS_UF_INTERDOMAIN_TRUST_ACCOUNT,
	g.ADS_UF_WORKSTATION_TRUST_ACCOUNT AS group_ADS_UF_WORKSTATION_TRUST_ACCOUNT,
	g.ADS_UF_SERVER_TRUST_ACCOUNT AS group_ADS_UF_SERVER_TRUST_ACCOUNT,
	g.ADS_UF_DONT_EXPIRE_PASSWD AS group_ADS_UF_DONT_EXPIRE_PASSWD,
	g.ADS_UF_MNS_LOGON_ACCOUNT AS group_ADS_UF_MNS_LOGON_ACCOUNT,
	g.ADS_UF_SMARTCARD_REQUIRED AS group_ADS_UF_SMARTCARD_REQUIRED,
	g.ADS_UF_TRUSTED_FOR_DELEGATION AS group_ADS_UF_TRUSTED_FOR_DELEGATION,
	g.ADS_UF_NOT_DELEGATED AS group_ADS_UF_NOT_DELEGATED,
	g.ADS_UF_USE_DES_KEY_ONLY AS group_ADS_UF_USE_DES_KEY_ONLY,
	g.ADS_UF_DONT_REQUIRE_PREAUTH AS group_ADS_UF_DONT_REQUIRE_PREAUTH,
	g.ADS_UF_PASSWORD_EXPIRED AS group_ADS_UF_PASSWORD_EXPIRED,
	g.ADS_UF_TRUSTED_TO_AUTHENTICATE_FOR_DELEGATION AS group_ADS_UF_TRUSTED_TO_AUTHENTICATE_FOR_DELEGATION,
    (CASE (g.groupType&0x00000001) WHEN (0x00000001) THEN 1 ELSE 0 END) AS group_GROUP_CREATED_BY_SYSTEM,
    (CASE (g.groupType&0x00000002) WHEN (0x00000002) THEN 1 ELSE 0 END) AS group_GROUP_SCOPE_GLOBAL,
    (CASE (g.groupType&0x00000004) WHEN (0x00000004) THEN 1 ELSE 0 END) AS group_GROUP_SCOPE_LOCAL,
    (CASE (g.groupType&0x00000008) WHEN (0x00000008) THEN 1 ELSE 0 END) AS group_GROUP_SCOPE_UNIVERSAL,
    (CASE (g.groupType&0x00000010) WHEN (0x00000010) THEN 1 ELSE 0 END) AS group_GROUP_SAM_APP_BASIC,
    (CASE (g.groupType&0x00000020) WHEN (0x00000020) THEN 1 ELSE 0 END) AS group_GROUP_SAM_APP_QUERY,
    (CASE (g.groupType&0x80000000) WHEN (0x80000000) THEN 1 ELSE 0 END) AS group_GROUP_SECURITY,
    (CASE (g.groupType&0x80000000) WHEN (0x80000000) THEN 0 ELSE 1 END) AS group_GROUP_DISTRIBUTION,
    m.objectClass as member_objectClass, m.dn as member_dn, m.title as member_title, m.cn as member_cn, m.sn as member_sn, m.comment as member_comment, m.description as member_description, m.instanceType as member_instanceType, m.displayName as member_displayName, m.name as member_name, m.dNSHostName as member_dNSHostName, m.userAccountControl as member_userAccountControl, m.badPwdCount as member_badPwdCount, m.primaryGroupID as member_primaryGroupID, m.adminCount as member_adminCount, m.objectSid as member_objectSid, m.sid as member_sid, m.rid as member_rid, m.sAMAccountName as member_sAMAccountName, m.sAMAccountType as member_sAMAccountType, m.objectCategory as member_objectCategory, m.managedBy as member_managedBy, m.givenName as member_givenName, m.info as member_info, m.department as member_department, m.company as member_company, m.homeDirectory as member_homeDirectory, m.userPrincipalName as member_userPrincipalName, m.manager as member_manager, m.mail as member_mail, m.operatingSystem as member_operatingSystem, m.operatingSystemVersion as member_operatingSystemVersion, m.operatingSystemServicePack as member_operatingSystemServicePack, m.groupType as member_groupType, m.ADS_UF_SCRIPT as member_ADS_UF_SCRIPT,
	m.ADS_UF_ACCOUNTDISABLE AS member_ADS_UF_ACCOUNTDISABLE,
	m.ADS_UF_HOMEDIR_REQUIRED AS member_ADS_UF_HOMEDIR_REQUIRED,
	m.ADS_UF_LOCKOUT AS member_ADS_UF_LOCKOUT,
	m.ADS_UF_PASSWD_NOTREQD AS member_ADS_UF_PASSWD_NOTREQD,
	m.ADS_UF_PASSWD_CANT_CHANGE AS member_ADS_UF_PASSWD_CANT_CHANGE,
	m.ADS_UF_ENCRYPTED_TEXT_PASSWORD_ALLOWED AS member_ADS_UF_ENCRYPTED_TEXT_PASSWORD_ALLOWED,
	m.ADS_UF_TEMP_DUPLICATE_ACCOUNT AS member_ADS_UF_TEMP_DUPLICATE_ACCOUNT,
	m.ADS_UF_NORMAL_ACCOUNT AS member_ADS_UF_NORMAL_ACCOUNT,
	m.ADS_UF_INTERDOMAIN_TRUST_ACCOUNT AS member_ADS_UF_INTERDOMAIN_TRUST_ACCOUNT,
	m.ADS_UF_WORKSTATION_TRUST_ACCOUNT AS member_ADS_UF_WORKSTATION_TRUST_ACCOUNT,
	m.ADS_UF_SERVER_TRUST_ACCOUNT AS member_ADS_UF_SERVER_TRUST_ACCOUNT,
	m.ADS_UF_DONT_EXPIRE_PASSWD AS member_ADS_UF_DONT_EXPIRE_PASSWD,
	m.ADS_UF_MNS_LOGON_ACCOUNT AS member_ADS_UF_MNS_LOGON_ACCOUNT,
	m.ADS_UF_SMARTCARD_REQUIRED AS member_ADS_UF_SMARTCARD_REQUIRED,
	m.ADS_UF_TRUSTED_FOR_DELEGATION AS member_ADS_UF_TRUSTED_FOR_DELEGATION,
	m.ADS_UF_NOT_DELEGATED AS member_ADS_UF_NOT_DELEGATED,
	m.ADS_UF_USE_DES_KEY_ONLY AS member_ADS_UF_USE_DES_KEY_ONLY,
	m.ADS_UF_DONT_REQUIRE_PREAUTH AS member_ADS_UF_DONT_REQUIRE_PREAUTH,
	m.ADS_UF_PASSWORD_EXPIRED AS member_ADS_UF_PASSWORD_EXPIRED,
	m.ADS_UF_TRUSTED_TO_AUTHENTICATE_FOR_DELEGATION AS member_ADS_UF_TRUSTED_TO_AUTHENTICATE_FOR_DELEGATION,
    (CASE (m.groupType&0x00000001) WHEN (0x00000001) THEN 1 ELSE 0 END) AS member_GROUP_CREATED_BY_SYSTEM,
    (CASE (m.groupType&0x00000002) WHEN (0x00000002) THEN 1 ELSE 0 END) AS member_GROUP_SCOPE_GLOBAL,
    (CASE (m.groupType&0x00000004) WHEN (0x00000004) THEN 1 ELSE 0 END) AS member_GROUP_SCOPE_LOCAL,
    (CASE (m.groupType&0x00000008) WHEN (0x00000008) THEN 1 ELSE 0 END) AS member_GROUP_SCOPE_UNIVERSAL,
    (CASE (m.groupType&0x00000010) WHEN (0x00000010) THEN 1 ELSE 0 END) AS member_GROUP_SAM_APP_BASIC,
    (CASE (m.groupType&0x00000020) WHEN (0x00000020) THEN 1 ELSE 0 END) AS member_GROUP_SAM_APP_QUERY,
    (CASE (m.groupType&0x80000000) WHEN (0x80000000) THEN 1 ELSE 0 END) AS member_GROUP_SECURITY,
    (CASE (m.groupType&0x80000000) WHEN (0x80000000) THEN 0 ELSE 1 END) AS member_GROUP_DISTRIBUTION 
    FROM raw_memberof r 
    INNER JOIN view_raw_users g ON r.dn_group = g.dn
    INNER JOIN view_raw_users m ON r.dn_member = m.dn 
    WHERE g.dn != m.dn ''')

    c.execute("CREATE VIEW view_activegroupusers AS select * from view_groupmembers where member_objectClass = 'user' and member_ADS_UF_LOCKOUT = 0 and member_ADS_UF_ACCOUNTDISABLE = 0")

    c.execute("CREATE VIEW view_orgchartusers AS select u.dn as u_dn,u.cn as u_cn,u.title as u_title,m.dn as m_dn,m.cn as m_cn,m.title as m_title from view_users u LEFT JOIN view_users m ON u.manager = m.dn where u.dn IS NOT NULL and (m.dn IS NOT NULL OR u.dn IN (select manager from view_users where manager IS NOT NULL))");

    sql.commit()
    return

# Insert the new user/group/computer into the database
def insert_into_db(struct,sql):
    c = sql.cursor()
    ldap_single_params = ['title','cn','sn','description','instanceType','displayName','name','dNSHostName','userAccountControl','badPwdCount','primaryGroupID','adminCount','objectSid','sAMAccountName','sAMAccountType','objectCategory','operatingSystem','operatingSystemServicePack','operatingSystemVersion','managedBy','givenName','info','department','company','homeDirectory','userPrincipalName','manager','mail','groupType', 'comment']
    ldap_values = []
    for ind in ldap_single_params:
        ldap_values.append(safe_struct_get(struct,ind))

    # Raw_users contains everything
    sql_statement = "insert into raw_users ('rid','sid','objectClass','dn','title','cn','sn','description','instanceType','displayName','name','dNSHostName','userAccountControl','badPwdCount','primaryGroupID','adminCount','objectSid','sAMAccountName','sAMAccountType','objectCategory','operatingSystem','operatingSystemServicePack','operatingSystemVersion','managedBy','givenName','info','department','company','homeDirectory','userPrincipalName','manager','mail','groupType', 'comment') VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
    ldap_values.insert(0,struct['dn'])

    # Make sure that this is a user, group or computer
    oc = None
    if 'computer' in struct['objectClass']:
        oc = 'computer'
    elif 'group' in struct['objectClass']:
        oc = 'group'
    elif 'user' in struct['objectClass']:
        oc = 'user'
    else:
        return
    ldap_values.insert(0,oc)

    # Now calculate the sid and rid
    sid, rid = get_string_sid_from_binary_sid(safe_struct_get(struct,'objectSid'))
    if sid and rid:
        ldap_values.insert(0,sid)
        ldap_values.insert(0,rid)
    else:
        ldap_values.insert(0,'')
        ldap_values.insert(0,'')
        
    c.execute(sql_statement, ldap_values)

    sql_memberof = 'replace into raw_memberof (dn_group,dn_member) VALUES (?,?)'
    if 'memberOf' in struct:
        for m in struct['memberOf']:
            if m != struct['dn']:
                c.execute(sql_memberof, [m,struct['dn']])

    if 'member' in struct and oc == 'group':
        for m in struct['member']:
            if m != struct['dn']:
                c.execute(sql_memberof, [struct['dn'],m])

    sql.commit()
    return

# https://blogs.msdn.microsoft.com/oldnewthing/20040315-00/?p=40253/
# http://stackoverflow.com/questions/33188413/python-code-to-convert-from-objectsid-to-sid-representation
def get_string_sid_from_binary_sid(base64string):
    binarysid = base64.b64decode(base64string)
    version = struct.unpack('B', binarysid[0])[0]
    assert version == 1, version
    length = struct.unpack('B', binarysid[1])[0]
    authority = struct.unpack('>Q', '\x00\x00' + binarysid[2:8])[0]
    string = 'S-%d-%d' % (version, authority)
    binarysid = binarysid[8:]
    assert len(binarysid) == 4 * length
    for i in xrange(length):
        value = struct.unpack('<L', binarysid[4*i:4*(i+1)])[0]
        string += '-%d' % (value)
    return (string,value)

# Get the specific value from the dict name/value pair
def safe_struct_get(struct,name):
    if not struct:
        return None
    
    if not name in struct:
        return None

    if not struct[name][0]:
        return None

    if name in ['instanceType','userAccountControl','badPwdCount','primaryGroupID','adminCount','sAMAccountType','groupType']:
        val = int(struct[name][0])
        if not val:
            return int(0)
        else:
            return val

    return struct[name][0]

# Sort out the nested groups
def calculate_chain_of_ancestry(sql,table):

    c = sql.cursor()

    # Get the initial list of users
    c.execute("select dn from "+table)
    all_dn = c.fetchall()
    all_dn_number = len(all_dn)
    all_dn_counter = 0
    for user_dn in all_dn:
        all_dn_counter += 1
        percentage_count = "{0:.0f}%".format(float(all_dn_counter)/all_dn_number * 100)
        sys.stdout.flush()
        get_member_groups(c,user_dn[0],table)
        sql.commit()
        sys.stdout.write("\r  Processed DN "+str(all_dn_counter)+"/"+str(all_dn_number)+" ("+percentage_count+")")
    return

def display_totals(sql):
    c = sql.cursor()
    c.execute("select count(*) from view_users")
    print "        Users: "+str(c.fetchone()[0])
    c.execute("select count(*) from view_groups")
    print "       Groups: "+str(c.fetchone()[0])
    c.execute("select count(*) from view_computers")
    print "    Computers: "+str(c.fetchone()[0])
    c.execute("select count(*) from view_groupmembers")
    print " Associations: "+str(c.fetchone()[0])
    return

def get_member_groups(cursor,user_dn,table):

    # Firstly, retrieve the list of groups that the provided DN belongs to
    initial_groups = update_member_groups_and_return_next_level(cursor,[user_dn],user_dn,False)
    if initial_groups == None:
        return

    processed_groups = dict()

    # Loop through each chunk of groups
    while True:
        # Take the current list of groups (initial_groups), use the database to find out
        # who the members are, update the database with membership and then return
        # the list of groups that the initial list are members of
        nested_groups = update_member_groups_and_return_next_level(cursor,initial_groups,user_dn,True)

        # If there are no more groups, break out of the loop.
        if nested_groups == None:
            break

        # nested_groups now contains a list of groups that initial_groups are a member of. 
        # We need to avoid the situation where we have circular dependencies (i.e. group A is a member
        # of group B, which is a member of Group C, which is a member of Group A).
        # Therefore, we will loop through the next level of groups and see if any of them 
        # are already in the database. If they are, it means that they have already been
        # included and don't need to be processed again.
        for i in initial_groups:
            processed_groups[i] = True

        initial_groups = []
        for i in nested_groups:
            # If the group hasn't already been covered, add it to the list
            if i not in processed_groups:
                initial_groups.append(i)
    
        # Break out if we are just going to cover groups that we have
        # already covered
        if len(initial_groups) == 0:
            break

    # For this specific user, also look at the primaryGroupId and add that group too
    sql_pgid = 'replace into raw_memberof (dn_group,dn_member) VALUES ((select dn from view_groups where rid = (select primaryGroupId from '+table+' where dn = ?)), ?)'
    cursor.execute(sql_pgid, [user_dn, user_dn])
    return

def update_member_groups_and_return_next_level(cursor,fetcheddn,original_user,updatedb):

    sql_member = 'replace into raw_memberof (dn_group,dn_member) VALUES (?,?)'
    new_children = []

    # Get the groups that the provided DN is in. Go through each of the DNs provided
    # in the array, retrieve the groups that they are members of and add it to a master list
    for dn in fetcheddn:
        cursor.execute("select group_dn from view_groupmembers where member_dn = ? and member_dn != group_dn", [dn])
        all_children = cursor.fetchall()

        # The new_children list now contains a list without each one being in its own array
        for child in all_children:
            new_children.append(child[0])

    # Now that we have a list of new groups, add the old list to the database
    if updatedb == True:
        for dn in fetcheddn:    
            cursor.execute(sql_member, [dn,original_user])

    # If there are no more descendents, return None
    # Otherwise return the next load of groups
    if not len(new_children):
        return None
    return new_children

# Write a log entry to stdout
def log(strval):
    sys.stdout.write('['+time.strftime("%d/%b/%y %H:%M:%S")+'] '+strval)
    sys.stdout.flush()
    return

# Write a log entry to stderr
def err(strval):
    sys.stderr.write('['+time.strftime("%d/%b/%y %H:%M:%S")+'] '+strval)
    sys.stderr.flush()
    return

# Start
banner()

if len(sys.argv)<2:
    err("Specify the source LDIF filename on the command line. Create it with a command such as:\n")
    err("ldapsearch -h <ip> -x -D <username> -w <password> -b <base DN> -E pr=1000/noprompt -o ldif-wrap=no > ldap.output\n")
    sys.exit(1)

source_filename = sys.argv[1]
if not os.path.isfile(source_filename):
    err("Unable to read "+source_filename+". Make sure this is a valid file.\n")
    sys.exit(2)

log("Creating database: ")
db_file = tempfile.NamedTemporaryFile(delete=False)
db_filename = db_file.name+'.'+time.strftime('%Y%m%d%H%M%S')+'.ad-ldap.db'
db_file.close()
sql = sqlite3.connect(db_filename)
build_db_schema(sql)
create_views(sql)
fix_db_indices(sql)
sys.stdout.write(db_filename+"\n")

f = open(source_filename,"r")
log("Reading LDIF..")
# Open the LDAP file and read its contents
lines = f.readlines()
sys.stdout.write(".done\n")
f.close()

# Create an initial object
current_dn = {}

# The list of ldap parameters to save
ldap_params = ['objectClass','title','cn','sn','description','instanceType','displayName','member','memberOf','name','dNSHostName','userAccountControl','badPwdCount','primaryGroupID','adminCount','objectSid','sAMAccountName','sAMAccountType','objectCategory','operatingSystem','operatingSystemServicePack','operatingSystemVersion','managedBy','givenName','info','department','company','homeDirectory','sIDHistory','userPrincipalName','manager','mail','groupType','comment']

log("Parsing LDIF...\n")
# Go through each line in the LDIF file
main_count = 0
num_lines = len(lines)
for line in lines:

    main_count += 1
    percentage_count = "{0:.0f}%".format(float(main_count)/num_lines * 100)
    sys.stdout.write("\r  Reading line "+str(main_count)+"/"+str(num_lines)+" ("+percentage_count+")")
    sys.stdout.flush()

    # If it starts with DN, its a new "block"
    val = match_param(line,'dn')
    if val != None: 
        process_struct(current_dn,sql)
        current_dn = {}
        current_dn['dn'] = val
        continue

    for p in ldap_params:
        update_struct(current_dn, p, match_param(line,p))


# We are at the last line, so process what
# is left as a new block
process_struct(current_dn,sql)
sys.stdout.write("\n")

log("Calculating user chain of ancestry (nested groups)...\n")
calculate_chain_of_ancestry(sql,'view_users')
sys.stdout.write("\n")
log("Completed\n")
log("Calculating computer chain of ancestry (nested groups)...\n")
calculate_chain_of_ancestry(sql,'view_computers')
sys.stdout.write("\n\n")
display_totals(sql)
sys.stdout.write("\n")
sql.close()
exit(0)
