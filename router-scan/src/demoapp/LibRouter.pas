// LibRouter headers for Delphi
// Copyright (C) Stas'M Corp. 2014-2017

// Project home page:
// http://stascorp.com/load/1-1-0-56

unit LibRouter;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
{$IFnDEF FPC}
  Windows;
{$ELSE}
  LCLIntf, LCLType, LMessages;
{$ENDIF}

const
  // library file name
  librouterdll = {$IFDEF MSWINDOWS}'librouter.dll'{$ELSE}'liblibrouter.so'{$ENDIF};
const
  // GetParam / SetParam usage
  stEnableDebug          = 0;
  stDebugVerbosity       = 1;
  stWriteLogCallback     = 2;
  stSetTableDataCallback = 3;
  stUserAgent            = 4;
  stUseCustomPage        = 5;
  stCustomPage           = 6;
  stDualAuthCheck        = 7;
  stPairsBasic           = 8;
  stPairsDigest          = 9;
  stProxyType            = 10;
  stProxyIP              = 11;
  stProxyPort            = 12;
  stUseCredentials       = 13;
  stCredentialsUsername  = 14;
  stCredentialsPassword  = 15;
  stPairsForm            = 16;
  stFilterRules          = 17;
  stProxyUseAuth         = 18;
  stProxyUser            = 19;
  stProxyPass            = 20;
const
  // SetTableData processing
  stcStatus     = 'Status';
  stcAuth       = 'Auth';
  stcType       = 'Type';
  stcRadioOff   = 'RadioOff';
  stcHidden     = 'Hidden';
  stcCheckX     = '[X]';
  stcMinus      = '-';
  stcBSSID      = 'BSSID';
  stcNoWireless = '<no wireless>';
  stcSSID       = 'SSID';
  stcSec        = 'Sec';
  stcKey        = 'Key';
  stcPin        = 'WPS';
  stcLANIP      = 'LANIP';
  stcLANMask    = 'LANMask';
  stcBridge     = '<bridge>';
  stcWANIP      = 'WANIP';
  stcWANMask    = 'WANMask';
  stcWANGate    = 'WANGate';
  stcDNS        = 'DNS';

type
  // callback procedures
  pfWriteLog = procedure(Str: PChar; Verbosity: Byte); stdcall;
  pfSetTableData = procedure(Row: DWord; Name, Value: PChar); stdcall;
type
  // structures
  TModuleDesc = record
    Enabled: Bool;
    Name: packed array[0..15] of Char;
    Desc: packed array[0..31] of Char;
  end;
  PModuleDesc = ^TModuleDesc;

function Initialize: Bool; stdcall;
function GetModuleCount(var Count: DWord): Bool; stdcall;
function GetModuleInfo(Index: DWord; Info: PModuleDesc): Bool; stdcall;
function SwitchModule(Index: DWord; Enabled: Bool): Bool; stdcall;
function GetParam(St: DWord; var Value: DWord; Size: DWord;
  var outLength: DWord): Bool; stdcall; overload;
  external librouterdll name {$IFDEF UNICODE}'GetParamW'{$ELSE}'GetParamA'{$ENDIF};
function GetParam(St: DWord; Value: Pointer; Size: DWord;
  var outLength: DWord): Bool; stdcall; overload;
  external librouterdll name {$IFDEF UNICODE}'GetParamW'{$ELSE}'GetParamA'{$ENDIF};
function GetParam(St: DWord; var Value: Bool; Size: DWord;
  var outLength: DWord): Bool; stdcall; overload;
  external librouterdll name {$IFDEF UNICODE}'GetParamW'{$ELSE}'GetParamA'{$ENDIF};
function SetParam(St: DWord; Value: NativeUInt): Bool; stdcall; overload;
  external librouterdll name {$IFDEF UNICODE}'SetParamW'{$ELSE}'SetParamA'{$ENDIF};
function SetParam(St: DWord; Value: Pointer): Bool; stdcall; overload;
  external librouterdll name {$IFDEF UNICODE}'SetParamW'{$ELSE}'SetParamA'{$ENDIF};
function SetParam(St: DWord; Value: Bool): Bool; stdcall; overload;
function PrepareRouter(Row, IP: DWord; Port: Word; var hRouter: Pointer): Bool; stdcall;
function ScanRouter(hRouter: Pointer): Bool; stdcall;
function StopRouter(hRouter: Pointer): Bool; stdcall;
function IsRouterStopping(hRouter: Pointer): Bool; stdcall;
function FreeRouter(hRouter: Pointer): Bool; stdcall;

implementation

function Initialize; external librouterdll;
function GetModuleCount; external librouterdll;
function GetModuleInfo; external librouterdll
  name {$IFDEF UNICODE}'GetModuleInfoW'{$ELSE}'GetModuleInfoA'{$ENDIF};
function SwitchModule; external librouterdll;
function PrepareRouter; external librouterdll;
function ScanRouter; external librouterdll;
function StopRouter; external librouterdll;
function IsRouterStopping; external librouterdll;
function FreeRouter; external librouterdll;
function SetParam(St: DWord; Value: Bool): Bool; stdcall; overload;
begin
  Result := SetParam(St, NativeUInt(Value));
end;

end.

