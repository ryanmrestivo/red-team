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
use Time::Piece;
use POSIX;

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
WriteFile( $outfile, "NE name,IP,Server time,NE time,year difference,month difference,day difference,hour difference,minute difference,second difference,accuracy,NTP1 polling,NTP2 polling,Multicast polling\n" ) ;
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
	my $code, $result_of_exec, $ne_name, $tzstat;
	$code="snmpget -v 3 -a $Cfg->{snmpapro} -u $Cfg->{snmpuser} -A $Cfg->{snmpap} -x $Cfg->{snmppro} -X $Cfg->{snmppk} -l $Cfg->{snmplevel} -r $Cfg->{snmpr} -t $Cfg->{snmpt} -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.1.1.1.11.1 2>/dev/null" ;
	#w2log( $code);
	$result_of_exec=qx( $code );
	unless( $result_of_exec ) {
		AppendFile( $outfile, ",$IP,,,,,,,,,INACCESSIBLE\n" );
		$error++;		
		next;
	} 
	
	$code="snmpget -v 3 -a $Cfg->{snmpapro} -u $Cfg->{snmpuser} -A $Cfg->{snmpap} -x $Cfg->{snmppro} -X $Cfg->{snmppk} -l $Cfg->{snmplevel} -r $Cfg->{snmpr} -t $Cfg->{snmpt} -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.1.1.1.3.1 2>/dev/null | cut -d '\"' -f 2 " ;
	$ne_name=qx( $code ) ;
	chomp ( $ne_name );
	$code="snmpget -v 3 -a $Cfg->{snmpapro} -u $Cfg->{snmpuser} -A $Cfg->{snmpap} -x $Cfg->{snmppro} -X $Cfg->{snmppk} -l $Cfg->{snmplevel} -r 2 -t 5 -Ov $IP 1.3.6.1.4.1.119.2.3.69.5.1.3.1.1.3.1 2>/dev/null | cut -b 13-100";	
	# 07 E0 03 0E 0B 0B 09 00 2B 01 00
	#perl -e 'foreach $i ( qw( 07E0 03 0E 0B 0B 09 00 2B 01 00 )) { printf "%.2d", hex($i);} '
	#2016031411110900430100
	$result_of_exec=qx( $code );
	unless( $result_of_exec ) {
		AppendFile( $outfile, "$ne_name,$IP,FATAL\n" );
		$error++;		
		next;
	} 
	chomp ( $result_of_exec );
	my @DT=split( /\s/, $result_of_exec );	
	my $device_time=sprintf( "%s-%.2i-%.2i %.2i:%.2i:%.2i", map { hex() }  "$DT[0]$DT[1]", $DT[2], $DT[3], $DT[4], $DT[5], $DT[6] ) ;
	my $timezone=( $DT[8] eq '2B' )?'+':'-';
	$timezone.=sprintf( "%.2i%.2i", map { hex() }  $DT[9], $DT[10] );
	
	
	
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime();
	$year+=1900;$mon++;
	
	my $stimezone=strftime("%z", localtime());
    my $server_time=get_date( );

	
	my $clock;
	if( abs( Time::Piece->strptime($server_time,  "%Y-%m-%d %T") - Time::Piece->strptime($device_time, "%Y-%m-%d %T") )>1 ) {
		$clock='NOK';
	} else {
		$clock='OK';
	}
	my $dyear,$dmonth,$dday,$dhour,$dmin,$dsec;
	$dyear=hex("$DT[0]$DT[1]")-$year;
	$dmonth=hex($DT[2])-$mon;
	$dday=hex($DT[3])-$mday;
	$dhour=hex($DT[4])-$hour;
	$dmin=hex($DT[5])-$min;
	$dsec=hex($DT[6])-$sec;

	$code="snmpget -v 3 -a $Cfg->{snmpapro} -u $Cfg->{snmpuser} -A $Cfg->{snmpap} -x $Cfg->{snmppro} -X $Cfg->{snmppk} -l $Cfg->{snmplevel} -r 2 -t 5 -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.4.2.1.5.1 2>/dev/null | cut -d ' ' -f 2 ";
	my $srv1interval=qx( $code );
	chomp( $srv1interval );
	
	$code="snmpget -v 3 -a $Cfg->{snmpapro} -u $Cfg->{snmpuser} -A $Cfg->{snmpap} -x $Cfg->{snmppro} -X $Cfg->{snmppk} -l $Cfg->{snmplevel} -r 2 -t 5 -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.4.2.1.5.2 2>/dev/null | cut -d ' ' -f 2";
	my $srv2interval=qx( $code );
	chomp( $srv2interval );

	$code="snmpget -v 3 -a $Cfg->{snmpapro} -u $Cfg->{snmpuser} -A $Cfg->{snmpap} -x $Cfg->{snmppro} -X $Cfg->{snmppk} -l $Cfg->{snmplevel} -r 2 -t 5 -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.4.1.1.8.1 2>/dev/null | cut -d ' ' -f 2";
	my $multicastinterval=qx( $code );
	chomp( $multicastinterval );
	
	
	AppendFile( $outfile, "$ne_name,$IP,$server_time TZ:$stimezone,$device_time TZ:$timezone,$dyear,$dmonth,$dday,$dhour,$dmin,$dsec,$clock,$srv1interval,$srv2interval,$multicastinterval\n" ) ;

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
