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

erplist='erplist'`echo $$`
erplist1='erplist1'`echo $$`
sepch=' '

###########

echo 'IP,ERP ID,ERP ID Start,ERP ID stop,ERP list,ERP list1' >> /home/nems/client_persist/htdocs/bulktool4/erp.debug
echo $IP','$erpid','$erpidstart','$erpidstop','$erplist','$erplist1 >> /home/nems/client_persist/htdocs/bulktool4/erp.debug


accessible=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.1.1.1.11.1 2>/dev/null`
lengthaccessible=${#accessible}
if (($lengthaccessible != 0))
then
ne_name=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.1.1.1.3.1 2>/dev/null | cut -d '"' -f 2`
ne_type=$accessible

erpgeneral=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.39.10.1.3.1 2>/dev/null | cut -d ' ' -f 2`
if [ $erpgeneral'a' == '2a' ]
then
snmpwalk -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -On $IP .1.3.6.1.4.1.119.2.3.69.501.5.39.1.1.6 2>/dev/null | cut -d '.' -f 18 | cut -d ' ' -f 1 > $erplist
snmpwalk -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -On $IP .1.3.6.1.4.1.119.2.3.69.501.5.39.2.1.8 2>/dev/null | cut -d '.' -f 18 | cut -d ' ' -f 1 > $erplist1

# -------------------- major and sub -----------------------

maxcurr=$((`cat $erplist | wc -l` + `cat $erplist1 | wc -l`))


while read erpid
do

if (( $erpid >= $erpidstart )) && (( $erpid <= $erpidstop ))
then
erpname=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.39.1.1.4.$erpid 2>/dev/null | cut -d '"' -f 2`
erpversion=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.39.1.1.3.$erpid 2>/dev/null | cut -d ' ' -f 2`
ringtype=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.39.1.1.7.$erpid 2>/dev/null | cut -d ' ' -f 2`
if [ $ringtype'a' == '1a' ]
then
ringstype='major'
fi
if [ $ringtype'a' == '2a' ]
then
ringstype='sub'
fi
port1id=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.39.3.1.5.$erpid.1 2>/dev/null | cut -d ' ' -f 2`
port2id=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.39.3.1.5.$erpid.2 2>/dev/null | cut -d ' ' -f 2`
slot1=$(( port1id / 8388608 - 1 ))
slot2=$(( port2id / 8388608 - 1))
port1=$(( (port1id - (slot1+1)*8388608)/65536))
port2=$(( (port2id - (slot2+1)*8388608)/65536))


ports0='S'$slot1'/P'$port1
ports1='S'$slot2'/P'$port2

if (( $slot1 == -1 ))
then
if (( $port1 <=64 ))
then
ports0='LAG'$port1
else
port1=$(( port1 - 64 ))
ports0='RTA'$port1
fi
fi

if (( $slot2 == -1 ))
then
if (( $port2 <=64 ))
then
ports1='LAG'$port2
else
port2=$(( port2 - 64 ))
ports1='RTA'$port2
fi
fi


rplowner=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.39.7.1.3.$erpid 2>/dev/null | cut -d ' ' -f 2`
if [ $rplowner'a' == '2a' ]
then
rplowns='RPL'
rplport=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.39.7.1.4.$erpid 2>/dev/null | cut -d ' ' -f 2`
revert=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt .1.3.6.1.4.1.119.2.3.69.501.5.39.7.1.5.$erpid 2>/dev/null | cut -d ' ' -f 2`
revertive=''
if [ $revert'a' == '2a' ]
then
revertive='non-revertive'
fi
if [ $revert'a' == '1a' ]
then
revertive='revertive'
fi
wtrtimer=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.39.8.1.3.$erpid 2>/dev/null | cut -d ' ' -f 2`
if [ $rplport'a' == '1a' ]
then
rplports=$ports0
fi
if [ $rplport'a' == '2a' ]
then
rplports=$ports1
fi
else
rplowns=''
rplports=''
wtrtimer=''
revertive=''
fi
guardtimer=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.39.8.1.4.$erpid 2>/dev/null | cut -d ' ' -f 2`
guardtimer=$(( guardtimer *10 ))
controlvlan=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.39.5.1.3.$erpid 2>/dev/null | cut -d ' ' -f 2`
mep0=''
mep1=''
mep0=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.39.3.1.6.$erpid.1 2>/dev/null | cut -d ' ' -f 2`
mep1=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.39.3.1.6.$erpid.2 2>/dev/null | cut -d ' ' -f 2`
if [ $mep0'a' == '0a' ]
then
mep0=''
fi
if [ $mep1'a' == '0a' ]
then
mep1=''
fi
maclast=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.39.5.1.4.$erpid 2>/dev/null | cut -d ' ' -f 2`
printf -v machex "%02X" "$maclast"
mac='01:19:A7:00:00:'$machex
rapsmeg=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.39.5.1.5.$erpid 2>/dev/null | cut -d ' ' -f 2`
rapsprio=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.39.5.1.6.$erpid 2>/dev/null | cut -d ' ' -f 2`



vlantemp='vlantemp'`echo $$`
snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt  -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.39.6.1.3.$erpid > $vlantemp
i=0
vlanlist=''
while read vlanline && (( i < 32 ))
do
if (( i == 0 ))
then
vlanline=`echo $vlanline | cut -d ' ' -f 2-1000`
fi
ii=0
si=1
while (( $ii <= 15 ))
do
p=$(((i*16+ii)*8))
c2=`echo $vlanline | cut -b $si`
c1=`echo $vlanline | cut -b $((si+1))`

if [ $c1 != '0' ]
then
if [ $c1 == '1' ]
then
vlanlist=$vlanlist$((p+1))$sepch
fi
if [ $c1 == '2' ]
then
vlanlist=$vlanlist$((p+2))$sepch
fi
if [ $c1 == '3' ]
then
vlanlist=$vlanlist$((p+1))$sepch$((p+2))$sepch
fi
if [ $c1 == '4' ]
then
vlanlist=$vlanlist$((p+3))$sepch
fi
if [ $c1 == '5' ]
then
vlanlist=$vlanlist$((p+1))$sepch$((p+3))$sepch
fi
if [ $c1 == '6' ]
then
vlanlist=$vlanlist$((p+2))$sepch$((p+3))$sepch
fi
if [ $c1 == '7' ]
then
vlanlist=$vlanlist$((p+1))$sepch$((p+2))$sepch$((p+3))$sepch
fi
if [ $c1 == '8' ]
then
vlanlist=$vlanlist$((p+4))$sepch
fi
if [ $c1 == '9' ]
then
vlanlist=$vlanlist$((p+1))$sepch$((p+4))$sepch
fi
if [ $c1 == 'A' ]
then
vlanlist=$vlanlist$((p+2))$sepch$((p+4))$sepch
fi
if [ $c1 == 'B' ]
then
vlanlist=$vlanlist$((p+1))$sepch$((p+2))$sepch$((p+4))$sepch
fi
if [ $c1 == 'C' ]
then
vlanlist=$vlanlist$((p+3))$sepch$((p+4))$sepch
fi
if [ $c1 == 'D' ]
then
vlanlist=$vlanlist$((p+1))$sepch$((p+3))$sepch$((p+4))$sepch
fi
if [ $c1 == 'E' ]
then
vlanlist=$vlanlist$((p+2))$sepch$((p+3))$sepch$((p+4))$sepch
fi
if [ $c1 == 'F' ]
then
vlanlist=$vlanlist$((p+1))$sepch$((p+2))$sepch$((p+3))$sepch$((p+4))$sepch
fi
fi
if [ $c2 != '0' ]
then
if [ $c2 == '1' ]
then
vlanlist=$vlanlist$((p+5))$sepch
fi
if [ $c2 == '2' ]
then
vlanlist=$vlanlist$((p+6))$sepch
fi
if [ $c2 == '3' ]
then
vlanlist=$vlanlist$((p+5))$sepch$((p+6))$sepch
fi
if [ $c2 == '4' ]
then
vlanlist=$vlanlist$((p+7))$sepch
fi
if [ $c2 == '5' ]
then
vlanlist=$vlanlist$((p+5))$sepch$((p+7))$sepch
fi
if [ $c2 == '6' ]
then
vlanlist=$vlanlist$((p+6))$sepch$((p+7))$sepch
fi
if [ $c2 == '7' ]
then
vlanlist=$vlanlist$((p+5))$sepch$((p+6))$sepch$((p+7))$sepch
fi
if [ $c2 == '8' ]
then
vlanlist=$vlanlist$((p+8))$sepch
fi
if [ $c2 == '9' ]
then
vlanlist=$vlanlist$((p+5))$sepch$((p+8))$sepch
fi
if [ $c2 == 'A' ]
then
vlanlist=$vlanlist$((p+6))$sepch$((p+8))$sepch
fi
if [ $c2 == 'B' ]
then
vlanlist=$vlanlist$((p+5))$sepch$((p+6))$sepch$((p+8))$sepch
fi
if [ $c2 == 'C' ]
then
vlanlist=$vlanlist$((p+7))$sepch$((p+8))$sepch
fi
if [ $c2 == 'D' ]
then
vlanlist=$vlanlist$((p+5))$sepch$((p+7))$sepch$((p+8))$sepch
fi
if [ $c2 == 'E' ]
then
vlanlist=$vlanlist$((p+6))$sepch$((p+7))$sepch$((p+8))$sepch
fi
if [ $c2 == 'F' ]
then
vlanlist=$vlanlist$((p+5))$sepch$((p+6))$sepch$((p+7))$sepch$((p+8))$sepch
fi
fi

si=$((si+3))
ii=$((ii+1))
done
i=$((i+1))
done < $vlantemp





echo $ne_name','$IP',on,'$erpid','$erpname','$erpversion',,'$ringstype','$ports0','$ports1','$rplowns','$rplports','$revertive','$wtrtimer','$guardtimer','$controlvlan','$mep0','$mep1','$mac','$rapsmeg','$rapsprio','$vlanlist',COMPLETED' >> $logfile

fi


done < $erplist

#------------------ Interconnection ------------------------
while read erpid
do
if (( $erpid >= $erpidstart )) && (( $erpid <= $erpidstop ))
then
erpname=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.39.2.1.5.$erpid 2>/dev/null | cut -d '"' -f 2`
erpversion=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.39.2.1.3.$erpid 2>/dev/null | cut -d ' ' -f 2`
ringstype='Interconnection'
upperring=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.39.2.1.4.$erpid 2>/dev/null | cut -d ' ' -f 2`
port1id=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.39.3.1.5.$erpid.1 2>/dev/null | cut -d ' ' -f 2`
slot1=$(( port1id / 8388608 - 1 ))
port1=$(( (port1id - (slot1+1)*8388608)/65536))

ports0='S'$slot1'/P'$port1

if (( $slot1 == -1 ))
then
if (( $port1 <=64 ))
then
ports0='LAG'$port1
else
port1=$(( port1 - 64 ))
ports0='RTA'$port1
fi
fi


rplowner=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.39.7.1.3.$erpid 2>/dev/null | cut -d ' ' -f 2`
if [ $rplowner'a' == '2a' ]
then
rplowns='RPL'
rplport=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.39.7.1.4.$erpid 2>/dev/null | cut -d ' ' -f 2`
revert=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.39.7.1.5.$erpid 2>/dev/null | cut -d ' ' -f 2`
revertive=''
if [ $revert'a' == '2a' ]
then
revertive='non-revertive'
fi
if [ $revert'a' == '1a' ]
then
revertive='revertive'
fi
wtrtimer=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.39.8.1.3.$erpid 2>/dev/null | cut -d ' ' -f 2`
if [ $rplport'a' == '1a' ]
then
rplports=$ports0
fi
if [ $rplport'a' == '2a' ]
then
rplports=$ports1
fi
else
rplowns=''
rplports=''
wtrtimer=''
revertive=''
fi
guardtimer=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.39.8.1.4.$erpid 2>/dev/null | cut -d ' ' -f 2`
guardtimer=$(( guardtimer *10 ))
controlvlan=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.39.5.1.3.$erpid 2>/dev/null | cut -d ' ' -f 2`
mep0=''
mep0=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.39.3.1.6.$erpid.1 2>/dev/null | cut -d ' ' -f 2`
if [ $mep0'a' == '0a' ]
then
mep0=''
fi
maclast=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.39.5.1.4.$erpid 2>/dev/null | cut -d ' ' -f 2`
printf -v machex "%02X" "$maclast"
mac='01:19:A7:00:00:'$machex
rapsmeg=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.39.5.1.5.$erpid 2>/dev/null | cut -d ' ' -f 2`
rapsprio=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.39.5.1.6.$erpid 2>/dev/null | cut -d ' ' -f 2`



vlantemp='vlantemp'`echo $$`
snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt  -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.39.6.1.3.$erpid > $vlantemp
i=0
vlanlist=''
while read vlanline && (( i < 32 ))
do
if (( i == 0 ))
then
vlanline=`echo $vlanline | cut -d ' ' -f 2-1000`
fi
ii=0
si=1
while (( $ii <= 15 ))
do
p=$(((i*16+ii)*8))
c2=`echo $vlanline | cut -b $si`
c1=`echo $vlanline | cut -b $((si+1))`

if [ $c1 != '0' ]
then
if [ $c1 == '1' ]
then
vlanlist=$vlanlist$((p+1))$sepch
fi
if [ $c1 == '2' ]
then
vlanlist=$vlanlist$((p+2))$sepch
fi
if [ $c1 == '3' ]
then
vlanlist=$vlanlist$((p+1))$sepch$((p+2))$sepch
fi
if [ $c1 == '4' ]
then
vlanlist=$vlanlist$((p+3))$sepch
fi
if [ $c1 == '5' ]
then
vlanlist=$vlanlist$((p+1))$sepch$((p+3))$sepch
fi
if [ $c1 == '6' ]
then
vlanlist=$vlanlist$((p+2))$sepch$((p+3))$sepch
fi
if [ $c1 == '7' ]
then
vlanlist=$vlanlist$((p+1))$sepch$((p+2))$sepch$((p+3))$sepch
fi
if [ $c1 == '8' ]
then
vlanlist=$vlanlist$((p+4))$sepch
fi
if [ $c1 == '9' ]
then
vlanlist=$vlanlist$((p+1))$sepch$((p+4))$sepch
fi
if [ $c1 == 'A' ]
then
vlanlist=$vlanlist$((p+2))$sepch$((p+4))$sepch
fi
if [ $c1 == 'B' ]
then
vlanlist=$vlanlist$((p+1))$sepch$((p+2))$sepch$((p+4))$sepch
fi
if [ $c1 == 'C' ]
then
vlanlist=$vlanlist$((p+3))$sepch$((p+4))$sepch
fi
if [ $c1 == 'D' ]
then
vlanlist=$vlanlist$((p+1))$sepch$((p+3))$sepch$((p+4))$sepch
fi
if [ $c1 == 'E' ]
then
vlanlist=$vlanlist$((p+2))$sepch$((p+3))$sepch$((p+4))$sepch
fi
if [ $c1 == 'F' ]
then
vlanlist=$vlanlist$((p+1))$sepch$((p+2))$sepch$((p+3))$sepch$((p+4))$sepch
fi
fi
if [ $c2 != '0' ]
then
if [ $c2 == '1' ]
then
vlanlist=$vlanlist$((p+5))$sepch
fi
if [ $c2 == '2' ]
then
vlanlist=$vlanlist$((p+6))$sepch
fi
if [ $c2 == '3' ]
then
vlanlist=$vlanlist$((p+5))$sepch$((p+6))$sepch
fi
if [ $c2 == '4' ]
then
vlanlist=$vlanlist$((p+7))$sepch
fi
if [ $c2 == '5' ]
then
vlanlist=$vlanlist$((p+5))$sepch$((p+7))$sepch
fi
if [ $c2 == '6' ]
then
vlanlist=$vlanlist$((p+6))$sepch$((p+7))$sepch
fi
if [ $c2 == '7' ]
then
vlanlist=$vlanlist$((p+5))$sepch$((p+6))$sepch$((p+7))$sepch
fi
if [ $c2 == '8' ]
then
vlanlist=$vlanlist$((p+8))$sepch
fi
if [ $c2 == '9' ]
then
vlanlist=$vlanlist$((p+5))$sepch$((p+8))$sepch
fi
if [ $c2 == 'A' ]
then
vlanlist=$vlanlist$((p+6))$sepch$((p+8))$sepch
fi
if [ $c2 == 'B' ]
then
vlanlist=$vlanlist$((p+5))$sepch$((p+6))$sepch$((p+8))$sepch
fi
if [ $c2 == 'C' ]
then
vlanlist=$vlanlist$((p+7))$sepch$((p+8))$sepch
fi
if [ $c2 == 'D' ]
then
vlanlist=$vlanlist$((p+5))$sepch$((p+7))$sepch$((p+8))$sepch
fi
if [ $c2 == 'E' ]
then
vlanlist=$vlanlist$((p+6))$sepch$((p+7))$sepch$((p+8))$sepch
fi
if [ $c2 == 'F' ]
then
vlanlist=$vlanlist$((p+5))$sepch$((p+6))$sepch$((p+7))$sepch$((p+8))$sepch
fi
fi

si=$((si+3))
ii=$((ii+1))
done
i=$((i+1))
done < $vlantemp





echo $ne_name','$IP',on,'$erpid','$erpname','$erpversion','$upperring','$ringstype','$ports0',,'$rplowns','$rplports','$revertive','$wtrtimer','$guardtimer','$controlvlan','$mep0',,'$mac','$rapsmeg','$rapsprio','$vlanlist',COMPLETED' >> $logfile

fi

currcount=$(( currcount + 1 ))
echo '<DIV STYLE="position: absolute; top:100px; left:400px; width:300; height:10"><progress value="'$currcount'" max="'$maxcurr'" ></progress></DIV>'

done < $erplist1



else
if [ $erpgeneral'a' == '1a' ] && [ $erpoff'a' == 'ona' ]
then
echo $ne_name','$IP',off,,,,,,,,,,,,,,,,,,,,COMPLETED' >> $logfile
fi
fi

else
echo ','$IP',,,,,,,,,,,,,,,,,,,,,FATAL' >> $logfile
fi

####
rm -rf $tmp
exit $error
