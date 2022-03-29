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
$template = HTML::Template->new(filename => 'login.htm', die_on_bad_params=>0 );

$query = new CGI;
foreach ( $query->param() ) { $Param->{$_}=$query->param($_); }


my $dbh, $stmt, $sth, $rv;
$message='';
$title="Login";

$template->param( AUTHORISED=>1 );

$dbh=db_connect() ;

my $show_form=1;

if(  Action() ==0 ) {
	if( $Param->{login} ) {
		message2 ( "Incorrect login or password" );			
		my $str="Unsuccessful login with  name '$Param->{login}' from :";
		map{ $str.=" $_ = $ENV{$_}; " } qw( REMOTE_HOST REMOTE_ADDR REMOTE_PORT HTTP_USER_AGENT ) ;		
		w2log( $str );
	}	
} else {
		my $row=GetRecordByField( $dbh,  'users', 'login', $Param->{login}, );
		my $secret=sha1_hex( time() );
		
		my $cookie_time=4; # set the cookies to 4 hours 
		my $cookie="<script type='text/javascript'>
		createCookie('id',		'$row->{id}',$cookie_time);
		createCookie('login',	'$row->{login}',$cookie_time);
		createCookie('name',	'$row->{name}',$cookie_time);
		createCookie('secret',	'$secret',$cookie_time);
		</script>"; 

		$template->param( SET_COOKIES=>$cookie );					
		my $nrow;
		$nrow->{login}=$Param->{login};
		$nrow->{secret}=$secret;
		$nrow->{dt}=time()+$cookie_time*3600;
		$nrow->{id}=$row->{id};
		DeleteRecord( $dbh, $nrow->{id}, 'session' );
 		InsertRecord( $dbh, $nrow->{id}, 'session', $nrow );
		my $str="Successful login with  name '$Param->{login}' from :";
		map{ $str.=" $_ = $ENV{$_}; " } qw( REMOTE_HOST REMOTE_ADDR REMOTE_PORT HTTP_USER_AGENT ) ;		
		w2log( $str );
	message2 ( "<font color=green>Login successfull</font>" );
	$show_form=0;
}


	 
$template->param( SHOWFORM=>$show_form );
$template->param( LOGIN=>$Param->{login} );
$template->param( ACTION=>  "$ENV{'SCRIPT_NAME'}" );
$template->param( TITLE=>$title );

  # print the template output
$template->param( MESSAGES=> $message );

#my %cookies = CGI::Cookie->fetch;
#if ( $cookies{'name'} ) {
#	$template->param( LOGIN_AS=> "You are login as '$cookies{'name'}->value'"  );	
#}

print  $template->output;

 
db_disconnect( $dbh );

##############################################

sub Action {
	
	if( $Param->{save} ) {
		my $row=GetRecordByField( $dbh, 'users', 'login', $Param->{login}, );
		unless( $row ) {	
			return 0;
		}
		if( $row->{password} eq sha1_hex( $Param->{password} ) ) {
			return 1;
		} else {
			return 0;
		}
	}
return 0;
}
