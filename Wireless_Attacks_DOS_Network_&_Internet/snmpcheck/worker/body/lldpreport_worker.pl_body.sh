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

maxcurr=100


accessible=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r 2 -t 3 -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.1.1.1.11.1 2>/dev/null`
lengthaccessible=${#accessible}
if (($lengthaccessible != 0))
then

error=0
ne_name=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.1.1.1.3.1 2>/dev/null | cut -d '"' -f 2`
ne_type=`echo $accessible | cut -d ' ' -f 2`


snmpwalk -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -On $IP .1.3.6.1.4.1.119.2.3.69.5.3.15.3.1.3 | cut -d '.' -f 18 | cut -d ' ' -f 1 > portlist.txt

snmpwalk -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -On $IP .1.3.6.1.4.1.119.2.3.69.501.5.30.1.1.3 2>/dev/null | cut -d '.' -f 18 | cut -d ' ' -f 1 >> portlist.txt
portlist=`cat portlist.txt | wc -l`


if (( $portlist > 0 ))
then

i=0

while read portid
do

error=0

if [ $portid'a' == 'a' ]
then
error=1
slot='unknown'
port='unknown'
elif (( $portid > 30 )) && (( $portid < 33 ))
then
slot=''

if (( $portid == 31 ))
then
port='NMS'
elif (( $portid == 32 ))
then
port='NE1'
fi

lldpena=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.0.8802.1.1.2.1.1.6.1.2.$portid 2>/dev/null | cut -d ' ' -f 2`
if [ $lldpena'a' == 'a' ]
then
lldpenatxt='unknown'
error=1
elif [ $lldpena'a' == '1a' ]
then
lldpenatxt='Tx only'
elif [ $lldpena'a' == '2a' ]
then
lldpenatxt='Rx only'
elif [ $lldpena'a' == '3a' ]
then
lldpenatxt='used'
elif [ $lldpena'a' == '4a' ]
then
lldpenatxt='not used'
fi

lldpmac=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.15.3.1.6.$portid 2>/dev/null | cut -d ' ' -f 2`
if [ $lldpmac'a' == 'a' ]
then
lldpmactxt='unknown'
error=1
elif [ $lldpmac'a' == '1a' ]
then
lldpmactxt='Standard'
elif [ $lldpmac'a' == '2a' ]
then
lldpmactxt='Proprietary'
fi

portsts=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.6.7.1.1.3.$portid 2>/dev/null | cut -d ' ' -f 2`

if [ $portsts'a' == 'a' ]
then
portststxt='unknown'
error=1
elif [ $portsts'a' == '1a' ]
then
portststxt='Link up'
elif [ $portsts'a' == '2a' ]
then
portststxt='Link down'
fi


elif (( $portid > 8388608 ))
then
slot=$(( portid / 8388608 - 1 ))
port=$(( (portid - (slot+1)*8388608)/65536))

lldpena=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.0.8802.1.1.2.1.1.6.1.2.$portid 2>/dev/null | cut -d ' ' -f 2`
if [ $lldpena'a' == 'a' ]
then
lldpenatxt='unknown'
error=1
elif [ $lldpena'a' == '1a' ]
then
lldpenatxt='Tx only'
elif [ $lldpena'a' == '2a' ]
then
lldpenatxt='Rx only'
elif [ $lldpena'a' == '3a' ]
then
lldpenatxt='used'
elif [ $lldpena'a' == '4a' ]
then
lldpenatxt='not used'
fi

lldpmac=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.15.3.1.6.$portid 2>/dev/null | cut -d ' ' -f 2`
if [ $lldpmac'a' == 'a' ]
then
lldpmactxt='unknown'
error=1
elif [ $lldpmac'a' == '1a' ]
then
lldpmactxt='Standard'
elif [ $lldpmac'a' == '2a' ]
then
lldpmactxt='Proprietary'
fi

portsts=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.3.13.8.1.1.13.$portid 2>/dev/null | cut -d ' ' -f 2`

if [ $portsts'a' == 'a' ]
then
portststxt='unknown'
error=1
elif [ $portsts'a' == '1a' ]
then
portststxt='Link down'
elif [ $portsts'a' == '2a' ]
then
portststxt='Link up'
fi


fi

if (( $error == 1))
then
result='ERROR'
else
result='COMPLETED'
fi


echo $ne_name','$IP','$ne_type','$result','$slot','$port','$lldpenatxt','$lldpmactxt','$portststxt >> $logfile

i=$((i+1))

maxcurr=$portlist

done < portlist.txt


else
echo $ne_name','$IP','$ne_type',FATAL' >> $logfile
fi

else
 echo ','$IP',,INACCESSIBLE' >> $logfile
 error=1
fi


####
rm -rf $tmp
exit $error

