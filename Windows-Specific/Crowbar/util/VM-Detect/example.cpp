/* Vm Detector */
/* Made by https://github.com/dehoisted */

#include "antivm.h"

int main()
{
    switch (isVM())
    {
    case true:
        std::cout << "Virtual Machine detected\n";
        exit(0);
        break;

    case false:
        std::cout << "Virtual Machine not detected\n";
        break;
    }
}
