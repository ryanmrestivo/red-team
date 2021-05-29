# LFI-Enum
Scritps to enumerate linux servers via LFI

# Usage
`bash script-name http://server.vulnerable.com/download.php?file=`

# Scripts
### process-info
Collect informations about running process.

### network-info
Collect informations about network such as open ports, ARP table and interfaces.

### common-files
Get the content of common files such as `/etc/passwd`, `/etc/crontab` and others.

# Util script
 - `/proc/net/tcp` parser - [linux_net_tcp.py](https://gist.github.com/Reboare/2e0122b993b8557935fd37b27436f8c2)
