#!/usr/bin/perl
# korolev-ia [at] yandex.ru
# version 1.0 2016.03.18
use lib "C:\GIT\snmpcheck\lib" ;
use lib "/opt/snmpcheck/lib" ;
use lib "../lib" ;
use lib "../../lib" ;

print "Content-type: text/html

" ;

use COMMON_ENV;
use CGI::Carp qw ( fatalsToBrowser );



$ENV{ "HTML_TEMPLATE_ROOT" }=$Paths->{TEMPLATE};
$template = HTML::Template->new(filename => 'snmpworker.htm', die_on_bad_params=>0 );

$query = new CGI;
foreach ( $query->param() ) { $Param->{$_}=$query->param($_); }


my $dbh, $stmt, $sth, $rv;
$message='';
$title="Add / Edit / Delete worker settings";


$template->param( AUTHORISED=>1 );

unless (  1==require_authorisation( ) ) { # we require authorisation and only root can add,modify or delete users
	message2( "Only Root can add, modify or delete worker settings" );
	$template->param( AUTHORISED=>0 );
	$template->param( ACTION=>  "$ENV{'SCRIPT_NAME'}" );
	$template->param( TITLE=>$title );	
	$template->param( MESSAGES=> $message );

	print  $template->output;
exit 0;
}





$dbh=db_connect() ;

my $show_form=0;
my $table='snmpworker';
my $record;


$Param->{auth}=$Param->{auth}?1:0;
unless ( Action() ) {
	$show_form=1;
};

	
 

if( $show_form ) {
	$template->param( SHOWFORM=>1 );
	$template->param( EDIT=>$Param->{edit} );
	$template->param( NEW=>$Param->{new} );

	
  if( $Param->{new} ) {
	$template->param( SNAME=>$Param->{sname} );
	$template->param( DESC=>$Param->{desc} );
	$template->param( WORKER=>$Param->{worker}  );
	$template->param( CGISCRIPT=>$Param->{cgiscript}  );
	$template->param( WORKER_BODY=>$Param->{worker_body}  );
	$template->param( EXPORT_PARAM=>$Param->{export_param}  );
	$template->param( TABLE_HEADER=>$Param->{table_header}  );
  }
  if( $Param->{edit} ) {
	my $row=GetRecord ( $dbh, $Param->{id}, $table );
	if( $row ) {		
		$template->param( ID=>$row->{id} );
		$template->param( SNAME=>$row->{sname} );
		$template->param( DESC=>$row->{desc} );
		$template->param( WORKER=>$row->{worker}  );
		$template->param( CGISCRIPT=>$row->{cgiscript}  );
		$template->param( WORKER_BODY=>$row->{worker_body}  );
		$template->param( EXPORT_PARAM=>$row->{export_param}  );
		$template->param( TABLE_HEADER=>$row->{table_header}  );
	}
	else{
		message2 ( " Cannot to get record from table $table with id = $Param->{id}" );
	}
  }
} else {

# show list of workers
	$stmt ="SELECT *  from $table order by sname; " ;
	$sth = $dbh->prepare( $stmt );
	unless ( $rv = $sth->execute() || $rv < 0 ) {
		message2 ( "Someting wrong with database  : $DBI::errstr" );
		w2log( "Sql ($stmt) Someting wrong with database  : $DBI::errstr"  );
	}
	my @loop_data=();
	while (my $row = $sth->fetchrow_hashref) {
		my %row_data;   
		foreach( keys( %{$row}) ) {
			#print $_;
			$row_data{ $_ }=$row->{$_};
		}
		push(@loop_data, \%row_data);
	}
	$template->param(USERS_LIST_LOOP => \@loop_data);
}

my @loop_data=();
foreach $w ( get_workers() ) {
	my %row_data;   
	$row_data{ LOOP_WORKER }=$w;
	push(@loop_data, \%row_data);
}
$template->param(WORKER_LIST_LOOP => \@loop_data);


@loop_data=();
foreach $w ( get_cgiscripts() ) {
	my %row_data;   
	$row_data{ LOOP_CGISCRIPT }=$w;
	push(@loop_data, \%row_data);
}
$template->param(CGISCRIPT_LIST_LOOP => \@loop_data);

@loop_data=();
my $Cfg=ReadConfig();
foreach $w ( sort( split(/,/, $Cfg->{approved_application_for_no_authentication}), split(/,/,$Cfg->{approved_application_for_authentication}) ) ) {
	my %row_data;   
	$row_data{ LOOP_SNAME }=$w;
	push(@loop_data, \%row_data);
}
$template->param(SNAME_LIST_LOOP => \@loop_data);


	
 
#print "<pre>".Dumper( $ENV{'SCRIPT_NAME'} )."</pre>";
$template->param( ACTION=>  "$ENV{'SCRIPT_NAME'}" );
$template->param( TITLE=>$title );




  # print the template output
$template->param( MESSAGES=> $message );
print  $template->output;

 
db_disconnect( $dbh );

##############################################

sub Action {
	my $row;	

	if( $Param->{save} ) {
		unless( check_smnpworker_record()  ) {	
			return 0;
		}
		
		$row->{sname}=$Param->{sname} ;
		$row->{desc}=$Param->{desc} ;
		$row->{worker}=$Param->{worker} ;
		$row->{cgiscript}=$Param->{cgiscript} ;
		$row->{worker_body}=$Param->{worker_body} ;
		$row->{export_param}=$Param->{export_param} ;
		$row->{table_header}=$Param->{table_header} ;
		
		unless( $Param->{id} ) { # if we save the new record 					
			if ( InsertRecord ( $dbh, $Param->{id},  $table, $row ) ) {
				message2 ( "Record inserted succsesfuly" );
				return 1;
			} else {
				message2 ( "Cannot insert record" );
				return 0;
			}
		}	
					
		if ( UpdateRecord ( $dbh, $Param->{id}, $table, $row ) ) {
			message2 ( "Record updated succsesfuly" );
			return 1;
		} else {
			message2 ( "Cannot update record" );
			return 0;
		}
			
	}
	if( $Param->{new} ) {
			return 0;
	}
 
	if( $Param->{edit} ) {
			return 0;
	}	

	if( $Param->{del} ) {
		if ( DeleteRecord ( $dbh, $Param->{id},  $table ) ) {
			message2 ( "Record deleted succsesfuly" );
			return 1;
		} else {
			message2 ( "Cannot delete record" );
			return 0;
		}
	}	
return 1;
}


sub check_smnpworker_record {
	my $retval=1;
	unless( CheckField ( $Param->{ sname } ,'login', "Field 'sname' ") ) {
			$retval=0 ;
	}
	unless( CheckField ( $Param->{ desc } ,'text', "Field 'desc' ") ) {
			$retval=0 ;
	}
	unless( CheckField ( $Param->{ worker } ,'filename', "Field 'worker script' ") ){
			$retval=0 ;
	}
	unless( CheckField ( $Param->{ cgiscript } ,'filename', "Field 'CGI script' ") ){
			$retval=0 ;
	}
	return $retval;
}

