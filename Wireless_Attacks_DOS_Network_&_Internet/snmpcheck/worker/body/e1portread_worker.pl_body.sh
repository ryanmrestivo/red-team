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
ne_type=`echo $accessible | cut -d ' ' -f 2`


ne_name=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.1.1.1.3.1 2>/dev/null | cut -d '"' -f 2`


#-------------------------------------------------------------------------------------------------------------------------


snmpwalk -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -On $IP .1.3.6.1.4.1.119.2.3.69.501.5.3.1.1.4 2>/dev/null | grep -v 'INTEGER: 0' | grep INTEGER | cut -d '.' -f 18 | cut -d ' ' -f 1 > portid.list

maxcurr=`cat portid.list | wc -l`

while read portid
do
error=0
slot=$(( portid / 8388608 - 1))
port=$(( (portid - (slot+1)*8388608) / 65536))
channel=$(( (portid - (slot+1)*8388608) - port*65536))

portnamehexorig=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.3.1.1.3.$portid 2>/dev/null`

if [ $portnamehexorig'a' == 'a' ]
then
error=1
portname='unknown'
else
stringtype=`echo $portnamehexorig | cut -b 1-11`

if [ $stringtype'a' == 'Hex-STRING:a' ]
then
portnamehex=`echo $portnamehexorig | cut -d ':' -f 2`
namelength=${#portnamehex}
namelength=$((namelength-1))
i=1
acthexname=''
while (( $i < $namelength ))
do
actchar=`echo $portnamehex | cut -b $i-$((i+1))`
if [ $actchar'a' != '00a' ]
then
acthexname=$acthexname'\x'$actchar
fi
i=$((i+3))
done
portname=`echo -e $acthexname`
else
portname=`echo $portnamehexorig | cut -d '"' -f 2`
fi
fi

----------------------------------------------------------

chusage=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.3.1.1.4.$portid 2>/dev/null | cut -d ' ' -f 2`
if [ $chusage'a' == 'a' ]
then
chusages='unknonw'
error=1
elif [ $chusage'a' == '1a' ]
then
chusages='Not Used'
elif [ $chusage'a' == '2a' ]
then
chusages='Used'
else
chusages='N/A'
fi

chreport=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.3.1.1.5.$portid 2>/dev/null | cut -d ' ' -f 2`
if [ $chreport'a' == 'a' ]
then
chreports='unknonw'
error=1
elif [ $chreport'a' == '1a' ]
then
chreports='Not Report'
elif [ $chreport'a' == '2a' ]
then
chreports='Report'
else
chreports='N/A'
fi


impedance=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.3.1.1.6.$portid 2>/dev/null | cut -d ' ' -f 2`
if [ $impedance'a' == 'a' ]
then
impedances='unknonw'
error=1
elif [ $impedance'a' == '1a' ]
then
impedances='120 ohm'
elif [ $impedance'a' == '2a' ]
then
impedances='75 ohm'
else
impedances='N/A'
fi


#-------------------------------------------------------------------------------------------------------------------

if (( $error == 0 ))
then
result='COMPLETED'
else
result='ERROR'
fi
currcount=$(( currcount + 1 ))
echo $ne_name','$ne_type','$IP','$result','$slot','$port','$channel','$portname','$chusages','$chreports','$impedances >> $logfile
done < portid.list



else
 echo ','$ne_type','$IP',FATAL,inaccessble' >> $logfile
 error=1
fi

####
rm -rf $tmp
exit $error

