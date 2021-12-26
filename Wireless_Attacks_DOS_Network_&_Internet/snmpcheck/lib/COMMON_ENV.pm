#!/usr/bin/perl
# korolev-ia [at] yandex.ru

use lib 'C:\GIT\snmpcheck\lib' ;
use lib "/opt/snmpcheck/lib" ;
use lib "../lib" ;
use lib "../../lib" ;

#use strict;
#use warnings;
use HTML::Template;
use DBI;
use CGI qw(param);
use Digest::SHA qw(sha1 sha1_hex );
use Data::Dumper;
use CGI::Cookie;
use CGI qw/:standard/;
use JSON;
use HTML::Entities;






$Url->{OUTFILE_DIR}='../reports';
$Url->{ACTION_TASK_ADD}="task_add.cgi" ;
$Url->{ACTION_TASK_ADD_CRONTAB}="task_add_crontab.cgi" ;
$Url->{ACTION_TASK_LIST}="task_list.cgi";
$Url->{ACTION_TASK_LIST_CRONTAB}="task_list_crontab.cgi" ;

$Paths->{HOME}='C:/GIT/snmpcheck/';
if( -d '/opt/snmpcheck' ) { 
	$Paths->{HOME}='/opt/snmpcheck/';
}	
if( -d '/home/nems/client_persist/htdocs/bulktool4' ) { 
	$Paths->{HOME}='/home/nems/client_persist/htdocs/bulktool4';
}

	
$Paths->{TEMPLATE}="$Paths->{HOME}/data/templates";
$Paths->{DB}="$Paths->{HOME}/data/db";
$Paths->{LOG}="$Paths->{HOME}/data/log/snmpcheck.log";
$Paths->{WORKER_LOG}="$Paths->{HOME}/data/log/worker";  # after all tests it can be set to /dev/null 
#$Paths->{WORKER_LOG}="/dev/null";
$Paths->{GROUPS}="$Paths->{HOME}/data/iplist/groups/";
$Paths->{WORKER_DIR}="$Paths->{HOME}/worker";
$Paths->{CGISCRIPT_DIR}="$Paths->{HOME}/html/cgi-bin";
$Paths->{JSON}="$Paths->{HOME}/data/json";
$Paths->{OUTFILE_DIR}="$Paths->{HOME}/html/reports";
$Paths->{PID_DIR}="$Paths->{HOME}/data/tmp";
$Paths->{TMP_DIR}="$Paths->{HOME}/data/tmp";

$Paths->{config.ini}="$Paths->{HOME}/data/cfg/config.ini";
$Paths->{global.ipasolink}="$Paths->{HOME}/data/iplist/global.ipasolink";



$Task->{1}='added';
$Task->{2}='started';
$Task->{3}='running';
$Task->{4}='finished';
$Task->{5}='failed';
$Task->{6}='canceled';
$Task->{7}='pending';








sub get_ip_list {
	my $ip_param=shift;
	my $Cfg=ReadConfig();
	my @IPs=();
	#print Dumper( $Cfg );
	#print Dumper( $ip_param );
	if( $ip_param->{ip} ) {	
		return ( $ip_param->{ip} ) ;
	}
	if( $Cfg->{iplistdb} eq 'ms5000' ) {
		# The next variables used for remote access to pgsql, but need the password
		#$Cfg->{ms5000flag}='-h';
		#$Cfg->{ms5000ip}='172.29.97.158';
		my $ms5000flag='';
		my $ms5000ip='';

		my $code='';
		my $result_of_exec='';
		my $statusfilter='';
		my @Flags;
		if( $ip_param->{inop} || $ip_param->{ucon} || $ip_param->{umng} ) {
		    push( @Flags, "'inop'" ) if( $ip_param->{inop} );
		    push( @Flags, "'ucon'" ) if( $ip_param->{ucon} );
    		push( @Flags, "'umng'" ) if( $ip_param->{umng} );
    		$statusfilter="and servicetype in ( " . join(',', @Flags ). " )" ;
		}

		if( $ip_param->{group} ) {
			my $mask=$ip_param->{group};
			if( $ip_param->{subgroup} ) {
				$mask=~s/0/_/g;
			} 
			$code="psql $ms5000flag $ms5000ip -U nems -p 55001 CMDB -A -t -q -c \"select a.neprimaryaddress from managed_element as a, summary_symbol as b where b.summary_symbol_location_id like '$mask' and b.summary_symbol_location_id=a.locationid and a.netype like 'iPASOLINK%' and b.summary_symbol_id <> -1 	$statusfilter;\"";			
			$result_of_exec=qx( $code );
			@IPs=split( /\s/, $result_of_exec );
			return @IPs;
		}

		if( $ip_param->{all_ipasolink} ) {
			$code="psql $ms5000flag $ms5000ip -U nems -p 55001 CMDB -A -t -q -c \"select neprimaryaddress from managed_element where netype like 'iPASOLINK%' $statusfilter ;\"";
			$result_of_exec=qx( $code );
			@IPs=split( /\s/, $result_of_exec );
			return @IPs;	
		}
		
	} else {
		# stadalone configuration

		if( $ip_param->{group} ) {
			if( -f "$Paths->{GROUPS}/$ip_param->{group}" ) {							
				@IPs=split( /\s/, ReadFile( "$Paths->{GROUPS}/$ip_param->{group}" ) );
				return @IPs;
			}
		}
		if( $ip_param->{all_ipasolink} ) {
			if( -f $Paths->{global.ipasolink} ) {
				@IPs=split( /\s/, ReadFile( $Paths->{global.ipasolink} ));
				return @IPs;				
			}
		}
	}
	return @IPs;
}



sub require_authorisation {
	my $dbh=shift;
	my $ifdbh=1 if( $dbh );
	my %cookies = CGI::Cookie->fetch;
	if(  $cookies{id} ) {
		my $id=$cookies{id}->value;
		if(  $cookies{secret} ) {
			unless( $ifdbh ) {
				$dbh=db_connect() ;
			}
			my $row=GetRecord( $dbh, $id, 'session' ) ;
			unless( $ifdbh ) {
				db_disconnect( $dbh );
			}
			unless( $row->{secret} eq $cookies{secret}->value ) {
				return 0;
			}
		} else {
			return 0;
		}
		return $id;
	}
	return 0;
}


sub get_login {
	my %cookies = CGI::Cookie->fetch;
	if(  $cookies{login} ) {
		return $cookies{login}->value;
	}
	return '';
}



sub ReadConfig {
	my $Cfg;
	if( -f $Paths->{config.ini} ){
		my $body=ReadFile( $Paths->{config.ini}  );
		foreach ( split( /\n/, $body ) ) {
			chomp;
			my ( $key, $var )=split( /=/, $_ );
			$Cfg->{ $key }=$var ;
		}	
	}
	return $Cfg;
}

sub get_groups {
	my $ms5000=shift;
	my $ls;
	if( 'ms5000' ne $ms5000 ) {
		my $dir=$Paths->{GROUPS};

		opendir(DIR, $dir) || w2log( "can't opendir $dir: $!" );
			foreach( reverse sort grep { /\.ipasolink$/ &&   -f "$dir/$_" } readdir(DIR) ) {
				$ls->{ $_ }=$_;
			}
		closedir DIR;
		return $ls;
	}

	my $code="psql $ms5000flag $ms5000ip -U nems -p 55001 CMDB -A -t -q -c \"select a.summary_symbol_location_id, symbol_name from summary_symbol as a, symbol as b where a.summary_symbol_id = b.symbol_id and b.symbol_id <> -1;\"";
	my $result_of_exec=qx( $code );

	foreach $str ( split( /\s/, $result_of_exec ) ) {
		my ($grp, $dname)=split( /\|/, $str );
		$ls->{$grp}=$dname;	
	}
	return $ls;
}


sub get_workers {
	my $dir=$Paths->{WORKER_DIR};
	my @ls;
	opendir(DIR, $dir) || w2log( "can't opendir $dir: $!" );
		@ls = reverse sort grep { /\.pl$/ && -f "$dir/$_" } readdir(DIR);
	closedir DIR;
	return @ls;
}


sub get_cgiscripts {
	my $dir=$Paths->{CGISCRIPT_DIR};
	my @ls;
	opendir(DIR, $dir) || w2log( "can't opendir $dir: $!" );
		@ls = reverse sort grep { /\.cgi$/ &&  -f "$dir/$_" } readdir(DIR);
	closedir DIR;
	return @ls;
}



sub update_tasks{
	my $dbh=shift;
	my $timeout=3600;	# set timeout to 1 hour for task. After this time without 
						# activities ( if not any any changes in ID.out.json files ) task mark as failed
	my $stmt ="SELECT * from tasks  where status IN (  ?, ? ); " ;  
	my $sth = $dbh->prepare( $stmt );
	my $mess='';
	unless ( $rv = $sth->execute( 2, 3 ) || $rv < 0 ) { # select only started or running tasks
		message2 ( "Someting wrong with database  : $DBI::errstr" );
		w2log( "Sql ($stmt) Someting wrong with database  : $DBI::errstr"  );
		return 0;
	}

	while (my $row = $sth->fetchrow_hashref) {
		my $json_file="$Paths->{JSON}/$row->{id}.out.json";	
		my $json_text=ReadFile( $json_file ) ;
			if( $json_text ) {
				my $nrow = JSON->new->utf8->decode($json_text) ;		
				if( ($nrow->{sdt} le $row->{sdt}) and ( $nrow->{status} == $row->{status} ) ) {
					if( $row->{sdt} + $timeout < time() ) { #failed by timeout
						$mess="Task $row->{id} failed by timeout reason. Do not get any status update json messages during $timeout sec.";
						w2log( $mess );
						$nrow->{mess}=$mess ;
						$nrow->{sdt}=time() ;
						$nrow->{id}=$row->{id} ;
						$nrow->{status}=5; # failed				
						update_task_status(  $dbh , $nrow );																		
					}
					next;
				}
				update_task_status(  $dbh , $nrow );																		
			} else {
				my $nrow;
				if( $row->{sdt}+$timeout < time() ) { #failed by timeout
					$mess="Task $row->{id} failed by timeout reason. Do not get any status update json messages during $timeout sec.";
					w2log( $mess );
					$nrow->{status}=5 ; # failed				
					$nrow->{mess}=$mess ;
					$nrow->{sdt}=time() ;
					$nrow->{id}=$row->{id} ;					
					# $nrow->{progress}=0 ;				
					update_task_status(  $dbh , $nrow );					
				}			
			}		
	}	
}




sub update_task_status {
	my $dbh=shift;
	my $row=shift;
	my $table='tasks';	
	return( UpdateRecord ( $dbh, $row->{id}, $table, $row ) )  ;	
}

sub db_connect {
	
my $dbfile = "$Paths->{DB}/sqlite.db"; 
my $dsn      = "dbi:SQLite:dbname=$dbfile";
my $user     = "";
my $password = "";

my $dbh = DBI->connect($dsn, $user, $password, {
   PrintError       => 0,
   RaiseError       => 1,
   AutoCommit       => 1,
   FetchHashKeyName => 'NAME_lc',
}) or w2log ( "Cannot connect to database : $DBI::errstr" );
return $dbh;
}

sub db_disconnect {
	my $dbh=shift;
	$dbh->disconnect;
}

sub get_date {
	my $time=shift() || time();
	my $format=shift || "%s-%.2i-%.2i %.2i:%.2i:%.2i";
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime($time);
	$year+=1900;$mon++;
    return sprintf( $format,$year,$mon,$mday,$hour,$min,$sec);
}	

sub generate_filename {
	my $time=shift() || time();
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime($time);
	$year+=1900;$mon++;
    return sprintf( "%s-%.2i-%.2i_%.2i-%.2i-%.2i",$year,$mon,$mday,$hour,$min,$sec);
}
	

sub w2log {
	my $msg=shift;
	open (LOG,">>$Paths->{LOG}") || print ("Can't open file $Paths->{LOG}. $msg") ;
	print LOG get_date()."\t$msg\n";
	#print STDERR $msg;
	close (LOG);
}

sub check_by_type{
	my $type=shift;
	
}


sub message2 {
	my $msg=shift;
	$message=$message."$msg<br>";
}

sub DeleteRecord {
	my $dbh=shift;
	my $id=shift;
	my $table=shift;
	my $stmt ="DELETE FROM $table WHERE id = ? ; ";
	my $sth = $dbh->prepare( $stmt );
	my $rv;
	unless ( $rv = $sth->execute( $id ) ) {
		message2 ( "Someting wrong with database  : $DBI::errstr" );
		w2log ( "Someting wrong with database  : $DBI::errstr" );
		return 0;
	}	
	return 1;
}

sub GetRecord {
	my $dbh=shift;
	my $id=shift;
	my $table=shift;
	#my $fields=shift || '*';
	my $stmt ="SELECT * from $table where id = ? ;";
	my $sth = $dbh->prepare( $stmt );
	my $rv;
	unless ( $rv = $sth->execute( $id ) || $rv < 0 ) {
		message2 ( "Someting wrong with database  : $DBI::errstr" );
		w2log ( "Sql( $stmt ) Someting wrong with database  : $DBI::errstr" );
		return 0;
	}
	return ( $sth->fetchrow_hashref );	
}

sub GetRecordByField {
	my $dbh=shift;
	my $table=shift;
	my $field=shift;
	my $value=shift;
	#my $fields=shift || '*';
	my $stmt ="SELECT * from $table where $field = ? ;";
	my $sth = $dbh->prepare( $stmt );
	my $rv;
	unless ( $rv = $sth->execute( $value ) || $rv < 0 ) {
		message2 ( "Someting wrong with database  : $DBI::errstr" );
		w2log ( "Sql( $stmt ) Someting wrong with database  : $DBI::errstr" );
		return 0;
	}
	return ( $sth->fetchrow_hashref );	
}


sub UpdateRecord {
	my $dbh=shift;
	my $id=shift;
	my $table=shift;
	my $row=shift;
	my @Val=();
	my @Col=();
	foreach $key ( keys %{ $row }) {
		push ( @Col," $key = ? " ) ;
		push ( @Val, $row->{$key} ) ;
	}
		push ( @Val, $id ) ;
	my $stmt ="UPDATE $table set " . join(',',@Col ). " where id=?  ";
	#w2log( $stmt,@Col );
	#unless ( $dbh->do( $stmt,  @Val ) ) {
	#	message2 ( "Someting wrong with database  : $DBI::errstr" );
	#	w2log ( "Sql( $stmt )Someting wrong with database  : $DBI::errstr" );
	#	return 0;
	#}
	;
	my $sth = $dbh->prepare( $stmt );
	my $rv;
	unless ( $rv = $sth->execute( @Val ) || $rv < 0 ) {
		message2 ( "Someting wrong with database  : $DBI::errstr" );
		w2log ( "Sql( $stmt )Someting wrong with database  : $DBI::errstr" );
		return 0;
	}
	return ( 1 );	
}

sub InsertRecord {
	my $dbh=shift;
	my $id=shift; # do not used
	my $table=shift;
	my $row=shift;
	my @F;
	my @V;
	my @Q;
	foreach( keys %{ $row }) {
		push ( @F, $_ );
		push (@V , $row->{$_} );
		push ( @Q, '?');
	}
	my $stmt ="INSERT into $table ( ". join(',', @F). ") values ( ". join(',', @Q). " ) ;";
	my $sth = $dbh->prepare( $stmt );
	my $rv;
	unless ( $rv = $sth->execute( @V )  || $rv < 0  ) {
		message2 ( "Someting wrong with database  : $DBI::errstr" );
		w2log ( "Sql( $stmt ). Someting wrong with database  : $DBI::errstr" );
		return 0;
	}
	return ( 1 );	
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

sub GetCountRecords {
	my $dbh=shift;
	my $table=shift;
	my $Where=shift; # ref to array

	my $stmt ="";
	if( $#{Where} > -1 ) {
		$stmt ="SELECT COUNT(*) as count FROM  $table where " . join( ' and ',  @{Where} )." ;";
	} else {
		$stmt ="SELECT COUNT(*) as count FROM  $table ;";
	}
		my $sth = $dbh->prepare( $stmt );
		unless ( my $rv = $sth->execute( ) || $rv < 0 ) {
			message2 ( "Someting wrong with database  : $DBI::errstr" );
			w2log ( "Sql( $stmt ) Someting wrong with database  : $DBI::errstr" );
			return 0;
		}
	return ( $sth->fetchrow_hashref->{count} );		   
}




sub GetCountRecords1 {
	my $dbh=shift;
	my $table=shift;
	my $Where=shift;

	my @F=();
	my @V=();	

	foreach( keys %{ $Where }) {
		push ( @F, " $_ = ? " );
		push ( @V , $Where->{$_} );
	}	
	my $stmt ="";
	my $sth;
	my $rv;
	if( $#F > -1 ) {
		$stmt ="SELECT COUNT(*) as count FROM  $table where " . join( ' and ',  @F )." ;";
		$sth = $dbh->prepare( $stmt );
		unless ( $rv = $sth->execute( @V ) || $rv < 0 ) {
			message2 ( "Someting wrong with database  : $DBI::errstr" );
			w2log ( "Sql( $stmt ) Someting wrong with database  : $DBI::errstr" );
			return 0;
		}
	} else {
		$stmt ="SELECT COUNT(*) as count FROM  $table ;";
		$sth = $dbh->prepare( $stmt );
		unless ( $rv = $sth->execute() || $rv < 0 ) {
			message2 ( "Someting wrong with database  : $DBI::errstr" );
			w2log ( "Sql( $stmt ) Someting wrong with database  : $DBI::errstr" );
			return 0;
		}
	}
	#my $r=$sth->fetchrow_hashref;
	#	message2( "<pre>".Dumper($r)."</pre>");

	return ( $sth->fetchrow_hashref->{count} );		   
}




sub CheckField {
	my $f=shift;
	my $type=shift;
	my $prefix=shift; 
	my $constrains;
	my $retval=1;
		# Sample of constrains
		#$constrains->{login}->{max}=50;
		#$constrains->{login}->{min}=3;
		#$constrains->{login}->{no_spaces}=1;
		#$constrains->{login}->{first_char_letter}=1;
		#$constrains->{login}->{no_special_chars}=1;
		#$constrains->{login}->{no_angle_brackets}=1;
		#$constrains->{login}->{no_quotes}=1;

		$constrains->{cron}->{min}=9;
		$constrains->{cron}->{cron}=1;


		$constrains->{int}->{numeric}=1;
		$constrains->{int}->{max}=20;
		$constrains->{int}->{min}=1;
		$constrains->{int}->{no_spaces}=1;
		#$constrains->{int}->{no_special_chars}=1;

		$constrains->{ip_op_empty}->{ip_op_empty}=1;
		$constrains->{ip_op_empty}->{max}=15;
		$constrains->{ip_op_empty}->{min}=0;
		$constrains->{ip_op_empty}->{no_spaces}=1;

		$constrains->{ip}->{ip}=1;
		$constrains->{ip}->{max}=15;
		$constrains->{ip}->{min}=7;
		$constrains->{ip}->{no_spaces}=1;

		$constrains->{filename}->{max}=254;
		$constrains->{filename}->{min}=1;
		$constrains->{filename}->{no_quotes}=1;
		$constrains->{filename}->{no_special_chars}=1;
		$constrains->{filename}->{no_spaces}=1;
		
		
		$constrains->{login}->{max}=50;
		$constrains->{login}->{min}=3;
		$constrains->{login}->{no_spaces}=1;
		$constrains->{login}->{first_char_letter}=1;
		$constrains->{login}->{no_special_chars}=1;

		$constrains->{text}->{max}=254;
		$constrains->{text}->{min}=0;
		$constrains->{text}->{no_angle_brackets}=1;

		$constrains->{text_no_empty}->{max}=254;
		$constrains->{text_no_empty}->{min}=1;
		
		$constrains->{desc}->{max}=254;
		$constrains->{desc}->{min}=1;
		#$constrains->{desc}->{no_special_chars}=1;
		
		$constrains->{html}->{max}=254;
		$constrains->{html}->{min}=0;
						
		$constrains->{password}->{max}=20;
		$constrains->{password}->{min}=6;
		$constrains->{password}->{no_spaces}=1;

		$constrains->{boolean}->{boolean}=1;
		$constrains->{boolean}->{max}=1;
		$constrains->{boolean}->{min}=0;

		$constrains->{boolean_true}->{boolean}=1;
		$constrains->{boolean_true}->{true}=1;
		$constrains->{boolean_true}->{max}=1;
		$constrains->{boolean_true}->{min}=1;

		
		
	unless( $constrains->{$type} ) {
		return 0;
	}


	foreach $key ( keys ( %{ $constrains->{$type} } ) ) {
		#print "# $f # $type -";
		if( $key eq 'boolean' ) {
			unless( $f=~/^[0|1]*$/ ) {
				message2( "$prefix must be 1 or 0" );
				$retval=0;
			}
		}
		if( $key eq 'true' ) {
			unless( $f ) {
				message2( "$prefix must be true" );
				$retval=0;
			}
		}
		if( $key eq 'numeric' ) {
			unless( $f=~/^\d+$/ ) {
				message2( "$prefix must be numeric integer" );
				$retval=0;
			}
		}
		if( $key eq 'ip_or_empty' ) {
			if( $f ne '' ) {
			unless( $f=~/^(\d+)\.(\d+)\.(\d+)\.(\d+)$/ ) {
				message2( "$prefix must be empty or IP address " );
				$retval=0;
			}
			}
		}
		if( $key eq 'ip' ) {
			unless( $f=~/^(\d+)\.(\d+)\.(\d+)\.(\d+)$/ ) {
				message2( "$prefix must be IP address " );
				$retval=0;
			}
		}
		if( $key eq 'max' ) {
			if( length( $f ) > $constrains->{$type}->{max} ) {
				message2( "$prefix must be less than  $constrains->{$type}->{max} letter(s)" );
				$retval=0;
			}
		}
		if( $key eq 'min' ) {
			if( length( $f ) < $constrains->{$type}->{min} ) {
				message2( "$prefix must be greater or equiv than $constrains->{$type}->{min} letter(s)" );
				$retval=0;
			}
		}
		if( $key eq 'no_spaces' ) {
			if( $f=~/\s/ ) {
				message2( "$prefix must contain not spaces" );
				$retval=0;
			}
		}
		if( $key eq 'first_char_letter' ) {
			unless( $f=~/^[A-Za-z]\w+$/ ) {
				#print "# $f # $type -";
				message2( "$prefix must begin from letter" );
				$retval=0;
			}
		}
		if( $key eq 'no_special_chars' ) {
			unless(  $f=~/^[\w\.\s-]*$/ ) {
				message2( "$prefix "."must have not special chars" );
				$retval=0;
			}
		}
		if( $key eq 'no_angle_brackets' ) {
			if(  $f=~/\</  ||  $f=~/\>/ ) {
				message2( "$prefix must have not angle brackets" );
				$retval=0;
			}
		}
		if( $key eq 'no_quotes' ) {
			if(  $f=~/\'/  ||  $f=~/\"/ ) {
				message2( "$prefix must have not any quotes" );
				$retval=0;
			}
		}

		
		if( $key eq 'cron' ) {
			my $myf=$f;
			$myf=~s/^\s+//; 
			$myf=~s/\s+$//; 
			my @fields=split(/\s/,$myf);
				#message2( "<pre>".Dumper( @fields)."</pre>" );
			
			if( $#fields != 4 ) {
				message2( "$prefix must have 5 fields" );
				$retval=0;
				next;
			}
			my @F=qw( Minute Hour Day Month Weekday );
			my $k=0;
			foreach $i (@fields) {
				unless( $i=~/^[\d,-\/\*]+$/) {
					message2( "$prefix fields '$F[$k]' have incorrect chars" );
					$retval=0;
					last;
				}
				next if( $i eq '*' );
				my @a=( split(',', $i) );					
				foreach ( @a ) {
					#next if( /^\*$/ ); # if several and one is '*' then failed ?
					next if( /^\d+$/ );
					next if( /^(\d+)-(\d+)$/ && $1<$2 );
					next if( /^\*\/\d+$/ );
					next if( /^(\d+)-(\d+)\/\d+$/ && $1<$2 );
					message2( "$prefix fields '$i' have incorrect chars or expression" );
					$retval=0;
					last;
				}
				++$k;
			}
		}
	}		
	return $retval;	
}

sub ReadFile {
	my $filename=shift;
	my $ret="";
	open (IN,"$filename") || w2log("Can't open file $filename") ;
		while (<IN>) { $ret.=$_; }
	close (IN);
	return $ret;
}	

sub WriteFile {
	my $filename=shift;
	my $body=shift;
	unless( open (OUT,">$filename")) { w2log("Can't open file $filename for write" ) ;return 0; }
	print OUT $body;
	close (OUT);
	return 1;
}	

sub AppendFile {
	my $filename=shift;
	my $body=shift;
	unless( open (OUT,">>$filename")) { w2log("Can't open file $filename for append" ) ;return 0; }
	print OUT $body;
	close (OUT);
	return 1;
}


1;

