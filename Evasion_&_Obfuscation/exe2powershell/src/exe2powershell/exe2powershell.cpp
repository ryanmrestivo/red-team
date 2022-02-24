/*******************************************************************************************************************************

  ______          ___  _____                       _____ _          _ _
 |  ____|        |__ \|  __ \                     / ____| |        | | |
 | |__  __  _____   ) | |__) |____      _____ _ _| (___ | |__   ___| | |
 |  __| \ \/ / _ \ / /|  ___/ _ \ \ /\ / / _ \ '__\___ \| '_ \ / _ \ | |
 | |____ >  <  __// /_| |  | (_) \ V  V /  __/ |  ____) | | | |  __/ | |
 |______/_/\_\___|____|_|   \___/ \_/\_/ \___|_| |_____/|_| |_|\___|_|_|

        [ exe2bat reborn in exe2powershell for modern Windows ]
 [ initial author ninar1, based on riftor work, and modernized by ycam ]
 [ exe2powershell version 1.0 - keep up2date: asafety.fr / synetis.com ]

exe2powershell.cpp

Main code taken from Riftors "exe2hex" (riftor@sec33.com - http://home.graffiti.net/riftor615/)
Adapted for Windows BAT file by ninar1.
Modernized to newer Windows systems by Yann CAM (ycam - http://www.asafety.fr | http://www.synetis.com)

    so credits 2 him
    also thx 2 BCK

This version is modernized from exe2bat to work with modern Windows version.
exe2bat have limitation :
- Need "debug.exe" available on the target computer (16-bit application removed on Windows 7 x64 but available on Windows 7 x86)
- Limit input exe to 64kB

exe2powershell replace the need of "debug.exe" by a PowerShell command line available on all Windows since Windows 7 / 2008.
There is no more limitation in input exe size.

Credits : Riftor, ninar1, BCK and ycam

*******************************************************************************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define VERSION "1.0"
#define BEFORE "echo|set /p="   // piece before buffer
#define AFTER ">>456.hex"       // piece after buffer
#define AFTER2 ">456.hex"       // piece after buffer (init)

char nfilein[128], nfileout[128];
FILE *filein, *fileout;
int i;
unsigned char cbyte;
unsigned long cx;

void header(){
    printf("  ______          ___  _____                       _____ _          _ _ \n");
    printf(" |  ____|        |__ \\|  __ \\                     / ____| |        | | |\n");
    printf(" | |__  __  _____   ) | |__) |____      _____ _ _| (___ | |__   ___| | |\n");
    printf(" |  __| \\ \\/ / _ \\ / /|  ___/ _ \\ \\ /\\ / / _ \\ '__\\___ \\| '_ \\ / _ \\ | |\n");
    printf(" | |____ >  <  __// /_| |  | (_) \\ V  V /  __/ |  ____) | | | |  __/ | |\n");
    printf(" |______/_/\\_\\___|____|_|   \\___/ \\_/\\_/ \\___|_| |_____/|_| |_|\\___|_|_|\n\n");
    printf("        [ exe2bat reborn in exe2powershell for modern Windows ]\n");
    printf(" [ initial author ninar1, based on riftor work, and modernized by ycam ]\n");
    printf(" [ exe2powershell version %s - keep up2date: asafety.fr / synetis.com ]\n", VERSION);
}

void usage(char** argv){
    printf("\n [*] Usage : %s inputfile outputfile", argv[0]);
    printf("\n [*] e.g.  : %s nc.exe nc.bat\n", argv[0]);
}

int main(int argc, char** argv){
    header();
    //usage
    if(argc!=3){
        usage(argv);
        exit(1);
    }

    //checks for readaccess
    if ((filein= fopen(argv[1], "r")) == NULL){
        printf("\n [-] File: %s does not exist\n",argv[1]);
        exit(1);
    }

    //do the job
    strcpy(nfilein,(const char *)argv[1]);
    strcpy(nfileout,(const char *)argv[2]);
    filein=fopen((const char *)nfilein,"rb");
    fileout=fopen((const char *)nfileout, "wt");
    fprintf(fileout,"@echo off\n%s%s\n",BEFORE,AFTER2);

    while(!feof(filein)){
        fprintf(fileout,"%s",BEFORE);
        for(i=0;i<128;i++){
            fscanf(filein, "%c", &cbyte);
            if(feof(filein)){
                break;
            }
            fprintf(fileout, "%d ", cbyte);
        }
        fprintf(fileout, "%s\n", AFTER);
    }
    fprintf(fileout,"powershell.exe -ExecutionPolicy Bypass -NoLogo -NonInteractive -NoProfile -WindowStyle Hidden -Command \"[string]$hex = get-content -path 456.hex;[Byte[]] $temp = $hex -split ' ';[System.IO.File]::WriteAllBytes('%s', $temp)\"\n", nfilein);
    fclose(filein);
    fclose(fileout);
    printf("\n [*] Finished: %s > %s \n", argv[1], argv[2]);
    return 0;
}
