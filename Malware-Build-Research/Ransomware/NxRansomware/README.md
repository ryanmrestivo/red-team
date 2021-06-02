# NxRansomware
A next generation of ransomware. Fully written using a .Net Framework + C&amp;C System

**Created By:** Guilherme Bacellar Moralez

# Disclaimer
**This code is created and maintened only for a research proposal. Please do not use for other proposes.**

**Please, do not run the code with a release profile. It can be seriously dangerous. Really!**


# Objectives
This project has a 2 main objectives:

* Malware Side
  * Prove that's possible to write a viable "product" using the .Net Framework
  * Prove that is hard and painfull to anti-virus to detect this kind of virus
  * Understand the execution enviroments
  * Understand the technical challenges to create a real and operational ransomware
  * Provide code and samples to AV companies and Security researchers

* C&C (Command and Control) Side
  * Build a state of art C&C system, using the latest tecnologies to prevent the backend hijack and invasion
  * Create a viable, safe and secure comunication channel between the malware and C&C infrastructure without using SSL certificates
  * Build a reversion proof C&C database system, using a in-memory storage and advanced cryptographic algorithms
 
# Ransomware Operation

***Attention:*** The Ransomware execution is locked using a hard coded rule to run (hijack files) at d:\temp - Locate the "ConfigurationManager.cs" for more informations.

**To Hijack Files**: Just run the binary (GoogleUpdate.exe)

**To Restore Files**: Run (GoogleUpdate.exe --decrypt)
