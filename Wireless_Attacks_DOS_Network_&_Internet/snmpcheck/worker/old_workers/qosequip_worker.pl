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
Que_num queset profnum proselect delpro actpro ent1cf ent1cp ent1cip ent2cf ent2cp ent2cip ent3cf ent3cp ent3cip ent4cf ent4cp ent4cip ent5cf ent5cp ent5cip ent6cf ent6cp ent6cip ent7cf ent7cp ent7cip ent8cf ent8cp ent8cip ent9cf ent9cp ent9cip ent10cf ent10cp ent10cip ent11cf ent11cp ent11cip ent12cf ent12cp ent12cip ent13cf ent13cp ent13cip ent14cf ent14cp ent14cip ent15cf ent15cp ent15cip ent16cf ent16cp ent16cip ent17cf ent17cp ent17cip ent18cf ent18cp ent18cip ent19cf ent19cp ent19cip ent20cf ent20cp ent20cip ent21cf ent21cp ent21cip ent22cf ent22cp ent22cip ent23cf ent23cp ent23cip ent24cf ent24cp ent24cip ent25cf ent25cp ent25cip ent26cf ent26cp ent26cip ent27cf ent27cp ent27cip ent28cf ent28cp ent28cip ent29cf ent29cp ent29cip ent30cf ent30cp ent30cip ent31cf ent31cp ent31cip ent32cf ent32cp ent32cip ent33cf ent33cp ent33cip ent34cf ent34cp ent34cip ent35cf ent35cp ent35cip ent36cf ent36cp ent36cip ent37cf ent37cp ent37cip ent38cf ent38cp ent38cip ent39cf ent39cp ent39cip ent40cf ent40cp ent40cip ent41cf ent41cp ent41cip ent42cf ent42cp ent42cip ent43cf ent43cp ent43cip ent44cf ent44cp ent44cip ent45cf ent45cp ent45cip ent46cf ent46cp ent46cip ent47cf ent47cp ent47cip ent48cf ent48cp ent48cip ent49cf ent49cp ent49cip ent50cf ent50cp ent50cip ent51cf ent51cp ent51cip ent52cf ent52cp ent52cip ent53cf ent53cp ent53cip ent54cf ent54cp ent54cip ent55cf ent55cp ent55cip ent56cf ent56cp ent56cip ent57cf ent57cp ent57cip ent58cf ent58cp ent58cip ent59cf ent59cp ent59cip ent60cf ent60cp ent60cip ent61cf ent61cp ent61cip ent62cf ent62cp ent62cip ent63cf ent63cp ent63cip ent64cf ent64cp ent64cip
) ;
my $export_param=join( ' ', map{ "$_='$ip_param->{$_}' " } @AA )  ;
WriteFile( $outfile, "NE name,NE IP,operation description,Result,Profile number,Entry number\n" ) ;
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
	#w2log( $code );
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
