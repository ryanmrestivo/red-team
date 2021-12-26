#!/usr/bin/perl
# korolev-ia [at] yandex.ru
# version 1.1 2016.04.11
use lib 'C:\GIT\snmpcheck\lib' ;
use lib '/opt/snmpcheck/lib' ;
use lib '../lib' ;
use lib '../../lib' ;

print "Content-type: text/html

" ;


use COMMON_ENV;
use CGI::Carp qw ( fatalsToBrowser );



$sname="qosequip";
$title="iPasolink QoS set tool (equipment mode)";
$ENV{ "HTML_TEMPLATE_ROOT" }=$Paths->{TEMPLATE};
$template = HTML::Template->new(filename => 'qosequip.htm', die_on_bad_params=>0 );

$template->param( SNAME=> $sname  );
$template->param( TITLE=> $title  );
$template->param( ACTION=>  $ENV{SCRIPT_NAME} );



$query = new CGI;
foreach ( $query->param() ) { $Param->{$_}=$query->param($_); }


my $dbh, $stmt, $sth, $rv;
$message='';

my $Cfg=ReadConfig();
if( $Cfg->{iplistdb} eq 'ms5000' ) {
	$template->param( MS5000=>1 );
}

$template->param( AUTHORISED=>1 );
if(  grep {/^$sname$/ } split( /,/, $Cfg->{approved_application_for_authentication} ) ) {
	unless (  require_authorisation()  ) { # we require any authorised user
		message2( "Only authorised user can add this task" );
		$template->param( AUTHORISED=>0 );
		$template->param( MESSAGES=> $message );

		print  $template->output;
	exit 0;
 }
}


unless( $Param->{Que_num} ) {
	$template->param( SHOWFORM_ZERO=> 1 );
	$template->param( SHOWFORM_FIRST=> 0 );
	$template->param( SHOWFORM_SECOND=> 0 );
	$template->param( SHOWFORM_TO_TASK=> 0 );
		print  $template->output;
	exit 0;
}

if( 1==$Param->{Que_num} ) {	
	$template->param( QUE_NUM_4=>1 ) ;
}



my $save_Que_num=$Param->{Que_num};
$dbh=db_connect() ;
if( $Param->{new} ) {
	my $row=GetRecordByField( $dbh, 'def_val', 'sname', "${sname}_$Param->{Que_num}" );
	if( $row ) {
		my $coder = JSON::XS->new->ascii->pretty->allow_nonref;
		$Param=$coder->decode ($row->{val});
		undef( $Param->{id} );
		undef( $Param->{save} );
		undef( $Param->{save_first} );
		undef( $Param->{save_second} );
		undef( $Param->{save_as_default} );
		undef( $Param->{edit} );
		undef( $Param->{new} );
	}
}

$Param->{Que_num}=$save_Que_num;

my $show_form=1;


$Param->{all_ipasolink}=$Param->{all_ipasolink}?1:0;
$Param->{subgroup}=$Param->{subgroup}?1:0;
$Param->{inop}=$Param->{inop}?1:0;
$Param->{ucon}=$Param->{ucon}?1:0;
$Param->{umng}=$Param->{umng}?1:0;


$template->param( SHOWFORM_FIRST=> 1 );
$template->param( SHOWFORM_SECOND=> 0 );
$template->param( SHOWFORM_TO_TASK=> 0 );

# get title of page from db
# my $trow=GetRecordByField ( $dbh, 'snmpworker', 'sname', $sname ) ;
# $title=$trow->{desc} if( $trow->{desc});

if( $Param->{save_as_default} ) {
	my $result=1;
	if( check_record()  ) {
		$template->param( SHOWFORM_FIRST=> 1 );
		$template->param( SHOWFORM_SECOND=> 0 );
		$template->param( SHOWFORM_TO_TASK=> 0 );
		$template->param( ACTION=>  $ENV{SCRIPT_NAME} );
		$template->param( TITLE=> $title );	
		my $coder = JSON::XS->new->utf8->pretty->allow_nonref; # bugs with JSON module and threads. we need use JSON::XS
		my $json = $coder->encode ($Param);
		my $row;
		if( $row=GetRecordByField( $dbh, 'def_val', 'sname', "${sname}_$Param->{Que_num}" )  ) {
			$row->{ val }=$coder->encode ($Param);
			$result=UpdateRecord( $dbh, $row->{id}, 'def_val', $row );
		} else {
			$row->{id}=GetNextSequence($dbh);
			$row->{ val }=$coder->encode ($Param);
			$row->{ sname }="${sname}_$Param->{Que_num}";			
			$result=InsertRecord( $dbh, $row->{id}, 'def_val', $row );
		}
		if( $result) {
			message2( "<font color=green>Default form values saved</font>");
		} else {
			message2( "Cannot save default form values");
		}
	}
}



if( $Param->{save_first} ) {
	if( check_record()  ) {
		$template->param( SHOWFORM_FIRST=> 0 );
		$template->param( SHOWFORM_SECOND=> 1 );
		$template->param( SHOWFORM_TO_TASK=> 0 );
		$template->param( DESC=> "$sname task " ) ; 	# .get_date() );
			if( 1 == $Param->{task_start_type} ) {
				$template->param( DESC=> "$sname crontab task " )
			}		
#message2( "<pre>".Dumper($Param)."</pre>");		
	} else{
		$template->param( SHOWFORM_FIRST=> 1 );
		$template->param( SHOWFORM_SECOND=> 0 );
		$template->param( SHOWFORM_TO_TASK=> 0 );
	}
}

if( $Param->{save_second} ) {
	if( check_record2()  ) {
		$template->param( SHOWFORM_FIRST=> 0 );
		$template->param( SHOWFORM_SECOND=> 0 );
		$template->param( SHOWFORM_TO_TASK=> 1 );
		$template->param( TITLE=>"$title. Ready to add task" );
		$template->param( ACTION=>  $ENV{SCRIPT_NAME}  );		
		$template->param( ACTION_TASK_ADD =>  $Url->{ACTION_TASK_ADD} );
		$template->param( DESC=> $Param->{desc}.get_date() );
		if( 1 == $Param->{task_start_type} ) {
			$template->param( ACTION_TASK_ADD =>  $Url->{ACTION_TASK_ADD_CRONTAB} );
			$template->param( DESC=> $Param->{desc} );
		}
		
	} else {
		$template->param( DESC=> $Param->{desc} );
		$template->param( ACTION=>  $ENV{SCRIPT_NAME}  );	
		$template->param( ACTION_TASK_ADD=>  $Url->{ACTION_TASK_ADD}  );	
		$template->param( SHOWFORM_FIRST=> 0 );
		$template->param( SHOWFORM_SECOND=> 1 );
		$template->param( SHOWFORM_TO_TASK=> 0 );
	}
}




my @loop_data=();
	my $grp=get_groups(  $Cfg->{iplistdb} );
	$grp->{''}='';
	foreach $group ( sort keys( %{$grp} ) ) {
		my %row_data;   
		$row_data{ SELECTED }=' selected ' if( $Param->{group} eq $group );
		$row_data{ SELECTED }=' selected ' if( !$Param->{group} and $grp eq '' ) ;
		$row_data{ GROUP }=$group;
		$row_data{ GROUP_NAME }=$grp->{$group};		
		push(@loop_data, \%row_data);
	}
		#my %row_data;   
		#$row_data{ SELECTED }=' selected ' 	unless( $Param->{group}  ) ;
		#$row_data{ GROUP }='';
		#$row_data{ GROUP_NAME }='';	
		#push(@loop_data, \%row_data);
		
	$template->param(GROUP_LIST_LOOP => \@loop_data);	
	$template->param( IP=> $Param->{ip} );
	$template->param( GROUP=> $Param->{group} );
	$template->param( SUBGROUP=> $Param->{subgroup} );
	$template->param( ALL_IPASOLINK=> $Param->{all_ipasolink} );
	$template->param( INOP=> $Param->{inop} );
	$template->param( UCON=> $Param->{ucon} );
	$template->param( UMNG=> $Param->{umng} );
	$template->param( WORKER_THREADS=> $Param->{worker_threads} );
	$template->param( TASK_START_TYPE=> $Param->{task_start_type} );
	$template->param( TASK_START_TYPE_CRON=>1 ) if( 1 == $Param->{task_start_type} ) ;
	$template->param( CRON=> $Param->{cron} );


	
if( $Param->{Que_num}==1 ) {
	$template->param( QUE_TXT=> 4 );
}
if( $Param->{Que_num}==2 ) {
	$template->param( QUE_TXT=> 8 );
}	
		
foreach $y ( qw( Que_num actpro delpro ent10cf ent10cip ent10cp ent11cf ent11cip ent11cp ent12cf 
ent12cip ent12cp ent13cf ent13cip ent13cp ent14cf ent14cip ent14cp ent15cf ent15cip 
ent15cp ent16cf ent16cip ent16cp ent17cf ent17cip ent17cp ent18cf ent18cip ent18cp 
ent19cf ent19cip ent19cp ent1cf ent1cip ent1cp ent20cf ent20cip ent20cp ent21cf 
ent21cip ent21cp ent22cf ent22cip ent22cp ent23cf ent23cip ent23cp ent24cf ent24cip 
ent24cp ent25cf ent25cip ent25cp ent26cf ent26cip ent26cp ent27cf ent27cip ent27cp 
ent28cf ent28cip ent28cp ent29cf ent29cip ent29cp ent2cf ent2cip ent2cp ent30cf 
ent30cip ent30cp ent31cf ent31cip ent31cp ent32cf ent32cip ent32cp ent33cf ent33cip 
ent33cp ent34cf ent34cip ent34cp ent35cf ent35cip ent35cp ent36cf ent36cip ent36cp 
ent37cf ent37cip ent37cp ent38cf ent38cip ent38cp ent39cf ent39cip ent39cp ent3cf 
ent3cip ent3cp ent40cf ent40cip ent40cp ent41cf ent41cip ent41cp ent42cf ent42cip 
ent42cp ent43cf ent43cip ent43cp ent44cf ent44cip ent44cp ent45cf ent45cip ent45cp 
ent46cf ent46cip ent46cp ent47cf ent47cip ent47cp ent48cf ent48cip ent48cp ent49cf 
ent49cip ent49cp ent4cf ent4cip ent4cp ent50cf ent50cip ent50cp ent51cf ent51cip 
ent51cp ent52cf ent52cip ent52cp ent53cf ent53cip ent53cp ent54cf ent54cip ent54cp 
ent55cf ent55cip ent55cp ent56cf ent56cip ent56cp ent57cf ent57cip ent57cp ent58cf 
ent58cip ent58cp ent59cf ent59cip ent59cp ent5cf ent5cip ent5cp ent60cf ent60cip 
ent60cp ent61cf ent61cip ent61cp ent62cf ent62cip ent62cp ent63cf ent63cip ent63cp 
ent64cf ent64cip ent64cp ent6cf ent6cip ent6cp ent7cf ent7cip ent7cp ent8cf 
ent8cip ent8cp ent9cf ent9cip ent9cp googletrick profnum proselect queset 

)) {
	my $Y=uc($y);
	$template->param( $Y => $Param->{ $y } );
	$template->param( "${Y}_$Param->{ $y }" => 1 ) if( $Param->{ $y } );
}
			

#message2( "<pre>".Dumper($template)."</pre>");		 

# print the template output
$template->param( MESSAGES=> $message );
print  $template->output;

 
db_disconnect( $dbh );

##############################################




sub check_record {
	my $retval=1;
	unless( CheckField ( $Param->{Que_num} ,'int', "Field 'Number of queues' " )) {
			$retval=0;
	} 	
	if( 1 != $Param->{Que_num} && 2 != $Param->{Que_num} ) {
			message2( "Incorrected value of 'Queue number'" );
			$retval=0;
	}	
	if( 1 == $Param->{task_start_type} && !require_authorisation() ) { 
			message2( "Only authorised user can add crontab task" );
			$retval=0;
	}	
	unless( CheckField ( $Param->{ip} ,'ip_op_empty', "Field 'ip' " )) {
			$retval=0;
	} 
	unless( CheckField ( $Param->{group} ,'text', "Field 'group' ") ){
		$retval=0;
	}
	unless( CheckField ( $Param->{all_ipasolink} ,'boolean', "Field 'IP list for all iPasolink' ") ){
		$retval=0;
	}
#	unless( CheckField ( $Param->{desc} ,'desc', "Field 'Description' ") ){
#		$retval=0;
#	}
	if( !$Param->{ip} && !$Param->{group} && !$Param->{all_ipasolink} ) {
		message2( "Must be set 'ip address' or 'group' or 'IP list for all iPasolink'" );
		$retval=0;
	}
	return $retval;
}

sub check_record2 {
	my $retval=1;
	if( 1 == $Param->{task_start_type} ) {
		unless( CheckField ( $Param->{cron} ,'cron', "Field 'Crontab' ") ){
			$retval=0;
		}
		unless( require_authorisation() ) { 
			message2( "Only authorised user can add crontab task" );
			$retval=0;
		}
	}
	unless( CheckField ( $Param->{desc} ,'desc', "Field 'Description' ") ){
		$retval=0;
	}
	return $retval;
}

