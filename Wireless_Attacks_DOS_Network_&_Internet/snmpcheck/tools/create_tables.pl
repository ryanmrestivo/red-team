#!/usr/bin/perl

BEGIN{ unshift @INC, '$ENV{SITE_ROOT}/cgi-bin' ,'C:\GIT\snmpcheck\html\cgi-bin', '/opt/snmpcheck/html/cgi-bin'; } 
use COMMON_ENV;


$dbh=db_connect();

#$stmt ="drop table session";
$stmt =" CREATE TABLE IF NOT EXISTS `session` (id integer,   login TEXT,   secret TEXT,   dt TEXT ) ; ";
do_sql( $stmt );

exit;

$stmt =" CREATE TABLE IF NOT EXISTS `Users` (  id INTEGER PRIMARY KEY AUTOINCREMENT ,     login TEXT,    name TEXT,   password TEXT ) ; ";
#do_sql( $stmt );
$pass=sha1_hex( 'root123' );
$stmt =" insert into  users (    login ,    name ,   password  ) values ( 'root' , 'Super user' ,  '$pass' ) ; ";

#do_sql( $stmt );
$pass=sha1_hex( 'support123' );
$stmt =" insert into  users (    login ,    name ,   password  ) values ( 'support' , 'Support user' ,  '$pass' ) ; ";
#do_sql( $stmt );

$stmt =" drop table  snmpworker ; ";
do_sql( $stmt );


$stmt =" CREATE TABLE IF NOT EXISTS snmpworker (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	sname  		TEXT,
	desc  		TEXT,
	ip		text,
	auth		BOOLEAN,
	snmpuser	text,
	snmpap		text,	
	snmppk		text,
	snmpr		INTEGER,	
	snmpt		INTEGER,
	snmpapro	text,	
	snmppro		text,	
	snmplevel	text,
	worker		text	
);  ";


do_sql( $stmt );

$stmt =" insert into  snmpworker (    
	sname  	,
	desc  	,
	ip	,
	auth	,
	snmpuser,
	snmpap	,
	snmppk	,
	snmpr	,
	snmpt	,
	snmpapro,
	snmppro	,
	snmplevel,
	worker
) 
values (  
	'ntpcheck'  	,
	'Ntpcheck'  	,
	'0.0.0.0'	,
	1	,
	'Admin',
	'password01'	,
	'password02'	,
	5	,
	1	,
	'MD5',
	'DES'	,
	'Authpriv',
	'ntpcheck.pl'
) ; ";


do_sql( $stmt );
exit;


sub do_sql {
	$sth = $dbh->prepare( $stmt );
	$rv = $sth->execute(  ) or die ( "Cannot connect to database : $DBI::errstr" );
	if($rv < 0){
		die ( "Cannot connect to database : $DBI::errstr" );
	}
}
