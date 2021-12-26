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

accessible=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.1.1.1.11.1 2>/dev/null`
lengthaccessible=${#accessible}
ne_type=''
if (($lengthaccessible != 0))
then
ne_name=''
ne_type=`echo $accessible | cut -d ' ' -f 2`
ne_name=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.1.1.1.3.1 2>/dev/null | cut -d '"' -f 2`

error=0

if [ $gbemtuallow'a' == '1a' ]
then

gbemtuset=`snmpset -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.30.2.1.4.1 i $gbemtu 2>/dev/null | cut -d ' ' -f 2`

if [ $gbemtu'a' == $gbemtuset'a' ]
then
operation='GbE MTU was set to '$gbemtu
result='COMPLETED'
else
operation='GbE MTU set to '$gbemtu' was unsuccessful'
result='ERROR'
error=1
fi

else
operation='GbE MTU set was not allowed'
result='SKIPPED'
fi
echo $ne_name','$IP','$ne_type','$operation','$result >>$logfile



if [ $femtuallow'a' == '1a' ]
then


femtuset=`snmpset -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.30.2.1.3.1 i $femtu 2>/dev/null | cut -d ' ' -f 2`

if [ $femtu'a' == $femtuset'a' ]
then
operation='FE MTU was set to '$femtu
result='COMPLETED'
else
operation='FE MTU set to '$femtu' was unsuccessful'
result='ERROR'
error=1
fi


else
operation='FE MTU set was not allowed'
result='SKIPPED'
fi
echo $ne_name','$IP','$ne_type','$operation','$result >>$logfile

else
 echo $ne_name','$IP',,Inaccessible,FATAL' >>$logfile
 error=1
fi

####
rm -rf $tmp
exit $error
