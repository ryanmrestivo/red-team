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

quenumber=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.1.1.4.1  2>/dev/null | cut -d ' ' -f 2`
if [ $quenumber'a' == 'a' ]
then
quenumber='unknown'
error=1
echo $ne_name','$ne_type','$IP',FATAL,'$quenumber >> $logfile
elif [ $quenumber'a' == '0a' ]
then
quenumber='invalid'
error=1
echo $ne_name','$ne_type','$IP',FATAL,'$quenumber >> $logfile
else

if [ $quenumber'a' == '1a' ]
then
quenumber=4
elif [ $quenumber'a' == '2a' ]
then
quenumber=8
fi

snmpwalk -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -On $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.5.1.3 2>/dev/null | grep INTEGER | cut -d '.' -f 18 | cut -d ' ' -f 1 > portid.list

maxcurr=`cat portid.list | wc -l`

while read portid
do
error=0
slot=$(( portid / 8388608 - 1))
port=$(( (portid - (slot+1)*8388608) / 65536))

if (( $slot == -1 ))
then
if (( $port < 65 ))
then
slot='LAG'
modules=''
else
slot='RTA'
port=$(( port - 64 ))
modules=''
fi
else
module=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.4.1.1.3.$(( slot + 1 )) 2>/dev/null | cut -d ' ' -f 2`
if [ $module'a' == 'a' ]
then
modules='unknown'
error=1
elif (( $module == 2 ))
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


#---------------------------------------------------------------------------------------------

qosmode=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.1.1.5.1 2>/dev/null | cut -d ' ' -f 2`
if [ $qosmode'a' == 'a' ]
then
error=1
qosmodes='unknown'
elif [ $qosmode'a' == '1a' ]
then
qosmodes='equipment'
elif [ $qosmode'a' == '2a' ]
then
qosmodes='port'
elif [ $qosmode'a' == '3a' ]
then
qosmodes='vlan'
else
qosmodes='N/A'
fi

classmode=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.9.1.3.$portid 2>/dev/null | cut -d ' ' -f 2`
if [ $classmode'a' == 'a' ]
then
error=1
classmodes='unknown'
elif [ $classmode'a' == '1a' ]
then
classmodes='port'
elif [ $classmode'a' == '2a' ]
then
classmodes='CoS (C-tag)'
elif [ $classmode'a' == '3a' ]
then
classmodes='CoS (S-tag)'
elif [ $classmode'a' == '4a' ]
then
classmodes='IPv4 DSCP'
elif [ $classmode'a' == '5a' ]
then
classmodes='IPv4 precedence'
else
classmodes='N/A'
fi


defprio=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.9.1.4.$portid 2>/dev/null | cut -d ' ' -f 2`
if [ $defprio'a' == 'a' ]
then
error=1
defprio='unknown'
fi

#port type recognition
#-------------------------------

if (( $portid < 8388608 ))
then
porttype='L'
else

ismodem=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.4.2.1.16.$portid 2>/dev/null | cut -d ' ' -f 2`
if [ $ismodem'a' == 'Sucha' ]
then
iseth=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.30.1.1.3.$portid 2>/dev/null | cut -d ' ' -f 2`

if [ $iseth'a' == 'Sucha' ]
then
porttype='U'
else
porttype='E'
fi

else
porttype='M'
fi

fi

#-------------------------------
#port type recognition end


if [ $porttype == 'M' ]
then

portnamehexorig=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.5.1.1.3.$portid 2>/dev/null`

if [ "$portnamehexorig"'a' == 'a' ]
then
error=1
portname='unknown'
else

stringtype=`echo $portnamehexorig | cut -b 1-11`

if [ "$stringtype"'a' == 'Hex-STRING:a' ]
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


elif [ $porttype == 'E' ]
then
portname=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.30.1.1.11.$portid 2>/dev/null | cut -d '"' -f 2`
elif [ $porttype == 'L' ]
then
portname=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.38.1.1.7.$portid 2>/dev/null | cut -d '"' -f 2`
elif [ $porttype == 'U' ]
then
portname=''

fi



#-------------------------------------------------------------------------------------------------------------------

if (( $error == 0 ))
then
result='COMPLETED'
else
result='ERROR'
fi
currcount=$(( currcount + 1 ))
echo $ne_name','$ne_type','$IP','$result','$quenumber','$modules','$slot','$port','$portname','$qosmodes','$classmodes','$defprio >> $logfile
done < portid.list



fi

else
 echo ','$ne_type','$IP',FATAL,inaccessble' >> $logfile
 error=1
fi


####
rm -rf $tmp
exit $error

