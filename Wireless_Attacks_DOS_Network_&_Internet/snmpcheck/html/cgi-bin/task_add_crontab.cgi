#!/usr/bin/perl
# korolev-ia [at] yandex.ru
# version 1.0 2016.04.05
use lib "C:\GIT\snmpcheck\lib" ;
use lib "/opt/snmpcheck/lib" ;
use lib "../lib" ;
use lib "../../lib" ;

print "Content-type: text/html

" ;

use COMMON_ENV;
use CGI::Carp qw ( fatalsToBrowser );


$query = new CGI;
foreach ( $query->param() ) { $Param->{$_}=$query->param($_); }
$login=$query->cookie('login');


$ENV{ "HTML_TEMPLATE_ROOT" }=$Paths->{TEMPLATE};
$template = HTML::Template->new(filename => 'task_add_crontab.htm', die_on_bad_params=>0 );

$table='crontasks';
$id=0; # id of new task
$sname=$Param->{sname};


$template->param( AUTHORISED=>1 );
	unless (  require_authorisation()  ) { # we require any authorised user
		message2( "Only authorised user can add crontab records" );
		$template->param( AUTHORISED=>0 );
		$template->param( ACTION=>  $ENV{SCRIPT_NAME} );
		$template->param( TITLE=>$title );
		$template->param( MESSAGES=> $message );

		print  $template->output;
		exit 0;
	}
$login=get_login();

$dbh=db_connect() ;


if(  Action() ==0 ) {
	message2( "Cannot add new crontab record" );	
} else {
	message2( "<font color=green>Task '$Param->{desc}' added. Please, check it in <a href='$Url->{ACTION_TASK_LIST_CRONTAB}?id=$id&edit=1'> Crontab list </a></font>" ) ;
	$template->param( REDIRECT_TO=> "$Url->{ACTION_TASK_LIST_CRONTAB}?id=$id&edit=1"  );
	w2log( "User '$login' add task '$Param->{desc}' for worker '$sname'. Parameters: ".JSON->new->utf8->encode($Param) );
}

$template->param( MESSAGES=> $message );
print  $template->output;

db_disconnect( $dbh );





sub Action {
	my $row;	

	if( $Param->{save} ) {
		unless( check_record()  ) {	
			return 0;
		}
			
		$row->{id}=GetNextSequence( $dbh ) ;
		$row->{taskid}=0 ; # not yet started
		$row->{status}=3 ; # status of crontab - running or pending
		$row->{param}=JSON->new->utf8->encode($Param); 
		$row->{sname}=$Param->{sname} ;
		$row->{desc}=$Param->{desc} ;
		$row->{cron}=$Param->{cron} ;
		$row->{login}=$login ;
		$row->{worker_threads}=$Param->{worker_threads} ;		
		$row->{sdt}=time() ;
		$row->{dt}=time() ;		
				
		if ( InsertRecord ( $dbh, $row->{id},  $table, $row ) ) {
			message2 ( "<font color=green>Record inserted succsesfuly</font>" );
			$id=$row->{id};
			return 1;
		} else {
			message2 ( "Cannot insert record" );
			return 0;
		}
							
	}

return 0;
}




sub check_record {
	$retval=1;
	unless( CheckField ( $Param->{desc} ,'text', "Fields 'desc' ") ){
			$retval=0 ;
	}
	unless( CheckField ( $Param->{cron} ,'cron', "Fields 'cron' ") ){
			$retval=0 ;
	}		
	unless( CheckField ( $Param->{sname} ,'login', "Fields 'sname' ") ){
			$retval=0 ;
	} else {
		my $table='snmpworker';
		my $row=GetRecordByField ( $dbh,  $table, 'sname', $Param->{sname} );
		unless( $row ) {
				message2( "Not found worker with name $Param->{sname}" );			
				$retval=0 ;
		}		
	}
	return $retval;
}
	


