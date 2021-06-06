using System;
using System.Collections.Generic;
using System.Text;

namespace Baphomet.Models
{
    public class UsbDeviceDTO
    {
        public string Name { get; set; }
        public long FreeSpace { get; set; }
        public string Format { get; set; }

    }
}
