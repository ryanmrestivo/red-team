unit Logic;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Process;

const
  CKEY1 = 77776;
  CKEY2 = 13666;
  MasterKey = 34;

function EncryptStr(const S :WideString; Key: Word): String;
function DecryptStr(const S: String; Key: Word): String;
procedure ToggleCrypt(var MS: TMemoryStream; Key: Word);
procedure ChangeIcon(ExeName, IcoName: String);
procedure ChDel(FileName: String);

implementation

function EncryptStr(const S :WideString; Key: Word): String;
var   i          :Integer;
      RStr       :String;
      RStrB      :TBytes Absolute RStr;
begin
  Result:= '';
  RStr:= UTF8Encode(S);
  for i := 0 to Length(RStr)-1 do begin
    RStrB[i] := RStrB[i] xor (Key shr 8);
    Key := (RStrB[i] + Key) * CKEY1 + CKEY2;
  end;
  for i := 0 to Length(RStr)-1 do begin
    Result:= Result + IntToHex(RStrB[i], 2);
  end;
end;

function DecryptStr(const S: String; Key: Word): String;
var   i, tmpKey  :Integer;
      RStr       :String;
      RStrB      :TBytes Absolute RStr;
      tmpStr     :string;
begin
  tmpStr:= UpperCase(S);
  SetLength(RStr, Length(tmpStr) div 2);
  i:= 1;
  try
    while (i < Length(tmpStr)) do begin
      RStrB[i div 2]:= StrToInt('$' + tmpStr[i] + tmpStr[i+1]);
      Inc(i, 2);
    end;
  except
    Result:= '';
    Exit;
  end;
  for i := 0 to Length(RStr)-1 do begin
    tmpKey:= RStrB[i];
    RStrB[i] := RStrB[i] xor (Key shr 8);
    Key := (tmpKey + Key) * CKEY1 + CKEY2;
  end;
  Result:= {%H-}UTF8Decode(RStr);
end;

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

procedure ChangeIcon(ExeName, IcoName: String);
var
  M: TProcess;
Begin
  M:=TProcess.Create(Nil);
  M.Executable:='mod\ResTool.exe';
  M.ShowWindow:=swoHIDE;
  //M.CurrentDirectory:=GetCurrentDir;
  M.Parameters.Add('-addoverwrite "Build.exe", "Build.exe", "'+IcoName+'", ICONGROUP, MAINICON, 0');
  M.Options:=[poWaitOnExit];
  M.Execute;
  M.Free;
  DeleteFile('mod\ResTool.ini');
  DeleteFile('mod\ResTool.log');
end;

procedure ChDel(FileName: String);
Begin
  if FileExists(FileName) then DeleteFile(FileName);
end;

end.

