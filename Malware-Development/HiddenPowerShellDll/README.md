
# HiddenPowerShell

This project was created to explore the various evasion techniques involving PowerShell

<ul>
 <li>Amsi</li>
<li>ScriptBlockLogging</li>
<li>Constrained Language Mode</li>
<li>AppLocker</li>
</ul>

# Metasploit module and payload
 
The module manages the delivery of an hta file and a stager ps1 file. When the hta is executed it extracts the dll and runs it via rundll32.
The metasploit payload is an Empire custom stager without Amsi bypass parts and ScriptBlockLogging, will be executed outside powershell. This prevents the logging bypass code from remaining logged.

# HiddenPowerShellDll

This .Net class library is used to run PowerShell scripts from c #.
The bypasses are executed and then the scriptblock that invokes the stager is executed. Using the DllExport package the .Net DLL exports a function that allows it to be executed via rundll32 and this results in a bypass of the default AppLocker rules

# Instructions

Put the hta_sharp.rb file in the $ (HOME) /.msf4/modules/exploits/windows/misc folder

Put in powershell_empire_http.rb file in the $ (HOME) /.msf4/payloads/singles/windows/x64 folder

Complete the solution<br>
Create the $ (metasploit_data_dir) / hta_sharp folder<br>
Copy the bin\Release\x64\HiddenPowerShellDll.dll file to $(metasploit_data_dir)/hta_sharp renaming it to HiddenPowerShellDllx64.dll<br>

# Note

If you run a meterpreter payload set PrependMigrate advanced property to true

To run the Empire payload:
<ul>
 <li>Create the http listener in Empire framework and use the StagingKey property to set the STAGINGKEY option of the powershell_empire_http payload</li>
<li>set PrependMigrate advanced property to false.</li>
</ul>

To maximize evasion it is necessary to use the https protocol for all the phases. Self signed or cloned certificates are supported. Do not use the default metasploit certificates.


# References

AMSI Bypass @_RastaMouse version<br>
ScriptBlockLogging @cobbr_io<br>
General inspiration runspace @Cneelis<br>
