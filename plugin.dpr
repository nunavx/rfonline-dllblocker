library plugin;

uses
  Windows,
  SysUtils,
  tlhelp32;

function Enigma_Plugin_About : PWideChar;
begin
  Enigma_Plugin_About :='Dll Blocker. Created by Unknown, Modified by Nuna.';
  // Function returns a wide string that will be shown in about column in Enigma Miscellaneous - Plugins
end;

function Enigma_Plugin_Description : PWideChar;
begin
  Enigma_Plugin_Description :='Block specified dll with dll';
  // Function returns a wide string that will be shown after user clicks on the plugin in Enigma Miscellaneous - Plugins
  // It may contain, for example, usage instructions
end;

const
  UNALLOWED_MODULES : array [0..1] of string =
  ('module1.dll', 'module2.dll');

var
  TimerID, TimerIDKill : dword;
  TimerInitialized : boolean = false;

function FindModule : boolean;
var
  me32 : MODULEENTRY32;
  i : integer;
  SnapShotID : dword;
begin
  // This function is calling when the protected file is being initialized
  // when main program is not initialized yet
  Result := false;
  //
  SnapShotID := CreateToolhelp32Snapshot(TH32CS_SNAPMODULE, GetCurrentProcessID);
  if SnapShotID <> 0 then
  begin
    me32.dwSize := SizeOf(me32);
    if Module32First(SnapShotID, me32) then
    begin
      repeat
        // search unallowed module
        for i := 0 to length(UNALLOWED_MODULES) - 1 do
        begin
          if LowerCase(UNALLOWED_MODULES[i]) = LowerCase(string(me32.szModule)) then
          begin
            Result := true;
            break;
          end;
        end;
        if Result then
        begin
          break;
        end;
      until not Module32Next(SnapShotID, me32);
    end;
    CloseHandle(SnapShotID);
  end;
end;

procedure Enigma_Plugin_OnInit;
begin

end;

procedure Timer_KillMe(hwnd : HWND; uMsg, idEvent, dwTime : dword); stdcall;
begin
  if (idEvent <> TimerIDKill) then Exit;
  KillTimer(0, idEvent);
  ExitProcess(0);
end;

procedure Timer_CheckMe(hwnd : HWND; uMsg, idEvent, dwTime : dword); stdcall;
begin
  if (idEvent <> TimerID) then Exit;
  if not TimerInitialized then
  begin
    KillTimer(0, idEvent);
    TimerID := SetTimer(0, 1, 1000 + Random(1000), @Timer_CheckMe);
  end;
  TimerInitialized := true;
  // check the module
  if FindModule then
  begin
    TimerIDKill := SetTimer(0, 1, 1000 + Random(1000), @Timer_KillMe);
    KillTimer(0, idEvent);
  end;
end;

procedure Enigma_Plugin_OnFinal;
begin
  // This function is calling when the protected file is initilized,
  // main program encrypted and ready for execution

  // start timer to check first process, delay for about 10 seconds
  TimerInitialized := false;
  TimerID := SetTimer(0, 1, 1000 + Random(1000), @Timer_CheckMe);
end;


exports
  Enigma_Plugin_About,
  Enigma_Plugin_Description,
  Enigma_Plugin_OnInit,
  Enigma_Plugin_OnFinal;

begin
end.
