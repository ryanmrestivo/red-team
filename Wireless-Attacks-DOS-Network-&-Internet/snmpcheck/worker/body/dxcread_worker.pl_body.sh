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




function getslotname {
IPaddress=$1
slotnum=$2
slotnum=$((slotnum+1))
module=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IPaddress .1.3.6.1.4.1.119.2.3.69.501.4.1.1.3.$slotnum 2>/dev/null | cut -d ' ' -f 2`
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
fi

}
function getportname {
portid=$1
oid=$2
IPaddress=$3
portnamehexorig=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IPaddress $oid'.'$portid 2>/dev/null`

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
}

function getporttype {

IPaddress=$1
portidfull=$2

slot=$(( portidfull / 8388608 - 1))
port=$(( (portidfull - (slot+1)*8388608) / 65536))
channel=$(( (portidfull - (slot+1)*8388608) - port*65536))
portid=$(( (slot+1)*8388608 + port*65536))

if (( $portid < 8388608 ))
then
porttype='L'
nameoid='.1.3.6.1.4.1.119.2.3.69.501.5.38.1.1.7'
nameportid=$portid
else
ise1=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IPaddress .1.3.6.1.4.1.119.2.3.69.501.5.3.1.1.4.$portidfull 2>/dev/null | cut -d ' ' -f 2`
if [ $ise1'a' == 'Sucha' ]
then
ismodem=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IPaddress .1.3.6.1.4.1.119.2.3.69.501.4.2.1.16.$portid 2>/dev/null | cut -d ' ' -f 2`
if [ $ismodem'a' == 'Sucha' ]
then
iseth=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IPaddress .1.3.6.1.4.1.119.2.3.69.501.5.30.1.1.3.$portid 2>/dev/null | cut -d ' ' -f 2`
if [ $iseth'a' == 'Sucha' ]
then

isstm1=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IPaddress .1.3.6.1.4.1.119.2.3.69.501.5.13.1.1.4.$portid 2>/dev/null | cut -d ' ' -f 2`
if [ $isstm1'a' == 'Sucha' ]
then

porttype='U'
nameoid='N/A'

else
porttype='S'
nameoid='.1.3.6.1.4.1.119.2.3.69.501.5.13.1.1.3'
nameportid=$portid
fi

else
porttype='E'
nameoid='.1.3.6.1.4.1.119.2.3.69.501.5.30.1.1.11'
nameportid=$portid
fi
else
porttype='M'
nameoid='.1.3.6.1.4.1.119.2.3.69.501.5.5.1.1.3'
nameportid=$portid
fi
else
porttype='E1'
nameoid='.1.3.6.1.4.1.119.2.3.69.501.5.3.1.1.3'
nameportid=$portidfull
fi
fi
}


#######################################
########## begin 
accessible=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r 2 -t 3 -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.1.1.1.11.1 2>/dev/null`
lengthaccessible=${#accessible}
if (($lengthaccessible != 0))
then
ne_type=`echo $accessible | cut -d ' ' -f 2`
ne_name=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.1.1.1.3.1 2>/dev/null | cut -d '"' -f 2`


#-------------------------------------------------------------------------------------------------------------------------


snmpwalk -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -On $IP .1.3.6.1.4.1.119.2.3.69.501.5.11.1.1.3 2>/dev/null | grep -v 'INTEGER: 0' | grep INTEGER | cut -d '.' -f 18 | cut -d ' ' -f 1 > dxcid.list

maxcurr=`cat dxcid.list | wc -l`

while read serviceid
do
error=0

getportname $serviceid '.1.3.6.1.4.1.119.2.3.69.501.5.11.1.1.4' $IP
servicename=$portname

servicetype=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.11.1.1.11.$serviceid 2>/dev/null | cut -d ' ' -f 2`


if [ $servicetype'a' == 'a' ]
then
error=1
servicetypes='unknown'
elif [ $servicetype'a' == '1a' ]
then
servicetypes='E1'
elif [ $servicetype'a' == '2a' ]
then
servicetypes='RST'
else
servicetypes='N/A'
fi

portidfull=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.11.1.1.6.$serviceid 2>/dev/null | cut -d ' ' -f 2`
if [ $portidfull'a' != 'a' ]
then
getporttype $IP $portidfull
getportname $nameportid $nameoid $IP
getslotname $IP $slot
itema=$modules
slota=$slot
porta=$port
channela=$channel
if [ $porttype'a' == 'E1a' ]
then
porttypea='E1'
elif [ $porttype'a' == 'Ma' ]
then
porttypea='Wireless'

elif [ $porttype'a' == 'Sa' ]
then
porttypea='STM1'

else
porttypea='N/A'
fi

portnamea=$portname

else
error=1
itema='unknown'
slota='unknown'
porta='unknown'
channela='unknown'
porttypea='unknown'
portnamea='unknown'

fi
#---------------------------------------------------------

portidfull=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.11.1.1.9.$serviceid 2>/dev/null | cut -d ' ' -f 2`
if [ $portidfull'a' != 'a' ]
then
getporttype $IP $portidfull
getportname $nameportid $nameoid $IP
getslotname $IP $slot
itemb=$modules
slotb=$slot
portb=$port
channelb=$channel
if [ $porttype'a' == 'E1a' ]
then
porttypeb='E1'
elif [ $porttype'a' == 'Ma' ]
then
porttypeb='Wireless'

elif [ $porttype'a' == 'Sa' ]
then
porttypeb='STM1'

else
porttypeb='N/A'
fi

portnameb=$portname

else
error=1
itemb='unknown'
slotb='unknown'
portb='unknown'
channelb='unknown'
porttypeb='unknown'
portnameb='unknown'

fi

#-----------------------------------

protectionanum=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t$snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.11.1.1.5.$serviceid 2>/dev/null | cut -d ' ' -f 2`
if [ $protectionanum'a' == 'a' ]
then
error=1
protectiona='unknown'
itemaprot='unknown'
slotaprot='unknown'
portaprot='unknown'
channelaprot='unknown'
porttypeaprot='unknown'
portnameaprot='unknown'
elif [ $protectionanum'a' == '1a' ]
then
protectiona='unprotected'
itemaprot=''
slotaprot=''
portaprot=''
channelaprot=''
porttypeaprot=''
portnameaprot=''
elif [ $protectionanum'a' == '2a' ]
then
protectiona='protected'
portidfull=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.11.1.1.7.$serviceid 2>/dev/null | cut -d ' ' -f 2`
if [ $portidfull'a' != 'a' ]
then
getporttype $IP $portidfull
getportname $nameportid $nameoid $IP
getslotname $IP $slot
itemaprot=$modules
slotaprot=$slot
portaprot=$port
channelaprot=$channel
if [ $porttype'a' == 'E1a' ]
then
porttypeaprot='E1'
elif [ $porttype'a' == 'Ma' ]
then
porttypeaprot='Wireless'

elif [ $porttype'a' == 'Sa' ]
then
porttypeaprot='STM1'

else
porttypeaprot='N/A'
fi
portnameaprot=$portname
else
error=1
itemaprot='unknown'
slotaprot='unknown'
portaprot='unknown'
channelaprot='unknown'
porttypeaprot='unknown'
portnameaprot='unknown'
fi

else
protectiona='N/A'
itemaprot='N/A'
slotaprot='N/A'
portaprot='N/A'
channelaprot='N/A'
porttypeaprot='N/A'
portnameaprot='N/A'
fi


protectionbnum=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t$snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.11.1.1.8.$serviceid 2>/dev/null | cut -d ' ' -f 2`
if [ $protectionbnum'a' == 'a' ]
then
error=1
protectionb='unknown'
itembprot='unknown'
slotbprot='unknown'
portbprot='unknown'
channelbprot='unknown'
porttypebprot='unknown'
portnamebprot='unknown'
elif [ $protectionbnum'a' == '1a' ]
then
protectionb='unprotected'
itembprot=''
slotbprot=''
portbprot=''
channelbprot=''
porttypebprot=''
portnamebprot=''
elif [ $protectionbnum'a' == '2a' ]
then
portidfull=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.11.1.1.10.$serviceid 2>/dev/null | cut -d ' ' -f 2`
if [ $portidfull'a' != 'a' ]
then
protectionb='protected'
getporttype $IP $portidfull
getportname $nameportid $nameoid $IP
getslotname $IP $slot
itembprot=$modules
slotbprot=$slot
portbprot=$port
channelbprot=$channel
if [ $porttype'a' == 'E1a' ]
then
porttypebprot='E1'
elif [ $porttype'a' == 'Ma' ]
then
porttypebprot='Wireless'

elif [ $porttype'a' == 'Sa' ]
then
porttypebprot='STM1'


else
porttypebprot='N/A'
fi
portnamebprot=$portname
else
error=1
itembprot='unknown'
slotbprot='unknown'
portbprot='unknown'
channelbprot='unknown'
porttypebprot='unknown'
portnamebprot='unknown'
fi

else
protectionb='N/A'
itembprot='N/A'
slotbprot='N/A'
portbprot='N/A'
channelbprot='N/A'
porttypebprot='N/A'
portnamebprot='N/A'
fi

#-------



if (( $error == 0 ))
then
result='COMPLETED'
else
result='ERROR'
fi
echo $ne_name','$ne_type','$IP','$result','$serviceid','$servicename','$servicetypes','$itema','$slota','$porta','$channela','$porttypea','$portnamea','$itemb','$slotb','$portb','$channelb','$porttypeb','$portnameb','$protectiona','$itemaprot','$slotaprot','$portaprot','$channelaprot','$porttypeaprot','$portnameaprot','$protectionb','$itembprot','$slotbprot','$portbprot','$channelbprot','$porttypebprot','$portnamebprot >> $logfile
done < dxcid.list



else
 echo ','$ne_type','$IP',FATAL,inaccessble' >> $logfile
 error=1
fi

####
rm -rf $tmp
exit $error





