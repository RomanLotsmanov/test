unit Splash;

interface   

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls, jpeg, MyMoneyDBEngine, mainForm, TransactionAdd,
  Mask, Buttons;

type
  TSplashFrm = class(TForm)
    img1: TImage;
    SplashLabel: TLabel;
    pb1: TProgressBar;
    btnok: TBitBtn;
    medtPass: TMaskEdit;
    procedure FormCreate(Sender: TObject);
    procedure btnokClick(Sender: TObject);
    procedure medtPassKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SplashFrm : TSplashFrm;

procedure SplashString(mess : string; procent, Delay : Integer);

implementation

{$R *.dfm}

uses idHTTP;

var
  HTTP : TIdHTTP;
  
procedure SplashString(mess : string; procent, Delay : Integer);
begin
  Application.ProcessMessages;
  SplashFrm.SplashLabel.Caption := mess;
  SplashFrm.SplashLabel.Refresh;
  SplashFrm.pb1.Position := procent;
  Sleep(Delay);
end;

procedure start;
var
  i, MaxWidth : Integer;
  S           : TStringList;
begin
  SplashFrm.medtPass.Visible := False;
  SplashFrm.btnok.Visible := False;
  SplashString('����� ������ ����������', 9, 100);
  //-- �������������� � ��������� ������ ��������
  FTList := TList.Create;
  if not LoadIndex then
    begin
      MessageDlg('�� ������� ��������� �������� ����� �������� ��', mtError, [mbOK], 0);
      Application.Terminate;
    end;
  for  i := 0 to NotesList.Count - 1 do
    mainFrm.chklstNotes.Items.Add(NotesList.Strings[i]);
  MaxWidth := 0;
  for i := 0 to mainFrm.chklstNotes.Items.Count - 1 do
    if MaxWidth < mainFrm.chklstNotes.Canvas.TextWidth(mainFrm.chklstNotes.Items.Strings[i]) then
      MaxWidth := mainFrm.chklstNotes.Canvas.TextWidth(mainFrm.chklstNotes.Items.Strings[i]);
  SendMessage(mainFrm.chklstNotes.Handle, LB_SETHORIZONTALEXTENT, MaxWidth+2, 0);
//-- ������� ��
  if FileExists(MainDBFile) then
    begin
      DBFile := TFileStream.Create(MainDBFile, fmOpenReadWrite);
    end
  else
    begin
      DBFile := TFileStream.Create(MainDBFile, fmCreate);
    end;
  DBFile.Free;
  if not CheckDB then
    if MessageDlg('��������� ����������� � ���� ������', mtWarning, [mbYes, mbNo], 0) = mrYes then
      RestoreDB
    else
      begin
        MessageDlg('���� ������ ���������� ��������� �����������! ���������� ������ ����������', mtError, [mbOK], 0);
        Application.Terminate;
      end;
  LoadDB;
  FillListFields;
  SplashString('��������� ������ ����� � ���', 99, 500);
  HTTP := TIdHTTP.Create(nil);
  HTTP.HandleRedirects := True;
  HTTP.ProtocolVersion := pv1_0;
  HTTP.ProtocolVersion := pv1_0;
//  HTTP.Proxy;
  S := TStringList.Create;
  try
    S.Text := HTTP.Get('http://www.rbc.ru/out/802.csv');
  except
    case HTTP.ResponseCode of
      403 : AddLogStr('������ ������� � ����� ����� ���');
    end;
    S.Text := HTTP.ResponseText;
  end;
  if not DirectoryExists(DBWorkDir + 'rbk')then
    MkDir(DBWorkDir + 'rbk\');
  if not FileExists(DBWorkDir + 'rbk\' + DateToStr(Date) + '.csv') then
    S.SaveToFile(DBWorkDir + 'rbk\' + DateToStr(Date) + '.csv');
  SplashString('������ ���������', 99, 500);
  HTTP.Free;
  S.Free;
  Run := true;
  SplashFrm.Hide;
  mainFrm.Show;
end;

procedure TSplashFrm.btnokClick(Sender: TObject);
begin
  start;
end;

procedure TSplashFrm.FormCreate(Sender: TObject);
Var
  ExtEndedStyle:dword;
  Wnd : hWnd;
  buff : Array[0.. 127] of Char;
begin
  Wnd := GetWindow(Handle, gw_HWndFirst);  // -- �� ���� ��������� ������ ���������
  While Wnd <> 0 DO
    Begin
      If (Wnd <> Application.Handle) and (GetWindow(Wnd, gw_Owner) = 0) Then
        Begin
          GetWindowText (Wnd, buff, sizeof (buff ));
          If StrPas (buff) = Application.Title Then
             Halt;
        End;
      Wnd := GetWindow (Wnd, gw_hWndNext);
    End;

  DBIndex := 0;
  indexType := 255;
  ProgramWorkDir := ExtractFileDir(ParamStr(0)) + '\';   // ���������� ���������� ���������
  LoadLog; // �������������� ��� �����
  AddLogStr('');
  AddLogStr('******* ��������� �������� ********');
  AddLogStr('');
  AddLogStr('����� ���� �����������');
  AddLogStr('���������� ��������� ' + ProgramWorkDir);
  DBWorkDir := ProgramWorkDir;             { TODO : ���������� ���������� �� }     // ���������� ������� ��
  AddLogStr('���������� ���� ������ ' + DBWorkDir);
  StartStream := TStringList.Create;
  if FileExists(DBWorkDir + 'started') then
    begin
      StartStream.LoadFromFile(DBWorkDir + 'started');
      MessageDlg('���� ������ �������� � ������ ������, ����� : ' + StartStream[0], mtError, [mbOK], 0);
      Application.Terminate;
      Exit;
    end;
//-- ���������� ���������� ���� ���� ������ ��
  StartStream.Add(GetCurrentUserName + ' ' + GetComputerNetName);
  StartStream.SaveToFile(DBWorkDir + 'started');
  StartStream.Free;
  MainDBFile          := DBWorkDir + 'Money.financy';
  AccountIndexFile    := DBWorkDir + AccountFileName;
  CurrencyIndexFile   := DBWorkDir + CurrencyFileName;
  CategoryIndexFile   := DBWorkDir + CategoryFileName;
  PersonaIndexFile    := DBWorkDir + PersonaFileName;
  ContractorIndexFile := DBWorkDir + ContractorFileName;
  StandardIndexFile   := DBWorkDir + StandardFileName;
  EventIndexFile      := DBWorkDir + EventFileName;

  CommentIndexFile      := DBWorkDir + CommentFileName;
  DescriptionIndexFile  := DBWorkDir + DescriptionFileName;
  DescriptionIndexFile1 := DBWorkDir + DescriptionFileName1;
  DescriptionIndexFile2 := DBWorkDir + DescriptionFileName2;

  BackUpDBFile        := DBWorkDir + 'Money.backup';
  AutoDBFile          := DBWorkDir + AutoFileName;
  NotesIndexFile      := DBWorkDir + 'notes.txt';
  SplashString('������� ������', 99, 500);
end;

procedure TSplashFrm.medtPassKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then start;
end;

end.
