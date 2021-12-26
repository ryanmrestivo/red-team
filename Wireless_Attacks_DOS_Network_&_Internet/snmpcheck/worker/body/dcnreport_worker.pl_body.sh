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
temperror=1
ne_name=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.1.1.1.3.1 2>/dev/null | cut -d '"' -f 2`
ne_type=`echo $accessible | cut -d ' ' -f 2`





snmpwalk -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -On $IP .1.3.6.1.4.1.119.2.3.69.501.4.2.1.16 2>/dev/null | cut -d '.' -f 17 | grep INTEGER | cut -d ' ' -f 1 > modem.list

rgrp1=0
rgrp2=0
rgrp3=0
rgrp4=0
rgrp5=0
rgrp6=0
rgrp7=0
rgrp8=0

fatalerror=0

while read slotid
do

groupnum=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.4.2.1.17.$slotid 2>/dev/null | cut -d ' ' -f 2`
if [ $groupnum'a' != 'a' ]
then

if (( $groupnum == 0 ))
then
slot=$((slotid / 8388608 + 39))
echo $slot >> modem1.list
else
eval 'grpflag=$rgrp'$groupnum
if (( $grpflag == 0 ))
then
slot=$((slotid / 8388608 + 39))
echo $slot >> modem1.list
eval 'rgrp'$groupnum'=1'
fi
fi

else
fatalerror=1
fi

done <modem.list

if (( $fatalerror == 0 ))
then

snmpwalk -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -On $IP .1.3.6.1.4.1.119.2.3.69.5.3.16.2.1.3 2>/dev/null > br.list

while read brnum
do
ifnum=`echo $brnum | cut -d '.' -f 18 | cut -d ' ' -f 1`
brnum=`echo $brnum | cut -d ' ' -f 4`
ok=0
if (( $ifnum < 55 )) && (( $ifnum > 40 ))
then
mdm=`cat modem1.list | grep $ifnum | wc -l`


if (( $mdm != 0 )) && (( $brnum !=0 ))
then
ok=1
fi

else
if (( $brnum != 0 ))
then
ok=1
fi
fi



if (( $ok == 1 ))
then

#in-band vid and cos section

if (( $ifnum < 87 )) && (( $ifnum > 70 ))
then
vid=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.15.6.1.6.$ifnum 2>/dev/null | cut -d ' ' -f 2`

if [ $vid'a' == 'a' ]
then
vid='unknown'
error=1
fi

cos=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.15.6.1.8.$ifnum 2>/dev/null | cut -d ' ' -f 2`

if [ $cos'a' == 'a' ]
then
cos='unknown'
error=1
fi

else
vid=''
cos=''
fi

# end of in-band section

# IP address section

ipaddr=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.16.1.1.3.$brnum 2>/dev/null | cut -d ' ' -f 2`
if [ $ipaddr'a' == 'a' ]
then
ipaddr='unknown'
error=1
fi

netmask=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.16.1.1.4.$brnum 2>/dev/null | cut -d ' ' -f 2`
if [ $netmask'a' == 'a' ]
then
netmask='unknown'
error=1
fi


# end on IP address section

# NMS or NE port usage section

if (( $ifnum < 35 )) && (( $ifnum > 30 ))
then
portusage=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.15.3.1.3.$ifnum 2>/dev/null | cut -d ' ' -f 2`
if [ $portusage'a' == 'a' ]
then
portusage='unknown'
error=1
else
if (( $portusage == 1 ))
then
portusagename='used'
else
portusagename='not used'
fi
fi

else
portusagename=''
fi

# NMS or NE port usage section end

# NE port usage user/management

if (( $ifnum == 32 ))
then
neportusg=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.25.1.3.1 2>/dev/null | cut -d ' ' -f 2`

if [ $neportusg'a' == 'a' ]
then
error=1
neportusage='unknown'
elif [ $neportusg'a' == '1a' ]
then
neportusage='user port'
elif [ $neportusg'a' == '2a' ]
then
neportusage='management port'
else
neportusage=''
fi

else
neportusage=''
fi

# NE port usage user/management end

# NMS port connect to NMS

if (( $ifnum == 31 ))
then
nmsportusg=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.15.3.1.5.31 2>/dev/null | cut -d ' ' -f 2`

if [ $nmsportusg'a' == 'a' ]
then
error=1
nmsportusage='unknown'
elif [ $nmsportusg'a' == '1a' ]
then
nmsportusage='Yes'
elif [ $nmsportusg'a' == '2a' ]
then
nmsportusage='No'
else
nmsportusage='invalid'
fi

else
nmsportusage=''
fi


# NMS port connect to NMS end

# M-plane traffic control section
if (( $temperror == 1 ))
then

mgmtbwlimit=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.29.1.1.3.1 2>/dev/null | cut -d ' ' -f 2`
mplanecos=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.29.1.1.4.1 2>/dev/null | cut -d ' ' -f 2`
if [ $mgmtbwlimit'a' == 'a' ]
then
mgmtbwlimit='unknown'
error=1
temperror=1
elif [ $mgmtbwlimit'a' == 'Sucha' ]
then
temperror=0
mgmtbwlimit='N/A'
else
temperror=0
fi

if [ $mplanecos'a' == 'a' ]
then
mplanecos='unknown'
error=1
temperror=1
elif [ $mplanecos'a' == 'Sucha' ]
then
temperror=0
mplanecos='N/A'
else
temperror=0
fi

if [ $mgmtbwlimit'a' == '0a' ]
then
mgmtbwlimit='disabled'
fi

fi

# M-plane traffic control section end

if (( $error == 0 ))
then
 result="COMPLETED"
else
 result="ERROR"
fi

if (( $ifnum == 31 ))
then
ifname='NMS'
elif (( $ifnum == 32 ))
then
ifname='NE'
elif (( $ifnum == 33 ))
then
ifname='NE2'
elif (( $ifnum == 34 ))
then
ifname='LCT'
elif (( $ifnum == 41 ))
then
ifname='Modem1'
elif (( $ifnum == 42 ))
then
ifname='Modem2'
elif (( $ifnum == 43 ))
then
ifname='Modem3'
elif (( $ifnum == 44 ))
then
ifname='Modem4'
elif (( $ifnum == 45 ))
then
ifname='Modem5'
elif (( $ifnum == 46 ))
then
ifname='Modem6'
elif (( $ifnum == 47 ))
then
ifname='Modem7'
elif (( $ifnum == 48 ))
then
ifname='Modem8'
elif (( $ifnum == 49 ))
then
ifname='Modem9'
elif (( $ifnum == 50 ))
then
ifname='Modem10'
elif (( $ifnum == 51 ))
then
ifname='Modem11'
elif (( $ifnum == 52 ))
then
ifname='Modem12'
elif (( $ifnum == 53 ))
then
ifname='Modem13'
elif (( $ifnum == 54 ))
then
ifname='Modem14'
elif (( $ifnum == 71 ))
then
ifname='in-band1'
elif (( $ifnum == 72 ))
then
ifname='in-band2'
elif (( $ifnum == 73 ))
then
ifname='in-band3'
elif (( $ifnum == 74 ))
then
ifname='in-band4'
elif (( $ifnum == 75 ))
then
ifname='in-band5'
elif (( $ifnum == 76 ))
then
ifname='in-band6'
elif (( $ifnum == 77 ))
then
ifname='in-band7'
elif (( $ifnum == 78 ))
then
ifname='in-band8'
elif (( $ifnum == 79 ))
then
ifname='in-band9'
elif (( $ifnum == 80 ))
then
ifname='in-band10'
elif (( $ifnum == 61 ))
then
ifname='in-band11'
elif (( $ifnum == 82 ))
then
ifname='in-band12'
elif (( $ifnum == 83 ))
then
ifname='in-band13'
elif (( $ifnum == 84 ))
then
ifname='in-band14'
elif (( $ifnum == 85 ))
then
ifname='in-band15'
elif (( $ifnum == 86 ))
then
ifname='in-band16'
else
ifname='UNKNOWN'
fi

echo $ne_name','$IP','$ne_type','$result','$ifname','$brnum','$vid','$cos','$ipaddr','$netmask','$portusagename','$neportusage','$nmsportusage','$mgmtbwlimit','$mplanecos >> $logfile




fi

done < br.list

fi

# Fatalproblem if start. For example if modem list cannot be recognized.

if (( $fatalerror == 1 ))
then
result='FATAL'
echo $ne_name','$IP','$ne_type','$result >> $logfile
fi
# Fatal problem if end

else
 echo ','$IP',,INACCESSIBLE' >> $logfile
 error=1
fi

####
rm -rf $tmp
exit $error


