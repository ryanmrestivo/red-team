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


accessible=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.1.1.1.11.1 2>/dev/null`
lengthaccessible=${#accessible}
if (($lengthaccessible != 0))
then
ne_type=`echo $accessible | cut -d ' ' -f 2`


ne_name=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.1.1.1.3.1 2>/dev/null | cut -d '"' -f 2`

if (( $ne_type < 400 ))
then

selectedclock=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.3.5.1.1.6.1 2>/dev/null | cut -d ' ' -f 2`
if [ $selectedclock'a' == 'a' ]
then
error=1
selectedclock=0
fi

selectedclocksts=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.3.5.1.1.7.1 2>/dev/null | cut -d ' ' -f 2`
if [ $selectedclocksts'a' == 'a' ]
then
error=1
selectedclockstatus='unknown'
elif [ $selectedclocksts'a' == '1a' ]
then
selectedclockstatus='locked'
elif [ $selectedclocksts'a' == '2a' ]
then
selectedclockstatus='holdover'
elif [ $selectedclocksts'a' == '3a' ]
then
selectedclockstatus='freerun'
else
selectedclockstatus='N/A'
fi


ssmglobmode=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.14.2.1.1.9.1 2>/dev/null | cut -d ' ' -f 2`
if [ $ssmglobmode'a' == 'a' ]
then
ssmglobmode='unknown'
error=1
elif (( $ssmglobmode == 1 ))
then
ssmglobmode='QL'
else
ssmglobmode='PL'
fi

clkmode=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.14.2.1.1.6.1 2>/dev/null | cut -d ' ' -f 2`
if [ $clkmode'a' == 'a' ]
then
clkmode=0
clkmodes='unknown'
error=1
elif (( $clkmode == 1 ))
then
clkmodes='Master'
else
clkmodes='Slave'
fi

if (( $clkmode == 1 ))
then
if (( $error == 0 ))
then
result='COMPLETED'
else
result='ERROR'
fi
echo $ne_name','$IP','$result','$ne_type','$clkmodes >> $logfile
elif (( $clkmode == 17 ))
then
clkmodes='Async'
if (( $error == 0 ))
then
result='COMPLETED'
else
result='ERROR'
fi
echo $ne_name','$IP','$result','$ne_type','$clkmodes >> $logfile
elif (( $clkmode !=4 ))
then
if (( $clkmode == 1 )) || (( $clkmode == 2 ))
then
slot=$clkmode
else
slot=$(( $clkmode - 1 ))
fi
module=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.4.1.1.3.$slot 2>/dev/null | cut -d ' ' -f 2`
if [ $module'a' == 'a' ]
then
modules='unknown'
error=1
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
slots=$(( slot - 1))
port=1
i='N/A'
prio='N/A'
lockout='N/A'
ssmusages='N/A'
fssm='N/A'


clockstatus1=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.3.5.2.1.3.1 2>/dev/null | cut -d ' ' -f 2`
if [ $clockstatus1'a' == 'a' ]
then
clockstatus='unknown'
error=1
elif [ $clockstatus1'a' == '1a' ]
then

clockstatus2=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.3.5.2.1.4.1 2>/dev/null | cut -d ' ' -f 2`
if [ $clockstatus2'a' == 'a' ]
then
clockstatus='unknown'
error=1
elif [ $clockstatus2'a' == '1a' ]
then

clockstatus3=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.3.5.2.1.5.1 2>/dev/null | cut -d ' ' -f 2`
if [ $clockstatus3'a' == 'a' ]
then
clockstatus='unknown'
error=1
elif [ $clockstatus3'a' == '1a' ]
then
clockstatus='normal'
else
clockstatus='Clock REF failed'
fi

else
clockstatus='Freq drift'
fi

else
clockstatus='Clock fail'
fi



ssmstat='N/A'

if (( $error == 0 ))
then
result='COMPLETED'
else
result='ERROR'
fi
clkselect='N/A'
clkstatus=$selectedclockstatus
#echo $ne_name','$IP','$result','$ne_type','$clkmodes','$ssmglobmode','$i','$slots','$modules','$port','$prio','$ssmusages','$clockstatus','$lockout','$ssmstat','$fssm >> $logfile
echo $ne_name','$IP','$result','$ne_type','$clkmodes','$ssmglobmode','$i','$slots','$modules','$port','$prio','$ssmusages','$clockstatus','$lockout','$ssmstat','$fssm','$clkselect','$clkstatus >> $logfile
fi
fi

#echo $ne_name','$IP','$result','$ne_type','$clkmodes','$i','$slots','$modules','$port','$prio','$ssmusages','$clockstatus','$lockout','$ssmstat


elif (( $ne_type >= 400 ))
then
selectedclock=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.3.5.1.1.6.1 2>/dev/null | cut -d ' ' -f 2`
if [ $selectedclock'a' == 'a' ]
then
error=1
selectedclock=0
fi

selectedclocksts=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.3.5.1.1.7.1 2>/dev/null | cut -d ' ' -f 2`
if [ $selectedclocksts'a' == 'a' ]
then
error=1
selectedclockstatus='unknown'
elif [ $selectedclocksts'a' == '1a' ]
then
selectedclockstatus='locked'
elif [ $selectedclocksts'a' == '2a' ]
then
selectedclockstatus='holdover'
elif [ $selectedclocksts'a' == '3a' ]
then
selectedclockstatus='freerun'
else
selectedclockstatus='N/A'
fi


ssmglobmode=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.14.2.11.1.7.1 2>/dev/null | cut -d ' ' -f 2`
if [ $ssmglobmode'a' == 'a' ]
then
ssmglobmode='unknown'
error=1
elif (( $ssmglobmode == 1 ))
then
ssmglobmode='QL'
else
ssmglobmode='PL'
fi

clkmode=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.14.2.11.1.5.1 2>/dev/null | cut -d ' ' -f 2`
if [ $clkmode'a' == 'a' ]
then
clkmode=0
clkmodes='unknown'
error=1
elif (( $clkmode == 1 ))
then
clkmodes='Master'
else
clkmodes='Slave'
fi



if (( $clkmode == 1 ))
then
if (( $error == 0 ))
then
result='COMPLETED'
else
result='ERROR'
fi
echo $ne_name','$IP','$result','$ne_type','$clkmodes >> $logfile
elif (( $clkmode == 17 ))
then
clkmodes='Async'
if (( $error == 0 ))
then
result='COMPLETED'
else
result='ERROR'
fi
echo $ne_name','$IP','$result','$ne_type','$clkmodes >> $logfile
elif (( $clkmode !=4 ))
then
if (( $clkmode == 1 )) || (( $clkmode == 2 ))
then
slot=$clkmode
else
slot=$(( $clkmode - 1 ))
fi
module=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.4.1.1.3.$slot 2>/dev/null | cut -d ' ' -f 2`
if [ $module'a' == 'a' ]
then
modules='unknown'
error=1
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
slots=$(( slot - 1))
port=1
fssm='N/A'
i='N/A'
prio='N/A'
lockout='N/A'
ssmusages='N/A'


clockstatus1=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.3.5.2.1.3.1 2>/dev/null | cut -d ' ' -f 2`
if [ $clockstatus1'a' == 'a' ]
then
clockstatus='unknown'
error=1
elif [ $clockstatus1'a' == '1a' ]
then


clockstatus2=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.3.5.2.1.4.1 2>/dev/null | cut -d ' ' -f 2`
if [ $clockstatus2'a' == 'a' ]
then
clockstatus='unknown'
error=1
elif [ $clockstatus2'a' == '1a' ]
then

clockstatus3=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.3.5.2.1.5.1 2>/dev/null | cut -d ' ' -f 2`
if [ $clockstatus3'a' == 'a' ]
then
clockstatus='unknown'
error=1
elif [ $clockstatus3'a' == '1a' ]
then
clockstatus='normal'
else
clockstatus='Clock REF failed'
fi

else
clockstatus='Freq drift'
fi

else
clockstatus='Clock fail'
fi


ssmstat='N/A'
if (( $error == 0 ))
then
result='COMPLETED'
else
result='ERROR'
fi
clkselect='N/A'
clkstatus=$selectedclockstatus
#echo $ne_name','$IP','$result','$ne_type','$clkmodes','$ssmglobmode','$i','$slots','$modules','$port','$prio','$ssmusages','$clockstatus','$lockout','$ssmstat','$fssm >> $logfile
echo $ne_name','$IP','$result','$ne_type','$clkmodes','$ssmglobmode','$i','$slots','$modules','$port','$prio','$ssmusages','$clockstatus','$lockout','$ssmstat','$fssm','$clkselect','$clkstatus >> $logfile
fi
fi




fi

if (( $ne_type < 400 )) && (( $clkmode == 4 ))
then

# 100, 100E and 200 section

i=1
iend=3
if (( $ne_type == 321 ))
then
iend=2
fi

while (( $i <= $iend ))
do
slot=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.14.2.2.1.3.$i 2>/dev/null | cut -d ' ' -f 2`
if [ $slot'a' == 'a' ]
then
slots='unknown'
modules='unknown'
port='unknown'
error=1
elif (( $slot == 0 ))
then
slots='empty'
modules=''
port=''
elif (( $slot == 1 ))
then
slots='Ext clk'
modules='Ext clk'
port=1
elif (( $slot == 2 ))
then
slots='Modem'
modules='Modem A'
port=1
elif (( $slot == 3 ))
then
slots='Modem'
modules='Modem A'
port=2
elif (( $slot == 4 ))
then
slots='MC'
modules='MC/Gbe'
port=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.14.2.1.1.5.1 2>/dev/null | cut -d ' ' -f 2`
if [ $port'a' == 'a' ]
then
port='unknown'
error=1
fi
elif (( $slot == 5 ))
then
slots='MC'
modules='MC/E1'
port=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.14.2.1.1.3.1 2>/dev/null | cut -d ' ' -f 2`
if [ $port'a' == 'a' ]
then
port='unknown'
error=1
fi

fi
if [ $slot'a' != 'a' ] && [ $slot'a' != '0a' ]
then
ssmusages=''
ssmstat=''
prio=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.14.2.2.1.4.$i 2>/dev/null | cut -d ' ' -f 2`
if [ $prio'a' == 'a' ]
then
prio='unknown'
error=1
fi



clockstatus1=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.3.5.2.1.3.$i 2>/dev/null | cut -d ' ' -f 2`
if [ $clockstatus1'a' == 'a' ]
then
clockstatus='unknown'
error=1
elif [ $clockstatus1'a' == '1a' ]
then


clockstatus2=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.3.5.2.1.4.$i 2>/dev/null | cut -d ' ' -f 2`
if [ $clockstatus2'a' == 'a' ]
then
clockstatus='unknown'
error=1
elif [ $clockstatus2'a' == '1a' ]
then

clockstatus3=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.3.5.2.1.5.$i 2>/dev/null | cut -d ' ' -f 2`
if [ $clockstatus3'a' == 'a' ]
then
clockstatus='unknown'
error=1
elif [ $clockstatus3'a' == '1a' ]
then
clockstatus='normal'
else
clockstatus='Clock REF failed'
fi

else
clockstatus='Freq drift'
fi

else
clockstatus='Clock fail'
fi


lockout=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.3.5.2.1.6.$i 2>/dev/null | cut -d ' ' -f 2`
if [ $lockout'a' == 'a' ]
then
lockout='unknown'
error=1
elif (( $lockout == 1 ))
then
lockout='lockout'
else
lockout='normal'
fi


else
ssmusages=''
prio=''
clockstatus=''
fi

if (( $error == 0 ))
then
result='COMPLETED'
else
result='ERROR'
fi

fssm='N/A'
ssmstat='N/A'

if (( $selectedclock == 0 ))
then
clkselect='unknown'
clkstatus='unknonw'
elif (( $selectedclock == $i ))
then
clkselect='Selected REF clock'
clkstatus=$selectedclockstatus
else
clkselect=''
clkstatus=''
fi

echo $ne_name','$IP','$result','$ne_type','$clkmodes','$ssmglobmode','$i','$slots','$modules','$port','$prio','$ssmusages','$clockstatus','$lockout','$ssmstat','$fssm','$clkselect','$clkstatus >> $logfile

i=$(( i + 1 ))

done

elif (( $ne_type >= 400 )) && (( $clkmode == 4 ))
then

# 400, 400A, EX, IX and 1000 section

i=1
iend=3
if (( $ne_type == 520 ))
then
iend=2
fi


while (( $i <= $iend ))
do
slot=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.14.2.12.1.3.$i 2>/dev/null | cut -d ' ' -f 2`
if [ $slot'a' == 'a' ]
then
slots='unknown'
modules='unknown'
port='unknown'
error=1
elif (( $slot == 0 ))
then
slots='empty'
modules=''
port=''

elif (( $slot <= 2 ))
then
slots='Ext clk'
modules='Ext clk'
port=$slot
elif (( $slot == 17 ))
then
slots='MC'
modules='MC/Gbe'
port=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.14.2.11.1.4.1 2>/dev/null | cut -d ' ' -f 2`
if [ $port'a' == 'a' ]
then
port='unknown'
error=1
fi

elif (( $slot == 18 ))
then
slots='MC'
modules='MC/Gbe'
port=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.14.2.11.1.8.1 2>/dev/null | cut -d ' ' -f 2`
if [ $port'a' == 'a' ]
then
port='unknown'
error=1
fi

elif (( $slot == 19 ))
then
slots='MC'
modules='MC/E1'
port=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.14.2.11.1.3.1 2>/dev/null | cut -d ' ' -f 2`
if [ $port'a' == 'a' ]
then
port='unknown'
error=1
fi

elif (( $slot >= 3 )) && (( $slot <= 16 ))
then
slots=$(( slot - 2 ))
module=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.4.1.1.3.$(( slot - 1 )) 2>/dev/null | cut -d ' ' -f 2`

if [ $module'a' == 'a' ]
then
modules='unknown'
error=1

elif (( $module == 3 ))
then
port=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.3.3.1.3.$(( slot - 1 )) 2>/dev/null | cut -d ' ' -f 2`
if [ $port'a' == 'a' ]
then
port='unknown'
error=1
fi

elif (( $module == 6 ))
then
port=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.32.1.1.3.$(( slot - 1 )) 2>/dev/null | cut -d ' ' -f 2`
if [ $port'a' == 'a' ]
then
port='unknown'
error=1
fi


else
port=1
fi

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

if [ $slot'a' != 'a' ] && [ $slot'a' != '0a' ]
then

prio=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.14.2.12.1.4.$i 2>/dev/null | cut -d ' ' -f 2`
if [ $prio'a' == 'a' ]
then
prio='unknown'
error=1
fi

ssmusage=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.14.2.12.1.6.$i 2>/dev/null | cut -d ' ' -f 2`

if [ $ssmusage'a' == 'a' ]
then
ssmusages='unknown'
error=1
elif (( $ssmusage == 0 ))
then
ssmusages='invalid'
elif (( $ssmusage == 1 ))
then
ssmusages='not used'
elif (( $ssmusage == 2 ))
then
ssmusages='used'
fi


clockstatus1=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.3.5.2.1.3.$i 2>/dev/null | cut -d ' ' -f 2`
if [ $clockstatus1'a' == 'a' ]
then
clockstatus='unknown'
error=1
elif [ $clockstatus1'a' == '1a' ]
then


clockstatus2=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.3.5.2.1.4.$i 2>/dev/null | cut -d ' ' -f 2`
if [ $clockstatus2'a' == 'a' ]
then
clockstatus='unknown'
error=1
elif [ $clockstatus2'a' == '1a' ]
then

clockstatus3=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.3.5.2.1.5.$i 2>/dev/null | cut -d ' ' -f 2`
if [ $clockstatus3'a' == 'a' ]
then
clockstatus='unknown'
error=1
elif [ $clockstatus3'a' == '1a' ]
then
clockstatus='normal'
else
clockstatus='Clock REF failed'
fi

else
clockstatus='Freq drift'
fi

else
clockstatus='Clock fail'
fi


lockout=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.3.5.2.1.6.$i 2>/dev/null | cut -d ' ' -f 2`
if [ $lockout'a' == 'a' ]
then
lockout='unknown'
error=1
elif (( $lockout == 1 ))
then
lockout='lockout'
else
lockout='normal'
fi

ssmstat=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.3.5.2.1.7.$i 2>/dev/null | cut -d ' ' -f 2`
if [ $ssmstat'a' == 'a' ]
then
ssmstat='unknown'
error=1
elif (( $ssmstat == 1 ))
then
ssmstat='PRC'
elif (( $ssmstat == 2 ))
then
ssmstat='SSUA'
elif (( $ssmstat == 3 ))
then
ssmstat='SSUB'
elif (( $ssmstat == 4 ))
then
ssmstat='Original'
elif (( $ssmstat == 5 ))
then
ssmstat='SEC'
elif (( $ssmstat == 6 ))
then
ssmstat='DNU'
elif (( $ssmstat == 7 ))
then
ssmstat='INVx'
elif (( $ssmstat == 8 ))
then
ssmstat='Failed'
elif (( $ssmstat == 9 ))
then
ssmstat='N/A'
fi

fssm=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.14.2.12.1.5.$i 2>/dev/null | cut -d ' ' -f 2`
if [ $fssm'a' == 'a' ]
then
fssm='unknown'
error=1
elif (( $fssm == 1 ))
then
fssm='PRC'
elif (( $fssm == 2 ))
then
fssm='SSUA'
elif (( $fssm == 3 ))
then
fssm='SSUB'
elif (( $fssm == 4 ))
then
fssm='SEC'
fi

else
fssm=''
ssmusages=''
prio=''
clockstatus=''
ssmstat=''
fi

if (( $error == 0 ))
then
result='COMPLETED'
else
result='ERROR'
fi

if (( $selectedclock == 0 ))
then
clkselect='unknown'
clkstatus='unknonw'
elif (( $selectedclock == $i ))
then
clkselect='Selected REF clock'
clkstatus=$selectedclockstatus
else
clkselect=''
clkstatus=''
fi

echo $ne_name','$IP','$result','$ne_type','$clkmodes','$ssmglobmode','$i','$slots','$modules','$port','$prio','$ssmusages','$clockstatus','$lockout','$ssmstat','$fssm','$clkselect','$clkstatus >> $logfile
i=$(( i + 1 ))
done

elif (( $clkmode != 4 ))
then
a='just trick'
else
echo $ne_name','$IP',FATAL,unknown type' >> $logfile
error=1
fi


if (( $error == 0 ))
then
echo $ne_name' '$IP' passed<BR>'
else
echo $ne_name' '$IP' error<BR>'
fi

else
 echo $ne_name' '$IP' inaccessible<BR>'
 echo $ne_name','$IP',FATAL' >> $logfile
 error=1
fi




####
rm -rf $tmp
exit $error

