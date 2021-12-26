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

accessible=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r 2 -t 3 -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.1.1.1.11.1 2>/dev/null`
lengthaccessible=${#accessible}
if (($lengthaccessible != 0))
then

error=0
ne_name=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.1.1.1.3.1 2>/dev/null | cut -d '"' -f 2`
result=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r 2 -t 5 -Ov $IP 1.3.6.1.4.1.119.2.3.69.5.1.3.1.1.3.1 2>/dev/null | cut -b 13-100`
r=${#result}
if (($r == 0))
then
error=1
else
syear=`date +%-Y`
smonth=`date +%-m`
sday=`date +%-d`
shour=`date +%-k`
smin=`date +%-M`
ssec=`date +%-S`

fsyear=`echo $syear | cut -b 1`
fsmonth=`echo $smonth | cut -b 1`
fsday=`echo $sday | cut -b 1`
fshour=`echo $shour | cut -b 1`
fsmin=`echo $smin | cut -b 1`
fssec=`echo $ssec | cut -b 1`
if [ $fsyear == '0 ' ]
then
syear=`echo $syear | cut -b 2`
fi
if [ $fsmonth == '0' ]
then
smonth=`echo $smonth | cut -b 2`
fi
if [ $fsday == '0' ]
then
sday=`echo $sday | cut -b 2`
fi
if [ $fshour == '0' ]
then
shour=`echo $shour | cut -b 2`
fi
if [ $fsmin == '0' ]
then
smin=`echo $smin | cut -b 2`
fi
if [ $fssec == '0' ]
then
ssec=`echo $ssec | cut -b 2`
fi

stimezone=`date +%z`
hyear=`echo $result | cut -d ' ' -f 1``echo $result | cut -d ' ' -f 2`
hmonth=`echo $result | cut -d ' ' -f 3`
hday=`echo $result | cut -d ' ' -f 4`
hhour=`echo $result | cut -d ' ' -f 5`
hmin=`echo $result | cut -d ' ' -f 6`
hsec=`echo $result | cut -d ' ' -f 7`
htimezonesign=`echo $result | cut -d ' ' -f 9`
htimezone=`echo $result | cut -d ' ' -f 10`
printf -v year '%d' 0x$hyear
printf -v month '%d' 0x$hmonth
printf -v day '%d' 0x$hday
printf -v hour '%d' 0x$hhour
printf -v min '%d' 0x$hmin
printf -v sec '%d' 0x$hsec
printf -v timezone '%d' 0x$htimezone
if [ $htimezonesign == '2B' ]
then
timezonesign='+'
else
timezonesign='-'
fi
timezonelength=${#timezone}
if [ $timezonelength == '1' ]
then
timezone='0'$timezone
fi
timezone=$timezone'00'
timezone=$timezonesign$timezone
dyear=$(( $syear-$year ))
dmonth=$(( $smonth-$month ))
dday=$(( $sday-$day ))
dhour=$(( $shour-$hour ))
dmin=$(( $smin-$min ))
dsec=$(( $ssec-$sec ))
dsec1=$dsec
dmin1=$dmin
if (( $dsec == 1 ))
then
dsec1=0
fi
if (( $dsec == -59 ))
then
if (( $dmin == 1 ))
then
dsec1=0
dmin1=0
fi
fi
if (( $dsec == -1 ))
then
dsec1=0
fi
if (( $dsec == 59 ))
then
if (( $dmin == -1 ))
then
dsec1=0
dmin1=0
fi
fi
difference=$dyear$dmonth$dday$dhour$dmin1$dsec1
if [ $difference == '000000' ]
then
clock='OK'
else
clock='NOK'
fi

srv1interval=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r 2 -t 5 -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.4.2.1.5.1 2>/dev/null | cut -d ' ' -f 2`
srv2interval=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r 2 -t 5 -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.4.2.1.5.2 2>/dev/null | cut -d ' ' -f 2`
multicastinterval=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r 2 -t 5 -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.4.1.1.8.1 2>/dev/null | cut -d ' ' -f 2`


echo $ne_name','$IP','$syear'-'$smonth'-'$sday' '$shour':'$smin':'$ssec' TZ:'$stimezone','$year'-'$month'-'$day' '$hour':'$min':'$sec' TZ:'$timezone','$dyear','$dmonth','$dday','$dhour','$dmin','$dsec','$clock','$srv1interval','$srv2interval','$multicastinterval >> $logfile
fi
else
 echo ','$IP',,,,,,,,,INACCESSIBLE' >> $logfile
 error=1
fi

####
rm -rf $tmp
exit $error
