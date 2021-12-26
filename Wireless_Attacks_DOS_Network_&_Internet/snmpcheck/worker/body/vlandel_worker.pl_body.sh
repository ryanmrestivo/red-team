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

if [ $vlanidstop'a' == 'a' ]
then
vlanidstop=$vlanidstart
fi

ne_name=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.1.1.1.3.1 2>/dev/null | cut -d '"' -f 2`
if [ $ne_name'a' != 'a' ]
then
snmpwalk -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -On $IP .1.3.6.1.4.1.119.2.3.69.501.5.20.5.1.3 2>/dev/null > raw_vlan.list

while read rawvlaninfo
do
nevlanid=`echo $rawvlaninfo | cut -d '.' -f 18 | cut -d ' ' -f 1`
nevlanname=`echo $rawvlaninfo | cut -d '"' -f 2`
if (( $vlanidstart <= $nevlanid && $vlanidstop >= $nevlanid ))
then
result=`snmpset -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.20.5.1.4.$nevlanid i 6 2>/dev/null | cut -d ' ' -f 2`
result1=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.20.5.1.4.$nevlanid 2>1 | cut -d ' ' -f 2`

if [ $result1'a' == '1a' ]
then
echo $ne_name','$IP','$nevlanid','$nevlanname',VLAN cannot be deleted,ERROR' >> $logfile
fi

if [ $result$result1'a' == '6Sucha' ]
then
echo $ne_name','$IP','$nevlanid','$nevlanname',VLAN deleted successfully,COMPLETED' >> $logfile
fi

if [ $result1'a' = 'a' ]
then
echo $ne_name','$IP','$nevlanid','$nevlanname',Timeout,ERROR' >> $logfile
fi

fi

if [ $vlanidstart$vlanidstop$allvlan'a' = 'ona' ]
then
result=`snmpset -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.20.5.1.4.$nevlanid i 6 2>/dev/null | cut -d ' ' -f 2`
result1=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.20.5.1.4.$nevlanid 2>1 | cut -d ' ' -f 2`

if [ $result1'a' == '1a' ]
then
echo $ne_name','$IP','$nevlanid','$nevlanname',VLAN cannot be deleted,ERROR' >> $logfile
fi

if [ $result$result1'a' == '6Sucha' ]
then
echo $ne_name','$IP','$nevlanid','$nevlanname',VLAN deleted successfully,COMPLETED' >> $logfile
fi

if [ $result1'a' = 'a' ]
then
echo $ne_name','$IP','$nevlanid','$nevlanname',Timeout,ERROR' >> $logfile
fi

fi

if [ $vlanidstart$vlanidstop$allvlan'a' = 'ona' ]
then
currcount=$nevlanid
else
currcount=$(( nevlanid - vlanidstart ))
fi


done <raw_vlan.list



else
echo $ne_name','$IP',, inaccessible,, FATAL' >> $logfile
error=1
fi


####
rm -rf $tmp
exit $error