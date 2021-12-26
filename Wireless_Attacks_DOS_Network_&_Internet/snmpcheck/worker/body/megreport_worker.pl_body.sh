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
###########


accessible=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r 2 -t 3 -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.1.1.1.11.1 2>/dev/null`
lengthaccessible=${#accessible}
if (($lengthaccessible != 0))
then

error=0
ne_name=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.1.1.1.3.1 2>/dev/null | cut -d '"' -f 2`
ne_type=`echo $accessible | cut -d ' ' -f 2`

#---------------------------------------------------------------------------------------------------
snmpwalk -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -On $IP .1.3.6.1.4.1.119.2.3.69.501.5.24.1.1.6 2>/dev/null | cut -d '.' -f 18 | cut -d ' ' -f 1 > meglist.txt

while read megindex
do

if [ $megindex'a' != 'a' ]
then

errorint=0
maintname=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.24.1.1.3.$megindex 2>/dev/null | cut -d '"' -f 2`
if [ $maintname'a' == 'a' ]
then
errorint=1
maintname='unknown'
fi

shortname=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.24.1.1.7.$megindex 2>/dev/null | cut -d '"' -f 2`
if [ $shortname'a' == 'a' ]
then
errorint=1
shortname='unknown'
fi


meglevel=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.24.1.1.4.$megindex 2>/dev/null | cut -d ' ' -f 2`
if [ $meglevel'a' == 'a' ]
then
errorint=1
meglevel='unknown'
fi


ccmsnmp=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.24.1.1.8.$megindex 2>/dev/null | cut -d ' ' -f 2`
if [ $ccmsnmp'a' == 'a' ]
then
errorint=1
ccm='unknown'
elif [ $ccmsnmp'a' == '1a' ]
then
ccm='disabled'
elif [ $ccmsnmp'a' == '2a' ]
then
ccm='enabled'
else
ccm='N/A'
fi

ccperiodsnmp=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.24.1.1.5.$megindex 2>/dev/null | cut -d ' ' -f 2`
if [ $ccperiodsnmp'a' == 'a' ]
then
errorint=1
ccperiod='unknown'
elif [ $ccperiodsnmp'a' == '1a' ]
then
ccperiod='3.3 [ms]'
elif [ $ccperiodsnmp'a' == '2a' ]
then
ccperiod='10 [ms]'
elif [ $ccperiodsnmp'a' == '3a' ]
then
ccperiod='100 [ms]'
elif [ $ccperiodsnmp'a' == '4a' ]
then
ccperiod='1 [s]'
elif [ $ccperiodsnmp'a' == '5a' ]
then
ccperiod='10 [s]'
elif [ $ccperiodsnmp'a' == '6a' ]
then
ccperiod='60 [s]'
else
ccperiod='N/A'
fi

ccmprio=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.24.1.1.9.$megindex 2>/dev/null | cut -d ' ' -f 2`
if [ $ccmprio'a' == 'a' ]
then
errorint=1
ccmprio='unknown'
fi


if [ $errorint'a' == '1a' ]
then
result='ERROR'
else
result='COMPLETED'
fi

echo $ne_name','$IP','$ne_type','$result','$megindex','$maintname','$shortname','$meglevel','$ccm','$ccperiod','$ccmprio >> $logfile

else
echo $ne_name','$IP','$ne_type',COMPLETED,No MEG configured' >> $logfile
fi

if [ $errorint'a' == '1a' ]
then
error=1
fi

done < meglist.txt


#---------------------------------------------------------------------------------------------------



else
 echo ','$IP',,INACCESSIBLE' >> $logfile
 error=1
fi

####
rm -rf $tmp
exit $error


