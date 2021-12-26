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


profnumback=$profnum

if (( "$Que_num" == "1" ))
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
else
echo $ne_name','$IP',Number of queue set to '$quenum' unsuccessful,ERROR' >> $logfile
error=1
fi

else
echo $ne_name','$IP',Number of queue set to '$quenum' was not allowed,SKIPPED' >> $logfile
fi

result=`snmpset -v 3 -a MD5 -u Admin -A password01 -x DES -X password02 -l AuthPriv -r 2 -t 10 -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.1.1.5.1 i 1 2>/dev/null | cut -d ' ' -f 2`
if [ $result'a' == '1a' ]
then
echo $ne_name','$IP',Equipment mode set successfully,COMPLETED' >> $logfile

actprofile=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP 1.3.6.1.4.1.119.2.3.69.501.5.21.1.1.3.1 2>/dev/null | cut -d ' ' -f 2`
if [ $actprofile'a' != 'a' ]
then
if (( $actprofile <= 3 )) && (( $actprofile >= 0 ))
then

if (( $actprofile == $profnum )) && [ $proselect'a' == 'a' ]
then
echo $ne_name','$IP',active profile number same as selected and automatic selection not allowed,FATAL,'$profnum >> $logfile
error=1
else

if (( $actprofile == $profnum ))
then
profnum=$((profnum+1))
if (( $profnum == 4 ))
then
profnum=1
fi
fi


delok=0

if [ $delpro'a' == 'ona' ]
then
i=1
while (( $i <=63 ))
do

if (( $delok == 0 ))
then
delres=`snmpset -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.2.1.7.$profnum.$i i 6 2>/dev/null | cut -d ' ' -f 2`
fi

if [ $delres'a' != '6a' ]
then
delok=1
error=1
i=63
echo $ne_name','$IP',entry cannot be deleted during table clean-up,FATAL,'$profnum','$i >> $logfile
fi
i=$((i+1))


done

if (( $delok == 0 ))
then
echo $ne_name','$IP',all 63 entries were deleted successfully,COMPLETED,'$profnum >> $logfile
fi

else


echo $ne_name','$IP',QoS table cleanup was not allowed,SKIPPED,'$profnum >> $logfile
fi

if (( $delok == 0 ))
then

i=1
while (( $i <= 64 ))
do
entvar="entcf=""$""ent"$i"cf"
eval "$entvar"
entvar="entcp=""$""ent"$i"cp"
eval "$entvar"
entvar="entcip=""$""ent"$i"cip"
eval "$entvar"

if [ $entcf'a' == '0a' ] || [ $entcp'a' == 'a' ] || [ $entcip'a' == 'a' ]
then
echo $ne_name','$IP',entry was skipped because not all parameter were defined,EMPTY,'$profnum','$i >> $logfile
else

delentok=0
if [ $delpro'a' != 'ona' ]
then
delres=`snmpset -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.2.1.7.$profnum.$i i 6 2>/dev/null | cut -d ' ' -f 2`

if [ $delres'a' != '6a'] && [ $delres'a' != 'Sucha' ]
then
delentok=1
error=1
fi
fi
if (( $delentok == 0 ))
then

if (( $i < 64 ))
then
setok=`snmpset -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.2.1.4.$profnum.$i i $entcf .1.3.6.1.4.1.119.2.3.69.501.5.21.2.1.5.$profnum.$i i $entcp .1.3.6.1.4.1.119.2.3.69.501.5.21.2.1.6.$profnum.$i i $entcip .1.3.6.1.4.1.119.2.3.69.501.5.21.2.1.7.$profnum.$i i 4 2>/dev/null | tr -d "\n" | cut -d ' ' -f 5`
else
setok=`snmpset -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.2.1.4.$profnum.$i i $entcf .1.3.6.1.4.1.119.2.3.69.501.5.21.2.1.5.$profnum.$i i $entcp .1.3.6.1.4.1.119.2.3.69.501.5.21.2.1.6.$profnum.$i i $entcip .1.3.6.1.4.1.119.2.3.69.501.5.21.2.1.7.$profnum.$i i 1 2>/dev/null | tr -d "\n" | cut -d ' ' -f 5`
fi

if [ $setok'a' != 'a' ]
then
echo $ne_name','$IP',entry setting was successful,COMPLETED,'$profnum','$i >> $logfile
else
echo $ne_name','$IP',entry cannot be set,ERROR,'$profnum','$i >> $logfile
error=1
fi
else
echo $ne_name','$IP',entry was not set because existing entry cannot be deleted,ERROR,'$profnum','$i >> $logfile
error=1
fi
fi


i=$((i+1))
done

if [ $actpro'a' == 'ona' ] && (( $error == 0 ))
then

activationok=`snmpset -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.501.5.21.1.1.3.1 i $profnum 2>/dev/null | cut -d ' ' -f 2`

if [ $activationok'a' == $profnum'a' ]
then
echo $ne_name','$IP',profile was activated successfully,COMPLETED,'$profnum >> $logfile
else
echo $ne_name','$IP',profile activation was not successful,ERROR,'$profnum >> $logfile
error=1
fi


else

if (( $error == 0 ))
then
echo $ne_name','$IP',profile activation was not allowed,SKIPPED,'$profnum >> $logfile
else
echo $ne_name','$IP',profile activation was not executed due to some error,ERROR,'$profnum >> $logfile
fi
fi

fi
fi

else
echo $ne_name','$IP',active profile number cannot be recognized,FATAL' >> $logfile
fi
else
echo $ne_name','$IP',active profile number cannot be recognized,FATAL' >> $logfile
error=1
fi

else
echo $ne_name','$IP',Equipment mode set unsuccessful,FATAL' >> $logfile
error=1
fi

else
echo $ne_name','$IP',inaccessible,FATAL' >> $logfile
error=1
fi


####
rm -rf $tmp
exit $error

