#!/usr/bin/perl
# korolev-ia [at] yandex.ru
# version 1.2 2016.04.10
use lib "/home/nems/client_persist/htdocs/bulktool4/lib" ;
use lib 'C:\GIT\snmpcheck\lib' ;
use lib "/opt/snmpcheck/lib" ;
use lib "../lib" ;
use lib "../../lib" ;

use COMMON_ENV;
use File::Basename;

use Getopt::Long;
use threads;
use threads::shared;

GetOptions (
        'json=s' => \$json_file,
        "help|h|?"  => \$help ) or show_help();

unless( -f $json_file ) {
	show_help();
	exit 1;
}


my $row;
my $json_text=ReadFile( $json_file );

my $Param =JSON->new->utf8->decode($json_text);
my $val_param=JSON->new->utf8->decode($Param->{param});

my $Cfg=ReadConfig();


my $outfile="$Paths->{OUTFILE_DIR}/$val_param->{sname}_".generate_filename()."_$Param->{id}_log.csv";
if( 1==$val_param->{task_start_type} ) { # if cron
	$outfile="$Paths->{OUTFILE_DIR}/$val_param->{sname}_".generate_filename()."_$Param->{id}_cron_$Param->{crontaskid}_log.csv";
}

my $json_out="$Paths->{JSON}/$Param->{id}.out.json";
my $timenow=time();

# by default body have name depend of worker name. obsolete
my $body_sh=dirname($0)."/body/$Param->{worker}_body.sh";
if( $Param->{worker_body} ) {
	my $b=$Param->{worker_body}; # absolute path
	if( $b=~/^\// and -f $b and -x $b ) {
		$body_sh=$b ;
	}
	$b=dirname($0)."/body/$Param->{worker_body}";
	if( -f $b and -x $b ) { # relative path. Must be in '$Paths->{WORKER_DIR}/body' 
		$body_sh=$b ;
	}
}


unless ( -f $body_sh  && -x $body_sh ) {
		write_out_json( 5, "Cannot execute worker body file $body_sh" , 0 );
		exit 1;
}

######### header of worker output table 
my @AA=split( /\s/, $Param->{export_param} );
my $export_param=join( ' ', map{ "$_='$val_param->{$_}' " } @AA )  ;
WriteFile( $outfile, "$Param->{table_header}\n" ) ;
######### header of worker output table 

my @IPs=get_ip_list( $val_param );
my $count_max=$#IPs+1 ; #
my $count=0;
my $error=0;

## for threads
share($count);
share($error);
##



my $uniqfile="$Param->{sname}.$Param->{id}.".time();
my @threads;
my $worker_threads=$val_param->{worker_threads} || 1 ;

foreach $t ( 1..$worker_threads ) {
  push @threads, threads->create(\&worker_thread, $t, \$count);
  sleep 1;
}

foreach $t (@threads) {
  $t->join();
}



my $body;
foreach( 0..$#IPs ) {
	$body='';
	my $tmp_outfile="$Paths->{TMP_DIR}/$uniqfile.out.$_.csv";
	my $body=ReadFile( $tmp_outfile );
	AppendFile( $outfile, $body );
	unlink( $tmp_outfile );
}

######### bottom of worker output table 
AppendFile( $outfile, "End of the report\n");
######### bottom of worker output table 

#######################################
########## we say to task manager thats task finished

write_out_json( 4, $error ? "Finished successfully with $error errors.":'Finished successfully', 100, $outfile );

#######################################

exit 0;

  
sub show_help {
print STDOUT "Usage: $0  --json='JSON_FILE' [ --help ]
Sample:
$0  --json='/tmp/123.json'
";
}


sub worker_thread {
	my $th=shift;
	
	while( 1 ) {
		my $result_of_exec, $code ;
		return 1 if( $count >= $count_max ) ;
		my $tmp_outfile="$Paths->{TMP_DIR}/$uniqfile.out.$count.csv";
		my $IP=@IPs[ $count++ ];

		# timeout for working worker_body.sh set to 1200 sec (20 min)
		$code="timeout 1200 $body_sh $Paths->{config.ini} $IP $tmp_outfile $export_param >/dev/null 2>&1";
		$result_of_exec=system( $code );
		#print "$th $result_of_exec\n";
		if( 0 < $result_of_exec ) {
			$error++;
		}
		if( 512==$result_of_exec ) {
			w2log( "Incorrect parameters with script: $code" );
		}
		if( time() - $timenow  > 15 || 0==$count ) {
			write_out_json( 3, 'Task running. All ok.', int( $count*100/$count_max ) );
		}
	}
}

sub write_out_json {
		my $status=shift;
		my $mess=shift;
		my $progress=shift;
		my $outfile=shift;
		my $row;	
		$timenow=time();
		$row->{sdt}=$timenow;
		$row->{status}=$status; # running
		$row->{id}=$Param->{id};
		$row->{mess}=$mess;
		$row->{progress}=$progress;  
		$row->{outfile}=basename( $outfile ) if( $outfile );  
		my $coder = JSON::XS->new->utf8->pretty->allow_nonref; # bugs with JSON module and threads. we need use JSON::XS
		my $json = $coder->encode ($row);

		unless( WriteFile( $json_out, $json ) ){
				w2log ("Cannot write file $json_file: $!");
				return 0;
		}
	return 1;
}

