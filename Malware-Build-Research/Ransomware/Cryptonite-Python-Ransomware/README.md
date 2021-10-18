![MIT License](https://img.shields.io/github/license/CYBERDEVILZ/CRYPTONITE) 
![Issues](https://img.shields.io/github/issues/CYBERDEVILZ/CRYPTONITE?color=cyan) 
![](https://img.shields.io/github/languages/top/CYBERDEVILZ/CRYPTONITE)   
![](https://img.shields.io/github/forks/cyberdevilz/cryptonite?style=social) 
![](https://img.shields.io/github/stars/CYBERDEVILZ/CRYPTONITE?style=social)
[![](https://img.shields.io/youtube/channel/views/UC1QZPervOHLiC4xpVnzbDFg?style=social)](https://www.youtube.com/channel/UC1QZPervOHLiC4xpVnzbDFg)

# CRYPTONITE - A Ransomware for Windows OS

![Cryptonite](https://user-images.githubusercontent.com/55954313/123502409-c500b480-d669-11eb-977b-4e9ac5c327fa.jpg)

## Fully functional ransomware that uses minimum resources to give maximum output

## TASK LIST ✔️
- [x] Encrypt all files except system specific ones
- [x] Encrytion must only be decrypted with a special key
- [x] Send the credentials of the victim to the attacker via secure tunnel, preferably **NGROK**
- [x] Pop up box should appear after encryption asking for ransom
- [x] Create a server to retrieve information sent by the victim
- [x] Add custom extension to encrypted files
- [x] Create an exe file generator
- [x] Graphical User Interface (Victim side)
- [x] Graphical User Interface (Attacker side)
- [ ] Create Windows Defender bypass script


---
# ☢️ SEE CRYPTONITE IN ACTION ☢️ (Outdated Video)

https://user-images.githubusercontent.com/55954313/135764868-2f24bebd-240c-4f77-9597-050f15067a31.mp4

---

# 📚 LEARN TO USE CRYPTONITE 📚
**Cryptonite** was developed with a motive of achieving maximum output with minimum efforts. Anyone can learn to use **Cryptonite**. I have included **two versions** of **Cryptonite**. One that stores data using **Sqlite3** and the other that uses **Mongo DB Atlas** to push the results into the cloud. Default method is to use **Sqlite3**, but if you are interested in using the **Mongo DB** version of **Cryptonite** then switch to the **mongo** branch of this repository.   
   
The below steps will guide you to use **Cryptonite** in detail (subjected to change as I add new concepts):-

## 1. SETTING UP FOR THE FIRST TIME 🍼
The following setups need to be done if you are using **Cryptonite** for the first time.

### Create an NGROK account

* Visit [NGROK](https://ngrok.com/)
* Signup for an account. If you can spare some money, then buy the premium version. Else, the free version will suffice.
* Login to [NGROK](https://dashboard.ngrok.com/login)
* Download the suitable release of **NGROK** for your operating system.

     ![image](https://user-images.githubusercontent.com/55954313/124344516-533be400-dbf0-11eb-9d8f-ff745a510e3e.png)

* Unzip and install **NGROK**.
  * For Linux / MAC users, unzip the folder via terminal: `unzip /path/to/ngrok.zip`.
  * For Windows users, just unzip the folder
  * Make sure to add ngrok to **PATH**
   

* Authenticate your **NGROK**:-   
  * Copy your AUTH TOKEN from [NGROK SETUP PAGE](https://dashboard.ngrok.com/get-started/your-authtoken)
  * For windows users, open cmd and type (replace `YOUR_AUTH_TOKEN_HERE` with your authtoken):-   
     
        ngrok authtoken YOUR_AUTH_TOKEN_HERE
  * For Linux / MAC users, open terminal and type (replace `YOUR_AUTH_TOKEN_HERE` with your authtoken):-   
     
        ./ngrok authtoken YOUR_AUTH_TOKEN_HERE

### Install the Python requirements for Cryptonite

    pip install -r "requirements.txt"  

## 2. FIRING UP THE SERVER! 🔥
Run the **Server.py** file before you send the ransomware to victims. The **Server.py** starts the server to receive victim's data sent by **Cryptonite** and creates an **NGROK tunnel** that performs **port forwarding** so that our server can be accessed by anyone around the world. Running **Server.py** also creates a **DB file** to store the victims' info.   

❗ Make sure that **Server.py** runs all the time.  

Copy the **NGROK URL** generated in the terminal. It will be useful in the next step.

## 3. FILLING UP THE DETAILS 📝
![image](https://user-images.githubusercontent.com/55954313/137672473-13c488a8-a604-4746-a134-619ef459887d.png)   

* Run **exeGen.py** and fill up the necessary details.
* **exeGen.py** will create an **exe** file that can be shipped to the victim.
* By default, Cryptonite is going to encrypt the contents of the folder named **testfolder** found in the directory where **Cryptonite.py** exists. But if you want to specify some different path, say the entire system, then make sure to edit the required field by replacing **./testfolder** to **/**   
   
### **ℹ️ INFORMATION**   
**exeGen** will automatically close after the **exe** has been generated and saved in the folder you specified. Do not try to forcefully close it. The process of creating an **exe** might take upto **5 minutes**.

## 4. TEST IT ON YOUR COMPUTER 🆗
Believe me when I say this... You can **safely test** this Ransomware on your device provided you **mention the correct path to the folder you are testing on**. I have already created a testing folder and the path has also been given. So its easier for you to see for yourself. What you need to do is run **Server.py**, execute **Cryptonite.py** and see the magic happen. If you wish to create your own folder and test it there, then mention the absolute path of the folder in place of **./testfolder**
   
 ## ⚠️ ❗ Do not give the base folder (/) for testing purposes ❗ ⚠️ 
 Never give the base folder for testing pupose as it will initiate the encryption of all the files (except the files inside these [folders](https://github.com/CYBERDEVILZ/Cryptonite/blob/0e835b6875c1a1f53c724f941c63564a2d93d6cd/Cryptonite.py#L34)). Please refrain from using the base folder unless you are absolutely sure of what you are doing. To be on the safer side, I have already ceated a **testfolder** and set the default value of the Encryption Folder Path to **testfolder**. Therefore, even if you accidentally run this Ransomware, it will only encrypt the **testfolder** and not the entire system.   

## 5. SEND IT TO YOUR VICTIMS 📬
After we have tested our Ransomware, we intend to send it to the victims in the form of an **exe** file. I have created a python script **exeGen.py** that will generate an **exe** file of custom name. By default the name would be **WindowsUpdate.exe**. But you can change it anytime you want using **exeGen.py**.   
   
Remember, creating an exe will take quite a long time (upto five minutes!), hence chill and wait out the process and **do not close exeGen.py during exe file generation**. exeGen will automatically close itself after the exe file has been generated.

### Things to consider before sending the exe file
* Make sure that the **Encryption Folder Path** is changed from **./testfolder** to **/** (if you are going for system wide encryption) or any folder path of your choice.
* All the Details should be correctly filled.
* **Server.py** must run all the time. Failure of which can result in Ransomware not being able to encrypt files (a popup of network error will be shown on the victim's screen and the Ransomware terminates).   
   
# 🚀 CRYPTONITE COMMAND CENTER 🚀
https://user-images.githubusercontent.com/55954313/136694138-6aec2389-4310-4a69-86aa-0f4dd9ee10ef.mp4

An all in one **monitoring dashboard** created to understand the **level of destruction** caused by this ransomware. The attacker can get to know the location of his victims plotted on a map with high precision. His IP address, hostname, place and other information are stored in a database and presented to the attacker in a neat table. Search and delete functionality has also been added. Grab a cup of coffee and sip on it while **Cryptonite** does all the hard work.

## 📓 Points to note...
* The Cryptonite Command Center can be accessed by running the **CommandCenter.py** file.
* Always use the inbuilt **RELOAD** button to reload the Command Center in case the values don't match up.

# Support Our YouTube Channel 📺
[![zbunkerart](https://user-images.githubusercontent.com/55954313/137255788-6b14ba33-6d3f-4c9a-9f2f-c78e088656f5.png)](https://www.youtube.com/channel/UC1QZPervOHLiC4xpVnzbDFg)
We are almost active on [YouTube](https://www.youtube.com/channel/UC1QZPervOHLiC4xpVnzbDFg) creating courses. We are relatively new to this. **Support It. Make an Impact.**

