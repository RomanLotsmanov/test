unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, WinSpool,
  Grids, ExtCtrls, Menus, ImgList, IniFiles, StdCtrls, FileCtrl, printers, pingModule,
  icmp, winSock, Mask, ComCtrls, ToolWin, AppEvnts, unit2, unit3;

type
  TForm1 = class(TForm)
    ImageList1: TImageList;
    ImageList2: TImageList;
    Memo1: TMemo;
    ApplicationEvents1: TApplicationEvents;
    ListView1: TListView;
    GroupBox1: TGroupBox;
    Button1: TButton;
    Label2: TLabel;
    Image1: TImage;
    Label3: TLabel;
    ToolBar1: TToolBar;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    ToolButton12: TToolButton;
    ToolButton13: TToolButton;
    ToolButton14: TToolButton;
    ToolButton15: TToolButton;
    Label1: TLabel;
    ToolButton16: TToolButton;
    Edit1: TEdit;
    ToolButton17: TToolButton;
    ToolButton18: TToolButton;
    ToolButton1: TToolButton;
    StatusBar1: TStatusBar;
    ProgressBar1: TProgressBar;
    PopupMenu1: TPopupMenu;
    zzz1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure RzToolButton4Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure RzToolButton1Click(Sender: TObject);
    procedure RzToolButton2Click(Sender: TObject);
    procedure RzButton1Click(Sender: TObject);
    procedure RzToolButton5Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure RzToolButton3Click(Sender: TObject);
    procedure RzToolButton9Click(Sender: TObject);
    procedure RzToolButton7Click(Sender: TObject);
    procedure RzToolButton8Click(Sender: TObject);
    procedure RzToolButton10Click(Sender: TObject);
    procedure RzToolButton11Click(Sender: TObject);
    procedure RzToolButton12Click(Sender: TObject);
    procedure RzToolButton6Click(Sender: TObject);
    procedure ApplicationEvents1Exception(Sender: TObject; E: Exception);
    procedure ListView1CustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
  private
    { Private declarations }
  public
    t1 : TPrnReq;
    { Public declarations }
  end;

const
// ��������� ���������
  Hour   = 3600000 / MSecsPerDay;
  Minute =   60000 / MSecsPerDay;
  Second =    1000 / MSecsPerDay;

  r3_sep  = '/';

  maxS    = 11;        // ������������ ������ ��������
  iniName = 'asm.ini'; // �������� ����� ��������
//----- ��������� ----
  tempDir     : string  = 'tmp\';           // ��������� �������
  BackUpDir   : string  = 'BackUp\';
  tempFile              = 'PrnJob.pjt';     // ��� ���������� �����
  hostsIndex            = 'Hosts.idx';      // ���� ������ ����
  printersIndex         = 'Printers.idx';   // ������� ������ ����
  usersIndex            = 'users.idx';      // ���� ������ �������������
  LogFile               = 'asm.log';        // ��� ����� �������
  DayEndTime  : TTime   = 23/59/00;        // ����� �������� ������� ���� (������ ����)
  sysJob      : array [1..4] of string = ('�������','�������','SYSTEM','system');
  maxLogLines           = 500;
  WTime       : integer = 2;
  ATime       : integer = 7;

var
  Form1          : TForm1;
  WorkDir        : string;       // ������� �������

  OptionsF       : TIniFile;     // ���� ��������
  crStop         : boolean;
  zz             : integer;
  wk             : byte;

procedure initialization_ASM;
procedure AddLogStr(s:string);
procedure MPrnReq;

implementation

{$R *.DFM}

type
  JOB_INFO_1_ARRAY = array of JOB_INFO_1;

TPrnJobBaseRec = record
  id         : char;        // 1 - S
  prnIndex   : integer;
  Doc        : string[255]; // 256
  HostIndex  : integer;     // 4
  userIndex  : integer;     // 4
  Pages      : integer;     // 4
  DateTime   : TDateTime;   // 8        total 277 bytes
  SpoolWork  : TDateTime;     // ������� ���������� (�������)
  DocType    : string[3];
end;

TPrintRec = record
  printName  : string;           // ��� ��������
  block      : boolean;
  TotalPages : Integer;
  status     : string[5];
  index      : integer;
  predJob    : JOB_INFO_1_ARRAY;        // ���������� �������
  curJob     : JOB_INFO_1_ARRAY;        // ���������� �������
end;

TFPrintRec = record
  printName  : string[127];           // ��� ��������
  status     : string[5];
  index      : integer;
end;

PPrintRec = ^TPrintRec;

var
  StartTime      : TDateTime;          // ����� ������ ���������
  req            : boolean;            // ������� ���������� �������� �������
  usersList      : TStringList;        // �������������� ������ �������������
  hostsList      : TStringList;        // �������������� ������ ������
  LogList        : TStringList;        // ������ �������
  printersList   : TFileStream;

  sysPRN         : TPrinter;           // �������� ��������� � ������� OS

  aList          : TList;
  aPrintRec      : PPrintRec;

  FPRN_rec       : TPrnJobBaseRec;     // ��� ������ ��
  tFile, bFile   : TFileStream;        // ��� ����� ��

  TSI, cp        : TListItem;

  ActiveBaseDay  : TDate;

  maxPIndex      : integer;

/// ----------- net

function IPAddrToName(IPAddr : string): string;
var
  SockAddrIn : TSockAddrIn;
  HostEnt    : PHostEnt;
  WSAData    : TWSAData;
begin
  WSAStartup($101, WSAData);
  SockAddrIn.sin_addr.s_addr := inet_addr(PChar(IPAddr));
  HostEnt := gethostbyaddr(@SockAddrIn.sin_addr.S_addr, 4, AF_INET);
  if HostEnt <> nil then
    result := StrPas(Hostent^.h_name)
  else
    result:='';
end;

function HostToIP(name: string; var Ip: string): Boolean;
var
  wsdata   : TWSAData;
  hostName : array [0..255] of char;
  hostEnt  : PHostEnt;
  addr     : PChar;
begin
  WSAStartup($0101, wsdata);
  try
    gethostname(hostName, sizeof (hostName));
    StrPCopy(hostName, name);
    hostEnt := gethostbyname(hostName);
    if Assigned(hostEnt) then
      if Assigned(hostEnt^.h_addr_list) then begin
        addr := hostEnt^.h_addr_list^;
        if Assigned(addr) then begin
          IP := Format('%d.%d.%d.%d', [byte (addr [0]),
           byte (addr [1]), byte (addr [2]), byte (addr [3])]);
          Result := True;
        end
        else
          Result := False;
      end
      else
        Result := False
    else begin
      Result := False;
    end;
  finally
    WSACleanup;
  end
end;

function ExtractHostName(NetName : string): string;
var
  s : string;
begin
  s := NetName;
  Delete(s, 1, 2);
  if pos('\', s) <> -1 then
    Delete(s, pos('\', s), length(s) - pos('\', s) + 1);
  Result := s;
end;

function ThisIsNetPrinter(netPrn : string): boolean;
begin
  result := (netPrn[1] = '\') and (netPrn[2] = '\');
end;

function ThisIsIPAddr(IP : string): boolean;
var
  i : integer;
begin
  result := false;
  for i := 1 to length(IP) do
    if not (IP[i] in ['0'..'9', '.']) then
      exit;
  result := true;
end;

function PrinterHostConnect(netPrn:string): boolean;   // no use, experemental !!!
var
  nw  : TNetResource;
  Err : DWORD;
begin
  result := false;
  nw.dwType := RESOURCETYPE_PRINT;
  nw.lpLocalName := nil;
  nw.lpRemoteName := PChar(netPrn);
  nw.lpProvider := nil;
  Err := WNetAddConnection2(nw, nil, nil, 0);
  if Err = NO_ERROR then
    result := true;
end;

// -----

function SysJobWork(user : string): boolean;
var
  i : Integer;
begin
  result := false;
  for i := 1 to Length(SysJob) do
    if SysJob[i] = user then
      begin
        result := true;
        break;
      end;
end;

function R3_doc(doc : string): boolean;
begin
  result := false;
  if Pos('TVP', doc) <> -1 then result := true;
end;

function DocHaveExt(Ext, doc : string) : boolean;
begin
  result := pos(Ext, AnsiUpperCase(doc)) = length(doc) - 3;
end;

function GetR3User(doc : string): string;
begin
  Delete(doc,pos(r3_sep, doc), Length(doc) - (pos(r3_sep, doc) - 1));
  result := doc;
end;

function GetR3Doc(doc : string): string;
begin
  Delete(doc, 1, pos(r3_sep, doc));
  result := doc;
end;


//--- ���������� ������ � ���. �����
procedure AddLogStr(s:string);
begin
  if LogList.Count > maxLogLines then
    begin
      LogList.Clear;
      form1.Memo1.Clear;
    end;
  form1.memo1.Lines.Add(DateToStr(now) + ' ' + TimeToStr(Time) + '   ' + s);
  LogList.Add(DateToStr(now) + ' ' + TimeToStr(Time) + '   ' + s);
end;

//--- ��������� ����������� ��������

procedure BlockControl(mode : boolean);
begin
  form1.ToolButton1.Enabled  := not mode;
  form1.ToolButton2.Enabled  := not mode;
  form1.ToolButton12.Enabled := not mode;
  form1.ToolButton11.Enabled := not mode;
  form1.ToolButton10.Enabled := not mode;
  form1.ToolButton8.Enabled  := not mode;
  form1.ToolButton7.Enabled  := not mode;
end;

procedure CriticalStop;
begin
  AddLogStr('*** ����������� ������ ***');
  crStop := true;
end;

//--- �������� ��������� � ������ �������
procedure MainStMess(s : string);
begin
  Form1.StatusBar1.Panels[0].Text := s;
  Form1.StatusBar1.Update;
end;

//--- ��������������� ��������� � ������ �������
procedure ChildStMess(s : string);
begin
  Form1.StatusBar1.Panels[2].Text := s;
  Form1.StatusBar1.UpDate;
end;

procedure STWorking;
const
  work : array [1..4] of char = (('-'),('/'),('|'),('\'));
begin
  Form1.StatusBar1.Panels[1].Text := work[wk];
  inc(wk);
  if wk > 4 then wk := 1;
end;

//--- �������������� �������� ���. ������
procedure ViewLogPanel(v : boolean);
begin
  Form1.ListView1.Visible :=  not v;
  Form1.Memo1.Visible := v;
end;

procedure StoreIndex(backUp : boolean);
var
  _dir    : string;
  i       : integer;
  cPRN    : TPrintRec;
  cPRN_   : TFPrintRec;
begin
  if backUp then
    begin
      _dir := BackUpDir;
      AddLogStr('������ ������� �������� ');
    end
  else
    begin
      _dir := WorkDir;
      AddLogStr('������ �������� ');
    end;
  AddLogStr('������ ������� ������ ' + _dir + hostsIndex);
  hostsList.SaveToFile(_dir + hostsIndex);
  AddLogStr('������ ������� ������������� ' + _dir + usersIndex);
  usersList.SaveToFile(_dir + usersIndex);
    //--- ���������� ������� �������
  try
    AddLogStr('������ ������� ��������� ' + _dir + printersIndex);
    printersList := TFileStream.Create(_dir + printersIndex, fmCreate);
    for i := 0 to aList.Count - 1 do
      begin
        cPRN := PPrintRec(aList.Items[i])^;
        FillChar(cPRN_.printName, SizeOf(cPRN_.printName), Ord(' '));
        cPRN_.printName := AnsiUpperCase(cPRN.printName);
        cPRN_.index := cPRN.index;
        cPRN_.status := cPRN.status;
        printersList.Write(cPRN_, SizeOf(cPRN_));
      end;
  finally
    printersList.Free;
  end;
end;


// ������ ����������� ����� ������
procedure StoreDayDataFile(backUp : boolean; ADate : TDate);
var
  i, cr, j : Integer;
  buf      : TPrnJobBaseRec;
begin
  form1.ProgressBar1.Position := 0;
  form1.ProgressBar1.Visible := true;
  MainStMess('���������� ����');
  ChildStMess(DateToStr(ADate) + '.dat');
  j := 0; cr := 0;
  try
    tFile.Seek(0, soFromBeginning);  // ��������� � ������ temp �����
    if not BackUp then
      begin
        bFile := TFileStream.Create(WorkDir + dateToStr(ADate) + '.dat', fmCreate); // ������� ���� ������
        AddLogStr('������ ������ ' + WorkDir + DateToStr(ADate) + '.dat');
      end
    else
      begin
        bFile := TFileStream.Create(backUpDir + dateToStr(ADate) + '.bak', fmCreate); // ������� ���� ������
        AddLogStr('������ ��������� ����� ������ ' + WorkDir + DateToStr(ADate) + '.bak');
      end;
    cr := Round(tFile.Size / SizeOf(FPRN_Rec));
    for i := 1 to cr do
      begin                                     // �������� �� tempa � ������
        tFile.Read(buf, SizeOf(buf));
        bFile.Write(buf, SizeOf(buf));
        form1.ProgressBar1.Position :=  round(i * (100 / cr));
        j := i;
      end;
  finally
    form1.ProgressBar1.Visible := false;
    if j < cr then AddLogStr('�������� �� ��� ������! ' + IntToStr(round(j * (100 / cr))) + '% ' + IntToStr(j) + ' �� ' + IntToStr(cr));
    bFile.Free;
  end;                                 // ��������� ������   
end;

//--- ��������� ���������� � �������� ��������
function GetSpoolerJobs(cPRN : TPrintRec): TPrintRec;
Const
  Defaults      : TPrinterDefaults = ( pDatatype : nil; pDevMode  : nil;
  DesiredAccess : PRINTER_ACCESS_USE or PRINTER_ACCESS_ADMINISTER );

type
  TJobs = array [0..1000] of JOB_INFO_1;
  PJobs = ^TJobs;

var
  bResult              : Boolean;
  hPrinter             : THandle;
  bytesNeeded, numJobs : Cardinal;
  pJ                   : PJobs;
  i                    : integer;

  Reply                : TsmICMP_Echo_Reply;
  c                    : string;


begin
  result := cPRN;
  SetLength(Result.curJob, 0);
  result.block := true;
  if ThisIsNetPrinter(cPRN.printName) then
    begin
      MainStMess('������� ���������� ����� � ������� ���������');
      ChildStMess(cPRN.printName);
      if not HostToIP(ExtractHostName(cPRN.printName),c) then
        exit;
      Ping(PChar(c),nil,Reply,500);

      if Reply.Status <> IP_SUCCESS then
        exit;
    end;

  bResult := OpenPrinter(PChar(cPRN.printName), hPrinter, @Defaults);  // ���������� �������� �� ����������� ����� !!!
  if not bResult then                                          // ������� ������ � ������������� SYS ����������
  begin
    ClosePrinter(hPrinter);
    MainStMess('������ �������� ���������� ������');
    ChildStMess(cPRN.printName);
    exit;
  end;
  EnumJobs(hPrinter, 0, 1000, 1, nil, 0, bytesNeeded, numJobs);
  pJ := AllocMem(bytesNeeded);
  bResult := EnumJobs(hPrinter, 0, 1000, 1, pJ, bytesNeeded, bytesNeeded, numJobs);
  if not bResult then
  begin
    ClosePrinter(hPrinter);
    MainStMess('������ ��������� ���������� � ���������� ������');
    ChildStMess(cPRN.printName);
    exit;
  end;
  ClosePrinter(hPrinter);

  MainStMess('��������� ���������� � ���������� ������');
  ChildStMess(cPRN.printName);
  for i := 0 to Pred(numJobs) do
  begin
    if Pj[i].pDocument <> nil then
    begin
      SetLength(Result.curJob, Length(Result.curJob) + 1);
      Result.curJob[Length(Result.curJob) - 1] := Pj[i];
    end;
  end;
  result.block := false;
end;

//--- ����� ��������� (�������� ������� ���������)
procedure MPrnReq;
var
  i, j, k   : Integer;           // ���������� ������
  st        : string;            // ���������� ��� ��������� ������� ��������
  no_z      : boolean;
  r3_Job    : boolean;
  sys_Job   : boolean;
  cPRN      : TPrintRec;
  userIndex : Integer;
  hostIndex : Integer;
  _pDocument, _pUserName : string;

begin
  if req then exit;  // ���� ���������� ������ �� �������� �� ��������� �� ����� ��������
  req := true;       // ������ �������
// ��������� �������� ������ �������� ������� ������ �������� � ���������

  if ((DayEndTime < Time) and (ActiveBaseDay = Date)) then  // ����� ��������� ���������� �����
    begin
      AddLogStr('�������������� �������� ������� ������ ' + DateTimeToStr(ActiveBaseDay));
      StoreDayDataFile(false, ActiveBaseDay);         // ������ ���������� ����
      StoreDayDataFile(true, ActiveBaseDay);          // BackUp ���������� ����
      tFile.Free;                                 // ��������� Temp
      tFile:=TFileStream.Create(tempDir + tempFile, fmCreate);   // ����������� temp
      StoreIndex(false);        // ������ �������
      StoreIndex(true);         // ������ backUp �������
      AddLogStr('-- ����� ����������� �������� � ������� ������ ' + IntToStr(zz));
      for j := 0 to aList.Count - 1 do  // ��������� ����������� �������� ���������
         PPrintRec(aList.Items[j])^.TotalPages := 0;
      ActiveBaseDay := ActiveBaseDay + 24 * hour;  // ������� ��������� ����
      AddLogStr('����� ������ ������������ ' + DateTimeToStr(ActiveBaseDay));
      zz := 0;       // ���������� �������� ��������� ��������
    end;

  form1.listview1.Items.BeginUpdate;  // ��������� ������
  form1.ListView1.Items.Clear;        // ������� ������ �� ���������

  for j := 0 to aList.Count - 1 do    // ������� �� ���� ���������
    begin
     cPRN := PPrintRec(aList.Items[j])^;  // ������� �������
     if cPRn.status = 'ERASE' then continue;
     if cPRN.status = 'PAUSE' then
       begin
         TSI := form1.ListView1.Items.Add;         // ----------
         TSI.Caption := cPRN.printName;
         TSI.SubItems.Add('');
         TSI.SubItems.Add('');
         TSI.SubItems.Add(IntToStr(cPRN.TotalPages));
         TSI.ImageIndex := 22;
         continue;
       end;
     if cPRN.status = 'STOP' then
       begin
         TSI := form1.ListView1.Items.Add;         // ----------
         TSI.Caption := cPRN.printName;
         TSI.SubItems.Add('');
         TSI.SubItems.Add('');
         TSI.SubItems.Add('STOP');
         TSI.ImageIndex := 23;
         continue;
       end;

     cPRN := GetSpoolerJobs(cPRN);        // ��������� ������� ������ ��� �������� ��������

   // ��������� ������� ������� � ����������

     for i := 0 to Length(cPRN.predJob) - 1 do
       begin
         no_z := true;
         for k := 0 to Length(cPRN.curJob) - 1 do
           if (cPRN.predJob[i].JobId = cPRN.curJob[k].JobId) then no_z :=false;
           if no_z then
             begin   // ����������� ������������ ��������� �������
           // ���������� ��� ��������
               _pDocument := cPRN.predJob[i].pDocument;
               _pUserName := cPRN.predJob[i].pUserName;

               FPRN_Rec.DocType := '---';
               if SysJobWork(_pUserName) then  // ���� ��������� ������� �� ��� SYS
                 begin
                   FPRN_Rec.DocType := 'SYS';
                   if R3_doc(_pDocument) then   // ���� R3 ��������
                     begin
                       FPRN_Rec.DocType := 'R/3';
                       _pUserName := GetR3User(_pDocument); // ��� ������������ ��� R/3
                       _pDocument := GetR3Doc(_pDocument);  // ������� ��� ���������� ��� R/3
                     end
                 end
               else
                 begin
                   if DocHaveExt('.DOC',_pDocument) then
                     FPRN_Rec.DocType := 'DOC';
                   if DocHaveExt('.XLS',_pDocument) then
                     FPRN_Rec.DocType := 'XLS';
                 end;
               userIndex :=  usersList.IndexOf(AnsiUpperCase(_pUserName));  // �������������� ������ �������������
               if userIndex = -1 then
                 userIndex := usersList.Add(AnsiUpperCase(_pUserName));
      { TODO 2 -ofleXX -cnet : Debug IP to host - ��� ������ � ���� ���� }
               if ThisIsIPAddr(ExtractHostName(cPRN.predJob[i].pMachineName)) then   // �������������� IP � ���
                 cPRN.predJob[i].pMachineName:=PChar(IPAddrToName(cPRN.predJob[i].pMachineName));
               hostIndex :=  hostsList.IndexOf(AnsiUpperCase(ExtractHostName(cPRN.predJob[i].pMachineName))); // �������������� ������ ������
               if hostIndex = -1 then
                 hostIndex := hostsList.Add(AnsiUpperCase(ExtractHostName(cPRN.predJob[i].pMachineName)));
     // ���������� ����9� ����� ������� �������� ��������� ������ � ��
               FillChar(FPRN_Rec.Doc, SizeOf(FPRN_Rec.Doc), Ord(' '));
               FPRN_Rec.id := 'N';
               FPRN_Rec.Doc := _pDocument;
               FPRN_Rec.prnIndex := j;
               FPRN_Rec.HostIndex := hostIndex;
               FPRN_Rec.userIndex := userIndex;
     // MS ����� ���� !!!
               FPRN_Rec.Pages := cPRN.predJob[i].TotalPages;
               if (cPRN.predJob[i].TotalPages < cPRN.predJob[i].PagesPrinted) then
                 FPRN_Rec.Pages := cPRN.predJob[i].PagesPrinted;
               if (cPRN.predJob[i].TotalPages = 0) and (cPRN.predJob[i].PagesPrinted > 0) then
                 FPRN_Rec.Pages := cPRN.predJob[i].PagesPrinted;
     // --------------------------------------------------------------------------------------
               FPRN_Rec.DateTime := SystemTimeToDateTime(cPRN.predJob[i].Submitted)+4*hour;
               FPRN_Rec.SpoolWork := now - FPRN_Rec.DateTime;


               tFile.Write(FPRN_Rec,SizeOf(FPRN_Rec));

               cPRN.TotalPages := cPRN.TotalPages + FPRN_Rec.Pages;

             {  AddLogStr(FloatToStr(cPRN.predJob[i].TotalPages) + ' ' + FloatToStr(cPRN.predJob[i].PagesPrinted) +
                 ' ' + FPRN_Rec.Doc + ' ' + hostsList.Strings[hostIndex] + ' ' +
                 usersList.Strings[userIndex]);}
             end;
       end;

// kos9k � ����������� ��� �� ������� ----
     for k := 0 to Length(cPRN.curJob) - 1 do
       for i := 0 to Length(cPRN.predJob) - 1 do
         if (cPRN.predJob[i].JobId = cPRN.curJob[k].JobId) then
           if (cPRN.predJob[i].TotalPages < cPRN.curJob[k].TotalPages) then
             cPRN.predJob[i].TotalPages := cPRN.curJob[k].TotalPages
           else
             cPRN.curJob[k].TotalPages := cPRN.predJob[i].TotalPages;
// ---------------------------------------

     cPRN.predJob := cPRN.curJob; // !!!

     PPrintRec(aList.Items[j])^ := cPRN;

     TSI := form1.ListView1.Items.Add;         // ----------

     TSI.Caption := cPRN.printName;
     TSI.SubItems.Add('');
     TSI.SubItems.Add('');
     TSI.SubItems.Add(IntToStr(cPRN.TotalPages));


     if cPRN.block then     // ���� ������� �������� �� ������ �� �����������
       TSI.ImageIndex := 13
     else
       if ThisIsNetPrinter(cPRN.printName) then  // ���� ������� ������� �� ������ �������� ��������
         TSI.ImageIndex := 12
       else
         TSI.ImageIndex := 21;
     for i := 0 to Length(cPRN.curJob) - 1 do
        begin
          r3_Job := false;
          sys_Job := false;
          if SysJobWork(cPRN.curJob[i].pUserName) then
            begin
              sys_Job := true;
              if R3_doc(cPRN.curJob[i].pDocument) then r3_Job := true;
            end;

          cp := form1.ListView1.Items.Add;

          if r3_Job then
              cp.Caption := '   ' + GetR3Doc(cPRN.curJob[i].pDocument)
            else
              cp.Caption := '   ' + cPRN.curJob[i].pDocument;

          if sys_Job then
              if R3_doc(cPRN.curJob[i].pDocument) then
                cp.ImageIndex := 17
              else
                cp.ImageIndex := 15
          else
            cp.ImageIndex := 14;
      // ����������� ���� �������� ����������� ��������� � ���������� �� ����������
          if DocHaveExt('.DOC',cPRN.curJob[i].pDocument) then cp.ImageIndex := 18;
          if DocHaveExt('.XLS',cPRN.curJob[i].pDocument) then cp.ImageIndex := 19;

      // �������� �� "��������� �����" - WTime �������� � �������
    {      if (SystemTimeToDateTime(cPRN.curJob[i].Submitted) + 4 * hour) + WTime * minute < now then
            begin
     
            end;
   {   // �������� �� "������� �����" - ATime �������� � �������
          if (SystemTimeToDateTime(cPRN.curJob[i].Submitted) + 4 * hour) + ATime * minute < now then
            begin
              cp.ParentColors:=false;
              cp.Color := clRed;
            end;         }

          cp.SubItems.Add(cPRN.curJob[i].pMachineName);            // ��������� ��� ������ � �������
          if r3_Job then                                              // ��������� ������������ � ����������� �� R/3
            cp.SubItems.Add(GetR3User(cPRN.curJob[i].pDocument))
          else
            cp.SubItems.Add(cPRN.curJob[i].pUserName);
          cp.SubItems.Add(FloatToStr(cPRN.curJob[i].TotalPages));  // ��������� ���������� �������
          case cPRN.curJob[i].Status of
            JOB_STATUS_PAUSED            : St := '������ ��������������';
            JOB_STATUS_ERROR             : St := '������';
            JOB_STATUS_DELETING          : St := '��������';
            JOB_STATUS_SPOOLING          : St := '����������';
            JOB_STATUS_PRINTING          : St := '������';
            JOB_STATUS_OFFLINE           : St := 'OFFLINE';
            JOB_STATUS_PAPEROUT          : St := '��� ������';
            JOB_STATUS_PRINTED           : St := '����������';
            JOB_STATUS_DELETED           : St := '�������';
            JOB_STATUS_BLOCKED_DEVQ      : St := '����������� �����������';
            JOB_STATUS_USER_INTERVENTION : St := '������������� ������������';
            JOB_STATUS_RESTART           : St := '����������';
            JOB_POSITION_UNSPECIFIED     : St := '��������';
            24                           : St := '���������� - ���� ������';
            18                           : St := '������ - ���� ������';
            20                           : St := '�������� - ���� ������';
          else
                                           St := IntToStr(cPRN.curJob[i].Status) + ' ������������...';
          end;

          cp.SubItems.Add(st);        // ��������� ������
          cp.SubItems.Add(DateTimeToStr(SystemTimeToDateTime(cPRN.curJob[i].Submitted) + 4 * hour)); // ��������� ���� ����� ���������� � spool
        end;
  end;

  form1.listview1.Items.EndUpdate;  // ��������� ������ ���������

  inc(zz);
  MainStMess('��������� ������...');
  STWorking;
  ChildStMess(IntToStr(zz));

  Application.ProcessMessages;  // ������ ���� ���� ����
  req := false;   // ������ �������
end;


function GetFileDate(FileName: string): TDateTime;
var
  intFileAge: LongInt;
begin
  intFileAge := FileAge(FileName);
  if intFileAge = -1 then
    Result := 0
  else
    Result := Trunc(FileDateToDateTime(intFileAge));
end;

//--- ������������� ���������� ���������
procedure initialization_ASM;
var
  i                   : integer;
  _tempDir,
  _BackUpDir,
  _DayEndTime, s      : string;
  cPRN                : TPrintRec;
  cPRN_               : TFPrintRec;
begin
  // ������ ������������ ��� ������������� ���������
  wk := 1;
  crStop := false;
  ViewLogPanel(true);
  try
    OptionsF := TIniFile.Create(ExtractFileDir(ParamStr(0)) + '\' +iniName);  // ������������ � ����� ��������
//---------- ������ �������� -----------------
    WorkDir := OptionsF.ReadString('main','WorkDir','error');
    _BackUpDir := OptionsF.ReadString('main','BackUpDir','error');
    _tempDir := OptionsF.ReadString('main','TempDir','error');
    _DayEndTime := OptionsF.ReadString('main','DayEndTime','error');

  finally
    OptionsF.Free;  // ��������� ���� ��������
  end;
//---------- �������� �������� -----------------
//------- ����������� �������� ��������
  if (WorkDir = 'error') or (WorkDir = '') then
    begin
      s := ExtractFileDir(ParamStr(0));
      if s[length(s)] = '\' then        // ���� � ����� �����
        WorkDir := ExtractFileDir(ParamStr(0)) + 'base\'
      else
        WorkDir := ExtractFileDir(ParamStr(0)) + '\base\';
      AddLogStr('������� ������� �� ��������� ' + WorkDir);
    end
  else
    AddLogStr('������� ������� ����� ��� ' + WorkDir);
  if DirectoryExists(WorkDir) then
    AddLogStr(' - ������� ���������� ��������')
  else
    if not ForceDirectories(WorkDir) then
      begin
        AddLogStr(' - ������� ���������� ���������� � �� ����� ���� �������');
        CriticalStop;
      end
    else
      AddLogStr(' - ������� ���������� ������� ������');
//------- ����������� ���������� ��������
  if (_tempDir = 'error') or (_tempDir = '') then
    begin
      tempDir := WorkDir + tempDir;
      AddLogStr('��������� ������� �� ��������� ' + tempDir);
    end
  else
    begin
      tempDir := _tempDir;
      AddLogStr('��������� ������� ����� ��� ' + tempDir);
    end;
  if DirectoryExists(tempDir) then
    AddLogStr(' - ��������� ���������� ��������')
  else
    if not ForceDirectories(tempDir) then
      begin
        AddLogStr(' - ��������� ���������� ���������� � �� ����� ���� �������');
        CriticalStop;
      end
    else
      AddLogStr(' - ��������� ���������� ������� ������');
//------- ����������� BackUp ��������
  if (_BackUpDir = 'error') or (_BackUpDir = '') then
    begin
      BackUpDir := WorkDir + BackUpDir;
      AddLogStr('BackUp ������� �� ��������� ' + BackUpDir);
    end
  else
    begin
      BackUpDir := _BackUpDir;
      AddLogStr('BackUp ������� ����� ��� ' + BackUpDir);
    end;
  if DirectoryExists(BackUpDir) then
    AddLogStr(' - BackUp ���������� ��������')
  else
    if not ForceDirectories(BackUpDir) then
      begin
        AddLogStr(' - BackUp ���������� ���������� � �� ����� ���� �������');
        CriticalStop;
      end
    else
      AddLogStr(' - BackUp ���������� ������� ������');
   if (_DayEndTime = 'error') or (_DayEndTime = '') then
     _DayEndTime := '23:59:00';
   DayEndTime := StrToTime(_DayEndTime);

   BlockControl(crStop);
   if crStop then
     exit;
//------- ���������� ������ ������
  AddLogStr('������� �������� ����� ������� ������ ' + workDir + hostsIndex);
  if FileExists(workDir + hostsIndex) then
    hostsList.LoadFromFile(workDir + hostsIndex)
  else
    AddLogStr('���� ������� ������ �� ��������');
  AddLogStr('��������� ��������� ����� : ');
 { for i := 0 to hostsList.Count - 1 do
    AddLogStr('   ' + hostsList.Strings[i]);}
  AddLogStr('--- ����� (' + IntToStr(hostsList.Count) + ')');

//------- ���������� ������ �������������
  AddLogStr('������� �������� ����� ������� ������������� ' + workDir + usersIndex);
  if FileExists(workDir + usersIndex) then
    usersList.LoadFromFile(workDir + usersIndex)
  else
    AddLogStr('���� ������� ������������� �� ��������');
  AddLogStr('��������� ��������� ������������ : ');
 { for i := 0 to usersList.Count - 1 do
    AddLogStr('   ' + usersList.Strings[i]);}
  AddLogStr('--- ����� (' + IntToStr(usersList.Count) + ')');

//------- ���������� ������ ���������
  AddLogStr('������� �������� ����� ��������� ' + workDir + printersIndex);
  aList := TList.Create;
  if FileExists(workDir + printersIndex) then
    try
      printersList := TFileStream.Create(workDir + printersIndex, fmShareDenyRead);
      maxPIndex := Round(printersList.Size / SizeOf(cPRN_));
      for i := 1 to maxPIndex do
        begin
          printersList.Read(cPRN_, SizeOf(cPRN_));
          New(aPrintRec);
          aPrintRec^.printName := AnsiUpperCase(cPRN_.printName);
          aPrintRec^.block := false;
          aPrintRec^.index := cPRN_.index;
          aPrintRec^.status := cPRN_.status;
          aPrintRec^.TotalPages := 0;

          cPRN := aPrintRec^;
          if cPRN.status <> 'ERASE' then
            begin
              cPRN := PPrintRec(aPrintRec)^;
              cPRN := GetSpoolerJobs(cPRN);
              aPrintRec^.predJob := cPRN.CurJob;
            end;
          aList.Add(aPrintRec);
        end;
    finally
      printersList.Free;
    end
  else
    begin
      AddLogStr('���� ��������� �� ��������, ������� ���������� ��������� ��������');
      maxPIndex := sysPRN.Printers.Count - 1;
      if sysPRN.Printers.Count > 0 then
        for i := 0 to sysPRN.Printers.Count - 1 do
          begin
            New(aPrintRec);
            aPrintRec^.printName := AnsiUpperCase(sysPRN.Printers[i]);
            aPrintRec^.block := false;
            aPrintRec^.index := i;
            aPrintRec^.status := 'READY';
            aPrintRec^.TotalPages := 0;
            cPRN := PPrintRec(aPrintRec)^;
            cPRN := GetSpoolerJobs(cPRN);
            aPrintRec^.predJob := cPRN.CurJob;
            aList.Add(aPrintRec);
          end
      else
        begin
          AddLogStr('��������� ��������� �� ����������. ���������� ��������������');
          exit;
        end;
    end;

  AddLogStr('���������� ��������� �������� : ');
  for i := 0 to aList.Count - 1 do
    begin
      aPrintRec := PPrintRec(aList.Items[i]);
      AddLogStr('  ' + aPrintRec^.printName);
    end;
  AddLogStr('--- ����� (' + IntToStr(aList.Count) + ')');

 // -- ������ �������� � ini
  try
    OptionsF := TIniFile.Create(ExtractFileDir(ParamStr(0)) + '\' +iniName);  // ������������ � ����� ��������
//---------- ������ �������� -----------------
    OptionsF.WriteString('main','WorkDir',WorkDir);
    OptionsF.WriteString('main','TempDir',TempDir);
    OptionsF.WriteString('main','BackUpDir',BackUpDir);
    OptionsF.WriteString('main','DayEndTime',TimeToStr(DayEndTime));
  finally
    OptionsF.Free;  // ��������� ���� ��������
  end;

  form1.ProgressBar1.Position := 0;
  ActiveBaseDay := Date;
  AddLogStr('������� ������ ' + DateTimeToStr(ActiveBaseDay) + ' ������������');
  if FileExists(tempDir + tempFile) and (GetFileDate(tempDir + tempFile) = ActiveBaseDay) then
    begin
      AddLogStr('- ����������� ������ ' + DateTimeToStr(ActiveBaseDay));
      tFile:=TFileStream.Create(tempDir + tempFile, fmOpenReadWrite); // �������� ���������� �����
      tFile.Seek(0, soFromEnd); // ������� � ����� ���������� �����
    end
  else
   begin   // ���� temp �� X ���� ���. base �� X ���� �� ���. - �� ���������� ������ ���� (�������� ��� ��������� ���� ������� � ��� �� ���� ����)
    if FileExists(tempDir + tempFile) then
      if not FileExists(WorkDir + DateTimeToStr(GetFileDate(tempDir + tempFile)) + '.dat') and (MessageDlg('������ ������ �� ���������� ����� �� ' + DateTimeToStr(GetFileDate(tempDir + tempFile)),mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
        begin    // ������ ������ �� temp'a
          tFile:=TFileStream.Create(tempDir + tempFile, fmOpenReadWrite); // �������� ���������� �����
          AddLogStr('- �������� ������ ���������� ������ ' + DateTimeToStr(GetFileDate(tempDir + tempFile)));
          StoreDayDataFile(true, GetFileDate(tempDir + tempFile));
          StoreDayDataFile(false, GetFileDate(tempDir + tempFile));
        end
      else
        begin
          tFile:=TFileStream.Create(tempDir + tempFile, fmOpenReadWrite); // �������� ���������� �����
          bFile:=TFileStream.Create(WorkDir + DateTimeToStr(GetFileDate(tempDir + tempFile)) + '.dat', fmOpenRead); // �������� ���������� �����
          if tFile.Size > bFile.Size then
            begin
            bFile.Free;
            if MessageDlg('���� �� ' + DateTimeToStr(GetFileDate(tempDir + tempFile)) + ' ����������, �� ��������� ���� ����� ����������, �����������',mtConfirmation, [mbYes, mbNo], 0) = mrYes then
              begin
                AddLogStr('- ������������ ������ ���������� ������ ' + DateTimeToStr(GetFileDate(tempDir + tempFile)));
                StoreDayDataFile(true, GetFileDate(tempDir + tempFile));
                StoreDayDataFile(false, GetFileDate(tempDir + tempFile));
              end
            end;
        end;
    tFile.Free;
    AddLogStr('�������� ���������� ����� ������');
    tFile:=TFileStream.Create(tempDir + tempFile, fmCreate); // �������� ���������� �����
   end;
  req:=false;

  AddLogStr('�������� � ������ ������ ��������');
  form1.T1 := TPrnReq.Create(true);
  form1.T1.Enabled := true;     // ����� �����������
  form1.t1.priority := tpNormal;
  form1.t1.resume;
  zz := 0;
  ViewLogPanel(false);
end;

//--- �������� ����� � ������������� ����������
procedure TForm1.FormCreate(Sender: TObject);
begin
// �������� ��� ������
  with ProgressBar1 do
  begin
    Parent := StatusBar1;
    Position := 120;
    Top := 6;
    Left := 135;
  end;

  StartTime := Now;
  LogList := TStringList.Create;
  AddLogStr('ASM ��� ����� ������� ' + TimeToStr(StartTime));
  AddLogStr('- ������ �������');
  sysPRN := TPrinter.Create;
  AddLogStr('�������� ������ ������');
  hostsList := TStringList.Create;       // ������� ������ <������ ������>
  hostsList.Duplicates := dupIgnore;     // ������������ ������� ���������� 2� ���������� ������
  AddLogStr('�������� ������ �������������');
  usersList := TStringList.Create;       // ������� ������ <������ �������������>
  usersList.Duplicates := dupIgnore;     // ������������ ������� ���������� 2� ���������� �������������
  initialization_ASM;
end;

//--- ������/�������� ���.
procedure TForm1.RzToolButton4Click(Sender: TObject);
begin
  ListView1.Visible :=  not ListView1.Visible;
  Memo1.Visible := not Memo1.Visible;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  i : Integer;
begin
  if crStop then exit;
  CanClose:=false;  // ��������� ������ ������������ ��� �������� ���������
  if zz <> 0 then
    begin
      T1.Enabled := false;
      AddLogStr('���������� ������ ������, �������� ������ ���������� ���������');
      if aList.Count <> 0 then
        begin
          StoreIndex(true);
          StoreDayDataFile(true, ActiveBaseDay);
          StoreIndex(false);
          StoreDayDataFile(false, ActiveBaseDay);
        end;
      LogList.SaveToFile(workDir + LogFile);
      AddLogStr('-- ����� ����������� �������� � ������� ������ ' + IntToStr(zz));
    end;
  AddLogStr('');
                                  // ���� ������������� ������ �� ��������� �������
  if MessageDlg('�� ������� ��� ������ ����� �� ���������', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    begin
      T1.Enabled := true;
      exit;
    end;

  sysPRN.Destroy;
  hostsList.Destroy;
  usersList.Destroy;
  LogList.Destroy;
  tFile.Free;

  for i := 0 to aList.Count - 1 do              // ������� ������� ������ aList
    Dispose(PPrintRec(aList.Items[i]));
  aList.Free;
  CanClose:=true;
end;

procedure TForm1.RzToolButton1Click(Sender: TObject);
begin  // ������ �������
  if T1.Enabled or (aList.Count = 0) then exit;  // ��� �������
  T1.Enabled := true;
  AddLogStr('������� ������� �������');
end;

procedure TForm1.RzToolButton2Click(Sender: TObject);
begin  // ��������� ������
  if not T1.Enabled then exit; // ��� ����������
  if MessageDlg('����������� ��������� �����������',mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      T1.Enabled := false;
      MainStMess('���������� �������������...');
      ChildStMess('');
      AddLogStr('������� ���������� �������');
    end;
end;

procedure TForm1.RzButton1Click(Sender: TObject);
begin
  GroupBox1.Visible := false;
end;

procedure TForm1.RzToolButton5Click(Sender: TObject);
begin
  GroupBox1.Left := form1.width div 2 - GroupBox1.Width div 2;
  GroupBox1.Visible := not GroupBox1.Visible;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  GroupBox1.Left := form1.width div 2 - GroupBox1.Width div 2;
end;

procedure TForm1.RzToolButton3Click(Sender: TObject);
begin
  form2.show;
end;

procedure TForm1.RzToolButton9Click(Sender: TObject);
begin
  form1.close;
end;

procedure AddPrinter(prnN : string);
var
  cPRN : TPrintRec;
  i    : integer;
begin
  form1.T1.Enabled := false;
  for i := 0 to aList.Count - 1 do
    if PPrintRec(aList.Items[i])^.printName = AnsiUpperCase(prnN) then
      begin
        cPRN := PPrintRec(aList.Items[i])^;
        cPRN.status := 'READY';
        cPRN.TotalPages := 0;
        cPRN.block := false;
        cPRN := GetSpoolerJobs(cPRN);
        cPRN.predJob := cPRN.CurJob;
        PPrintRec(aList.Items[i])^ := cPRN;
        form1.T1.Enabled := true;
        AddLogStr('�������� ������� ' + prnN);
        exit;
      end;

  New(aPrintRec);
  aPrintRec^.index := maxPIndex + 1;
  aPrintRec^.printName := AnsiUpperCase(prnN);
  aPrintRec^.block := false;
  aPrintRec^.TotalPages := 0;
  aPrintRec^.status := 'READY';

  cPRN := PPrintRec(aPrintRec)^;
  cPRN := GetSpoolerJobs(cPRN);
  aPrintRec^.predJob := cPRN.CurJob;
  aList.Add(aPrintRec);
  AddLogStr('�������� ������� ' + prnN);
  form1.T1.Enabled := true;
end;

procedure DeletePrinter(prnN : string);
var
  i : Integer;
begin
  if aList.Count < 1 then exit;
  form1.T1.Enabled := false;
  for i := 0 to aList.Count - 1 do    // ������� �� ���� ���������
    if PPrintRec(aList.Items[i])^.printName = AnsiUpperCase(prnN) then
      begin
        PPrintRec(aList.Items[i])^.status := 'ERASE';
        AddLogStr('������ ������� ' + prnN);
        break;
      end;
  form1.T1.Enabled := true;
end;

procedure PausePrinter(prnN : string);
var
  i : Integer;
begin
  if aList.Count < 1 then exit;
  form1.T1.Enabled := false;
  for i := 0 to aList.Count - 1 do    // ������� �� ���� ���������
    if PPrintRec(aList.Items[i])^.printName = AnsiUpperCase(prnN) then
      begin
        PPrintRec(aList.Items[i])^.status := 'PAUSE';
        AddLogStr('����� ��� �������� ' + prnN);
        break;
      end;
  form1.T1.Enabled := true;
end;

procedure ReadyPrinter(prnN : string);
var
  i : Integer;
begin
  if aList.Count < 1 then exit;
  form1.T1.Enabled := false;
  for i := 0 to aList.Count - 1 do    // ������� �� ���� ���������
    if PPrintRec(aList.Items[i])^.printName = AnsiUpperCase(prnN) then
      begin
        PPrintRec(aList.Items[i])^.status := 'READY';
        AddLogStr('������ ��� �������� ' + prnN);
        break;
      end;
  form1.T1.Enabled := true;
end;

procedure StopPrinter(prnN : string);
var
  i : Integer;
begin
  if aList.Count < 1 then exit;
  form1.T1.Enabled := false;
  for i := 0 to aList.Count - 1 do    // ������� �� ���� ���������
    if PPrintRec(aList.Items[i])^.printName = AnsiUpperCase(prnN) then
      begin
        PPrintRec(aList.Items[i])^.status := 'STOP';
        PPrintRec(aList.Items[i])^.TotalPages := 0;
        AddLogStr('���� ��� �������� ' + prnN);
        break;
      end;
  form1.T1.Enabled := true;
end;


procedure TForm1.RzToolButton7Click(Sender: TObject);
begin
  if Edit1.Text = '' then exit;
  DeletePrinter(Edit1.Text);
end;

procedure TForm1.RzToolButton8Click(Sender: TObject);
begin
  if Edit1.Text = '' then exit;
  AddPrinter(Edit1.Text);
end;

procedure TForm1.RzToolButton10Click(Sender: TObject);
begin
  if Edit1.Text = '' then exit;
  PausePrinter(Edit1.Text);
end;

procedure TForm1.RzToolButton11Click(Sender: TObject);
begin
  if Edit1.Text = '' then exit;
  ReadyPrinter(Edit1.Text);
end;

procedure TForm1.RzToolButton12Click(Sender: TObject);
begin
  if Edit1.Text = '' then exit;
  StopPrinter(Edit1.Text);
end;

procedure TForm1.RzToolButton6Click(Sender: TObject);
begin // ���������� ������ ����
  AddLogStr('���������� ������ ������ �������� �������');
  if aList.Count = 0 then exit;
  T1.Enabled := false;
  StoreIndex(true);
  StoreDayDataFile(true, ActiveBaseDay);
  StoreIndex(false);
  StoreDayDataFile(false, ActiveBaseDay);
  LogList.SaveToFile(workDir + LogFile);
  T1.Enabled := true;
end;

procedure TForm1.ApplicationEvents1Exception(Sender: TObject;
  E: Exception);
begin
  AddLogStr('�������������� ��������');
end;

procedure TForm1.ListView1CustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  with ListView1.Canvas.Brush do
   begin
     case Item.Index of
       0: Color := clYellow;
       1: Color := clGreen;
       2: Color := clRed;
     end;
   end;
end;

end.
