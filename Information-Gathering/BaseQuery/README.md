# BaseQuery

Solving the problem of having thousands of different files from leaked databases and not an efficient way to store/query them. BaseQuery is an all in one program that 
takes the annoyance out of searching through data-breaches. You can find breaches in places such as [RaidForums.com](RAIDFORUMS.com) or [Databases.today](Databases.today).
### Features Included:
 * Calculating the time a file will take to import, before hand
 * A 4x nested storage structure
 * Average import speeds of 10,000+ entries per second
 * Instantaneous querying system
 * Email harvesting programs built in
 ***
### Installing

To Install BaseQuery type the following commands

```
git clone https://github.com/g666gle/BaseQuery.git
sudo chmod 777 -R BaseQuery/
cd BaseQuery
./run.sh
```


## Getting Started
1. Place any databases that you have into the "PutYourDataBasesHere" folder
    - As of right now, BaseQuery can only accept files in the format where each line is either "test@example.com:password" or "password:test@example.com"
    - It doesn't matter if the line formats are mixed up within the same file. Ex) The first line may be "email:password" and the second can be "password:email"
    - One entry per line!! 
    - MAKE SURE THAT YOUR FILES DO NOT HAVE SPACES IN THE NAMES OF THE DATABASE FILES!
    - If you need a better visual there is an example.txt file in the folder "PutYourDataBasesHere"
    - You should delete the example file before running the program.
1. Now that you have all of your files in the correct folder
    - Open up a terminal
    - type './run.sh' if that doesn't work type 'bash run.sh'
1. Follow the instructions on the screen
    - That's it, enjoy!

***
### Prerequisites

```
Python Version 3.6+
Bash 4.0+
mmap (sudo pip3 install mmap)
```


## Built With

* Ubuntu 18.04 bionic

* Bash Version:
GNU bash, version 4.4.19(1)-release (x86_64-pc-linux-gnu)

* Python Version:
3.6.7

## Authors

* **G666gle** - *All work* - [(Github)](https://github.com/G666gle) [(Twitter)](https://twitter.com/g666gle1)


## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

### DISCLAIMER:

* READ UP ON YOUR LOCAL LAWS FIRST BEFORE USING THIS PROGRAM.


