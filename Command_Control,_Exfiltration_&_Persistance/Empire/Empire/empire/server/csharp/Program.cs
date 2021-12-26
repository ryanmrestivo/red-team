using Sharpire;
using System;

class Program
{
    static void Main()
    {
        
        Console.WriteLine("Enter Arguments");
        string[] arguments = Console.ReadLine().Split(' ');
        SessionInfo sessionInfo = new SessionInfo(arguments);
        (new EmpireStager(sessionInfo)).Execute();
    }
}

 

