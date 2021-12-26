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

ne_name=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.1.1.1.3.1 2>/dev/null | cut -d '"' -f 2`
if [ $ne_name'a' == 'a' ]
then
echo $ne_name','$IP',inaccessible<BR>'
echo $ne_name','$IP',inaccessible,,FATAL' >> $logfile
else
result=`snmpset -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r 2 -t 5 -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.4.1.1.3.1 i 1 2>/dev/null | cut -d ' ' -f 2`
if [ $result'a' == 1'a' ]
then
echo $ne_name','$IP',NTP service stop,,COMPLETED' >> $logfile
else
echo $ne_name','$IP',NTP service stop,,ERROR' >> $logfile
error=1
fi
result1=`snmpset -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.4.2.1.3.1 a $ntp1 2>/dev/null | cut -b 11-50`
pollres1=`snmpset -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.4.2.1.5.1 i $ntp1_poll 2>/dev/null | cut -d ' ' -f 2`
if [ $result1'a' == $ntp1'a' ] && [ $pollres1'a' == $ntp1_poll'a' ]
then
echo $ne_name','$IP',ntp server1 address is set to '$ntp1',ntp server1 polling period is set to '$ntp1_poll',COMPLETED' >> $logfile
else
echo $ne_name','$IP',ntp server1 address or polling period set,,ERROR' >> $logfile
error=1
fi
result2=`snmpset -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.4.2.1.3.2 a $ntp2 2>/dev/null | cut -b 11-50`
pollres2=`snmpset -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.4.2.1.5.2 i $ntp2_poll 2>/dev/null | cut -d ' ' -f 2`

if [ $result2'a' == $ntp2'a' ] && [ $pollres2'a' == $ntp2_poll'a' ]
then
echo $ne_name','$IP',ntp server2 address is set to '$ntp2',ntp server2 polling period is set to '$ntp2_poll',COMPLETED' >> $logfile
else
echo $ne_name','$IP',ntp server2 address or polling period set,,ERROR' >> $logfile
error=1
fi

result3=`snmpset -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.4.2.1.3.3 a $ntp3 2>/dev/null | cut -b 11-50`
pollres3=`snmpset -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.4.2.1.5.3 i $ntp3_poll 2>/dev/null | cut -d ' ' -f 2`

if [ $result3'a' == $ntp3'a' ] && [ $pollres3'a' == $ntp3_poll'a' ]
then
echo $ne_name','$IP',ntp server3 address is set to '$ntp3',ntp server2 polling period is set to '$ntp3_poll',COMPLETED' >> $logfile
else
echo $ne_name','$IP',ntp server3 address or polling period set,,ERROR' >> $logfile
error=1
fi

result4=`snmpset -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.4.2.1.3.4 a $ntp4 2>/dev/null | cut -b 11-50`
pollres4=`snmpset -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.4.2.1.5.4 i $ntp4_poll 2>/dev/null | cut -d ' ' -f 2`
if [ $result4'a' == $ntp4'a' ] && [ $pollres4'a' == $ntp4_poll'a' ]
then
echo $ne_name','$IP',ntp server4 address is set to '$ntp4',ntp server2 polling period is set to '$ntp4_poll',COMPLETED' >> $logfile
else
echo $ne_name','$IP',ntp server4 address or polling period set,,ERROR' >> $logfile
error=1
fi

result5=`snmpset -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r 2 -t 10 -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.4.1.1.3.1 i 2 2>/dev/null | cut -d ' ' -f 2`
#result5=2
if [ $result5'a' == 2'a' ]
then
echo $ne_name','$IP',NTP service start,,COMPLETED' >> $logfile
else
echo $ne_name','$IP',NTP service start,,ERROR' >> $logfile
error=1
fi

fi

####
rm -rf $tmp
exit $error