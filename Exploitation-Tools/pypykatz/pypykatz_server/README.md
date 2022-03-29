# pypykatz_server
Pypykatz server

This is the server part of a server-agent model credential acquiring tool based on pypykatz.  

Be sure to install ```pypykatz``` via ```pip install pypykatz``` first.

## Usage

```server.py <server_type> <....>```
Currently supported server types: 
1. socket  
  

### Socket server
```server_type``` = ```socket```

#### Parameters
```server.py socket -l <listen_ip> -p <listen_port> -o <output_dir>```

#### Example
```server.py socket 127.0.0.1 6666```

#### Options:
1. ```listen_ip```
IP to listen on  
Optional, defaults to ```0.0.0.0```
2. ```listen_port```   
TCP port to listen on
Optional, defaults to ```54545```
3. ```output_dir```  
  Output directory to store credentials in  
  Optional, defaults to ```creds```
4. ```r```  
  Server will push back the results to the agent.
