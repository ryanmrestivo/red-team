// Demo console application using LibRouter
// Copyright (C) Stas'M Corp. 2014-2017

// Project home page:
// http://stascorp.com/load/1-1-0-56

program demo;

{$IFDEF FPC}
  {$MODE DelphiUnicode}
{$ENDIF}

{$APPTYPE CONSOLE}

uses
{$IFDEF UNIX}
  cthreads,
  cmem,
{$ENDIF}
{$IFnDEF FPC}
  Windows,
{$ENDIF}
  SysUtils,
  LibRouter;

type
  TIPv4 = record case Boolean of
    False: (dw: LongWord);
    True: (b: Array[0..3] of Byte);
  end;

procedure SetTableDataW(Row: DWord; Name, Value: PChar); stdcall;
begin
  if Row <> 123 then
    Exit;
  Writeln(String(Name), ': ', String(Value));
end;

var
  mCount: DWord;
  I: Integer;
  Module: TModuleDesc;
  Pairs: String;
  IP: TIPv4;
  Port: Word;
  hRouter: Pointer;
begin
  if not Initialize() then begin
    Writeln('Initialize failed');
    Exit;
  end;
  Writeln('librouter initialized!');

  if not GetModuleCount(mCount) then begin
    Writeln('GetModuleCount failed');
    Exit;
  end;
  for I := 0 to mCount - 1 do begin
    if not GetModuleInfo(I, @Module) then begin
      Writeln('GetModuleInfo failed');
      Exit;
    end;
    Write('Module name: ', String(Module.Name), ' (');
    if Module.Enabled then
      Writeln('enabled)')
    else
      Writeln('disabled)');
    Writeln('Module desc: ', String(Module.Desc));
    Writeln('');
  end;

  SetParam(stProxyType, 0); // don't use proxy
  SetParam(stUserAgent, PChar('Mozilla/5.0 (Windows NT 5.1; rv:9.0.1) Gecko/20100101 Firefox/9.0.1'));
  SetParam(stUseCustomPage, Pointer(False));
  SetParam(stDualAuthCheck, Pointer(False));
  Writeln('Settings updated');

  Pairs := 'admin'#9'admin'#13#10+
           'admin'#9'password'#13#10+
           'admin'#9'1234'#13#10;
  if not SetParam(stPairsBasic, PChar(Pairs)) then begin
    Writeln('Failed to load Basic Authentication pairs');
    Exit;
  end;
  if not SetParam(stPairsDigest, PChar(Pairs)) then begin
    Writeln('Failed to load Digest Authentication pairs');
    Exit;
  end;
  if not SetParam(stPairsForm, PChar(Pairs)) then begin
    Writeln('Failed to load Form Authentication pairs');
    Exit;
  end;
  Writeln('Pairs updated');

  if not SetParam(stSetTableDataCallback, @SetTableDataW) then begin
    Writeln('Failed to set callback procedure');
    Exit;
  end;

  Writeln('');
  while True do begin
    Writeln('Enter IP address to scan (ex. 192 168 1 1):');
    Read(IP.b[3]);
    Read(IP.b[2]);
    Read(IP.b[1]);
    Read(IP.b[0]);
    Writeln('Enter port number:');
    Readln(Port);

    if not PrepareRouter(123, IP.dw, Port, hRouter) then begin
      Writeln('PrepareRouter failed');
      Exit;
    end;
    Writeln('Scanning router...');
    if not ScanRouter(hRouter) then begin
      Writeln('ScanRouter failed');
      Exit;
    end;
    if not FreeRouter(hRouter) then begin
      Writeln('FreeRouter failed');
      Exit;
    end;
    Writeln('');
  end;
end.
