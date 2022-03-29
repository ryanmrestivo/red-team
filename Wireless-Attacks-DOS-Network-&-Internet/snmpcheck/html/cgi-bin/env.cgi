#!/usr/bin/perl
# korolev-ia [at] yandex.ru
# version 1.0 2016.03.18
use lib "C:\GIT\snmpcheck\lib" ;
use lib "/opt/snmpcheck/lib" ;
use lib "../lib" ;
use lib "../../lib" ;

print "Content-type: text/html

" ;

print "<html><table>\n";
foreach( sort keys(%ENV) ) {
	print "<tr><td>$_<td>$ENV{$_}";
}
