unit Debug;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

procedure Dump(Str, F: String);
function MSToString(M: TMemoryStream): AnsiString;
procedure Log(Str: String; Color: Byte);

const
  BLACK=0;
  BLUE=1;
  GREEN=2;
  CYAN=3;
  RED=4;
  MAGENTA=5;
  BROWN=6;
  LIGHTGRAY=7;
  DARKGRAY=8;
  LIGHTBLUE=9;
  LIGHTGREEN=10;
  LIGHTCYAN=11;
  LIGHTRED=12;
  LIGHTMAGENTA=13;
  YELLOW=14;
  WHITE=15;
  BLINK=128;

implementation

procedure Dump(Str, F: String);
var
  FFile: Text;
Begin
  AssignFile(FFile, F);
  if FileExists(F) then Begin
    Append(FFile);
    Str:=sLineBreak+Str;
  end else Rewrite(FFile);
  Writeln(FFile, Str);
  CloseFile(FFile);
end;

function MSToString(M: TMemoryStream): AnsiString;
begin
  SetString(Result, PAnsiChar(M.Memory), M.Size);
end;

procedure Log(Str: String; Color: Byte);
Begin
  TextColor(Color);
  Writeln(Str);
  TextColor(LightGray);
end;

end.

