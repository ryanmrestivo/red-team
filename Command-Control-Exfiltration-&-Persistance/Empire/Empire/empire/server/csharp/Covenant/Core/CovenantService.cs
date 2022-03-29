// Author: Ryan Cobb (@cobbr_io)
// Modified by: Jake Krasnov (@_hubbl3)
// Project: Empire (https://github.com/BC-SECURITY/Empire)
//          code originally from Covenant (https://github.com/cobbr/Covenant)
// License: GNU GPLv3

using System;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Security.Claims;
using System.Collections.Generic;
using System.Collections.Concurrent;
using System.Text.RegularExpressions;

using Microsoft.Extensions.Configuration;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Identity;
using Microsoft.CodeAnalysis;


using Covenant.Models;

using Covenant.Models.Grunts;

using Covenant.Core.Empire;

namespace Covenant.Core
{


    public interface IIdentityRoleService
    {
        Task<IEnumerable<IdentityRole>> GetRoles();
        Task<IdentityRole> GetRole(string roleId);
        Task<IdentityRole> GetRoleByName(string rolename);
    }

    public interface IIdentityUserRoleService
    {
        Task<IEnumerable<IdentityUserRole<string>>> GetUserRoles();
        Task<IEnumerable<IdentityUserRole<string>>> GetUserRolesForUser(string userId);
        Task<IdentityUserRole<string>> GetUserRole(string userId, string roleId);
        Task<IdentityUserRole<string>> CreateUserRole(string userId, string roleId);
        Task DeleteUserRole(string userId, string roleId);
    }




    public interface IReferenceAssemblyService
    {
        Task<IEnumerable<ReferenceAssembly>> GetReferenceAssemblies();
        Task<IEnumerable<ReferenceAssembly>> GetDefaultNet35ReferenceAssemblies();
        Task<IEnumerable<ReferenceAssembly>> GetDefaultNet40ReferenceAssemblies();
        Task<ReferenceAssembly> GetReferenceAssembly(int id);
        Task<ReferenceAssembly> GetReferenceAssemblyByName(string name, Common.DotNetVersion version);
        Task<ReferenceAssembly> CreateReferenceAssembly(ReferenceAssembly assembly);
        Task<IEnumerable<ReferenceAssembly>> CreateReferenceAssemblies(params ReferenceAssembly[] assemblies);
        Task<ReferenceAssembly> EditReferenceAssembly(ReferenceAssembly assembly);
        Task DeleteReferenceAssembly(int id);
    }

    public interface IEmbeddedResourceService
    {
        Task<IEnumerable<EmbeddedResource>> GetEmbeddedResources();
        Task<EmbeddedResource> GetEmbeddedResource(int id);
        Task<EmbeddedResource> GetEmbeddedResourceByName(string name);
        Task<EmbeddedResource> CreateEmbeddedResource(EmbeddedResource resource);
        Task<IEnumerable<EmbeddedResource>> CreateEmbeddedResources(params EmbeddedResource[] resources);
        Task<EmbeddedResource> EditEmbeddedResource(EmbeddedResource resource);
        Task DeleteEmbeddedResource(int id);
    }

    public interface IReferenceSourceLibraryService
    {
        Task<IEnumerable<ReferenceSourceLibrary>> GetReferenceSourceLibraries();
        Task<ReferenceSourceLibrary> GetReferenceSourceLibrary(int id);
        Task<ReferenceSourceLibrary> GetReferenceSourceLibraryByName(string name);
        Task<ReferenceSourceLibrary> CreateReferenceSourceLibrary(ReferenceSourceLibrary library);
        Task<IEnumerable<ReferenceSourceLibrary>> CreateReferenceSourceLibraries(params ReferenceSourceLibrary[] libraries);
        Task<ReferenceSourceLibrary> EditReferenceSourceLibrary(ReferenceSourceLibrary library);
        Task DeleteReferenceSourceLibrary(int id);
    }

    public interface IGruntTaskOptionService
    {
        Task<GruntTaskOption> EditGruntTaskOption(GruntTaskOption option);
        Task<GruntTaskOption> CreateGruntTaskOption(GruntTaskOption option);
        Task<IEnumerable<GruntTaskOption>> CreateGruntTaskOptions(params GruntTaskOption[] options);
    }


    public interface IGruntTaskService : IReferenceAssemblyService, IEmbeddedResourceService, IReferenceSourceLibraryService,
        IGruntTaskOptionService
    {
        Task<IEnumerable<GruntTask>> GetGruntTasks();
        Task<IEnumerable<GruntTask>> GetGruntTasksForGrunt(int gruntId);
        Task<GruntTask> GetGruntTask(int id);
        Task<GruntTask> GetGruntTaskByName(string name, Common.DotNetVersion version = Common.DotNetVersion.Net35);
        Task<GruntTask> CreateGruntTask(GruntTask task);
        Task<IEnumerable<GruntTask>> CreateGruntTasks(params GruntTask[] tasks);
        Task<GruntTask> EditGruntTask(GruntTask task);
        Task DeleteGruntTask(int taskId);
        Task<string> ParseParametersIntoTask(GruntTask task, List<ParsedParameter> parameters);
    }

    public interface IGruntCommandService
    {
        Task<IEnumerable<GruntCommand>> GetGruntCommands();
        Task<IEnumerable<GruntCommand>> GetGruntCommandsForGrunt(int gruntId);
        Task<GruntCommand> GetGruntCommand(int id);
        Task<GruntCommand> CreateGruntCommand(GruntCommand command);
        Task<IEnumerable<GruntCommand>> CreateGruntCommands(params GruntCommand[] commands);
        Task<GruntCommand> EditGruntCommand(GruntCommand command);
        Task DeleteGruntCommand(int id);
    }

    public interface ICommandOutputService
    {
        Task<IEnumerable<CommandOutput>> GetCommandOutputs();
        Task<CommandOutput> GetCommandOutput(int commandOutputId);
        Task<CommandOutput> CreateCommandOutput(CommandOutput output);
        Task<IEnumerable<CommandOutput>> CreateCommandOutputs(params CommandOutput[] outputs);
        Task<CommandOutput> EditCommandOutput(CommandOutput output);
        Task DeleteCommandOutput(int id);
    }

    public interface IGruntTaskingService
    {
        Task<IEnumerable<GruntTasking>> GetGruntTaskings();
        Task<IEnumerable<GruntTasking>> GetGruntTaskingsForGrunt(int gruntId);
        Task<IEnumerable<GruntTasking>> GetUninitializedGruntTaskingsForGrunt(int gruntId);
        Task<IEnumerable<GruntTasking>> GetGruntTaskingsSearch(int gruntId);
        Task<GruntTasking> GetGruntTasking(int taskingId);
        Task<GruntTasking> GetGruntTaskingByName(string taskingName);
        Task<GruntTasking> CreateGruntTasking(GruntTasking tasking);
        Task<IEnumerable<GruntTasking>> CreateGruntTaskings(params GruntTasking[] taskings);
        Task<GruntTasking> EditGruntTasking(GruntTasking tasking);
        Task DeleteGruntTasking(int taskingId);
    }


    public interface ICovenantService2 : IGruntTaskService 
    {
        Task<IEnumerable<T>> CreateEntities<T>(params T[] entities);
        EmpireContext GetEmpire();
        void DisposeContext();
    }




    
    public class EmpireService: ICovenantService2 
    {
        protected EmpireContext _context;
        public EmpireService()
        {
            _context = new EmpireContext();
        }

        public EmpireContext GetEmpire()
        {
            return _context;
        }

        #region Test Compiler Request
        public byte[] CompileExe(GruntTask task, Common.DotNetVersion version, OutputKind outputKind, Boolean Compress)
        {
            byte[] ILBytes = null;
            if (version == Common.DotNetVersion.Net35 || version == Common.DotNetVersion.Net40)
            {
                List<Compiler.Reference> references = null;
                switch (version)
                {
                    case Common.DotNetVersion.Net35:
                        references = Common.DefaultNet35References;
                        break;
                    case Common.DotNetVersion.Net40:
                        references = Common.DefaultNet40References;
                        break;
                }
                ILBytes = Compiler.Compile(new Compiler.CsharpFrameworkCompilationRequest
                {
                    Language = task.Language,
                    Source = task.Code,
                    TargetDotNetVersion = version,
                    OutputKind = outputKind,
                    References = references
                });
            }
            else if (version == Common.DotNetVersion.NetCore31)
            {
                string src = task.Code;
                string sanitizedName = Utilities.GetSanitizedFilename(task.Name);
                string dir = Common.CovenantDataDirectory + "Grunt" + Path.DirectorySeparatorChar + sanitizedName + Path.DirectorySeparatorChar;
                string ResultName;
                /*if (template.StagerCode == CodeTemplate)
                {
                    ResultName = sanitizedName + "Stager";
                    dir += sanitizedName + "Stager" + Path.DirectorySeparatorChar;
                    string file = sanitizedName + "Stager" + Utilities.GetExtensionForLanguage(template.Language);
                    File.WriteAllText(dir + file, src);
                }*/
                if(true)
                {
                    ResultName = sanitizedName;
                    dir += sanitizedName + Path.DirectorySeparatorChar;
                    string file = sanitizedName + Utilities.GetExtensionForLanguage(task.Language);
                    File.WriteAllText(dir + file, src);
                }
                ILBytes = Compiler.Compile(new Compiler.CsharpCoreCompilationRequest
                {
                    ResultName = ResultName,
                    Language = task.Language,
                    TargetDotNetVersion = version,
                    SourceDirectory = dir,
                    OutputKind = outputKind,
                    //update this to not be hardcoded 
                    RuntimeIdentifier = Compiler.RuntimeIdentifier.win_x64,
                    UseSubprocess = true
                });
            }
            if (ILBytes == null || ILBytes.Length == 0)
            {
                throw new CovenantCompileGruntStagerFailedException("Compiling Grunt code failed");
            }
            if (Compress)
            {
                ILBytes = Utilities.Compress(ILBytes);
            }
            return ILBytes;
        }
        #endregion




        //Eventually this may access the Empire DB instead but for now just shove it in a list 
        //This actually might end up being handled on the python side anyways
        public async Task<IEnumerable<T>> CreateEntities<T>(params T[] entities)
        {

            foreach (T entity in entities)
            {
                _context.Add(entity);
            }

            return entities;
        }

        
               
        public async Task<string> ParseParametersIntoTask(GruntTask task, List<ParsedParameter> parameters)
        {
            return null;
        }

            #region Core functions for Empire Service


            public async Task<IEnumerable<EmbeddedResource>> CreateEmbeddedResources(params EmbeddedResource[] resources)
        {
            _context.embeddedResources = resources.OfType<EmbeddedResource>().ToList();
            return resources;
        }

        //Reference Assembly methods
        public async Task<ReferenceAssembly> GetReferenceAssemblyByName(string name, Common.DotNetVersion version)
        {
            ReferenceAssembly assembly = _context.referenceAssemblies.First(asm => asm.Name == name);
            return assembly;
        }

        public async Task<IEnumerable<ReferenceAssembly>> CreateReferenceAssemblies(params ReferenceAssembly[] assemblies)
        {
            
            _context.referenceAssemblies = assemblies.OfType<ReferenceAssembly>().ToList();
            
            return assemblies;
        }

        //Refrence library methods

        public async Task<IEnumerable<ReferenceSourceLibrary>> CreateReferenceSourceLibraries(params ReferenceSourceLibrary[] libraries)
        {
            _context.referenceSourceLibraries = libraries.OfType<ReferenceSourceLibrary>().ToList();
            return libraries;
        }

        public async Task<ReferenceSourceLibrary> GetReferenceSourceLibraryByName(string name)
        {
            //original had an include for ReferenceSourceLibraryReferenceAssemblies.ReferenceAssembly and ReferenceSourceLibraryEmbeddedResources.EmbeddedResource
            // if there is an issue with retrieving a library look into this atrribute more 
            ReferenceSourceLibrary library = _context.referenceSourceLibraries.First(RSL => RSL.Name == name);
            if (library == null)
            {
                Console.WriteLine($"NotFound - ReferenceSourceLibrary with Name: {name}");
            }
            return library;
        }

        //Grunt Task Methods
        public async Task<GruntTask> GetGruntTask(int id)
        {
            GruntTask task = _context.gruntTasks.FirstOrDefault(tsk => tsk.Id == id);
            if (task == null)
            {
                Console.WriteLine($"NotFound - GruntTask with id: {id}");
            }
            return task;
        }

        public async Task<GruntTask> CreateGruntTask(GruntTask task)
        {
            //Need to consider restructuring this method and the context class 
            //The way it is currently done is built around interacting with a sqllite db. 
            //need to decide if the Empire server will manage the DB directly.
            List<GruntTaskOption> options = task.Options.ToList();
            List<EmbeddedResource> resources = task.EmbeddedResources.ToList();
            List<ReferenceAssembly> assemblies = task.ReferenceAssemblies.ToList();
            List<ReferenceSourceLibrary> libraries = task.ReferenceSourceLibraries.ToList();
            task.Options = new List<GruntTaskOption>();
            task.EmbeddedResources.ForEach(ER => task.Remove(ER));
            task.ReferenceAssemblies.ForEach(RA => task.Remove(RA));
            task.ReferenceSourceLibraries.ForEach(RSL => task.Remove(RSL));
            task.Id = _context.GetNextTaskID();

            foreach (GruntTaskOption option in options)
            {
                option.GruntTaskId = task.Id;
                //since the option is being added to the task not sure the options need to be stored separately 
                //this was a structure done for the covenant Db
                _context.Add(option);
                task.Options.Add(option);
            }
            foreach (EmbeddedResource resource in resources)
            {
                await this.CreateEntities(
                    new GruntTaskEmbeddedResource
                    {
                        EmbeddedResource = await this.GetEmbeddedResourceByName(resource.Name),
                        GruntTask = task
                    }
                );
                task.Add(resource);
            }
            foreach (ReferenceAssembly assembly in assemblies)
            {
                //This is all Database schema based so doesn't work without the databasse
                await this.CreateEntities(
                    new GruntTaskReferenceAssembly
                    {
                        ReferenceAssembly = await this.GetReferenceAssemblyByName(assembly.Name, assembly.DotNetVersion),
                        GruntTask = task
                    }
                );
                //instead do this
                task.Add(assembly);
            }
            foreach (ReferenceSourceLibrary library in libraries)
            {
               /* await this.CreateEntities(
                    new GruntTaskReferenceSourceLibrary
                    {
                        ReferenceSourceLibrary = await this.GetReferenceSourceLibraryByName(library.Name),
                        GruntTask = task
                    }
                );*/
                task.Add(library);
            }
            //add the Grunt task to teh context list
            _context.Add(task);
            // _notifier.OnCreateGruntTask(this, task);
            return await this.GetGruntTask(task.Id);
        }

        public async Task<IEnumerable<GruntTask>> GetGruntTasks()
        {
            return _context.gruntTasks;
        }

        public List<GruntTask> GetGruntTasks2()
        {
            return _context.gruntTasks;
        }

        public void DisposeContext()
        {
            _context = new EmpireContext();
        }

        //This is what actually compiles the code
        public async Task<GruntTasking> CreateGruntTasking(GruntTasking tasking)
        {
            //I don't think we need this part at the moment
            //
            //tasking.Grunt = await this.GetGrunt(tasking.GruntId);
            //tasking.Grunt.Listener = await this.GetListener(tasking.Grunt.ListenerId);
            //tasking.GruntTask = await this.GetGruntTask(tasking.GruntTaskId);
            //tasking.GruntCommand = await this.GetGruntCommand(tasking.GruntCommandId);
            //tasking.GruntCommand.CommandOutput ??= await this.GetCommandOutput(tasking.GruntCommand.CommandOutputId);
            List<string> parameters = tasking.GruntTask.Options.OrderBy(O => O.Id).Select(O => string.IsNullOrEmpty(O.Value) ? O.DefaultValue : O.Value).ToList();
            /*if (tasking.GruntTask.Name.Equals("powershell", StringComparison.OrdinalIgnoreCase) && !string.IsNullOrWhiteSpace(tasking.Grunt.PowerShellImport))
            {
                parameters[0] = Common.CovenantEncoding.GetString(Convert.FromBase64String(tasking.Grunt.PowerShellImport)) + "\r\n" + parameters[0];
            }
            else if (tasking.GruntTask.Name.Equals("powershellimport", StringComparison.OrdinalIgnoreCase))
            {
                if (parameters.Count >= 1)
                {
                    string import = parameters[0];
                    byte[] importBytes = Convert.FromBase64String(import);
                    if (importBytes.Length >= 3 && importBytes[0] == 0xEF && importBytes[1] == 0xBB && importBytes[2] == 0xBF)
                    {
                        import = Convert.ToBase64String(importBytes.Skip(3).ToArray());
                    }
                    tasking.Grunt.PowerShellImport = import;
                }
                else
                {
                    tasking.Grunt.PowerShellImport = "";
                }
                _context.Grunts.Update(tasking.Grunt);
                tasking.GruntCommand.CommandOutput.Output = "PowerShell Imported";

                _context.GruntCommands.Update(tasking.GruntCommand);
                await _context.SaveChangesAsync();
                await _notifier.NotifyEditGrunt(this, tasking.Grunt);
                await _notifier.NotifyEditGruntCommand(this, tasking.GruntCommand);
                tasking.Status = GruntTaskingStatus.Completed;
            }
            else if (tasking.GruntTask.Name.Equals("wmigrunt", StringComparison.OrdinalIgnoreCase))
            {
                Launcher l = await _context.Launchers.FirstOrDefaultAsync(L => L.Name.ToLower() == parameters[1].ToLower());
                if (l == null || l.LauncherString == null || l.LauncherString.Trim() == "")
                {
                    throw new ControllerNotFoundException($"NotFound - Launcher with name: {parameters[1]}");
                }

                // Add .exe extension if needed
                List<string> split = l.LauncherString.Split(" ").ToList();
                parameters[1] = split.FirstOrDefault();
                if (!parameters[1].EndsWith(".exe", StringComparison.OrdinalIgnoreCase)) { parameters[1] += ".exe"; }

                // Add Directory
                string Directory = "C:\\Windows\\System32\\";
                if (parameters[1].Equals("powershell.exe", StringComparison.OrdinalIgnoreCase)) { Directory += "WindowsPowerShell\\v1.0\\"; }
                else if (parameters[1].Equals("wmic.exe", StringComparison.OrdinalIgnoreCase)) { Directory += "wbem\\"; }
                if (!parameters[1].StartsWith("C:\\", StringComparison.OrdinalIgnoreCase)) { parameters[1] = Directory + parameters[1]; }
                if (split.Count > 1) { parameters[1] += " " + String.Join(" ", split.Skip(1).ToArray()); }
            }
            else if (tasking.GruntTask.Name.Equals("dcomgrunt", StringComparison.OrdinalIgnoreCase))
            {
                Launcher l = await _context.Launchers.FirstOrDefaultAsync(L => L.Name.ToLower() == parameters[1].ToLower());
                if (l == null || l.LauncherString == null || l.LauncherString.Trim() == "")
                {
                    throw new ControllerNotFoundException($"NotFound - Launcher with name: {parameters[1]}");
                }
                // Add .exe extension if needed
                List<string> split = l.LauncherString.Split(" ").ToList();
                parameters[1] = split.FirstOrDefault();
                if (!parameters[1].EndsWith(".exe", StringComparison.OrdinalIgnoreCase)) { parameters[1] += ".exe"; }

                // Add command parameters
                split.RemoveAt(0);
                parameters.Insert(2, String.Join(" ", split.ToArray()));

                // Add Directory
                string Directory = "C:\\Windows\\System32\\";
                if (parameters[1].Equals("powershell.exe", StringComparison.OrdinalIgnoreCase)) { Directory += "WindowsPowerShell\\v1.0\\"; }
                else if (parameters[1].Equals("wmic.exe", StringComparison.OrdinalIgnoreCase)) { Directory += "wbem\\"; }
                if (!parameters[1].StartsWith("C:\\", StringComparison.OrdinalIgnoreCase)) { parameters[1] = Directory + parameters[1]; }

                parameters.Insert(3, Directory);
            }
            else if (tasking.GruntTask.Name.Equals("powershellremotinggrunt", StringComparison.OrdinalIgnoreCase))
            {
                Launcher l = await _context.Launchers.FirstOrDefaultAsync(L => L.Name.ToLower() == parameters[1].ToLower());
                if (l == null || l.LauncherString == null || l.LauncherString.Trim() == "")
                {
                    throw new ControllerNotFoundException($"NotFound - Launcher with name: {parameters[1]}");
                }
                // Add .exe extension if needed
                List<string> split = l.LauncherString.Split(" ").ToList();
                parameters[1] = split.FirstOrDefault();
                if (!parameters[1].EndsWith(".exe", StringComparison.OrdinalIgnoreCase)) { parameters[1] += ".exe"; }
                // Add Directory
                string Directory = "C:\\Windows\\System32\\";
                if (parameters[1].Equals("powershell.exe", StringComparison.OrdinalIgnoreCase)) { Directory += "WindowsPowerShell\\v1.0\\"; }
                else if (parameters[1].Equals("wmic.exe", StringComparison.OrdinalIgnoreCase)) { Directory += "wbem\\"; }
                if (!parameters[1].StartsWith("C:\\", StringComparison.OrdinalIgnoreCase)) { parameters[1] = Directory + parameters[1]; }
                parameters[1] = parameters[1] + " " + string.Join(" ", split.Skip(1).ToList());
            }
            else if (tasking.GruntTask.Name.Equals("bypassuacgrunt", StringComparison.OrdinalIgnoreCase))
            {
                Launcher l = await _context.Launchers.FirstOrDefaultAsync(L => L.Name.ToLower() == parameters[0].ToLower());
                if (l == null || l.LauncherString == null || l.LauncherString.Trim() == "")
                {
                    throw new ControllerNotFoundException($"NotFound - Launcher with name: {parameters[0]}");
                }
                // Add .exe extension if needed
                string[] split = l.LauncherString.Split(" ");
                parameters[0] = split.FirstOrDefault();
                if (!parameters[0].EndsWith(".exe", StringComparison.OrdinalIgnoreCase)) { parameters[0] += ".exe"; }

                // Add parameters need for BypassUAC Task
                string ArgParams = String.Join(" ", split.ToList().GetRange(1, split.Count() - 1));
                string Directory = "C:\\Windows\\System32\\";
                if (parameters[0].Equals("powershell.exe", StringComparison.OrdinalIgnoreCase)) { Directory += "WindowsPowerShell\\v1.0\\"; }
                else if (parameters[0].Equals("wmic.exe", StringComparison.OrdinalIgnoreCase)) { Directory += "wbem\\"; }

                parameters.Add(ArgParams);
                parameters.Add(Directory);
                parameters.Add("0");
            }
            else*/
            if (tasking.GruntTask.Name.Equals("SharpShell", StringComparison.CurrentCultureIgnoreCase))
            {
                string WrapperFunctionFormat =
    @"using System;
using System.IO;
using System.Linq;
using System.Text;
using System.Security;
using System.Security.Principal;
using System.Collections.Generic;
using SharpSploit.Credentials;
using SharpSploit.Enumeration;
using SharpSploit.Execution;
using SharpSploit.Generic;
using SharpSploit.Misc;
using SharpSploit.LateralMovement;

public static class Task
{{
    public static string Execute()
    {{
        {0}
    }}
}}";
                string csharpcode = string.Join(" ", parameters);
                tasking.GruntTask.Code = string.Format(WrapperFunctionFormat, csharpcode);
                tasking.GruntTask.Compiled = false;
                _context.Update(tasking.GruntTask);
                parameters = new List<string> { };
            }
            /*else if (tasking.GruntTask.Name.Equals("Disconnect", StringComparison.CurrentCultureIgnoreCase))
            {
                Grunt g = await this.GetGruntByName(parameters[0]);
                parameters[0] = g.GUID;
            }
            else if (tasking.GruntTask.Name.Equals("Connect", StringComparison.CurrentCultureIgnoreCase))
            {
                parameters[0] = parameters[0] == "localhost" ? tasking.Grunt.Hostname : parameters[0];
                parameters[0] = parameters[0] == "127.0.0.1" ? tasking.Grunt.IPAddress : parameters[0];
            }*/
            tasking.Parameters = parameters;
            try
            {
                //tasking.GruntTask.Compile(tasking.runtimeIdentifier);
            }
            catch (CompilerException e)
            {
                Console.WriteLine("compile failed");
            }
            /*await _context.GruntTaskings.AddAsync(tasking);
            await _context.SaveChangesAsync();
            tasking.GruntCommand.GruntTaskingId = tasking.Id;
            tasking.GruntCommand.GruntTasking = tasking;
            await this.EditGruntCommand(tasking.GruntCommand);
            Grunt parent = (await this.GetParentGrunt(tasking.Grunt)) ?? tasking.Grunt;
            parent.Listener = await this.GetListener(parent.ListenerId);
            await _notifier.NotifyCreateGruntTasking(this, tasking);
            await _notifier.NotifyNotifyListener(this, parent);*/
            return tasking;
        }
        #endregion

        #region GruntTaskComponents EmbeddedResource Actions
        public async Task<IEnumerable<EmbeddedResource>> GetEmbeddedResources()
        {
            return _context.embeddedResources.ToList();
        }

        public async Task<EmbeddedResource> GetEmbeddedResource(int id)
        {
            EmbeddedResource resource =  _context.embeddedResources.FirstOrDefault(ER => ER.Id == id);
            if (resource == null)
            {
                throw new ControllerNotFoundException($"NotFound - EmbeddedResource with id: {id}");
            }
            return resource;
        }

        public async Task<EmbeddedResource> GetEmbeddedResourceByName(string name)
        {
            EmbeddedResource resource = _context.embeddedResources
                .Where(ER => ER.Name == name)
                .FirstOrDefault();
            if (resource == null)
            {
                throw new ControllerNotFoundException($"NotFound - EmbeddedResource with Name: {name}");
            }
            return resource;
        }

        public async Task<EmbeddedResource> CreateEmbeddedResource(EmbeddedResource resource)
        {
            _context.embeddedResources.Add(resource);
            // _notifier.OnCreateEmbeddedResource(this, resource);
            return await this.GetEmbeddedResource(resource.Id);
        }


        //NOT FULLY IMPLEMENTED
        public async Task<EmbeddedResource> EditEmbeddedResource(EmbeddedResource resource)
        {
            EmbeddedResource matchingResource = await this.GetEmbeddedResource(resource.Id);
            matchingResource.Name = resource.Name;
            matchingResource.Location = resource.Location;
            //_context.embeddedResources.Update(matchingResource);
            
            // _notifier.OnEditEmbeddedResource(this, resource);
            return await this.GetEmbeddedResource(matchingResource.Id);
        }

        public async Task DeleteEmbeddedResource(int id)
        {
            EmbeddedResource matchingResource = await this.GetEmbeddedResource(id);
            _context.embeddedResources.Remove(matchingResource);
            // _notifier.OnDeleteEmbeddedResource(this, matchingResource.Id);
            
        }
        #endregion

        #region GruntTaskOption Actions
        public async Task<GruntTaskOption> EditGruntTaskOption(GruntTaskOption option)
        {
            /*_context.Entry(option).State = EntityState.Modified;
            await _context.SaveChangesAsync();*/
            return option;
        }

        public async Task<GruntTaskOption> CreateGruntTaskOption(GruntTaskOption option)
        {
            _context.Add(option);
            
            // _notifier.OnCreateGruntTaskOption(this, option);
            return option;
        }

        public async Task<IEnumerable<GruntTaskOption>> CreateGruntTaskOptions(params GruntTaskOption[] options)
        {
            _context.gruntTaskOptions.AddRange(options);
            
            return options;
        }
        #endregion

       

        #region GruntTask Actions

        public async Task<IEnumerable<GruntTask>> GetGruntTasksForGrunt(int gruntId)
        {
            //Grunt grunt = await this.GetGrunt(gruntId);
            return _context.gruntTasks
                // .Where(T => T.SupportedDotNetVersions.Contains(version))
                /*.Include(T => T.Options)
                .Include(T => T.Author)
                .Include("GruntTaskReferenceSourceLibraries.ReferenceSourceLibrary")
                .Include("GruntTaskReferenceSourceLibraries.ReferenceSourceLibrary.ReferenceSourceLibraryReferenceAssemblies.ReferenceAssembly")
                .Include("GruntTaskReferenceSourceLibraries.ReferenceSourceLibrary.ReferenceSourceLibraryEmbeddedResources.EmbeddedResource")
                .Include("GruntTaskReferenceAssemblies.ReferenceAssembly")
                .Include("GruntTaskEmbeddedResources.EmbeddedResource")*/
                .AsEnumerable()
                .Where(T => T.CompatibleDotNetVersions.Contains(Common.DotNetVersion.Net35));
        }


        public async Task<GruntTask> GetGruntTaskByName(string name, Common.DotNetVersion version = Common.DotNetVersion.Net35)
        {
            string lower = name.ToLower();

            GruntTask task = _context.gruntTasks
                .Where(T => T.Name.ToLower() == lower)
                // .Where(T => T.CompatibleDotNetVersions.Contains(version))
                /*.Include(T => T.Options)
                .Include(T => T.Author)
                .Include("GruntTaskReferenceSourceLibraries.ReferenceSourceLibrary")
                .Include("GruntTaskReferenceSourceLibraries.ReferenceSourceLibrary.ReferenceSourceLibraryReferenceAssemblies.ReferenceAssembly")
                .Include("GruntTaskReferenceSourceLibraries.ReferenceSourceLibrary.ReferenceSourceLibraryEmbeddedResources.EmbeddedResource")
                .Include("GruntTaskReferenceAssemblies.ReferenceAssembly")
                .Include("GruntTaskEmbeddedResources.EmbeddedResource")*/
                .AsEnumerable()
                .Where(T => T.CompatibleDotNetVersions.Contains(version))
                .FirstOrDefault();
            if (task == null)
            {
                // Probably bad performance here
                task = _context.gruntTasks
                    /*.Include(T => T.Options)
                    .Include(T => T.Author)
                    .Include("GruntTaskReferenceSourceLibraries.ReferenceSourceLibrary")
                    .Include("GruntTaskReferenceSourceLibraries.ReferenceSourceLibrary.ReferenceSourceLibraryReferenceAssemblies.ReferenceAssembly")
                    .Include("GruntTaskReferenceSourceLibraries.ReferenceSourceLibrary.ReferenceSourceLibraryEmbeddedResources.EmbeddedResource")
                    .Include("GruntTaskReferenceAssemblies.ReferenceAssembly")
                    .Include("GruntTaskEmbeddedResources.EmbeddedResource")*/
                    .AsEnumerable()
                    .Where(T => T.Aliases.Any(A => A.Equals(lower, StringComparison.CurrentCultureIgnoreCase)))
                    .Where(T => T.CompatibleDotNetVersions.Contains(version))
                    .FirstOrDefault();
                if (task == null)
                {
                    throw new ControllerNotFoundException($"NotFound - GruntTask with Name: {name}");
                }
            }
            return await Task.FromResult(task);
        }

        private async Task<string> GetUsageForGruntTask(int id)
        {
            return await GetUsageForGruntTask(await this.GetGruntTask(id));
        }

        private async Task<string> GetUsageForGruntTask(GruntTask task)
        {
            string usage = "Usage: " + task.Name;
            foreach (var option in task.Options)
            {
                if (option.Optional)
                {
                    usage += "[ <" + option.Name.ToLower() + "> ]";
                }
                else
                {
                    usage += " <" + option.Name.ToLower() + ">";
                }
            }
            return await Task.FromResult(usage);
        }

        

        public async Task<IEnumerable<GruntTask>> CreateGruntTasks(params GruntTask[] tasks)
        {
            List<GruntTask> createdTasks = new List<GruntTask>();
            foreach (GruntTask t in tasks)
            {
                createdTasks.Add(await this.CreateGruntTask(t));
            }
            return createdTasks;
        }

        public async Task<GruntTask> EditGruntTask(GruntTask task)
        {
            /*GruntTask updatingTask = await this.GetGruntTask(task.Id);
            updatingTask.Name = task.Name;
            updatingTask.Description = task.Description;
            updatingTask.Help = task.Help;
            updatingTask.Aliases = task.Aliases;
            if (updatingTask.Code != task.Code)
            {
                updatingTask.Code = task.Code;
                updatingTask.Compiled = false;
            }
            else
            {
                updatingTask.Compiled = task.Compiled;
            }
            updatingTask.UnsafeCompile = task.UnsafeCompile;
            updatingTask.TokenTask = task.TokenTask;
            updatingTask.TaskingType = task.TaskingType;

            task.Options.Where(O => O.Id == 0).ToList().ForEach(async O => await this.CreateGruntTaskOption(O));
            var removeOptions = updatingTask.Options.Select(UT => UT.Id).Except(task.Options.Select(O => O.Id));
            removeOptions.ToList().ForEach(RO => updatingTask.Options.Remove(updatingTask.Options.FirstOrDefault(UO => UO.Id == RO)));
            foreach (var option in updatingTask.Options)
            {
                var newOption = task.Options.FirstOrDefault(T => T.Id == option.Id);
                if (newOption != null)
                {
                    option.Name = newOption.Name;
                    option.Description = newOption.Description;
                    option.Value = newOption.Value;
                    option.SuggestedValues = newOption.SuggestedValues;
                    option.Optional = newOption.Optional;
                    option.DisplayInCommand = newOption.DisplayInCommand;
                }
            }

            var removeAssemblies = updatingTask.ReferenceAssemblies.Select(MRA => MRA.Id).Except(task.ReferenceAssemblies.Select(RA => RA.Id));
            var addAssemblies = task.ReferenceAssemblies.Select(MRA => MRA.Id).Except(updatingTask.ReferenceAssemblies.Select(MRA => MRA.Id));
            removeAssemblies.ToList().ForEach(async RA => updatingTask.Remove(await this.GetReferenceAssembly(RA)));
            addAssemblies.ToList().ForEach(async AA => updatingTask.Add(await this.GetReferenceAssembly(AA)));

            var removeResources = updatingTask.EmbeddedResources.Select(MER => MER.Id).Except(task.EmbeddedResources.Select(ER => ER.Id));
            var addResources = task.EmbeddedResources.Select(MER => MER.Id).Except(updatingTask.EmbeddedResources.Select(MER => MER.Id));
            removeResources.ToList().ForEach(async RR => updatingTask.Remove(await this.GetEmbeddedResource(RR)));
            addResources.ToList().ForEach(async AR => updatingTask.Add(await this.GetEmbeddedResource(AR)));

            var removeLibraries = updatingTask.ReferenceSourceLibraries.Select(MRSL => MRSL.Id).Except(task.ReferenceSourceLibraries.Select(RSL => RSL.Id));
            var addLibraries = task.ReferenceSourceLibraries.Select(RSL => RSL.Id).Except(updatingTask.ReferenceSourceLibraries.Select(MRSL => MRSL.Id));
            removeLibraries.ToList().ForEach(async RL => updatingTask.Remove(await this.GetReferenceSourceLibrary(RL)));
            addLibraries.ToList().ForEach(async AL => updatingTask.Add(await this.GetReferenceSourceLibrary(AL)));

            GruntTaskAuthor author = await _context.GruntTaskAuthors.FirstOrDefaultAsync(A => A.Name == task.Author.Name);
            if (author != null)
            {
                updatingTask.AuthorId = author.Id;
                updatingTask.Author = author;
            }
            else
            {
                await _context.GruntTaskAuthors.AddAsync(task.Author);
                await _context.SaveChangesAsync();
                updatingTask.AuthorId = task.Author.Id;
                updatingTask.Author = task.Author;
            }

            _context.GruntTasks.Update(updatingTask);
            await _context.SaveChangesAsync();

            // _notifier.OnEditGruntTask(this, updatingTask);*/
            return null;
        }

        public async Task DeleteGruntTask(int taskId)
        {
            /*GruntTask removingTask = await this.getGruntTask(taskId);
            if (removingTask == null)
            {
                throw new ControllerNotFoundException($"NotFound - GruntTask with id: {taskId}");
            }
            _context.gruntTasks.Remove(removingTask);
            
            // _notifier.OnDeleteGruntTask(this, removingTask.Id);*/
        }
        #endregion


       

        #region GruntTaskComponents ReferenceSourceLibrary Actions
        public async Task<IEnumerable<ReferenceSourceLibrary>> GetReferenceSourceLibraries()
        {
            return _context.referenceSourceLibraries;
                /*.Include("ReferenceSourceLibraryReferenceAssemblies.ReferenceAssembly")
                .Include("ReferenceSourceLibraryEmbeddedResources.EmbeddedResource")
                .ToListA();*/
        }

        public async Task<ReferenceSourceLibrary> GetReferenceSourceLibrary(int id)
        {
            ReferenceSourceLibrary library = _context.referenceSourceLibraries
                .Where(RSL => RSL.Id == id)
                /*.Include("ReferenceSourceLibraryReferenceAssemblies.ReferenceAssembly")
                .Include("ReferenceSourceLibraryEmbeddedResources.EmbeddedResource")*/
                .FirstOrDefault();
            if (library == null)
            {
                throw new ControllerNotFoundException($"NotFound - ReferenceSourceLibrary with id: {id}");
            }
            return library;
        }

       

        public async Task<ReferenceSourceLibrary> CreateReferenceSourceLibrary(ReferenceSourceLibrary library)
        {
            _context.referenceSourceLibraries.Add(library);
            // _notifier.OnCreateReferenceSourceLibrary(this, library);
            return await this.GetReferenceSourceLibrary(library.Id);
        }

        //This not properly down at the moment
        public async Task<ReferenceSourceLibrary> EditReferenceSourceLibrary(ReferenceSourceLibrary library)
        {
            /*ReferenceSourceLibrary matchingLibrary = await this.GetReferenceSourceLibrary(library.Id);
            matchingLibrary.Name = library.Name;
            matchingLibrary.Description = library.Description;
            matchingLibrary.Location = library.Location;

            var removeAssemblies = matchingLibrary.ReferenceAssemblies.Select(MRA => MRA.Id).Except(library.ReferenceAssemblies.Select(RA => RA.Id));
            var addAssemblies = library.ReferenceAssemblies.Select(MRA => MRA.Id).Except(matchingLibrary.ReferenceAssemblies.Select(MRA => MRA.Id));
            removeAssemblies.ToList().ForEach(async RA => matchingLibrary.Remove(await this.GetReferenceAssembly(RA)));
            addAssemblies.ToList().ForEach(async AA => matchingLibrary.Add(await this.GetReferenceAssembly(AA)));

            var removeResources = matchingLibrary.EmbeddedResources.Select(MER => MER.Id).Except(library.EmbeddedResources.Select(ER => ER.Id));
            var addResources = library.EmbeddedResources.Select(MER => MER.Id).Except(matchingLibrary.EmbeddedResources.Select(MER => MER.Id));
            removeResources.ToList().ForEach(async RR => matchingLibrary.Remove(await this.GetEmbeddedResource(RR)));
            addResources.ToList().ForEach(async AR => matchingLibrary.Add(await this.GetEmbeddedResource(AR)));

            _context.referenceSourceLibraries.Update(matchingLibrary);*/
            
            // _notifier.OnEditReferenceSourceLibrary(this, library);
            return await this.GetReferenceSourceLibrary(library.Id);
        }

        public async Task DeleteReferenceSourceLibrary(int id)
        {
            ReferenceSourceLibrary referenceSourceLibrary = await this.GetReferenceSourceLibrary(id);
            _context.referenceSourceLibraries.Remove(referenceSourceLibrary);
            
            // _notifier.OnDeleteReferenceSourceLibrary(this, referenceSourceLibrary.Id);
        }
        #endregion
        #region GruntTaskComponent ReferenceAssembly Actions
        public async Task<IEnumerable<ReferenceAssembly>> GetReferenceAssemblies()
        {
            return _context.referenceAssemblies.ToList();
        }

        public async Task<IEnumerable<ReferenceAssembly>> GetDefaultNet35ReferenceAssemblies()
        {
            return new List<ReferenceAssembly>
            {
                await this.GetReferenceAssemblyByName("mscorlib.dll", Common.DotNetVersion.Net35),
                await this.GetReferenceAssemblyByName("System.dll", Common.DotNetVersion.Net35),
                await this.GetReferenceAssemblyByName("System.Core.dll", Common.DotNetVersion.Net35)
            };
        }

        public async Task<IEnumerable<ReferenceAssembly>> GetDefaultNet40ReferenceAssemblies()
        {
            return new List<ReferenceAssembly>
            {
                await this.GetReferenceAssemblyByName("mscorlib.dll", Common.DotNetVersion.Net40),
                await this.GetReferenceAssemblyByName("System.dll", Common.DotNetVersion.Net40),
                await this.GetReferenceAssemblyByName("System.Core.dll", Common.DotNetVersion.Net40)
            };
        }

        public async Task<ReferenceAssembly> GetReferenceAssembly(int id)
        {
            ReferenceAssembly assembly = _context.referenceAssemblies.FirstOrDefault(RA => RA.Id == id);
            if (assembly == null)
            {
                throw new ControllerNotFoundException($"NotFound - ReferenceAssembly with id: {id}");
            }
            return assembly;
        }


        public async Task<ReferenceAssembly> CreateReferenceAssembly(ReferenceAssembly assembly)
        {
            _context.referenceAssemblies.Add(assembly);
            // _notifier.OnCreateReferenceAssembly(this, assembly);
            return await this.GetReferenceAssembly(assembly.Id);
        }

        public async Task<ReferenceAssembly> EditReferenceAssembly(ReferenceAssembly assembly)
        {
            ReferenceAssembly matchingAssembly = await this.GetReferenceAssembly(assembly.Id);
            matchingAssembly.Name = assembly.Name;
            matchingAssembly.Location = assembly.Location;
            matchingAssembly.DotNetVersion = assembly.DotNetVersion;
            //_context.ReferenceAssemblies.Update(matchingAssembly);
            
            // _notifier.OnEditReferenceAssembly(this, matchingAssembly);
            return await this.GetReferenceAssembly(matchingAssembly.Id);
        }

        public async Task DeleteReferenceAssembly(int id)
        {
            ReferenceAssembly matchingAssembly = await this.GetReferenceAssembly(id);
            _context.referenceAssemblies.Remove(matchingAssembly);
            // _notifier.OnDeleteReferenceAssembly(this, matchingAssembly.Id);
        }
        #endregion
    }

}

