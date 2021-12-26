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
if (($lengthaccessible != 0))
then

error=0
year=`date +%-Y`
month=`date +%-m`
day=`date +%-d`
hour=`date +%-k`
min=`date +%-M`
sec=`date +%-S`
timezone=`date +%z`
firstchar=`echo $timezone | cut -b 1`
timezonehour=`echo $timezone | cut -b 2-3`
timezonemin=`echo $timezone | cut -b 4-5`
if [ $firstchar == '+' ]
then
firsttz='2B'
else
firsttz='2D'
fi
printf -v htimezonehour "%02x" "$timezonehour"
printf -v htimezonemin "%02x" "$timezonemin"
printf -v hyear "%04x" "$year"
printf -v hmonth "%02x" "$month"
printf -v hday "%02x" "$day"
printf -v hhour "%02x" "$hour"
printf -v hmin "%02x" "$min"
printf -v hsec "%02x" "$sec"

readok=1

if [ $tzmanualallow'a' == '1a' ]
then
timetext='ONLY timezone'
#echo "snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r 2 -t 10 -Ov $IP 1.3.6.1.4.1.119.2.3.69.5.1.3.1.1.3.1 2>/dev/null | cut -d ' ' -f 2-100"
netime=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r 2 -t 10 -Ov $IP 1.3.6.1.4.1.119.2.3.69.5.1.3.1.1.3.1 2>/dev/null | cut -d ' ' -f 2-100`

firsttz=$tzmanual
timezonehour=''
timezonemin=''
if [ "$netime"'a' == 'a' ]
then
readok=0
else
hy1=`echo $netime | cut -d ' ' -f 1`
hy2=`echo $netime | cut -d ' ' -f 2`
hyear=$hy1$hy2
hmonth=`echo $netime | cut -d ' ' -f 3`
hday=`echo $netime | cut -d ' ' -f 4`
hhour=`echo $netime | cut -d ' ' -f 5`
hmin=`echo $netime | cut -d ' ' -f 6`
hsec=`echo $netime | cut -d ' ' -f 7`
fi
else
timetext='time'
fi

hexstring=$hyear$hmonth$hday$hhour$hmin$hsec'00'$firsttz$timezonehour$timezonemin
ne_name=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.1.1.1.3.1 2>/dev/null | cut -d '"' -f 2`

if (( $readok == 1 ))
then
result=`snmpset -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r 2 -t 10 -Ov $IP 1.3.6.1.4.1.119.2.3.69.5.1.3.1.1.3.1 x $hexstring 2>/dev/null`
else
result=''
fi

r=${#result}
if (($r == 0))
then
echo $ne_name','$IP',time set failed,ERROR' >>$logfile
error=1
else
echo $ne_name','$IP','$timetext' set successful,COMPLETED' >>$logfile
fi

else
 echo $ne_name','$IP',Inaccessible,ERROR' >>$logfile
 error=1
fi



####
rm -rf $tmp
exit $error

