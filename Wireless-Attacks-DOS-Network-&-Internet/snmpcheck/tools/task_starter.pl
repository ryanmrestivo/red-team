#!/usr/bin/perl
# korolev-ia [at] yandex.ru
# version 1.1 2016.04.11
use lib "/home/nems/client_persist/htdocs/bulktool4/lib" ;
use lib "C:\GIT\snmpcheck\lib" ;
use lib "/opt/snmpcheck/lib" ;
use lib "../lib" ;
use lib "../../lib" ;

use COMMON_ENV;
use File::Basename;
use Getopt::Long;


GetOptions ( "help|h|?"  => \$help );
if( $help ) {
	show_help();
	exit 1;
}


######## check if there do not finished porcess
my $basename=basename($0);
my $pid_file="$Paths->{PID_DIR}/$basename.pid";
my $process_timeout=600;
if( -f $pid_file ) {
	my ($pid,$pid_dt)=split( ',',ReadFile( $pid_file ));
	$pid=~s/\s//gm;
	# check if previrous process do not finished yet
	my $cmd="ps -p $pid -o comm= | grep $basename";
	if( 0==system($cmd) ) {
		w2log( "Previrous $0 process do not finished yet" );
			if( $pid_dt+$timeout < time() ){
				# try to kill the timeouted process
				if( kill('-KILL', $pid ) ) {
					w2log( "Kill the process $basename with pid $pis by timeout reasone" );					
					unlink ( $pid_file );
				} else {
					w2log( "Cannot to kill the process $basename with pid $pis by timeout reasone." );
					exit (1);
				}
			}
		exit 0;
	}
	# we do not found the process. the pid may be do not removed by any reasones
	# we will go 
}





		
		
$dbh=db_connect() ;

$table='tasks';

start_tasks( $dbh );

db_disconnect( $dbh );

exit 0;



sub start_tasks{
	my $dbh=shift;
	my $stmt ="SELECT a.*,b.worker,b.export_param,b.worker_body,b.table_header from tasks as a, snmpworker as b where a.status=? and a.pdt < ? and a.sname=b.sname; " ;  # select only added(planed) task   
	my $sth = $dbh->prepare( $stmt );
	my $dt=time();
	my $mess='';
	unless ( $rv = $sth->execute( 1, $dt ) || $rv < 0 ) {
		message2 ( "Someting wrong with database  : $DBI::errstr" );
		w2log( "Sql ($stmt) Someting wrong with database  : $DBI::errstr"  );
		return 0;
	}

	while (my $row = $sth->fetchrow_hashref) {
		my $json_text=JSON->new->utf8->encode( $row ) ;
		my $json_file="$Paths->{JSON}/$row->{id}.param.json";
		unless( WriteFile( $json_file, $json_text ) ){
				$mess="Cannot start task with id $row->{id}, becouse cannot write file $json_file: $!";
				$nrow->{status}=5 ; # failed				
				$nrow->{mess}=$mess ;
				$nrow->{sdt}=time() ;
				$nrow->{progress}=0 ;
				$nrow->{id}=$row->{id} ;
				update_task_status(  $dbh , $nrow );
				w2log( $mess );
				next;
		};	
		# start
		my $mylog=( $Paths->{WORKER_LOG} eq '/dev/null' )?'/dev/null':"$Paths->{WORKER_LOG}.$row->{id}.log";
		my $cmd="$Paths->{WORKER_DIR}/$row->{worker} --json=$json_file >> $mylog 2>&1 &" ;
		w2log ( "Start the worker : $cmd " );
		# we don't check the status of task, we only start the cmd
		system( "$cmd" ) ;
		

		my $nrow;
		$mess="Task with id $row->{id} started";
		$nrow->{status}=2 ; # started
		$nrow->{mess}=$mess ;
		$nrow->{sdt}=time() ;
		$nrow->{progress}=0 ;
		$nrow->{id}=$row->{id} ;

		update_task_status(  $dbh , $nrow );
	}		
}




 
  
sub show_help {
print STDOUT "Task starter. Can be start from command line or from cron
Usage: $0 [ --help ]
";
}