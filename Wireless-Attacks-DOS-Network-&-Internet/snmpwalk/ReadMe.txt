==============================================================================
SnmpWalk v1.02 - Lists existing SNMP variables on any network device.
==============================================================================

Copyright (C) 2009-2010 SnmpSoft Company. All Rights Reserved.

Contents
--------
  1. Overview
  2. Features
  3. Usage & Parameters
  4. Examples
  5. License & Disclaimer
  6. Version History


1. Overview
------------
  SNMP is  a unified protocol  of network monitoring  and network  device
  management.  All active  network  devices  support SNMP.  Besides  that,
  SNMP is supported  by major operational  systems and a large  number of
  network applications.

  SnmpWalk allows you to detect a set of variables that are available for
  reading  on a certain device. You can obtain  a full list  or just part.
  By  analyzing  the  results  of a network  device  scan  obtained  with
  SnmpWalk  you  can develop a list  of supported MIBs  and,  in this way,
  obtain full descriptions of variables and possible values. Besides that,
  MIB  documents  contain  information  about  SNMP  variables  that  are
  available only for writing.  After analyzing information retrieved with
  SnmpWalk  from hardware  or software SNMP sources,  you can use SnmpSet
  and SnmpGet tools to change and obtain values.

  The value  of SnmpWalk  is  not limited  to only  the SNMP analysis  of
  supported features.  This tool can effectively  obtain SNMP tables  and
  read whole sections  of variables.  This particularly  refers to tables
  that are  often used for presenting statistical  and status information.

  SnmpWalk  is  a command-line  tool,  which  makes  possible  its use in
  scripts.  This tool  supports modern IPv6  in addition to  the standard
  IPv4.  Moreover,  SnmpWalk  allows  you  to  use  a simple  version  of
  SNMPv1/SNMPv2c and also supports a safe version of SNMPv3.
  

2. Features
------------
  + Support of SNMP v1/v2c and SNMPv3
  + Support of IPv4 and IPv6
  + Command line interface (CLI)
  + Full or partial SNMP variables tree
  + Allows for any type of SNMP variable
  + Various Auth. & Privacy protocols
  + Windows NT/2000/XP/2003/Vista/2008

  
3. Usage & Parameters
----------------------
  SnmpWalk.exe [-q] -r:host [-p:port] [-t:timeout] [-v:version] [-c:community]
        [-ei:engine_id] [-sn:sec_name] [-ap:auth_proto] [-aw:auth_passwd]
        [-pp:priv_proto] [-pw:priv_passwd] [-ce:cont_engine] [-cn:cont_name]
        [-os:start_oid] [-op:stop_oid] [-csv]

   -q               Quiet mode (suppress header; print variable values only).
   -r:host          Name or network address (IPv4/IPv6) of remote host.
   -p:port          SNMP port number on remote host. Default: 161
   -t:timeout       SNMP timeout in seconds (1-600). Default: 5
   -v:version       SNMP version. Supported version: 1, 2c or 3. Default: 1
   -c:community     SNMP community string for SNMP v1/v2c. Default: public
   -ei:engine_id    Engine ID. Format: hexadecimal string. (SNMPv3).
   -sn:sec_name     SNMP security name for SNMPv3.
   -ap:auth_proto   Authentication protocol. Supported: MD5, SHA (SNMPv3).
   -aw:auth_passwd  Authentication password (SNMPv3).
   -pp:priv_proto   Privacy protocol. Supported: DES, IDEA, AES128, AES192,
                    AES256, 3DES (SNMPv3).
   -pw:priv_passwd  Privacy password (SNMPv3).
   -cn:cont_name    Context name. (SNMPv3)
   -ce:cont_engine  Context engine. Format: hexadecimal string. (SNMPv3)
   -os:start_oid    Object ID (OID) of first SNMP variable to walk. Default:.1
   -op:stop_oid     Object ID (OID) of last SNMP variable to walk.
                    Default: walk to the very last variable.
   -csv             Output in CSV (Comma Separated Values) format.  

4. Examples
------------
  SnmpWalk.exe -r:MainRouter -csv
  SnmpWalk.exe -r:10.0.0.1 -t:10 -c:"admin_rw" -os:.1.3.6.1.2.1.1
  SnmpWalk.exe -r:"::1" -v:3 -sn:SomeName -ap:MD5 -aw:SomeAuthPass -pp:DES
               -pw:SomePrivPass -os:.1.3.6.1.2.1 -op:.1.3.6.1.2.65535 -q  

5. License & Disclaimer
------------------------
  FREE USE LICENSE. You  may install  and use  any number of copies
  of  this  SOFTWARE  on your  devices  free of  charge.  You  must
  distribute  a copy of  this license  within  ReadMe.txt file with
  any  copy of the SOFTWARE and  anyone to whom you  distribute the
  SOFTWARE is subject to this license.

  RESTRICTIONS.  You may not  reduce the SOFTWARE to human readable
  form,  reverse engineer,  de-compile,  disassemble, merge,  adapt,
  or modify the SOFTWARE, except  and only to  the extent that such
  activity is expressly permitted by applicable law notwithstanding
  this  limitation.  You may not rent, lease,  or lend the SOFTWARE.
  You may not use the SOFTWARE to perform any unauthorized transfer
  of  information,  such  as  copying  or  transferring  a  file in
  violation of a copyright, or for any illegal purpose.

  NO WARRANTIES.  To the maximum extent permitted by applicable law,
  SnmpSoft Company  expressly   disclaims  any  warranty  for  this
  SOFTWARE. The SOFTWARE and any related documentation are provided
  "as is" without warranty  of any kind,  either express or implied,
  including,   without  limitation,  the  implied   warranties   of
  merchantability  or fitness for a particular  purpose. The entire
  risk  arising out of use or performance  of the  SOFTWARE remains
  with you.


6. Version History
-------------------
  1.02  - FIXED: CSV format output 

  1.01  - FIXED: Redirecting the output to a file

  1.0  - Initial release
  

SnmpSoft Company
================
Simple Network Monitoring Programs
http://www.snmpsoft.com
FreeTools for Network Administrators
http://www.snmpsoft.com/freetools/
  
======================================EOF=====================================