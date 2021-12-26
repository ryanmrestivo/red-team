#!/usr/bin/perl

BEGIN{ unshift @INC, '$ENV{SITE_ROOT}/cgi-bin' ,'C:\GIT\snmpcheck\html\cgi-bin', '/opt/snmpcheck/html/cgi-bin'; } 
use COMMON_ENV;

use Getopt::Long;


GetOptions (
        'json=s' => \$json_file,
        "help|h|?"  => \$help ) or show_help();



unless(  -f $json ) {
	print STDERR "File not found $json: $!" ;
	show_help();
	exit 1;
}


my $json_text=ReadFile( $json);
my $row = JSON->new->utf8->decode($json_text) ;		

$dbh=db_connect() ;
update_task_status( $dbh, $row );
db_disconnect( $dbh );
 

exit 0;
 
  
sub show_help {
print STDOUT "Usage: $0  --json='JSON_FILE' [ --help ]
Sample:
$0  --json='/tmp/123.json'
";
}