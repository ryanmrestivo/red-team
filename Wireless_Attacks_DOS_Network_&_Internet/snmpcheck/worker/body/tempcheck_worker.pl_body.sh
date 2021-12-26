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



accessible=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.1.1.1.11.1 2>/dev/null | cut -d ' ' -f 2`
lengthaccessible=${#accessible}
if (($lengthaccessible != 0))
then
error=0
ne_type=$accessible
ne_name=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.1.1.1.3.1 2>/dev/null | cut -d '"' -f 2`

if [ $ne_type'a' == '1000a' ]
then
main1=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.3.35.2.1.12.17 2>/dev/null | cut -d ' ' -f 2`
main2=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.3.35.2.1.12.18 2>/dev/null | cut -d ' ' -f 2`
if [ $main1'a' != '-999a' ] && [ $main1'a' != 'Sucha' ]
then
t10=$((main1/10))
t11=$((main1-t10*10))
t1=$t10'.'$t11
else
t1=''
fi
if [ $main2'a' != '-999a' ] && [ $main2'a' != 'Sucha' ]
then
t20=$((main2/10))
t21=$((main2-t20*10))
t2=$t20'.'$t21
else
t2=''
fi

else
main1=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.3.3.1.1.13.1 2>/dev/null | cut -d ' ' -f 2`
if [ $main1'a' != '-999a' ]
then
t10=$((main1/10))
t11=$((main1-t10*10))
t1=$t10'.'$t11
t2=''
else
t1=''
t2=''
fi
fi

i=1
while (( $i <= 14 ))
do
eval 'modem'$i'=""'
eval 'odu'$i'=""'
i=$((i+1))
done

# if not AOR

if [ $ne_type'a' != '520a' ] && [ $ne_type'a' != '451a' ]
then

i=1
if [ $ne_type'a' == '1000a' ]
then
iend=14
else
iend=4
fi

while (( $i <= $iend ))
do
ii=$(((i+1)*8388608+65536))
modemex=`snmpget -v 3 -a MD5 -u Admin -A password01 -x DES -X password02 -l AuthPriv -r 3 -t 1 -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.8.1.1.11.$ii 2>/dev/null | cut -d ' ' -f 2`
if [ $modemex'a' != 'a' ]
then
if [ $modemex'a' == '1a' ]
then

modem=`snmpget -v 3 -a MD5 -u Admin -A password01 -x DES -X password02 -l AuthPriv -r 3 -t 1 -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.8.1.1.12.$ii 2>/dev/null | cut -d ' ' -f 2`

# Exclude iPasolink type(s) were modem temperature unavailable

if [ $ne_type'a' == '450a' ]
then
modem='N/A'
fi

if [ $modem'a' != 'a' ]
then
eval 'modem'$i'='$modem
else
eval 'modem'$i'="unknown"'
error=1
fi

oduex=`snmpget -v 3 -a MD5 -u Admin -A password01 -x DES -X password02 -l AuthPriv -r 3 -t 1 -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.8.1.1.9.$ii 2>/dev/null | cut -d ' ' -f 2`
if [ $oduex'a' == '1a' ]
then
odu=`snmpget -v 3 -a MD5 -u Admin -A password01 -x DES -X password02 -l AuthPriv -r 3 -t 1 -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.8.1.1.10.$ii 2>/dev/null | cut -d ' ' -f 2`

if [ $odu'a' != 'a' ]
then
eval 'odu'$i'='$odu
else
eval 'odu'$i'="unknown"'
error=1
fi

elif [ $oduex'a' == '0a' ]
then
eval 'odu'$i'="invalid"'
elif [ $oduex'a' == 'a' ] 
then
eval 'odu'$i'="unknown"'
error=1
fi

fi

else
eval 'modem'$i'="N/A"'
eval 'odu'$i'="N/A"'
error=1
fi

i=$((i+1))
done

# if AOR
fi

if (( $error == 0 ))
then
result='COMPLETED'
else
result='ERROR'
fi

echo $ne_name','$IP','$ne_type','$t1','$t2','$result','$modem1','$odu1','$modem2','$odu2','$modem3','$odu3','$modem4','$odu4','$modem5','$odu5','$modem6','$odu6','$modem7','$odu7','$modem8','$odu8','$modem9','$odu9','$modem10','$odu10','$modem11','$odu11','$modem12','$odu12','$modem13','$odu13','$modem14','$odu14 >> $logfile
else
 echo ','$IP',,,,FATAL' >> $logfile
 error=1
fi

####
rm -rf $tmp
exit $error

