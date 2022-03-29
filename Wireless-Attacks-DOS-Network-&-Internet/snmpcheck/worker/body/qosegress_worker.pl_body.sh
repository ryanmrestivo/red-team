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



if (( $Que_num == 1 ))
then
quenum=4
else
quenum=8
fi


ne_name=''
result=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.1.1.13.0 2>/dev/null | cut -d ' ' -f 2`
error=0
if [ $result'a' != 'a' ]
then
ne_name=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.1.1.1.3.1 2>/dev/null | cut -d '"' -f 2`




if [ $queset'a' == 'ona' ]
then
result=`snmpset -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r 2 -t 10 -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.1.1.4.1 i $Que_num 2>/dev/null | cut -d ' ' -f 2`
if [ $result'a' == $Que_num'a' ]
then
echo $ne_name','$IP',Number of queue set to '$quenum' successfully,COMPLETED' >> $logfile
fi
else
echo $ne_name','$IP',Number of queue set to '$quenum' was not allowed,SKIPPED' >> $logfile
fi
result=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.1.1.4.1 2>/dev/null | cut -d ' ' -f 2`
if [ $result'a' == $Que_num'a' ]
then

snmpwalk -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -On $IP .1.3.6.1.4.1.119.2.3.69.501.4.2.1.16 2>/dev/null | cut -d '.' -f 17 | grep INTEGER | cut -d ' ' -f 1 > modem.list
snmpwalk -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t$snmpt -On $IP .1.3.6.1.4.1.119.2.3.69.501.5.30.1.1.3 2>/dev/null | cut -d '.' -f 18 | grep INTEGER | cut -d ' ' -f 1 > Ethernet.list
snmpwalk -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -On $IP .1.3.6.1.4.1.119.2.3.69.501.5.38.1.1.8 2>/dev/null | cut -d '.' -f 18 | grep INTEGER | cut -d ' ' -f 1 > laglist.list

rm -rf lagportlist.list 2>/dev/null
touch lagportlist.list
while read lagid
do
i=9
while (( $i <= 16 ))
do
portid=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.38.1.1.$i.$lagid 2>/dev/null | cut -d ' ' -f 2`
if [ $portid'a' != '0a' ] && [ $lagid'a' != 'a' ]
then
echo $portid >> lagportlist.list
fi
i=$(( i + 1 ))
done
done < laglist.list
rm -rf modem1.list 2>/dev/null
touch modem1.list
while read modemid
do
lagorrta=`cat lagportlist.list | grep $modemid | wc -l`
if (( $lagorrta == 0 ))
then
echo $modemid >> modem1.list
fi
done < modem.list

rm -rf Ethernet1.list
touch Ethernet1.list
while read ethid
do
lagorrta=`cat lagportlist.list | grep $ethid | wc -l`
if (( $lagorrta == 0 ))
then
echo $ethid >> Ethernet1.list
fi
done < Ethernet.list

while read lagid
do
if (( $lagid < 4194304 ))
then
echo $lagid >> Ethernet1.list
else
echo $lagid >> modem1.list
fi
done < laglist.list

# Modem section

if [ $modemset'a' == 'a' ] && [ $modemport'a' == 'a' ]
then
echo $ne_name','$IP',Modem set was not allowed,SKIPPED,modem' >> $logfile
else

if [ $modemport'a' != 'a' ]
then
if (( $modemport < 100 ))
then
portid=$(( (modemport + 1) * 8388608 + 65536 ))
portids='modem'$modemport
else
portid=$(( ( modemport - 100 + 64 ) * 65536 ))
portids='RTA'$(( modemport - 100 ))
fi
portok=`cat modem1.list | grep $portid | wc -l`
if (( $portok == 1 ))
then
echo $portid > modem1.list
else
rm -rf modem1.list 2>/dev/null
touch modem1.list
echo $ne_name','$IP','$portids' was given but no such port,SKIPPED,modem' >> $logfile
fi
fi

maxcurr=$(( `cat modem1.list | wc -l` * ( 2 + 8 + quenum * 6  ) ))

while read portid
do
error=0
if (( $portid < 8388608 ))
then
slot='RTA'
port=$(( (portid / 65536) - 64 ))
else
slot=$(( portid / 8388608 - 1 ))
port=$(( (portid - (slot+1)*8388608)/65536))
fi

# Scheduler setting
if (( $modemscheduler == 0 ))
then
echo $ne_name','$IP',Scheduler value was empty,SKIPPED,modem,'$slot','$port >> $logfile
else
result=`snmpset -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.5.1.3.$portid i $modemscheduler 2>/dev/null | cut -d ' ' -f 2`
if [ $result'a' == $modemscheduler'a' ]
then
echo $ne_name','$IP',Scheduler set to '$modemscheduler' was successful,COMPLETED,modem,'$slot','$port >> $logfile
elif [ $result'a' != $modemscheduler'a' ]
then
echo $ne_name','$IP',Scheduler set to '$modemscheduler' was unsuccessful,ERROR,modem,'$slot','$port >> $logfile
error=1
fi
fi

#Drop mode set

if (( $modemdropmode == 0 ))
then
echo $ne_name','$IP',Drop mode value was empty,SKIPPED,modem,'$slot','$port >> $logfile
else
result=`snmpset -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.5.1.4.$portid i $modemdropmode 2>/dev/null | cut -d ' ' -f 2`
if [ $result'a' == $modemdropmode'a' ]
then
echo $ne_name','$IP',Drop mode set to '$modemdropmode' was successful,COMPLETED,modem,'$slot','$port >> $logfile
elif [ $result'a' != $modemdropmode'a' ]
then
echo $ne_name','$IP',Drop mode set to '$modemdropmode' was unsuccessful,ERROR,modem,'$slot','$port >> $logfile
error=1
fi
fi



#Internal priority setting

if [ $minterprioallow'a' == 'ona' ]
then
i=0
while (( $i < 8 ))
do
eval iprio=\$modeminternalpri$i
result=`snmpset -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.5.1.$(( i + 5 )).$portid i $iprio 2>/dev/null | cut -d ' ' -f 2`
if [ $result'a' == $iprio'a' ]
then
echo $ne_name','$IP',internal priority '$iprio' mapping to queue '$i' was successful,COMPLETED,modem,'$slot','$port >> $logfile
elif [ $result'a' != $iprio'a' ]
then
echo $ne_name','$IP',internal priority '$iprio' mapping to queue '$i' was unsuccessful,ERROR,modem,'$slot','$port >> $logfile
error=1
fi
i=$(( i + 1 ))
done
else
echo $ne_name','$IP',internal priority mapping to queue set was not allowed,SKIPPED,modem,'$slot','$port >> $logfile
fi

# DWRR, Queue length and shaper set

if [ $mdwrrallow'a' == 'ona' ]
then

i=1
while (( $i <= $quenum ))
do
eval dwrr=\$mdwrr$(( i - 1 ))
result=`snmpset -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.6.1.6.$portid.$i i $dwrr 2>/dev/null | cut -d ' ' -f 2`
if [ $result'a' == $dwrr'a' ]
then
echo $ne_name','$IP',DWRR weight was set to '$dwrr' on queue '$(( i - 1 ))',COMPLETED,modem,'$slot','$port >> $logfile
elif [ $result'a' != $dwrr'a' ]
then
echo $ne_name','$IP',DWRR weight was not set to '$dwrr' on queue '$(( i - 1 ))',ERROR,modem,'$slot','$port >> $logfile
error=1
fi
i=$(( i + 1 ))
done

i=1
while (( $i <= $quenum ))
do
eval mql=\$mql$(( i - 1 ))
result=`snmpset -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.6.1.7.$portid.$i i $mql 2>/dev/null | cut -d ' ' -f 2`
if [ $result'a' == $mql'a' ]
then
echo $ne_name','$IP',Queue size was set to '$mql' on queue '$(( i - 1 ))',COMPLETED,modem,'$slot','$port >> $logfile
elif [ $result'a' != $dwrr'a' ]
then
echo $ne_name','$IP',Queue size was not set to '$mql' on queue '$(( i - 1 ))',ERROR,modem,'$slot','$port >> $logfile
error=1
fi
i=$(( i + 1 ))
done

i=1
while (( $i <= $quenum ))
do
eval mqs=\$mqs$(( i - 1 ))
if [ $mqs'a' == 'a' ]
then
echo $ne_name','$IP',Queue shaper value was empty,SKIPPED,modem,'$slot','$port >> $logfile
else
result=`snmpset -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.6.1.4.$portid.$i i $mqs 2>/dev/null | cut -d ' ' -f 2`
if [ $result'a' == $mqs'a' ]
then
echo $ne_name','$IP',Queue shaper was set to '$mqs' on queue '$(( i - 1 ))',COMPLETED,modem,'$slot','$port >> $logfile
elif [ $result'a' != $dwrr'a' ]
then
echo $ne_name','$IP',Queue shaper not was set to '$mqs' on queue '$(( i - 1 ))',ERROR,modem,'$slot','$port >> $logfile
error=1
fi
fi
i=$(( i + 1 ))
done


else
echo $ne_name','$IP',DWRR Queue length and shaper set was not allowed,SKIPPED,modem,'$slot','$port >> $logfile
fi

# WTDY, WREDG and WREDY set

if [ $mwtdallow'a' == 'ona' ]
then

i=1
while (( $i <= $quenum ))
do
eval wtdy=\$mwtdy$(( i - 1 ))
result=`snmpset -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.6.1.8.$portid.$i i $wtdy 2>/dev/null | cut -d ' ' -f 2`
if [ $result'a' == $wtdy'a' ]
then
echo $ne_name','$IP',WTD yellow threshold was set to '$wtdy' on queue '$(( i - 1 ))',COMPLETED,modem,'$slot','$port >> $logfile
elif [ $result'a' != $wtdy'a' ]
then
echo $ne_name','$IP',WTD yellow threshold was not set to '$wtdy' on queue '$(( i - 1 ))',ERROR,modem,'$slot','$port >> $logfile
error=1
fi
i=$(( i + 1 ))
done

i=1
while (( $i <= $quenum ))
do
eval wredg=\$mwredg$(( i - 1 ))
result=`snmpset -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.6.1.10.$portid.$i i $wredg 2>/dev/null | cut -d ' ' -f 2`
if [ $result'a' == $wredg'a' ]
then
echo $ne_name','$IP',WRED green threshold was set to '$wredg' on queue '$(( i - 1 ))',COMPLETED,modem,'$slot','$port >> $logfile
elif [ $result'a' != $wtdy'a' ]
then
echo $ne_name','$IP',WRED green threshold was not set to '$wredg' on queue '$(( i - 1 ))',ERROR,modem,'$slot','$port >> $logfile
error=1
fi
i=$(( i + 1 ))
done

i=1
while (( $i <= $quenum ))
do
eval wredy=\$mwredy$(( i - 1 ))
result=`snmpset -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.6.1.9.$portid.$i i $wredy 2>/dev/null | cut -d ' ' -f 2`
if [ $result'a' == $wredy'a' ]
then
echo $ne_name','$IP',WRED yellow threshold was set to '$wredy' on queue '$(( i - 1 ))',COMPLETED,modem,'$slot','$port >> $logfile
elif [ $result'a' != $wtdy'a' ]
then
echo $ne_name','$IP',WRED yellow threshold was not set to '$wredy' on queue '$(( i - 1 ))',ERROR,modem,'$slot','$port >> $logfile
error=1
fi
i=$(( i + 1 ))
done


else
echo $ne_name','$IP',wtdy Queue length and shaper set was not allowed,SKIPPED,modem,'$slot','$port >> $logfile
fi

# ....


if (( $error == 0 ))
then
result='COMPLETED'
else
result='ERROR'
fi
done < modem1.list

fi
# Ethernet section
if [ $ethernetport'a' == 'a' ] || [ $ethernetslot'a' == 'a' ]
then
ethernetportset=''
else
ethernetportset=1
fi

if [ $ethernetset'a' == 'a' ] && [ $ethernetportset'a' == 'a' ]
then
echo $ne_name','$IP',Ethernet set was not allowed,SKIPPED,Ethernet' >> $logfile
else

if [ $ethernetportset'a' != 'a' ]
then
if (( $ethernetslot < 100 ))
then
portid=$(( ( ethernetslot + 1 ) * 8388608 + ( 65536 * ethernetport ) ))
portids='Ethernet'$ethernetslot'/'$ethernetport
else
portid=$(( ethernetport * 65536 ))
portids='LAG'$ethernetport
fi
portok=`cat Ethernet1.list | grep $portid | wc -l`
if (( $portok == 1 ))
then
echo $portid > Ethernet1.list
else
rm -rf Ethernet1.list 2>/dev/null
touch Ethernet1.list
echo $ne_name','$IP','$portids' was given but no such port,SKIPPED,Ethernet' >> $logfile
fi
fi

maxcurr1=$(( `cat Ethernet1.list | wc -l` * ( 3 + 8 + quenum * 6  ) ))

while read portid
do
error=0
if (( $portid < 4194304 ))
then
slot='LAG'
port=$(( portid / 65536 ))
else
slot=$(( portid / 8388608 - 1 ))
port=$(( (portid - (slot+1)*8388608)/65536))
fi

# Scheduler setting
if (( $ethernetscheduler == 0 ))
then
echo $ne_name','$IP',Scheduler was value was empty,SKIPPED,Ethernet,'$slot','$port >> $logfile
else
result=`snmpset -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.5.1.3.$portid i $ethernetscheduler 2>/dev/null | cut -d ' ' -f 2`
if [ $result'a' == $ethernetscheduler'a' ]
then
echo $ne_name','$IP',Scheduler set to '$ethernetscheduler' was successful,COMPLETED,Ethernet,'$slot','$port >> $logfile
elif [ $result'a' != $ethernetscheduler'a' ]
then
echo $ne_name','$IP',Scheduler set to '$ethernetscheduler' was unsuccessful,ERROR,Ethernet,'$slot','$port >> $logfile
error=1
fi
fi

#Drop mode set
if (( $ethernetdropmode == 0 ))
then
echo $ne_name','$IP',Drop mode value was empty,SKIPPED,Ethernet,'$slot','$port >> $logfile
else
result=`snmpset -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.5.1.4.$portid i $ethernetdropmode 2>/dev/null | cut -d ' ' -f 2`
if [ $result'a' == $ethernetdropmode'a' ]
then
echo $ne_name','$IP',Drop mode set to '$ethernetdropmode' was successful,COMPLETED,Ethernet,'$slot','$port >> $logfile
elif [ $result'a' != $ethernetdropmode'a' ]
then
echo $ne_name','$IP',Drop mode set to '$ethernetdropmode' was unsuccessful,ERROR,Ethernet,'$slot','$port >> $logfile
error=1
fi
fi

#Port shaper set
if [ $esps0'a' == 'a' ]
then
echo $ne_name','$IP',Port shaper value was empty,SKIPPED,Ethernet,'$slot','$port >> $logfile
else
result=`snmpset -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.5.1.13.$portid i $esps0 2>/dev/null | cut -d ' ' -f 2`
if [ $result'a' == $esps0'a' ]
then
echo $ne_name','$IP',Port shaper set to '$esps0' was successful,COMPLETED,Ethernet,'$slot','$port >> $logfile
elif [ $result'a' != $ethernetdropmode'a' ]
then
echo $ne_name','$IP',Port shaper set to '$esps0' was unsuccessful,ERROR,Ethernet,'$slot','$port >> $logfile
error=1
fi
fi


#Internal priority setting

if [ $einterprioallow'a' == 'ona' ]
then
i=0
while (( $i < 8 ))
do
eval iprio=\$ethernetinternalpri$i
result=`snmpset -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.5.1.$(( i + 5 )).$portid i $iprio 2>/dev/null | cut -d ' ' -f 2`
if [ $result'a' == 'a' ]
then
echo $ne_name','$IP',internal priority '$iprio' mapping to queue '$i' was unsuccessful,ERROR,Ethernet,'$slot','$port >> $logfile
error=1
elif [ $result'a' == $iprio'a' ]
then
echo $ne_name','$IP',internal priority '$iprio' mapping to queue '$i' was successful,COMPLETED,Ethernet,'$slot','$port >> $logfile
elif [ $result'a' != $iprio'a' ]
then
echo $ne_name','$IP',internal priority '$iprio' mapping to queue '$i' was unsuccessful,ERROR,Ethernet,'$slot','$port >> $logfile
error=1
fi
i=$(( i + 1 ))
done
else
echo $ne_name','$IP',internal priority mapping to queue set was not allowed,SKIPPED,Ethernet,'$slot','$port >> $logfile
fi

# DWRR, Queue length and shaper set

if [ $edwrrallow'a' == 'ona' ]
then

i=1
while (( $i <= $quenum ))
do
eval dwrr=\$edwrr$(( i - 1 ))
result=`snmpset -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.6.1.6.$portid.$i i $dwrr 2>/dev/null | cut -d ' ' -f 2`
if [ $result'a' == $dwrr'a' ]
then
echo $ne_name','$IP',DWRR weight was set to '$dwrr' on queue '$(( i - 1 ))',COMPLETED,Ethernet,'$slot','$port >> $logfile
elif [ $result'a' != $dwrr'a' ]
then
echo $ne_name','$IP',DWRR weight was not set to '$dwrr' on queue '$(( i - 1 ))',ERROR,Ethernet,'$slot','$port >> $logfile
error=1
fi
i=$(( i + 1 ))
done

i=1
while (( $i <= $quenum ))
do
eval eql=\$eql$(( i - 1 ))
result=`snmpset -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.6.1.7.$portid.$i i $eql 2>/dev/null | cut -d ' ' -f 2`
if [ $result'a' == $eql'a' ]
then
echo $ne_name','$IP',Queue size was set to '$eql' on queue '$(( i - 1 ))',COMPLETED,Ethernet,'$slot','$port >> $logfile
elif [ $result'a' != $dwrr'a' ]
then
echo $ne_name','$IP',Queue size was not set to '$eql' on queue '$(( i - 1 ))',ERROR,Ethernet,'$slot','$port >> $logfile
error=1
fi
i=$(( i + 1 ))
done

i=1
while (( $i <= $quenum ))
do
eval eqs=\$eqs$(( i - 1 ))
if [ $eqs'a' == 'a' ]
then
echo $ne_name','$IP',Queue shaper value was empty,SKIPPED,Ethernet,'$slot','$port >> $logfile
else
result=`snmpset -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.6.1.4.$portid.$i i $eqs 2>/dev/null | cut -d ' ' -f 2`
if [ $result'a' == $eqs'a' ]
then
echo $ne_name','$IP',Queue shaper was set to '$eqs' on queue '$(( i - 1 ))',COMPLETED,Ethernet,'$slot','$port >> $logfile
elif [ $result'a' != $dwrr'a' ]
then
echo $ne_name','$IP',Queue shaper was not set to '$eqs' on queue '$(( i - 1 ))',ERROR,Ethernet,'$slot','$port >> $logfile
error=1
fi
fi
i=$(( i + 1 ))
done


else
echo $ne_name','$IP',DWRR Queue length and shaper set was not allowed,SKIPPED,Ethernet,'$slot','$port >> $logfile
fi

# WTDY, WREDG and WREDY set

if [ $ewtdallow'a' == 'ona' ]
then

i=1
while (( $i <= $quenum ))
do
eval wtdy=\$ewtdy$(( i - 1 ))
result=`snmpset -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.6.1.8.$portid.$i i $wtdy 2>/dev/null | cut -d ' ' -f 2`
if [ $result'a' == $wtdy'a' ]
then
echo $ne_name','$IP',WTD yellow threshold was set to '$wtdy' on queue '$(( i - 1 ))',COMPLETED,Ethernet,'$slot','$port >> $logfile
elif [ $result'a' != $wtdy'a' ]
then
echo $ne_name','$IP',WTD yellow threshold was not set to '$wtdy' on queue '$(( i - 1 ))',ERROR,Ethernet,'$slot','$port >> $logfile
error=1
fi
i=$(( i + 1 ))
done

i=1
while (( $i <= $quenum ))
do
eval wredg=\$ewredg$(( i - 1 ))
result=`snmpset -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.6.1.10.$portid.$i i $wredg 2>/dev/null | cut -d ' ' -f 2`
if [ $result'a' == $wredg'a' ]
then
echo $ne_name','$IP',WRED green threshold was set to '$wredg' on queue '$(( i - 1 ))',COMPLETED,Ethernet,'$slot','$port >> $logfile
elif [ $result'a' != $wtdy'a' ]
then
echo $ne_name','$IP',WRED green threshold was not set to '$wredg' on queue '$(( i - 1 ))',ERROR,Ethernet,'$slot','$port >> $logfile
error=1
fi
i=$(( i + 1 ))
done

i=1
while (( $i <= $quenum ))
do
eval wredy=\$ewredy$(( i - 1 ))
result=`snmpset -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.6.1.9.$portid.$i i $wredy 2>/dev/null | cut -d ' ' -f 2`
if [ $result'a' == $wredy'a' ]
then
echo $ne_name','$IP',WRED yellow threshold was set to '$wredy' on queue '$(( i - 1 ))',COMPLETED,Ethernet,'$slot','$port >> $logfile
elif [ $result'a' != $wtdy'a' ]
then
echo $ne_name','$IP',WRED yellow threshold was not set to '$wredy' on queue '$(( i - 1 ))',ERROR,Ethernet,'$slot','$port >> $logfile
error=1
fi
i=$(( i + 1 ))
done


else
echo $ne_name','$IP',wtdy Queue length and shaper set was not allowed,SKIPPED,Ethernet,'$slot','$port >> $logfile
fi

# ....



if (( $error == 0 ))
then
result='COMPLETED'
else
result='ERROR'
fi

done < Ethernet1.list

fi



else
if [ $result'a' == '1a' ]
then
quenum1=4
elif [ $result'a' == '2a' ]
then
quenum1=8
elif [ $result'a' == 'a' ]
then
quenum1='unknown'
fi
echo $ne_name','$IP',Number of queues is '$quenum1' instead of '$quenum',FATAL' >> $logfile
error=1
fi
else
echo $ne_name','$IP',inaccessible,FATAL' >> $logfile
error=1
fi



####
rm -rf $tmp
exit $error

