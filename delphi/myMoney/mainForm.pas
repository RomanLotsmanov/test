unit mainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ImgList, Grids, ExtCtrls, myMoneyDBEngine, ToolWin,
  ComCtrls, Menus, ActnList, TeEngine, Series, TeeProcs, Chart, DateUtils, Buttons,
  CheckLst, VirtualTrees;

type
  TmainFrm = class(TForm)
    pnlCalendar: TPanel;
    ActionImgLst: TImageList;
    tlbMainToolbar: TToolBar;
    mainMenu: TMainMenu;
    N1: TMenuItem;
    ActionList: TActionList;
    btnSafeBox: TToolButton;
    btnAccount: TToolButton;
    btnCallendar: TToolButton;
    btnBasket: TToolButton;
    btnMoneyBox: TToolButton;
    btnPrice: TToolButton;
    btnAnalitics: TToolButton;
    btnSpliter: TToolButton;
    btnAbout: TToolButton;
    StringGrid1: TStringGrid;
    pnlAccount: TPanel;
    pnlSafeBox: TPanel;
    pnlBasket: TPanel;
    pnlMoneyBox: TPanel;
    pnlPrice: TPanel;
    pnlAnalytics: TPanel;
    lvAccount: TListView;
    pm1: TPopupMenu;
    N11: TMenuItem;
    N21: TMenuItem;
    N2: TMenuItem;
    l1: TImageList;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    N10: TMenuItem;
    N12: TMenuItem;
    cht1: TChart;
    pnlstatus: TPanel;
    pb1: TProgressBar;
    lblstatus: TLabel;
    N13: TMenuItem;
    N14: TMenuItem;
    N15: TMenuItem;
    N16: TMenuItem;
    N17: TMenuItem;
    N18: TMenuItem;
    N19: TMenuItem;
    psrsSeries1: TPieSeries;
    btn1: TBitBtn;
    lvTotals: TListView;
    pnl6: TPanel;
    cbbTotals: TComboBoxEx;
    cht2: TChart;
    lnsrsSeries1: TLineSeries;
    lnsrsSeries2: TLineSeries;
    lnsrsSeries3: TLineSeries;
    pnl4: TPanel;
    spl1: TSplitter;
    pnl7: TPanel;
    cal1: TMonthCalendar;
    chklstNotes: TCheckListBox;
    lbl1: TLabel;
    lbl2: TLabel;
    vrtldrwtrPrice: TVirtualDrawTree;
    pnl8: TPanel;
    edtPriceNotes: TEdit;
    globalFilter: TPanel;
    lbl3: TLabel;
    dtpFromDate: TDateTimePicker;
    dtpToDate: TDateTimePicker;
    cbbIncision: TComboBoxEx;
    cbbPeriod: TComboBoxEx;
    btnDecDate: TBitBtn;
    btnIncDate: TBitBtn;
    procedure btnSafeBoxClick(Sender: TObject);
    procedure btnAccountClick(Sender: TObject);
    procedure btnCallendarClick(Sender: TObject);
    procedure btnBasketClick(Sender: TObject);
    procedure btnMoneyBoxClick(Sender: TObject);
    procedure btnPriceClick(Sender: TObject);
    procedure btnAnaliticsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure btnAboutClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure N11Click(Sender: TObject);
    procedure N21Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure rzdtFromDateChange(Sender: TObject);
    procedure rzdtToDateChange(Sender: TObject);
    procedure CBoxIncisionChange(Sender: TObject);
    procedure dtpFromDateChange(Sender: TObject);
    procedure dtpToDateChange(Sender: TObject);
    procedure lvAccountCustomDrawItem(Sender: TCustomListView; Item: TListItem;
      State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure cbbPeriodChange(Sender: TObject);
    procedure StringGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure N12Click(Sender: TObject);
    procedure N10Click(Sender: TObject);
    procedure lvAccountCompare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure StringGrid1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure StringGrid1DblClick(Sender: TObject);
    procedure lvAccountDblClick(Sender: TObject);
    procedure btnDecDateClick(Sender: TObject);
    procedure btnIncDateClick(Sender: TObject);
    procedure cbbAnalitycsIncisionChange(Sender: TObject);
    procedure cht1ClickSeries(Sender: TCustomChart; Series: TChartSeries;
      ValueIndex: Integer; Button: TMouseButton; Shift: TShiftState; X,
      Y: Integer);
    procedure btn1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lvTotalsCustomDrawItem(Sender: TCustomListView; Item: TListItem;
      State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure chkIncomingClick(Sender: TObject);
    procedure btnPriceNotesRightButtonClick(Sender: TObject);
    procedure chklstNotesClickCheck(Sender: TObject);
    procedure btnPriceNotesKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lvAccountKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure vrtldrwtrPriceDrawNode(Sender: TBaseVirtualTree;
      const PaintInfo: TVTPaintInfo);
    procedure cbbIncisionChange(Sender: TObject);
  private
    { Private declarations }
  public
   { Public declarations }
  protected
    procedure CreateParams(var p: TCreateParams); override;        //-- корректное сворачивание формы
    procedure WMSysCommand(var m: TMessage); message WM_SYSCOMMAND;
  end;

  TGradientKind = (gkHorz, gkVert);

var
  mainFrm     : TmainFrm;
  T           : Boolean;
  Column, Row : Integer;
  run         : Boolean = false;
  CharDeep    : Integer = 0;
  ChartSDeep  : Integer = 0;

implementation

{$R *.dfm}

uses TransactionAdd, about, Math, Options;

procedure TmainFrm.CreateParams(var p: TCreateParams);
begin
  inherited;
  p.WndParent := 0;
end;

procedure TmainFrm.WMSysCommand(var m: TMessage);
begin
  m.Result := DefWindowProc(Handle, m.Msg, m.wParam, m.lParam);
end;

//------------------------------------------------------------------------------
// Рисует градиент.
//------------------------------------------------------------------------------
procedure GradFill(DC: HDC; ARect: TRect; ClrTopLeft, ClrBottomRight: TColor;
  Kind: TGradientKind);
var
  GradientCache: array [0..16] of array of Cardinal;
  NextCacheIndex: Integer;

  function FindGradient(Size: Integer; CL, CR: Cardinal): Integer;
  begin
    Assert(Size > 0);
    Result := 16 - 1;
    while Result >= 0 do
    begin
      if (Length(GradientCache[Result]) = Size) and
        (GradientCache[Result][0] = CL) and
        (GradientCache[Result][Length(GradientCache[Result]) - 1] = CR) then Exit;
      Dec(Result);
    end;
  end;

  function MakeGradient(Size: Integer; CL, CR: Cardinal): Integer;
  var
    R1, G1, B1: Integer;
    R2, G2, B2: Integer;
    R, G, B: Integer;
    I: Integer;
    Bias: Integer;
  begin
    Assert(Size > 0);
    Result := NextCacheIndex;
    Inc(NextCacheIndex);
    if NextCacheIndex >= 16 then NextCacheIndex := 0;
    R1 := CL and $FF;
    G1 := CL shr 8 and $FF;
    B1 := CL shr 16 and $FF;
    R2 := Integer(CR and $FF) - R1;
    G2 := Integer(CR shr 8 and $FF) - G1;
    B2 := Integer(CR shr 16 and $FF) - B1;
    SetLength(GradientCache[Result], Size);
    Dec(Size);
    Bias := Size div 2;
    if Size > 0 then
      for I := 0 to Size do
      begin
        R := R1 + (R2 * I + Bias) div Size;
        G := G1 + (G2 * I + Bias) div Size;
        B := B1 + (B2 * I + Bias) div Size;
        GradientCache[Result][I] := R + G shl 8 + B shl 16;
      end
    else
    begin
      R := R1 + R2 div 2;
      G := G1 + G2 div 2;
      B := B1 + B2 div 2;
      GradientCache[Result][0] := R + G shl 8 + B shl 16;
    end;
  end;

  function GetGradient(Size: Integer; CL, CR: Cardinal): Integer;
  begin
    Result := FindGradient(Size, CL, CR);
    if Result < 0 then Result := MakeGradient(Size, CL, CR);
  end;

var
  Size, I, Start, Finish: Integer;
  GradIndex: Integer;
  R, CR: TRect;
  Brush: HBRUSH;
begin
  NextCacheIndex := 0;
  if not RectVisible(DC, ARect) then
    Exit;
  ClrTopLeft := ColorToRGB(ClrTopLeft);
  ClrBottomRight := ColorToRGB(ClrBottomRight);
  GetClipBox(DC, CR);
  if Kind = gkHorz then
  begin
    Size := ARect.Right - ARect.Left;
    if Size <= 0 then Exit;
    Start := 0; Finish := Size - 1;
    if CR.Left > ARect.Left then Inc(Start, CR.Left - ARect.Left);
    if CR.Right < ARect.Right then Dec(Finish, ARect.Right - CR.Right);
    R := ARect; Inc(R.Left, Start); R.Right := R.Left + 1;
  end
  else begin
    Size := ARect.Bottom - ARect.Top;
    if Size <= 0 then Exit;
    Start := 0; Finish := Size - 1;
    if CR.Top > ARect.Top then Inc(Start, CR.Top - ARect.Top);
    if CR.Bottom < ARect.Bottom then Dec(Finish, ARect.Bottom - CR.Bottom);
    R := ARect; Inc(R.Top, Start); R.Bottom := R.Top + 1;
  end;
  GradIndex := GetGradient(Size, ClrTopLeft, ClrBottomRight);
  for I := Start to Finish do
  begin
    Brush := CreateSolidBrush(GradientCache[GradIndex][I]);
    Windows.FillRect(DC, R, Brush);
    OffsetRect(R, Integer(Kind = gkHorz), Integer(Kind = gkVert));
    DeleteObject(Brush);
  end;
end;


procedure DrawPrice;
var
  i: Integer;
  NewNode, root : PVirtualNode;
  NodeData: PItemNode;
begin
  try
    mainFrm.vrtldrwtrPrice.Clear;
    mainFrm.vrtldrwtrPrice.BeginUpdate;
    root := mainFrm.vrtldrwtrPrice.AddChild(nil);
    NodeData := mainFrm.vrtldrwtrPrice.GetNodeData(root);
    with NodeData^ do
      begin
        ID := 0;
        TType := ID_SPEND;
      end;
    for I := 0 to TransactionGetCount - 1 do
      begin
        TransactionRead(i);
        if (FinancyTransaction.Date >= mainFrm.dtpFromDate.Date) and (FinancyTransaction.Date <= mainFrm.dtpToDate.Date) then
        begin
          NewNode := mainFrm.vrtldrwtrPrice.AddChild(root);
          NodeData := mainFrm.vrtldrwtrPrice.GetNodeData(NewNode);
          with NodeData^ do
          begin
            ID := FinancyTransaction.IDkey;
            TType := ID_REC;
          end;
        end;
      end;

    root := mainFrm.vrtldrwtrPrice.AddChild(nil);
    NodeData := mainFrm.vrtldrwtrPrice.GetNodeData(root);
    with NodeData^ do
      begin
        ID := 0;
        TType := ID_INCOMING;
      end;
  finally
    mainFrm.vrtldrwtrPrice.EndUpdate;
  end;
  mainFrm.vrtldrwtrPrice.FullExpand(nil);
end;

procedure ReSizeGrid;
var
  i, j, k, dday                       : integer;
  year, month, dd                     : Word;
  date1, cellDate                     : TDateTime;
  newM                                : Boolean;
  Cell                                : string;
  balance, summ, spend, income, PrevBalance, TB : Extended;
begin
  if t or (not run) then Exit;
  PrevBalance := 0;
  mainFrm.Stringgrid1.RowHeights[0] := 20;
  for i := 0 to mainFrm.Stringgrid1.colcount - 1 do
    begin
      for j := 1 to mainFrm.Stringgrid1.rowcount - 1 do
         mainFrm.Stringgrid1.RowHeights[j] := (mainFrm.StringGrid1.Height - mainFrm.Stringgrid1.RowHeights[0]) div (mainFrm.StringGrid1.RowCount - 1) - 2;
      mainFrm.Stringgrid1.colWidths[i] := mainFrm.StringGrid1.Width div mainFrm.StringGrid1.ColCount - 2;
    end;
  mainFrm.Stringgrid1.Cells[0,0] := 'Понедельник';
  mainFrm.Stringgrid1.Cells[1,0] := 'Вторник';
  mainFrm.Stringgrid1.Cells[2,0] := 'Среда';
  mainFrm.Stringgrid1.Cells[3,0] := 'Четверг';
  mainFrm.Stringgrid1.Cells[4,0] := 'Пятница';
  mainFrm.Stringgrid1.Cells[5,0] := 'Суббота';
  mainFrm.Stringgrid1.Cells[6,0] := 'Воскресенье';
  date1 := StartOfTheMonth(mainFrm.dtpFromDate.Date);
  dday := DaysInMonth(IncMonth(Date1, -1)) - (DayOfTheWeek(date1) -  2);
  NewM := False;
  DecodeDate(Date1, Year, Month, dd);
  if month > 1 then
    Dec(Month)
  else
     begin
       Dec(Year);
       month := 12;
     end;
                             // Date>0:item1>1:item2
  FTList.Sort(DateCompare);
  for i := 1 to mainFrm.Stringgrid1.colcount - 1 do
    for j := 0 to mainFrm.Stringgrid1.rowcount do
      begin
        if (j + 1 = DayOfTheWeek(date1)) and (i = 1) then
          begin
            dDay := 1;
            NewM := True;
          end;
        if (dday = DaysInMonth(Date1) + 1) and newM then dday := 1;
        if dday = 1 then Inc(Month);
        if month = 13 then
          begin
            month := 1;
            Inc(Year);
          end;
        dd := dday;
        cellDate := EncodeDate(Year, Month, dd);
        cell := DateToStr(cellDate) + '>';
        if (i = 1) and (j = 0) then          //-- первый день в ячейке для подсчета баланса
          PrevBalance := Totalbalance(cellDate);
        income := 0;
        spend := 0;
        balance := 0;
        case mainFrm.cbbIncision.ItemIndex of
        0: for k := 0 to TransactionGetCount - 1 do         //-- транзакции
             begin
               TransactionRead(k);
               if FinancyTransaction.Date = cellDate then
                 begin
                   if FinancyTransaction.Flag = TINCOME then
                     begin
                       income := income + FinancyTransaction.Summ;
                       cell := Cell + IntToStr(ImageIndexGetIndex(CategoryList[FinancyTransaction.Category])) + ':' + DescriptionNameList[FinancyTransaction.Description.Name] + ' ' + DescriptionBrandList[FinancyTransaction.Description.Brand] + ' ' + DescriptionSeriesList[FinancyTransaction.Description.Series] + ' | +' + MoneyFormat(FinancyTransaction.Summ) + '>';
                     end;
                   if FinancyTransaction.Flag = TSPENDING then
                     begin
                       spend := spend + FinancyTransaction.Summ;
                       cell := Cell + IntToStr(ImageIndexGetIndex(CategoryList[FinancyTransaction.Category])) + ':' + DescriptionNameList[FinancyTransaction.Description.Name] + ' ' + DescriptionBrandList[FinancyTransaction.Description.Brand] + ' ' + DescriptionSeriesList[FinancyTransaction.Description.Series] + ' | -' + MoneyFormat(FinancyTransaction.Summ) + '>';
                     end;
                 end;
             end;
        1: for k := 0 to CategoryList.Count - 1 do        //-- категории
             begin
               summ := GetTotalSummByIndex(k, CATEGORY_INDEX, cellDate, cellDate);
               if summ <> 0 then
                 Cell := Cell + IntToStr(ImageIndexGetIndex(CategoryList[k])) + ':' + GetSubString(ImageIndexGetString(CategoryList[k]),GetSubElementsCount(CategoryList[k])) + ' | ' + MoneyFormat(Summ) + '>';
               if summ < 0 then
                 spend := spend + (summ * -1);
               if summ  > 0 then
                 income := income + summ;
             end;
        2: for k := 0 to CategoryList.Count - 1 do        //-- событие
             begin
               summ := GetTotalSummByIndex(k, EVENT_INDEX, cellDate, cellDate);
               if summ <> 0 then
                 Cell := Cell + IntToStr(ImageIndexGetIndex(EventList[k])) + ':' + ImageIndexGetString(EventList[k])+ ' | ' + MoneyFormat(Summ) + '>';
               if summ < 0 then
                 spend := spend + (summ * -1);
               if summ  > 0 then
                 income := income + summ;
             end;
        3: for k := 0 to CategoryList.Count - 1 do        //-- персона
             begin
               summ := GetTotalSummByIndex(k, PERSONA_INDEX, cellDate, cellDate);
               if summ <> 0 then
                 Cell := Cell + IntToStr(ImageIndexGetIndex(PersonaList[k])) + ':' + ImageIndexGetString(PersonaList[k])+ ' | ' + MoneyFormat(Summ) + '>';
               if summ < 0 then
                 spend := spend + (summ * -1);
               if summ  > 0 then
                 income := income + summ;
             end;
        4: for k := 0 to CategoryList.Count - 1 do        //-- персона
             begin
               summ := GetTotalSummByIndex(k, CONTRACTOR_INDEX, cellDate, cellDate);
               if summ <> 0 then
                 Cell := Cell + IntToStr(ImageIndexGetIndex(ContractorList[k])) + ':' + ImageIndexGetString(ContractorList[k])+ ' | ' + MoneyFormat(Summ) + '>';
               if summ < 0 then
                 spend := spend + (summ * -1);
               if summ  > 0 then
                 income := income + summ;
             end;
        end;
        if spend > income then
          begin
            balance := spend - income;
            TB := Totalbalance(cellDate);
            if TB > 0 then
              Cell := Cell + '999:' + '+' + MoneyFormat(TB) + ' | -' + MoneyFormat(balance)
            else
              Cell := Cell + '999:' + MoneyFormat(TB) + ' | -' + MoneyFormat(balance)
          end;
{ DONE : косяк условие не расчитано на чистый доход }
        if (spend <= income) and ((spend <> 0) or (income <> 0)) then
          begin
            balance := income - spend;
            TB := Totalbalance(cellDate);
            if TB > 0 then
              Cell := Cell + '999:' + '+' + MoneyFormat(TB) + ' | +' + MoneyFormat(balance)
            else
              Cell := Cell + '999:' + MoneyFormat(TB) + ' | +' + MoneyFormat(balance)
          end;
        if (spend = 0) and (income = 0)then
          if PrevBalance > 0 then
            Cell := Cell + '999:' + '+' + MoneyFormat(PrevBalance) + ' | ' + MoneyFormat(0)
          else
            Cell := Cell + '999:' + MoneyFormat(PrevBalance) + ' |  ' + MoneyFormat(0)
        else
          PrevBalance := Totalbalance(cellDate);
        mainFrm.Stringgrid1.Cells[j, i] := cell;
        inc(dday)
      end;
end;

procedure DrawQuotes;
const
  CurrencyIdenty : array[1..12] of string[9] = ('USD ЦБ РФ','EUR ЦБ РФ','AUD ЦБ РФ','GBP ЦБ РФ','BYR ЦБ РФ','DKK ЦБ РФ','KZT ЦБ РФ','CAD ЦБ РФ','NOK ЦБ РФ','UAH ЦБ РФ','CHF ЦБ РФ','JPY ЦБ РФ');
  CurrencyNames  : array[1..12] of string[25] = ('Доллар США','ЕВРО','Австралийский доллар','Англ. фунт стерлингов','1000 Белорусских рублей','10 Датских крон',
                                                 'Казахский тенге','Канадский доллар','Норвежских крон','Украинских гривен','Швейцарский франк','Японских иен');
var
  S             : TStringList;
  P, I, j       : integer;
  Value         : string;
  item          : TListItem;
  spend, income : Extended;
  d             : TDate;
begin
  if not Run then Exit;
  mainFrm.lvTotals.Items.Clear;
  S := TStringList.Create;
  if FileExists(DBWorkDir + 'rbk\' + DateToStr(Date) + '.csv') then
    S.LoadFromFile(DBWorkDir + 'rbk\' + DateToStr(Date) + '.csv');
  mainFrm.lnsrsSeries1.Clear;
  mainFrm.lnsrsSeries2.Clear;
  mainFrm.lnsrsSeries3.Clear;
  case mainFrm.cbbTotals.ItemIndex of
    0:begin
        item := mainFrm.lvTotals.Items.Add;
        item.Caption := 'Чистый доход';
        income := RoundTo(GetTotalSummByType(TINCOME, mainFrm.dtpFromDate.Date, mainFrm.dtpToDate.Date), -2);
        item.SubItems.Add('+' + FloatToStr(income) + ' рублей');
        item := mainFrm.lvTotals.Items.Add;
        item.Caption := 'Чистый расход';
        spend := RoundTo(GetTotalSummByType(TSPENDING, mainFrm.dtpFromDate.Date, mainFrm.dtpToDate.Date), -2);
        item.SubItems.Add('-' + FloatToStr(spend) + ' рублей');
        item := mainFrm.lvTotals.Items.Add;
        item.Caption := 'Баланс';
        item.SubItems.Add(FloatToStr(Totalbalance(mainFrm.dtpToDate.Date)) + ' рублей');
        item := mainFrm.lvTotals.Items.Add;
        item.Caption := 'Баланс за период';
        item.SubItems.Add(FloatToStr(income - spend) + ' рублей');
        item := mainFrm.lvTotals.Items.Add;
        item.Caption := 'Оборот';
        item.SubItems.Add(FloatToStr(RoundTo(GetTotalSummByType(TALL, mainFrm.dtpFromDate.Date, mainFrm.dtpToDate.Date), -2)) + ' рублей');
        d := mainFrm.dtpFromDate.Date;
        repeat
           mainFrm.lnsrsSeries1.AddXY(d, GetTotalSummByType(TINCOME, d, d), DateToStr(d), clGreen);
           mainFrm.lnsrsSeries2.AddXY(d, GetTotalSummByType(TSPENDING, d, d), '', clRed);
           mainFrm.lnsrsSeries3.AddXY(d, Totalbalance(d), '', clBlue);
           d:= IncDay(d, 1);
        until d > mainFrm.dtpToDate.Date;
      end;
    1:begin
        P := S.IndexOf('#---- Курсы ЦБ РФ ----');
        if not (P = -1) then
          begin
          for j := 1 to 12 do
            begin
             Value := '';
             P := S.IndexOf('#---- Курсы ЦБ РФ ----');
             for i := 0 to 17 do
              begin
               inc(P);
               if Pos(CurrencyIdenty[j], S.Strings[p]) > 0 then
                 Value := S.Strings[p];
              end;
              Delete(Value, 1, pos('/', Value));   // USD ЦБ РФ,1 Доллар США,27/02,31.6065,0.019
              Delete(Value, 1, pos(',', Value));
              Delete(Value, pos(',', Value), 20);
              item := mainFrm.lvTotals.Items.Add;
              item.Caption := CurrencyNames[j];
              item.SubItems.Add(Value + ' рублей');
            end;
          end;
      end;
  end;
{ DONE : Сделать в цикле по всем валютам и показателям+ график }
  S.Free;
end;


procedure DrawAnalitics;
var
  i, k, j              : Integer;
  summ, percent, total : Extended;
  StartDate, endDate   : TDateTime;
  s, s1                : string;
begin
  StartDate := mainFrm.dtpFromDate.Date;
  EndDate := mainFrm.dtpToDate.Date;
  mainFrm.psrsSeries1.Clear;
  Total := GetTotalSummByType(TSPENDING, StartDate, EndDate);
  if total = 0 then Exit;
  Randomize;
  s := 'Нет';
  summ := 0;
  k := 0;
  case mainFrm.cbbIncision.ItemIndex of
{ DONE : Переделать 0 }
    0:begin
        summ := RoundTo(GetTotalSummByType(TINCOME, StartDate, endDate), -1);
        total := GetTotalSummByType(TALL, StartDate, endDate);
        percent := RoundTo(summ /(total/100), -1);
        mainFrm.psrsSeries1.AddPie(summ, ' ' + FloatToStr(percent) + '% '  + ' доходы', clGreen);
        summ := RoundTo(GetTotalSummByType(TSPENDING, StartDate, endDate), -1);
        total := GetTotalSummByType(TALL, StartDate, endDate);
        percent := RoundTo(summ /(total/100), -1);
        mainFrm.psrsSeries1.AddPie(summ, ' ' + FloatToStr(percent) + '% '  + ' расходы', clRed);
      end;
    1:for I := 0 to CategoryList.Count - 1 do  //-- категории
        begin
          if Pos(s, CategoryList[i]) <> 0 then
            begin
              if CharDeep = 0 then
                summ := summ + GetTotalSummByIndex(i, CATEGORY_INDEX, StartDate, EndDate)
              else  //-- расчитать сумму вглубь
                begin
                  j := i;
                  repeat
                    summ := summ + GetTotalSummByIndex(j, CATEGORY_INDEX, StartDate, EndDate);
                    inc(j);
                    if j = CategoryList.Count - 1 then Break;
                  until GetSubElementsCount(CategoryList[j]) <= CharDeep;
                end;
              if (S = 'Нет') and (CharDeep = 0) then
                begin
                  percent := RoundTo(summ /(total/100), -1);
                  if summ <> 0 then
                  //  if mainFrm.chkIncoming.Checked or (summ < 0) then       //-- с доходами
                      mainFrm.psrsSeries1.AddPie(summ, ' ' + FloatToStr(percent) + '% ' + s, Random(clWhite));
                  summ := 0;
                end;
            if (GetSubElementsCount(CategoryList[i + 1]) < CharDeep) and (GetSubElementsCount(CategoryList[i]) = CharDeep) and (k = ChartSDeep) then
              inc(k);
            if (GetSubElementsCount(CategoryList[i]) = CharDeep) and (k = ChartSDeep) and (CharDeep <> 0) and (summ <> 0) then
              begin
                s1 := GetSubString(ImageIndexGetString(CategoryList[i]), GetSubElementsCount(CategoryList[i]));
               // if mainFrm.chkIncoming.Checked or (summ < 0) then
                  mainFrm.psrsSeries1.AddPie(summ, ' ' + {FloatToStr(percent) + '% ' +} s1, Random(clWhite));
                summ := 0;
              end;
              Continue;
            end;
          if (GetSubElementsCount(CategoryList[i]) = CharDeep - 1) {or (i = CategoryList.Count - 1)} or (CharDeep = 0) then
            begin                                      //-- значит базовая категория запомнить ее и суммировать по ней все подкатегории
              if summ <> 0 then
                begin
                  s1 := s;
                  inc(k);
                  if Length(s1) > maxSChart then
                    begin
                      Delete(S1, maxSChart, Length(s1) - (maxSChart - 1));
                      S1 := S1 + '..';
                    end;
                  percent := RoundTo(summ /(total/100), -1);
                  if (CharDeep = 0) {or (i = CategoryList.Count - 1)} then
                    mainFrm.psrsSeries1.AddPie(summ, ' ' + FloatToStr(percent) + '% ' + s1, Random(clWhite));
                end;
              summ := GetTotalSummByIndex(i, CATEGORY_INDEX, StartDate, EndDate);
              s := ':' + ImageIndexGetString(CategoryList[i]);
            end;
        end;
    2:for I := 0 to CategoryList.Count - 1 do  //-- категори раскрытые где не 0
        begin
          summ := GetTotalSummByIndex(i, CATEGORY_INDEX, StartDate, EndDate);
          percent := RoundTo(summ /(total/100), -1);
          if summ <> 0 then
            begin
              s := GetSubString(ImageIndexGetString(CategoryList[i]), GetSubElementsCount(CategoryList[i]));
              if Length(s) > maxSChart then
                begin
                  Delete(S, maxSChart, Length(s) - (maxSChart - 1));
                  S := S + '..';
                end;
             // if mainFrm.chkIncoming.Checked or (summ < 0) then
                mainFrm.psrsSeries1.AddPie(summ, ' ' + FloatToStr(percent) + '% ' + s, Random(clWhite));
            end;
        end;
    3:for I := 0 to EventList.Count - 1 do  //-- события
        begin
          summ := GetTotalSummByIndex(i, EVENT_INDEX, StartDate, EndDate);
          percent := RoundTo(summ /(total/100), -1);
          if summ <> 0 then
            begin
              s := ImageIndexGetString(EventList[i]);
              if Length(s) > maxSChart then
                begin
                  Delete(S, maxSChart, Length(s) - (maxSChart - 1));
                  S := S + '..';
                end;
              mainFrm.psrsSeries1.AddPie(summ, ' ' + FloatToStr(percent) + '% ' + s, Random(clWhite));
            end;
        end;
    4:for I := 0 to PersonaList.Count - 1 do
        begin
          summ := GetTotalSummByIndex(i, PERSONA_INDEX, StartDate, EndDate);
          percent := RoundTo(summ /(total/100), -1);
          if summ <> 0 then
            begin
              s := ImageIndexGetString(PersonaList[i]);
              if Length(s) > maxSChart then
                begin
                  Delete(S, maxSChart, Length(s) - (maxSChart - 1));
                  S := S + '..';
                end;
              mainFrm.psrsSeries1.AddPie(summ, ' ' + FloatToStr(percent) + '% '  + s, Random(clWhite));
            end;
        end;
    5:for I := 0 to ContractorList.Count - 1 do
        begin
          summ := GetTotalSummByIndex(i, CONTRACTOR_INDEX, StartDate, EndDate);
          percent := RoundTo(summ /(total/100), -1);
          if summ <> 0 then
            begin
              s := ImageIndexGetString(ContractorList[i]);
              if Length(s) > maxSChart then
                begin
                  Delete(S, maxSChart, Length(s) - (maxSChart - 1));
                  s := s + '..';
                end;
              mainFrm.psrsSeries1.AddPie(summ, ' ' + FloatToStr(percent) + '% ' + s, Random(clWhite));
            end;
        end;
  end;

end;


procedure HideAllPanel;
begin
   mainFrm.pnlSafeBox.Visible := False;
   mainFrm.pnlAccount.Visible := False;
   mainFrm.pnlCalendar.Visible := False;
   mainFrm.pnlBasket.Visible := False;
   mainFrm.pnlMoneyBox.Visible := False;
   mainFrm.pnlPrice.Visible := False;
   mainFrm.pnlAnalytics.Visible := False;
end;


procedure DrawAccountsTransaction;
var
  i               : Integer;
  item            : TListItem;
  incoming, spend : Extended;
begin
  if t or (not run) then Exit;
  mainFrm.lvAccount.Clear;
  mainFrm.lvAccount.Columns[7].Width := ColAccEventWidth;
  mainFrm.lvAccount.Columns[8].Width := ColAccPersonaWidth;
  mainFrm.lvAccount.SortType := stText;
  incoming := 0;
  spend := 0;
  for I := 0 to TransactionGetCount - 1 do
    begin
      TransactionRead(i);
      if (FinancyTransaction.Date >= mainFrm.dtpFromDate.Date) and (FinancyTransaction.Date <= mainFrm.dtpToDate.Date) then
        begin
          item := mainFrm.lvAccount.Items.Add;
          item.Caption := DateToStr(FinancyTransaction.Date);
          case FinancyTransaction.Flag of          { TODO : Четко определить тип }
          TINCOME:begin
                    incoming := incoming + FinancyTransaction.Summ;
                    item.ImageIndex := 214;
                  end;
          TSPENDING:begin
                      spend := spend + FinancyTransaction.Summ;
                      item.ImageIndex := 215;
                    end;
          end;
//   item.ImageIndex := ImageIndexGetIndex(CategoryList[FinancyTransaction.Category]);

          item.SubItems.Add(DescriptionNameList[FinancyTransaction.Description.Name] + ' ' + DescriptionBrandList[FinancyTransaction.Description.Brand] + ' ' + DescriptionSeriesList[FinancyTransaction.Description.Series]);
          if FinancyTransaction.Flag = TSPENDING then
            item.SubItems.Add('-' + MoneyFormat(FinancyTransaction.Price))
          else
            item.SubItems.Add('+' + MoneyFormat(FinancyTransaction.Price));
          case FinancyTransaction.Measure of
          MNUMBER      : item.SubItems.Add(FloatToStr(FinancyTransaction.Number) + ' шт.');
          MSERVICE     : item.SubItems.Add(FloatToStr(FinancyTransaction.Number) + ' усл.');
          MPACK        : item.SubItems.Add(FloatToStr(FinancyTransaction.Number) + ' упак.');
          MLITRE       : item.SubItems.Add(FloatToStr(FinancyTransaction.Number) + ' Л.');
          MMLITRE      : item.SubItems.Add(FloatToStr(FinancyTransaction.Number) + ' мЛ.');
          MKILOGRAM    : item.SubItems.Add(FloatToStr(FinancyTransaction.Number) + ' Кг.');
          MGRAM        : item.SubItems.Add(FloatToStr(FinancyTransaction.Number) + ' г.');
          MMGRAM       : item.SubItems.Add(FloatToStr(FinancyTransaction.Number) + ' мг.');
          MMETER       : item.SubItems.Add(FloatToStr(FinancyTransaction.Number) + ' м.');
          MSMETER      : item.SubItems.Add(FloatToStr(FinancyTransaction.Number) + ' см.');
          MKMETER      : item.SubItems.Add(FloatToStr(FinancyTransaction.Number) + ' км.');
          MCUBICMETER  : item.SubItems.Add(FloatToStr(FinancyTransaction.Number) + ' м3.');
          MSQUAREMETER : item.SubItems.Add(FloatToStr(FinancyTransaction.Number) + ' м2.');
          MMINUTE      : item.SubItems.Add(FloatToStr(FinancyTransaction.Number) + ' мин.');
          MHOURS       : item.SubItems.Add(FloatToStr(FinancyTransaction.Number) + ' ч.');
          MDAY         : item.SubItems.Add(FloatToStr(FinancyTransaction.Number) + ' день');
          MWEEK        : item.SubItems.Add(FloatToStr(FinancyTransaction.Number) + ' нед.');
          MMONTH       : item.SubItems.Add(FloatToStr(FinancyTransaction.Number) + ' мес.');
          MYEAR        : item.SubItems.Add(FloatToStr(FinancyTransaction.Number) + ' год');
          QUALITY      : item.SubItems.Add(FloatToStr(FinancyTransaction.Number) + ' Качество');
          end;
          if FinancyTransaction.AbsProc then
            item.SubItems.Add(FloatToStr(FinancyTransaction.Discount) + ' %')
          else
            item.SubItems.Add(FloatToStr(FinancyTransaction.Discount));
          if FinancyTransaction.Flag = TSPENDING then
            item.SubItems.Add('-' + MoneyFormat(FinancyTransaction.Summ))
          else
            item.SubItems.Add('+' + MoneyFormat(FinancyTransaction.Summ));

          item.SubItemImages[0] := ImageIndexGetIndex(CategoryList[FinancyTransaction.Category]);
          item.SubItemImages[5] := ImageIndexGetIndex(CategoryList[FinancyTransaction.Category]);

          item.SubItems.Add(GetSubString(ImageIndexGetString(CategoryList[FinancyTransaction.Category]),GetSubElementsCount(CategoryList[FinancyTransaction.Category])));
          item.SubItems.Add(ImageIndexGetString(EventList[FinancyTransaction.Event]));
          item.SubItems.Add(ImageIndexGetString(PersonaList[FinancyTransaction.Persona]));
          item.SubItems.Add(ImageIndexGetString(ContractorList[FinancyTransaction.Contractor]));
          item.SubItems.Add(CommentList[FinancyTransaction.Comment]);
          item.SubItems.Add(IntToStr(FinancyTransaction.IDkey));
        end;
    end;
  item := mainFrm.lvAccount.Items.Add;
  item.Caption := '';
  item.SubItems.Add('Доходы  +' + MoneyFormat(incoming) + '  Расходы  -' + MoneyFormat(spend));
  item.SubItems.Add(' ');
  item.SubItems.Add('');
  item.SubItems.Add('');
  item.SubItems.Add('');
  if incoming > spend then
    item.SubItems.Add('  Баланс  +' + MoneyFormat(incoming - spend))
  else
    item.SubItems.Add('  Баланс  -' + MoneyFormat(spend - incoming));
end;


// Закрытие программы
procedure TmainFrm.btn1Click(Sender: TObject);
begin
  Dec(CharDeep);
  if CharDeep < 0 then CharDeep := 0;
  DrawAnalitics;
end;

procedure TmainFrm.btnAboutClick(Sender: TObject);
begin
  AboutFrm.Show;
end;


procedure TmainFrm.btnAccountClick(Sender: TObject);
begin
  HideAllPanel;
  pnlAccount.Visible := True;
  pnlAccount.Align := alClient;
  DrawAccountsTransaction;
end;


procedure TmainFrm.btnDecDateClick(Sender: TObject);
begin
  case cbbPeriod.ItemIndex of
    0:begin
        dtpFromDate.Date := IncDay(dtpFromDate.Date, -1);
        dtpToDate.Date := dtpFromDate.Date;
      end;
    1:begin
        dtpFromDate.Date := IncDay(dtpFromDate.Date, -7);
        dtpToDate.Date := IncDay(dtpFromDate.Date, 6);
      end;
    2:begin
        dtpFromDate.Date := IncMonth(dtpFromDate.Date, -1);
        dtpToDate.Date := IncDay(dtpFromDate.Date, DaysInMonth(dtpFromDate.Date) - 1);
      end;
  end;
  if btnSafeBox.Down then
    DrawQuotes;
  if btnAccount.Down then
    DrawAccountsTransaction;
  if btnCallendar.Down then
    ReSizeGrid;
  if btnPrice.Down then
    DrawPrice;
  if btnAnalitics.Down then
    DrawAnalitics;
end;

procedure TmainFrm.btnIncDateClick(Sender: TObject);
begin
  case cbbPeriod.ItemIndex of
    0:begin
        dtpFromDate.Date := IncDay(dtpFromDate.Date, 1);
        dtpToDate.Date := dtpFromDate.Date;
      end;
    1:begin
        dtpFromDate.Date := IncDay(dtpFromDate.Date, 7);
        dtpToDate.Date := IncDay(dtpFromDate.Date, 6);
      end;
    2:begin
        dtpFromDate.Date := IncMonth(dtpFromDate.Date, 1);
        dtpToDate.Date := IncDay(dtpFromDate.Date, DaysInMonth(dtpFromDate.Date) - 1);
      end;
  end;
  if btnSafeBox.Down then
    DrawQuotes;
  if btnAccount.Down then
    DrawAccountsTransaction;
  if btnCallendar.Down then
    ReSizeGrid;
  if btnPrice.Down then
    DrawPrice;
  if btnAnalitics.Down then
    DrawAnalitics;
end;

procedure TmainFrm.btnAnaliticsClick(Sender: TObject);
begin
  HideAllPanel;
  pnlAnalytics.Visible := True;
  pnlAnalytics.Align := alClient;
  DrawAnalitics;
end;


procedure TmainFrm.btnBasketClick(Sender: TObject);
begin
  HideAllPanel;
  pnlBasket.Visible := True;
  pnlBasket.Align := alClient;
end;


procedure TmainFrm.btnCallendarClick(Sender: TObject);
begin
  HideAllPanel;
  pnlCalendar.Visible := True;
  pnlCalendar.Align := alClient;
  ReSizeGrid;
end;


procedure TmainFrm.btnMoneyBoxClick(Sender: TObject);
begin
  HideAllPanel;
  pnlMoneyBox.Visible := True;
  pnlMoneyBox.Align := alClient;
  ClearNotUsedDescription;
end;


procedure TmainFrm.btnPriceNotesKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  i, MaxWidth : integer;
begin
  if Key <> VK_RETURN then Exit;
  if edtPriceNotes.Text = '' then Exit;
  if chklstNotes.Items.IndexOf(DateToStr(cal1.Date) + ' ' + edtPriceNotes.Text) > -1 then Exit;
  chklstNotes.Items.Add(DateToStr(cal1.Date) + ' ' + edtPriceNotes.Text);
  edtPriceNotes.Text := '';
  MaxWidth := 0;
  for i := 0 to chklstNotes.Items.Count - 1 do
    if MaxWidth < chklstNotes.Canvas.TextWidth(chklstNotes.Items.Strings[i]) then
      MaxWidth := chklstNotes.Canvas.TextWidth(chklstNotes.Items.Strings[i]);
  SendMessage(chklstNotes.Handle, LB_SETHORIZONTALEXTENT, MaxWidth+2, 0);
end;

procedure TmainFrm.btnPriceNotesRightButtonClick(Sender: TObject);
var
  i, MaxWidth : integer;
begin
//  if btnPriceNotes.Text = '' then Exit;
//  if chklstNotes.Items.IndexOf(DateToStr(cal1.Date) + ' ' + btnPriceNotes.Text) > -1 then Exit;
//  chklstNotes.Items.Add(DateToStr(cal1.Date) + ' ' + btnPriceNotes.Text);
//  btnPriceNotes.Text := '';
  MaxWidth := 0;
  for i := 0 to chklstNotes.Items.Count - 1 do
    if MaxWidth < chklstNotes.Canvas.TextWidth(chklstNotes.Items.Strings[i]) then
      MaxWidth := chklstNotes.Canvas.TextWidth(chklstNotes.Items.Strings[i]);
  SendMessage(chklstNotes.Handle, LB_SETHORIZONTALEXTENT, MaxWidth+2, 0);
end;

procedure TmainFrm.btnPriceClick(Sender: TObject);
begin
  HideAllPanel;
  pnlPrice.Visible := True;
  pnlPrice.Align := alClient;
  DrawPrice;
end;


procedure TmainFrm.btnSafeBoxClick(Sender: TObject);
begin
  HideAllPanel;
  pnlSafeBox.Visible := True;
  pnlSafeBox.Align := alClient;
  DrawQuotes;
end;


procedure TmainFrm.CBoxIncisionChange(Sender: TObject);
begin
  DrawAccountsTransaction;
end;


procedure TmainFrm.chkIncomingClick(Sender: TObject);
begin
  DrawAnalitics;
end;

procedure TmainFrm.chklstNotesClickCheck(Sender: TObject);
var
  i : Integer;
begin
  for i := 0 to chklstNotes.Items.Count - 1 do
    if chklstNotes.Checked[i] then
      begin
        chklstNotes.Items.Delete(i);
        break;
      end;
end;

procedure TmainFrm.cht1ClickSeries(Sender: TCustomChart; Series: TChartSeries;
  ValueIndex: Integer; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ChartSDeep := ValueIndex;
  inc(CharDeep);
  DrawAnalitics;
end;

procedure TmainFrm.cbbPeriodChange(Sender: TObject);
begin
  case cbbPeriod.ItemIndex of
    0 :begin
         mainFrm.dtpFromDate.Date := Date;
         mainFrm.dtpToDate.Date := Date;
       end;
    1 :begin
         mainFrm.dtpFromDate.Date := StartOfTheWeek(Date);
         mainFrm.dtpToDate.Date := EndOfTheWeek(Date);
       end;
    2 :begin
         mainFrm.dtpFromDate.Date := StartOfTheMonth(Date);
         mainFrm.dtpToDate.Date := EndOfTheMonth(Date);
       end;
  end;
  if btnSafeBox.Down then
    DrawQuotes;
  if btnAccount.Down then
    DrawAccountsTransaction;
  if btnCallendar.Down then
    ReSizeGrid;
  if btnPrice.Down then
    DrawPrice;
  if btnAnalitics.Down then
    DrawAnalitics;
end;


procedure TmainFrm.cbbAnalitycsIncisionChange(Sender: TObject);
begin
  DrawAnalitics;
end;


procedure TmainFrm.dtpFromDateChange(Sender: TObject);
begin
  if btnSafeBox.Down then
    DrawQuotes;
  if btnAccount.Down then
    DrawAccountsTransaction;
  if btnCallendar.Down then
    ReSizeGrid;
  if btnPrice.Down then
    DrawPrice;
  if btnAnalitics.Down then
    DrawAnalitics;
end;


procedure TmainFrm.dtpToDateChange(Sender: TObject);
begin
  if btnSafeBox.Down then
    DrawQuotes;
  if btnAccount.Down then
    DrawAccountsTransaction;
  if btnCallendar.Down then
    ReSizeGrid;
  if btnPrice.Down then
    DrawPrice;
  if btnAnalitics.Down then
    DrawAnalitics;
end;


procedure TmainFrm.FormActivate(Sender: TObject);
begin
  DrawAccountsTransaction;
end;


procedure TmainFrm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := False;
  if MessageDlg('Выйти из программы', mtInformation, [mbYes, mbNo], 0) = mrNo  then exit;
  Finish;
  CanClose := True;
  t := True;
  Application.Terminate;
end;


procedure TmainFrm.FormCreate(Sender: TObject);
begin
  vrtldrwtrPrice.NodeDataSize := SizeOf(TItemNode);
  T := False;
  HideAllPanel;
  pnlSafeBox.Visible := True;
  pnlSafeBox.Align := alClient;
  btnSafeBox.Down := True;
  cbbPeriod.ItemsEx.AddItem('День', 216, 216, 216, 0, nil);
  cbbPeriod.ItemsEx.AddItem('Неделя', 217, 217, 217, 0, nil);
  cbbPeriod.ItemsEx.AddItem('Месяц', 218, 218, 218, 0, nil);
  cbbPeriod.ItemIndex := 2;
  mainFrm.dtpFromDate.Date := StartOfTheMonth(Date);
  mainFrm.dtpToDate.Date := EndOfTheMonth(Date);
  cbbIncision.ItemsEx.AddItem('Транзакции', 52, 52, 52, 0, nil);
  cbbIncision.ItemsEx.AddItem('Категории', 90, 90, 90, 0, nil);
  cbbIncision.ItemsEx.AddItem('События', 155, 155, 155, 0, nil);
  cbbIncision.ItemsEx.AddItem('Персоны', 118, 118, 118, 0, nil);
  cbbIncision.ItemsEx.AddItem('Контрагенты', 170, 170, 170, 0, nil);
  cbbIncision.ItemIndex := 0;
  newRecFromBackup := 0;
  newRecFromSave := 0;
//  dtpcalendar.Date := Date;
  Column := -1;
  Row := -1;
end;


// Перерисовка сетки при изменении размера формы
procedure TmainFrm.FormResize(Sender: TObject);
begin
  ReSizeGrid;
//  btnSpliter.Width := tlbMainToolbar.Width - btnSafeBox.Width - btnAccount.Width - btnCallendar.Width - btnBasket.Width - btnMoneyBox.Width - btnPrice.Width - btnAnalitics.Width - btnAbout.Width - 10;
end;


procedure TmainFrm.FormShow(Sender: TObject);
begin
  DrawQuotes;
end;

procedure TmainFrm.lvAccountCompare(Sender: TObject; Item1, Item2: TListItem;
  Data: Integer; var Compare: Integer);
begin
   Compare := 0;
   if StrToDate(Item1.Caption) > StrToDate(Item2.Caption) then
     Compare := 1
   else
     if StrToDate(Item1.Caption) < StrToDate(Item2.Caption) then
       Compare := -1;
end;


procedure TmainFrm.lvAccountCustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
   if ( Item.Index mod 2 ) <> 0 then
      Sender.Canvas.Brush.Color := cl3DLight
   else
      Sender.Canvas.Brush.Color := clWhite;
   if Item.Index = lvAccount.Items.Count - 1 then Sender.Canvas.Brush.Color := clMoneyGreen;
end;


procedure TmainFrm.lvAccountDblClick(Sender: TObject);
var
  item : TListItem;
  i    : Integer;
begin
  for i := 0 to lvAccount.Items.Count - 2 do
    if lvAccount.Items[i].Selected then
      begin
        item := lvAccount.Items[i];
        DBIndex := TransactionGetPositionByID(StrToInt(item.SubItems[10]));
        TransactionRead(DBIndex);
        TransactionAddFrm.Show;
        Exit;
      end;
  ClearFinancyTransactionRec;
  if CompareDate(dtpFromDate.Date, dtpToDate.Date) = 0 then
    FinancyTransaction.Date := dtpFromDate.Date;
  DBIndex := TransactionGetCount;
  TransactionAddFrm.Show;
end;

procedure TmainFrm.lvAccountKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  item : TListItem;
  i    : Integer;
begin
  case Key of
  VK_DELETE:begin
              if MessageDlg('Удалить запись ?', mtInformation, [mbYes, mbNo], 0) = mrNo  then exit;
              for i := 0 to lvAccount.Items.Count - 2 do
                if lvAccount.Items[i].Selected then
                  begin
                    item := lvAccount.Items[i];
                    DBIndex := TransactionGetPositionByID(StrToInt(item.SubItems[10]));
                    TransactionDelete(DBIndex);
                    DrawAccountsTransaction;
                    Break;
                  end;
            end;
  VK_RETURN:begin
              for i := 0 to lvAccount.Items.Count - 2 do
              if lvAccount.Items[i].Selected then
                begin
                  item := lvAccount.Items[i];
                  DBIndex := TransactionGetPositionByID(StrToInt(item.SubItems[10]));
                  TransactionRead(DBIndex);
                  TransactionAddFrm.Show;
                  Break;
                end;
            end;
  VK_INSERT:begin
              ClearFinancyTransactionRec;
              for i := 0 to lvAccount.Items.Count - 2 do      //-- если выбрана дата то установим дату заранее
                if lvAccount.Items[i].Selected then
                  begin
                    FinancyTransaction.Date := StrToDate(lvAccount.Items[i].Caption);
                    Break;
                  end;
              if CompareDate(dtpFromDate.Date, dtpToDate.Date) = 0 then
                FinancyTransaction.Date := dtpFromDate.Date;
              DBIndex := TransactionGetCount;
              TransactionAddFrm.Show;
            end;
  end;
end;

procedure TmainFrm.lvTotalsCustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  case cbbTotals.ItemIndex of
    0:case Item.Index of
        0: Sender.Canvas.Brush.Color := clGreen;
        1: Sender.Canvas.Brush.Color := clRed;
        2: Sender.Canvas.Brush.Color := clBlue;
      end;
    1:begin
        if ( Item.Index mod 2 ) <> 0 then
          Sender.Canvas.Brush.Color := cl3DLight
        else
          Sender.Canvas.Brush.Color := clWhite;
        if Item.Index = lvTotals.Items.Count - 1 then Sender.Canvas.Brush.Color := clMoneyGreen;
      end;
  end;
end;

procedure TmainFrm.N10Click(Sender: TObject);   //-- Удалить из чека
var
  item : TListItem;
  i    : Integer;
begin
  for i := 0 to lvAccount.Items.Count - 2 do
    if lvAccount.Items[i].Selected then
      begin
        item := lvAccount.Items[i];
        DBIndex := TransactionGetPositionByID(StrToInt(item.SubItems[10]));
        TransactionRead(DBIndex);
        FinancyTransaction.BillNumber := 0;
        TransactionSave(DBIndex);
        DrawAccountsTransaction;
        Break;
      end;
end;


procedure TmainFrm.N11Click(Sender: TObject);  //-- Редактировать существующую
var
  item : TListItem;
  i    : Integer;
begin
  for i := 0 to lvAccount.Items.Count - 2 do
    if lvAccount.Items[i].Selected then
      begin
        item := lvAccount.Items[i];
        DBIndex := TransactionGetPositionByID(StrToInt(item.SubItems[10]));
        TransactionRead(DBIndex);
        TransactionAddFrm.Show;
        Break;
      end;
end;


procedure TmainFrm.N12Click(Sender: TObject);  //-- Добавить стандартный товар
var
  item : TListItem;
  i    : Integer;
begin
  for i := 0 to lvAccount.Items.Count - 2 do
    if lvAccount.Items[i].Selected then
      begin
        item := lvAccount.Items[i];
        DBIndex := TransactionGetPositionByID(StrToInt(item.SubItems[10]));
        TransactionRead(DBIndex);
        SaveStandardItem(DescriptionNameList[FinancyTransaction.Description.Name]);
        Break;
      end;
end;


procedure TmainFrm.N21Click(Sender: TObject);   //-- Добавить новую
var
  i : Integer;
begin
  ClearFinancyTransactionRec;
  for i := 0 to lvAccount.Items.Count - 2 do      //-- если выбрана дата то установим дату заранее
    if lvAccount.Items[i].Selected then
      begin
        FinancyTransaction.Date := StrToDate(lvAccount.Items[i].Caption);
        Break;
      end;
  if CompareDate(dtpFromDate.Date, dtpToDate.Date) = 0 then
    FinancyTransaction.Date := dtpFromDate.Date;
  DBIndex := TransactionGetCount;
  TransactionAddFrm.Show;
end;


procedure TmainFrm.N2Click(Sender: TObject);    //-- Удаление транзакции
var
  item : TListItem;
  i    : Integer;
begin
  if MessageDlg('Удалить запись ?', mtInformation, [mbYes, mbNo], 0) = mrNo  then exit;
  for i := 0 to lvAccount.Items.Count - 2 do
    if lvAccount.Items[i].Selected then
      begin
        item := lvAccount.Items[i];
        DBIndex := TransactionGetPositionByID(StrToInt(item.SubItems[10]));
        TransactionDelete(DBIndex);
        DrawAccountsTransaction;
        Break;
      end;
end;


procedure TmainFrm.rzdtFromDateChange(Sender: TObject);
begin
  DrawAccountsTransaction;
end;


procedure TmainFrm.rzdtToDateChange(Sender: TObject);
begin
  DrawAccountsTransaction;
end;


{ DONE : Добавить цикл для многих строк }
procedure TmainFrm.StringGrid1DblClick(Sender: TObject);
begin
  if Row = 0 then Exit;
  dtpFromDate.Date := StrToDate(GetMainString(StringGrid1.Cells[Column, Row]));
  dtpToDate.Date := StrToDate(GetMainString(StringGrid1.Cells[Column, Row]));
  HideAllPanel;
  btnAccount.Down := True;
  btnCallendar.Down := False;
  pnlAccount.Visible := True;
  pnlAccount.Align := alClient;
  DrawAccountsTransaction;
end;

procedure TmainFrm.StringGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  i                   : integer;
  hGrid               : TStringGrid;
  bmp                 : TBitmap;
  s, s1, s2           : string;
  y, m, d, y1, m1, d1 : Word;
begin
  hGrid := (Sender as TStringGrid);
  if (ARow <> 0) then
    DecodeDate(StrToDate(GetMainString(hGrid.Cells[ACol, ARow])), y, m, d);
  DecodeDate(dtpFromDate.Date, y1, m1, d1);
  if (ARow <> 0) and (m = m1) then      //-- выбраный месяц закрашиваем квадратики
    hGrid.Canvas.Brush.Color := MonthColor
  else
    hGrid.Canvas.Brush.Color := clWindow;
  if ARow = 0 then
    hGrid.Canvas.Brush.Color := clBtnFace;
  hGrid.Canvas.FillRect(Rect);
  for I := 0 to GetSubElementsCount(hGrid.Cells[ACol, ARow]) do
    begin
    if (ARow = 0) then       // выводим дни недели
      begin
        hGrid.Canvas.Font.Style := [fsBold];
        hGrid.Canvas.Font.Name := 'Verdana';
        hGrid.Canvas.Font.Size := CalendarFontSize;
        if (ACol = 5) or (ACol = 6) then
          hGrid.Canvas.Font.Color := clRed
        else
          hGrid.Canvas.Font.Color := clBlack;
        hGrid.Canvas.TextOut(Rect.Right - hGrid.Canvas.TextWidth(GetMainString(hGrid.Cells[ACol, ARow])) - 3, Rect.Top + 2, GetMainString(hGrid.Cells[ACol, ARow]))
      end
    else
      begin
        hGrid.Canvas.Font.Style := [fsBold];
        if (StrToDate(GetMainString(hGrid.Cells[ACol, ARow])) = Date) or ((ACol = Column) and (ARow = Row)) then
          begin
            if ((ACol = Column) and (ARow = Row)) then       // отрисовываем выделение или сегодня
              hGrid.Canvas.Pen.Color := clBlue
            else
              begin
                hGrid.Canvas.Font.Style := [fsBold, fsItalic, fsUnderline];       // сегодня
                 hGrid.Canvas.Pen.Color := clRed;
              end;
            hGrid.Canvas.Pen.Width := 2;
            hGrid.Canvas.Brush.Style := bsClear;
            hGrid.Canvas.Rectangle(Rect.Left + 1, Rect.Top + 1, Rect.Right, Rect.Bottom);
            hGrid.Canvas.Pen.Color := clBlack;
            hGrid.Canvas.Brush.Style := bsSolid;
          end
        else
          begin
            hGrid.Canvas.Font.Style := [fsBold];
            hGrid.Canvas.Pen.Color := clBlack;
            hGrid.Canvas.Pen.Width := 1;
          end;
        if (ACol = 5) or (ACol = 6) then
          hGrid.Canvas.Font.Color := clRed
        else
          hGrid.Canvas.Font.Color := clBlack;
        hGrid.Canvas.TextOut(Rect.Left + 5, Rect.Top + 2, GetMainString(hGrid.Cells[ACol, ARow]));  // рисуем число
      end;
      hGrid.Canvas.Font.Style := [];
      hGrid.Canvas.Font.Color := clBlack;
      if i > 0 then
        begin
          try
            hGrid.Canvas.Font.Size := CalendarFontSize;
            bmp := TBitmap.Create;
            case cbbIncision.ItemIndex of
              0: TransactionAddFrm.CategoryImgLst.GetBitmap(ImageIndexGetIndex(GetSubString(hGrid.Cells[ACol, ARow], i)), bmp);
              1: TransactionAddFrm.CategoryImgLst.GetBitmap(ImageIndexGetIndex(GetSubString(hGrid.Cells[ACol, ARow], i)), bmp);
              2: TransactionAddFrm.EventImgLst.GetBitmap(ImageIndexGetIndex(GetSubString(hGrid.Cells[ACol, ARow], i)), bmp);
              3: TransactionAddFrm.PersonaImgLst.GetBitmap(ImageIndexGetIndex(GetSubString(hGrid.Cells[ACol, ARow], i)), bmp);
              4: TransactionAddFrm.ContractorImgLst.GetBitmap(ImageIndexGetIndex(GetSubString(hGrid.Cells[ACol, ARow], i)), bmp);
            end;

            if i = GetSubElementsCount(hGrid.Cells[ACol, ARow]) then      // последний элемент рисуем внизу таблицы
              begin
                hGrid.Canvas.Font.Style := [fsBold];
                hGrid.Canvas.Draw(Rect.Left + 2, Rect.Bottom + (hGrid.Canvas.Font.Height - 5), bmp);
                s1 := ImageIndexGetString(GetSubString(hGrid.Cells[ACol, ARow], i));
                s2 := s1;
                Delete(s1, Pos('|', s1) -1, Length(s1) - Pos('|', s1) +2);
                Delete(s2, 1, Pos('|', s2) + 1);
                hGrid.Canvas.Font.Color := clBlack;
                if s1[1] = '-' then
                  hGrid.Canvas.Font.Color := clMaroon;
                if s1[1] = '+' then
                  hGrid.Canvas.Font.Color := clGreen;
                hGrid.Canvas.TextOut(Rect.Left + bmp.Width + 3, Rect.Bottom + (hGrid.Canvas.Font.Height - 5), s1);
                hGrid.Canvas.Font.Color := clBlack;
                if s2[1] = '-' then
                  hGrid.Canvas.Font.Color := clRed;
                if s2[1] = '+' then
                  hGrid.Canvas.Font.Color := clMoneyGreen;
                hGrid.Canvas.TextOut(Rect.Right - hGrid.Canvas.TextWidth(s2) - 5, Rect.Bottom + (hGrid.Canvas.Font.Height - 5), s2);
              end
            else
              begin                       // рисуем очередной элемент списка
                hGrid.Canvas.Font.Style := [];
                if (Rect.Top - (hGrid.Canvas.Font.Height - 3) * (i + 1) + 3) < (Rect.Bottom + hGrid.Canvas.Font.Height * 3) then
                  hGrid.Canvas.Draw(Rect.Left + 2, Rect.Top - (hGrid.Canvas.Font.Height - 3) * (i + 1) + 3, bmp);
                s := ImageIndexGetString(GetSubString(hGrid.Cells[ACol, ARow], i));
                if (Rect.Right - Rect.Left - (bmp.Width + 3)) < hGrid.Canvas.TextWidth(s) then   //-- строка длинее ячейки
                  begin
                    while (Rect.Right - Rect.Left - (bmp.Width + 3)) < hGrid.Canvas.TextWidth(s) do
                      Delete(s, Pos('|', s) - 2, 1);
                    s := StringReplace(s, ' |', '..|', [rfIgnoreCase]);
                  end
                else
                  while (Rect.Right - Rect.Left - (bmp.Width + 3)) > hGrid.Canvas.TextWidth(s) do
                    Insert(' ', s, Pos('|', s) -1);

                s1 := s;
                s2 := s;
                Delete(s1, Pos('|', s1), Length(s1) - Pos('|', s1) + 2);
                Delete(s2, 1, Pos('|', s2) + 1);
                hGrid.Canvas.Font.Color := clBlack;
                hGrid.Canvas.Font.Style := [];
                if (Rect.Top - (hGrid.Canvas.Font.Height - 3) * (i + 1) + 3) > (Rect.Bottom + hGrid.Canvas.Font.Height * 3) then
                  begin//-- рисуем только по высоте
                    hGrid.Canvas.Font.Style := [fsBold];
                    s:= '.....';
                    hGrid.Canvas.TextOut(Rect.Left + bmp.Width + 3, Rect.Top - (hGrid.Canvas.Font.Height - 3) * (i + 1) + 3, s);
                    Continue;
                  end;
                if (Rect.Top - (hGrid.Canvas.Font.Height - 3) * (i + 1) + 3) > (Rect.Bottom + hGrid.Canvas.Font.Height * 2) then  //-- все не рисуем
                  Continue;

                hGrid.Canvas.TextOut(Rect.Left + bmp.Width + 3, Rect.Top - (hGrid.Canvas.Font.Height - 3) * (i + 1) + 3, s1);
                if s2[1] = '-' then
                  hGrid.Canvas.Font.Color := clRed;
                if s2[1] = '+' then
                  hGrid.Canvas.Font.Color := clGreen;
                hGrid.Canvas.TextOut(Rect.Right - hGrid.Canvas.TextWidth(s2) - 5, Rect.Top - (hGrid.Canvas.Font.Height - 3) * (i + 1) + 3, s2);
              end;
            bmp.Free;
          except
            on e:Exception do bmp.Free;
          end;
        end;
    end;
end;

procedure TmainFrm.StringGrid1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  StringGrid1.MouseToCell(X, Y, Column, Row);
end;


//-- тест отрисовки дерева
procedure TmainFrm.vrtldrwtrPriceDrawNode(Sender: TBaseVirtualTree;
  const PaintInfo: TVTPaintInfo);
var
  Data: PItemNode;
  i, level : Integer;
  S: WideString;
  R, RealRect: TRect;
  Bmp : TBitmap;
begin
  with Sender as TVirtualDrawTree, PaintInfo do
  begin
    Data := Sender.GetNodeData(Node);

  {  if (Column = FocusedColumn) and (Node = FocusedNode) then
      Canvas.Font.Color := clHighlightText
    else
      Canvas.Font.Color := clWindowText;   }

    PaintInfo.Canvas.Font.Name := 'Verdana';
    PaintInfo.Canvas.Font.Style := [];
    PaintInfo.Canvas.Font.Color := clWindowText;


    SetBKMode(Canvas.Handle, TRANSPARENT);

    R := ContentRect;
    InflateRect(R, -TextMargin, 0);
    Dec(R.Right);
    Dec(R.Bottom);

    RealRect := PaintInfo.CellRect;
    if PaintInfo.Node = Sender.FocusedNode then
      GradFill(PaintInfo.Canvas.Handle, RealRect, clWhite, clHighlight, gkVert)
    else
      begin
      {  PaintInfo.Canvas.Brush.Color := clYellow;
        PaintInfo.Canvas.FillRect(RealRect);}
      end;

    if (Column = 0) and (Sender.HasChildren[Node]) then
      begin
        bmp := TBitmap.Create;
        try
          TransactionAddFrm.CategoryImgLst.GetBitmap(220, bmp);
          PaintInfo.Canvas.Draw(RealRect.Left, RealRect.Top, Bmp);
        finally
          FreeAndNil(Bmp);
        end;
      end;

    S := '';
    case Data.TType of
    ID_SPEND   :begin
                  GradFill(PaintInfo.Canvas.Handle, RealRect, clWhite, clRed, gkVert);
                  PaintInfo.Canvas.Font.Style := [fsBold];
                  PaintInfo.Canvas.Font.Color := clWhite;
                  case Column of
                    0: S := 'Расходы';
                  end;
                  with R do
                    begin
                      if (NodeWidth - 2 * Margin) > (Right - Left) then
                      S := ShortenString(Canvas.Handle, S, Right - Left, Left);
                    end;
                  DrawTextW(Canvas.Handle, PWideChar(S), Length(S), R, DT_TOP or DT_LEFT or DT_VCENTER or DT_SINGLELINE);
                  Exit;
                end;
    ID_INCOMING:begin
                  GradFill(PaintInfo.Canvas.Handle, RealRect, clWhite, clLime, gkVert);
                  PaintInfo.Canvas.Font.Style := [fsBold];
                  PaintInfo.Canvas.Font.Color := clWhite;
                  case Column of
                    0: S := 'Доходы';
                  end;
                  with R do
                    begin
                      if (NodeWidth - 2 * Margin) > (Right - Left) then
                      S := ShortenString(Canvas.Handle, S, Right - Left, Left);
                    end;
                  DrawTextW(Canvas.Handle, PWideChar(S), Length(S), R, DT_TOP or DT_LEFT or DT_VCENTER or DT_SINGLELINE);
                  Exit;
                end;
    end;

    for i := 0 to TransactionGetCount - 1 do
      begin
        TransactionRead(i);
        if FinancyTransaction.IDkey = Data.ID then Break;
      end;


    case Column of
      0:begin
          if Data.TType = ID_REC then
            begin
              bmp := TBitmap.Create;
              try
                TransactionAddFrm.CategoryImgLst.GetBitmap(ImageIndexGetIndex(CategoryList[FinancyTransaction.Category]), Bmp);
                level := Round(Sender.GetNodeLevel(Node));
                PaintInfo.Canvas.Draw(RealRect.Left + level * vrtldrwtrPrice.Indent, RealRect.Top, Bmp);
              finally
                FreeAndNil(Bmp);
              end;
            end;
          S := DescriptionNameList[FinancyTransaction.Description.Name] + ' ' {+ DescriptionBrandList[FinancyTransaction.Description.Brand] + ' ' + DescriptionSeriesList[FinancyTransaction.Description.Series]};
          if Length(S) > 0 then
          begin
            with R do
            begin
              if (NodeWidth - 2 * Margin) > (Right - Left) then
                S := ShortenString(Canvas.Handle, S, Right - Left, Left);
            end;
            DrawTextW(Canvas.Handle, PWideChar(S), Length(S), R, DT_TOP or DT_LEFT or DT_VCENTER or DT_SINGLELINE);
          end;
        end;
      1:begin
          S := MoneyFormat(FinancyTransaction.Price);
          if Length(S) > 0 then
          begin
            with R do
            begin
              if (NodeWidth - 2 * Margin) > (Right - Left) then
                S := ShortenString(Canvas.Handle, S, Right - Left, Left);
            end;
            DrawTextW(Canvas.Handle, PWideChar(S), Length(S), R, DT_TOP or DT_RIGHT or DT_VCENTER or DT_SINGLELINE);
          end;
        end;
      2:begin
          S := FloatToStr(FinancyTransaction.Number);
          if Length(S) > 0 then
          begin
            with R do
            begin
              if (NodeWidth - 2 * Margin) > (Right - Left) then
                S := ShortenString(Canvas.Handle, S, Right - Left, Left);
            end;
            DrawTextW(Canvas.Handle, PWideChar(S), Length(S), R, DT_TOP or DT_RIGHT or DT_VCENTER or DT_SINGLELINE);
          end;
        end;
       3:begin
          S := MoneyFormat(FinancyTransaction.Summ);
            with R do
            begin
              if (NodeWidth - 2 * Margin) > (Right - Left) then
                S := ShortenString(Canvas.Handle, S, Right - Left, Left);
            end;
            DrawTextW(Canvas.Handle, PWideChar(S), Length(S), R, DT_TOP or DT_RIGHT or DT_VCENTER or DT_SINGLELINE);
        end;
      4:begin
          S := FloatToStr(FinancyTransaction.Discount);
          with R do
          begin
            if (NodeWidth - 2 * Margin) > (Right - Left) then
              S := ShortenString(Canvas.Handle, S, Right - Left, Left);
          end;
          DrawTextW(Canvas.Handle, PWideChar(S), Length(S), R, DT_TOP or DT_LEFT or DT_VCENTER or DT_SINGLELINE);
        end;
      5:begin
          S := DateToStr(FinancyTransaction.Date);
          with R do
            begin
              if (NodeWidth - 2 * Margin) > (Right - Left) then
                S := ShortenString(Canvas.Handle, S, Right - Left, Left);
            end;
            DrawTextW(Canvas.Handle, PWideChar(S), Length(S), R, DT_TOP or DT_LEFT or DT_VCENTER or DT_SINGLELINE);
        end;
      6:begin
          S := CommentList[FinancyTransaction.Comment];
          if Length(S) > 0 then
          begin
            with R do
            begin
              if (NodeWidth - 2 * Margin) > (Right - Left) then
                S := ShortenString(Canvas.Handle, S, Right - Left, Left);
            end;
            DrawTextW(Canvas.Handle, PWideChar(S), Length(S), R, DT_TOP or DT_LEFT or DT_VCENTER or DT_SINGLELINE);
          end;
        end;
    end;
  end;
end;

procedure TmainFrm.cbbIncisionChange(Sender: TObject);
begin
  if btnSafeBox.Down then
    DrawQuotes;
  if btnAccount.Down then
    DrawAccountsTransaction;
  if btnCallendar.Down then
    ReSizeGrid;
  if btnPrice.Down then
    DrawPrice;
  if btnAnalitics.Down then
    DrawAnalitics;
end;

end.
