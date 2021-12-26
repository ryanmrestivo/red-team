========================
Exploit Pack - Project
========================

Exploit Pack has been designed by an experienced team of software developers 
and exploit writers to automate processes so that penetration testers can focus 
on what's really important. The threat. This blend of software engineers and 
subject matter experts provides an unique advantage by combining technical 
know-how with true insight into the problem set, resulting in more efficient 
solutions for cyber security surveillance.

========================
Installation notes:
========================

Windows:
Download and install Java 8 from Oracle:
Windows Java SE Java 8 for 32 bits or Java 8 for 64 bits 
After you have installed Java 8 in your machine, double click ExplotPack.jar or from a console run this command: "java -jar ExploitPack.jar"

Linux:
Under any Linux distribution that supports DEB packages like Ubuntu, Debian, Kali, etc. you can run the following commands to install Java 8 from an official repository 
Copy and paste the following in a terminal window:

echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" >> /etc/apt/sources.list
echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" >> /etc/apt/sources.list
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886
sudo apt-get update
sudo apt-get install oracle-java8-installer

OSX:
Download and install Java 8 for OSX 32/64 bits from Oracle: OSX Java 8 32/64 bits
After you have Java 8 installed in your Mac, double click ExploitPack.jar to run it or from a console: "java -jar ExploitPack.jar"

========================
Known issues:
========================
Using Exploit Pack could produce addiction
Prolonged periods of time using this tool could produce network mayhem or even dead
In case of intoxication ( using Exploit Pack under Windows ) please call your doctor immediately.

========================
BUILD OUTPUT DESCRIPTION
========================

When you build an Java application project that has a main class, the IDE
automatically copies all of the JAR
files on the projects classpath to your projects dist/lib folder. The IDE
also adds each of the JAR files to the Class-Path element in the application
JAR files manifest file (MANIFEST.MF).

To run the project from the command line, go to the dist folder and
type the following:

java -jar "ExploitPack.jar" 

To distribute this project, zip up the dist folder (including the lib folder)
and distribute the ZIP file.

Notes:

* If two JAR files on the project classpath have the same name, only the first
JAR file is copied to the lib folder.
* Only JAR files are copied to the lib folder.
If the classpath contains other types of files or folders, these files (folders)
are not copied.
* If a library on the projects classpath also has a Class-Path element
specified in the manifest,the content of the Class-Path element has to be on
the projects runtime path.
* To set a main class in a standard Java project, right-click the project node
in the Projects window and choose Properties. Then click Run and enter the
class name in the Main Class field. Alternatively, you can manually type the
class name in the manifest Main-Class element.
