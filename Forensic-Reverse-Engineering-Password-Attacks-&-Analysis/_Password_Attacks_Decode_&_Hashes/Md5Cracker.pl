#!/usr/bin/perl
# use strict; Sorry next time i'll use it ;)
# MD5 Hash Bruteforce Kit
# by Iman Karim (iman.karim@smail.inf.fh-bonn-rhein-sieg.de)
# URL : http://home.inf.fh-rhein-sieg.de/~ikarim2s/
# Date : 11.02.2007
# Info[0] : This Cracker is by far not the fastest! But it helped me alot to find "lost" passwords ;)
# Info[1] : Written under Kubuntu Linux (Throw away Windows!)
# Info[2] : If you can code a bit perl, you can modify it to crack sha etc too...
# Greets to: Invisible!
$ver = "01";
$dbgtmr = "1"; #Intervall of showing the current speed + lastpassword in seconds.

if ($dbgtmr<=0){ die "Set dbgtmr to a value >=1 !\n";};
use Digest::MD5 qw(md5_hex);
use Time::HiRes qw(gettimeofday);

if ($ARGV[0]=~"a") {
 $alpha = "abcdefghijklmnopqrstuvwxyz";}
if ($ARGV[0]=~"A") {
 $alpha = $alpha. "ABCDEFGHIJKLMNOPQRSTUVWXYZ";}
if ($ARGV[0]=~"d") {
 $alpha = $alpha."1234567890";}
if ($ARGV[0]=~"x") {
 $alpha = $alpha. "!\"\$%&/()=?-.:\\*'-_:.;,";}

if ($alpha eq "" or $ARGV[3] eq "") {usage();};
if (length($ARGV[3]) != 32) { die "Sorry but it seems that the MD5 is not valid!\n";};

print "Selected charset for attack: '$alpha\'\n";
print "Going to Crack '$ARGV[3]'...\n";

for (my $t=$ARGV[1];$t<=$ARGV[2];$t++){
 crack ($t);
}

sub usage{
print " #############################################################################\n";
print " # MD5 Hash Bruteforce Kit v_$ver                                              #\n";
print " # by Iman Karim (iman.karim\@smail.inf.fh-bonn-rhein-sieg.de)                 #\n";
print " # http:\/\/home.inf.fh-rhein-sieg.de\/~ikarim2s\                                 #\n";
print " #                                                                            #\n";
print " # Usage: perl Md5Cracker.pl <setChar> <minChar> <maxChar> <hashMD5>        #\n";
print " # Character options: a - small letters # a,b,c                               #\n";
print " #                    A - big letters   # A,B,C                               #\n";
print " #                    n - numbers       # 1,2,3                               #\n";
print " #                    s - symbols       # !,#,@                               #\n";
print " # Example: ./Md5Cracker.pl aAns 1 4 900150983cd24fb0d6963f7d28e17f72       #\n";
print " #                                                                            #\n";
print " #############################################################################\n";
sys.exit(1)
}

sub crack{
 $CharSet = shift;
 @RawString = ();
 for (my $i =0;$i<$CharSet;$i++){ $RawString[i] = 0;}
 $Start = gettimeofday();
 do{
  for (my $i =0;$i<$CharSet;$i++){
   if ($RawString[$i] > length($alpha)-1){
    if ($i==$CharSet-1){
    print "Bruteforcing done with $CharSet Chars. No Results.\n";
    $cnt=0;
    return false;
   }
   $RawString[$i+1]++;
   $RawString[$i]=0;
   }
  }
###################################################
   $ret = "";
   for (my $i =0;$i<$CharSet;$i++){ $ret = $ret . substr($alpha,$RawString[$i],1);}
   $hash = md5_hex($ret);
   $cnt++;
   $Stop = gettimeofday();
   if ($Stop-$Start>$dbgtmr){
    $cnt = int($cnt/$dbgtmr);
    print "$cnt hashes\\second.\tLast Pass '$ret\'\n";
    $cnt=0;
    $Start = gettimeofday();
   }
            print "$ARGV[3] != $hash ($ret)\n";
   if ($ARGV[3] eq $hash){
    die "\n**** Password Cracked! => $ret\n";
   }
###################################################
  #checkhash($CharSet)."\n";

  $RawString[0]++;
 }while($RawString[$CharSet-1]<length($alpha));
}

sub checkhash{
 $CharSet = shift;
 $ret = "";
 for (my $i =0;$i<$CharSet;$i++){ $ret = $ret . substr($alpha,$RawString[$i],1);}
 $hash = md5_hex($ret);
 $cnt++;
 $Stop = gettimeofday();
 if ($Stop-$Start>$dbgtmr){
  $cnt = int($cnt/$dbgtmr);
  print "$cnt hashes\\second.\tLast Pass '$ret\'\n";
  $cnt=0;
  $Start = gettimeofday();
 }

 if ($ARGV[3] eq $hash){
  die "\n**** Password Cracked! => $ret\n";
 }
 
}