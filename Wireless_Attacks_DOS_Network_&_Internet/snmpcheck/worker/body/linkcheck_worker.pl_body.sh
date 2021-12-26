#!/bin/bash
params=''
while read varpost
do
varpost=`echo $varpost | tr -d "\r" | cut -f1`
params=$params"$varpost"'&'
export "$varpost"
done

while read env
do
export $env
done < config.ini

echo `date +%F_%H-%M-%S`'&'$REMOTE_ADDR'&'$REMOTE_PORT'&'$params >> $basedir/log/linkcheck_operation.log
authenticated=`echo $HTTP_REFERER | cut -d '/' -f 5`
if [ $authenticated'a' != 'no_auth.cgi?application=linkchecka' ]
then
echo 'Content-type: text/html'
echo ''
echo '<HTML>'
echo '<HEAD><TITLE>iPasolink link check tool authorization failed</TITLE></HEAD>'
echo 'Please use following link:'
echo '<BR>'
echo '<a href="/bulktool/index.html">Bulktool main page</a>'
echo '</HTML>'
exit
fi

export workdir=$basedir'/temp/linkcheck'`echo $$`
rm -rf $workdir 2>/dev/null
mkdir $workdir
cd $workdir
export logfile=$basedir'/temp/linkcheck_'`date +%Y-%m-%d_%H-%M-%S`'_'`echo $$`'_log.csv'
export logfilename='linkcheck_'`date +%Y-%m-%d_%H-%M-%S`'_'`echo $$`'_log.csv'
export htmlfilename='linkcheck_'`date +%Y-%m-%d_%H-%M-%S`'_'`echo $$`'.html'

export IP1,IP2
export workdir
export subgroup

echo 'Content-type: text/html;'
echo ''
echo '<META HTTP-EQUIV="REFRESH" CONTENT="2 ; URL=/bulktool/'$htmlfilename'">'
echo '<HTML>'
echo 'Preparing for run'
echo '</HTML>'

echo '' > $htmlhome'/bulktool/'$htmlfilename'1.html'
echo '' > $htmlhome'/bulktool/'$htmlfilename'2.html'
echo '' > $htmlhome'/bulktool/'$htmlfilename'3.html'
echo '' > $htmlhome'/bulktool/'$htmlfilename'4.html'
echo '' > $htmlhome'/bulktool/'$htmlfilename'5.html'
echo '' > $htmlhome'/bulktool/'$htmlfilename'6.html'
echo '' > $htmlhome'/bulktool/'$htmlfilename'7.html'

echo 'Running for '$runlength' seconds' > $htmlhome'/bulktool/'$htmlfilename'counter.html'

echo '' > $htmlhome'/bulktool/'$htmlfilename'101.html'
echo '' > $htmlhome'/bulktool/'$htmlfilename'102.html'
echo '' > $htmlhome'/bulktool/'$htmlfilename'103.html'
echo '' > $htmlhome'/bulktool/'$htmlfilename'104.html'
echo '' > $htmlhome'/bulktool/'$htmlfilename'105.html'
echo '' > $htmlhome'/bulktool/'$htmlfilename'106.html'
echo '' > $htmlhome'/bulktool/'$htmlfilename'107.html'


echo '<META HTTP-EQUIV="REFRESH" CONTENT="'$refreshrate' ; URL=/bulktool/'$htmlfilename'">' > $htmlhome'/bulktool/'$htmlfilename
echo '<HTML>' >> $htmlhome'/bulktool/'$htmlfilename
echo 'Link status check tool is running ' >> $htmlhome'/bulktool/'$htmlfilename

echo '<DIV STYLE="position: absolute; top:5px; left:300px; width:300; height:50">' >> $htmlhome'/bulktool/'$htmlfilename
echo '<FORM ACTION="/cgi-bin/linkcheckstop.cgi" METHOD="POST" ENCTYPE="text/plain">' >> $htmlhome'/bulktool/'$htmlfilename
echo '<INPUT TYPE="submit" VALUE="Stop">' >> $htmlhome'/bulktool/'$htmlfilename
echo '<input TYPE="hidden" NAME="htmlfilename" VALUE="'$htmlfilename'">' >> $htmlhome'/bulktool/'$htmlfilename
echo '<input TYPE="hidden" NAME="workdir" VALUE="'$workdir'">' >> $htmlhome'/bulktool/'$htmlfilename
echo '<input TYPE="hidden" NAME="googletrick" VALUE="jfgc">' >> $htmlhome'/bulktool/'$htmlfilename
echo '</FORM>' >> $htmlhome'/bulktool/'$htmlfilename
echo '</DIV>' >> $htmlhome'/bulktool/'$htmlfilename



echo '<object STYLE="position: absolute; top:50px; left:0px; height: 500px; width: 500px; " type="text/html" data="'$htmlfilename'1.html"></object>' >> $htmlhome'/bulktool/'$htmlfilename
echo '<object STYLE="position: absolute; top:150px; left:0px; height: 500px; width: 500px; " type="text/html" data="'$htmlfilename'2.html"></object>' >> $htmlhome'/bulktool/'$htmlfilename
echo '<object STYLE="position: absolute; top:250px; left:0px; height: 500px; width: 500px; " type="text/html" data="'$htmlfilename'3.html"></object>' >> $htmlhome'/bulktool/'$htmlfilename
echo '<object STYLE="position: absolute; top:350px; left:0px; height: 500px; width: 500px; " type="text/html" data="'$htmlfilename'4.html"></object>' >> $htmlhome'/bulktool/'$htmlfilename
echo '<object STYLE="position: absolute; top:450px; left:0px; height: 500px; width: 500px; " type="text/html" data="'$htmlfilename'5.html"></object>' >> $htmlhome'/bulktool/'$htmlfilename
echo '<object STYLE="position: absolute; top:550px; left:0px; height: 500px; width: 500px; " type="text/html" data="'$htmlfilename'6.html"></object>' >> $htmlhome'/bulktool/'$htmlfilename
echo '<object STYLE="position: absolute; top:650px; left:0px; height: 500px; width: 500px; " type="text/html" data="'$htmlfilename'7.html"></object>' >> $htmlhome'/bulktool/'$htmlfilename

echo '<object STYLE="position: absolute; top:0px; left:450px;" type="text/html" data="'$htmlfilename'counter.html"></object>' >> $htmlhome'/bulktool/'$htmlfilename

echo '<object STYLE="position: absolute; top:50px; left:550px; height: 500px; width: 500px; " type="text/html" data="'$htmlfilename'101.html"></object>' >> $htmlhome'/bulktool/'$htmlfilename
echo '<object STYLE="position: absolute; top:150px; left:550px; height: 500px; width: 500px;" type="text/html" data="'$htmlfilename'102.html"></object>' >> $htmlhome'/bulktool/'$htmlfilename
echo '<object STYLE="position: absolute; top:250px; left:550px; height: 500px; width: 500px; " type="text/html" data="'$htmlfilename'103.html"></object>' >> $htmlhome'/bulktool/'$htmlfilename
echo '<object STYLE="position: absolute; top:350px; left:550px; height: 500px; width: 500px; " type="text/html" data="'$htmlfilename'104.html"></object>' >> $htmlhome'/bulktool/'$htmlfilename
echo '<object STYLE="position: absolute; top:450px; left:550px; height: 500px; width: 500px; " type="text/html" data="'$htmlfilename'105.html"></object>' >> $htmlhome'/bulktool/'$htmlfilename
echo '<object STYLE="position: absolute; top:550px; left:550px; height: 500px; width: 500px; " type="text/html" data="'$htmlfilename'106.html"></object>' >> $htmlhome'/bulktool/'$htmlfilename
echo '<object STYLE="position: absolute; top:650px; left:550px; height: 500px; width: 500px; " type="text/html" data="'$htmlfilename'107.html"></object>' >> $htmlhome'/bulktool/'$htmlfilename



echo '</HTML>' >> $htmlhome'/bulktool/'$htmlfilename
nohup $basedir'/cgi-bin/'linkcheck.cgi.worker >/dev/null 2>/dev/null &

