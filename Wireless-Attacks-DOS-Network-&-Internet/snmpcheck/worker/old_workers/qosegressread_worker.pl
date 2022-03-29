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
WriteFile( $outfile, "NE name,NE type,IP,Result,Number of queues,Card type,Slot,Port,Port name,QoS mode,Port classification mode,Scheduler,Drop mode,Port shaper [Mbps],P0,P1,P2,P3,P4,P5,P6,P7,Q0 speed,Q1 speed,Q2 speed,Q3 speed,Q4 speed,Q5 speed,Q6 speed,Q7 speed,Q0 length,Q1 length,Q2 length,Q3 length,Q4 length,Q5 length,Q6 length,Q7 length,Q0 weight,Q1 weight,Q2 weight,Q3 weight,Q4 weight,Q5 weight,Q6 weight,Q7 weight,Q0 WTDY,Q1 WTDY,Q2 WTDY,Q3 WTDY,Q4 WTDY,Q5 WTDY,Q6 WTDY,Q7 WTDY,Q0 WREDG,Q1 WREDG,Q2 WREDG,Q3 WREDG,Q4 WREDG,Q5 WREDG,Q6 WREDG,Q7 WREDG,Q0 WREDY,Q1 WREDY,Q2 WREDY,Q3 WREDY,Q4 WREDY,Q5 WREDY,Q6 WREDY,Q7 WREDY,\n" ) ;
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

my $code, $result_of_exec;
my $body_sh=dirname($0)."/body/".basename($0)."_body.sh";
if( -f $body_sh  && -x $body_sh ) {
	$code="$body_sh $Paths->{config.ini} $IP $outfile >/dev/null 2>&1 ";
	$result_of_exec=system( $code );
} else {
	w2log( "Cannot to start worker body file $body_sh" );
	last;
}
if( 1==$result_of_exec ) {
	$error++;
}
if( 2==$result_of_exec ) {
	w2log( "Incorrect parameters with script: $code" );
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
