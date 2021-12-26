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
agingsnmp=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.27.1.1.6.1 2>/dev/null | cut -d ' ' -f 2`
if [ $agingsnmp'a' == 'a' ]
then
error=1
aging='unknown'
elif [ $agingsnmp'a' == '1a' ]
then
aging='Off'
elif [ $agingsnmp'a' == '2a' ]
then
aging='On'
else
aging='N/A'
fi


agingtime=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.27.1.1.5.1 2>/dev/null | cut -d ' ' -f 2`
if [ $agingtime'a' == 'a' ]
then
error=1
agingtime='unknown'
fi


mtugbe=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.30.2.1.4.1 2>/dev/null | cut -d ' ' -f 2`
if [ $mtugbe'a' == 'a' ]
then
error=1
mtugbe='unknown'
fi

mtufe=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.30.2.1.3.1 2>/dev/null | cut -d ' ' -f 2`
if [ $mtufe'a' == 'a' ]
then
error=1
mtufe='unknown'
fi

vlanmodesnm=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.20.1.1.3.1 2>/dev/null | cut -d ' ' -f 2`
if [ $vlanmodesnm'a' == 'a' ]
then
error=1
vlanmode='unknown'
elif [ $vlanmodesnm'a' == '1a' ]
then
vlanmode='802.1Q'
elif [ $vlanmodesnm'a' == '2a' ]
then
vlanmode='802.1ad'
else
vlanmode='N/A'
fi

defvlan=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.20.1.1.4.1 2>/dev/null | cut -d ' ' -f 2`
if [ $defvlan'a' == 'a' ]
then
error=1
defvlan='unknown'
fi

deftpidsnmp=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.20.1.1.5.1 2>/dev/null | cut -d ' ' -f 2-3`
if [ "$deftpidsnmp"'a' == 'a' ]
then
error=1
deftpid='unknown'
else
deftpid1=`echo $deftpidsnmp | cut -d ' ' -f 1`
deftpid2=`echo $deftpidsnmp | cut -d ' ' -f 2`
deftpid='0x'$deftpid1$deftpid2
fi



#---------------------------------------------------------------------------------------------------

if (( $error == 1))
then
result='ERROR'
else
result='COMPLETED'
fi


echo $ne_name','$IP','$ne_type','$result','$aging','$agingtime','$mtugbe','$mtufe','$vlanmode','$defvlan','$deftpid >> $logfile

else
 echo ','$IP',,INACCESSIBLE' >> $logfile
 error=1
fi

####
rm -rf $tmp
exit $error


