unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, Mask, IniFiles, Buttons, ExtCtrls, ShellAPI, ShlObj;

type
  TForm2 = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Button1: TButton;
    Button2: TButton;
    DateTimePicker1: TDateTimePicker;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    procedure RzButtonEdit1ButtonClick(Sender: TObject);
    procedure RzButton2Click(Sender: TObject);
    procedure RzButtonEdit2ButtonClick(Sender: TObject);
    procedure RzButtonEdit3ButtonClick(Sender: TObject);
    procedure RzButton1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.DFM}

uses unit1;

function FolderSelDialog(TitleName : string) : string;
var
  lpItemID : PItemIDList;
  BrowseInfo : TBrowseInfo;
  DisplayName : array[0..MAX_PATH] of char;
  TempPath : array[0..MAX_PATH] of char;
begin
  FillChar(BrowseInfo, sizeof(TBrowseInfo), #0);
  BrowseInfo.hwndOwner := Form1.Handle;
  BrowseInfo.pszDisplayName := @DisplayName;
  BrowseInfo.lpszTitle := PChar(TitleName);
  BrowseInfo.ulFlags := BIF_RETURNONLYFSDIRS;
  lpItemID := SHBrowseForFolder(BrowseInfo);
  if lpItemId <> nil then
  begin
    SHGetPathFromIDList(lpItemID, TempPath);
    result := TempPath;
    GlobalFreePtr(lpItemID);
  end;
end;


procedure TForm2.RzButtonEdit1ButtonClick(Sender: TObject);
begin
  Edit1.Text := FolderSelDialog('Выбор рабочего каталога :');
  form2.SetFocus;
end;

procedure TForm2.RzButton2Click(Sender: TObject);
begin
  form2.Close;
end;

procedure TForm2.RzButtonEdit2ButtonClick(Sender: TObject);
begin
  Edit1.Text := FolderSelDialog('Выбор временного каталога :');
  form2.SetFocus;
end;

procedure TForm2.RzButtonEdit3ButtonClick(Sender: TObject);
begin
  Edit1.Text := FolderSelDialog('Выбор BackUp каталога :');
  form2.SetFocus;
end;

procedure TForm2.RzButton1Click(Sender: TObject);
begin // Сохранение настроек
  WorkDir := Edit1.Text;
  TempDir := Edit2.Text;
  BackUpDir := Edit3.Text;
  DayEndTime := DateTimePicker1.Time;
  try
    OptionsF := TIniFile.Create(ExtractFileDir(ParamStr(0)) + '\' +iniName);  // подключаемся к файлу настроек
//---------- запись настроек -----------------
    OptionsF.WriteString('main','WorkDir',WorkDir);
    OptionsF.WriteString('main','TempDir',TempDir);
    OptionsF.WriteString('main','BackUpDir',BackUpDir);
    OptionsF.WriteString('main','DayEndTime',TimeToStr(DayEndTime));
  finally
    OptionsF.Free;  // закрываем файл настроек
  end;
  if crStop then
    begin
      AddLogStr('');
      AddLogStr(' Переинициализация после неудачного запуска');
      initialization_ASM;
    end;
  form2.close;
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
  Edit1.Text := WorkDir;
  Edit2.Text := TempDir;
  Edit3.Text := BackUpDir;
  DateTimePicker1.Time := DayEndTime;
end;

end.
