#!/usr/bin/perl
# korolev-ia [at] yandex.ru
# version 1.2 2016.04.22
use lib "/home/nems/client_persist/htdocs/bulktool4/lib" ;
use lib "C:\GIT\snmpcheck\lib" ;
use lib "/opt/snmpcheck/lib" ;
use lib "../lib" ;
use lib "../../lib" ;

use COMMON_ENV;
use File::Basename;
use Getopt::Long;
use DateTime::Cron::Simple;

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
# check the finished tasks
update_tasks($dbh);

$table='crontasks';

cron_tasks( $dbh );

db_disconnect( $dbh );

exit 0;



sub cron_tasks{
	my $dbh=shift;
	my $rv;
	my $retval=1;
	my $stmt ="SELECT distinct a.* from crontasks as a, tasks as b where  a.status=3 and a.taskid not in ( select id from tasks where status in ( 1, 2, 3 ) )  ;
	# or ( a.status=3 and b.id=a.taskid and b.status in ( 4, 5, 6 ) ) ; " ;  #  only finished, failed or canceled tasks
	#my $stmt ="SELECT distinct a.* from crontasks as a, tasks as b where ( a.status=3 and a.taskid=0 ) or ( a.status=3 and b.id=a.taskid and b.status in ( 4, 5, 6 ) ) ; " ;  #  only finished, failed or canceled tasks
	#my $stmt ="SELECT * from crontasks where status=3; " ;  # select only running crontabs

	my $sth = $dbh->prepare( $stmt );	
	unless ( $rv = $sth->execute( ) || $rv < 0 ) {
		w2log( "Sql ($stmt) Someting wrong with database  : $DBI::errstr"  );
		return 0;
	}
	while (my $row = $sth->fetchrow_hashref) { 
		my $cron = DateTime::Cron::Simple->new( $row->{cron} );
		if ($cron->validate_time) {
			my $nrow;			
			$nrow->{id}=GetNextSequence( $dbh ) ;
			$nrow->{sname}=$row->{sname} ;
			$nrow->{login}=$row->{login} ;
			$nrow->{param}=$row->{param};
			$nrow->{crontaskid}=$row->{id};
			$nrow->{worker_threads}=$row->{worker_threads};
			$nrow->{status}=1 ; # added
			$nrow->{mess}='' ;

			$nrow->{dt}=time() ;
			$nrow->{sdt}=$nrow->{dt} ;
			$nrow->{pdt}=$nrow->{dt} ; # planed time of starting task. there can be inserted future time
			$nrow->{desc}=$row->{desc}." $row->{id} ".get_date() ;
			
			my $mrow;
			$mrow->{taskid}=$nrow->{id};
			$mrow->{sdt}=$nrow->{dt};
		
			if ( InsertRecord ( $dbh, $nrow->{id}, 'tasks', $nrow ) && UpdateRecord ( $dbh, $row->{id}, 'crontasks', $mrow )) {				
				w2log( "Cron: user '$nrow->{login}' add task '$nrow->{desc}' for worker '$row->{sname}'. Parameters: $nrow->{param}" );
			} else {
				w2log( "Error: Cron: cannot add task : '$nrow->{desc}' for worker '$row->{sname}'. Parameters: $nrow->{param}" );
				$retval=0;
			}			
		}	
	}
	
	return $retval;
}



  
sub show_help {
print STDOUT "Crontab task starter. Add planed tasks from table 'crontasks' in to table 'tasks'. Can be start from command line or from cron
Usage: $0 [ --help ]
";
}