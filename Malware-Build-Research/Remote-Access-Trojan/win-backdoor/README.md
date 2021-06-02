## Description
This is a persistent reverse shell that uses windows TCP sockets to communicate with a listener. The listener can be anything that accepts a remote connection, I used netcat to test (nc -lnvp 8080). Persistence is achieved through a registry run key that executes the backdoor path on a reboot. The purpose of this project was to gain a grasp of simple winAPI calls and sockets in C, as well as explore malware techniques. As of writing this, the executable goes undetected by windows defender and has a virustotal.com score of 3/72. The reason for its low detection rate could be due to the simplicity of the executable which doesn't pack/encrypt itself or use any typical process injection methods.

### Execution

1. reverse shell executed
2. copy self to temp folder
3. execute instance from temp folder
4. write registry run key for reboot persistence
5. continually beacon listener until a connection is made 
6. wait for module code from listener to start the reverse shell
7. use CreateProcess() to start cmd.exe and pipe stdin/out/err to the socket

*since the cmd process is wrapped in a loop that accepts module codes from the listener the backdoor will stay connected even when the shell is exited*

*If the backdoor loses connection to the listener it will continue to beacon every 5 seconds to re-establish connection which could raise a red flag for Anti-virus*

#### Notes:

- See Makefile for intended compilation and gcc flags for a compact exe
  - Need to use a compiler that supports windows runtime (mingw)
- Change ip and port in main.h 


