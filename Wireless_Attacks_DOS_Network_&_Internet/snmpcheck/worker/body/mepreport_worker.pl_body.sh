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
snmpwalk -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -On $IP .1.3.6.1.4.1.119.2.3.69.501.5.24.3.1.16 2>/dev/null | cut -d '.' -f 18 | cut -d ' ' -f 1 > meplist.txt

maxcurr=`cat meplist.txt | wc -l`

while read mepindex
do
errorint=0
if [ $mepindex'a' != 'a' ]
then

portid=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.24.3.1.3.$mepindex 2>/dev/null | cut -d ' ' -f 2`

if [ $portid'a' != 'a' ]
then

slot=$(( portid / 8388608 - 1 ))
port=$(( (portid - (slot+1)*8388608)/65536))


module=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.4.1.1.3.$((slot+1)) 2>/dev/null | cut -d ' ' -f 2`
if [ $module'a' == 'a' ]
then
modules='unknown'
errorint=1
else
if (( $module == 2 ))
then
modules='Modem A'
elif (( $module == 3 ))
then
modules='16 E1'
elif (( $module == 6 ))
then
modules='Gbe A'
elif (( $module == 9 ))
then
modules='MSE'
elif (( $module == 11 ))
then
modules='AUX'
elif (( $module == 12 ))
then
modules='STM1 2 port'
elif (( $module == 14 ))
then
modules='PS'
elif (( $module == 15 ))
then
modules='FAN'
elif (( $module == 17 ))
then
modules='MC'
elif (( $module == 18 ))
then
modules='PTP'
elif (( $module == 19 ))
then
modules='Modem EA'
fi
fi

else
errorint=1
slot='unknown'
port='unknown'
modules='unknonw'
fi

mepid=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.24.3.1.7.$mepindex 2>/dev/null | cut -d ' ' -f 2`
if [ $mepid'a' == 'a' ]
then
errorint=1
mepid='unknown'
fi

vlanid=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.24.3.1.4.$mepindex 2>/dev/null | cut -d ' ' -f 2`
if [ $vlanid'a' == 'a' ]
then
errorint=1
vlanid='unknown'
fi


megindex=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.24.3.1.5.$mepindex 2>/dev/null | cut -d ' ' -f 2`
if [ $megindex'a' == 'a' ]
then
errorint=1
megindex='unknown'
fi


peermep=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.24.4.1.4.$mepindex 2>/dev/null | cut -d ' ' -f 2`
if [ $peermep'a' == 'a' ]
then
errorint=1
peermep='unknown'
elif [ $peermep'a' == 'Sucha' ]
then
peermep=''
fi


if (( $errorint == 1))
then
result='ERROR'
else
result='COMPLETED'
fi

echo $ne_name','$IP','$ne_tpye','$result','$mepindex','$mepid','$modules','$slot','$port','$vlanid','$megindex','$peermep >> $logfile

else
echo $ne_name','$IP','$ne_tpye',COMPLETED,NO MEP configured' >>$logfile
fi

if (( $errorint == 1 ))
then
error=1
fi


done < meplist.txt

#---------------------------------------------------------------------------------------------------


else
 echo ','$IP',,INACCESSIBLE' >> $logfile
 error=1
fi

####
rm -rf $tmp
exit $error



