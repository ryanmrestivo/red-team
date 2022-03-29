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



$sname="qosport";
$title="iPasolink QoS set tool  (port mode)";
$ENV{ "HTML_TEMPLATE_ROOT" }=$Paths->{TEMPLATE};
$template = HTML::Template->new(filename => 'qosport.htm', die_on_bad_params=>0 );

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
		
foreach $y ( qw( Que_num edwrr0 edwrr1 edwrr2 edwrr3 edwrr4 edwrr5 edwrr6 edwrr7 edwrrallow 
einterprioallow eql0 eql1 eql2 eql3 eql4 eql5 eql6 eql7 eqs0 
eqs1 eqs2 eqs3 eqs4 eqs5 eqs6 eqs7 esps0 ethernetdefportprio ethernetdropmode 
ethernetinternalpri0 ethernetinternalpri1 ethernetinternalpri2 ethernetinternalpri3 ethernetinternalpri4 ethernetinternalpri5 ethernetinternalpri6 ethernetinternalpri7 ethernetport ethernetscheduler 
ethernetschedulermode ethernetset ethernetslot ewredg0 ewredg1 ewredg2 ewredg3 ewredg4 ewredg5 ewredg6 
ewredg7 ewredy0 ewredy1 ewredy2 ewredy3 ewredy4 ewredy5 ewredy6 ewredy7 ewtdallow 
ewtdy0 ewtdy1 ewtdy2 ewtdy3 ewtdy4 ewtdy5 ewtdy6 ewtdy7 fakename0 fakename1 
fakename2 fakename3 fakename4 fakename5 fakename6 fakename7 googletrick mdwrr0 mdwrr1 mdwrr2 
mdwrr3 mdwrr4 mdwrr5 mdwrr6 mdwrr7 mdwrrallow minterprioallow modemdefportprio modemdropmode modeminternalpri0 
modeminternalpri1 modeminternalpri2 modeminternalpri3 modeminternalpri4 modeminternalpri5 modeminternalpri6 modeminternalpri7 modemport modemscheduler modemschedulermode 
modemset mql0 mql1 mql2 mql3 mql4 mql5 mql6 mql7 mqs0 
mqs1 mqs2 mqs3 mqs4 mqs5 mqs6 mqs7 mwredg0 mwredg1 mwredg2 
mwredg3 mwredg4 mwredg5 mwredg6 mwredg7 mwredy0 mwredy1 mwredy2 mwredy3 mwredy4 
mwredy5 mwredy6 mwredy7 mwtdallow mwtdy0 mwtdy1 mwtdy2 mwtdy3 mwtdy4 mwtdy5 
mwtdy6 mwtdy7 queset 

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

