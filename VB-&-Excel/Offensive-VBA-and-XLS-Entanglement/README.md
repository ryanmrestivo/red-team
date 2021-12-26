# Offensive VBA and XLS Entanglement
This repo provides examples of how VBA can be used for offensive purposes beyond a simple dropper or shell injector. As we develop more use cases, the repo will be updated. The main entry in the repo is the code for demonstrating the XLS Entanglement attack. 

# Why VBA?
VBA provides every capability that other offensive languages offer including rudimentry reflection capability with the modification of the AccessVBOM registry key. In addition to that, VBA runs inside of programs that are traditionally long running programs on a victim's computers including Outlook. This means that a beacon can run entirely inside "native processes without the need to migrate processes or open additional ports. If Outlook is converted to a C2 beacon, then there is no need for the beacon to reach out of the network either. With the ability to export Win32 APIs we have the ability to execute all kinds of attacks, including things like [Kerberoasting](https://github.com/Adepts-Of-0xCC/VBA-macro-experiments/blob/main/kerberoast.vba) or running [Embedded PEs](https://github.com/itm4n/VBA-RunPE).

# Examples
| File | Description |
| ---  | --- |
| [HelloWorld.vba](../main/HelloWorld.vba)| Demonstrates disabling the protections against accessing the VBA project and dynamically injecting VBA code|
| [HelloWorldWin32_API.vba](../main/HelloWorld_Win32API.vba)| Same as HelloWorld.vba but uses Win32 APIs instead of WScript to modify the registry|
| [OutlookC2_POC.vba](../main/OutlookC2_POC.vba)| Macro to convert Outlook into a C2 that watches for an email and injects VBA into an Excel file|
| [XLS Entaglement](../main/XLS%20Entanglement)| Contains the files for executing a rudimentry XLS Entanglement attack|
