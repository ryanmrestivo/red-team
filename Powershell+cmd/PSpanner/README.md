# PSpanner

![Securethelogs.com](https://ctrla1tdel.files.wordpress.com/2020/01/image-37.png)


PSPanner is a lightweight PowerShell script which can help you identify open TCP ports. I created this as certain Anti-Virus vendors block tools such as NMAP.

Network scans are often used for good and can help the blue team identify gaps and potential entry points for attackers.

<b>Selecting your destination</b>

If you wish to do a single scan, enter the URL or IP. At this moment of time, it doesn’t support IP ranges. If you wish to scan multiple, enter all destination into a txt file.

<b>Single Destination Scan </b>
![singlescan](https://ctrla1tdel.files.wordpress.com/2020/01/singlescan.gif)

<b>Multiple Destination Scan </b>
![singlescan](https://ctrla1tdel.files.wordpress.com/2020/01/txtscan.gif)

*The IPs I took from Shodan. I don’t own or advise scanning them.
They were the first ones on the site and are used as an example.

<b><Running Live....(Internet Connection Needed)/b>
 Run the following within Powershell:

powershell –nop –c “iex(New-Object Net.WebClient).DownloadString(‘https://raw.githubusercontent.com/securethelogs/PSpanner/master/PSpanner.ps1’)”

For More Information: https://securethelogs.com/pspanner-network-scanner/
