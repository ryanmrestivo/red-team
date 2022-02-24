/* by ninar1
exe2bat.cpp

main code taken from Riftors  exe2hex
	riftor@sec33.com
	http://home.graffiti.net/riftor615/

    so credits 2 him
  also thx 2 BCK


usage: exe2bat.exe [input.exe] [output.bat]


*/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define BEFORE "echo "   // piece before buffer
#define AFTER " >>123.hex" // piece after buffer
#define AFTER2 " >123.hex" // piece after buffer

char nfilein[128], nfileout[128],buffer[1];
FILE *filein, *fileout, *file;
int i;
unsigned char cbyte;
unsigned long cx, offset;


int main(int argc, char*argv[])
{

//usage
if(argc!=3)
  {
   system( "cls" );
   printf("\n||exe2batch||\n",argv[0]);
   printf("\nUsage : %s inputfile outputfile",argv[0]);
   printf("\ne.g.  : %s dcmd.exe command.txt\n",argv[0]);
   exit(1);
  }

//checks for readaccess
if ((filein= fopen(argv[1], "r")) == NULL )
{
system( "cls" );
printf("\nFile: %s does not exist\n",argv[1]);
exit(1);
}
//BCK addon
//checks 4 filesize


char buffer[1];
file=fopen(argv[1],"r+b");
for(i=0;fread(buffer,1,1,file)!=0;i++);
if(i>=65536)
{
system( "cls" );
printf("\nFile: %s to big 4 debug make sure FILE < 64KB\n",argv[1]);
exit(1);
}



//do the job

        strcpy(nfilein,(const char *)argv[1]);
        strcpy(nfileout,(const char *)argv[2]);
        filein=fopen((const char *)nfilein,"rb");
        fileout=fopen((const char *)nfileout, "wt");
        offset=256;
        cx=0;
        fprintf(fileout,"%sn 1.dll%s",BEFORE,AFTER2);

        while(!feof(filein)){
                             fprintf(fileout,"\n%se %04x%s\n%s",BEFORE,offset,AFTER,BEFORE);
                             for(i=0;i<128;i++)
                             {
                                               fscanf(filein, "%c", &cbyte);
                                               if(feof(filein)){
                                                                break;
                                               }
                                               cx++;
                                               fprintf(fileout, "%02x ",cbyte);
                             }
        fprintf(fileout, "%s ",AFTER);
                             offset=offset+128;
        }
        fprintf(fileout,"\n%sr cx%s\n",BEFORE,AFTER);
        fprintf(fileout,"%s%04x%s\n",BEFORE,cx,AFTER);
        fprintf(fileout,"%sw%s\n",BEFORE,AFTER);
  fprintf(fileout,"%sq%s\n",BEFORE,AFTER);
        fprintf(fileout,"debug<123.hex\n");
  fprintf(fileout,"copy 1.dll %s\n",nfilein);
        fclose(filein);
        fclose(fileout);
  printf("\nFinished: %s > %s \n",argv[1],argv[2]);
        return 0;
}
