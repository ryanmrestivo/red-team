#pragma once

#include <iostream>
#include <Windows.h>

void toLowerCase(char* ptr, unsigned int len) {
    for (unsigned int i = 0; i < len; i++) {
        if (isupper(ptr[i]))
            ptr[i] = tolower(ptr[i]);
    }
}

// Easy to improve yourself
bool isVM()
{
    std::string sysManufacturer, sysName;
    char buf[1000];
    DWORD sz = 1000;
    int ret;

    ret = RegGetValueA(HKEY_LOCAL_MACHINE, "SYSTEM\\CurrentControlSet\\Control\\SystemInformation", "SystemManufacturer", RRF_RT_ANY, NULL, &buf[0], &sz);
    toLowerCase(buf, strlen(buf));
    sysManufacturer = buf;
 
    if (ret == ERROR_SUCCESS && (sysManufacturer.find("vmware") != std::string::npos || sysManufacturer.find("innotek gmbh") != std::string::npos)) {
        return 1;
    }

    ret = RegGetValueA(HKEY_LOCAL_MACHINE, "SYSTEM\\CurrentControlSet\\Control\\SystemInformation", "SystemProductName", RRF_RT_ANY, NULL, &buf[0], &sz);

    toLowerCase(buf, strlen(buf));
    sysName = buf;
                                             //add more strings to make it better :)
    if (ret == ERROR_SUCCESS && (sysName.find("vmware") != std::string::npos || sysName.find("virtualbox") != std::string::npos)) {
        return 1;
    }
    return 0;
}
