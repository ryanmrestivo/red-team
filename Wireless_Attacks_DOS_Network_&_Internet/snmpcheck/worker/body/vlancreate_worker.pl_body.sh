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
if [ $ne_name'a' != 'a' ]
then

nevlanname=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.20.5.1.3.$vlanid 2>/dev/null | cut -d '"' -f 2`

if [ "$nevlanname"'a' == "No Such Instance currently exists at this OIDa" ]
then

if [ $createvlan'a' == 'ona' ]
then

result=`snmpset -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.20.5.1.3.$vlanid s "$vlanname" .1.3.6.1.4.1.119.2.3.69.501.5.20.5.1.4.$vlanid i 4 2>/dev/null | grep INTEGER | cut -d ' ' -f 2`

if [ $result'a' != 'a' ]
then
echo $ne_name','$IP','$vlanid','$vlanname',successfully created with VLAN name '$vlanname',COMPLETED' >> $logfile
else
echo $ne_name','$IP','$vlanid','$vlanname',cannot be created with VLAN name '$vlanname',ERROR' >> $logfile
error=1
fi
else
echo $ne_name','$IP','$vlanid','$vlanname',does not exists and did not created,NO PERMISSION' >> $logfile
fi
else

if [ "$nevlanname"'a' == "$vlanname"'a' ]
then
echo $ne_name','$IP','$vlanid','$vlanname',exist with same name ('$vlanname') nothing to do ,SKIPPED' >> $logfile
else
result=`snmpset -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.20.5.1.3.$vlanid s "$vlanname" | cut -d '"' -f 2`
if [ "$result"'a' == "$vlanname"'a' ]
then
echo $ne_name','$IP','$vlanid','$vlanname',successfully renamed from '$nevlanname' to '$vlanname' ,COMPLETED' >> $logfile
else
echo $ne_name','$IP','$vlanid','$vlanname',cannot be renamed from '$nevlanname' to '$vlanname' ,ERROR' >> $logfile
error=1
fi
fi
fi


else
echo $ne_name','$IP',, inaccessible,, FATAL' >> $logfile
error=1
fi

####
rm -rf $tmp
exit $error
