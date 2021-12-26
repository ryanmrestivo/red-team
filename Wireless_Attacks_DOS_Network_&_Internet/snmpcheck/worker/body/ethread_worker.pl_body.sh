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

ne_type=`echo $accessible | cut -d ' ' -f 2`


ne_name=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.1.1.1.3.1 2>/dev/null | cut -d '"' -f 2`

if [ $adminstatus'a' == 'disa' ]
then
snmpwalk -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -On $IP .1.3.6.1.4.1.119.2.3.69.501.5.30.1.1.8 | grep 'INTEGER: 1' | cut -d '.' -f 18 | cut -d ' ' -f 1 > portlist.txt
elif [ $adminstatus'a' == 'enaa' ]
then
snmpwalk -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -On $IP .1.3.6.1.4.1.119.2.3.69.501.5.30.1.1.8 | grep 'INTEGER: 2' | cut -d '.' -f 18 | cut -d ' ' -f 1 > portlist.txt
elif [ $adminstatus'a' == 'anya' ]
then
snmpwalk -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -On $IP .1.3.6.1.4.1.119.2.3.69.501.5.30.1.1.8 | cut -d '.' -f 18 | cut -d ' ' -f 1 > portlist.txt
fi

femtu=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.30.2.1.3.1 | cut -d ' ' -f 2`
gemtu=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.30.2.1.4.1 | cut -d ' ' -f 2`

maxcurr=`cat portlist.txt | wc -l`
currcount=0
while read portid
do
error=0
slot=$(( portid / 8388608 - 1 ))
port=$(( (portid - (slot+1)*8388608)/65536))

porttype=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.30.1.1.3.$portid | cut -d ' ' -f 2`
if [ $porttype'a' == 'a' ]
then
error=1
porttype='unknown'
elif [ $porttype'a' == '0a' ]
then
porttype='invalid'
elif [ $porttype'a' == '1a' ]
then
porttype='fiber'

if (( $ne_type == 100 )) || (( $ne_type == 200 )) || (( $ne_type == 450 ))
then
if (( $port <= 4 )) && (( $slot == 0 ))
then
porttype='copper'
fi
else
if (( $port <= 2 ))
then
porttype='copper'
fi
fi

elif [ $porttype'a' == '2a' ]
then
porttype='copper'
fi

portname=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.30.1.1.11.$portid | cut -d '"' -f 2`

portspeed=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.30.1.1.4.$portid | cut -d ' ' -f 2`
if [ $portspeed'a' == 'a' ]
then
error=1
portspeed='unknown'
elif [ $portspeed'a' == '1a' ]
then
portspeed='auto'
elif [ $portspeed'a' == '2a' ]
then
portspeed='10 Mbps'
elif [ $portspeed'a' == '3a' ]
then
portspeed='100 Mbps'
elif [ $portspeed'a' == '4a' ]
then
portspeed='1000 Mbps'
fi


portduplex=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.30.1.1.5.$portid | cut -d ' ' -f 2`
if [ $portduplex'a' == 'a' ]
then
error=1
portduplex='unknown'
elif [ $portduplex'a' == '1a' ]
then
portduplex='half'
elif [ $portduplex'a' == '2a' ]
then
portduplex='full'
fi


portmdi=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.30.1.1.7.$portid | cut -d ' ' -f 2`
if [ $portmdi'a' == 'a' ]
then
error=1
portmdi='unknown'
elif [ $portmdi'a' == '1a' ]
then
portmdi='mdi'
elif [ $portmdi'a' == '2a' ]
then
portmdi='mdi-x'
fi

portadm=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.30.1.1.8.$portid | cut -d ' ' -f 2`
if [ $portadm'a' == 'a' ]
then
error=1
portadm='unknown'
elif [ $portadm'a' == '1a' ]
then
portadm='disabled'
elif [ $portadm'a' == '2a' ]
then
portadm='enabled'
fi

portflow=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.30.1.1.6.$portid | cut -d ' ' -f 2`
if [ $portflow'a' == 'a' ]
then
error=1
portflow='unknown'
elif [ $portflow'a' == '1a' ]
then
portflow='disabled'
elif [ $portflow'a' == '2a' ]
then
portflow='enabled'
fi

portmon=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.30.1.1.9.$portid | cut -d ' ' -f 2`
if [ $portmon'a' == 'a' ]
then
error=1
portmon='unknown'
elif [ $portmon'a' == '1a' ]
then
portmon='none'
elif [ $portmon'a' == '2a' ]
then
portmon='mirrored'
elif [ $portmon'a' == '3a' ]
then
portmon='mirror'
fi

portmond=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.30.1.1.10.$portid | cut -d ' ' -f 2`
if [ $portmond'a' == 'a' ]
then
error=1
portmond='unknown'
elif [ $portmond'a' == '1a' ]
then
portmond='ingress'
elif [ $portmond'a' == '2a' ]
then
portmond='egress'
elif [ $portmond'a' == '3a' ]
then
portmond='both'
fi


cportspeed=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.3.13.8.1.1.4.$portid | cut -d ' ' -f 2`
if [ $cportspeed'a' == 'a' ]
then
error=1
cportspeed='unknown'
cportduplex='unknown'
elif [ $cportspeed'a' == '0a' ]
then
cportspeed='invalid'
cportduplex='invalid'
elif [ $cportspeed'a' == '1a' ]
then
cportspeed='10 Mbps'
cportduplex='half'
elif [ $cportspeed'a' == '2a' ]
then
cportspeed='10 Mbps'
cportduplex='full'
elif [ $cportspeed'a' == '3a' ]
then
cportspeed='100 Mbps'
cportduplex='half'
elif [ $cportspeed'a' == '4a' ]
then
cportspeed='100 Mbps'
cportduplex='full'
elif [ $cportspeed'a' == '5a' ]
then
cportspeed='1000 Mbps'
cportduplex='full'
fi

cportmdi=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.3.13.8.1.1.6.$portid | cut -d ' ' -f 2`
if [ $cportmdi'a' == 'a' ]
then
error=1
cportmdi='unknown'
elif [ $cportmdi'a' == '0a' ]
then
cportmdi='invalid'
elif [ $cportmdi'a' == '1a' ]
then
cportmdi='mdi'
elif [ $cportmdi'a' == '2a' ]
then
cportmdi='mdi-x'
fi

cportoper=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.3.13.8.1.1.13.$portid | cut -d ' ' -f 2`
if [ $cportoper'a' == 'a' ]
then
error=1
cportoper='unknown'
elif [ $cportoper'a' == '0a' ]
then
cportoper='invalid'
elif [ $cportoper'a' == '1a' ]
then
cportoper='down'
elif [ $cportoper'a' == '2a' ]
then
cportoper='up'

# New lines for version 1.0x.xx ------------ START ----------------------

elif [ $cportoper'a' == 'Sucha' ]
then

if [ $portadm'a' == 'enableda' ]
then

linkstatus=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.3.13.8.1.1.7.$portid | cut -d ' ' -f 2`
if [ $linkstatus'a' == 'a' ]
then
error=1
cportoper='unknown'
elif [ $linkstatus'a' == '1a' ]
then
cportoper='up'
else
cportoper='down'
fi
else
cportoper='down'
fi

#New lines for version 1.0x.xx --------------- END ------------------------

else
cportoper='N/A'
fi

cportflow=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.3.13.8.1.1.5.$portid | cut -d ' ' -f 2`
if [ $cportflow'a' == 'a' ]
then
error=1
cportflow='unknown'
elif [ $cportflow'a' == '1a' ]
then
cportflow='disabled'
elif [ $cportflow'a' == '2a' ]
then
cportflow='enabled'
fi

if [ $femtu'a' == 'a' ]
then
femtu='unknown'
error=1
fi
if [ $gemtu'a' == 'a' ]
then
gemtu='unknown'
error=1
fi


if [ "$cportspeed" == "unknown" ]
then
portmtu='unknown'
elif [ "$cportspeed" == "invalid" ]
then
portmtu='invalid'
elif [ "$cportspeed" == "1000 Mbps" ]
then
portmtu=$gemtu
else
portmtu=$femtu
fi

synce=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.31.2.1.3.$portid | cut -d ' ' -f 2`
if [ $synce'a' == 'a' ]
then
synce='unknown'
error=1
elif [ $synce'a' == '0a' ]
then
synce='invalid'
elif [ $synce'a' == '1a' ]
then
synce='disabled'
elif [ $synce'a' == '2a' ]
then
synce='enabled'
elif [ $synce'a' == '3a' ]
then
synce='enabled/master'
elif [ $synce'a' == '4a' ]
then
synce='enabled/slave'
else
synce='N/A'
fi


if (( $error == 0 ))
then
Result='COMPLETED'
else
Result='ERROR'
fi

echo $ne_name','$IP','$Result','$slot','$port','$portname','$portmtu','$portadm','$cportoper','$porttype','$portspeed','$cportspeed','$portduplex','$cportduplex','$portmdi','$cportmdi','$portflow','$cportflow','$synce','$portmon','$portmond >> $logfile


done < portlist.txt


else
 echo $ne_name','$IP',FATAL' >> $logfile
 error=1
fi

####
rm -rf $tmp
exit $error

