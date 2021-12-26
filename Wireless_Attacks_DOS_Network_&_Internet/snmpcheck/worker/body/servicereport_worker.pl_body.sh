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



function getnetmask {
netbit=$1
if (( $netbit == 32 ))
then
subnetmask='255.255.255.255'
elif (( $netbit == 31 ))
then
subnetmask='255.255.255.254'
elif (( $netbit == 30 ))
then
subnetmask='255.255.255.252'
elif (( $netbit == 29 ))
then
subnetmask='255.255.255.248'
elif (( $netbit == 28 ))
then
subnetmask='255.255.255.240'
elif (( $netbit == 27 ))
then
subnetmask='255.255.255.224'
elif (( $netbit == 26 ))
then
subnetmask='255.255.255.192'
elif (( $netbit == 25 ))
then
subnetmask='255.255.255.128'
elif (( $netbit == 24 ))
then
subnetmask='255.255.255.0'
elif (( $netbit == 23 ))
then
subnetmask='255.255.254.0'
elif (( $netbit == 22 ))
then
subnetmask='255.255.252.0'
elif (( $netbit == 21 ))
then
subnetmask='255.255.248.0'
elif (( $netbit == 20 ))
then
subnetmask='255.255.240.0'
elif (( $netbit == 19 ))
then
subnetmask='255.255.224.0'
elif (( $netbit == 18 ))
then
subnetmask='255.255.192.0'
elif (( $netbit == 17 ))
then
subnetmask='255.255.128.0'
elif (( $netbit == 16 ))
then
subnetmask='255.255.0.0'
elif (( $netbit == 15 ))
then
subnetmask='255.254.0.0'
elif (( $netbit == 14 ))
then
subnetmask='255.252.0.0'
elif (( $netbit == 13 ))
then
subnetmask='255.248.0.0'
elif (( $netbit == 12 ))
then
subnetmask='255.240.0.0'
elif (( $netbit == 11 ))
then
subnetmask='255.224.0.0'
elif (( $netbit == 10 ))
then
subnetmask='255.192.0.0'
elif (( $netbit == 9 ))
then
subnetmask='255.128.0.0'
elif (( $netbit == 8 ))
then
subnetmask='255.0.0.0'
elif (( $netbit == 7 ))
then
subnetmask='254.0.0.0'
elif (( $netbit == 6 ))
then
subnetmask='252.0.0.0'
elif (( $netbit == 5 ))
then
subnetmask='248.0.0.0'
elif (( $netbit == 4 ))
then
subnetmask='240.0.0.0'
elif (( $netbit == 3 ))
then
subnetmask='224.0.0.0'
elif (( $netbit == 2 ))
then
subnetmask='192.0.0.0'
elif (( $netbit == 1 ))
then
subnetmask='128.0.0.0'
elif (( $netbit == 0 ))
then
subnetmask='0.0.0.0'
else
subnetmask='N/A'
fi
}

function convertntptime {
ntptime=$1

if (( $ntptime == 4 ))
then
ntptimes='16 [s]'
elif (( $ntptime == 5 ))
then
ntptimes='32 [s]'
elif (( $ntptime == 6 ))
then
ntptimes='1 [min] 4 [s] (64 [s])'
elif (( $ntptime == 7 ))
then
ntptimes='2 [min] 8 [s] (128 [s])'
elif (( $ntptime == 8 ))
then
ntptimes='4 [min] 16 [s] (256 [s])'
elif (( $ntptime == 9 ))
then
ntptimes='8 [min] 32 [s] (512 [s])'
elif (( $ntptime == 10 ))
then
ntptimes='17 [min] 4 [s] (1024 [s])'
elif (( $ntptime == 11 ))
then
ntptimes='34 [min] 8 [s] (2048 [s])'
elif (( $ntptime == 12 ))
then
ntptimes='1 [h] 8 [min] 16 [s] (4096 [s])'
elif (( $ntptime == 13 ))
then
ntptimes='2 [h] 16 [min] 32 [s] (8192 [s])'
elif (( $ntptime == 14 ))
then
ntptimes='4 [h] 33 [min] 4 [s] (16384 [s])'
elif (( $ntptime == 15 ))
then
ntptimes='9 [h] 6 [min] 8 [s] (32768 [s])'
elif (( $ntptime == 16 ))
then
ntptimes='18 [h] 12 [min] 16 [s] (65536 [s])'
elif (( $ntptime == 17 ))
then
ntptimes='36 [h] 24 [min] 32 [s] (131072 [s])'
else
ntptimes='N/A'
fi
}



###########  begin



accessible=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r 2 -t 3 -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.1.1.1.11.1 2>/dev/null`
lengthaccessible=${#accessible}
if (($lengthaccessible != 0))
then
ne_type=`echo $accessible | cut -d ' ' -f 2`

ne_name=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.1.1.1.3.1 2>/dev/null | cut -d '"' -f 2`

#SNMP service section
#-------------------------------------------------------------------------------------------------------------------------
snmpv12cstatus=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.11.1.1.3.1 2>/dev/null | cut -d ' ' -f 2`
if [ $snmpv12cstatus'a' == 'a' ]
then
error=1
snmpv12cstatus='unknown'
elif [ $snmpv12cstatus'a' == '1a' ]
then
snmpv12cstatus='disabled'
elif [ $snmpv12cstatus'a' == '2a' ]
then
snmpv12cstatus='enabled'
else
snmpv12cstatus='N/A'
fi

snmpv3status=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.11.1.1.4.1 2>/dev/null | cut -d ' ' -f 2`
if [ $snmpv3status'a' == 'a' ]
then
error=1
snmpv3status='unknown'
elif [ $snmpv3status'a' == '1a' ]
then
snmpv3status='disabled'
elif [ $snmpv3status'a' == '2a' ]
then
snmpv3status='enabled'
else
snmpv3status='N/A'
fi

updport=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.11.1.1.5.1 2>/dev/null | cut -d ' ' -f 2`
if [ $updport'a' == 'a' ]
then
error=1
updport='unknown'
fi

snmp1=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.11.2.1.7.1 2>/dev/null | cut -d ' ' -f 2`

if [ $snmp1'a' == 'a' ]
then
error=1
communityname='unknown'
accesslevel='unknown'
accesscontrol='unknown'
sourceip='unknown'
subnetmask='unknown'
elif [ $snmp1'a' == '1a' ]
then
communityname=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.11.2.1.3.1 2>/dev/null | cut -d '"' -f 2`
accesslevel=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.11.2.1.4.1 2>/dev/null | cut -d ' ' -f 2`
if [ $accesslevel'a' == 'a' ]
then
error=1
accesslevel='unknown'
elif [ $accesslevel'a' == '1a' ]
then
accesslevel='OPERATOR'
elif [ $accesslevel'a' == '2a' ]
then
accesslevel='CONFIG'
elif [ $accesslevel'a' == '3a' ]
then
accesslevel='ADMIN'
else
accesslevel='N/A'
fi

sourceip=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.11.2.1.5.1 2>/dev/null | cut -d ' ' -f 2`
if [ $sourceip'a' == 'a' ]
then
error=1
sourceip='unknown'
fi

subnetmaskbit=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.11.2.1.6.1 2>/dev/null | cut -d ' ' -f 2`
if [ $subnetmaskbit'a' == 'a' ]
then
error=1
subnetmask='unknown'
else
getnetmask $subnetmaskbit
fi

if [ $sourceip'a' == 'unknowna' ] || [ $subnetmask'a' == 'unknowna' ]
then
accesscontrol='unknown'
elif [ $sourceip'a' == '0.0.0.0a' ] && [ $subnetmaskbit'a' == '0a' ]
then
accesscontrol='disabled'
else
accesscontrol='enabled'
fi

else
communityname=''
accesslevel=''
accesscontrol=''
sourceip=''
subnetmask=''
fi


#NTP section
#-------------------------------------------------------------------------------------------------------------------------
ntpservice=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.4.1.1.3.1 2>/dev/null | cut -d ' ' -f 2`
if [ $ntpservice'a' == 'a' ]
then
error=1
ntpservice='unknown'
elif [ $ntpservice'a' == '1a' ]
then
ntpservice='disabled'
elif [ $ntpservice'a' == '2a' ]
then
ntpservice='enabled'
else
ntpservice='N/A'
fi

ntpservermode=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.4.1.1.4.1 2>/dev/null | cut -d ' ' -f 2`
if [ $ntpservermode'a' == 'a' ]
then
error=1
ntpservermode='unknown'
elif [ $ntpservermode'a' == '1a' ]
then
ntpservermode='unicast'
elif [ $ntpservermode'a' == '2a' ]
then
ntpservermode='multicast'
elif [ $ntpservermode'a' == '3a' ]
then
ntpservermode='disabled'
else
ntpservermode='N/A'
fi

ntpclientmode=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.4.1.1.5.1 2>/dev/null | cut -d ' ' -f 2`
if [ $ntpclientmode'a' == 'a' ]
then
error=1
ntpclientmode='unknown'
elif [ $ntpclientmode'a' == '1a' ]
then
ntpclientmode='unicast'
elif [ $ntpclientmode'a' == '2a' ]
then
ntpclientmode='multicast'
elif [ $ntpclientmode'a' == '3a' ]
then
ntpclientmode='disabled'
else
ntpclientmode='N/A'
fi

stratum=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.4.1.1.6.1 2>/dev/null | cut -d ' ' -f 2`
if [ $stratum'a' == 'a' ]
then
error=1
stratum='unknown'
fi

multicastport=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.4.1.1.7.1 2>/dev/null | cut -d ' ' -f 2`
if [ $multicastport'a' == 'a' ]
then
error=1
multicastport='unknown'
else
multicastport='Bridge '$((multicastport-10))
fi


multicastinterval=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.4.1.1.8.1 2>/dev/null | cut -d ' ' -f 2`
if [ $multicastinterval'a' == 'a' ]
then
error=1
multicastinterval='unknown'
else
convertntptime $multicastinterval
multicastinterval=$ntptimes
fi



if [ $ntpservice == 'enabled' ]
then

#---------------------------------- Workaround for NTP server IP addresses -----------------------------------------------------

snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.6.1.1.1.3.1 2>/dev/null | cut -d '"' -f 2-1000 > ntpstat.txt
ntp1ip='0.0.0.0'
ntp2ip='0.0.0.0'
ntp3ip='0.0.0.0'
ntp4ip='0.0.0.0'
i=0
ntpnum=1
while read line
do
i=$((i+1))
if (( $i >= 3 ))
then
if [ "$line"'a' != 'a' ]
then

ntpstatus=`echo $line | cut -b 1`
if [ $ntpstatus'a' == '*a' ]
then
ntpstatus='Selected'
ntpentry=1
ntpok=1
startchar=2
elif [ $ntpstatus'a' == '+a' ]
then
ntpstatus='Candidate'
ntpentry=1
ntpok=1
startchar=2
else
ntpstatus='Configured'
ntpentry=1
startchar=1
fi
newline=`echo $line | cut -b $startchar-1000`
ntpserver=`echo $newline | cut -d ' ' -f 1`
if [ $ntpserver'a' != '224.0.1.1a' ]
then
eval 'ntp'$ntpnum'ip='$ntpserver
ntpnum=$((ntpnum+1))
fi
fi
fi
done < ntpstat.txt

#------------------------------------ End of workaround --------------------------------------------------------------------------------





ntp1version=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.4.2.1.4.1 2>/dev/null | cut -d ' ' -f 2`
if [ $ntp1version'a' == 'a' ]
then
error=1
ntp1version='unknown'
fi
ntp1polling=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.4.2.1.5.1 2>/dev/null | cut -d ' ' -f 2`
if [ $ntp1polling'a' == 'a' ]
then
error=1
ntp1polling='unknown'
else
convertntptime $ntp1polling
ntp1polling=$ntptimes
fi


ntp2version=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.4.2.1.4.2 2>/dev/null | cut -d ' ' -f 2`
if [ $ntp2version'a' == 'a' ]
then
error=1
ntp2version='unknown'
fi
ntp2polling=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.4.2.1.5.2 2>/dev/null | cut -d ' ' -f 2`
if [ $ntp2polling'a' == 'a' ]
then
error=1
ntp2polling='unknown'
else
convertntptime $ntp2polling
ntp2polling=$ntptimes
fi


ntp3version=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.4.2.1.4.3 2>/dev/null | cut -d ' ' -f 2`
if [ $ntp3version'a' == 'a' ]
then
error=1
ntp3version='unknown'
fi
ntp3polling=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.4.2.1.5.3 2>/dev/null | cut -d ' ' -f 2`
if [ $ntp3polling'a' == 'a' ]
then
error=1
ntp3polling='unknown'
else
convertntptime $ntp3polling
ntp3polling=$ntptimes
fi



ntp4version=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.4.2.1.4.4 2>/dev/null | cut -d ' ' -f 2`
if [ $ntp4version'a' == 'a' ]
then
error=1
ntp4version='unknown'
fi
ntp4polling=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.4.2.1.5.4 2>/dev/null | cut -d ' ' -f 2`
if [ $ntp4polling'a' == 'a' ]
then
error=1
ntp4polling='unknown'
else
convertntptime $ntp4polling
ntp4polling=$ntptimes
fi


else

ntp1ip=''
ntp1version=''
ntp1polling=''
ntp2ip=''
ntp2version=''
ntp2polling=''
ntp3ip=''
ntp3version=''
ntp3polling=''
ntp4ip=''
ntp4version=''
ntp4polling=''

fi

#------------------------------------------------------------------------------------------------------------------------

ftpstatus=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.7.1.1.3.1 2>/dev/null | cut -d ' ' -f 2`
if [ $ftpstatus'a' == 'a' ]
then
error=1
ftpstatus='unknown'
elif [ $ftpstatus'a' == '1a' ]
then
ftpstatus='disabled'
elif [ $ftpstatus'a' == '2a' ]
then
ftpstatus='enabled'
elif [ $ftpstatus'a' == '3a' ]
then
ftpstatus='Always enabled'
else
ftpstatus='N/A'
fi

tcpcommand=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.7.1.1.4.1 2>/dev/null | cut -d ' ' -f 2`
if [ $tcpcommand'a' == 'a' ]
then
error=1
tcpcommand='unknown'
fi

tcpdata=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.7.1.1.5.1 2>/dev/null | cut -d ' ' -f 2`
if [ $tcpdata'a' == 'a' ]
then
error=1
tcpdata='unknown'
fi

maxsession=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.7.1.1.6.1 2>/dev/null | cut -d ' ' -f 2`
if [ $maxsession'a' == 'a' ]
then
error=1
maxsession='unknown'
fi

autostop=`snmpget -v 3 -a $snmpapro -u $snmpuser -A $snmpap -x $snmppro -X $snmppk -l $snmplevel -r $snmpr -t $snmpt -Ov $IP .1.3.6.1.4.1.119.2.3.69.5.3.7.1.1.7.1 2>/dev/null | cut -d ' ' -f 2`
if [ $autostop'a' == 'a' ]
then
error=1
autostop='unknown'
elif [ $autostop'a' == '1a' ]
then
autostop='disabled'
elif [ $autostop'a' == '2a' ]
then
autostop='enabled'
else
autostop='N/A'
fi



#-------------------------------------------------------------------------------------------------------------------------


if (( $error == 0 ))
then
result='COMPLETED'
else
result='ERROR'
fi

echo $ne_name','$ne_type','$IP','$result','$snmpv12cstatus','$snmpv3status','$updport','$communityname','$accesslevel','$accesscontrol','$sourceip','$subnetmask','$ntpservice','$ntpservermode','$ntpclientmode','$stratum','$multicastport','$multicastinterval','$ntp1ip','$ntp1version','$ntp1polling','$ntp2ip','$ntp2version','$ntp2polling','$ntp3ip','$ntp3version','$ntp3polling','$ntp4ip','$ntp4version','$ntp4polling','$ftpstatus','$tcpcommand','$tcpdata','$maxsession','$autostop >> $logfile


else
 echo ','$ne_type','$IP',FATAL,inaccessble' >> $logfile
 error=1
fi


####
rm -rf $tmp
exit $error
