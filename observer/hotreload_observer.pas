unit hotreload_observer;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

procedure Register;

implementation

uses
  Dialogs,
  LazIDEIntf,
  MenuIntf,
  ProjectIntf,
  dirwatch,
  WebSocket2;


type

  { TObserver }

  TObserver = class
  private
    FDir: string;
    FDirWatch: TDirwatch;
    FPort: string;
    FWebSocket: TWebSocketServer;
    procedure DirChange(Sender: TObject; {%H-}AEntry: TDirectoryEntry; {%H-}AEvents: TFileEvents);
  public
    constructor Create(const APort, ADir: string);
    destructor Destroy; override;
  end;

{ TObserver }

procedure TObserver.DirChange(Sender: TObject; AEntry: TDirectoryEntry; AEvents: TFileEvents);
var
  VIndex: integer;
begin
  if (Assigned(FWebSocket)) then
  begin
    FWebSocket.LockTermination;
    try
      for VIndex := 0 to (FWebSocket.Count - 1) do
      begin
        TWebSocketCustomConnection(FWebSocket[VIndex]).SendText('reload');
      end;
    finally
      FWebSocket.UnLockTermination;
    end;
  end;
end;

constructor TObserver.Create(const APort, ADir: string);
begin
  inherited Create;
  FPort := APort;
  FDir := ADir;
  FWebSocket := TWebSocketServer.Create('localhost', APort);
  FWebSocket.Start;
  FDirWatch := TDirwatch.Create(nil);
  FDirWatch.AddWatch(ADir, AllEvents);
  FDirWatch.OnChange := @DirChange;
  TThread.ExecuteInThread(@FDirWatch.StartWatch);
end;

destructor TObserver.Destroy;
begin
  FDirWatch.Terminate;
  FWebSocket.TerminateThread;
  FreeAndNil(FDirWatch);
  FreeAndNil(FWebSocket);
  inherited Destroy;
end;

var
  VDir: string = '/home/';
  VObserver: TObserver = nil;
  VPort: string = '8090';

procedure stop_observer(Sender: TObject);
begin
  if (Assigned(VObserver)) then
  begin
    FreeAndNil(VObserver);
  end;
end;


procedure start_observer(Sender: TObject);
var
  VActiveProject: TLazProject;
begin
  stop_observer(nil);
  VActiveProject := LazarusIDE.ActiveProject;
  if (Assigned(VActiveProject)) and
    (LowerCase(VActiveProject.LazCompilerOptions.TargetOS) = 'browser') then
  begin
    VDir := ExtractFilePath(LazarusIDE.ActiveProject.ProjectInfoFile);

    VPort := InputBox('Port', '', '8090');

    VObserver := TObserver.Create(VPort, VDir);
  end;
end;


procedure observer_info(Sender: TObject);
begin
  ShowMessage(Format('Port:%s|Dir:%s|Observing:%s',
    [VPort, VDir, BoolToStr(Assigned(VObserver), 'true', 'false')]));
end;


procedure Register;   
var
  VMenu: TIDEMenuSection;
begin
  VMenu := RegisterIDESubMenu(mnuTools, 'hotreload', 'Hot Reload', nil, nil);
  RegisterIDEMenuCommand(VMenu, 'hotreload_start', 'Start...', nil, @start_observer);
  RegisterIDEMenuCommand(VMenu, 'hotreload_stop', 'Stop...', nil, @stop_observer);
  RegisterIDEMenuCommand(VMenu, 'hotreload_info', 'Info...', nil, @observer_info);
end;


end.
