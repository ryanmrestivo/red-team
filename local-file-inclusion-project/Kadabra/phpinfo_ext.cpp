#include <iostream>
#include <stdlib.h>
#include <string>
#include <vector>
#include <fstream>
using namespace std;

int main(int argc, char *argv[]) {
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
        //cout << "[+] ABRACADABRA FOUND :)\n";
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
                }
                else cout << read[i];
            }
        }
    }
}
