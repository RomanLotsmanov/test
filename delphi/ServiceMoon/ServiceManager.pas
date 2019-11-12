{----------------------------------------------------------------
 Unit:     ServiceManager.pas
 Purpose:  Wrapper around some of the Windows API Functions
           supporting NT-Services.
 Autors:   Frederik Schaller (frederik.schaller@myschaller.ch
           Marc Duerst (marc@idev.ch)

           Lotsmanov R.A. 2012 modified
 ----------------------------------------------------------------}

unit ServiceManager;

interface

uses
  SysUtils, Windows, WinSvc;

type

  TServiceManager = class
  private
    { Private declarations }
    ServiceControlManager: SC_Handle;
    ServiceHandle:         SC_Handle;
  protected
    function DoStartService(NumberOfArgument: DWord; ServiceArgVectors: PChar): boolean;
  public
    { Public declarations }
    function Connect(MachineName: Pchar = nil; DatabaseName: PChar = nil; Access: DWord = SC_MANAGER_ALL_ACCESS): boolean;  // Access may be SC_MANAGER_ALL_ACCESS
    function OpenServiceConnection(ServiceName: PChar) : boolean;
    function StartService: boolean; overload; // Simple start
    function StartService(NumberOfArgument: DWord; ServiceArgVectors: PChar): boolean; overload; // More complex start
    function StopService: boolean;
    function PauseService : boolean;
    function ContinueService : boolean;
    function ShutdownService : boolean;
    function DisableService : boolean;
    function EnableService : boolean;
    function GetStatus : DWORD;
    function ServiceRunning : boolean;
    function ServiceStopped : boolean;
  end;

implementation

{ TServiceManager }

function TServiceManager.Connect(MachineName, DatabaseName: PChar; Access: DWord): boolean;
begin
  result := false;
  { open a connection to the windows service manager }
  ServiceControlManager := OpenSCManager(MachineName, DatabaseName, Access);
  result := (ServiceControlManager <> 0);
end;


function TServiceManager.OpenServiceConnection(ServiceName: PChar): boolean;
begin
  result := false;
  { open a connetcion to a specific service }
  ServiceHandle := OpenService(ServiceControlManager, ServiceName, SERVICE_ALL_ACCESS);
  result := (ServiceHandle <> 0);
end;

function TServiceManager.PauseService : boolean;
var
  ServiceStatus:         TServiceStatus;
begin
  { Pause the service: attention not supported by all services }
  Result := ControlService(ServiceHandle, SERVICE_CONTROL_PAUSE, ServiceStatus);
end;

function TServiceManager.StopService : boolean;
var
  ServiceStatus:         TServiceStatus;
begin
  { Stop the service }
  result := ControlService(ServiceHandle, SERVICE_CONTROL_STOP, ServiceStatus);
end;

function TServiceManager.ContinueService : boolean;
var
  ServiceStatus:         TServiceStatus;
begin
  { Continue the service after a pause: attention not supported by all services }
  Result := ControlService(ServiceHandle, SERVICE_CONTROL_CONTINUE, ServiceStatus);
end;

function TServiceManager.ShutdownService : boolean;
var
  ServiceStatus:         TServiceStatus;
begin
  { Shut service down: attention not supported by all services }
  Result := ControlService(ServiceHandle, SERVICE_CONTROL_SHUTDOWN, ServiceStatus);
end;

function TServiceManager.StartService: boolean;
begin
  result := DoStartService(0, '');
end;

function TServiceManager.StartService(NumberOfArgument: DWord; ServiceArgVectors: PChar): boolean;
begin
  result := DoStartService(NumberOfArgument, ServiceArgVectors);
end;

function TServiceManager.GetStatus: DWORD;
var
  ServiceStatus:         TServiceStatus;
begin
{ Returns the status of the service. Maybe you want to check this
  more than once, so just call this function again.
  Results may be: SERVICE_STOPPED
                  SERVICE_START_PENDING
                  SERVICE_STOP_PENDING
                  SERVICE_RUNNING
                  SERVICE_CONTINUE_PENDING
                  SERVICE_PAUSE_PENDING
                  SERVICE_PAUSED   }
  result := 0;
  QueryServiceStatus(ServiceHandle, ServiceStatus);
  result := ServiceStatus.dwCurrentState;
end;

function TServiceManager.DisableService : boolean;
begin
  Result := ChangeServiceConfig(ServiceHandle, SERVICE_NO_CHANGE, SERVICE_DISABLED, SERVICE_NO_CHANGE, nil, nil, nil, nil, nil, nil, nil);
end;

function TServiceManager.EnableService : boolean;
begin
  Result := ChangeServiceConfig(ServiceHandle, SERVICE_NO_CHANGE, SERVICE_AUTO_START, SERVICE_NO_CHANGE, nil, nil, nil, nil, nil, nil, nil);
end;

function TServiceManager.ServiceRunning: boolean;
begin
  result := (GetStatus = SERVICE_RUNNING);
end;

function TServiceManager.ServiceStopped: boolean;
begin
  result := (GetStatus = SERVICE_STOPPED);
end;

function TServiceManager.DoStartService(NumberOfArgument: DWord; ServiceArgVectors: PChar): boolean;
var
  err : integer;
begin
  result := WinSvc.StartService(ServiceHandle, NumberOfArgument, ServiceArgVectors);
end;

end.
