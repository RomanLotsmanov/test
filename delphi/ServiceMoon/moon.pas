unit moon;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, WinSvc, DateUtils, Math,
  ToolWin, ImgList, ServiceManager, Menus, Spin, PingSend;

const
  NOT_SERVER_CONECT     = $0000000A;
  NOT_SERVICE_CONECT    = $0000000B;
  NOT_SUCCESS_OPERATION = $0000000C;
  myProgress : array[0..3] of char = ('-', '\', '|', '/');

type
  TForm1 = class(TForm)
    lv1: TListView;
    tmr1: TTimer;
    pnl2: TPanel;
    pb1: TProgressBar;
    pnl3: TPanel;
    edt1: TEdit;
    btn1: TButton;
    btn2: TButton;
    ImageList1: TImageList;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ComboBoxEx1: TComboBoxEx;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    ToolButton12: TToolButton;
    ToolButton13: TToolButton;
    ToolButton14: TToolButton;
    ToolButton15: TToolButton;
    PopupMenu1: TPopupMenu;
    Selectall1: TMenuItem;
    Deselectall1: TMenuItem;
    Invert1: TMenuItem;
    SpinEdit1: TSpinEdit;
    btn3: TToolButton;
    tmr2: TTimer;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tmr1Timer(Sender: TObject);
    procedure lv1CustomDrawItem(Sender: TCustomListView; Item: TListItem;
      State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure btn2Click(Sender: TObject);
    procedure pnl1Click(Sender: TObject);
    procedure ToolButton5Click(Sender: TObject);
    procedure ToolButton6Click(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
    procedure ToolButton3Click(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure ToolButton11Click(Sender: TObject);
    procedure ToolButton12Click(Sender: TObject);
    procedure ToolButton10Click(Sender: TObject);
    procedure ToolButton14Click(Sender: TObject);
    procedure Selectall1Click(Sender: TObject);
    procedure Deselectall1Click(Sender: TObject);
    procedure Invert1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ToolButton9Click(Sender: TObject);
    procedure SpinEdit1Change(Sender: TObject);
    procedure tmr2Timer(Sender: TObject);
    procedure ComboBoxEx1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

Snode = record
  StartDT : TDateTime;
  Code    : Cardinal;
end;

var
  ServiceArr     : array of Snode;
  Form1          : TForm1;
  SpyServiceList : TStringList;
  inProcQuery    : Boolean = False;
  work           : Boolean = True;
  LogFileName    : string = 'ServiceMonitor.log';
  LogFile        : TextFile;
  p              : Byte = 0;
  
implementation

{$R *.dfm}

function RemoteServiceStatus(SrvName, ServiceName : string) : Cardinal;
var
  ServiceManager: TServiceManager;
begin
  Result := 0;
  ServiceManager := TServiceManager.Create();
  try
    if not ServiceManager.Connect(PChar(SrvName)) then
      begin
        Result := NOT_SERVER_CONECT;
        Exit;
      end;
    if not ServiceManager.OpenServiceConnection(PChar(ServiceName)) then
      begin
        Result := NOT_SERVICE_CONECT;
        Exit;
      end;
    Result := ServiceManager.GetStatus;
  finally
    FreeAndNil(ServiceManager);
  end;
end;


function RemoteServiceDisable(SrvName, ServiceName : string) : Cardinal;
var
  ServiceManager: TServiceManager;
begin
  Result := 0;
  ServiceManager := TServiceManager.Create();
  try
    if not ServiceManager.Connect(PChar(SrvName)) then
      begin
        Result := NOT_SERVER_CONECT;
        Exit;
      end;
    if not ServiceManager.OpenServiceConnection(PChar(ServiceName)) then
      begin
        Result := NOT_SERVICE_CONECT;
        Exit;
      end;
    if not ServiceManager.DisableService then
      Result := NOT_SUCCESS_OPERATION;
  finally
    FreeAndNil(ServiceManager);
  end;
end;


function RemoteServiceEnable(SrvName, ServiceName : string) : Cardinal;
var
  ServiceManager: TServiceManager;
begin
  Result := 0;
  ServiceManager := TServiceManager.Create();
  try
    if not ServiceManager.Connect(PChar(SrvName)) then
      begin
        Result := NOT_SERVER_CONECT;
        Exit;
      end;
    if not ServiceManager.OpenServiceConnection(PChar(ServiceName)) then
      begin
        Result := NOT_SERVICE_CONECT;
        Exit;
      end;
    if not ServiceManager.EnableService then
      Result := NOT_SUCCESS_OPERATION;
  finally
    FreeAndNil(ServiceManager);
  end;
end;


function RemoteServiceStart(SrvName, ServiceName : string) : Cardinal;
var
  ServiceManager: TServiceManager;
begin
  Result := 0;
  ServiceManager := TServiceManager.Create();
  try
    if not ServiceManager.Connect(PChar(SrvName)) then
      begin
        Result := NOT_SERVER_CONECT;
        Exit;
      end;
    if not ServiceManager.OpenServiceConnection(PChar(ServiceName)) then
      begin
        Result := NOT_SERVICE_CONECT;
        Exit;
      end;
    if not ServiceManager.StartService() then
      Result := NOT_SUCCESS_OPERATION;
  finally
    FreeAndNil(ServiceManager);
  end;
end;


function RemoteServiceStop(SrvName, ServiceName : string) : Cardinal;
var
  ServiceManager: TServiceManager;
begin
  Result := 0;
  ServiceManager := TServiceManager.Create();
  try
    if not ServiceManager.Connect(PChar(SrvName)) then
      begin
        Result := NOT_SERVER_CONECT;
        Exit;
      end;
    if not ServiceManager.OpenServiceConnection(PChar(ServiceName)) then
      begin
        Result := NOT_SERVICE_CONECT;
        Exit;
      end;
    if not ServiceManager.StopService() then
      Result := NOT_SUCCESS_OPERATION;
  finally
    FreeAndNil(ServiceManager);
  end;
end;


function RemoteServicePause(SrvName, ServiceName : string) : Cardinal;
var
  ServiceManager: TServiceManager;
begin
  Result := 0;
  ServiceManager := TServiceManager.Create();
  try
    if not ServiceManager.Connect(PChar(SrvName)) then
      begin
        Result := NOT_SERVER_CONECT;
        Exit;
      end;
    if not ServiceManager.OpenServiceConnection(PChar(ServiceName)) then
      begin
        Result := NOT_SERVICE_CONECT;
        Exit;
      end;
    if not ServiceManager.PauseService then
      Result := NOT_SUCCESS_OPERATION;
  finally
    FreeAndNil(ServiceManager);
  end;
end;


procedure DecodeDateTimeDif(DateTime1, DateTime2 : TDateTime; var YY, MM, DD, HH, MN, SS, MS : integer);
var
  YY1, YY2, MM1, MM2, DD1, DD2, HH1, HH2, MN1, MN2, SS1, SS2, MS1, MS2 : word;
  DT                                                                   : TDateTime;
begin
  If DateTime1 > DateTime2 then
    begin
      DecodeDateTime(DateTime2, YY1, MM1, DD1, HH1, MN1, SS1, MS1);
      DecodeDateTime(DateTime1, YY2, MM2, DD2, HH2, MN2, SS2, MS2);
      DT := DateTime2;
    end
  else
    begin
      DecodeDateTime(DateTime1, YY1, MM1, DD1, HH1, MN1, SS1, MS1);
      DecodeDateTime(DateTime2, YY2, MM2, DD2, HH2, MN2, SS2, MS2);
      DT := DateTime1;
     end;
  YY := YY2 - YY1;
  MM := MM2 - MM1;
  DD := DD2 - DD1;
  HH := HH2 - HH1;
  MN := MN2 - MN1;
  SS := SS2 - SS1;
  MS := MS2 - MS1;
  If MS < 0 then
    begin
      SS := SS - 1;
      MS := MS + 1000;
    end;
  If SS < 0 then
    begin
      MN := MN - 1;
      SS := SS + 60;
    end;
  If MN < 0 then
    begin
      HH := HH - 1;
      MN := MN + 60;
    end;
  If HH < 0 then
    begin
      DD := DD - 1;
      HH := HH + 24;
    end;
  If DD < 0 then
    begin
      MM := MM - 1;
      DD := DD + DaysInMonth(IncMonth(DT, MM));
    end;
  If MM < 0 then
    begin
      YY := YY - 1;
      MM := MM + 12;
    end;
end;


procedure MDelay(Wnd: HWND = 0);
var
  Msg: TMsg;
begin
  while True do
  begin
    if not PeekMessage(Msg, Wnd, 0, 0, PM_REMOVE) then Break;
    TranslateMessage(Msg);
    DispatchMessage(Msg);
  end;
end;


function GetServerString(Line : string) : String;
var
  p : Integer;
begin
  p := Pos('\', Line);
  Delete(Line, p, Length(Line) - p + 1);
  Result := Line;
end;


function GetServiceString(Line : string) : string;
begin
  Delete(Line, 1, Pos('\', Line));
  Result := Line;
end;


procedure TForm1.FormCreate(Sender: TObject);
var
  item : TListItem;
  i    : Integer;
begin
  AssignFile(LogFile, LogFileName);
  if FileExists(LogFileName) then
    Append(LogFile)
  else
    Rewrite(LogFile);
  SpyServiceList := TStringList.Create;
  Writeln(LogFile, (DateTimeToStr(Date + time) + ' Программа монтторинга запущена, начато наблюдение'));
  SpyServiceList.LoadFromFile('Services.lst');
  SetLength(ServiceArr, SpyServiceList.Count);
  for i := 0 to SpyServiceList.Count - 1 do
    begin
      ServiceArr[i].StartDT := Now;
      item := lv1.Items.Add;
      item.Caption := SpyServiceList[i];
      item.SubItems.Add('..');
    end;
end;


procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  work := False;
  Writeln(LogFile, (DateTimeToStr(Date + time) + ' Окончание мониторинга, вход из программы'));
  SpyServiceList.SaveToFile('Services.lst');
  CloseFile(LogFile);
  SpyServiceList.Free;
  ServiceArr := nil;
end;


function PingHost(position : Integer) : string;
var
  Ping : TPingSend;
begin
  Result := 'Timed out';
  Ping  := TPingSend.Create;
  Ping.Timeout := 1000;
  if Ping.Ping(SpyServiceList[position]) then
    Result := IntToStr(Ping.PingTime) + ' ms.';
  Ping.Free;
end;


procedure GetServicesStatus;
var
  i                          : Integer;
  status                     : Cardinal;
  YY, MM, DD, HH, MN, SS, MS : integer;
begin
 if inProcQuery then Exit;
 inProcQuery := True;
 Form1.pb1.Position := 0;
// MDelay;
 for i := 0 to SpyServiceList.Count - 1 do
   begin
     if (Pos('\', SpyServiceList[i]) <> 0) then
       begin
         Form1.pb1.Position := (i + 1) * Round(100 / (SpyServiceList.Count - 1));
         Form1.lv1.Items[i].Caption := Trim(SpyServiceList[i]);
         status := RemoteServiceStatus(GetServerString(Trim(SpyServiceList[i])), GetServiceString(Trim(SpyServiceList[i])));
          case status of
            SERVICE_RUNNING          : begin   // -- all ok
                                         if (ServiceArr[i].Code <> SERVICE_RUNNING) and (ServiceArr[i].Code <> 0) then
                                           begin
                                             DecodeDateTimeDif(ServiceArr[i].StartDT, Now, YY, MM, DD, HH, MN, SS, MS);
                                             Writeln(LogFile, (DateTimeToStr(Date + time) + '   РАБОТА СЕРВИСА    ' + GetServiceString(SpyServiceList[i]) + '   на сервере : ' + GetServerString(SpyServiceList[i]) + ' ВОССТАНОВЛЕНА спустя '
                                               + IntToStr(YY) + '.' + IntToStr(MM) + '.' + IntToStr(DD) + ' ' + IntToStr(HH) + ':' + IntToStr(MN) + ':' + IntToStr(SS)));
                                           end;
                                         ServiceArr[i].StartDT := Now;
                                         ServiceArr[i].Code := SERVICE_RUNNING;
                                         Form1.lv1.Items[i].SubItems[0] := 'RUNING';
                                       end;
            SERVICE_STOPPED          : begin
                                         if ServiceArr[i].Code <> SERVICE_STOPPED then
                                           begin
                                             ServiceArr[i].Code := SERVICE_STOPPED;
                                             Writeln(LogFile, (DateTimeToStr(Date + time) + '   Зафиксирована остановка сервиса : статус - SERVICE_STOPPED   ' + GetServiceString(SpyServiceList[i]) + '   на сервере : ' + GetServerString(SpyServiceList[i])));
                                           end;
                                         Form1.lv1.Items[i].SubItems[0] := 'STOPED';
                                       end;
            SERVICE_START_PENDING    : begin
                                         if ServiceArr[i].Code <> SERVICE_START_PENDING then
                                           begin
                                             ServiceArr[i].Code := SERVICE_START_PENDING;
                                             Writeln(LogFile, (DateTimeToStr(Date + time) + '   Зафиксирован запуск сервиса : статус - SERVICE_START_PENDING   ' + GetServiceString(SpyServiceList[i]) + '   на сервере : ' + GetServerString(SpyServiceList[i])));
                                           end;
                                         Form1.lv1.Items[i].SubItems[0] := 'STARTING';
                                       end;
            SERVICE_STOP_PENDING     : begin
                                         if ServiceArr[i].Code <> SERVICE_STOP_PENDING then
                                           begin
                                             ServiceArr[i].Code := SERVICE_STOP_PENDING;
                                            Writeln(LogFile, (DateTimeToStr(Date + time) + '   Зафиксирована начало остановки сервиса : статус - SERVICE_STOP_PENDING   ' + GetServiceString(SpyServiceList[i]) + '   на сервере : ' + GetServerString(SpyServiceList[i])));
                                           end;
                                         Form1.lv1.Items[i].SubItems[0] := 'STOPING';
                                       end;
            SERVICE_CONTINUE_PENDING : begin
                                         if ServiceArr[i].Code <> SERVICE_CONTINUE_PENDING then
                                           begin
                                             ServiceArr[i].Code := SERVICE_CONTINUE_PENDING;
                                             Writeln(LogFile, (DateTimeToStr(Date + time) + '   Зафиксирована возобновление сервиса : статус - SERVICE_CONTINUE_PENDING   ' + GetServiceString(SpyServiceList[i]) + '   на сервере : ' + GetServerString(SpyServiceList[i])));
                                           end;
                                         Form1.lv1.Items[i].SubItems[0] := 'RESTORING';
                                       end;
            SERVICE_PAUSE_PENDING    : begin
                                         if ServiceArr[i].Code <> SERVICE_PAUSE_PENDING then
                                           begin
                                             ServiceArr[i].Code := SERVICE_PAUSE_PENDING;
                                             Writeln(LogFile, (DateTimeToStr(Date + time) + '   Зафиксирована возобновление сервиса : статус - SERVICE_PAUSE_PENDING   ' + GetServiceString(SpyServiceList[i]) + '   на сервере : ' + GetServerString(SpyServiceList[i])));
                                           end;
                                         Form1.lv1.Items[i].SubItems[0] := 'PAUSE in process';
                                       end;
            SERVICE_PAUSED           : begin
                                         if ServiceArr[i].Code <> SERVICE_PAUSED then
                                           begin
                                             ServiceArr[i].Code := SERVICE_PAUSED;
                                             Writeln(LogFile, (DateTimeToStr(Date + time) + '   Зафиксирована возобновление сервиса : статус - SERVICE_PAUSED   ' + GetServiceString(SpyServiceList[i]) + '   на сервере : ' + GetServerString(SpyServiceList[i])));
                                           end;
                                         Form1.lv1.Items[i].SubItems[0] := 'PAUSE';
                                       end;
            NOT_SERVER_CONECT        : begin
                                         if ServiceArr[i].Code <> NOT_SERVER_CONECT then
                                           begin
                                             ServiceArr[i].Code := NOT_SERVER_CONECT;
                                             Writeln(LogFile, (DateTimeToStr(Date + time) + '   Сервер недоступен   : ' + GetServerString(SpyServiceList[i])));
                                           end;
                                         Form1.lv1.Items[i].SubItems[0] := 'SERVER UNREACHEBLE';
                                       end;
            NOT_SERVICE_CONECT       : begin
                                         if ServiceArr[i].Code <> NOT_SERVICE_CONECT then
                                           begin
                                             ServiceArr[i].Code := NOT_SERVICE_CONECT;
                                             Writeln(LogFile, (DateTimeToStr(Date + time) + '   Недоступен сервис   ' + GetServiceString(SpyServiceList[i]) + '   на сервере : ' + GetServerString(SpyServiceList[i])));
                                           end;
                                         Form1.lv1.Items[i].SubItems[0] := 'SERVICE NOT ACCESS';
                                       end;
          end;
          Flush(LogFile);
        end;
    end;
  inProcQuery := False;
  form1.lv1.Repaint;
  Form1.pb1.Position := 0;
end;


procedure TForm1.tmr1Timer(Sender: TObject);
begin
  Inc(p);
  if p > 3 then p := 0;
  Label1.Caption := myProgress[p];
  if not work then Exit;
  GetServicesStatus;
end;


procedure TForm1.lv1CustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  if Item.Index mod 2 <> 0 then
    lv1.Canvas.Brush.Color := clWindow
  else
    lv1.Canvas.Brush.Color := cl3DLight;
  if (Item.SubItems[0] = 'STOPED') or (Item.SubItems[0] = 'STOPING') then lv1.Canvas.Brush.Color := clRed;
  if (Item.SubItems[0] = 'Timed out') then lv1.Canvas.Brush.Color := clPurple;
  if (Item.SubItems[0] = 'STARTING') then lv1.Canvas.Brush.Color := clGreen;
  if (Item.SubItems[0] = 'SERVER UNREACHEBLE') or (Item.SubItems[0] = 'SERVICE NOT ACCESS') then lv1.Canvas.Brush.Color := clLime;
  if (Pos('SEND SUCCESS', Item.SubItems[0]) <> 0) then lv1.Canvas.Brush.Color := clAqua;
  if (Pos('SEND FAULT', Item.SubItems[0]) <> 0) then lv1.Canvas.Brush.Color := clFuchsia;
end;


procedure TForm1.btn2Click(Sender: TObject);
begin
  pnl3.Visible := False;
end;


procedure TForm1.pnl1Click(Sender: TObject);
begin
  pnl3.Top := Form1.Height div 2 - pnl3.Height div 2;
  pnl3.Left := Form1.Width div 2 - pnl3.Width div 2;
  pnl3.Visible := True;
end;


procedure TForm1.ToolButton5Click(Sender: TObject);
var
  i : Integer;
begin
  for i := 0 to lv1.Items.Count - 1 do
    if lv1.Items[i].Checked then
      begin
        if Pos('\', lv1.Items[i].Caption) = 0 then continue;
        Writeln(LogFile, (DateTimeToStr(Date + time) + '   Принудительная установка сервиса   ' + GetServiceString(lv1.Items[i].Caption) + '   в DISABLE на сервере : ' + GetServerString(lv1.Items[i].Caption)));
        RemoteServiceDisable(GetServerString(lv1.Items[i].Caption), GetServiceString(lv1.Items[i].Caption));
      end;
end;


procedure TForm1.ToolButton6Click(Sender: TObject);
var
  i : Integer;
begin
  for i := 0 to lv1.Items.Count - 1 do
    if lv1.Items[i].Checked then
      begin
        if Pos('\', lv1.Items[i].Caption) = 0 then continue;
        Writeln(LogFile, (DateTimeToStr(Date + time) + '   Принудительная установка сервиса   ' + GetServiceString(lv1.Items[i].Caption) + '   в AUTOMATIC на сервере : ' + GetServerString(lv1.Items[i].Caption)));
        RemoteServiceEnable(GetServerString(lv1.Items[i].Caption), GetServiceString(lv1.Items[i].Caption));
      end;
end;


procedure TForm1.ToolButton1Click(Sender: TObject);
var
  i : Integer;
begin
  for i := 0 to lv1.Items.Count - 1 do
    if lv1.Items[i].Checked then
      begin
        if Pos('\', lv1.Items[i].Caption) = 0 then continue;
        Writeln(LogFile, (DateTimeToStr(Date + time) + '   Принудительный запуск сервиса   ' + GetServiceString(lv1.Items[i].Caption) + '   на сервере : ' + GetServerString(lv1.Items[i].Caption)));
        if RemoteServiceStart(GetServerString(lv1.Items[i].Caption), GetServiceString(lv1.Items[i].Caption)) = 0 then
          lv1.Items[i].SubItems[0] := 'SEND SUCCESS START'
        else
          lv1.Items[i].SubItems[0] := 'SEND FAULT START';
      end;
end;


procedure TForm1.ToolButton2Click(Sender: TObject);
var
  i : Integer;
begin
  for i := 0 to lv1.Items.Count - 1 do
    if lv1.Items[i].Checked then
      begin
        if Pos('\', lv1.Items[i].Caption) = 0 then continue;
        Writeln(LogFile, (DateTimeToStr(Date + time) + '   Принудительная остановка сервиса   ' + GetServiceString(lv1.Items[i].Caption) + '   на сервере : ' + GetServerString(lv1.Items[i].Caption)));
        if RemoteServiceStop(GetServerString(lv1.Items[i].Caption), GetServiceString(lv1.Items[i].Caption)) = 0 then
          lv1.Items[i].SubItems[0] := 'SEND SUCCESS STOP'
        else
          lv1.Items[i].SubItems[0] := 'SEND FAULT STOP';
      end;
end;


procedure TForm1.ToolButton3Click(Sender: TObject);
var
  i : Integer;
begin
  for i := 0 to lv1.Items.Count - 1 do
    if lv1.Items[i].Checked then
      begin
        if Pos('\', lv1.Items[i].Caption) = 0 then continue;
        Writeln(LogFile, (DateTimeToStr(Date + time) + '   Принудительная пауза сервиса   ' + GetServiceString(lv1.Items[i].Caption) + '   на сервере : ' + GetServerString(lv1.Items[i].Caption)));
        if RemoteServicePause(GetServerString(lv1.Items[i].Caption), GetServiceString(lv1.Items[i].Caption)) = 0 then
          lv1.Items[i].SubItems[0] := 'SEND SUCCESS PAUSE'
        else
          lv1.Items[i].SubItems[0] := 'SEND FAULT PAUSE';
      end;
end;


procedure TForm1.btn1Click(Sender: TObject);
var
  item : TListItem;
begin
  SpyServiceList.Add(edt1.Text);
  item := lv1.Items.Add;
  item.Caption := edt1.Text;
  item.SubItems.Add('..');
  SetLength(ServiceArr, SpyServiceList.Count);
  pnl3.Visible := false;
end;


procedure TForm1.ToolButton11Click(Sender: TObject);
begin
  pnl3.Visible := True;
end;


procedure TForm1.ToolButton12Click(Sender: TObject);
var
  i : Integer;
begin
  for i := 0 to lv1.Items.Count - 1 do
    if lv1.Items[i].Checked then
      begin
        lv1.Items.Delete(i);
        SpyServiceList.Delete(i);
      end;
end;


procedure TForm1.ToolButton10Click(Sender: TObject);
begin
  MessageDlg('Service monitor 1.0.1   Lotsmanov R.A. 2012', mtInformation, [mbOk], 0);
end;


procedure TForm1.ToolButton14Click(Sender: TObject);
begin
  if ToolButton14.ImageIndex = 10 then
    begin
      ToolButton14.imageIndex := 9;
      work := False;
      Writeln(LogFile, (DateTimeToStr(Date + time) + ' Остановка мониторинга'));
      Exit;
    end;
  if ToolButton14.ImageIndex = 9 then
    begin
      ToolButton14.imageIndex := 10;
      work := True;
      Writeln(LogFile, (DateTimeToStr(Date + time) + ' Восстановление мониторинга'));
    end;
end;


procedure TForm1.Selectall1Click(Sender: TObject);
var
  i : Integer;
begin
  for i := 0 to lv1.Items.Count - 1 do
    lv1.Items[i].Checked := True;
end;


procedure TForm1.Deselectall1Click(Sender: TObject);
var
  i : Integer;
begin
  for i := 0 to lv1.Items.Count - 1 do
    lv1.Items[i].Checked := False;
end;


procedure TForm1.Invert1Click(Sender: TObject);
var
  i : Integer;
begin
  for i := 0 to lv1.Items.Count - 1 do
    lv1.Items[i].Checked := not lv1.Items[i].Checked;
end;


procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := (not work) or (not inProcQuery);
end;


procedure TForm1.ToolButton9Click(Sender: TObject);
var
  i : Integer;
begin
  ComboBoxEx1.Items.Add(ComboBoxEx1.Text);
  for i := 0 to lv1.Items.Count - 1 do
    if Pos(UpperCase(ComboBoxEx1.Text), UpperCase(lv1.Items[i].Caption)) > 0 then
      lv1.Items[i].Checked := true;
end;


procedure TForm1.SpinEdit1Change(Sender: TObject);
begin
  tmr1.Interval := SpinEdit1.Value * 1000;
  Writeln(LogFile, (DateTimeToStr(Date + time) + ' Изменение времени опроса на ' + IntToStr(SpinEdit1.Value) + ' c.'));
end;


procedure TForm1.tmr2Timer(Sender: TObject);
var
  i : Integer;
  s : string;
  YY, MM, DD, HH, MN, SS, MS : Integer;
begin
  for i := 0 to SpyServiceList.Count - 1 do
    if (Pos('\', SpyServiceList[i]) = 0) then
      begin
        s := PingHost(i);
        if s = 'Timed out' then
          begin
            if ServiceArr[i].Code <> 1 then
              begin
                ServiceArr[i].StartDT := Now;
                Writeln(LogFile, (DateTimeToStr(Date + time) + '   Узел ' + SpyServiceList[i] + ' недоступен'));
              end;
            ServiceArr[i].Code := 1;
          end
        else
          begin
            if ServiceArr[i].Code <> 0 then
              begin
                DecodeDateTimeDif(ServiceArr[i].StartDT, Now, YY, MM, DD, HH, MN, SS, MS);
                Writeln(LogFile, (DateTimeToStr(Date + time) + '   Узел ' + SpyServiceList[i] + ' вновь доступен спустя '
                  + IntToStr(YY) + '.' + IntToStr(MM) + '.' + IntToStr(DD) + ' ' + IntToStr(HH) + ':' + IntToStr(MN) + ':' + IntToStr(SS) + '.' + IntToStr(MS)));
              end;
            ServiceArr[i].Code := 0;
          end;
        Form1.lv1.Items[i].SubItems[0] := s;
      end;
  form1.lv1.Repaint;
end;

procedure TForm1.ComboBoxEx1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  i : Integer;
begin
  if Key <> VK_RETURN then Exit;
  ComboBoxEx1.Items.Add(ComboBoxEx1.Text);
  for i := 0 to lv1.Items.Count - 1 do
    if Pos(UpperCase(ComboBoxEx1.Text), UpperCase(lv1.Items[i].Caption)) > 0 then
      lv1.Items[i].Checked := true;
end;

end.
