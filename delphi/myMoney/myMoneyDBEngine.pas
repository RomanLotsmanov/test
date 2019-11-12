unit myMoneyDBEngine;

interface

uses Classes, SysUtils, Dialogs, Forms, TransactionAdd, DateUtils, Controls, Windows;

const
//-- Имена фала индексов
   AccountFileName    = 'Account.idx';
   CurrencyFileName   = 'Currency.idx';
   CategoryFileName   = 'Category.idx';
   PersonaFileName    = 'Persona.idx';
   ContractorFileName = 'Contractor.idx';
   EventFileName      = 'Event.idx';
   StandardFileName   = 'StdItems.idx';
   AutoFileName       = 'Auto.dat';
   DescriptionFileName = 'Descr.idx';
   DescriptionFileName1 = 'Descr1.idx';
   DescriptionFileName2 = 'Descr2.idx';
   CommentFileName     = 'Comment.idx';
//-- Определяем лог. файл
   LogFileName        = 'Log.log';
   maxLogLines        = 500; // максимальное кол-во сторочек лога
//-- Типы транзакций
   TALL          = 255;// все

 //-- Типы транзакций
   TUNDEFINED       = 0;  //  - неопределен;
   TSPENDING        = 1;  //  - расход
   TDEBTSPEND       = 2;  //  - заплатить по долгам
   TDEBTGIVE        = 3;  //  - дать в долг
   TWAITSPENDING    = 4;  //  - запланированнные траты
   TLOSEMONEY       = 5;  //  - потеря денег
   TTRANSFEROUT     = 6;  //  - преевод денег - деньги ушли
   TMONEYCOMPLIMENT = 7;  //  - дарим деньги

   TFREEZE          = 10; //  - заморозили отложили деньги

   TTRANSFERIN      = 11; //  - перевод денег - деньги пришли
   TINCOME          = 12; //  - доход
   TDEBTINCOME      = 13; //  - взять в долг
   TDEBTRETURN      = 14; //  - нам вернули долг
   TWAITINCOME      = 15; //  - отложенный доход
   TSELLMONEY       = 16; //  - продали что либо
   TMONEYPRESENT    = 17; //  - нам подарили деньги
   TFINDMONEY       = 18; //  - нашли на улице
   TMONEYBACK       = 19; //  - возврат денег по возврату товара

   TLOSE            = 20; //  - сломалось вышло из строя списать
   TPRESENT         = 21; //  - мы подарили то что ранее купили
   TWARRIANTY       = 22; //  - находиться в гарантии
   TRENT            = 23; //  - находиться в аренде

   TDELETE          = 255; // - Удалено

//-- Типы измерений
   MNUMBER          = 0;
   MSERVICE         = 1;
   MPACK            = 2;

   MLITRE           = 3;
   MMLITRE          = 4;

   MKILOGRAM        = 5;
   MGRAM            = 6;
   MMGRAM           = 7;

   MMETER           = 8;
   MSMETER          = 9;
   MKMETER          = 10;

   MCUBICMETER      = 11;
   MSQUAREMETER     = 12;

   MMINUTE          = 13;
   MHOURS           = 14;
   MDAY             = 15;
   MWEEK            = 16;
   MMONTH           = 17;
   MYEAR            = 18;

   QUALITY          = 19;



//-- Константы на тип операции
   ACCOUNT_INDEX    = 0;
   Currency_INDEX   = 1;
   CATEGORY_INDEX   = 2;
   PERSONA_INDEX    = 3;
   CONTRACTOR_INDEX = 4;
   EVENT_INDEX      = 5;

   ID_INCOMING      = 0;
   ID_SPEND         = 1;
   ID_DEBT          = 3;
   ID_TRANSFER      = 4;
   ID_INDEX         = 5;
   ID_REC           = 6;
   ID_BILL          = 7;

type
  TDescription = packed record     // 3-ной индекс  Name="Название" Series="Серия" Brand="Марка"
    Name    : Integer;
    Brand   : Integer;
    Series  : Integer;
  end;

  TFinancyTransaction = packed record
    Account         : Word;         // Счет - ссылка на файл индексов СЧЕТА
    Date            : TDateTime;    // Дата время операции
     EndDate        : TDateTime;    // запланированная дата
    Flag            : Byte;         // Тип транзакции
    Price           : Extended;     // Цена
     price2         : Extended;     // для диапазона цен
    Number          : Extended;     // Количество
    Discount        : Extended;     // Скидка
    AbsProc         : Boolean;      // Абсолютные ли проценты
    Summ            : Extended;     // Сумма транзакции = (Price * Number) - Discount
    Currency        : Word;         // Валюта - ссылка на файл индексов ВАЛЮТ
    Category        : Word;         // Категория - ссылка на файл индексов КАТЕГОРИЙ
    Description     : TDescription; // Описание    !!!
    Persona         : Word;         // Персона - ссылка на файл индексов ПЕРСОНА
    Comment         : Word;         // Коментарий
    Contractor      : Integer;      // Контрагент - ссылка на файл индексов КОНТРАГЕНТЫ
    Event           : Integer;      // Событие - Ссылка на файл индексов СОБЫТИЯ
    BillNumber      : Integer;      // Номер чека для привязки по чекам    - если 0 то чека нет одиночная транзакция
    IDkey           : Integer;      // Уникальный ID номер
    Measure         : Integer;      // Еденица измерения
    Priority        : Byte;         // приоритет 255 макс.
    Packing         : Word;         // упаковка (кол-во пакетиков) default=1
  end;

  PTFinancyTransaction = ^TFinancyTransaction;

  TItemNode = record
    ID              : Integer;
    TType           : Byte;
  end;

  PItemNode = ^TItemNode;
var
//-- Имена файлов Программы
  AccountIndexFile       : string;
  CurrencyIndexFile      : string;
  CategoryIndexFile      : string;
  PersonaIndexFile       : string;
  ContractorIndexFile    : string;
  EventIndexFile         : string;
  MainDBFile             : string;
  LogFile                : string;
  BackUpDBFile           : string;
  StandardIndexFile      : string;
  AutoDBFile             : string;
  NotesIndexFile         : string;
  DescriptionIndexFile   : string;
  DescriptionIndexFile1  : string;
  DescriptionIndexFile2  : string;
  CommentIndexFile       : string;
//-- Списки основных индексов программы
  AccountList            : TStringList;
  CurrencyList           : TStringList;
  CategoryList           : TStringList;
  PersonaList            : TStringList;
  ContractorList         : TStringList;
  EventList              : TStringList;
  StandardList           : TStringList;
  NotesList              : TStringList;
  CommentList            : TStringList;
  DescriptionNameList    : TStringList;  // вначале используем только его
  DescriptionSeriesList  : TStringList;
  DescriptionBrandList   : TStringList;
//-- Поток лога
  LogList                : TStringList;
  StartStream            : TStringList;
//-- Директории программы
  ProgramWorkDir         : string;
  DBWorkDir              : string;
//-- Файл БД
  DBFile                 : TFileStream;
  BBFile                 : TFileStream;
  AutoFile               : TFileStream;
//-- Обьект записи
  FinancyTransaction     : TFinancyTransaction;  // основная рабочая переменная
  CFinancyTransaction    : TFinancyTransaction;  // переменная для копирования не используется
  TempFinancyTransaction : TFinancyTransaction;  // временная переменная
  PFinancyFtansaction    : PTFinancyTransaction;
  DBIndex                : Integer;
  FTList                 : TList;       // для построения списка обьектов TFinancyTransaction  в памяти


procedure AddLogStr(s : string);
function Finish : Boolean;
function LoadLog : boolean;
//-- Парсеры конструкций строк
function ImageIndexGetIndex(Line : string) : Integer;
function ImageIndexSetIndex(Line : string; index : Integer) : String;
function ImageIndexGetString(Line : string) : String;
function GetSubElementsCount(Line : string) : Integer;
function GetMainString(Line : string) : String;
function GetSubString(Line : string; n : Integer) : string;
function SetSubString(Line, SubStr : string) : string;
function ReplaceSubString(Line, SubStr : string) : string;
procedure ClearFinancyTransactionRec;
//-- Работа с БД
function LoadIndex : Boolean;
function TransactionGetCount : Integer;
function TransactionSave(Position : integer) : Boolean;
function TransactionRead(Position : integer) : Boolean;
function TransactionChangeByBill(Contactor, Account, Bill : Word; DDate : TDateTime) : Boolean;
function TransactionDelete(Position : integer) : Boolean;
function TransactionChangeIndex(Index, iType : integer; Add : boolean) : Boolean;
function TransactionGetMaxBillNumber : Integer;
function TransactionGetMaxIDKey : Integer;
function TransactionGetPositionByID(id : Integer) : Integer;
function TransactionDoBackUp : Boolean;
function TransactionSaveDB : Boolean;
function LoadDB : boolean;
procedure SaveStandardItem(Item : string);
function CheckDB : Boolean;
procedure RestoreDB;

//-- Конвертируем ДБ в новый формат
//procedure ConvertDB;

procedure AutoAdd;
procedure AutoRead(position : Integer);
function AutoGetCount : Integer;

function TryOpenFile(FileName : string; createNew : Boolean) : Boolean;
procedure CriticalExit;
function DateCompare(Item1, Item2: Pointer): Integer;

//-- аналитика
function Totalbalance(cellDate : TDate) : extended;
function GetTotalSummByIndex(Index, IndexType : integer; StartDate, EndDate : TDateTime) : Extended;
//function GetTotalSumm(incoming : Boolean; StartDate, EndDate : TDateTime) : Extended;
function GetTotalSummByType(Flag: byte; StartDate, EndDate : TDate) : Extended;
function GetMinDate : TDate;
function GetMaxDate : TDate;

function MoneyFormat(Money : Extended) : string;
function GetCurrentUserName : string;
function GetComputerNetName : string;

procedure ClearNotUsedDescription;

implementation

uses Splash, Options, mainForm, Math;


function GetCurrentUserName : string;
var
  UserName : string;
  UserNameLen : Dword;
begin
  UserNameLen := 255;
  SetLength(userName, UserNameLen);
  if GetUserName(PChar(UserName), UserNameLen) then
    Result := Copy(UserName,1,UserNameLen - 1)
  else
    Result := '';
end;

function GetComputerNetName: string;
var
  buffer: array[0..255] of char;
  size: dword;
begin
  size := 256;
  if GetComputerName(buffer, size) then
    Result := buffer
  else
    Result := ''
end;

procedure ClearNotUsedDescription;
var
  i, j, n : Integer;
  ok      : Boolean;
begin
  i := 1;
  n := DescriptionNameList.Count - 1;
  while i < n do
    begin
      ok := False;
      for j := 0 to FTList.Count - 1 do
        if PTFinancyTransaction(FTList.Items[j]).Description.Name = i then
          begin
            ok := true;
            Break;
          end;
      if not ok then
        begin
          DescriptionNameList.Delete(i);
          for j := 0 to FTList.Count - 1 do
            if PTFinancyTransaction(FTList.Items[j]).Description.Name > i then
              PTFinancyTransaction(FTList.Items[j]).Description.Name := PTFinancyTransaction(FTList.Items[j]).Description.Name - 1;
          Dec(n);
          Dec(i);
        end;
      inc(i);
    end;

  i := 1;
  n := DescriptionBrandList.Count - 1;
  while i < n do
    begin
      ok := False;
      for j := 0 to FTList.Count - 1 do
        if PTFinancyTransaction(FTList.Items[j]).Description.Brand = i then
          begin
            ok := true;
            Break;
          end;
      if not ok then
        begin
          DescriptionBrandList.Delete(i);
          for j := 0 to FTList.Count - 1 do
            if PTFinancyTransaction(FTList.Items[j]).Description.Brand > i then
              PTFinancyTransaction(FTList.Items[j]).Description.Brand := PTFinancyTransaction(FTList.Items[j]).Description.Brand - 1;
          Dec(n);
          Dec(i);
        end;
      inc(i);
    end;

  i := 1;
  n := DescriptionSeriesList.Count - 1;
  while i < n do
    begin
      ok := False;
      for j := 0 to FTList.Count - 1 do
        if PTFinancyTransaction(FTList.Items[j]).Description.Series = i then
          begin
            ok := true;
        //    Break;
          end;
      if not ok then
        begin
          DescriptionSeriesList.Delete(i);
          for j := 0 to FTList.Count - 1 do
            if PTFinancyTransaction(FTList.Items[j]).Description.Series > i then
              PTFinancyTransaction(FTList.Items[j]).Description.Series := PTFinancyTransaction(FTList.Items[j]).Description.Series - 1;
          Dec(n);
          Dec(i);
        end;
      inc(i);
    end;
end;

//-- Форматирование суммы 3   150,5   123,454   к виду 150,50
function MoneyFormat(Money : Extended) : string;
begin
  Money := RoundTo(Money, RoundN);
  Result := FloatToStr(Money);
  if Pos(',', Result) = 0 then Result := Result + ',00';
  if Pos(',', Result) = Length(Result) - 1 then Result := Result + '0';
end;

//-- Критический выход
procedure CriticalExit;
begin
  AddLogStr('АВАРИЯ движка БД');
  Application.Terminate;
end;

//-- Сравнение дат  ???{ TODO -orom -cслужебные функции : где используеться почему нестандартным способом }
function DateCompare(Item1, Item2: Pointer): Integer;
begin
  if PTFinancyTransaction(Item1)^.Date > PTFinancyTransaction(Item2)^.Date then
    Result :=1
  else
    if PTFinancyTransaction(Item1)^.Date = PTFinancyTransaction(Item2)^.Date then
      Result :=0
    else
      Result := -1;
end;

//-- Очистка всех полей
procedure ClearFinancyTransactionRec;
begin
  FinancyTransaction.Account := 0;
  FinancyTransaction.Date := Now;
  FinancyTransaction.Flag := TSPENDING;
  FinancyTransaction.Price := 0;
  FinancyTransaction.Number := 1;       // !!!
  FinancyTransaction.Discount := 0;
  FinancyTransaction.AbsProc := False;
  FinancyTransaction.Summ := 0;
  FinancyTransaction.Currency := 0;
  FinancyTransaction.Category := 0;
  FinancyTransaction.Description.Name := 0;
  FinancyTransaction.Description.Brand := 0;
  FinancyTransaction.Description.Series := 0;
  FinancyTransaction.Persona:= 0;
  FinancyTransaction.Comment := 0;
  FinancyTransaction.Contractor := 0;
  FinancyTransaction.Event := 0;
  FinancyTransaction.BillNumber := 0;
  FinancyTransaction.IDkey := -1;
  FinancyTransaction.Measure := MNUMBER; // количество
  FinancyTransaction.Packing := 1;
  FinancyTransaction.price2 := 0;
  FinancyTransaction.Priority := 100;
  FinancyTransaction.EndDate := Now;
end;


//-- Инициализируем поток лога и загружаем файл
function LoadLog : boolean;
begin
  LogFile := ProgramWorkDir + LogFileName;
  LogList := TStringList.Create;        // создаем поток логов
  if FileExists(LogFile) then LogList.LoadFromFile(LogFile);
end;


//-- Сохранение лог потока и его уничтожение из памяти
function SaveLog : boolean;
begin
  try
    LogList.SaveToFile(LogFile);
  finally
    LogList.Free;
  end;
end;


//-- Добавляем строку в лог поток с указанием даты и времени, контролируем лимит лог файла.
procedure AddLogStr(s : string);
begin
  if LogList.Count > maxLogLines then
      LogList.Clear
   else
     LogList.Add(DateToStr(now) + ' ' + TimeToStr(Time) + '   ' + s);
end;


//-- Проверка доступа к файлу
function TryOpenFile(FileName : string; createNew : Boolean) : Boolean;
var
  buff   : Byte;
  ZZFile : TFileStream;
begin
{I-}
  Result := False;
  if FileExists(FileName) then
    repeat
      try
        if createNew then
          ZZFile := TFileStream.Create(FileName, fmCreate)
        else
          ZZFile := TFileStream.Create(FileName, fmOpenReadWrite or fmShareExclusive);
        if ZZFile.Size > 0 then
          begin
            ZZFile.Read(buff, 1);
            ZZFile.Seek(0, soFromBeginning);
            ZZFile.Write(buff, 1)
          end
        else
          begin
            buff := 255;
            ZZFile.Write(buff, 1);
            ZZFile.Size := 0;
          end;
        ZZFile.Free;
        Result := True;
      except
        on EFCreateError do
          begin
            AddLogStr('Ошибка доступа к файлу ' + FileName + ' файл уже открыт');
            if MessageDlg('Ошибка доступа к файлу ' + FileName + ', файл открыт в другой программе! Такое бывает при работе антивирусов, или программ синхронизации. Попробуйте повторить попытку спустя минуту', mtError, [mbRetry, mbAbort], 0) = 3 then exit;
          end;
        on EFOpenError do
          begin
            AddLogStr('Ошибка доступа к файлу ' + FileName + ' файл уже открыт');
            if MessageDlg('Ошибка доступа к файлу ' + FileName + ', файл открыт в другой программе! Такое бывает при работе антивирусов, или программ синхронизации. Попробуйте повторить попытку спустя минуту', mtError, [mbRetry, mbAbort], 0) = 3 then exit;
          end;
      end;
    until Result
  else
    Result := True;
{I+}
end;


//-- Загружаем индексные файлы
function LoadIndex : Boolean;
var
  i : Integer;
begin
  Result := True;
  AccountList := TStringList.Create;       //-- Загружаем список счетов, если их нет обязательно вызываем мастер для их заполнения
  AccountList.Duplicates := dupIgnore;
  if FileExists(AccountIndexFile) then
    begin
      if not TryOpenFile(AccountIndexFile, false) then
        begin
          AddLogStr('Проблема при загрузке файла индексов, файл не занружен ' + AccountIndexFile);
          Result := False;
        end
      else
        begin
          AccountList.LoadFromFile(AccountIndexFile);
          AddLogStr('Список счетов загружен из файла ' + AccountIndexFile);
          AddLogStr('Загружены счета :');
          for i := 0 to AccountList.Count - 1 do
            AddLogStr('   ' + AccountList.Strings[i]);
        end;
    end
  else
    begin
      AddLogStr('Список счетов пуст - готов к заполнению');
      CategoryList.Add('4:Бумажник');
    end;
  SplashString('Список счетов загружен', 9, 100);
  CurrencyList := TStringList.Create;
  CurrencyList.Duplicates := dupIgnore;
  if FileExists(CurrencyIndexFile) then
    begin
      if not TryOpenFile(CurrencyIndexFile, false) then
        begin
          AddLogStr('Проблема при загрузке файла индексов, файл не загружен ' + CurrencyIndexFile);
          Result := False;
        end
      else
        begin
           CurrencyList.LoadFromFile(CurrencyIndexFile);
           AddLogStr('Список валют загружен из файла ' + CurrencyIndexFile);
           AddLogStr('   загружено ' + IntToStr(CurrencyList.Count) + ' валют');
           AddLogStr('Загружены валюты :');
           for i := 0 to CurrencyList.Count - 1 do
              AddLogStr('   ' + CurrencyList.Strings[i]);
        end;
    end
  else
    begin
      AddLogStr('Добавлена валюта по умолчанию - Рубли РФ');
      CurrencyList.Add('0:RUB Рубли РФ');
      Exit;
    end;
  SplashString('Список валют загружен', 11, 100);
  CategoryList := TStringList.Create;      //-- Загружаем файл категорий, если есть
  CategoryList.Duplicates := dupIgnore;
  if FileExists(CategoryIndexFile) then
    begin
      if not TryOpenFile(CurrencyIndexFile, false) then
        begin
          AddLogStr('Проблема при загрузке файла индексов, файл не загружен ' + CurrencyIndexFile);
          Result := False;
        end
      else
        begin
          CategoryList.LoadFromFile(CategoryIndexFile);
          if CategoryList.Count = 0  then
            CategoryList.Add('0:Нет')   //-- Первая строка всегда должна быть такой
          else
            if CategoryList[0] <> '0:Нет' then  CategoryList.Insert(0, '0:Нет');
          AddLogStr('Список категорий загружен из файла ' + CategoryIndexFile);
          AddLogStr('   загружено ' + IntToStr(CategoryList.Count) + ' категорий');
        end;
    end
  else
    begin
      CategoryList.Add('0:Нет');
      AddLogStr('Список категорий пуст - готов к заполнению');
    end;
  SplashString('Список категорий', 25, 100);
  PersonaList := TStringList.Create;            //-- Загружаем список персон если нет добавляем одну ОБЩЕЕ
  PersonaList.Duplicates := dupIgnore;
  PersonaList.CaseSensitive := False;
  if FileExists(PersonaIndexFile) then
    begin
      if not TryOpenFile(PersonaIndexFile, false) then
        begin
          AddLogStr('Проблема при загрузке файла индексов, файл не загружен ' + PersonaIndexFile);
          Result := False;
        end
      else
        begin
          PersonaList.LoadFromFile(PersonaIndexFile);
          if PersonaList.Count = 0  then
            PersonaList.Add('0:Общее')   //-- Первая строка всегда должна быть такой
          else
            if PersonaList[0] <> '0:Общее' then  PersonaList.Insert(0, '0:Общее');
          AddLogStr('Список персон загружен из файла ' + PersonaIndexFile);
          AddLogStr('   загружено ' + IntToStr(PersonaList.Count) + ' персоны');
        end;
    end
  else
    begin
      AddLogStr('Список персон пуст - готов к заполнению');
      PersonaList.Add('0:Общее');
    end;
  SplashString('Список персон загружен', 27, 100);
  ContractorList := TStringList.Create;        //-- Загружаем список контрагентов, если есть
  ContractorList.Duplicates := dupIgnore;
  ContractorList.CaseSensitive := False;
  if FileExists(ContractorIndexFile) then
    begin
      if not TryOpenFile(ContractorIndexFile, false) then
        begin
          AddLogStr('Проблема при загрузке файла индексов, файл не загружен ' + ContractorIndexFile);
          Result := False;
        end
      else
        begin
          ContractorList.LoadFromFile(ContractorIndexFile);
          if ContractorList.Count = 0  then
            ContractorList.Add('0:Нет')   //-- Первая строка всегда должна быть такой
          else
            if ContractorList[0] <> '0:Нет' then  ContractorList.Insert(0, '0:Нет');
          AddLogStr('Список контрагентов загружен из файла ' + ContractorIndexFile);
          AddLogStr('   загружено ' + IntToStr(ContractorList.Count) + ' контрагента');
        end;
    end
  else
    begin
      ContractorList.Add('0:Нет');
      AddLogStr('Список контрагентов пуст - готов к заполнению');
    end;
  SplashString('Список контрагентов загружен', 32, 100);
  EventList := TStringList.Create;     //-- Загружаем список событий, если есть
  EventList.Duplicates := dupIgnore;
  EventList.CaseSensitive := False;
  if FileExists(EventIndexFile) then
    begin
      if not TryOpenFile(EventIndexFile, false) then
        begin
          AddLogStr('Проблема при загрузке файла индексов, файл не загружен ' + EventIndexFile);
          Result := False;
        end
      else
        begin
          EventList.LoadFromFile(EventIndexFile);
          if EventList.Count = 0  then
            EventList.Add('0:Нет')   //-- Первая строка всегда должна быть такой
          else
            if EventList[0] <> '0:Нет' then  EventList.Insert(0, '0:Нет');
          AddLogStr('Список событий загружен из файла ' + EventIndexFile);
          AddLogStr('   загружено ' + IntToStr(EventList.Count) + ' события');
        end;
    end
  else
    begin
      EventList.Add('0:Нет');
      AddLogStr('Список событий пуст - готов к заполнению');
    end;

  SplashString('Список стандартных товаров загружен', 40, 100);
  StandardList := TStringList.Create;
  StandardList.Duplicates := dupIgnore;
  if FileExists(StandardIndexFile) then
    begin
      if not TryOpenFile(StandardIndexFile, false) then
        begin
          AddLogStr('Проблема при загрузке файла индексов, файл не загружен ' + StandardIndexFile);
          Result := False;
        end
      else
        begin
          StandardList.LoadFromFile(StandardIndexFile);
          AddLogStr('Список стандартных товаров из файла ' + StandardIndexFile);
          AddLogStr('   загружено ' + IntToStr(StandardList.Count) + ' товаров');
        end;
    end
  else
    AddLogStr('Список стандартных товаров пуст - готов к заполнению');
  StandardList.Sort;
  SplashString('Список стандарных товаров загружен', 45, 100);
  NotesList := TStringList.Create;
  NotesList.Duplicates := dupIgnore;
  if FileExists(NotesIndexFile) then
    begin
      if not TryOpenFile(NotesIndexFile, false) then
        begin
          AddLogStr('Проблема при загрузке файла индексов, файл не загружен ' + NotesIndexFile);
          Result := False;
        end
      else
        begin
          NotesList.LoadFromFile(NotesIndexFile);
          AddLogStr('Список заметок из файла ' + NotesIndexFile);
          AddLogStr('   загружено ' + IntToStr(NotesList.Count) + ' заметок');
        end;
    end
  else
    AddLogStr('Список заметок пуст - готов к заполнению');
  StandardList.Sort;
  SplashString('Список заметок загружен', 55, 100);

  CommentList := TStringList.Create;
  CommentList.Duplicates := dupIgnore;
  CommentList.CaseSensitive := False;
  if FileExists(CommentIndexFile) then
    begin
      if not TryOpenFile(CommentIndexFile, false) then
        begin
          AddLogStr('Проблема при загрузке файла индексов, файл не загружен ' + CommentIndexFile);
          Result := False;
        end
      else
        begin
          CommentList.LoadFromFile(CommentIndexFile);
          AddLogStr('Список коментариев из файла ' + CommentIndexFile);
          AddLogStr('   загружено ' + IntToStr(CommentList.Count) + ' коментариев');
        end;
    end
  else
    begin
      CommentList.Add('');
      AddLogStr('Список коментариев пуст - готов к заполнению');
    end;
  SplashString('Список коментариев загружен', 65, 100);
  if CommentList[0] <> '' then  CommentList.Insert(0, '');

  DescriptionNameList := TStringList.Create;
  DescriptionNameList.Duplicates := dupIgnore;
  DescriptionNameList.CaseSensitive := False;
  if FileExists(DescriptionIndexFile) then
    begin
      if not TryOpenFile(DescriptionIndexFile, false) then
        begin
          AddLogStr('Проблема при загрузке файла индексов, файл не загружен ' + DescriptionIndexFile);
          Result := False;
        end
      else
        begin
          DescriptionNameList.LoadFromFile(DescriptionIndexFile);
          AddLogStr('Список описаний из файла ' + DescriptionIndexFile);
          AddLogStr('   загружено ' + IntToStr(DescriptionNameList.Count) + ' описаний');
        end;
    end
  else
     AddLogStr('Список описаний пуст - готов к заполнению');
  SplashString('Список описаний загружен', 75, 100);
  if DescriptionNameList.Count = 0 then
    DescriptionNameList.Add('');
  if DescriptionNameList[0] <> '' then
    DescriptionNameList.Insert(0, '');

  DescriptionBrandList := TStringList.Create;
  DescriptionBrandList.Duplicates := dupIgnore;
  DescriptionBrandList.CaseSensitive := False;
  if FileExists(DescriptionIndexFile1) then
    begin
      if not TryOpenFile(DescriptionIndexFile1, false) then
        begin
          AddLogStr('Проблема при загрузке файла индексов, файл не загружен ' + DescriptionIndexFile1);
          Result := False;
        end
      else
        begin
          DescriptionBrandList.LoadFromFile(DescriptionIndexFile1);
          AddLogStr('Список производителей из файла ' + DescriptionIndexFile1);
          AddLogStr('   загружено ' + IntToStr(DescriptionBrandList.Count) + ' производителей');
        end;
    end
  else
     AddLogStr('Список производителей пуст - готов к заполнению');
  SplashString('Список описаний загружен', 85, 100);
  if DescriptionBrandList.Count = 0 then
    DescriptionBrandList.Add('');
  if DescriptionBrandList[0] <> '' then
    DescriptionBrandList.Insert(0, '');


  DescriptionSeriesList := TStringList.Create;
  DescriptionSeriesList.Duplicates := dupIgnore;
  DescriptionSeriesList.CaseSensitive := False;
  if FileExists(DescriptionIndexFile2) then
    begin
      if not TryOpenFile(DescriptionIndexFile2, false) then
        begin
          AddLogStr('Проблема при загрузке файла индексов, файл не загружен ' + DescriptionIndexFile2);
          Result := False;
        end
      else
        begin
          DescriptionSeriesList.LoadFromFile(DescriptionIndexFile2);
          AddLogStr('Список описаний серий из файла ' + DescriptionIndexFile2);
          AddLogStr('   загружено ' + IntToStr(DescriptionSeriesList.Count) + ' серий');
        end;
    end
  else
     AddLogStr('Список описаний пуст - готов к заполнению');
  if DescriptionSeriesList.Count = 0 then
    DescriptionSeriesList.Add('');
  if DescriptionSeriesList[0] <> '' then
    DescriptionSeriesList.Insert(0, '');
  SplashString('Список описаний загружен', 75, 100);

  Result := True;
end;


//-- Сохранение индексов и освобождение памяти
function SaveIndex : Boolean;
begin
  Result := True;
  try
    if not TryOpenFile(AccountIndexFile, true) then
      begin
        AddLogStr('Проблема при сохранении файла индексов, файл не сохранен ' + AccountIndexFile);
        Result := False;
      end
    else
      AccountList.SaveToFile(AccountIndexFile);
    if not TryOpenFile(CurrencyIndexFile, true) then
      begin
        AddLogStr('Проблема при сохранении файла индексов, файл не сохранен ' + CurrencyIndexFile);
        Result := False;
      end
    else
      CurrencyList.SaveToFile(CurrencyIndexFile);
    if not TryOpenFile(CategoryIndexFile, true) then
      begin
        AddLogStr('Проблема при сохранении файла индексов, файл не сохранен ' + CategoryIndexFile);
        Result := False;
      end
    else
      CategoryList.SaveToFile(CategoryIndexFile);
    if not TryOpenFile(PersonaIndexFile, true) then
      begin
        AddLogStr('Проблема при сохранении файла индексов, файл не сохранен ' + PersonaIndexFile);
        Result := False;
      end
    else
      PersonaList.SaveToFile(PersonaIndexFile);
    if not TryOpenFile(ContractorIndexFile, true) then
      begin
        AddLogStr('Проблема при сохранении файла индексов, файл не сохранен ' + ContractorIndexFile);
        Result := False;
      end
    else
      ContractorList.SaveToFile(ContractorIndexFile);
    if not TryOpenFile(EventIndexFile, true) then
      begin
        AddLogStr('Проблема при сохранении файла индексов, файл не сохранен ' + EventIndexFile);
        Result := False;
      end
    else
      EventList.SaveToFile(EventIndexFile);

    if not TryOpenFile(CommentIndexFile, true) then
      begin
        AddLogStr('Проблема при сохранении файла индексов, файл не сохранен ' + CommentIndexFile);
        Result := False;
      end
    else
      CommentList.SaveToFile(CommentIndexFile);

    if not TryOpenFile(DescriptionIndexFile, true) then
      begin
        AddLogStr('Проблема при сохранении файла индексов, файл не сохранен ' + DescriptionIndexFile);
        Result := False;
      end
    else
      DescriptionNameList.SaveToFile(DescriptionIndexFile);

    if not TryOpenFile(DescriptionIndexFile1, true) then
      begin
        AddLogStr('Проблема при сохранении файла индексов, файл не сохранен ' + DescriptionIndexFile1);
        Result := False;
      end
    else
      DescriptionBrandList.SaveToFile(DescriptionIndexFile1);

    if not TryOpenFile(DescriptionIndexFile2, true) then
      begin
        AddLogStr('Проблема при сохранении файла индексов, файл не сохранен ' + DescriptionIndexFile2);
        Result := False;
      end
    else
      DescriptionSeriesList.SaveToFile(DescriptionIndexFile2);

    if not TryOpenFile(StandardIndexFile, true) then
      begin
        AddLogStr('Проблема при сохранении файла индексов, файл не сохранен ' + StandardIndexFile);
        Result := False;
      end
    else
      StandardList.SaveToFile(StandardIndexFile);
    if not TryOpenFile(NotesIndexFile, true) then
      begin
        AddLogStr('Проблема при сохранении файла индексов, файл не сохранен ' + NotesIndexFile);
        Result := False;
      end
    else
      NotesList.SaveToFile(NotesIndexFile);
  finally
    AccountList.Free;
    CurrencyList.Free;
    CategoryList.Free;
    PersonaList.Free;
    ContractorList.Free;
    EventList.Free;
    StandardList.Free;
    CommentList.Free;
    DescriptionNameList.Free;
    DescriptionBrandList.Free;
    DescriptionSeriesList.Free;
  end;
end;


//-- Извлекаем инденкс изображения из строки формата NN:Description пробелы недопустимы
function ImageIndexGetIndex(Line : string) : Integer;
begin
  Result := 0;
  Delete(Line, Pos(':', Line), Length(Line) - Pos(':', Line) + 1);
  Result := StrToInt(Line);
end;


//-- Добавляем индекс к строке
function ImageIndexSetIndex(Line : string; index : Integer) : String;
begin
  Result := IntToStr(index) + ':' + Line;
end;


//-- Отделяем строку от индекса
function ImageIndexGetString(Line : string) : String;
begin
  Delete(Line, 1, Pos(':', Line));
  Result := Line;
end;


//-- Определить присутствие субэлементов Продукты>Овощи>Картофель   (если после последнего > нет символов то он не считается)
function GetSubElementsCount(Line : string) : Integer;
var
  i : Integer;
begin
  Result := 0;
  for I := 0 to Length(Line) - 1 do
     if Line[i] = '>' then Result := Result + 1;
end;


//-- Отделяем Основной элемент от суб элементов
function GetMainString(Line : string) : String;
begin
  Delete(Line, Pos('>', Line), Length(Line) - Pos('>', Line) + 1);
  Result := Line;
end;


//-- Отделяем N-ый субэлемент  string>sub1>sub2>sub3
function GetSubString(Line : string; n : Integer) : string;
var
  i, j : Integer;
begin
  j := 0;
  //-- Подрезаем спереди
  for I := 0 to Length(Line) do
     begin
       if Line[i] = '>' then inc(j);
       if j = n then
         begin
           j := i;
           Break;
         end;
     end;
  Delete(Line, 1, j);
  //-- Подрезаем сзади
  for I := 0 to Length(Line) do
     if Line[i] = '>' then Delete(Line, i, Length(Line) - i + 1);
  Result := Line;
end;


//-- Добавить подкатегорию
function SetSubString(Line, SubStr : string) : string;
begin
  Result := Line + '>' + SubStr;
end;

//-- Замена подстроки в строке
function ReplaceSubString(Line, SubStr : string) : string;
var
  I: Integer;
begin
  for I := Length(Line) downto 0 do
     if Line[i] = '>' then Break;
  Delete(Line, i + 1, Length(Line) - i);
  Result := Line + SubStr;
end;


//-- Возвращает количество транзакций
function TransactionGetCount : Integer;
begin
  if MEM then
    begin
      Result := FTList.count;
      Exit;
    end;
  try
    DBFile := TFileStream.Create(MainDBFile, fmOpenRead);
    Result := DBFile.Size div SizeOf(FinancyTransaction);
  finally
    DBFile.Free;
  end;
end;


//-- Добавление N-ой транзакции в список
function TransactionSave(Position : integer) : Boolean;
begin
  if MEM then
    begin
      New(PFinancyFtansaction);
      with PFinancyFtansaction^ do
      begin
        Account          := FinancyTransaction.Account;
        Date             := FinancyTransaction.Date;
        EndDate          := FinancyTransaction.EndDate;
        Flag             := FinancyTransaction.Flag;
        Price            := FinancyTransaction.Price;
        price2           := FinancyTransaction.price2;
        Number           := FinancyTransaction.Number;
        Discount         := FinancyTransaction.Discount;
        AbsProc          := FinancyTransaction.AbsProc;
        Summ             := FinancyTransaction.Summ;
        Currency         := FinancyTransaction.Currency;
        Category         := FinancyTransaction.Category;
        Description      := FinancyTransaction.Description;
        Persona          := FinancyTransaction.Persona;
        Comment          := FinancyTransaction.Comment;
        Contractor       := FinancyTransaction.Contractor;
        Event            := FinancyTransaction.Event;
        BillNumber       := FinancyTransaction.BillNumber;
        IDkey            := FinancyTransaction.IDkey;
        Measure          := FinancyTransaction.Measure;
        Priority         := FinancyTransaction.Priority;
        Packing          := FinancyTransaction.Packing;
      end;
      if Position > FTList.Count - 1 then
        FTList.Add(PFinancyFtansaction)
      else
        FTList[Position] := PFinancyFtansaction;
      Exit;
    end;
  try
    if not TryOpenFile(MainDBFile, False) then
      begin
        AddLogStr('Ошибка открытия файла БД ' + MainDBFile + ' критическая ошибка');
        CriticalExit;
        Exit;
      end;
    DBFile := TFileStream.Create(MainDBFile, fmOpenWrite);
    DBFile.Seek(Position * SizeOf(FinancyTransaction), soFromBeginning);
    DBFile.Write(FinancyTransaction, SizeOf(FinancyTransaction));
  finally
    DBFile.Free;
  end;
end;


//-- Получение N-ой транзакции из списка
function TransactionRead(Position : integer) : Boolean;
begin
  Result := False;
  if MEM then
    begin
      with FinancyTransaction do
      begin
        Account          := PTFinancyTransaction(FTList.Items[Position]).Account;
        Date             := PTFinancyTransaction(FTList.Items[Position]).Date;
        EndDate          := PTFinancyTransaction(FTList.Items[Position]).EndDate;
        Flag             := PTFinancyTransaction(FTList.Items[Position]).Flag;
        Price            := PTFinancyTransaction(FTList.Items[Position]).Price;
        price2           := PTFinancyTransaction(FTList.Items[Position]).price2;
        Number           := PTFinancyTransaction(FTList.Items[Position]).Number;
        Discount         := PTFinancyTransaction(FTList.Items[Position]).Discount;
        AbsProc          := PTFinancyTransaction(FTList.Items[Position]).AbsProc;
        Summ             := PTFinancyTransaction(FTList.Items[Position]).Summ;
        Currency         := PTFinancyTransaction(FTList.Items[Position]).Currency;
        Category         := PTFinancyTransaction(FTList.Items[Position]).Category;
        Description      := PTFinancyTransaction(FTList.Items[Position]).Description;
        Persona          := PTFinancyTransaction(FTList.Items[Position]).Persona;
        Comment          := PTFinancyTransaction(FTList.Items[Position]).Comment;
        Contractor       := PTFinancyTransaction(FTList.Items[Position]).Contractor;
        Event            := PTFinancyTransaction(FTList.Items[Position]).Event;
        BillNumber       := PTFinancyTransaction(FTList.Items[Position]).BillNumber;
        IDkey            := PTFinancyTransaction(FTList.Items[Position]).IDkey;
        Measure          := PTFinancyTransaction(FTList.Items[Position]).Measure;
        Packing          := PTFinancyTransaction(FTList.Items[Position]).Packing;
        Priority         := PTFinancyTransaction(FTList.Items[Position]).Priority;
      end;
      Exit;
    end;
  try
    DBFile := TFileStream.Create(MainDBFile, fmOpenRead or  fmShareDenyWrite);
    DBFile.Seek(Position * SizeOf(FinancyTransaction), soFromBeginning);
    DBFile.Read(FinancyTransaction, SizeOf(FinancyTransaction));
  finally
    DBFile.Free;
  end;
  Result := True;
end;


//-- Удаление транзакции из списка
function TransactionDelete(Position : integer) : Boolean;
begin
  if MEM then
    begin
 {      New(PFinancyFtansaction);
       PFinancyFtansaction^.Flag := TDELETE;
       FTList[Position] := PFinancyFtansaction;}
      FTList.Delete(Position);
      Exit;
    end;
  try
    if not TryOpenFile(MainDBFile, False) then
      begin
        AddLogStr('Ошибка открытия файла БД ' + MainDBFile + ' критическая ошибка');
        CriticalExit;
        Exit;
      end;
    DBFile := TFileStream.Create(MainDBFile, fmOpenWrite);
    if Position <> (DBFile.Size div SizeOf(FinancyTransaction) - 1) then
      begin
        DBFile.Seek(SizeOf(FinancyTransaction), soFromEnd);
        DBFile.Read(FinancyTransaction, SizeOf(FinancyTransaction));
        DBFile.Seek(Position * SizeOf(FinancyTransaction), soFromBeginning);
        DBFile.Write(FinancyTransaction, SizeOf(FinancyTransaction));
      end;
    DBFile.Seek(SizeOf(FinancyTransaction), soFromEnd);
    DBFile.Size := (DBFile.Size div SizeOf(FinancyTransaction) - 1) * SizeOf(FinancyTransaction);
  finally
    DBFile.Free;
  end;
end;


//-- Изменение основных аттрибутов по всему чеку
function TransactionChangeByBill(Contactor, Account, Bill : Word; DDate : TDateTime) : Boolean;
var
  i : Integer;
begin
  if MEM then
    begin
    for i := 0 to FTList.Count - 1 do
       if PTFinancyTransaction(FTList.Items[i]).BillNumber = Bill then
         begin
           PTFinancyTransaction(FTList.Items[i]).Account := Account;
           PTFinancyTransaction(FTList.Items[i]).Date := DDate;
           PTFinancyTransaction(FTList.Items[i]).Contractor := Contactor;
//           PTFinancyTransaction(FTList.Items[i]).BillFileName;
          end
    end
  else
    begin
      try
      if not TryOpenFile(MainDBFile, False) then
      begin
        AddLogStr('Ошибка открытия файла БД ' + MainDBFile + ' критическая ошибка');
        CriticalExit;
        Exit;
      end;
      DBFile := TFileStream.Create(MainDBFile, fmOpenReadWrite);
      for I := 0 to (DBFile.Size div SizeOf(TempFinancyTransaction) - 1) do
        begin
          DBFile.Read(TempFinancyTransaction, SizeOf(TempFinancyTransaction));
          if TempFinancyTransaction.BillNumber = Bill then
            begin
              TempFinancyTransaction.Account := Account;
              TempFinancyTransaction.Date := DDate;
              TempFinancyTransaction.Contractor := Contactor;
              DBFile.Seek(i * SizeOf(TempFinancyTransaction), soFromBeginning);
              DBFile.Write(TempFinancyTransaction, SizeOf(TempFinancyTransaction));
            end;
        end;
      finally
        DBFile.Free;
      end;
    end;
end;

//-- Изменение индексов ключей в связи с редактированием одного из списка
function TransactionChangeIndex(Index, iType : integer; Add : boolean) : Boolean;
var
  i : Integer;
begin
  if MEM then
    begin
      for I := 0 to FTList.Count - 1 do
        case iType of
          ACCOUNT_INDEX:begin
                          if (PTFinancyTransaction(FTList.Items[i]).Account = Index) and (not Add) then PTFinancyTransaction(FTList.Items[i]).Account := 0;
                          if PTFinancyTransaction(FTList.Items[i]).Account > Index then
                            if Add then
                              Inc(PTFinancyTransaction(FTList.Items[i]).Account)
                            else
                              Dec(PTFinancyTransaction(FTList.Items[i]).Account);
                        end;
          Currency_INDEX:begin
                          if (PTFinancyTransaction(FTList.Items[i]).Currency = Index) and (not Add) then PTFinancyTransaction(FTList.Items[i]).Currency := 0;
                          if PTFinancyTransaction(FTList.Items[i]).Currency > Index then
                            if Add then
                              Inc(PTFinancyTransaction(FTList.Items[i]).Currency)
                            else
                              Dec(PTFinancyTransaction(FTList.Items[i]).Currency);
                         end;
          CATEGORY_INDEX:begin
                          if (PTFinancyTransaction(FTList.Items[i]).Category = Index) and (not Add) then PTFinancyTransaction(FTList.Items[i]).Category := 0;
                          if PTFinancyTransaction(FTList.Items[i]).Category > Index then
                            if Add then
                              Inc(PTFinancyTransaction(FTList.Items[i]).Category)
                            else
                              Dec(PTFinancyTransaction(FTList.Items[i]).Category);
                         end;
          PERSONA_INDEX:begin
                          if (PTFinancyTransaction(FTList.Items[i]).Persona = Index) and (not Add) then PTFinancyTransaction(FTList.Items[i]).Persona := 0;
                          if PTFinancyTransaction(FTList.Items[i]).Persona > Index then
                            if Add then
                              Inc(PTFinancyTransaction(FTList.Items[i]).Persona)
                            else
                              Dec(PTFinancyTransaction(FTList.Items[i]).Persona);
                        end;
          CONTRACTOR_INDEX:begin
                             if (PTFinancyTransaction(FTList.Items[i]).Contractor = Index) and (not Add) then PTFinancyTransaction(FTList.Items[i]).Contractor := 0;
                             if PTFinancyTransaction(FTList.Items[i]).Contractor > Index then
                               if Add then
                                Inc(PTFinancyTransaction(FTList.Items[i]).Contractor)
                               else
                                 Dec(PTFinancyTransaction(FTList.Items[i]).Contractor);
                           end;
          EVENT_INDEX:begin
                        if (PTFinancyTransaction(FTList.Items[i]).Event = Index) and (not Add) then PTFinancyTransaction(FTList.Items[i]).Event := 0;
                        if PTFinancyTransaction(FTList.Items[i]).Event > Index then
                          if Add then
                            Inc(PTFinancyTransaction(FTList.Items[i]).Event)
                          else
                            Dec(PTFinancyTransaction(FTList.Items[i]).Event);
                      end;
        end;
      Exit;
    end;
  try
    if not TryOpenFile(MainDBFile, False) then
      begin
        AddLogStr('Ошибка открытия файла БД ' + MainDBFile + ' критическая ошибка');
        CriticalExit;
        Exit;
      end;
    DBFile := TFileStream.Create(MainDBFile, fmOpenReadWrite);
    Result := False;
    DBFile.Seek(0, soFromBeginning);
    for I := 0 to (DBFile.Size div SizeOf(FinancyTransaction)) - 1 do
      begin
        DBFile.Read(FinancyTransaction, SizeOf(FinancyTransaction));
        case iType of
        ACCOUNT_INDEX:begin
                        if (FinancyTransaction.Account = Index) and (not Add) then FinancyTransaction.Account := 0;
                        if FinancyTransaction.Account > Index then
                          if Add then
                            Inc(FinancyTransaction.Account)
                          else
                            Dec(FinancyTransaction.Account);
                      end;
        Currency_INDEX:begin
                        if (FinancyTransaction.Currency = Index) and (not Add) then FinancyTransaction.Currency := 0;
                        if FinancyTransaction.Currency > Index then
                          if Add then
                            Inc(FinancyTransaction.Currency)
                          else
                            Dec(FinancyTransaction.Currency);
                       end;
        CATEGORY_INDEX:begin
                        if (FinancyTransaction.Category = Index) and (not Add) then FinancyTransaction.Category := 0;
                        if FinancyTransaction.Category > Index then
                          if Add then
                            Inc(FinancyTransaction.Category)
                          else
                            Dec(FinancyTransaction.Category);
                       end;
        PERSONA_INDEX:begin
                        if (FinancyTransaction.Persona = Index) and (not Add) then FinancyTransaction.Persona := 0;
                        if FinancyTransaction.Persona > Index then
                          if Add then
                            Inc(FinancyTransaction.Persona)
                          else
                            Dec(FinancyTransaction.Persona);
                      end;
        CONTRACTOR_INDEX:begin
                           if (FinancyTransaction.Contractor = Index) and (not Add) then FinancyTransaction.Contractor := 0;
                           if FinancyTransaction.Contractor > Index then
                             if Add then
                              Inc(FinancyTransaction.Contractor)
                             else
                               Dec(FinancyTransaction.Contractor);
                         end;
        EVENT_INDEX:begin
                      if (FinancyTransaction.Event = Index)  and (not Add) then FinancyTransaction.Event := 0;
                      if FinancyTransaction.Event > Index then
                        if Add then
                          Inc(FinancyTransaction.Event)
                        else
                          Dec(FinancyTransaction.Event);
                    end;
        end;
        DBFile.Seek(((i)  * SizeOf(FinancyTransaction)), soFromBeginning);
        DBFile.Write(FinancyTransaction, SizeOf(FinancyTransaction));
        DBFile.Seek(((i + 1)  * SizeOf(FinancyTransaction)), soFromBeginning);
      end;
  finally
    DBFile.Free;
  end;
end;

//-- Получение максимального номера чека среди всех транзакций
function TransactionGetMaxBillNumber : Integer;
var
  i : Integer;
begin
  Result := 0;
  if MEM then
    begin
      for I := 0 to FTList.Count - 1 do
        if PTFinancyTransaction(FTList.Items[i]).BillNumber > Result then Result := PTFinancyTransaction(FTList.Items[i]).BillNumber;
      Exit;
    end;
  try
    DBFile := TFileStream.Create(MainDBFile, fmOpenRead);
    DBFile.Seek(0, soFromBeginning);
    for I := 1 to DBFile.Size div SizeOf(TempFinancyTransaction) do
      begin
        DBFile.Read(TempFinancyTransaction, SizeOf(TempFinancyTransaction));
        if TempFinancyTransaction.BillNumber > Result then Result := TempFinancyTransaction.BillNumber;
      end;
  finally
    DBFile.Free;
  end;
end;


//-- Получение максимального ID среди всех транзакций
function TransactionGetMaxIDKey : Integer;
var
  i : Integer;
begin
  Result := 0;
  if MEM then
    begin
      for I := 0 to FTList.Count - 1 do
        if PTFinancyTransaction(FTList.Items[i]).IDkey > Result then Result := PTFinancyTransaction(FTList.Items[i]).IDkey;
      Exit;
    end;
  try
    DBFile := TFileStream.Create(MainDBFile, fmOpenRead);
    DBFile.Seek(0, soFromBeginning);
    for I := 1 to DBFile.Size div SizeOf(TempFinancyTransaction) do
      begin
        DBFile.Read(TempFinancyTransaction, SizeOf(TempFinancyTransaction));
        if TempFinancyTransaction.IDkey > Result then Result := TempFinancyTransaction.IDkey;
      end;
  finally
    DBFile.Free;
  end;
end;

//-- Получение позиции по ID
function TransactionGetPositionByID(id : Integer) : Integer;
var
  i : Integer;
begin
  Result := 0;
  if MEM then
    begin
      for I := 0 to FTList.Count - 1 do
        if PTFinancyTransaction(FTList.Items[i]).IDkey = id then Result := i;
      Exit;
    end;
  try
    DBFile := TFileStream.Create(MainDBFile, fmOpenRead);
    DBFile.Seek(0, soFromBeginning);
    for I := 1 to DBFile.Size div SizeOf(TempFinancyTransaction) do
      begin
        DBFile.Read(TempFinancyTransaction, SizeOf(TempFinancyTransaction));
        if TempFinancyTransaction.IDkey = id then Result := i - 1;
      end;
  finally
    DBFile.Free;
  end;
end;

//-- Бэкап БД
function TransactionDoBackUp : Boolean;
var
  i : Integer;
begin
  Result := True;
  if MEM then
    begin
      try
        if TryOpenFile(BackUpDBFile , True) then
          begin
            BBFile := TFileStream.Create(BackUpDBFile, fmCreate);
            for I := 0 to FTList.Count - 1 do
              begin
                with FinancyTransaction do
                begin
                  Account          := PTFinancyTransaction(FTList.Items[i]).Account;
                  Date             := PTFinancyTransaction(FTList.Items[i]).Date;
                  EndDate          := PTFinancyTransaction(FTList.Items[i]).EndDate;
                  Flag             := PTFinancyTransaction(FTList.Items[i]).Flag;
                  Price            := PTFinancyTransaction(FTList.Items[i]).Price;
                  price2           := PTFinancyTransaction(FTList.Items[i]).price2;
                  Number           := PTFinancyTransaction(FTList.Items[i]).Number;
                  Discount         := PTFinancyTransaction(FTList.Items[i]).Discount;
                  AbsProc          := PTFinancyTransaction(FTList.Items[i]).AbsProc;
                  Summ             := PTFinancyTransaction(FTList.Items[i]).Summ;
                  Currency         := PTFinancyTransaction(FTList.Items[i]).Currency;
                  Category         := PTFinancyTransaction(FTList.Items[i]).Category;
                  Description      := PTFinancyTransaction(FTList.Items[i]).Description;
                  Persona          := PTFinancyTransaction(FTList.Items[i]).Persona;
                  Comment          := PTFinancyTransaction(FTList.Items[i]).Comment;
                  Contractor       := PTFinancyTransaction(FTList.Items[i]).Contractor;
                  Event            := PTFinancyTransaction(FTList.Items[i]).Event;
                  BillNumber       := PTFinancyTransaction(FTList.Items[i]).BillNumber;
                  IDkey            := PTFinancyTransaction(FTList.Items[i]).IDkey;
                  Measure          := PTFinancyTransaction(FTList.Items[i]).Measure;
                  Priority         := PTFinancyTransaction(FTList.Items[i]).Priority;
                  Packing          := PTFinancyTransaction(FTList.Items[i]).Packing;
                end;
                BBFile.Write(FinancyTransaction, SizeOf(FinancyTransaction));
              end;
          end
        else
          begin
            AddLogStr('Проблема при сохранении резервной копии БД, файл не сохранен ' + BackUpDBFile);
            Result := False;
          end;
        if not TryOpenFile(StringReplace(AccountIndexFile, '.idx', '.bak', [rfIgnoreCase]), true) then //-- сохраняем резервные копии мндексов
          begin
            AddLogStr('Проблема при сохранении резервной копии файла индексов, файл не сохранен ' + StringReplace(AccountIndexFile, '.idx', '.bak', [rfIgnoreCase]));
            Result := False;
          end
        else
          AccountList.SaveToFile(StringReplace(AccountIndexFile, '.idx', '.bak', [rfIgnoreCase]));
        if not TryOpenFile(StringReplace(CurrencyIndexFile, '.idx', '.bak', [rfIgnoreCase]), true) then
          begin
            AddLogStr('Проблема при сохранении резервной копии файла индексов, файл не сохранен ' + StringReplace(CurrencyIndexFile, '.idx', '.bak', [rfIgnoreCase]));
            Result := False;
          end
        else
          CurrencyList.SaveToFile(StringReplace(CurrencyIndexFile, '.idx', '.bak', [rfIgnoreCase]));
        if not TryOpenFile(StringReplace(CategoryIndexFile, '.idx', '.bak', [rfIgnoreCase]), true) then
          begin
            AddLogStr('Проблема при сохранении резервной копии файла индексов, файл не сохранен ' + StringReplace(CategoryIndexFile, '.idx', '.bak', [rfIgnoreCase]));
            Result := False;
          end
        else
          CategoryList.SaveToFile(StringReplace(CategoryIndexFile, '.idx', '.bak', [rfIgnoreCase]));
        if not TryOpenFile(StringReplace(PersonaIndexFile, '.idx', '.bak', [rfIgnoreCase]), true) then
          begin
            AddLogStr('Проблема при сохранении резервной копии файла индексов, файл не сохранен ' + StringReplace(PersonaIndexFile, '.idx', '.bak', [rfIgnoreCase]));
            Result := False;
          end
        else
          PersonaList.SaveToFile(StringReplace(PersonaIndexFile, '.idx', '.bak', [rfIgnoreCase]));
        if not TryOpenFile(StringReplace(EventIndexFile, '.idx', '.bak', [rfIgnoreCase]), true) then
          begin
            AddLogStr('Проблема при сохранении резервной копии файла индексов, файл не сохранен ' + StringReplace(EventIndexFile, '.idx', '.bak', [rfIgnoreCase]));
            Result := False;
          end
        else
          EventList.SaveToFile(StringReplace(EventIndexFile, '.idx', '.bak', [rfIgnoreCase]));
        if not TryOpenFile(StringReplace(ContractorIndexFile, '.idx', '.bak', [rfIgnoreCase]), true) then
          begin
            AddLogStr('Проблема при сохранении резервной копии файла индексов, файл не сохранен ' + StringReplace(ContractorIndexFile, '.idx', '.bak', [rfIgnoreCase]));
            Result := False;
          end
        else
          ContractorList.SaveToFile(StringReplace(ContractorIndexFile, '.idx', '.bak', [rfIgnoreCase]));
        if not TryOpenFile(StringReplace(StandardIndexFile, '.idx', '.bak', [rfIgnoreCase]), true) then
          begin
            AddLogStr('Проблема при сохранении резервной копии файла индексов, файл не сохранен ' + StringReplace(StandardIndexFile, '.idx', '.bak', [rfIgnoreCase]));
            Result := False;
          end
        else
          StandardList.SaveToFile(StringReplace(StandardIndexFile, '.idx', '.bak', [rfIgnoreCase]));
        if not TryOpenFile(StringReplace(NotesIndexFile, '.idx', '.bak', [rfIgnoreCase]), true) then
          begin
            AddLogStr('Проблема при сохранении резервной копии файла индексов, файл не сохранен ' + StringReplace(NotesIndexFile, '.idx', '.bak', [rfIgnoreCase]));
            Result := False;
          end
        else
          NotesList.SaveToFile(StringReplace(NotesIndexFile, '.idx', '.bak', [rfIgnoreCase]));
      finally
        BBFile.Free;
      end;
      Exit;
    end;
  try
    Result := True;
    if TryOpenFile(BackUpDBFile , True) and TryOpenFile(MainDBFile , False) then
      begin
        DBFile := TFileStream.Create(MainDBFile, fmOpenReadWrite);
        BBFile := TFileStream.Create(BackUpDBFile, fmCreate);
        DBFile.Seek(0, soFromBeginning);
        for I := 0 to (DBFile.Size div SizeOf(FinancyTransaction)) - 1 do
          begin
            DBFile.Read(FinancyTransaction, SizeOf(FinancyTransaction));
            BBFile.Write(FinancyTransaction, SizeOf(FinancyTransaction));
          end;
      end
    else
      begin
        AddLogStr('Проблема при сохранении резервной копии БД, файл не сохранен ' + BackUpDBFile);
        Result := False;
      end;
    if not TryOpenFile(StringReplace(AccountIndexFile, '.idx', '.bak', [rfIgnoreCase]), true) then  //-- сохраняем резервные копии мндексов
      begin
        AddLogStr('Проблема при сохранении резервной копии файла индексов, файл не сохранен ' + StringReplace(AccountIndexFile, '.idx', '.bak', [rfIgnoreCase]));
        Result := False;
      end
    else
      AccountList.SaveToFile(StringReplace(CurrencyIndexFile, '.idx', '.bak', [rfIgnoreCase]));
    if not TryOpenFile(StringReplace(CurrencyIndexFile, '.idx', '.bak', [rfIgnoreCase]), true) then
      begin
        AddLogStr('Проблема при сохранении резервной копии файла индексов, файл не сохранен ' + StringReplace(AccountIndexFile, '.idx', '.bak', [rfIgnoreCase]));
        Result := False;
      end
    else
      CurrencyList.SaveToFile(StringReplace(CurrencyIndexFile, '.idx', '.bak', [rfIgnoreCase]));
    if not TryOpenFile(StringReplace(CategoryIndexFile, '.idx', '.bak', [rfIgnoreCase]), true) then
      begin
        AddLogStr('Проблема при сохранении резервной копии файла индексов, файл не сохранен ' + StringReplace(CategoryIndexFile, '.idx', '.bak', [rfIgnoreCase]));
        Result := False;
      end
    else
      CategoryList.SaveToFile(StringReplace(CategoryIndexFile, '.idx', '.bak', [rfIgnoreCase]));
    if not TryOpenFile(StringReplace(PersonaIndexFile, '.idx', '.bak', [rfIgnoreCase]), true) then
      begin
        AddLogStr('Проблема при сохранении резервной копии файла индексов, файл не сохранен ' + StringReplace(PersonaIndexFile, '.idx', '.bak', [rfIgnoreCase]));
        Result := False;
      end
    else
      PersonaList.SaveToFile(StringReplace(PersonaIndexFile, '.idx', '.bak', [rfIgnoreCase]));
    if not TryOpenFile(StringReplace(EventIndexFile, '.idx', '.bak', [rfIgnoreCase]), true) then
      begin
        AddLogStr('Проблема при сохранении резервной копии файла индексов, файл не сохранен ' + StringReplace(EventIndexFile, '.idx', '.bak', [rfIgnoreCase]));
        Result := False;
      end
    else
      EventList.SaveToFile(StringReplace(EventIndexFile, '.idx', '.bak', [rfIgnoreCase]));
    if not TryOpenFile(StringReplace(ContractorIndexFile, '.idx', '.bak', [rfIgnoreCase]), true) then
      begin
        AddLogStr('Проблема при сохранении резервной копии файла индексов, файл не сохранен ' + StringReplace(ContractorIndexFile, '.idx', '.bak', [rfIgnoreCase]));
        Result := False;
      end
    else
      ContractorList.SaveToFile(StringReplace(ContractorIndexFile, '.idx', '.bak', [rfIgnoreCase]));
    if not TryOpenFile(StringReplace(StandardIndexFile, '.idx', '.bak', [rfIgnoreCase]), true) then
      begin
        AddLogStr('Проблема при сохранении резервной копии файла индексов, файл не сохранен ' + StringReplace(StandardIndexFile, '.idx', '.bak', [rfIgnoreCase]));
        Result := False;
      end
    else
      StandardList.SaveToFile(StringReplace(StandardIndexFile, '.idx', '.bak', [rfIgnoreCase]));
  finally
    BBFile.Free;
    DBFile.Free;
  end;
end;

//-- Загрузка БД
function LoadDB : Boolean;
var
  i, j : Integer;
begin
  try
    if not FileExists(MainDBFile) then
      begin
        SplashString('База пуста и готова к заполнению', 99, 200);
        Exit;
      end;
    DBFile := TFileStream.Create(MainDBFile, fmOpenReadWrite);
    j := (DBFile.Size div SizeOf(FinancyTransaction));
    for I := 0 to j - 1 do
      begin
        SplashString('Загрузка записи # ' + IntToStr(i + 1), Round((j/100) * i), Round(500 / j));
        DBFile.Read(FinancyTransaction, SizeOf(FinancyTransaction));
{ DONE : Сделать проверку БД }
        if MEM then
          begin
            New(PFinancyFtansaction);
            with PFinancyFtansaction^ do
            begin
              Account          := FinancyTransaction.Account;
              Date             := FinancyTransaction.Date;
              EndDate          := FinancyTransaction.EndDate;
              Flag             := FinancyTransaction.Flag;
              Price            := FinancyTransaction.Price;
              Price2           := FinancyTransaction.price2;
              Number           := FinancyTransaction.Number;
              Discount         := FinancyTransaction.Discount;
              AbsProc          := FinancyTransaction.AbsProc;
              Summ             := FinancyTransaction.Summ;
              Currency         := FinancyTransaction.Currency;
              Category         := FinancyTransaction.Category;
              Description      := FinancyTransaction.Description;
              Persona          := FinancyTransaction.Persona;
              Comment          := FinancyTransaction.Comment;
              Contractor       := FinancyTransaction.Contractor;
              Event            := FinancyTransaction.Event;
              BillNumber       := FinancyTransaction.BillNumber;
              IDkey            := FinancyTransaction.IDkey;
              Measure          := FinancyTransaction.Measure;
              Priority         := FinancyTransaction.Priority;
              Packing          := FinancyTransaction.Packing;
            end;
            FTList.Add(PFinancyFtansaction);
          end;
      end;
  finally
    DBFile.Free;
    Result := True;
  end;
end;


function CheckAccount : Boolean;
begin
  if AccountList.Count - 1 < FinancyTransaction.Account then
    Result := False
  else
    Result := True;
end;

function CheckCategory : Boolean;
begin
  if CategoryList.Count - 1 < FinancyTransaction.Category then
    Result := False
  else
    Result := True;
end;

function CheckPersona : Boolean;
begin
  if PersonaList.Count - 1 < FinancyTransaction.Persona then
    Result := False
  else
    Result := True;
end;

function CheckEvent : Boolean;
begin
  if EventList.Count - 1 < FinancyTransaction.Event then
    Result := False
  else
    Result := True;
end;

function CheckContractor : Boolean;
begin
  if ContractorList.Count - 1 < FinancyTransaction.Contractor then
    Result := False
  else
    Result := True;
end;

function CheckPrice : Boolean;
begin
  if FinancyTransaction.Price = 0 then
    Result := False
  else
    Result := True;
end;

function CheckSumm : Boolean;
begin
{ TODO : надо как то проверять сумму }
  Result := False;
  if FinancyTransaction.AbsProc then
    begin
      if RoundTo(FinancyTransaction.Summ, RoundN) = RoundTo(FinancyTransaction.Price * FinancyTransaction.Number * FinancyTransaction.Packing * (1 - FinancyTransaction.Discount * 0.01), RoundN) then
        Result := True
    end
  else
    if RoundTo(FinancyTransaction.Summ, RoundN) = RoundTo(FinancyTransaction.Price * FinancyTransaction.Number * FinancyTransaction.Packing - FinancyTransaction.Discount, RoundN) then
      Result := True;
end;


function CheckDB : Boolean;
var
  i, j : Integer;
  errAccount    : Integer;
  errCategory   : Integer;
  errPersona    : Integer;
  errEvent      : Integer;
  errContractor : Integer;
  errSumm       : Integer;
  errPrice      : Integer;
begin
  Result := False;
  try
    if not FileExists(MainDBFile) then
      begin
        SplashString('База пуста и готова к заполнению', 99, 200);
        Exit;
      end;
    DBFile := TFileStream.Create(MainDBFile, fmOpenReadWrite);
    j := (DBFile.Size div SizeOf(FinancyTransaction));
    errAccount    := 0;
    errCategory   := 0;
    errPersona    := 0;
    errEvent      := 0;
    errSumm       := 0;
    errPrice      := 0;
    errContractor := 0;
    for I := 0 to j - 1 do
      begin
        SplashString('Проверка записи # ' + IntToStr(i + 1), Round((j/100) * i), Round(1000 / j));
        DBFile.Read(FinancyTransaction, SizeOf(FinancyTransaction));
        if not CheckAccount then Inc(errAccount);
        if not CheckCategory then Inc(errCategory);
        if not CheckPersona then Inc(errPersona);
        if not CheckEvent then Inc(errEvent);
        if not CheckContractor then Inc(errContractor);
        if not CheckPrice then Inc(errPrice);
   {     if not CheckSumm then
          begin
            AddLogStr('  Ошибка суммы товара ' + DescriptionNameList[FinancyTransaction.Description.Name]);
            Inc(errSumm);
          end; }
      end;
  finally
    DBFile.Free;
  end;
  if (errAccount = 0) and (errCategory = 0) and (errPersona = 0) and (errEvent = 0) and (errContractor = 0) and (errPrice = 0) and (errSumm = 0) then
    Result := True
  else
    MessageDlg('В базе данных обнаружены ошибки : ' + #13 +
      IntToStr(errAccount) + ' в счетах, ' + #13 +
      IntToStr(errCategory) + ' в категориях, ' + #13 +
      IntToStr(errPersona) + ' в персонах, ' +  #13 +
      IntToStr(errEvent) + ' в событиях, ' +  #13 +
      IntToStr(errContractor) + ' в контрагентах, ' +  #13 +
      IntToStr(errPrice) + ' в цене, ' +  #13 +
      IntToStr(errSumm) + ' в сумме, ' +  #13, mtWarning, [mbOK], 0);
end;


{ TODO : сделать востановление БД }
procedure RestoreDB;
begin

end;

{procedure ConvertDB;
var
  newTrans : TFinancyTransaction2;
  Index, i    : Integer;
begin
  try
    BBFile := TFileStream.Create(DBWorkDir + 'Money.new', fmCreate);
//-- Description и Comment заполняем списки а обратно присваиваем номер в списке
   for I := 0 to FTList.Count - 1 do
     begin
       Index := DescriptionNameList.IndexOf(PTFinancyTransaction(FTList.Items[i]).Description);
       if Index = -1 then  //-- нет в списке значит добавим
           PTFinancyTransaction(FTList.Items[i]).Description := IntToStr(DescriptionNameList.Add(PTFinancyTransaction(FTList.Items[i]).Description))
       else
         PTFinancyTransaction(FTList.Items[i]).Description := IntToStr(Index);

       Index := CommentList.IndexOf(PTFinancyTransaction(FTList.Items[i]).Comment);
       if Index = -1 then  //-- нет в списке значит добавим
         PTFinancyTransaction(FTList.Items[i]).Comment := IntToStr(CommentList.Add(PTFinancyTransaction(FTList.Items[i]).Comment))
       else
         PTFinancyTransaction(FTList.Items[i]).Comment := IntToStr(Index);
     end;
//--перегоняем из одного формата в другой
    for I := 0 to FTList.Count - 1 do
        begin
          with newTrans do
          begin
            Account          := PTFinancyTransaction(FTList.Items[i]).Account;
            Date             := PTFinancyTransaction(FTList.Items[i]).Date;
            EndDate  := PTFinancyTransaction(FTList.Items[i]).Date;
            Flag     := PTFinancyTransaction(FTList.Items[i]).TransactionType;
            Price            := PTFinancyTransaction(FTList.Items[i]).Price;
            price2 := 0;
            Number           := PTFinancyTransaction(FTList.Items[i]).Number;
            Discount         := PTFinancyTransaction(FTList.Items[i]).Discount;
            AbsProc          := PTFinancyTransaction(FTList.Items[i]).AbsProc;
            Summ             := PTFinancyTransaction(FTList.Items[i]).Summ;
            Currency         := PTFinancyTransaction(FTList.Items[i]).Currency;
            Category         := PTFinancyTransaction(FTList.Items[i]).Category;
            Description.Name := StrToInt(PTFinancyTransaction(FTList.Items[i]).Description);
            Description.Brand := 0;
            Description.Series := 0;
            Persona          := PTFinancyTransaction(FTList.Items[i]).Persona;
            Comment     := StrToInt(PTFinancyTransaction(FTList.Items[i]).Comment);
            Contractor       := PTFinancyTransaction(FTList.Items[i]).Contractor;
            Event            := PTFinancyTransaction(FTList.Items[i]).Event;
            BillNumber       := PTFinancyTransaction(FTList.Items[i]).BillNumber;
            IDkey            := PTFinancyTransaction(FTList.Items[i]).IDkey;
            Measure  := PTFinancyTransaction(FTList.Items[i]).Measure;
            Priority := 255;
            Packing  := 1;
//-- меняем константы Flag и Measure
            if Flag = 1 then Flag := 12;
            if Flag = 2 then Flag := 1;

            if Measure = 1 then Measure := 3;
            if Measure = 2 then Measure := 4;
            if Measure = 3 then Measure := 5;
            if Measure = 4 then Measure := 6;
            if Measure = 5 then Measure := 7;
            if Measure = 10 then Measure := 1;
          end;
//-- и наконец пишем в итоговый файл
          BBFile.Write(newTrans, SizeOf(newTrans));
        end;
  finally
    BBFile.Free;
  end;
  SaveIndex;
end;          }

procedure AutoAdd;
begin
  try
    if not TryOpenFile(AutoDBFile, false) then
      begin
        AddLogStr('Ошибка открытия файла БД ' + MainDBFile + ' критическая ошибка');
        CriticalExit;
        Exit;
      end;
    if FileExists(AutoDBFile) then
      AutoFile := TFileStream.Create(AutoDBFile, fmOpenWrite)
    else
      AutoFile := TFileStream.Create(AutoDBFile, fmCreate);
    AutoFile.Seek(0, soFromEnd);
    AutoFile.Write(TempFinancyTransaction, SizeOf(TempFinancyTransaction));
  finally
    AutoFile.Free;
  end;
end;

procedure AutoRead(Position : Integer);
begin
  try
    if not TryOpenFile(AutoDBFile, false) then
      begin
        AddLogStr('Ошибка открытия файла БД ' + MainDBFile + ' критическая ошибка');
        CriticalExit;
        Exit;
      end;
    if not FileExists(AutoDBFile) then
      Exit
    else
      AutoFile := TFileStream.Create(AutoDBFile, fmOpenRead, fmShareDenyNone);
    AutoFile.Seek(Position * SizeOf(TempFinancyTransaction), soFromBeginning);
    AutoFile.Read(TempFinancyTransaction, SizeOf(TempFinancyTransaction));
  finally
    AutoFile.Free;
  end;
end;


function AutoGetCount : Integer;
begin
  Result := 0;
  TryOpenFile(AutoDBFile, false);
  if not FileExists(AutoDBFile) then Exit;
  try
    AutoFile := TFileStream.Create(AutoDBFile, fmOpenRead, fmShareDenyNone);
    Result := AutoFile.Size div SizeOf(TempFinancyTransaction);
  finally
    AutoFile.Free;
  end;
end;

{ DONE : Сделать список стандартных товаров }
procedure SaveStandardItem(Item : string);
var
  i : Integer;
begin
  if StandardList.Find(Item, i) then Exit;
  StandardList.Add(Item);
end;


function Totalbalance(cellDate : TDate) : extended;
var
  i : Integer;
  income : Extended;
  Spend : Extended;
begin
  Result := 0;
  income := 0;
  Spend := 0;
  if MEM then
    begin
      for i := 0 to FTList.count - 1 do
        if cellDate >= PTFinancyTransaction(FTList.Items[i]).Date then
          if (PTFinancyTransaction(FTList.Items[i]).Flag = TINCOME) or (PTFinancyTransaction(FTList.Items[i]).Flag = TWAITINCOME) then
            income := income + PTFinancyTransaction(FTList.Items[i]).Summ
          else
            spend := spend + PTFinancyTransaction(FTList.Items[i]).Summ;
      if income > spend then
        Result := Result + (income - Spend)
      else
        Result := Result - (Spend - income);
      Exit;
    end;
  try
    DBFile := TFileStream.Create(MainDBFile, fmOpenRead);
    for i := 0 to (DBFile.Size div SizeOf(FinancyTransaction)) - 1 do
      begin
        DBFile.Read(FinancyTransaction, SizeOf(FinancyTransaction));
        if cellDate >= FinancyTransaction.Date then
        if (FinancyTransaction.Flag = TINCOME) or (FinancyTransaction.Flag = TWAITINCOME) then
          income := income + FinancyTransaction.Summ
        else
          spend := spend + FinancyTransaction.Summ;
      end;
    if income > spend then
      Result := Result + (income - Spend)
    else
      Result := Result - (Spend - income);
  finally
    DBFile.Free;
  end;
end;


function GetTotalSummByIndex(Index, IndexType : integer; StartDate, EndDate : TDateTime) : Extended;
var
  i : Integer;
begin
  Result := 0;
  if MEM then
    begin
      for i := 0 to FTList.count - 1 do
        case IndexType of
        ACCOUNT_INDEX    : begin
                             if (PTFinancyTransaction(FTList.Items[i]).Account = Index) and
                              (PTFinancyTransaction(FTList.Items[i]).Date >= StartDate) and
                              (PTFinancyTransaction(FTList.Items[i]).Date <= EndDate) then
                                 begin
                                   if (PTFinancyTransaction(FTList.Items[i]).Flag = TINCOME) then
                                     Result := Result + PTFinancyTransaction(FTList.Items[i]).Summ;
                                   if (PTFinancyTransaction(FTList.Items[i]).Flag = TSPENDING) then
                                     Result := Result - PTFinancyTransaction(FTList.Items[i]).Summ;
                                 end;
                           end;
        Currency_INDEX   : begin
                             if (PTFinancyTransaction(FTList.Items[i]).Currency = Index) and
                              (PTFinancyTransaction(FTList.Items[i]).Date >= StartDate) and
                              (PTFinancyTransaction(FTList.Items[i]).Date <= EndDate) then
                                 begin
                                   if (PTFinancyTransaction(FTList.Items[i]).Flag = TINCOME) then
                                     Result := Result + PTFinancyTransaction(FTList.Items[i]).Summ;
                                   if (PTFinancyTransaction(FTList.Items[i]).Flag = TSPENDING) then
                                     Result := Result - PTFinancyTransaction(FTList.Items[i]).Summ;
                                 end;
                           end;
        CATEGORY_INDEX   : begin
                             if (PTFinancyTransaction(FTList.Items[i]).Category = Index) and
                              (PTFinancyTransaction(FTList.Items[i]).Date >= StartDate) and
                              (PTFinancyTransaction(FTList.Items[i]).Date <= EndDate) then
                                 begin
                                   if (PTFinancyTransaction(FTList.Items[i]).Flag = TINCOME) then
                                     Result := Result + PTFinancyTransaction(FTList.Items[i]).Summ;
                                   if (PTFinancyTransaction(FTList.Items[i]).Flag = TSPENDING) then
                                     Result := Result - PTFinancyTransaction(FTList.Items[i]).Summ;
                                 end;
                           end;
        PERSONA_INDEX    : begin
                             if (PTFinancyTransaction(FTList.Items[i]).Persona = Index) and
                              (PTFinancyTransaction(FTList.Items[i]).Date >= StartDate) and
                              (PTFinancyTransaction(FTList.Items[i]).Date <= EndDate) then
                                 begin
                                   if (PTFinancyTransaction(FTList.Items[i]).Flag = TINCOME) then
                                     Result := Result + PTFinancyTransaction(FTList.Items[i]).Summ;
                                   if (PTFinancyTransaction(FTList.Items[i]).Flag = TSPENDING) then
                                     Result := Result - PTFinancyTransaction(FTList.Items[i]).Summ;
                                 end;
                           end;
        CONTRACTOR_INDEX : begin
                             if (PTFinancyTransaction(FTList.Items[i]).Contractor = Index) and
                              (PTFinancyTransaction(FTList.Items[i]).Date >= StartDate) and
                              (PTFinancyTransaction(FTList.Items[i]).Date <= EndDate) then
                                 begin
                                   if (PTFinancyTransaction(FTList.Items[i]).Flag = TINCOME) then
                                     Result := Result + PTFinancyTransaction(FTList.Items[i]).Summ;
                                   if (PTFinancyTransaction(FTList.Items[i]).Flag = TSPENDING) then
                                     Result := Result - PTFinancyTransaction(FTList.Items[i]).Summ;
                                 end;
                           end;
        EVENT_INDEX      : begin
                             if (PTFinancyTransaction(FTList.Items[i]).Event = Index) and
                              (PTFinancyTransaction(FTList.Items[i]).Date >= StartDate) and
                              (PTFinancyTransaction(FTList.Items[i]).Date <= EndDate) then
                                 begin
                                   if (PTFinancyTransaction(FTList.Items[i]).Flag = TINCOME) then
                                     Result := Result + PTFinancyTransaction(FTList.Items[i]).Summ;
                                   if (PTFinancyTransaction(FTList.Items[i]).Flag = TSPENDING) then
                                     Result := Result - PTFinancyTransaction(FTList.Items[i]).Summ;
                                 end;
                           end;
        end;
      Exit;
    end;
  try
    DBFile := TFileStream.Create(MainDBFile, fmOpenRead);
    for i := 0 to (DBFile.Size div SizeOf(FinancyTransaction)) - 1 do
      begin
        DBFile.Read(FinancyTransaction, SizeOf(FinancyTransaction));
        case IndexType of
        ACCOUNT_INDEX    : begin
                             if (FinancyTransaction.Account = Index) and (FinancyTransaction.Date >= StartDate) and (FinancyTransaction.Date <= EndDate) then
                               begin
                                 if FinancyTransaction.Flag = TINCOME then
                                   Result := Result + FinancyTransaction.Summ;
                                 if FinancyTransaction.Flag = TSPENDING then
                                   Result := Result - FinancyTransaction.Summ;
                              end;
                           end;
        Currency_INDEX   : begin
                             if (FinancyTransaction.Currency = Index) and (FinancyTransaction.Date >= StartDate) and (FinancyTransaction.Date <= EndDate) then
                               begin
                                 if FinancyTransaction.Flag = TINCOME then
                                   Result := Result + FinancyTransaction.Summ;
                                 if FinancyTransaction.Flag = TSPENDING then
                                   Result := Result - FinancyTransaction.Summ;
                              end;
                           end;
        CATEGORY_INDEX   : begin
                             if (FinancyTransaction.Category = Index) and (FinancyTransaction.Date >= StartDate) and (FinancyTransaction.Date <= EndDate) then
                               begin
                                 if FinancyTransaction.Flag = TINCOME then
                                   Result := Result + FinancyTransaction.Summ;
                                 if FinancyTransaction.Flag = TSPENDING then
                                   Result := Result - FinancyTransaction.Summ;
                              end;
                           end;
        PERSONA_INDEX    : begin
                             if (FinancyTransaction.Persona = Index) and (FinancyTransaction.Date >= StartDate) and (FinancyTransaction.Date <= EndDate) then
                               begin
                                 if FinancyTransaction.Flag = TINCOME then
                                   Result := Result + FinancyTransaction.Summ;
                                 if FinancyTransaction.Flag = TSPENDING then
                                   Result := Result - FinancyTransaction.Summ;
                              end;
                           end;
        CONTRACTOR_INDEX : begin
                             if (FinancyTransaction.Contractor = Index) and (FinancyTransaction.Date >= StartDate) and (FinancyTransaction.Date <= EndDate) then
                               begin
                                 if FinancyTransaction.Flag = TINCOME then
                                   Result := Result + FinancyTransaction.Summ;
                                 if FinancyTransaction.Flag = TSPENDING then
                                   Result := Result - FinancyTransaction.Summ;
                              end;
                           end;
        EVENT_INDEX      : begin
                             if (FinancyTransaction.Event = Index) and (FinancyTransaction.Date >= StartDate) and (FinancyTransaction.Date <= EndDate) then
                               begin
                                 if FinancyTransaction.Flag = TINCOME then
                                   Result := Result + FinancyTransaction.Summ;
                                 if FinancyTransaction.Flag = TSPENDING then
                                   Result := Result - FinancyTransaction.Summ;
                              end;
                           end;
        end;
      end;
  finally
    DBFile.Free;
  end;
end;

{function GetTotalSumm(incoming : Boolean; StartDate, EndDate : TDateTime) : Extended;
var
  i : Integer;
begin
  Result := 0;
  if MEM then
    begin
      for i := 0 to FTList.count - 1 do
        if (PTFinancyTransaction(FTList.Items[i]).Date >= StartDate) and (PTFinancyTransaction(FTList.Items[i]).Date <= EndDate) then
          begin
            if incoming and ((PTFinancyTransaction(FTList.Items[i]).Flag = TINCOME) or (PTFinancyTransaction(FTList.Items[i]).Flag = TWAITINCOME)) then
              Result := Result + PTFinancyTransaction(FTList.Items[i]).Summ;
            if not incoming and ((PTFinancyTransaction(FTList.Items[i]).Flag = TSPENDING) or (PTFinancyTransaction(FTList.Items[i]).Flag = TWAITSPENDING)) then
              Result := Result + PTFinancyTransaction(FTList.Items[i]).Summ;
          end;
      Exit;
    end;
  try
    DBFile := TFileStream.Create(MainDBFile, fmOpenRead);
    for i := 0 to (DBFile.Size div SizeOf(FinancyTransaction)) - 1 do
      begin
        DBFile.Read(FinancyTransaction, SizeOf(FinancyTransaction));
        if (FinancyTransaction.Date >= StartDate) and (FinancyTransaction.Date <= EndDate) then
          begin
            if incoming and ((FinancyTransaction.Flag = TINCOME) or (FinancyTransaction.Flag = TWAITINCOME)) then
              Result := Result + FinancyTransaction.Summ;
            if not incoming and ((FinancyTransaction.Flag = TSPENDING) or (FinancyTransaction.Flag = TWAITSPENDING)) then
              Result := Result + FinancyTransaction.Summ;
          end;
      end;
  finally
    DBFile.Free;
  end;
end;}

function GetTotalSummByType(Flag: byte; StartDate, EndDate : TDate) : Extended;
var
  i : Integer;
begin
  Result := 0;
  if MEM then
    begin
      for i := 0 to FTList.count - 1 do
        if (CompareDate(PTFinancyTransaction(FTList.Items[i]).Date, StartDate) >= 0) and (CompareDate(PTFinancyTransaction(FTList.Items[i]).Date, EndDate) <= 0) then
          if (PTFinancyTransaction(FTList.Items[i]).Flag = Flag) or (Flag = TALL) then
            Result := Result + PTFinancyTransaction(FTList.Items[i]).Summ;
      Exit;
    end;
  try
    DBFile := TFileStream.Create(MainDBFile, fmOpenRead);
    for i := 0 to (DBFile.Size div SizeOf(FinancyTransaction)) - 1 do
      begin
        DBFile.Read(FinancyTransaction, SizeOf(FinancyTransaction));
        if (FinancyTransaction.Date >= StartDate) and (FinancyTransaction.Date <= EndDate) then
          if (FinancyTransaction.Flag = Flag) or (Flag = TALL) then
             Result := Result + FinancyTransaction.Summ;
      end;
  finally
    DBFile.Free;
  end;
end;


function GetMinDate : TDate;
var
  i : Integer;
begin
  Result := IncMonth(Now, 24);
  if MEM then
    begin
      for i := 0 to FTList.count - 1 do
        if (PTFinancyTransaction(FTList.Items[i]).Date < Result) then
          Result := (PTFinancyTransaction(FTList.Items[i]).Date);
      Exit;
    end;
  try
    DBFile := TFileStream.Create(MainDBFile, fmOpenRead);
    for i := 0 to (DBFile.Size div SizeOf(FinancyTransaction)) - 1 do
      begin
        DBFile.Read(FinancyTransaction, SizeOf(FinancyTransaction));
        if (FinancyTransaction.Date < Result) then
           Result := FinancyTransaction.Date;
      end;
  finally
    DBFile.Free;
  end;
end;

function GetMaxDate : TDate;
var
  i : Integer;
begin
  Result := IncMonth(Now, -240);
  if MEM then
    begin
      for i := 0 to FTList.count - 1 do
        if (PTFinancyTransaction(FTList.Items[i]).Date > Result) then
          Result := (PTFinancyTransaction(FTList.Items[i]).Date);
      Exit;
    end;
  try
    DBFile := TFileStream.Create(MainDBFile, fmOpenRead);
    for i := 0 to (DBFile.Size div SizeOf(FinancyTransaction)) - 1 do
      begin
        DBFile.Read(FinancyTransaction, SizeOf(FinancyTransaction));
        if (FinancyTransaction.Date < Result) then
           Result := FinancyTransaction.Date;
      end;
  finally
    DBFile.Free;
  end;
end;

function TransactionSaveDB : Boolean;
var
  i : Integer;
  S : Boolean;
begin
  if not TryOpenFile(AccountIndexFile, true) then
    begin
      AddLogStr('Проблема при сохранении файла индексов, файл не сохранен ' + AccountIndexFile);
      Result := False;
    end
  else
    AccountList.SaveToFile(AccountIndexFile);
  if not TryOpenFile(CurrencyIndexFile, true) then
    begin
      AddLogStr('Проблема при сохранении файла индексов, файл не сохранен ' + CurrencyIndexFile);
      Result := False;
    end
  else
    CurrencyList.SaveToFile(CurrencyIndexFile);
  if not TryOpenFile(CategoryIndexFile, true) then
    begin
      AddLogStr('Проблема при сохранении файла индексов, файл не сохранен ' + CategoryIndexFile);
      Result := False;
    end
  else
    CategoryList.SaveToFile(CategoryIndexFile);
  if not TryOpenFile(PersonaIndexFile, true) then
    begin
      AddLogStr('Проблема при сохранении файла индексов, файл не сохранен ' + PersonaIndexFile);
      Result := False;
    end
  else
    PersonaList.SaveToFile(PersonaIndexFile);
  if not TryOpenFile(ContractorIndexFile, true) then
    begin
      AddLogStr('Проблема при сохранении файла индексов, файл не сохранен ' + ContractorIndexFile);
      Result := False;
    end
  else
    ContractorList.SaveToFile(ContractorIndexFile);
  if not TryOpenFile(EventIndexFile, true) then
    begin
      AddLogStr('Проблема при сохранении файла индексов, файл не сохранен ' + EventIndexFile);
      Result := False;
    end
  else
    EventList.SaveToFile(EventIndexFile);
  if not TryOpenFile(StandardIndexFile, true) then
    begin
      AddLogStr('Проблема при сохранении файла индексов, файл не сохранен ' + StandardIndexFile);
      Result := False;
    end
  else
    StandardList.SaveToFile(StandardIndexFile);


  if not TryOpenFile(CommentIndexFile, true) then
      begin
        AddLogStr('Проблема при сохранении файла индексов, файл не сохранен ' + CommentIndexFile);
        Result := False;
      end
    else
      CommentList.SaveToFile(CommentIndexFile);

    if not TryOpenFile(DescriptionIndexFile, true) then
      begin
        AddLogStr('Проблема при сохранении файла индексов, файл не сохранен ' + DescriptionIndexFile);
        Result := False;
      end
    else
      DescriptionNameList.SaveToFile(DescriptionIndexFile);

    if not TryOpenFile(DescriptionIndexFile1, true) then
      begin
        AddLogStr('Проблема при сохранении файла индексов, файл не сохранен ' + DescriptionIndexFile1);
        Result := False;
      end
    else
      DescriptionBrandList.SaveToFile(DescriptionIndexFile1);

    if not TryOpenFile(DescriptionIndexFile2, true) then
      begin
        AddLogStr('Проблема при сохранении файла индексов, файл не сохранен ' + DescriptionIndexFile2);
        Result := False;
      end
    else
      DescriptionSeriesList.SaveToFile(DescriptionIndexFile2);

  NotesList.Clear;
  for I := 0 to mainFrm.chklstNotes.Items.Count - 1 do
     NotesList.Add(mainFrm.chklstNotes.Items[i]);
  if not TryOpenFile(NotesIndexFile, true) then
    begin
      AddLogStr('Проблема при сохранении файла индексов, файл не сохранен ' + NotesIndexFile);
      Result := False;
    end
  else
    NotesList.SaveToFile(NotesIndexFile);

  if MEM then
    try
      repeat
        s := TryOpenFile(MainDBFile, True);
        if not S then
          begin
            AddLogStr(' #101 - Ошибка открытия файла БД ' + MainDBFile + ' основная БД не записана');
            if MessageDlg('База данных может быть утеряна. Закройте программы препятстующие доступу к файлу ' + MainDBFile + '. Повторить попытку!', mtError, [mbYes, mbNo], 0) = 7 then exit;
          end;
      until S;
      DBFile := TFileStream.Create(MainDBFile, fmCreate);
      Result := S;
      for I := 0 to FTList.Count - 1 do
        begin
          with FinancyTransaction do
          begin
            Account          := PTFinancyTransaction(FTList.Items[i]).Account;
            Date             := PTFinancyTransaction(FTList.Items[i]).Date;
            EndDate          := PTFinancyTransaction(FTList.Items[i]).EndDate;
            Flag             := PTFinancyTransaction(FTList.Items[i]).Flag;
            Price            := PTFinancyTransaction(FTList.Items[i]).Price;
            Price2           := PTFinancyTransaction(FTList.Items[i]).price2;
            Number           := PTFinancyTransaction(FTList.Items[i]).Number;
            Discount         := PTFinancyTransaction(FTList.Items[i]).Discount;
            AbsProc          := PTFinancyTransaction(FTList.Items[i]).AbsProc;
            Summ             := PTFinancyTransaction(FTList.Items[i]).Summ;
            Currency         := PTFinancyTransaction(FTList.Items[i]).Currency;
            Category         := PTFinancyTransaction(FTList.Items[i]).Category;
            Description      := PTFinancyTransaction(FTList.Items[i]).Description;
            Persona          := PTFinancyTransaction(FTList.Items[i]).Persona;
            Comment          := PTFinancyTransaction(FTList.Items[i]).Comment;
            Contractor       := PTFinancyTransaction(FTList.Items[i]).Contractor;
            Event            := PTFinancyTransaction(FTList.Items[i]).Event;
            BillNumber       := PTFinancyTransaction(FTList.Items[i]).BillNumber;
            IDkey            := PTFinancyTransaction(FTList.Items[i]).IDkey;
            Measure          := PTFinancyTransaction(FTList.Items[i]).Measure;
            Priority         := PTFinancyTransaction(FTList.Items[i]).Priority;
            Packing          := PTFinancyTransaction(FTList.Items[i]).Packing;
          end;
          DBFile.Write(FinancyTransaction, SizeOf(FinancyTransaction));
        end;
    finally
      DBFile.Free;
    end;
end;


function Finish : Boolean;
var
  i : Integer;
begin
  Result := False;
  SaveLog;
  TransactionDoBackUp;
  TransactionSaveDB;
  for I := 1 to FTList.Count do
    Dispose(PTFinancyTransaction(FTList.Items[I - 1]));
  FTList.Free;
  AccountList.Free;
  CurrencyList.Free;
  CategoryList.Free;
  PersonaList.Free;
  ContractorList.Free;
  EventList.Free;

  CommentList.Free;
  DescriptionNameList.Free;
  DescriptionBrandList.Free;
  DescriptionSeriesList.Free;
  NotesList.Free;
  DeleteFile(PChar(DBWorkDir + 'started'));
  Result := True;
end;

end.



