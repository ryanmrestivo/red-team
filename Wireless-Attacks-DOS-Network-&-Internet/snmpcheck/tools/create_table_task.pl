#!/usr/bin/perl

BEGIN{ unshift @INC, '$ENV{SITE_ROOT}/cgi-bin' ,'C:\GIT\snmpcheck\html\cgi-bin', '/opt/snmpcheck/html/cgi-bin'; } 
use COMMON_ENV;



$dbh=db_connect();



#$stmt = "CREATE TABLE IF NOT EXISTS sequ (id int);" ;
#do_sql( $stmt );
#$stmt = "insert into sequ( id ) values ( 0 );" ;
#do_sql( $stmt );

#$stmt = "drop table IF EXISTS tasks ;" ;
#do_sql( $stmt );

$stmt =" CREATE TABLE IF NOT EXISTS tasks (
	id 		INTEGER,
	sname  		TEXT,
	desc  		TEXT,
	user  		TEXT,
	pdt		text,	
	sdt		text,	
	dt		text,	
	param		text,
	status		INTEGER,
	outfile		text,
	progress	INTEGER,
	mess		text
);  ";


#do_sql( $stmt );
#exit;

$stmt = "drop table IF EXISTS snmpworker ;" ;
do_sql( $stmt );

$stmt =" CREATE TABLE IF NOT EXISTS snmpworker (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	sname  		TEXT,
	desc  		TEXT,
	worker		text,	
	cgiscript	text	
);  ";

do_sql( $stmt );
exit;



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
	snmplevel
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
	'Authpriv'
) ; ";


do_sql( $stmt );
exit;


sub do_sql {
	print $stmt;
	 $sth = $dbh->prepare( $stmt );
	 $rv = $sth->execute(  ) or die ( "Cannot connect to database : $DBI::errstr" );
	if($rv < 0){
		die ( "Cannot connect to database : $DBI::errstr" );
	}
}


sub GetNextSequence {
	my $dbh=shift;
	my $table='sequ';
	my $stmt ="update $table set id=id+1; ";
	my $sth = $dbh->prepare( $stmt );
	my $rv;
	unless ( $rv = $sth->execute( ) || $rv < 0 ) {
		message2 ( "Someting wrong with database  : $DBI::errstr" );
		w2log ( "Sql( $stmt ) Someting wrong with database  : $DBI::errstr" );
		return 0;
	}
	$stmt ="select id from $table";
	$sth = $dbh->prepare( $stmt );
	unless ( $rv = $sth->execute(  ) || $rv < 0 ) {
		message2 ( "Someting wrong with database  : $DBI::errstr" );
		w2log ( "Sql( $stmt ) Someting wrong with database  : $DBI::errstr" );
		return 0;
	}
	my $row=$sth->fetchrow_hashref;
	return ( $row->{id} );	
}

