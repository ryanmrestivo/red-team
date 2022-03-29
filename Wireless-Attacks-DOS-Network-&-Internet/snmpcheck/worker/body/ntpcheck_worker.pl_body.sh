#!/bin/bash

read_param() {
shift
shift
shift
for var in "$@"
do
	export "$var"
done
}

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

read_param "$@"

tmp=/tmp/worker.$$
mkdir $tmp
cd $tmp
error=0

###########

templogfile="$tmp/templogfile.txt"

accessible=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.1.1.1.11.1 2>/dev/null`
lengthaccessible=${#accessible}
if (($lengthaccessible != 0))
then
ne_name=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.1.1.1.3.1 2>/dev/null | cut -d '"' -f 2`

snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.6.1.1.1.3.1 2>/dev/null | cut -d '"' -f 2-1000 > ntpstat.txt
i=0
ntps='NOT CONFIGURED'
ntpok=0
ntpentry=0
while read line
do
i=$((i+1))
if (( $i >= 3 ))
then
if [ "$line"'a' != 'a' ]
then

ntpstatus=`echo $line | cut -b 1`
if [ $ntpstatus'a' == '*a' ]
then
ntpstatus='Selected'
ntpentry=1
ntpok=1
startchar=2
elif [ $ntpstatus'a' == '+a' ]
then
ntpstatus='Candidate'
ntpentry=1
ntpok=1
startchar=2
else
ntpstatus='Configured'
ntpentry=1
startchar=1
fi
newline=`echo $line | cut -b $startchar-1000`
ntpserver=`echo $newline | cut -d ' ' -f 1`
ntpserverref=`echo $newline | cut -d ' ' -f 2`
stratum=`echo $newline | cut -d ' ' -f 3`
t=`echo $newline | cut -d ' ' -f 4`
when=`echo $newline | cut -d ' ' -f 5`
poll=`echo $newline | cut -d ' ' -f 6`
reach=`echo $newline | cut -d ' ' -f 7`
delay=`echo $newline | cut -d ' ' -f 8`
offset=`echo $newline | cut -d ' ' -f 9`
jitter=`echo $newline | cut -d ' ' -f 10`
echo $ne_name','$IP','$ntpstatus','$ntpserver','$ntpserverref','$stratum','$t','$when','$poll','$reach','$delay','$offset','$jitter >> $templogfile

fi
fi
done < ntpstat.txt



if (( $ntpentry == 0 ))
then
echo $ne_name','$IP',NOT CONFIGURED' >> $logfile
else
if (( $ntpok == 0 ))
then
ntps='NOT WORKING'
else
ntps='WORKING'
fi

while read templine
do
templine1=`echo $templine | cut -d ',' -f 1-2`
templine2=`echo $templine | cut -d ',' -f 3-100`
echo $templine1','$ntps','$templine2 >> $logfile
done < $templogfile
fi


else
echo ','$IP',FATAL' >> $logfile
fi

####
rm -rf $tmp
exit $error

