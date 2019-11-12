unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ElTree, ElHeader, RzButton, RzStatus, RzPanel,
  RzSplit, RzCmboBx, RzCommon, Mask, RzEdit, ComCtrls, RzDTP, RzLstBox,
  RzChkLst, ImgList, IniFiles, RzSelDir, RzShellDialogs, RzPrgres, DdeMan;

type
  TForm1 = class(TForm)
    OpenDialog1: TOpenDialog;
    RzSplitter1: TRzSplitter;
    RzToolbar1: TRzToolbar;
    RzStatusBar1: TRzStatusBar;
    ElTree1: TElTree;
    RzStatusPane1: TRzStatusPane;
    RzToolButton1: TRzToolButton;
    RzEdit1: TRzEdit;
    RzFrameController1: TRzFrameController;
    RzEdit2: TRzEdit;
    RzEdit3: TRzEdit;
    RzEdit4: TRzEdit;
    RzEdit5: TRzEdit;
    RzListBox1: TRzListBox;
    RzListBox2: TRzListBox;
    RzListBox3: TRzListBox;
    RzImageComboBox1: TRzImageComboBox;
    RzCheckList1: TRzCheckList;
    RzStatusBar2: TRzStatusBar;
    RzStatusPane2: TRzStatusPane;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    RadioButton1: TRadioButton;
    RzGroupBox1: TRzGroupBox;
    RzDateTimePicker1: TRzDateTimePicker;
    RadioButton2: TRadioButton;
    ImageList1: TImageList;
    ImageList2: TImageList;
    RzDateTimePicker2: TRzDateTimePicker;
    RzDateTimePicker3: TRzDateTimePicker;
    RzDateTimePicker4: TRzDateTimePicker;
    Label8: TLabel;
    Label9: TLabel;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    Image6: TImage;
    RzSelectFolderDialog1: TRzSelectFolderDialog;
    RzStatusPane3: TRzStatusPane;
    RzStatusPane4: TRzStatusPane;
    RzProgressBar1: TRzProgressBar;
    RzKeyStatus1: TRzKeyStatus;
    RzKeyStatus2: TRzKeyStatus;
    RzComboBox1: TRzComboBox;
    RzToolButton2: TRzToolButton;
    RzSpacer1: TRzSpacer;
    RzSpacer2: TRzSpacer;
    Label10: TLabel;
    RzSpacer3: TRzSpacer;
    RzClockStatus1: TRzClockStatus;
    RzToolButton3: TRzToolButton;
    SaveDialog1: TSaveDialog;
    RzToolButton4: TRzToolButton;
    procedure Button1Click(Sender: TObject);
    procedure ElTree1HeaderColumnClick(Sender: TObject;
      SectionIndex: Integer);
    procedure ElTree1CompareItems(Sender: TObject; Item1,
      Item2: TElTreeItem; var res: Integer);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure RadioButton2Click(Sender: TObject);
    procedure RadioButton1Click(Sender: TObject);
    procedure RzToolButton2Click(Sender: TObject);
    procedure RzEdit5Change(Sender: TObject);
    procedure RzEdit3Change(Sender: TObject);
    procedure RzEdit4Change(Sender: TObject);
    procedure RzListBox1Click(Sender: TObject);
    procedure RzEdit5DblClick(Sender: TObject);
    procedure RzEdit3DblClick(Sender: TObject);
    procedure RzEdit4DblClick(Sender: TObject);
    procedure RzListBox2Click(Sender: TObject);
    procedure RzListBox3Click(Sender: TObject);
    procedure RzEdit1DblClick(Sender: TObject);
    procedure RzEdit2DblClick(Sender: TObject);
    procedure RzToolButton3Click(Sender: TObject);
    procedure RzToolButton4Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

const
// XLS streams array
  CXlsBof:    array[0..5] of Word = ($809, 8, 00, $10, 0, 0);
  CXlsEof:    array[0..1] of Word = ($0A, 00);
  CXlsLabel:  array[0..5] of Word = ($204, 0, 0, 0, 0, 0);
  CXlsNumber: array[0..4] of Word = ($203, 14, 0, 0, 0);
  CXlsRk:     array[0..4] of Word = ($27E, 10, 0, 0, 0);

  iniName = 'ASMR.ini';
  hostsIndex            = 'Hosts.idx';      // хост индекс файл
  printersIndex         = 'Printers.idx';   // принтер индекс файл
  usersIndex            = 'users.idx';      // файл индекс пользователей
// временные константы
  Hour = 3600000/MSecsPerDay;
  Minute = 60000/MSecsPerDay;
  Second = 1000/MSecsPerDay;


type
  TPrnJobBaseRec = record
  id         : char;        // 1
  prnIndex   : integer;
  Doc        : string[255]; // 256
  HostIndex  : integer;     // 4
  userIndex  : integer;     // 4
  Pages      : integer;     // 4
  DateTime   : TDateTime;   // 8        total 277 bytes
  SpoolWork  : TDateTime;
  DocType    : string[3];
end;

TFPrintRec = record
  printName  : string[127];           // имя принтера
  status     : string[5];
  index      : integer;
end;


var
  pFile    : TFileStream;
  FPRN_Rec : TPrnJobBaseRec;
  OptionsF : TIniFile;     // файл настроек
  WorkDir  : string;
  AppPath  : string;

  usersList      : TStringList;        // индексированый список пользователей
  hostsList      : TStringList;        // индексированый список хостов
  printersList   : TStringList;        // индексированый список принтеров

  TotalPages     : Integer;
  printersList_  : TFileStream;


procedure MainStMess(mess : string);
begin
  form1.RzStatusPane2.Caption := mess;
  form1.RzStatusPane2.Update;
end;

function PaternCmpr(Text,Source:String):boolean;
var
  i,j,k:Integer;
  s:string;

function mPos(Str,SubStr:string;var index:integer):boolean;
var
  i,j,k:integer;
begin
  result:=false;
  if length(SubStr) <= length(Str) then
    for j:=1 to length(Str) do // Совпадение элемента : ?-любой символ, #-любое число
      begin
        k:=0;  // счетчик совпадений
        for i:=j to length(Str) do
          if (Str[i] = SubStr[k+1]) or (SubStr[k+1] = '?') or ((SubStr[k+1] = '#') and (Str[i] in ['0'..'9'])) then
            begin
              if ((index > 0) and (i < index)) then continue; // если ищем совпадение выше index то ждем i > index
              inc(k);  // добавляем совпадение
              if k = length(SubStr) then
                begin
                  result:=true; // если счетчик совпадений равен длинне подстроки то подстрока найдена
                  index:=i+1;     // "Зазор"
                  exit;
                end;
            end
          else
            k:=0; // при первом несовпадении сбрасываем счетчик совпадений
      end;
end;

begin   // text - *?#zz     source - Any string
  result:=false;
  s:='';
  k:=0;
  if Pos('*',Text) <> 0 then // Сложная маска с *
    begin
      j:=length(text);
      k:=1;
      if j <> 1 then
        for i:=1 to j do // Выделение очередного microBlock и поиск его в строке Source
          begin
            if ((text[i] = '*') and (i > 1)) then  // если превый символ то искать еще нечего
              begin
                if s = '' then continue;         // если например две ** то s = ''
                if not mPos(source,s,k) then exit;// ищем microBlock
                if (i - (length(s)+1) = 0) and (i <> k) then exit; // Корректная обработка начала X*
                s:='';                          // освобождаем для следующей строки microBlock
              end
            else
              if text[i] <> '*' then s:=s + text[i];  // заполняем очередной microBlock
            if (i=j) and (text[i] <> '*') then
              begin
                if (length(source)-length(s)) < k then exit;         // Корректная обработка окончания !!! *X
                k:=(length(source)-length(s));
                if not mPos(source,s,k) then exit;// ищем microBlock
                s:='';                          // освобождаем для следующей строки microBlock
              end;
          end;
      result:=true;
    end
  else          // маска без *
    Result := (length(source) = length(text)) and (mPos(source,text,k)); // при такой маске длины обязательно совпадают
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  i, cr, j, n, Code : Integer;
  TSI         : TElTreeItem;
  loDT, hiDT  : TDateTime;
  s           : string;
  OperBegin, OperEnd: TTimeStamp;
  Total: LongWord;

begin
  OperBegin := DateTimeToTimeStamp(Now);
  s := DateToStr(RzDateTimePicker1.date);
  s := s + TimeToStr(RzDateTimePicker2.time);
  loDT := StrToDateTime(s);
  s := DateToStr(RzDateTimePicker3.date);
  s := s + TimeToStr(RzDateTimePicker4.time);
  hiDT := StrToDateTime(s);
  for j := 0 to RzCheckList1.Items.Count - 1 do
    if RzCheckList1.ItemState[j] = cbChecked then
      begin
        ElTree1.IsUpdating := true;
        RzProgressBar1.Visible := true;
        RzProgressBar1.Percent := 0;
        pFile := TFileStream.Create(workDir + RzCheckList1.Items[j], fmShareDenyRead);
        cr := Round(pFile.Size / SizeOf(FPRN_Rec));
        MainStMess('Обработка запроса (' + IntToStr(j + 1) + '|' + IntToStr(RzCheckList1.Items.Count) + ') : ');
        for i := 1 to cr do
          begin
            pFile.Read(FPRN_Rec,SizeOf(FPRN_Rec));
       // проверка условий запроса
            if not PaternCmpr(RzEdit5.Text, printersList.strings[FPRN_Rec.prnIndex]) or
               not PaternCmpr(RzEdit3.Text, UsersList.strings[FPRN_Rec.UserIndex])   or
               not PaternCmpr(RzEdit4.Text, HostsList.strings[FPRN_Rec.HostIndex]) or
               not PaternCmpr(RzEdit1.Text, FPRN_Rec.Doc) then continue;

            if ((RzImageComboBox1.ItemIndex = 1) and (FPRN_Rec.DocType <> 'SYS')) or
               ((RzImageComboBox1.ItemIndex = 3) and (FPRN_Rec.DocType <> 'R/3')) or
               ((RzImageComboBox1.ItemIndex = 4) and (FPRN_Rec.DocType <> 'DOC')) or
               ((RzImageComboBox1.ItemIndex = 5) and (FPRN_Rec.DocType <> 'XLS')) or
               ((RzImageComboBox1.ItemIndex = 2) and (FPRN_Rec.DocType <> '---')) then continue;

        // проверка диапазона времени

            if RadioButton2.Checked then // не любое время
              if not ((loDT <= FPRN_Rec.DateTime)  and
                      (hiDT >= FPRN_Rec.DateTime)) then
                      continue;
        // проверка диапазона страниц
            s := RzEdit2.Text;
            if s <> '*' then
              if s[1] = '>' then
                begin
                  Delete(s, 1, 1);
                  Val(s, n, Code);
                  if not (n < FPRN_Rec.Pages) then continue;
                end
              else
                if s[1] = '<' then
                  begin
                    Delete(s, 1, 1);
                    Val(s, n, Code);
                    if not (n > FPRN_Rec.Pages) then continue;
                  end
                else
                  begin
                    Val(s, n, Code);
                    if n <> FPRN_Rec.Pages then continue;
                  end;

            TSI := ElTree1.Items.AddItem(nil);         // ----------
            TSI.ParentStyle := false;
            TSI.Text := FPRN_Rec.Doc;
            TSI.ImageIndex := 1;
            if FPRN_Rec.DocType = 'SYS' then TSI.ImageIndex := 0;
            if FPRN_Rec.DocType = 'R/3' then TSI.ImageIndex := 2;
            if FPRN_Rec.DocType = 'XLS' then TSI.ImageIndex := 4;
            if FPRN_Rec.DocType = 'DOC' then TSI.ImageIndex := 3;
            TSI.ColumnText.Add(HostsList.Strings[FPRN_Rec.HostIndex]);
            TSI.ColumnText.Add(UsersList.Strings[FPRN_Rec.UserIndex]);
            TSI.ColumnText.Add(IntToStr(FPRN_Rec.pages));
            TSI.ColumnText.Add(DateTimeToStr(FPRN_Rec.DateTime));
            TSI.ColumnText.Add(TimeToStr(FPRN_Rec.SpoolWork));
            TSI.ColumnText.Add(PrintersList.Strings[FPRN_Rec.prnIndex]);

            RzProgressBar1.Percent :=  round(i * (100/cr));

            TotalPages := TotalPages + FPRN_Rec.pages;
          end;
        TSI := ElTree1.Items.AddItem(nil);         // ----------
        TSI.ParentStyle := false;
        TSI.Text := 'Всего : ';
        TSI.ColumnText.Add('');
        TSI.ColumnText.Add('');
        TSI.ColumnText.Add(IntToStr(TotalPages));
        TSI.ColumnText.Add('');
        TSI.ColumnText.Add('');
        TSI.ColumnText.Add('');
        RzProgressBar1.Visible := false;
        MainStMess('Режим ожидания запроса');
        ElTree1.IsUpdating := false;
        pFile.Free;
      end;
  OperEnd := DateTimeToTimeStamp(Now); {запоминается момент окончания операции}
  Total := OperEnd.Time - OperBegin.Time;
  RzStatusPane4.Caption := TimeToStr(total);
end;

procedure TForm1.ElTree1HeaderColumnClick(Sender: TObject;
  SectionIndex: Integer);
begin
  ElTree1.SortSection:=SectionIndex;
  if ElTree1.HeaderSections[SectionIndex].SortMode=hsmAscend then
     ElTree1.HeaderSections[SectionIndex].SortMode:=hsmDescend else
     ElTree1.HeaderSections[SectionIndex].SortMode:=hsmAscend;
   ElTree1.Sort(false);
end;

procedure TForm1.ElTree1CompareItems(Sender: TObject; Item1,
  Item2: TElTreeItem; var res: Integer);
var S1, S2 : string;
begin
  S1 := '';
  S2 := '';
  try
    if Item1.ColumnText.Count>0 then S1:=Item1.ColumnText[0];
  except
     on E:Exception do ;
  end;
  try
    if Item2.ColumnText.Count>0 then S2:=Item2.ColumnText[0];
  except
     on E:Exception do ;
  end;
  If Item1.Bold then
  begin
    if Item2.Bold then
    begin
      res:=AnsiCompareText(S1, S2);
    end else res:=-1;
  end else
    if item2.Bold then res:=1 else
    begin
      res:=AnsiCompareText(S1, S2);
    end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  cPRN_           : TFPrintRec;
  maxPIndex, i, k : integer;
  SRec            : TSearchRec;
  FindRes         : integer;
begin
  TotalPages := 0;
  RzDateTimePicker1.Date := Date;
  RzDateTimePicker3.Date := Date;
  MainStMess('Режим ожидания запроса');
  AppPath := ExtractFileDir(ParamStr(0));
  RzImageComboBox1.AddItem('Все',6,0);
  RzImageComboBox1.AddItem('Система',0,0);
  RzImageComboBox1.AddItem('Разное',1,0);
  RzImageComboBox1.AddItem('SAP R/3',2,0);
  RzImageComboBox1.AddItem('MS Word',3,0);
  RzImageComboBox1.AddItem('MS Excel',4,0);
  RzImageComboBox1.ItemIndex := 0;
  RzComboBox1.ItemIndex := 0;
  WorkDir := 'error';
  if AppPath[length(AppPath)] <> '\' then
    AppPath := AppPath + '\';
  try
    OptionsF := TIniFile.Create(AppPath + iniName);  // подключаемся к файлу настроек
//---------- чтение настроек -----------------
    WorkDir := OptionsF.ReadString('main','WorkDir','error');
  finally
    OptionsF.Free;  // закрываем файл настроек
  end;
  if WorkDir = 'error' then
  repeat
  until RzSelectFolderDialog1.Execute;
  if WorkDir = 'error' then workDir := RzSelectFolderDialog1.SelectedPathName;
//----- Проверка ----
  if WorkDir[length(workDir)] <> '\' then
    workDir := workDir + '\';

//--------- Запись настроек ----------------
  try
    OptionsF := TIniFile.Create(AppPath + '\' +iniName);  // подключаемся к файлу настроек
    OptionsF.WriteString('main','WorkDir',WorkDir);
  finally
    OptionsF.Free;  // закрываем файл настроек
  end;

  usersList := TStringList.Create;
  hostsList := TStringList.Create;
  printersList := TStringList.Create;

  usersList.LoadFromFile(workDir + usersIndex);
  hostsList.LoadFromFile(workDir + hostsIndex);

  if FileExists(workDir + printersIndex) then
    try
      printersList_ := TFileStream.Create(workDir + printersIndex, fmShareDenyRead);
      maxPIndex := Round(printersList_.Size / SizeOf(cPRN_));
      for k := 0 to maxPIndex do
        begin
          printersList_.Seek(0, soFromBeginning);
          for i := 1 to maxPIndex do
            begin
              printersList_.Read(cPRN_, SizeOf(cPRN_));
              if k = cPRN_.index then
                printersList.Add(cPRN_.printName);
            end;
        end;
    finally
      printersList_.Free;
    end;

  FindRes := FindFirst(workDir + '*.dat', faAnyFile, SRec);

  while FindRes = 0 do // пока мы находим файлы (каталоги), то выполнять цикл
  begin
    RzCheckList1.Items.Add(SRec.Name); // добавление в список название
    FindRes := FindNext(SRec); // продолжение поиска по заданным условиям
  end;

  RzListBox1.Items.Assign(printersList);
  RzListBox2.Items.Assign(usersList);
  RzListBox3.Items.Assign(hostsList);
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  usersList.Free;
  hostsList.Free;
  printersList.Free;
end;

procedure TForm1.RadioButton2Click(Sender: TObject);
begin
  RzGroupBox1.Enabled := true;
end;

procedure TForm1.RadioButton1Click(Sender: TObject);
begin
  RzGroupBox1.Enabled := false;
end;

procedure TForm1.RzToolButton2Click(Sender: TObject);
begin
  TotalPages := 0;
  ElTree1.Items.Clear;
end;

procedure TForm1.RzEdit5Change(Sender: TObject);
var
  i:Integer;
begin
  RzListBox1.Items.Clear;
  if RzEdit5.Text = '' then exit;
  for i := 0 to printersList.Count - 1 do
    if PaternCmpr(RzEdit5.Text, printersList.strings[i]) then
       RzListBox1.Items.Add(printersList.strings[i]);
end;


procedure TForm1.RzEdit3Change(Sender: TObject);
var
  i:Integer;
begin
  RzListBox2.Items.Clear;
  if RzEdit3.Text = '' then exit;
  for i := 0 to usersList.Count - 1 do
    if PaternCmpr(RzEdit3.Text, usersList.strings[i]) then
       RzListBox2.Items.Add(usersList.strings[i]);
end;

procedure TForm1.RzEdit4Change(Sender: TObject);
var
  i:Integer;
begin
  RzListBox3.Items.Clear;
  if RzEdit4.Text = '' then exit;
  for i := 0 to hostsList.Count - 1 do
    if PaternCmpr(RzEdit4.Text, hostsList.strings[i]) then
       RzListBox3.Items.Add(hostsList.strings[i]);
end;

procedure TForm1.RzListBox1Click(Sender: TObject);
begin
  RzEdit5.Text := RzListBox1.SelectedItem;
end;

procedure TForm1.RzEdit5DblClick(Sender: TObject);
begin
  RzEdit5.Text := '*';
end;

procedure TForm1.RzEdit3DblClick(Sender: TObject);
begin
  RzEdit3.Text := '*';
end;

procedure TForm1.RzEdit4DblClick(Sender: TObject);
begin
  RzEdit4.Text := '*';
end;

procedure TForm1.RzListBox2Click(Sender: TObject);
begin
  RzEdit3.Text := RzListBox2.SelectedItem;
end;

procedure TForm1.RzListBox3Click(Sender: TObject);
begin
  RzEdit4.Text := RzListBox3.SelectedItem;
end;

procedure TForm1.RzEdit1DblClick(Sender: TObject);
begin
  RzEdit1.Text := '*';
end;

procedure TForm1.RzEdit2DblClick(Sender: TObject);
begin
  RzEdit2.Text := '*';
end;

// XLS streams

{procedure XlsBeginStream(XlsStream: TStream; const BuildNumber: Word);
begin
  CXlsBof[4] := BuildNumber;
  XlsStream.WriteBuffer(CXlsBof, SizeOf(CXlsBof));
end;

procedure XlsEndStream(XlsStream: TStream);
begin
  XlsStream.WriteBuffer(CXlsEof, SizeOf(CXlsEof));
end;

procedure XlsWriteCellRk(XlsStream: TStream; const ACol, ARow: Word;
  const AValue: Integer);
var
  V: Integer;
begin
  CXlsRk[2] := ARow;
  CXlsRk[3] := ACol;
  XlsStream.WriteBuffer(CXlsRk, SizeOf(CXlsRk));
  V := (AValue shl 2) or 2;
  XlsStream.WriteBuffer(V, 4);
end;

procedure XlsWriteCellNumber(XlsStream: TStream; const ACol, ARow: Word;
  const AValue: Double);
begin
  CXlsNumber[2] := ARow;
  CXlsNumber[3] := ACol;
  XlsStream.WriteBuffer(CXlsNumber, SizeOf(CXlsNumber));
  XlsStream.WriteBuffer(AValue, 8);
end;

procedure XlsWriteCellLabel(XlsStream: TStream; const ACol, ARow: Word;
  const AValue: string);
var
  L: Word;
begin
  L := Length(AValue);
  CXlsLabel[1] := 8 + L;
  CXlsLabel[2] := ARow;
  CXlsLabel[3] := ACol;
  CXlsLabel[5] := L;
  XlsStream.WriteBuffer(CXlsLabel, SizeOf(CXlsLabel));
  XlsStream.WriteBuffer(Pointer(AValue)^, L);
end;     }

procedure QueryToExcelCSV(kind : byte);
var
  i, cr, j, n, Code, st : Integer;
  loDT, hiDT  : TDateTime;
  s           : string;
  OperBegin, OperEnd : TTimeStamp;
  Total       : LongWord;
  CSVf        : TStringList;
begin
  st := 0;     // накопление
  if not form1.SaveDialog1.Execute then exit;
  CSVf := TStringList.Create;

  if kind = 0 then
    CSVf.Add('Документ :' + ';' + 'Тип :' + ';' + 'Хост :' + ';' + 'Пользователь :'  + ';' + 'Страниц :'  + ';' +
     'Время :'  + ';' + 'В работе :' + ';' + 'Принтер :');
  if kind = 1 then
    CSVf.Add('Документ :' + ';' + 'Тип :' + ';' + 'Хост :' + ';' + 'Пользователь :'  + ';' + 'Страниц :'  + ';' +
     'Увеличение Страниц :'  + ';' + 'Время :'  + ';' + 'В работе :' + ';' + 'Принтер :');

  CSVf.Add('');

  s := DateToStr(form1.RzDateTimePicker1.date);
  s := s + TimeToStr(form1.RzDateTimePicker2.time);
  loDT := StrToDateTime(s);
  s := DateToStr(form1.RzDateTimePicker3.date);
  s := s + TimeToStr(form1.RzDateTimePicker4.time);
  hiDT := StrToDateTime(s);

  OperBegin := DateTimeToTimeStamp(Now);
  for j := 0 to form1.RzCheckList1.Items.Count - 1 do
    if form1.RzCheckList1.ItemState[j] = cbChecked then
      begin

        form1.RzProgressBar1.Visible := true;
        form1.RzProgressBar1.Percent := 0;
        pFile := TFileStream.Create(workDir + form1.RzCheckList1.Items[j], fmShareDenyRead);
        cr := Round(pFile.Size / SizeOf(FPRN_Rec));
        MainStMess('Обработка запроса (' + IntToStr(j + 1) + '|' + IntToStr(form1.RzCheckList1.Items.Count) + ') : ');
        for i := 1 to cr do
          begin
            pFile.Read(FPRN_Rec,SizeOf(FPRN_Rec));
       // проверка условий запроса
            if not PaternCmpr(form1.RzEdit5.Text, printersList.strings[FPRN_Rec.prnIndex]) or
               not PaternCmpr(form1.RzEdit3.Text, UsersList.strings[FPRN_Rec.UserIndex])   or
               not PaternCmpr(form1.RzEdit4.Text, HostsList.strings[FPRN_Rec.HostIndex]) or
               not PaternCmpr(form1.RzEdit1.Text, FPRN_Rec.Doc) then continue;

            if ((form1.RzImageComboBox1.ItemIndex = 1) and (FPRN_Rec.DocType <> 'SYS')) or
               ((form1.RzImageComboBox1.ItemIndex = 3) and (FPRN_Rec.DocType <> 'R/3')) or
               ((form1.RzImageComboBox1.ItemIndex = 4) and (FPRN_Rec.DocType <> 'DOC')) or
               ((form1.RzImageComboBox1.ItemIndex = 5) and (FPRN_Rec.DocType <> 'XLS')) or
               ((form1.RzImageComboBox1.ItemIndex = 2) and (FPRN_Rec.DocType <> '---')) then continue;

        // проверка диапазона времени

            if form1.RadioButton2.Checked then // не любое время
              if not ((loDT <= FPRN_Rec.DateTime)  and
                      (hiDT >= FPRN_Rec.DateTime)) then
                      continue;
        // проверка диапазона страниц
            s := form1.RzEdit2.Text;
            if s <> '*' then
              if s[1] = '>' then
                begin
                  Delete(s, 1, 1);
                  Val(s, n, Code);
                  if not (n < FPRN_Rec.Pages) then continue;
                end
              else
                if s[1] = '<' then
                  begin
                    Delete(s, 1, 1);
                    Val(s, n, Code);
                    if not (n > FPRN_Rec.Pages) then continue;
                  end
                else
                  begin
                    Val(s, n, Code);
                    if n <> FPRN_Rec.Pages then continue;
                  end;

            st := st + FPRN_Rec.Pages; // накопление страниц

            if kind = 0 then
              CSVf.Add(FPRN_Rec.Doc + ';' + FPRN_Rec.DocType + ';' + HostsList.Strings[FPRN_Rec.HostIndex]  + ';' +
                UsersList.Strings[FPRN_Rec.UserIndex] + ';' + IntToStr(FPRN_Rec.Pages) + ';' + FormatDateTime('dd.mm.yy hh:mm:ss', FPRN_Rec.DateTime) + ';' +
                TimeToStr(FPRN_Rec.SpoolWork) + ';' + PrintersList.Strings[FPRN_Rec.prnIndex]);
            if kind = 1 then
              CSVf.Add(FPRN_Rec.Doc + ';' + FPRN_Rec.DocType + ';' + HostsList.Strings[FPRN_Rec.HostIndex]  + ';' +
                UsersList.Strings[FPRN_Rec.UserIndex] + ';' + IntToStr(FPRN_Rec.Pages) + ';' + IntToStr(st) + ';' +
                FormatDateTime('hh:mm:ss', FPRN_Rec.DateTime) + ';' + TimeToStr(FPRN_Rec.SpoolWork) + ';' +
                PrintersList.Strings[FPRN_Rec.prnIndex]);

            form1.RzProgressBar1.Percent :=  round(i * (100/cr));
          end;
        form1.RzProgressBar1.Visible := false;
        MainStMess('Режим ожидания запроса');
        pFile.Free;
      end;
  CSVf.SaveToFile(form1.SaveDialog1.FileName);
  CSVf.Destroy;
  OperEnd := DateTimeToTimeStamp(Now); {запоминается момент окончания операции}
  Total := OperEnd.Time - OperBegin.Time;
  form1.RzStatusPane4.Caption := TimeToStr(total);
end;

procedure TForm1.RzToolButton3Click(Sender: TObject);
begin
  QueryToExcelCSV(0);
end;

procedure TForm1.RzToolButton4Click(Sender: TObject);
begin
  QueryToExcelCSV(1);
end;

end.
