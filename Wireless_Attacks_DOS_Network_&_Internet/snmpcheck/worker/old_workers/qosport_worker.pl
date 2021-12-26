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
my @AA=qw( 
Que_num queset modemport modemset modemscheduler modemschedulermode modemdefportprio modemdropmode minterprioallow fakename0 fakename1 fakename2 fakename3 fakename4 fakename5 fakename6 fakename7 modeminternalpri0 modeminternalpri1 modeminternalpri2 modeminternalpri3 modeminternalpri4 modeminternalpri5 modeminternalpri6 modeminternalpri7 mdwrrallow mdwrr0 mql0 mqs0 mdwrr1 mql1 mqs1 mdwrr2 mql2 mqs2 mdwrr3 mql3 mqs3 mwtdallow mwtdy0 mwredg0 mwredy0 mwtdy1 mwredg1 mwredy1 mwtdy2 mwredg2 mwredy2 mwtdy3 mwredg3 mwredy3 ethernetset ethernetscheduler esps0 ethernetschedulermode ethernetdefportprio ethernetdropmode einterprioallow fakename0 fakename1 fakename2 fakename3 fakename4 fakename5 fakename6 fakename7 ethernetinternalpri0 ethernetinternalpri1 ethernetinternalpri2 ethernetinternalpri3 ethernetinternalpri4 ethernetinternalpri5 ethernetinternalpri6 ethernetinternalpri7 edwrrallow edwrr0 eql0 eqs0 edwrr1 eql1 eqs1 edwrr2 eql2 eqs2 edwrr3 eql3 eqs3 ewtdallow ewtdy0 ewredg0 ewredy0 ewtdy1 ewredg1 ewredy1 ewtdy2 ewredg2 ewredy2 ewtdy3 ewredg3 ewredy3
) ;
my $export_param=join( ' ', map{ "$_='$ip_param->{$_}' " } @AA )  ;
WriteFile( $outfile, "NE name,NE IP,Operation,Result,Type,Slot,Port\n" ) ;
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
	$code="$body_sh $Paths->{config.ini} $IP $outfile $export_param >/dev/null 2>&1 ";
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
