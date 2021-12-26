#!/bin/bash
CONFIG=$1
IP=$2
logfile=$3

if [ -z ${CONFIG+x} ]; then 
	exit 2
fi
if [ -z ${IP+x} ]; then 
	exit 2
fi
if [ -z ${logfile+x} ]; then 
	exit 2
fi



. $CONFIG


tmp=/tmp/worker.$$
mkdir $tmp
cd $tmp
error=0

accessible=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r 2 -t 3 -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.1.1.1.11.1 2>/dev/null`
lengthaccessible=${#accessible}
if (($lengthaccessible != 0))
then
ne_type=`echo $accessible | cut -d ' ' -f 2`

ne_name=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.1.1.1.3.1 2>/dev/null | cut -d '"' -f 2`

qosmode=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r 2 -t 3 -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.1.1.5.1  2>/dev/null | cut -d ' ' -f 2`
if [ $qosmode'a' == 'a' ]
then
qosmode='unknown'
error=1
elif (( $qosmode == 0 ))
then
qosmode='invalid'
elif (( $qosmode == 1 ))
then
qosmode='equipment'
elif (( $qosmode == 2 ))
then
qosmode='port'
elif (( $qosmode == 3 ))
then
qosmode='vlan'
fi

qosactiveprofile=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r 2 -t 3 -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.1.1.3.1  2>/dev/null | cut -d ' ' -f 2`
if [ $qosactiveprofile'a' == 'a' ]
then
qosactiveprofile='unknown'
error=1
fi

quenumber=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r 2 -t 3 -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.1.1.4.1  2>/dev/null | cut -d ' ' -f 2`
if [ $quenumber'a' == 'a' ]
then
quenumber='unknown'
error=1
elif [ $quenumber'a' == '0a' ]
then
quenumber='invalid'
elif [ $quenumber'a' == '1a' ]
then
quenumber=4
elif [ $quenumber'a' == '2a' ]
then
quenumber=8
fi

i=1
while (( $i <= 3 ))
do

ii=1
while (( $ii <= 64 ))
do


entact=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r 2 -t 3 -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.2.1.7.$i.$ii 2>/dev/null | cut -d ' ' -f 2`
if [ $entact'a' == 'a' ]
then
classfield='unknown'
classprio='unknown'
interprio='unknown'
error=1
elif [ $entact'a' == 'Sucha' ]
then
classfield='empty'
classprio='empty'
interprio='empty'
else

classfield=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r 2 -t 3 -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.2.1.4.$i.$ii 2>/dev/null | cut -d ' ' -f 2`
if [ $classfield'a' == 'a' ]
then
classfield='unknown'
error=1
elif (( $classfield == -1 ))
then
classfield='unused'
elif (( $classfield == 1 ))
then
classfield='VlanCos'
elif (( $classfield == 2 ))
then
classfield='IPv4precedence'
elif (( $classfield == 3 ))
then
classfield='IPv4DSCP'
elif (( $classfield == 4 ))
then
classfield='IPv6DSCP'
elif (( $classfield == 5 ))
then
classfield='MPLS_EXP'
elif (( $classfield == 10 ))
then
classfield='Other'
fi

classprio=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r 2 -t 3 -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.2.1.5.$i.$ii 2>/dev/null | cut -d ' ' -f 2`
if [ $classprio'a' == 'a' ]
then
classprio='unknown'
error=1
elif (( $classprio == -1 ))
then
classprio='unused'
fi

interprio=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r 2 -t 3 -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.2.1.6.$i.$ii 2>/dev/null | cut -d ' ' -f 2`
if [ $interprio'a' == 'a' ]
then
interprio='unknown'
error=1
elif (( $interprio == -1 ))
then
interprio='unused'
fi


fi


if (( $error == 0 ))
then
result='COMPLETED'
else
result='ERROR'
fi

if [ $qosmode != 'equipment' ]
then
result='MISMATCH'
else
if [ $classfield'a' == 'emptya' ]
then
result='EMPTY'
fi
fi

if (( $i == $qosactiveprofile ))
then
profilestatus='active'
else
profilestatus='passive'
fi

echo $ne_name','$ne_type','$IP','$result','$qosmode','$quenumber','$qosactiveprofile','$i','$profilestatus','$ii','$classfield','$classprio','$interprio >> $logfile

ii=$(( ii + 1 ))

currcount=$(( currcount + 1 ))

done

i=$(( i + 1 ))

done


else
 echo $ne_name','$ne_type','$IP',FATAL,inaccessble' >> $logfile
 error=1
fi



####
rm -rf $tmp
exit $error

