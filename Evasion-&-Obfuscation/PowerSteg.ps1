<#

.SYNOPSIS
Insert command information into BMP images for later execution
    
.DESCRIPTION
This script works in two modes.  The first mode is used to embed information into image files.  Using this first mode, you can put powershell commands into an image file, for later execution.  You can use any type of image file, but just note that the extraction process will rely on a BMP file.    

The second mode is the reverse process, where inserted information is extracted from a file.  Using the runcmd switch, you can immediately take the information and run it with PowerShell.  Alternatively, if you leave it in the default mode, PowerSteg will extract the information into a text file.

.PARAMETER InFile
This is the first parameter, which tells PowerSteg what image you wish to embed data into.

.PARAMETER OutFile
This is the second parameter, which tells PowerSteg where the resulting image file should be stored and what to name it.

.PARAMETER StegFile
This is the third parameter, which should be a simple text file, containing your desired steganographic information.

.PARAMETER -desteg
This switch triggers the desteg function

.PARAMETER -runcmd
This switch runs whatever steg data is extracted from the BMP file that you initially embedded information into.

.EXAMPLE
.\powersteg.ps1
This is the default command, which can be used to insert command information into an image file.
When you run powersteg with no switches or parameters, it will prompt you for the input file, the output file, and the steg data file.

.EXAMPLE
.\powersteg.ps1 test.jpg test.bmp cmd.txt
This is the full command-line parameter way to utilize powersteg for inserting data into a file.  Note that I supplied a jpg image - PowerSteg can use input images that are not BMP, but it will convert them to BMP before inserting the command data.

.EXAMPLE
.\powersteg.ps1 -desteg
This is the reverse function, which will strip command data out into a file for use separately (start-process for example)

.EXAMPLE
.\powersteg.ps1 -desteg -runcmd
This switch was added to simplify the usage of powersteg, so you can easily extract and run steg commands without touching the disk.

.EXAMPLE
.\powersteg.ps1 blah.bmp -desteg -runcmd
Reverse function, using all command line functionality.  This will assume blah.bmp contains inserted steg data, then extract it and run a new PowerShell process using that steg data.

#>


<#
#############################################################################################################
#############################################################################################################
#############################################################################################################
       Current steg file layout below:
       <--BMPHEADER--><--STEGHEADER--><--STEGDATA--><--BMPDATA-->
                      |               \
                      |                 \
                      |                   \
                      |                     \
                      |                       \
                      |                         \
                      |                           \
                      |                             \
                      |                               \
                      |                                 \
                      |                                   \
                      |                                     \
                      |                                       \
                      |                                         \
                      |                                           \
                      |                                             \
                      |                                               \
                      |                                                 \
                      |                                                   \
                      |                                                     \
                      |                                                       \
                      |                                                         \
				      |                                                           \
                      |--4 bytes, steg data size (in bytes)--|--4 bytes, extension--|
	Example header info:::
	Stegdata length (19)  // 32 bits, 4 bytes
	00000000000000000000000000010011
	Stegdata extension (txt)  //  28 bits, 4 ascii chars
	111010011110001110100
	Stegdata (testing new cmd.sh)
	00000000000000000000000000010011000000011101001111000111010001110100011001010111001101110100011010010110111001100111001000000110111001100101011101110010000001100011011011010110010000101110011100110110100000001010
	Full data for insertion:
	0000000000000000000000000001001111101001111000111010000000000000000000000000000010011000000011101001111000111010001110100011001010111001101110100011010010110111001100111001000000110111001100101011101110010000001100011011011010110010000101110011100110110100000001010
#############################################################################################################
#############################################################################################################
#############################################################################################################
#>

param (
    [Parameter(Mandatory=$True)][string]$InFile,
    [Parameter(Mandatory=$false)][string]$OutFile,
    [Parameter(Mandatory=$false)][string]$StegFile,
    [switch]$desteg = $false,
    [switch]$runcmd = $false
)


####----> Load assemblies if necessary
# Forms assembly for selecting image file as $InFile
[Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null


#----> Start a timer to report how long execution takes
$stopwatch = [system.diagnostics.stopwatch]::startNew()

<#
#############################################################################################################
###--- ADD FUNCTION HERE TO CHECK FOR FILETYPE AND CONVERT TO BMP IF NECESSARY ---###########################
###--- https://blogs.technet.microsoft.com/heyscriptingguy/2010/07/05/hey-scripting-guy-how-can-i-use-windows-powershell-to-convert-graphics-files-to-different-file-formats/ ---##
###--- https://hazzy.techanarchy.net/posh/powershell/bmp-to-jpg-the-powershell-way/ ---######################
###*** Got it working, but conversion to and from BMP ruins steg data so it is only ***######################
###*** feasible to convert the initial image from whatever to BMP and then extract from that ***######################
#############################################################################################################
#>

####----> Check parameters and force setting them if null
if(!$InFile){
	####----> Check InFile to see if it's a BMP, and convert if it's not

	### Get file from user dialog
	### Limited filetypes - Images only
	$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
	    InitialDirectory = [Environment]::GetFolderPath('MyPictures') 
	    Filter = 'Images (*.jpg,*.jpeg,*.gif,*.png,*.tif,*.tiff,*.bmp)|*.jpg;*.jpeg,*.gif;*.png;*.tif;*.tiff;*.bmp'
	}

	$null = $FileBrowser.ShowDialog()
	$InFile = $FileBrowser.FileName
}
else{
	$linux = "/bin/"
	if($linux){
		$InFile = (pwd).path + '/' + $InFile
	} else {
		$InFile = (pwd).path + '\' + $InFile
	}
}
if(!$desteg){
	if(!$OutFile){
		$OutFile = Read-Host -Prompt "Enter the desired output file name"
	}
	if(!$StegFile){
		$StegFile = Read-Host -Prompt "Enter the steganographic command filename"
	}
}

if(!$desteg){
	write-host $InFile

	# Set input filename for use later in converting back to original format
	$originalfilename = $InFile

	# Set a flag for whether or not we converted to BMP
	$convertedfile = $False

	### Check file type and set bmp extension
	$ext = @()
	4..1 | %{
		$ext += $InFile[-$_]
	}
	$fileext = -join $ext
	$fileext = $fileext.Trim('.')

	if($fileext -like 'jpg' -or $fileext -like 'jpeg' -or $fileext -like 'bmp' -or $fileext -like 'gif' -or $fileext -like 'png' -or $fileext -like 'tif' -or $fileext -like 'tiff'){
		$newfilename = $InFile -replace $fileext,'bmp'
		$convertedfile = $True
	}

	else{
		write-output "The selected filetype is invalid.  Please try running PowerSteg again, and select either a BMP, GIF, JPG, or PNG file."
		break
	}

	if($convertedfile){
		### Perform actual save function
		$convertfile = new-object System.Drawing.Bitmap($InFile)
		$convertfile.Save($newfilename, "bmp")	
		$InFile = $newfilename
	}	
}


####----> Modifying script for Windows default PATH functionality
$testpath = test-path "/bin/"

####----> If there is no /bin/, it's Windows
if($testpath -ne "True"){
	$tmppath = (pwd).path
	if($OutFile){
		$StegFile = $tmppath + '\' + $StegFile
		$OutFile = $tmppath + '\' + $OutFile
	}
}

####----> Otherwise it is Linux so you need / instead of \
if($testpath -eq "True"){
	$tmppath = (pwd).PATH
	if($OutFile){
		$StegFile = $tmppath + '/' + $StegFile
		$OutFile = $tmppath + '/' + $OutFile
	}
}

<#########################################################################
////////////////////----Write debugging information----///////////////////
#########################################################################>
if($PSCmdlet.MyInvocation.BoundParameters["Debug"].IsPresent){
	write-host "Full input file path is:"
	write-host "------------------------"
	write-host $InFile

	write-host " "
	write-host "Full output file path is:"
	write-host "-------------------------"
	if(!$OutFile){
		write-host "Not defined"
	}
	else{
		write-host $OutFile	
	}

	write-host " "
	write-host "Full steg file path is:"
	write-host "-----------------------"
	if(!$StegFile){
		write-host "Not defined"
	}
	else{
		write-host $StegFile	
	}
	write-host " "
}


<#
////////////////////////////////////////////////////////////////
///////////////////----Enstegcmd function----///////////////////
////////////////////////////////////////////////////////////////
#>
####----> if no desteg flag is set, ensteg the file
if(!$desteg){
	####----> read bytes from input file
	$bytes = (get-item $InFile).length

	####----> If the data to be added is larger than the target file, notify user and halt execution
	$lengthcheck = (get-item $stegfile).length * 8
	$lengthcheck = $lengthcheck + 60

	$carriercheck = $bytes - 54
	write-host " "
	write-host "There are $carriercheck bytes available for adding steg data."
	write-host " "

	if($carriercheck -lt $lengthcheck){
		write-host "Your input data is too large for the carrier file.  Please find a larger BMP carrier and try again.  Your file requires $lengthcheck bytes, but your carrier file only has $carriercheck bytes."
		return
	}

	####----> copy infile for writing output to
	Copy-Item $InFile $OutFile


	<#
	///////////////////----Set up steg header----///////////////////
	#>

	<#
	///////////////////----Add steg data length field----///////////////////
	#>

	####----> read in steg data --- need this first to add steg data length field
	#[byte[]] $stegbytes = get-content -encoding byte -path $stegfile
	[byte[]] $stegbytes = [system.io.file]::readallbytes($stegfile)

	####----> make array to store new stegged file data
	$stegarr = New-Object System.Collections.Generic.List[System.String]

	####----> add steg header length info
	$stegdatalen = $stegbytes.length
	$stegdatalen = [convert]::tostring($stegdatalen, 2).padleft(32, "0")
	$stegarr.Add($stegdatalen)

	$stegdatalendecimal = [convert]::toint32($stegdatalen, 2)
	write-host "Inserted steg data length header is:"
	write-host "------------------------------------"
	write-host $stegdatalen "or $stegdatalendecimal bytes"

	write-host " "
	write-host "The total amount of steg data bits to be added is:"
	write-host "--------------------------------------------------"
	write-host $lengthcheck


	<#
	///////////////////----Add steg extension field----///////////////////
	#>

	####----> get file extension info
	$ext = $Stegfile -replace "\.\/",""
	$reg = [regex]"(\......$|\.....$|\....$)"
	$extension = $reg.match($ext)
	$extension = $extension.Captures[0].value
	$extension = $extension -replace "\.", ""

	####----> add extension to 4-byte header array
	$extarr = New-Object System.Collections.ArrayList
	for ($i = 0; $i -le $extension.length-1; $i++){
		$d = [int][char]$extension[$i]
		[void]$extarr.Add($d)
	}

	$extpaddedlist = New-Object System.Collections.Generic.List[System.String]
	$g = 0
	foreach ($c in $extarr){
		$c = [convert]::tostring($c, 2).padleft(7, "0")
		[void]$extpaddedlist.Add($c)
	}
	$extpadded = $extpaddedlist.ToArray()

	$extpadded = [system.string]::Join("",($extpadded))
	$stegarr.Add($extpadded.padleft(28, "0"))

	write-host " "
	write-host "Inserted steg extension header is:"
	write-host "----------------------------------"
	write-host $extpadded "or $extension"


	<#
	///////////////////----Convert steg data from given stegfile----///////////////////
	#>

	####----> read in the command to steg into our output file
	foreach ($b in $stegbytes){
		write-progress -Activity "Processing bytes for $StegFile" -CurrentOperation $b -PercentComplete (($stegarr.length / $stegbytes.length) * 100)
		$b = [convert]::tostring($b, 2).padleft(8, "0")
		$stegarr += $b
	}

	####----> remove spaces and prep array for inserting into file
	$stegarr = [system.string]::Join("",($stegarr))

	####----> read in data for inserting steganography bits
	$filereadStream = [System.IO.File]::Open($infile, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
	$reader = New-Object System.IO.BinaryReader($filereadStream)
	$reader.BaseStream.Position = 54;
	$carrierbytes = $reader.ReadBytes($stegarr.length)
	$reader.close()
	
	#### TESTING FILE READ PERFORMANCE
	#    get-content is at least 4 times as SLOW -- do NOT use that
	#    binaryreader is right there with readallbytes
	#    streamreader is ???

	####----> Make an array and then populate it with enstegged data
	$stegdatalist = New-Object System.Collections.Generic.List[System.Byte]
	$j = 0
	while($j -le $stegarr.length-1){
		####----> If the steg data bit is a 1, do AND op to ensure LSB is 1
		if($stegarr[$j] -eq '1'){
			$stegdatalist.Add($carrierbytes[$j] -bor 1)
		}
		####----> Otherwise, use XOR to ensure LSB is 0
		else{
			$stegdatalist.Add($carrierbytes[$j] -band 254)
		}
		$j += 1
	}
	$stegdata = $stegdatalist.ToArray()


	<#########################################################################
	////////////////////----Write debugging information----///////////////////
	#########################################################################>
	if($PSCmdlet.MyInvocation.BoundParameters["Debug"].IsPresent){
		write-host " "
		write-host "Default image data is:"
		write-host "----------------------"
		write-host $carrierbytes

		write-host " "
		write-host "File data to be inserted:"
		write-host "-------------------------"
		write-host $stegbytes

		write-host " "
		write-host "Steg bits are:"
		write-host "--------------"
		write-host $stegarr

		write-host " "
		write-host "Inserted steg data is:"
		write-host "----------------------"
		write-host $stegdata

		write-host " "
		write-host "Data format is:"
		write-host "---------------"
		write-host $stegdata.gettype()
		write-host " "
	}
	<#
	///////////////////----Begin actual steg operations, inserting bits into data----///////////////////
	#>

	# stream out the bytes array into the target file
	$fileStream = [System.IO.File]::Open($OutFile, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Write, [System.IO.FileShare]::ReadWrite)
	$writer = New-Object System.IO.BinaryWriter($fileStream)
	$writer.BaseStream.Position = 54;
	$writer.write($stegdata)
	$writer.Close()

}

<#
/////////////////////////////////////////////////////////////
///////////////////----Desteg function----///////////////////
/////////////////////////////////////////////////////////////
#>
####----> if desteg switch is not set, desteg command from the stegged file
else{
	####----> Get bytes into an array from stegged image
	$bytes = [System.IO.File]::ReadAllBytes($InFile)

	####----> Start reading after end of BMP header
	$f = 54
	####----> Set end of loop to be after steg size (54 plus 31)
	$sizeloop = 85
	####----> Set end of loop to be after steg extension (85 plus 28)
	$extloop = 113

	<#
	///////////////////----Retrieve steg data size----///////////////////
	#>
	####----> Make an array for compiling info about header
	$steglength = New-Object System.Collections.Generic.List[System.String]

	####----> Loop through steg header length and put into array
	while($f -le $sizeloop){
		####----> Check to see if byte is 0
		if(($bytes[$f] -band 1) -eq 0){
			$steglength.Add('0')
		}
		####----> Check to see if LSB is 1
		else{
			$steglength.Add('1')
		}
		$f += 1
	}
	$steglength = [system.string]::Join("",($steglength))
	$steglength = [convert]::toint32($steglength,2)

	write-host " "
	write-host "Steg data length is:"
	write-host "--------------------"
	write-host ($steglength * 8)

	<#
	///////////////////----Retrieve steg extension data----///////////////////
	#>
	####----> Make arrays for compiling info about extension
	$extension = New-Object System.Collections.Generic.List[System.String]
	$extfinal = New-Object System.Collections.Generic.List[System.String]

	####----> Loop through steg extension data and put into array
	while($f -le $extloop){
		####----> Check to see if byte is 0
		if(($bytes[$f] -band 1) -eq 0){
			$extension.Add('0')
		}
		####----> Check to see if LSB is 1
		else{
			$extension.Add('1')
		}
		$f += 1
	}
	$extension = [system.string]::Join("",($extension))

	####----> Make array and store extension information
	$extbyte = New-Object System.Collections.Generic.List[System.String]
	$k = 0
	$i = 0
	while ($k -le 27){
		while($i -le 6){
			if($i -eq 6){
				if(($extension[$k] -band 1) -eq 0){
					$extbyte += 0
				}
				else{
					$extbyte += 1
				}
				$extbyte = [system.string]::join("",($extbyte))
				$extbyte = [convert]::tobyte($extbyte, 2)
				$extbyte = [convert]::tochar($extbyte)
				$extfinal += $extbyte
				$extbyte = @()
			}
			elseif(($extension[$k] -band 1) -eq 0){
				$extbyte += 0
			}
			else{
				$extbyte += 1
			}
		$i += 1
		$k += 1
		}
	$i = 0
	}

	$extout = @()

	####----> If the extension data only has 3 values, just store those 3
	if($extfinal[0] -eq 0){
		1..3 | % {
			$extout += [convert]::tochar($extfinal[$_])
		}
	}

	####----> Otherwise, store all 4 values for writing the file later
	else{
		foreach($b in $extfinal){
			$extout += [convert]::tochar($b)
		}
	}

	$extout = [system.string]::Join("",($extout))

	write-host " "
	write-host "Extension information is:"
	write-host "-------------------------"
	write-host $extout
	write-host " "

	<#
	///////////////////----Retrieve steg data----///////////////////
	#>

	####----> Create array to put steg data in
	$stegdata = @()

	####----> Loop through and get data for insertion into array
	$steglength = $steglength * 8
	$stegend = $f + $steglength
	$curbyte = @()
	$outdata = @()
	$tmppath = (pwd).path

	if(!$testpath){
		$newoutfile = $tmppath + '\stegoutput.' + $extout
	}

	if($testpath){
		$newoutfile = $tmppath + '/stegoutput.' + $extout
	}

	####----> read in data for retrieving steganography data bits
	$filereadStream = [System.IO.File]::Open($infile, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
	$reader = New-Object System.IO.BinaryReader($filereadStream)
	$reader.BaseStream.Position = 114;
	$displaystegdata = $reader.ReadBytes($steglength)
	$reader.close()

	####----> Set up variables for writing out steg data
	$stegout = New-Object System.Collections.Generic.List[System.Byte]
	$stegbyte = New-Object System.Collections.Generic.List[System.String]
	$s = 0
	$iter = 0

	####----> Retrieve stegged info for writing out to file
	while($s -lt $steglength){
		while($iter -le 7){
			if($iter -eq 7){
				if(($displaystegdata[$s] -band 1) -eq 0){
					$stegbyte.Add('0')
				}
				else{
					$stegbyte.Add('1')
				}
				$stegbyte = [system.string]::Join("",($stegbyte))
				$stegbyte = [convert]::toint32($stegbyte, 2)
				$stegout.Add($stegbyte)
				$stegbyte = New-Object System.Collections.Generic.List[System.String]
			}
			elseif(($displaystegdata[$s] -band 1) -eq 0){ 
				$stegbyte.Add('0')
			}
			else{
				$stegbyte.Add('1')
			}
			$iter += 1
			$s += 1
		}	
	$iter = 0
	}

	if(!$runcmd){
		write-host "Saving data to $newoutfile"
		[io.file]::WriteAllBytes($newoutfile, $stegout)
	}

	if($runcmd){
		$command = @()
		$stegout | %{
			$command += [char]$_
		}
		$cmd = -join $command
		start-process powershell $cmd
	}

}

$stopwatch.stop()
[int]$exectime = $stopwatch.elapsed.totalseconds

write-host " "
write-host "Script execution took $exectime seconds."
