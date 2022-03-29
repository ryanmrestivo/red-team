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

#------------------------------------------------ Portname for ORO----------------------------

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

if [ $qosmodes'a' == 'porta' ]
then
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
else
classmodes='N/A (not port mode)'
fi

#------------------------------------------------ Portname for ORO end -----------------------

maxcurr1=$(( 3 + 8 + 6 * 8 ))

schmode=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.5.1.3.$portid 2>/dev/null | cut -d ' ' -f 2`
if [ $schmode'a' == 'a' ]
then
schmode='unknown'
error=1
elif (( $schmode == 1 ))
then
schmode='2 SP'
elif (( $schmode == 2  ))
then
schmode='4 SP'
elif (( $schmode == 3 ))
then
schmode='1 SP + 3 DWRR'
elif (( $schmode == 4 ))
then
schmode='4 DWWR'
elif (( $schmode == 5 ))
then
schmode='1 SP + 7 DWRR'
elif (( $schmode == 6 ))
then
schmode='2 SP + 6 DWRR'
elif (( $schmode == 7 ))
then
schmode='8 SP'
fi

dropmode=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.5.1.4.$portid 2>/dev/null | cut -d ' ' -f 2`
if [ $dropmode'a' == 'a' ]
then
dropmode='unknown'
error=1
elif (( $dropmode == 1 ))
then
dropmode='WTD'
elif (( $dropmode == 2  ))
then
dropmode='WRED'
fi

portspeed=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.5.1.13.$portid 2>/dev/null | cut -d ' ' -f 2`
if [ $portspeed'a' == 'a' ]
then
portspeed='unknonwn'
error=1
else
portspeedh=$(( portspeed/1000 ))
portspeedl=$(( portspeed - portspeedh * 1000 ))
if (( $portspeedl == 0 ))
then
portspeed=$portspeedh
else

if (( $portspeedl > 99 ))
then
portspeed=$portspeedh'.'$portspeedl
elif (( $portspeedl > 9 ))
then
portspeed=$portspeedh'.0'$portspeedl
else
portspeed=$portspeedh'.00'$portspeedl
fi

fi
fi

pri1=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.5.1.5.$portid 2>/dev/null | cut -d ' ' -f 2`
if [ $pri1'a' == 'a' ]
then
pri1='unknown'
error=1
fi
pri2=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.5.1.6.$portid 2>/dev/null | cut -d ' ' -f 2`
if [ $pri2'a' == 'a' ]
then
pri2='unknown'
error=1
fi
pri3=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.5.1.7.$portid 2>/dev/null | cut -d ' ' -f 2`
if [ $pri3'a' == 'a' ]
then
pri3='unknown'
error=1
fi
pri4=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.5.1.8.$portid 2>/dev/null | cut -d ' ' -f 2`
if [ $pri4'a' == 'a' ]
then
pri4='unknown'
error=1
fi
pri5=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.5.1.9.$portid 2>/dev/null | cut -d ' ' -f 2`
if [ $pri5'a' == 'a' ]
then
pri5='unknown'
error=1
fi
pri6=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.5.1.10.$portid 2>/dev/null | cut -d ' ' -f 2`
if [ $pri6'a' == 'a' ]
then
pri6='unknown'
error=1
fi
pri7=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.5.1.11.$portid 2>/dev/null | cut -d ' ' -f 2`
if [ $pri7'a' == 'a' ]
then
pri7='unknown'
error=1
fi
pri8=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.5.1.12.$portid 2>/dev/null | cut -d ' ' -f 2`
if [ $pri8'a' == 'a' ]
then
pri8='unknown'
error=1
fi

i=1
while (( $i <= 8 ))
do
if (( $i > $quenumber ))
then
eval 'qsp'$i=''
else
qsp=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.6.1.4.$portid.$i 2>/dev/null | cut -d ' ' -f 2`
if [ $qsp'a' == 'a' ]
then
qsp='unknonwn'
error=1
else
qsph=$(( qsp/1000 ))
qspl=$(( qsp - qsph * 1000 ))
if (( $qspl == 0 ))
then
qsp=$qsph
else

if (( $qspl > 99 ))
then
qsp=$qsph'.'$qspl
elif (( $qspl > 9 ))
then
qsp=$qsph'.0'$qspl
else
qsp=$qsph'.00'$qspl
fi

fi
fi
eval 'qsp'$i=$qsp
fi
i=$(( i + 1 ))
done

i=1
while (( $i <= 8 ))
do
if (( $i > $quenumber ))
then
eval 'ql'$i=''
else
ql=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.6.1.7.$portid.$i 2>/dev/null | cut -d ' ' -f 2`
if [ $ql'a' == 'a' ]
then
ql='unknonwn'
error=1
fi
eval 'ql'$i=$ql
fi
i=$(( i + 1 ))
done

i=1
while (( $i <= 8 ))
do
if (( $i > $quenumber ))
then
eval 'dwrr'$i=''
else
dwrr=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.6.1.6.$portid.$i 2>/dev/null | cut -d ' ' -f 2`
if [ $dwrr'a' == 'a' ]
then
dwrr='unknonwn'
error=1
fi
eval 'dwrr'$i=$dwrr
fi
i=$(( i + 1 ))
done

i=1
while (( $i <= 8 ))
do
if (( $i > $quenumber ))
then
eval 'wtdy'$i=''
else
wtdy=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.6.1.8.$portid.$i 2>/dev/null | cut -d ' ' -f 2`
if [ $wtdy'a' == 'a' ]
then
wtdy='unknonwn'
error=1
fi
eval 'wtdy'$i=$wtdy
fi
i=$(( i + 1 ))
done

i=1
while (( $i <= 8 ))
do
if (( $i > $quenumber ))
then
eval 'wredg'$i=''
else
wredg=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.6.1.10.$portid.$i 2>/dev/null | cut -d ' ' -f 2`
if [ $wredg'a' == 'a' ]
then
wredg='unknonwn'
error=1
fi
eval 'wredg'$i=$wredg
fi
i=$(( i + 1 ))
done

i=1
while (( $i <= 8 ))
do
if (( $i > $quenumber ))
then
eval 'wredy'$i=''
else
wredy=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.6.1.9.$portid.$i 2>/dev/null | cut -d ' ' -f 2`
if [ $wredy'a' == 'a' ]
then
wredy='unknonwn'
error=1
fi
eval 'wredy'$i=$wredy
fi
i=$(( i + 1 ))
done



if (( $error == 0 ))
then
result='COMPLETED'
else
result='ERROR'
fi
currcount=$(( currcount + 1 ))
echo $ne_name','$ne_type','$IP','$result','$quenumber','$modules','$slot','$port','$portname','$qosmodes','$classmodes','$schmode','$dropmode','$portspeed','$pri1','$pri2','$pri3','$pri4','$pri5','$pri6','$pri7','$pri8','$qsp1','$qsp2','$qsp3','$qsp4','$qsp5','$qsp6','$qsp7','$qsp8','$ql1','$ql2','$ql3','$ql4','$ql5','$ql6','$ql7','$ql8','$dwrr1','$dwrr2','$dwrr3','$dwrr4','$dwrr5','$dwrr6','$dwrr7','$dwrr8','$wtdy1','$wtdy2','$wtdy3','$wtdy4','$wtdy5','$wtdy6','$wtdy7','$wtdy8','$wredg1','$wredg2','$wredg3','$wredg4','$wredg5','$wredg6','$wredg7','$wredg8','$wredy1','$wredy2','$wredy3','$wredy4','$wredy5','$wredy6','$wredy7','$wredy8 >> $logfile
done < portid.list



fi

else
 echo ','$ne_type','$IP',FATAL,inaccessble' >> $logfile
 error=1
fi


####
rm -rf $tmp
exit $error

