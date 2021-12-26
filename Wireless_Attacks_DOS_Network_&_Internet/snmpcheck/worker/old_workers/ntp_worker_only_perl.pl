#!/usr/bin/perl
# korolev-ia [at] yandex.ru
# version 1.1 2016.04.13
use lib "/home/nems/client_persist/htdocs/bulktool4/lib" ;
use lib "C:\GIT\snmpcheck\lib" ;
use lib "/opt/snmpcheck/lib" ;
use lib "../lib" ;
use lib "../../lib" ;

use COMMON_ENV;
use File::Basename;

use Getopt::Long;



GetOptions (
        'json=s' => \$json_file,
        "help|h|?"  => \$help ) or show_help();



unless( -f $json_file ) {
	show_help();
	exit 1;
}


$json_text=ReadFile( $json_file );

$Param =JSON->new->utf8->decode($json_text);
$ip_param=JSON->new->utf8->decode($Param->{param});
my $Cfg=ReadConfig();


$outfile="$Paths->{OUTFILE_DIR}/$ip_param->{sname}_".generate_filename()."_$Param->{id}_log.csv";

my $json_out="$Paths->{JSON}/$Param->{id}.out.json";
my $row;
my $timenow=time();

my @IPs=get_ip_list( $ip_param );
$count_max=$#IPs || 1 ;
my $count=0;
my $error=0;

######### header of worker output table 
WriteFile( $outfile, "NE name,NE IP,Main operation,Polling period,Result\n" ) ;
######### header of worker output table 


foreach $IP( @IPs ) {
#######################################
########## we say to task manager thats task runing
	if( time() - $timenow  > 15 || 0==$count ) {
		sleep 1;
		$timenow=time();
		$row->{sdt}=time();
		$row->{status}=3; # running
		$row->{id}=$Param->{id};
		$row->{mess}='Task running. All ok.';
		$row->{progress}=int( $count*100/$count_max ) ;	
		unless( WriteFile( $json_out, JSON->new->utf8->encode($row) ) ){
				w2log ("Cannot write file $json_file: $!");
		}
	}
	$count++;

#######################################


#######################################
########### worker code
	my $code, $result_of_exec, $ne_name, $ntpstat;
	$code="snmpget -v 3 -a $Cfg->{snmpapro} -u $Cfg->{snmpuser} -A $Cfg->{snmpap} -x $Cfg->{snmppro} -X $Cfg->{snmppk} -l $Cfg->{snmplevel} -r $Cfg->{snmpr} -t $Cfg->{snmpt} -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.1.1.1.3.1 2>/dev/null | cut -d '\"' -f 2 " ;
	$ne_name=qx( $code ) ;
	chomp ( $ne_name );
	unless( $ne_name ) {
		AppendFile( $outfile, "$ne_name,$IP,inaccessible,,FATAL\n" );
		$error++;		
		next;
	} 
	
	$code="snmpset -v 3 -a $Cfg->{snmpapro} -u $Cfg->{snmpuser} -A $Cfg->{snmpap} -x $Cfg->{snmppro} -X $Cfg->{snmppk} -l $Cfg->{snmplevel} -r 2 -t 5 -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.4.1.1.3.1 i 1 2>/dev/null | cut -d ' ' -f 2";	
	$result_of_exec=qx( $code );
	chomp( $result_of_exec );
	if( 1 == $result_of_exec ) {
		AppendFile( $outfile, "$ne_name,$IP,NTP service stop,,COMPLETED\n" );
	} else {
		AppendFile( $outfile, "$ne_name,$IP,NTP service stop,,ERROR\n" );
		$error++;
	}
	my $result1,$result2,$result3,$result4;
	my $pollres1,$pollres2,$pollres3,$pollres4;

	$code="snmpset -v 3 -a $Cfg->{snmpapro} -u $Cfg->{snmpuser} -A $Cfg->{snmpap} -x $Cfg->{snmppro} -X $Cfg->{snmppk} -l $Cfg->{snmplevel} -r $Cfg->{snmpr} -t $Cfg->{snmpt} -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.4.2.1.3.1 a $ip_param->{ntp1} 2>/dev/null | cut -b 11-50";
	$result1=qx( $code );
	chomp( $result1 );
	$code="snmpset -v 3 -a $Cfg->{snmpapro} -u $Cfg->{snmpuser} -A $Cfg->{snmpap} -x $Cfg->{snmppro} -X $Cfg->{snmppk} -l $Cfg->{snmplevel} -r $Cfg->{snmpr} -t $Cfg->{snmpt} -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.4.2.1.5.1 i $ip_param->{ntp1_poll} 2>/dev/null | cut -d ' ' -f 2";
	#w2log( $code );
	$pollres1=qx( $code );
	chomp( $pollres1 );
	if( ($result1 == $ip_param->{ntp1})  && ($pollres1 ==  $ip_param->{ntp1_poll}) ) {
		AppendFile( $outfile, "$ne_name,$IP,ntp server1 address is set to '$ip_param->{ntp1}',ntp server1 polling period is set to '$ip_param->{ntp1_poll}',COMPLETED\n" );
	} else {
		AppendFile( $outfile, "$ne_name,$IP,ntp server1 address or polling period set,,ERROR\n" );
		$error++;
	}


	$code="snmpset -v 3 -a $Cfg->{snmpapro} -u $Cfg->{snmpuser} -A $Cfg->{snmpap} -x $Cfg->{snmppro} -X $Cfg->{snmppk} -l $Cfg->{snmplevel} -r $Cfg->{snmpr} -t $Cfg->{snmpt} -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.4.2.1.3.2 a $ip_param->{ntp2} 2>/dev/null | cut -b 11-50";
	$result2=qx( $code );
	chomp( $result2 );
	$code="snmpset -v 3 -a $Cfg->{snmpapro} -u $Cfg->{snmpuser} -A $Cfg->{snmpap} -x $Cfg->{snmppro} -X $Cfg->{snmppk} -l $Cfg->{snmplevel} -r $Cfg->{snmpr} -t $Cfg->{snmpt} -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.4.2.1.5.2 i $ip_param->{ntp2_poll} 2>/dev/null | cut -d ' ' -f 2";
	$pollres2=qx( $code );
	chomp( $pollres2 );
	if( ($result2 == $ip_param->{ntp2})  && ($pollres2 ==  $ip_param->{ntp2_poll}) ) {
		AppendFile( $outfile, "$ne_name,$IP,ntp server2 address is set to '$ip_param->{ntp2}',ntp server1 polling period is set to '$ip_param->{ntp2_poll}',COMPLETED\n" );
	} else {
		AppendFile( $outfile, "$ne_name,$IP,ntp server2 address or polling period set,,ERROR\n" );
		$error++;
	}	
	
	
	$code="snmpset -v 3 -a $Cfg->{snmpapro} -u $Cfg->{snmpuser} -A $Cfg->{snmpap} -x $Cfg->{snmppro} -X $Cfg->{snmppk} -l $Cfg->{snmplevel} -r $Cfg->{snmpr} -t $Cfg->{snmpt} -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.4.2.1.3.3 a $ip_param->{ntp3} 2>/dev/null | cut -b 11-50";
	$result3=qx( $code );
	chomp( $result3 );
	$code="snmpset -v 3 -a $Cfg->{snmpapro} -u $Cfg->{snmpuser} -A $Cfg->{snmpap} -x $Cfg->{snmppro} -X $Cfg->{snmppk} -l $Cfg->{snmplevel} -r $Cfg->{snmpr} -t $Cfg->{snmpt} -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.4.2.1.5.3 i $ip_param->{ntp3_poll} 2>/dev/null | cut -d ' ' -f 2";
	$pollres3=qx( $code );
	chomp( $pollres3 );
	if( ($result3 == $ip_param->{ntp3})  && ($pollres3 ==  $ip_param->{ntp3_poll}) ) {
		AppendFile( $outfile, "$ne_name,$IP,ntp server3 address is set to '$ip_param->{ntp3}',ntp server1 polling period is set to '$ip_param->{ntp3_poll}',COMPLETED\n" );
	} else {
		AppendFile( $outfile, "$ne_name,$IP,ntp server3 address or polling period set,,ERROR\n" );
		$error++;
	}	
	
	$code="snmpset -v 3 -a $Cfg->{snmpapro} -u $Cfg->{snmpuser} -A $Cfg->{snmpap} -x $Cfg->{snmppro} -X $Cfg->{snmppk} -l $Cfg->{snmplevel} -r $Cfg->{snmpr} -t $Cfg->{snmpt} -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.4.2.1.3.4 a $ip_param->{ntp4} 2>/dev/null | cut -b 11-50";
	$result4=qx( $code );
	chomp( $result4 );
	$code="snmpset -v 3 -a $Cfg->{snmpapro} -u $Cfg->{snmpuser} -A $Cfg->{snmpap} -x $Cfg->{snmppro} -X $Cfg->{snmppk} -l $Cfg->{snmplevel} -r $Cfg->{snmpr} -t $Cfg->{snmpt} -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.4.2.1.5.4 i $ip_param->{ntp4_poll} 2>/dev/null | cut -d ' ' -f 2";
	$pollres4=qx( $code );
	chomp( $pollres4 );
	if( ($result4 == $ip_param->{ntp4})  && ($pollres4 ==  $ip_param->{ntp4_poll}) ) {
		AppendFile( $outfile, "$ne_name,$IP,ntp server4 address is set to '$ip_param->{ntp4}',ntp server1 polling period is set to '$ip_param->{ntp4_poll}',COMPLETED\n" );
	} else {
		AppendFile( $outfile, "$ne_name,$IP,ntp server4 address or polling period set,,ERROR\n" );
		$error++;
	}	
	

	
	$code="snmpset -v 3 -a $Cfg->{snmpapro} -u $Cfg->{snmpuser} -A $Cfg->{snmpap} -x $Cfg->{snmppro} -X $Cfg->{snmppk} -l $Cfg->{snmplevel} -r 2 -t 10 -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.4.1.1.3.1 i 2 2>/dev/null | cut -d ' ' -f 2";	
	$result_of_exec=qx( $code );
	chomp( $result_of_exec );
	if( 2==$result_of_exec  ) {
		AppendFile( $outfile, "$ne_name,$IP,NTP service start,,COMPLETED\n" );
	} else {
		AppendFile( $outfile, "$ne_name,$IP,NTP service start,,ERROR\n" );
		$error++;
	}

	
########### end of worker code
#######################################

}

######### bottom of worker output table 
AppendFile( $outfile, "End of the report\n");
######### bottom of worker output table 




#######################################
########## we say to task manager thats task finished

$row->{sdt}=time();
$row->{status}=4; # finished
$row->{id}=$Param->{id};
$row->{progress}=100 ;
$row->{outfile}=basename( $outfile );
$row->{mess}='Finished successfully';
if( $error ) {
	$row->{mess}='Finished with errors.';
} 


unless( WriteFile( $json_out, JSON->new->utf8->encode($row) ) ){
	w2log ("Cannot write file $json_file: $!");
}
#######################################

exit 0;
 


 
  
sub show_help {
print STDOUT "Usage: $0  --json='JSON_FILE' [ --help ]
Sample:
$0  --json='/tmp/123.json'
";
}
