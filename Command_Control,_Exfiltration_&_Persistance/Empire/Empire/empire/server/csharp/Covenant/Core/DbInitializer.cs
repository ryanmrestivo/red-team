// Author: Ryan Cobb (@cobbr_io)
// Modified by: Jake Krasnov (@hubbl3)
// Project: Empire (https://github.com/BC-SECURITY/Empire)
//          Code originally from Covenant (https://github.com/cobbr/Covenant)
// License: GNU GPLv3

using System;
using System.IO;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Collections.Concurrent;

using Microsoft.AspNetCore.Identity;

using YamlDotNet.Serialization;

using Covenant.Models;
using Covenant.Core.Empire;

using Covenant.Models.Grunts;
using System.Runtime.Serialization;

namespace Covenant.Core
{
    public static class DbInitializer
    {

        public async static Task Initialize(ICovenantService2 service)
        {
            await InitializeTasks2(service);
        }
        
        public async static Task IngestTask(ICovenantService2 service, String recievedTask)
        {
            
            IDeserializer deserializer = new DeserializerBuilder().Build();
            List<SerializedGruntTask> serialized = deserializer.Deserialize<List<SerializedGruntTask>>(recievedTask);
            List<GruntTask> tasks = serialized.Select(S => new GruntTask().FromSerializedGruntTask(S)).ToList();
            foreach (GruntTask task in tasks)
            {
                await service.CreateGruntTask(task);

            }

        }

        public async static Task InitializeTasks2(ICovenantService2 service)
        {
            EmpireContext context = service.GetEmpire();
            if (!context.referenceAssemblies.Any())
            {
                List<ReferenceAssembly> ReferenceAssemblies = Directory.GetFiles(Common.CovenantAssemblyReferenceNet35Directory).Select(R =>
                {
                    FileInfo info = new FileInfo(R);
                    return new ReferenceAssembly
                    {
                        Name = info.Name,
                        Location = info.FullName.Replace(Common.CovenantAssemblyReferenceDirectory, ""),
                        DotNetVersion = Common.DotNetVersion.Net35
                    };
                }).ToList();
                Directory.GetFiles(Common.CovenantAssemblyReferenceNet40Directory).ToList().ForEach(R =>
                {
                    FileInfo info = new FileInfo(R);
                    ReferenceAssemblies.Add(new ReferenceAssembly
                    {
                        Name = info.Name,
                        Location = info.FullName.Replace(Common.CovenantAssemblyReferenceDirectory, ""),
                        DotNetVersion = Common.DotNetVersion.Net40
                    });
                });
                await service.CreateReferenceAssemblies(ReferenceAssemblies.ToArray());
            }
            if (!context.embeddedResources.Any())
            {
                EmbeddedResource[] EmbeddedResources = Directory.GetFiles(Common.CovenantEmbeddedResourcesDirectory).Select(R =>
                {
                    FileInfo info = new FileInfo(R);
                    return new EmbeddedResource
                    {
                        Name = info.Name,
                        Location = info.FullName.Replace(Common.CovenantEmbeddedResourcesDirectory, "")
                    };
                }).ToArray();
                await service.CreateEmbeddedResources(EmbeddedResources);
            }

            #region ReferenceSourceLibraries
            if (!context.referenceSourceLibraries.Any())
            {
                var ReferenceSourceLibraries = new ReferenceSourceLibrary[]
                {
                    new ReferenceSourceLibrary
                    {
                        Name = "SharpSploit", Description = "SharpSploit is a library for C# post-exploitation modules.",
                        Location =  "SharpSploit" + Path.DirectorySeparatorChar + "SharpSploit" + Path.DirectorySeparatorChar,
                        CompatibleDotNetVersions = new List<Common.DotNetVersion> { Common.DotNetVersion.Net35, Common.DotNetVersion.Net40 }
                    },
                    new ReferenceSourceLibrary
                    {
                        Name = "Rubeus", Description = "Rubeus is a C# toolset for raw Kerberos interaction and abuses.",
                        Location = "Rubeus" + Path.DirectorySeparatorChar,
                        CompatibleDotNetVersions = new List<Common.DotNetVersion> { Common.DotNetVersion.Net35, Common.DotNetVersion.Net40 }
                    },
                    new ReferenceSourceLibrary
                    {
                        Name = "Seatbelt", Description = "Seatbelt is a C# project that performs a number of security oriented host-survey \"safety checks\" relevant from both offensive and defensive security perspectives.",
                        Location = "Seatbelt" + Path.DirectorySeparatorChar,
                        CompatibleDotNetVersions = new List<Common.DotNetVersion> { Common.DotNetVersion.Net35, Common.DotNetVersion.Net40 }
                    },
                    new ReferenceSourceLibrary
                    {
                        Name = "SharpDPAPI", Description = "SharpDPAPI is a C# port of some Mimikatz DPAPI functionality.",
                        Location = "SharpDPAPI" + Path.DirectorySeparatorChar + "SharpDPAPI" + Path.DirectorySeparatorChar,
                        CompatibleDotNetVersions = new List<Common.DotNetVersion> { Common.DotNetVersion.Net35, Common.DotNetVersion.Net40 }
                    },
                    // new ReferenceSourceLibrary
                    // {
                    //     Name = "SharpChrome", Description = "SharpChrome is a C# port of some Mimikatz DPAPI functionality targeting Google Chrome.",
                    //     Location = Common.CovenantReferenceSourceLibraries + "SharpDPAPI" + Path.DirectorySeparatorChar + "SharpChrome" + Path.DirectorySeparatorChar,
                    //     SupportedDotNetVersions = new List<Common.DotNetVersion> { Common.DotNetVersion.Net35, Common.DotNetVersion.Net40 }
                    // },
                    new ReferenceSourceLibrary
                    {
                        Name = "SharpDump", Description = "SharpDump is a C# port of PowerSploit's Out-Minidump.ps1 functionality.",
                        Location = "SharpDump" + Path.DirectorySeparatorChar,
                        CompatibleDotNetVersions = new List<Common.DotNetVersion> { Common.DotNetVersion.Net35, Common.DotNetVersion.Net40 }
                    },
                    new ReferenceSourceLibrary
                    {
                        Name = "SharpUp", Description = "SharpUp is a C# port of various PowerUp functionality.",
                        Location = "SharpUp" + Path.DirectorySeparatorChar,
                        CompatibleDotNetVersions = new List<Common.DotNetVersion> { Common.DotNetVersion.Net35, Common.DotNetVersion.Net40 }
                    },
                    new ReferenceSourceLibrary
                    {
                        Name = "SharpWMI", Description = "SharpWMI is a C# implementation of various WMI functionality.",
                        Location = "SharpWMI" + Path.DirectorySeparatorChar,
                        CompatibleDotNetVersions = new List<Common.DotNetVersion> { Common.DotNetVersion.Net35, Common.DotNetVersion.Net40 }
                    },
                    new ReferenceSourceLibrary
                    {
                        Name = "SharpSC", Description = "SharpSC is a .NET assembly to perform basic operations with services.",
                        Location= "SharpSC" + Path.DirectorySeparatorChar,
                        CompatibleDotNetVersions = new List<Common.DotNetVersion> { Common.DotNetVersion.Net35, Common.DotNetVersion.Net40 }
                    }
                };
                await service.CreateReferenceSourceLibraries(ReferenceSourceLibraries);

                var ss = await service.GetReferenceSourceLibraryByName("SharpSploit");
                var ru = await service.GetReferenceSourceLibraryByName("Rubeus");
                var se = await service.GetReferenceSourceLibraryByName("Seatbelt");
                var sd = await service.GetReferenceSourceLibraryByName("SharpDPAPI");
                // var sc = await service.GetReferenceSourceLibraryByName("SharpChrome");
                var sdu = await service.GetReferenceSourceLibraryByName("SharpDump");
                var su = await service.GetReferenceSourceLibraryByName("SharpUp");
                var sw = await service.GetReferenceSourceLibraryByName("SharpWMI");
                var sc = await service.GetReferenceSourceLibraryByName("SharpSC");
                await service.CreateEntities(
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = ss, ReferenceAssembly = await service.GetReferenceAssemblyByName("mscorlib.dll", Common.DotNetVersion.Net35) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = ss, ReferenceAssembly = await service.GetReferenceAssemblyByName("mscorlib.dll", Common.DotNetVersion.Net40) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = ss, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.dll", Common.DotNetVersion.Net35) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = ss, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.dll", Common.DotNetVersion.Net40) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = ss, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.Core.dll", Common.DotNetVersion.Net35) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = ss, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.Core.dll", Common.DotNetVersion.Net40) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = ss, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.DirectoryServices.dll", Common.DotNetVersion.Net35) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = ss, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.DirectoryServices.dll", Common.DotNetVersion.Net40) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = ss, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.DirectoryServices.Protocols.dll", Common.DotNetVersion.Net35) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = ss, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.DirectoryServices.Protocols.dll", Common.DotNetVersion.Net40) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = ss, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.IdentityModel.dll", Common.DotNetVersion.Net35) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = ss, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.IdentityModel.dll", Common.DotNetVersion.Net40) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = ss, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.Management.dll", Common.DotNetVersion.Net35) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = ss, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.Management.dll", Common.DotNetVersion.Net40) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = ss, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.Management.Automation.dll", Common.DotNetVersion.Net35) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = ss, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.Management.Automation.dll", Common.DotNetVersion.Net40) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = ss, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.Windows.Forms.dll", Common.DotNetVersion.Net35) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = ss, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.Windows.Forms.dll", Common.DotNetVersion.Net40) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = ss, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.ServiceProcess.dll", Common.DotNetVersion.Net35) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = ss, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.ServiceProcess.dll", Common.DotNetVersion.Net40) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = ss, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.XML.dll", Common.DotNetVersion.Net35) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = ss, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.XML.dll", Common.DotNetVersion.Net40) },

    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = ru, ReferenceAssembly = await service.GetReferenceAssemblyByName("mscorlib.dll", Common.DotNetVersion.Net35) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = ru, ReferenceAssembly = await service.GetReferenceAssemblyByName("mscorlib.dll", Common.DotNetVersion.Net40) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = ru, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.dll", Common.DotNetVersion.Net35) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = ru, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.dll", Common.DotNetVersion.Net40) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = ru, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.Core.dll", Common.DotNetVersion.Net35) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = ru, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.Core.dll", Common.DotNetVersion.Net40) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = ru, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.DirectoryServices.dll", Common.DotNetVersion.Net35) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = ru, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.DirectoryServices.dll", Common.DotNetVersion.Net40) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = ru, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.DirectoryServices.AccountManagement.dll", Common.DotNetVersion.Net35) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = ru, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.DirectoryServices.AccountManagement.dll", Common.DotNetVersion.Net40) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = ru, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.IdentityModel.dll", Common.DotNetVersion.Net35) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = ru, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.IdentityModel.dll", Common.DotNetVersion.Net40) },

    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = se, ReferenceAssembly = await service.GetReferenceAssemblyByName("mscorlib.dll", Common.DotNetVersion.Net35) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = se, ReferenceAssembly = await service.GetReferenceAssemblyByName("mscorlib.dll", Common.DotNetVersion.Net40) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = se, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.dll", Common.DotNetVersion.Net35) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = se, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.dll", Common.DotNetVersion.Net40) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = se, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.Core.dll", Common.DotNetVersion.Net35) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = se, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.Core.dll", Common.DotNetVersion.Net40) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = se, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.DirectoryServices.dll", Common.DotNetVersion.Net35) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = se, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.DirectoryServices.dll", Common.DotNetVersion.Net40) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = se, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.Management.dll", Common.DotNetVersion.Net35) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = se, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.Management.dll", Common.DotNetVersion.Net40) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = se, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.ServiceProcess.dll", Common.DotNetVersion.Net35) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = se, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.ServiceProcess.dll", Common.DotNetVersion.Net40) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = se, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.XML.dll", Common.DotNetVersion.Net35) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = se, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.XML.dll", Common.DotNetVersion.Net40) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = se, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.Web.Extensions.dll", Common.DotNetVersion.Net35) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = se, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.Web.Extensions.dll", Common.DotNetVersion.Net40) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = se, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.Data.dll", Common.DotNetVersion.Net35) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = se, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.Data.dll", Common.DotNetVersion.Net40) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = se, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.Data.DataSetExtensions.dll", Common.DotNetVersion.Net35) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = se, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.Data.DataSetExtensions.dll", Common.DotNetVersion.Net40) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = se, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.Windows.Forms.dll", Common.DotNetVersion.Net35) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = se, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.Windows.Forms.dll", Common.DotNetVersion.Net40) },

    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = sd, ReferenceAssembly = await service.GetReferenceAssemblyByName("mscorlib.dll", Common.DotNetVersion.Net35) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = sd, ReferenceAssembly = await service.GetReferenceAssemblyByName("mscorlib.dll", Common.DotNetVersion.Net40) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = sd, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.dll", Common.DotNetVersion.Net35) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = sd, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.dll", Common.DotNetVersion.Net40) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = sd, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.Core.dll", Common.DotNetVersion.Net35) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = sd, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.Core.dll", Common.DotNetVersion.Net40) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = sd, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.XML.dll", Common.DotNetVersion.Net35) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = sd, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.XML.dll", Common.DotNetVersion.Net40) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = sd, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.Security.dll", Common.DotNetVersion.Net35) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = sd, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.Security.dll", Common.DotNetVersion.Net40) },

    // new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = sc, ReferenceAssembly = await service.GetReferenceAssemblyByName("mscorlib.dll", Common.DotNetVersion.Net35) },
    // new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = sc, ReferenceAssembly = await service.GetReferenceAssemblyByName("mscorlib.dll", Common.DotNetVersion.Net40) },
    // new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = sc, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.dll", Common.DotNetVersion.Net35) },
    // new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = sc, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.dll", Common.DotNetVersion.Net40) },
    // new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = sc, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.Core.dll", Common.DotNetVersion.Net35) },
    // new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = sc, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.Core.dll", Common.DotNetVersion.Net40) },
    // new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = sc, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.XML.dll", Common.DotNetVersion.Net35) },
    // new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = sc, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.XML.dll", Common.DotNetVersion.Net40) },
    // new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = sc, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.Security.dll", Common.DotNetVersion.Net35) },
    // new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = sc, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.Security.dll", Common.DotNetVersion.Net40) },


    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = sdu, ReferenceAssembly = await service.GetReferenceAssemblyByName("mscorlib.dll", Common.DotNetVersion.Net35) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = sdu, ReferenceAssembly = await service.GetReferenceAssemblyByName("mscorlib.dll", Common.DotNetVersion.Net40) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = sdu, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.dll", Common.DotNetVersion.Net35) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = sdu, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.dll", Common.DotNetVersion.Net40) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = sdu, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.Core.dll", Common.DotNetVersion.Net35) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = sdu, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.Core.dll", Common.DotNetVersion.Net40) },

    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = su, ReferenceAssembly = await service.GetReferenceAssemblyByName("mscorlib.dll", Common.DotNetVersion.Net35) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = su, ReferenceAssembly = await service.GetReferenceAssemblyByName("mscorlib.dll", Common.DotNetVersion.Net40) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = su, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.dll", Common.DotNetVersion.Net35) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = su, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.dll", Common.DotNetVersion.Net40) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = su, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.Core.dll", Common.DotNetVersion.Net35) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = su, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.Core.dll", Common.DotNetVersion.Net40) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = su, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.Management.dll", Common.DotNetVersion.Net35) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = su, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.Management.dll", Common.DotNetVersion.Net40) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = su, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.ServiceProcess.dll", Common.DotNetVersion.Net35) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = su, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.ServiceProcess.dll", Common.DotNetVersion.Net40) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = su, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.XML.dll", Common.DotNetVersion.Net35) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = su, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.XML.dll", Common.DotNetVersion.Net40) },

    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = sw, ReferenceAssembly = await service.GetReferenceAssemblyByName("mscorlib.dll", Common.DotNetVersion.Net35) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = sw, ReferenceAssembly = await service.GetReferenceAssemblyByName("mscorlib.dll", Common.DotNetVersion.Net40) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = sw, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.dll", Common.DotNetVersion.Net35) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = sw, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.dll", Common.DotNetVersion.Net40) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = sw, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.Core.dll", Common.DotNetVersion.Net35) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = sw, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.Core.dll", Common.DotNetVersion.Net40) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = sw, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.Management.dll", Common.DotNetVersion.Net35) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = sw, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.Management.dll", Common.DotNetVersion.Net40) },

    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = sc, ReferenceAssembly = await service.GetReferenceAssemblyByName("mscorlib.dll", Common.DotNetVersion.Net35) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = sc, ReferenceAssembly = await service.GetReferenceAssemblyByName("mscorlib.dll", Common.DotNetVersion.Net40) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = sc, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.dll", Common.DotNetVersion.Net35) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = sc, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.dll", Common.DotNetVersion.Net40) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = sc, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.Core.dll", Common.DotNetVersion.Net35) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = sc, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.Core.dll", Common.DotNetVersion.Net40) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = sc, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.ServiceProcess.dll", Common.DotNetVersion.Net35) },
    new ReferenceSourceLibraryReferenceAssembly { ReferenceSourceLibrary = sc, ReferenceAssembly = await service.GetReferenceAssemblyByName("System.ServiceProcess.dll", Common.DotNetVersion.Net40) }
                );
            }
            #endregion
            
            if (!context.gruntTasks.Any())
            {
                List<string> files = Directory.GetFiles(Common.CovenantTaskDirectory)
                    .Where(F => F.EndsWith(".yaml", StringComparison.CurrentCultureIgnoreCase))
                    .ToList();
                IDeserializer deserializer = new DeserializerBuilder().Build();
                foreach (string file in files)
                {
                    
                    string yaml = File.ReadAllText(file);
                    List<SerializedGruntTask> serialized = deserializer.Deserialize<List<SerializedGruntTask>>(yaml);
                    List<GruntTask> tasks = serialized.Select(S => new GruntTask().FromSerializedGruntTask(S)).ToList();
                    foreach (GruntTask task in tasks)
                    {
                        await service.CreateGruntTask(task);
                        
                    }
                }
            }
        }

    }
}