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
$template = HTML::Template->new(filename => 'users.htm', die_on_bad_params=>0 );

$query = new CGI;
foreach ( $query->param() ) { $Param->{$_}=$query->param($_); }


my $dbh, $stmt, $sth, $rv;
$message='';
my $show_form=0;
my $table='users';
my $record;
$title="Add / Edit / Delete users";

$template->param( AUTHORISED=>1 );
unless (  1==require_authorisation( ) ) { # we require authorisation and only root can add,modify or delete users
	message2( "Only Root can add, modify or delete users" );
	$template->param( AUTHORISED=>0 );
	$template->param( ACTION=>  "$ENV{'SCRIPT_NAME'}" );
	$template->param( TITLE=>$title );
	$template->param( MESSAGES=> $message );

	print  $template->output;
exit 0;
}

$dbh=db_connect() ;

unless ( Action() ) {
	$show_form=1;
};


if( $show_form ) {
	$template->param( SHOWFORM=>1 );
	$template->param( EDIT=>$Param->{edit} );
	$template->param( NEW=>$Param->{new} );

  if( $Param->{new} ) {
		$template->param( LOGIN=> $Param->{login} );
		$template->param( NAME=> $Param->{name} );
		#$template->param( ID=>'' );
  }
  if( $Param->{edit} ) {
	my $row=GetRecord ( $dbh, $Param->{id}, $table );
	if( $row ) {		
		$template->param( LOGIN=>$row->{login} );
		$template->param( NAME=>$row->{name} );
		$template->param( ID=>$row->{id} );
	}
	else{
		message2 ( " Cannot to get record from table $table with id = $Param->{id}" );
	}
  }
} else {

# show list of users
	$stmt =qq( SELECT id, name, login  from users order by login; );
	$sth = $dbh->prepare( $stmt );
	unless ( $rv = $sth->execute() || $rv < 0 ) {
		message2 ( "Someting wrong with database  : $DBI::errstr" );
		w2log( "Sql ($stmt) Someting wrong with database  : $DBI::errstr"  );
	}

	while (my $row = $sth->fetchrow_hashref) {
		my %row_data;   
		foreach( keys( %{$row}) ) {
			$row_data{ $_ }=$row->{$_};
		}
		push(@loop_data, \%row_data);
	}
	$template->param(USERS_LIST_LOOP => \@loop_data);
}
 
 
db_disconnect( $dbh );




#print "<pre>".Dumper( $ENV{'SCRIPT_NAME'} )."</pre>";
$template->param( ACTION=>  "$ENV{'SCRIPT_NAME'}" );
$template->param( TITLE=>$title );
$template->param( MESSAGES=> $message );

  # print the template output
  
print  $template->output;

 


##############################################

sub Action {
	my $row;	

	if( $Param->{save} ) {
		unless( check_login_name_record()  ) {	
			return 0;
		}
		
		$row->{login}=$Param->{login};
		$row->{name}=$Param->{name} ;
		
		unless( $Param->{id} ) { # if we save the new record the password is required
		
			if( check_password_record() ) {
				$row->{password}=sha1_hex( $Param->{password} );
			} else {
				return 0;
			}
			
			if ( InsertRecord ( $dbh, $Param->{id}, 'users', $row ) ) {
				message2 ( "Record inserted succsesfuly" );
				return 1;
			} else {
				message2 ( "Cannot insert record" );
				return 0;
			}
		}	
		
		# if exist fiels id, then we edit the record
		# if fiels password is not empty, then update password too
		if( $Param->{password} ne '' ) { # if we password is no empty
			if( check_password_record() ) {
				$row->{password}=sha1_hex( $Param->{password} );
			} else {
				return 0;
			}
		}
			
		if ( UpdateRecord ( $dbh, $Param->{id}, 'users', $row ) ) {
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
			if ( 1==$Param->{id} )  {
				message2 ( "Cannot delete user Root" );	
				return 0;
			}
			if ( DeleteRecord ( $dbh, $Param->{id}, 'users' ) ) {
				message2 ( "Record deleted succsesfuly" );
				return 1;
			} else {
				message2 ( "Cannot delete record" );
				return 0;
			}
	}	
return 1;
}


sub check_login_name_record {
	my $retval=1;
	unless( CheckField ( $Param->{login} ,'login', "Field 'login' " )) {
		$retval=0;
	} 
	unless( CheckField ( $Param->{name} ,'text', "Field 'name' ") ){
		$retval=0;
		}
	return $retval;
}

sub check_password_record {
	if( $Param->{password} ne $Param->{password0}  ) {
		message2( "Fields 'password' and 'password0' must be equiv" ); 
		return 0;
	}
	if( CheckField ( $Param->{password} ,'password', "Field 'password' ") ) {
			return 1;
		}
	return 0;
}

