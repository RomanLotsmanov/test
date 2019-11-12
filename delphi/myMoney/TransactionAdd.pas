unit TransactionAdd;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Buttons, ToolWin, ImgList,
  ExtCtrls, Menus, jpeg, Math;

type
  TTransactionAddFrm = class(TForm)
    ToolBar: TToolBar;
    CurrencyCheck: TCheckBox;
    DescriptionCBox: TComboBoxEx;
    OKbtn: TBitBtn;
    Cancelbtn: TBitBtn;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label10: TLabel;
    CommentEdt: TEdit;
    CategoryImgLst: TImageList;
    pmAuto: TPopupMenu;
    Label12: TLabel;
    Label9: TLabel;
    Label13: TLabel;
    absProc: TCheckBox;
    lbl1: TLabel;
    CurrencyImgLst: TImageList;
    PersonaImgLst: TImageList;
    EventImgLst: TImageList;
    btnIncoming: TToolButton;
    btnSpend: TToolButton;
    btnAuto: TToolButton;
    ToolBarImgLst: TImageList;
    lAccountImgLst: TImageList;
    chkAvto: TCheckBox;
    ContractorImgLst: TImageList;
    btn1: TToolButton;
    pnlAdd: TPanel;
    lbl2: TLabel;
    lbl3: TLabel;
    edtAdd: TEdit;
    btnAdd: TBitBtn;
    btnDelete: TBitBtn;
    btnCancel: TBitBtn;
    btnChange: TBitBtn;
    btnSub: TBitBtn;
    btnBill: TToolButton;
    lvBill: TListView;
    btnBillAdd: TBitBtn;
    chkStandardItem: TCheckBox;
    cbbmeasure: TComboBoxEx;
    dtpDateTimeEdt: TDateTimePicker;
    cbbAccount: TComboBoxEx;
    cbbCategory: TComboBoxEx;
    cbbCurrency: TComboBoxEx;
    cbbPersona: TComboBoxEx;
    cbbContractor: TComboBoxEx;
    cbbEvent: TComboBoxEx;
    cbbAdd: TComboBoxEx;
    edtPrice: TEdit;
    edtNumber: TEdit;
    edtDiscont: TEdit;
    edtSumm: TEdit;
    DescriptionCBox1: TComboBoxEx;
    lbl4: TLabel;
    lbl5: TLabel;
    DescriptionCBox2: TComboBoxEx;
    edtPacking: TEdit;
    lbl6: TLabel;
    lbl7: TLabel;
    priorityBar: TTrackBar;
    down1: TSpeedButton;
    down2: TSpeedButton;
    CalcPrice: TSpeedButton;
    procedure PriceEdtChange(Sender: TObject);
    procedure NumberEdtChange(Sender: TObject);
    procedure DiscountEdtChange(Sender: TObject);
    procedure CurrencyCheckClick(Sender: TObject);
    procedure PriceEdtClick(Sender: TObject);
    procedure NumberEdtClick(Sender: TObject);
    procedure DiscountEdtClick(Sender: TObject);
    procedure SummEdtClick(Sender: TObject);
    procedure CancelbtnClick(Sender: TObject);
    procedure OKbtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure AccountChange(Sender: TObject);
    procedure DescriptionCBoxChange(Sender: TObject);
    procedure CommentEdtChange(Sender: TObject);
    procedure DateTimeEdtChange(Sender: TObject);
    procedure CategoryChange(Sender: TObject);
    procedure PersonaChange(Sender: TObject);
    procedure SummEdtChange(Sender: TObject);
    procedure ContractorChange(Sender: TObject);
    procedure EventChange(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure AccountKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnAddClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure CurrencyChange(Sender: TObject);
    procedure btnChangeClick(Sender: TObject);
    procedure btnSubClick(Sender: TObject);
    procedure CurrencyKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure CategoryKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure PersonaKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ContractorKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EventKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edtAddClick(Sender: TObject);
    procedure btnBillClick(Sender: TObject);
    procedure btnIncomingClick(Sender: TObject);
    procedure btnSpendClick(Sender: TObject);
    procedure btnBillAddClick(Sender: TObject);
    procedure cbbmeasureChange(Sender: TObject);
    procedure dtpDateTimeEdtChange(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure DescriptionCBoxExit(Sender: TObject);
    procedure PriceEdtKeyPress(Sender: TObject; var Key: Char);
    procedure edtPriceKeyPress(Sender: TObject; var Key: Char);
    procedure edtNumberKeyPress(Sender: TObject; var Key: Char);
    procedure edtDiscontKeyPress(Sender: TObject; var Key: Char);
    procedure edtSummKeyPress(Sender: TObject; var Key: Char);
    procedure btnAutoClick(Sender: TObject);
    procedure down1Click(Sender: TObject);
    procedure down2Click(Sender: TObject);
    procedure DescriptionCBoxKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DescriptionCBox1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DescriptionCBox2KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure CalcPriceClick(Sender: TObject);
    procedure edtPackingChange(Sender: TObject);
    procedure absProcClick(Sender: TObject);
  private
    { Private declarations }
 //   procedure AutoClick(Sender: TObject);
  public
    { Public declarations }
  end;

procedure FillListFields;

var
  indexType         : Byte;
  TransactionAddFrm : TTransactionAddFrm;
  TBill             : Integer;
  newRecFromBackup  : Integer;
  newRecFromSave    : Integer;

implementation

{$R *.dfm}

uses myMoneyDBEngine, Options;

const
  szcAutoSuggestDropdown = 'Auto-Suggest Dropdown';
  
function GetCName(hWnd: HWND): string;
var
  lpC: PAnsiChar;
begin
  lpC := GetMemory(MAX_PATH - 1);
  GetClassName(hWnd, lpC, MAX_PATH);
  Result := lpC;
  FreeMemory(lpC);
end;

function AutoSuggestDropDownVisible: Boolean;
const
  szcAutoSuggestDropdown = 'Auto-Suggest Dropdown';
begin
  Result := GetWindowLong(FindWindow(szcAutoSuggestDropdown, nil), GWL_STYLE)
            and WS_VISIBLE <> 0;
end;

function Compare(List: TStringList; Index1, Index2: Integer): Integer;
var S1, S2: String;
begin
    S1:= List[ Index1 ];
    S2:= List[ Index2 ];
    if S1 = S2
      then Result:= 0
      else if S1 < S2
            then Result:= -1
            else Result:= +1;
end;
procedure LoadDescrComboBox(Combo : TComboBoxEx; I : byte);
var S: TStringList;
begin
  Combo.Clear;
  S:= TStringList.Create;
  case i of
  0 : S.Assign(DescriptionNameList);
  1 : S.Assign(DescriptionBrandList);
  2 : S.Assign(DescriptionSeriesList);
  end;
  try
    S.CustomSort(Compare);
    Combo.Items.Text := S.Text;
  finally
    S.Free;
  end;
  Combo.Text := '';
end;

{procedure TTransactionAddFrm.AutoClick(Sender : TObject);
begin
  AutoRead((Sender as TMenuItem).Tag);
  edtPrice.Text := FloatToStr(TempFinancyTransaction.Price);
  edtNumber.Text := FloatToStr(TempFinancyTransaction.Number);
  edtDiscont.Text := FloatToStr(TempFinancyTransaction.Discount);
  absProc.Checked := FinancyTransaction.AbsProc;
  edtSumm.Text := FloatToStr(TempFinancyTransaction.Summ);
  cbbCurrency.ItemIndex := TempFinancyTransaction.Currency;
  cbbCategory.ItemIndex := TempFinancyTransaction.Category;
 // DescriptionCBox.Text := TempFinancyTransaction.Description;
  cbbPersona.ItemIndex := TempFinancyTransaction.Persona;
 // CommentEdt.Text := TempFinancyTransaction.Comment;
  cbbContractor.ItemIndex := TempFinancyTransaction.Contractor;
  cbbEvent.ItemIndex := TempFinancyTransaction.Event;
  cbbmeasure.ItemIndex := TempFinancyTransaction.Measure;
end;}

procedure FillAuto;
{var
  item : TMenuItem;
  i    : Integer;}
begin
 { TransactionAddFrm.pmAuto.Items.Clear;
  for i := 0 to AutoGetCount - 1 do
    begin
      AutoRead(i);
      item := TMenuItem.Create(TransactionAddFrm);
      item.ImageIndex := ImageIndexGetIndex(CategoryList[TempFinancyTransaction.Category]);
      item.Caption := DescriptionNameList[TempFinancyTransaction.Description.Name];
      item.Tag := i;
      item.OnClick := TransactionAddFrm.AutoClick;
      TransactionAddFrm.pmAuto.Items.Add(item);
    end;}
end;

procedure ReCalculate;
begin
  case TransactionAddFrm.CalcPrice.Tag of
    0:if TransactionAddFrm.absProc.Checked then
        TransactionAddFrm.edtSumm.Text := FloatToStr(RoundTo((StrToFloat(TransactionAddFrm.edtPrice.Text) * StrToFloat(TransactionAddFrm.edtNumber.Text)) * StrToFloat(TransactionAddFrm.edtPacking.Text) * (1 - (StrToFloat(TransactionAddFrm.edtDiscont.Text) * 0.01)), RoundN))
      else
        TransactionAddFrm.edtSumm.Text := FloatToStr(RoundTo((StrToFloat(TransactionAddFrm.edtPrice.Text) * StrToFloat(TransactionAddFrm.edtNumber.Text)) * StrToFloat(TransactionAddFrm.edtPacking.Text) - StrToFloat(TransactionAddFrm.edtDiscont.Text), RoundN));

    1:if TransactionAddFrm.absProc.Checked then
        TransactionAddFrm.edtPrice.Text := FloatToStr(RoundTo(((StrToFloat(TransactionAddFrm.edtSumm.Text) * (1 - (StrToFloat(TransactionAddFrm.edtDiscont.Text) * 0.01))) / (StrToFloat(TransactionAddFrm.edtNumber.Text)) / StrToFloat(TransactionAddFrm.edtPacking.Text)), RoundN))
      else
        TransactionAddFrm.edtPrice.Text := FloatToStr(RoundTo((StrToFloat(TransactionAddFrm.edtSumm.Text) - StrToFloat(TransactionAddFrm.edtDiscont.Text)) / (StrToFloat(TransactionAddFrm.edtNumber.Text)) / StrToFloat(TransactionAddFrm.edtPacking.Text), RoundN));
    2:if TransactionAddFrm.absProc.Checked then
        TransactionAddFrm.edtDiscont.Text := FloatToStr(RoundTo(((StrToFloat(TransactionAddFrm.edtSumm.Text) / (StrToFloat(TransactionAddFrm.edtPrice.Text) * StrToFloat(TransactionAddFrm.edtNumber.Text) * StrToFloat(TransactionAddFrm.edtPacking.Text))) * 0.01), RoundN))
      else
        TransactionAddFrm.edtDiscont.Text := FloatToStr(RoundTo(StrToFloat(TransactionAddFrm.edtSumm.Text) - StrToFloat(TransactionAddFrm.edtPrice.Text) * StrToFloat(TransactionAddFrm.edtNumber.Text) * StrToFloat(TransactionAddFrm.edtPacking.Text), RoundN));
   end;
end;

procedure FillListFields;
var
  i : integer;
begin
  for i := 0 to AccountList.Count - 1 do
    TransactionAddFrm.cbbAccount.ItemsEx.AddItem(ImageIndexGetString(AccountList[i]), ImageIndexGetIndex(AccountList[i]), ImageIndexGetIndex(AccountList[i]), ImageIndexGetIndex(AccountList[i]), 0, nil);
  TransactionAddFrm.cbbAccount.ItemIndex := 0;

  for i := 0 to CurrencyList.Count - 1 do
    TransactionAddFrm.cbbCurrency.ItemsEx.AddItem(ImageIndexGetString(CurrencyList[i]), ImageIndexGetIndex(CurrencyList[i]), ImageIndexGetIndex(CurrencyList[i]), ImageIndexGetIndex(CurrencyList[i]), 0, nil);
  TransactionAddFrm.cbbCurrency.ItemIndex := 0;

  for i := 0 to PersonaList.Count - 1 do
    TransactionAddFrm.cbbPersona.ItemsEx.AddItem(ImageIndexGetString(PersonaList[i]), ImageIndexGetIndex(PersonaList[i]), ImageIndexGetIndex(PersonaList[i]), ImageIndexGetIndex(PersonaList[i]), 0, nil);
  TransactionAddFrm.cbbPersona.ItemIndex := 0;

  for I := 0 to CategoryList.Count - 1 do
    if GetSubElementsCount(CategoryList[i]) = 0 then
       TransactionAddFrm.cbbCategory.ItemsEx.AddItem(ImageIndexGetString(CategoryList[i]), ImageIndexGetIndex(CategoryList[i]), ImageIndexGetIndex(CategoryList[i]), ImageIndexGetIndex(CategoryList[i]), 0, nil)
    else
      TransactionAddFrm.cbbCategory.ItemsEx.AddItem(GetSubString(CategoryList[i], GetSubElementsCount(CategoryList[i])), ImageIndexGetIndex(CategoryList[i]), ImageIndexGetIndex(CategoryList[i]), ImageIndexGetIndex(CategoryList[i]), GetSubElementsCount(CategoryList[i]), nil);
  TransactionAddFrm.cbbCategory.ItemIndex := 0;

  for i := 0 to ContractorList.Count - 1 do
    TransactionAddFrm.cbbContractor.ItemsEx.AddItem(ImageIndexGetString(ContractorList[i]), ImageIndexGetIndex(ContractorList[i]), ImageIndexGetIndex(ContractorList[i]), ImageIndexGetIndex(ContractorList[i]), 0, nil);
  TransactionAddFrm.cbbContractor.ItemIndex := 0;

  for i := 0 to EventList.Count - 1 do
    TransactionAddFrm.cbbEvent.ItemsEx.AddItem(ImageIndexGetString(EventList[i]), ImageIndexGetIndex(EventList[i]), ImageIndexGetIndex(EventList[i]), ImageIndexGetIndex(EventList[i]), 0, nil);
  TransactionAddFrm.cbbEvent.ItemIndex := 0;
  for i := 0 to StandardList.Count - 1 do
    TransactionAddFrm.DescriptionCBox.Items.Add(StandardList[i]);
  TransactionAddFrm.cbbmeasure.Items.Add('шт.');
  TransactionAddFrm.cbbmeasure.Items.Add('усл.');
  TransactionAddFrm.cbbmeasure.Items.Add('упак.');
  TransactionAddFrm.cbbmeasure.Items.Add('Л');
  TransactionAddFrm.cbbmeasure.Items.Add('мЛ.');
  TransactionAddFrm.cbbmeasure.Items.Add('Кг.');
  TransactionAddFrm.cbbmeasure.Items.Add('г.');
  TransactionAddFrm.cbbmeasure.Items.Add('мг.');
  TransactionAddFrm.cbbmeasure.Items.Add('м.');
  TransactionAddFrm.cbbmeasure.Items.Add('см.');
  TransactionAddFrm.cbbmeasure.Items.Add('мм.');
  TransactionAddFrm.cbbmeasure.Items.Add('м3');
  TransactionAddFrm.cbbmeasure.Items.Add('м2');
  TransactionAddFrm.cbbmeasure.Items.Add('мин.');
  TransactionAddFrm.cbbmeasure.Items.Add('ч.');
  TransactionAddFrm.cbbmeasure.Items.Add('день');
  TransactionAddFrm.cbbmeasure.Items.Add('нед.');
  TransactionAddFrm.cbbmeasure.Items.Add('мес.');
  TransactionAddFrm.cbbmeasure.Items.Add('год');
  TransactionAddFrm.cbbmeasure.Items.Add('качество');
  TransactionAddFrm.cbbmeasure.ItemIndex := 0;
end;


procedure FillBillList(BillNumber : integer);
var
  i     : Integer;
  item  : TListItem;
  spend : Extended;
begin
  spend := 0;
  TransactionAddFrm.lvBill.Clear;
  for i := 0 to TransactionGetCount - 1 do
    begin
      TransactionRead(i);
      if FinancyTransaction.BillNumber = BillNumber then
        begin
          spend := spend + FinancyTransaction.Summ;
          item := TransactionAddFrm.lvBill.Items.Add;
          item.Caption := DescriptionNameList[FinancyTransaction.Description.Name] + ' ' + DescriptionBrandList[FinancyTransaction.Description.Brand] + ' ' + DescriptionSeriesList[FinancyTransaction.Description.Series];
          item.ImageIndex := ImageIndexGetIndex(CategoryList[FinancyTransaction.Category]);
          item.SubItems.Add(FloatToStr(FinancyTransaction.Price));
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
          item.SubItems.Add(FloatToStr(FinancyTransaction.Summ));
          item.SubItems.Add(GetSubString(ImageIndexGetString(CategoryList[FinancyTransaction.Category]),GetSubElementsCount(CategoryList[FinancyTransaction.Category])));
          item.SubItems.Add(ImageIndexGetString(EventList[FinancyTransaction.Event]));
          item.SubItems.Add(ImageIndexGetString(PersonaList[FinancyTransaction.Persona]));
        end;
    end;
  item := TransactionAddFrm.lvBill.Items.Add;
  item.Caption := '  ИТОГО по чеку:';
  item.SubItems.Add('');
  item.SubItems.Add('');
  item.SubItems.Add('');
  item.SubItems.Add(FloatToStr(Spend));
end;


procedure TTransactionAddFrm.AccountChange(Sender: TObject);
begin
  if cbbAccount.ItemIndex <> FinancyTransaction.Account then
    cbbAccount.Color := clWindow
  else
    cbbAccount.Color := FirstColor;
  if indexType = ACCOUNT_INDEX then
    begin
      edtAdd.Text := cbbAccount.Items[cbbAccount.ItemIndex];
      cbbAdd.ItemIndex := ImageIndexGetIndex(AccountList[cbbAccount.ItemIndex]);
    end;
end;

procedure TTransactionAddFrm.AccountKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  i : integer;
begin
  if (Key = VK_INSERT) or (Key = VK_DELETE) then
    begin
       btnSub.Enabled := False;
       indexType := ACCOUNT_INDEX;
       pnlAdd.Left := cbbAccount.Left;
       pnlAdd.Top := cbbAccount.Top + cbbAccount.Height;
       pnlAdd.Visible := True;
       cbbAdd.Clear;
       cbbAdd.Images := lAccountImgLst;
       for I := 0 to lAccountImgLst.Count - 1 do
        cbbAdd.ItemsEx.AddItem('', i, i, i, 0, nil);
       edtAdd.Text := cbbAccount.Items[cbbAccount.ItemIndex];
       cbbAdd.ItemIndex := ImageIndexGetIndex(AccountList[cbbAccount.ItemIndex]);
    end;
  if (Key = VK_ESCAPE) then pnlAdd.Visible := False;
end;

procedure TTransactionAddFrm.btnBillAddClick(Sender: TObject);
var
  i, Index : Integer;
begin
  if not btnBill.Down then
    begin
      MessageDlg('Невозможно добавить в чек кнопка чека не нажата', mtInformation, [mbOK], 0);
      Exit;
    end;
  FinancyTransaction.Account := cbbAccount.ItemIndex;
  FinancyTransaction.Date := dtpDateTimeEdt.Date;
  if btnIncoming.Down then
    FinancyTransaction.Flag := TINCOME
  else
    if btnSpend.Down then
      FinancyTransaction.Flag := TSPENDING
    else
      begin
        MessageDlg('Случилось невороятное, но ничего страшного', mtInformation, [mbOK], 0);
        Exit;
      end;
  if StrToFloat(TransactionAddFrm.edtPrice.Text) <= 0 then
    begin         //-- Проверяем данные
      MessageDlg('Нулевая или отрицательная стоимость. Заполните обязательное поле', mtInformation, [mbOK], 0);
      edtPrice.Color := clRed;
      Exit;
    end;
  FinancyTransaction.Price := StrToFloat(TransactionAddFrm.edtPrice.Text);
  FinancyTransaction.Number := StrToFloat(TransactionAddFrm.edtNumber.Text);
  if StrToFloat(TransactionAddFrm.edtNumber.Text) <= 0 then
    begin
      MessageDlg('Нулевая или отрицательное количество. Заполните обязательное поле', mtInformation, [mbOK], 0);
      edtNumber.Color := clRed;
      Exit;
    end;
  FinancyTransaction.Discount := StrToFloat(TransactionAddFrm.edtDiscont.Text);
  if StrToFloat(TransactionAddFrm.edtDiscont.Text) < 0 then
  begin
      MessageDlg('Отрицательная скидка невозможна. Заполните обязательное поле', mtInformation, [mbOK], 0);
      edtDiscont.Color := clRed;
      Exit;
    end;
  FinancyTransaction.AbsProc := absProc.Checked;
  FinancyTransaction.Summ := StrToFloat(edtSumm.Text);
  if StrToFloat(edtSumm.Text) <= 0 then
    begin         //-- Проверяем данные
      MessageDlg('Нулевая или отрицательная сумма. Заполните обязательное поле', mtInformation, [mbOK], 0);
      edtSumm.Color := clRed;
      Exit;
    end;
  FinancyTransaction.Currency := cbbCurrency.ItemIndex;
  FinancyTransaction.Category := cbbCategory.ItemIndex;
  
  if DescriptionCBox.Text = '' then
    begin         //-- Проверяем данные
      MessageDlg('Не задано описание. Заполните обязательное поле', mtInformation, [mbOK], 0);
      DescriptionCBox.Color := clRed;
      Exit;
    end;

  index := DescriptionNameList.IndexOf(Trim(DescriptionCBox.Text));
  if index = -1 then
    FinancyTransaction.Description.Name := DescriptionNameList.Add(Trim(DescriptionCBox.Text))
  else
    FinancyTransaction.Description.Name := Index;

  index := DescriptionBrandList.IndexOf(Trim(DescriptionCBox1.Text));
  if index = -1 then
    FinancyTransaction.Description.Brand := DescriptionBrandList.Add(Trim(DescriptionCBox1.Text))
  else
    FinancyTransaction.Description.Brand := Index;

  index := DescriptionSeriesList.IndexOf(Trim(DescriptionCBox2.Text));
  if index = -1 then
    FinancyTransaction.Description.Series := DescriptionSeriesList.Add(Trim(DescriptionCBox2.Text))
  else
    FinancyTransaction.Description.Series := Index;

  FinancyTransaction.Persona:= cbbPersona.ItemIndex;

  index := CommentList.IndexOf(Trim(CommentEdt.Text));
  if index = -1 then
    FinancyTransaction.Comment := CommentList.Add(Trim(CommentEdt.Text))
  else
    FinancyTransaction.Comment := Index;

  FinancyTransaction.Contractor := cbbContractor.ItemIndex;
  FinancyTransaction.Event := cbbEvent.ItemIndex;
  FinancyTransaction.Measure := cbbmeasure.ItemIndex;
  FinancyTransaction.Priority := priorityBar.Position;
  FinancyTransaction.Packing := StrToInt(edtPacking.Text);
  if FinancyTransaction.BillNumber = 0 then
    FinancyTransaction.BillNumber := TransactionGetMaxBillNumber + 1;
  TransactionChangeByBill(FinancyTransaction.Contractor, FinancyTransaction.Account, FinancyTransaction.BillNumber, FinancyTransaction.Date);
  if chkStandardItem.Checked then SaveStandardItem(DescriptionCBox.Text);
  DBIndex := TransactionGetCount;
  if (FinancyTransaction.IDkey = -1) or (FinancyTransaction.IDkey <= TransactionGetMaxIDKey) then
    FinancyTransaction.IDkey := TransactionGetMaxIDKey + 1;
  TransactionSave(DBIndex);
  inc(DBIndex);
  FinancyTransaction.IDkey := -1;
  edtPrice.Text := '0,00';
  DescriptionCBox.Text := '';
  DescriptionCBox1.Text := '';
  DescriptionCBox2.Text := '';
  priorityBar.Position := 100;
  edtPacking.Text := '1';
  DescriptionCBox.Items.Clear;

  LoadDescrComboBox(DescriptionCBox, 0);
  LoadDescrComboBox(DescriptionCBox1, 1);
  LoadDescrComboBox(DescriptionCBox2, 2);

  edtDiscont.Text := '0';
  absProc.Checked := False;
  edtSumm.Text := '0';
  cbbCategory.ItemIndex := 0;
  cbbPersona.ItemIndex := 0;
  CommentEdt.Text := '';
  cbbmeasure.ItemIndex := 0;
  edtNumber.Text := FloatToStr(1);
  chkStandardItem.Checked := False;
  FillBillList(FinancyTransaction.BillNumber);
  if chkAvto.Checked then
    begin
      TempFinancyTransaction := FinancyTransaction;
      AutoAdd;
    end;
  inc(newRecFromBackup);
  inc(newRecFromSave);
  if newRecFromBackup >= maxRecFromBackup then
    if TransactionDoBackUp then newRecFromBackup := 0;
  if newRecFromSave >= maxRecFromMainDB then
    if TransactionSaveDB then newRecFromSave := 0;
end;

procedure TTransactionAddFrm.btnBillClick(Sender: TObject);
begin
  if btnSpend.Down and btnBill.Down then
      TransactionAddFrm.Height := lvBill.Top + lvBill.Height + 35
  else
    TransactionAddFrm.Height := 512;
end;

procedure TTransactionAddFrm.btnAddClick(Sender: TObject);
begin
  case indexType of
  ACCOUNT_INDEX:begin
                  AccountList.Add(ImageIndexSetIndex(edtAdd.Text, cbbAdd.ItemIndex));
                  cbbAccount.ItemsEx.AddItem(edtAdd.Text, cbbAdd.ItemIndex, cbbAdd.ItemIndex, cbbAdd.ItemIndex, 0, nil);
                  cbbAccount.ItemIndex := cbbAccount.Items.Count - 1;
                end;
  Currency_INDEX:begin
                   CurrencyList.Add(ImageIndexSetIndex(edtAdd.Text, cbbAdd.ItemIndex));
                   cbbCurrency.ItemsEx.AddItem(edtAdd.Text, cbbAdd.ItemIndex, cbbAdd.ItemIndex, cbbAdd.ItemIndex, 0, nil);
                   cbbCurrency.ItemIndex := cbbCurrency.Items.Count - 1;
                end;
  CATEGORY_INDEX:begin
                   CategoryList.Add(ImageIndexSetIndex(edtAdd.Text, cbbAdd.ItemIndex));
                   cbbCategory.ItemsEx.AddItem(edtAdd.Text, cbbAdd.ItemIndex, cbbAdd.ItemIndex, cbbAdd.ItemIndex, 0, nil);
                   cbbCategory.ItemIndex := cbbCategory.Items.Count - 1;
                 end;
  PERSONA_INDEX:begin
                  PersonaList.Add(ImageIndexSetIndex(edtAdd.Text, cbbAdd.ItemIndex));
                  cbbPersona.ItemsEx.AddItem(edtAdd.Text, cbbAdd.ItemIndex, cbbAdd.ItemIndex, cbbAdd.ItemIndex, 0, nil);
                  cbbPersona.ItemIndex := cbbPersona.Items.Count - 1;
                end;
  CONTRACTOR_INDEX:begin
                     ContractorList.Add(ImageIndexSetIndex(edtAdd.Text, cbbAdd.ItemIndex));
                     cbbContractor.ItemsEx.AddItem(edtAdd.Text, cbbAdd.ItemIndex, cbbAdd.ItemIndex, cbbAdd.ItemIndex, 0, nil);
                     cbbContractor.ItemIndex := cbbContractor.Items.Count - 1;
                   end;
  EVENT_INDEX:begin
                EventList.Add(ImageIndexSetIndex(edtAdd.Text, cbbAdd.ItemIndex));
                cbbEvent.ItemsEx.AddItem(edtAdd.Text, cbbAdd.ItemIndex, cbbAdd.ItemIndex, cbbAdd.ItemIndex, 0, nil);
                cbbEvent.ItemIndex := cbbEvent.Items.Count - 1;
              end;
  end;
end;

procedure TTransactionAddFrm.btnAutoClick(Sender: TObject);
begin
  pmAuto.Popup(TransactionAddFrm.Left + TransactionAddFrm.Width - btnAuto.Width, TransactionAddFrm.Top + ToolBar.Height);
end;

procedure TTransactionAddFrm.btnCancelClick(Sender: TObject);
begin
  pnlAdd.Visible := False;
end;

procedure TTransactionAddFrm.btnChangeClick(Sender: TObject);
var
  i, j             : Integer;
  oldS, newS, temp : string;
begin
  case indexType of
  ACCOUNT_INDEX:begin
                  j := cbbAccount.ItemIndex;
                  AccountList[j] := ImageIndexSetIndex(edtAdd.Text, cbbAdd.ItemIndex);
                  cbbAccount.Clear;
                  for i := 0 to AccountList.Count - 1 do
                    cbbAccount.ItemsEx.AddItem(ImageIndexGetString(AccountList[i]), ImageIndexGetIndex(AccountList[i]), ImageIndexGetIndex(AccountList[i]), ImageIndexGetIndex(AccountList[i]), 0, nil);
                  cbbAccount.ItemIndex := j;
                end;
  Currency_INDEX:begin
                  j := cbbCurrency.ItemIndex;
                  CurrencyList[j] := ImageIndexSetIndex(edtAdd.Text, cbbAdd.ItemIndex);
                  cbbCurrency.Clear;
                  for i := 0 to CurrencyList.Count - 1 do
                    cbbCurrency.ItemsEx.AddItem(ImageIndexGetString(CurrencyList[i]), ImageIndexGetIndex(CurrencyList[i]), ImageIndexGetIndex(CurrencyList[i]), ImageIndexGetIndex(CurrencyList[i]), 0, nil);
                  cbbCurrency.ItemIndex := j;
                end;
  CATEGORY_INDEX:begin
                  j := cbbCategory.ItemIndex;
                  if CategoryList[j] = '0:Нет' then Exit;
               //-- старое значение
                  OldS := ImageIndexGetString(CategoryList[j]);
                  if GetSubElementsCount(CategoryList[j]) = 0 then
                    temp := ImageIndexGetString(CategoryList[j])
                  else
                    temp := GetSubString(CategoryList[j], GetSubElementsCount(CategoryList[j]));
               //-- Заменяем субэлемент и добавляем новую иконку
                  if GetSubElementsCount(CategoryList[j]) > 0 then       // sub !!!
                    begin
                      CategoryList[j] := ReplaceSubString(CategoryList[j], edtAdd.Text);
                      CategoryList[j] := ImageIndexSetIndex(ImageIndexGetString(CategoryList[j]), cbbAdd.ItemIndex);
                    end
                  else
                    CategoryList[j] := ImageIndexSetIndex(edtAdd.Text, cbbAdd.ItemIndex);
           //-- перестроить весь список
                  NewS := GetSubString(CategoryList[j], GetSubElementsCount(CategoryList[j]));
                  NewS := StringReplace(oldS, temp, newS, [rfIgnoreCase]);
                  for I := 0 to CategoryList.Count - 1 do
                     CategoryList[i] := StringReplace(CategoryList[i], OldS, NewS, [rfIgnoreCase]);
                  cbbCategory.Clear;
                  for I := 0 to CategoryList.Count - 1 do
                    if GetSubElementsCount(CategoryList[i]) = 0 then
                      cbbCategory.ItemsEx.AddItem(ImageIndexGetString(CategoryList[i]), ImageIndexGetIndex(CategoryList[i]), ImageIndexGetIndex(CategoryList[i]), ImageIndexGetIndex(CategoryList[i]), 0, nil)
                     else
                      cbbCategory.ItemsEx.AddItem(GetSubString(CategoryList[i], GetSubElementsCount(CategoryList[i])), ImageIndexGetIndex(CategoryList[i]), ImageIndexGetIndex(CategoryList[i]), ImageIndexGetIndex(CategoryList[i]), GetSubElementsCount(CategoryList[i]), nil);
                  cbbCategory.ItemIndex := j;
                end;
  PERSONA_INDEX:begin
                  j := cbbPersona.ItemIndex;
                  if PersonaList[j] = '0:Нет' then Exit;
                  PersonaList[j] := ImageIndexSetIndex(edtAdd.Text, cbbAdd.ItemIndex);
                  cbbPersona.Clear;
                  for i := 0 to PersonaList.Count - 1 do
                    cbbPersona.ItemsEx.AddItem(ImageIndexGetString(PersonaList[i]), ImageIndexGetIndex(PersonaList[i]), ImageIndexGetIndex(PersonaList[i]), ImageIndexGetIndex(PersonaList[i]), 0, nil);
                  cbbPersona.ItemIndex := j;
                end;
  CONTRACTOR_INDEX:begin
                     j := cbbContractor.ItemIndex;
                     if ContractorList[j] = '0:Нет' then Exit;
                     ContractorList[j] := ImageIndexSetIndex(edtAdd.Text, cbbAdd.ItemIndex);
                     cbbContractor.Clear;
                     for i := 0 to ContractorList.Count - 1 do
                       cbbContractor.ItemsEx.AddItem(ImageIndexGetString(ContractorList[i]), ImageIndexGetIndex(ContractorList[i]), ImageIndexGetIndex(ContractorList[i]), ImageIndexGetIndex(ContractorList[i]), 0, nil);
                     cbbContractor.ItemIndex := j;
                   end;
  EVENT_INDEX:begin
                j := cbbEvent.ItemIndex;
                if EventList[j] = '0:Нет' then Exit;
                EventList[j] := ImageIndexSetIndex(edtAdd.Text, cbbAdd.ItemIndex);
                cbbEvent.Clear;
                for i := 0 to EventList.Count - 1 do
                  cbbEvent.ItemsEx.AddItem(ImageIndexGetString(EventList[i]), ImageIndexGetIndex(EventList[i]), ImageIndexGetIndex(EventList[i]), ImageIndexGetIndex(EventList[i]), 0, nil);
                cbbAccount.ItemIndex := j;
              end;
  end;
end;

procedure TTransactionAddFrm.btnDeleteClick(Sender: TObject);
var
  j, i : Integer;
  OldS : string;
begin
{ DONE : доделать проверку чтобы неудалялись активные индексы в базе }
{ DONE : Доделать чтобы удалялись подкатегории }
  case indexType of
  ACCOUNT_INDEX:begin
                  if MessageDlg('Удалить счет всем элементам базы использующим этот счет будет присвоен первый счет из списка ', mtInformation, [mbYes, mbNo], 0) = mrNo  then exit;
                  if AccountList.Count = 1 then
                     begin
                       MessageDlg('Нельзя удалить последний счет', mtWarning, [mbOK], 0);
                       Exit;
                     end;
                  j := cbbAccount.ItemIndex;
                  AccountList.Delete(cbbAccount.ItemIndex);
                  cbbAccount.Items.Delete(cbbAccount.ItemIndex);
                  cbbAccount.ItemIndex := j - 1;
                  TransactionChangeIndex(j, ACCOUNT_INDEX ,false);
                end;
  Currency_INDEX:begin
                   if MessageDlg('Удалить валюту! Элементам базы использующим эту валюту будет присвоена первая валюта из списка', mtInformation, [mbYes, mbNo], 0) = mrNo  then exit;
                   if CurrencyList.Count = 1 then
                     begin
                       MessageDlg('Нельзя удалить последнюю валюту', mtWarning, [mbOK], 0);
                       Exit;
                     end;
                   j := cbbCurrency.ItemIndex;
                   CurrencyList.Delete(cbbCurrency.ItemIndex);
                   cbbCurrency.Items.Delete(cbbCurrency.ItemIndex);
                   cbbCurrency.ItemIndex := j - 1;
                   TransactionChangeIndex(j, Currency_INDEX ,false);
                 end;
  CATEGORY_INDEX:begin
                   if MessageDlg('Удалить категорию и подкатегории! Элементам базы использующим эту категорию будет присвоено <Нет категории>', mtInformation, [mbYes, mbNo], 0) = mrNo  then exit;
                   if CategoryList[cbbCategory.ItemIndex] = '0:Нет' then Exit;
                   j := cbbCategory.ItemIndex;
                   OldS := ImageIndexGetString(CategoryList[j]);
                   i := 0;
                   repeat
                      if CategoryList.Count - 1 = i then exit;
                      if Pos(OldS, CategoryList[i]) <> 0 then
                        begin
                          CategoryList.Delete(i);
                          cbbCategory.Items.Delete(i);
                          TransactionChangeIndex(i, CATEGORY_INDEX ,false);
                          Dec(i);
                        end
                      else
                        inc(i);
                   until false;
                   cbbCategory.ItemIndex := j - 1;
                 end;
  PERSONA_INDEX:begin
                  if MessageDlg('Удалить персону! Элементам базы использующим эту персону будет присвоено <Общее>', mtInformation, [mbYes, mbNo], 0) = mrNo  then exit;
                  if PersonaList[cbbPersona.ItemIndex] = '0:Общее' then Exit;
                  j := cbbPersona.ItemIndex;
                  PersonaList.Delete(cbbPersona.ItemIndex);
                  cbbPersona.Items.Delete(cbbPersona.ItemIndex);
                  cbbPersona.ItemIndex := j - 1;
                  TransactionChangeIndex(j, PERSONA_INDEX ,false);
                end;
  CONTRACTOR_INDEX:begin
                     if MessageDlg('Удалить контрагента! Элементам базы использующим этого контрагента будет присвоено <Нет контрагента>', mtInformation, [mbYes, mbNo], 0) = mrNo  then exit;
                     if ContractorList[cbbContractor.ItemIndex] = '0:Нет' then Exit;
                     j := cbbContractor.ItemIndex;
                     ContractorList.Delete(cbbContractor.ItemIndex);
                     cbbContractor.Items.Delete(cbbContractor.ItemIndex);
                     cbbContractor.ItemIndex := j - 1;
                     TransactionChangeIndex(j, CONTRACTOR_INDEX ,false);
                   end;
  EVENT_INDEX:begin
                if MessageDlg('Удалить событие! Элементам базы использующим это событие будет присвоено <Нет события>', mtInformation, [mbYes, mbNo], 0) = mrNo  then exit;
                if EventList[cbbEvent.ItemIndex] = '0:Нет' then Exit;
                j := cbbEvent.ItemIndex;
                EventList.Delete(cbbEvent.ItemIndex);
                cbbEvent.Items.Delete(cbbEvent.ItemIndex);
                cbbEvent.ItemIndex := j - 1;
                TransactionChangeIndex(j, EVENT_INDEX ,false);
              end;
  end;
end;

procedure TTransactionAddFrm.btnIncomingClick(Sender: TObject);
begin
  btnBill.Enabled := False;
  btnBill.Down := False;
  if btnSpend.Down and btnBill.Down then
    TransactionAddFrm.Height := lvBill.Top + lvBill.Height + 35
  else
    TransactionAddFrm.Height := 512;
end;

procedure TTransactionAddFrm.btnSpendClick(Sender: TObject);
begin
  btnBill.Enabled := true;
  if btnSpend.Down and btnBill.Down then
    TransactionAddFrm.Height := lvBill.Top + lvBill.Height + 35
  else
    TransactionAddFrm.Height := 512;
end;

procedure TTransactionAddFrm.btnSubClick(Sender: TObject);
var
  j, i : Integer;
begin
  if  indexType = CATEGORY_INDEX then
    begin
      j := cbbCategory.ItemIndex;
      if CategoryList[j] = '0:Нет' then
        begin
          MessageDlg('Нельзя добавить подкатегорию к НЕТ', mtInformation, [mbOK], 0);
          Exit;
        end;
      CategoryList.Insert(j + 1, ImageIndexSetIndex(SetSubString(ImageIndexGetString(CategoryList[j]), edtAdd.Text), cbbAdd.ItemIndex));
      TransactionChangeIndex(j, CATEGORY_INDEX ,true);
      cbbCategory.Clear;
      for I := 0 to CategoryList.Count - 1 do
         if GetSubElementsCount(CategoryList[i]) = 0 then
           cbbCategory.ItemsEx.AddItem(ImageIndexGetString(CategoryList[i]), ImageIndexGetIndex(CategoryList[i]), ImageIndexGetIndex(CategoryList[i]), ImageIndexGetIndex(CategoryList[i]), 0, nil)
         else
           cbbCategory.ItemsEx.AddItem(GetSubString(CategoryList[i], GetSubElementsCount(CategoryList[i])), ImageIndexGetIndex(CategoryList[i]), ImageIndexGetIndex(CategoryList[i]), ImageIndexGetIndex(CategoryList[i]), GetSubElementsCount(CategoryList[i]), nil);
      cbbCategory.ItemIndex := j + 1;
    end;
end;

procedure TTransactionAddFrm.CancelbtnClick(Sender: TObject);
begin
  pnlAdd.Visible := False;
  TransactionAddFrm.Hide;
end;

procedure TTransactionAddFrm.CategoryChange(Sender: TObject);
begin
  if cbbCategory.ItemIndex <> FinancyTransaction.Category then
    cbbCategory.Color := clWindow
  else
    cbbCategory.Color := SecondColor;
  if indexType = CATEGORY_INDEX then
    begin
      edtAdd.Text := cbbCategory.Items[cbbCategory.ItemIndex];
      cbbAdd.ItemIndex := ImageIndexGetIndex(CategoryList[cbbCategory.ItemIndex]);
    end;
end;

procedure TTransactionAddFrm.CategoryKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  i : integer;
begin
  if (Key = VK_INSERT) or (Key = VK_DELETE) then
    begin
       btnSub.Enabled := True;
       indexType := CATEGORY_INDEX;
       pnlAdd.Left := cbbCurrency.Left;
       pnlAdd.Top := cbbCurrency.Top + cbbCurrency.Height;
       pnlAdd.Visible := True;
       cbbAdd.Clear;
       cbbAdd.Images := CategoryImgLst;
       for I := 0 to CategoryImgLst.Count - 1 do
         cbbAdd.ItemsEx.AddItem('', i, i, i, 0, nil);
       edtAdd.Text := cbbCategory.Items[cbbCategory.ItemIndex];
       cbbAdd.ItemIndex := ImageIndexGetIndex(CategoryList[cbbCategory.ItemIndex]);
    end;
  if (Key = VK_ESCAPE) then pnlAdd.Visible := False;
end;

procedure TTransactionAddFrm.cbbmeasureChange(Sender: TObject);
begin
  if cbbmeasure.ItemIndex <> FinancyTransaction.Measure then
    cbbmeasure.Color := clWindow
  else
    cbbmeasure.Color := FirstColor;
end;

procedure TTransactionAddFrm.CommentEdtChange(Sender: TObject);
begin
 { if CommentEdt.Text <> CommentList[FinancyTransaction.Comment] then
    CommentEdt.Color := clWindow
  else
    CommentEdt.Color := SecondColor;}
end;

procedure TTransactionAddFrm.ContractorChange(Sender: TObject);
begin
  if cbbContractor.ItemIndex <> FinancyTransaction.Contractor then
    cbbContractor.Color := clWindow
  else
    cbbContractor.Color := SecondColor;
  if indexType = CONTRACTOR_INDEX then
    begin
      edtAdd.Text := cbbContractor.Items[cbbContractor.ItemIndex];
      cbbAdd.ItemIndex := ImageIndexGetIndex(ContractorList[cbbContractor.ItemIndex]);
    end;
end;

procedure TTransactionAddFrm.ContractorKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
var
  i : integer;
begin
  if (Key = VK_INSERT) or (Key = VK_DELETE) then
    begin
       btnSub.Enabled := False;
       indexType := CONTRACTOR_INDEX;
       pnlAdd.Left := cbbContractor.Left;
       pnlAdd.Top := cbbContractor.Top + cbbContractor.Height;
       pnlAdd.Visible := True;
       cbbAdd.Clear;
       cbbAdd.Images := ContractorImgLst;
       for I := 0 to ContractorImgLst.Count - 1 do
         cbbAdd.ItemsEx.AddItem('', i, i, i, 0, nil);
       edtAdd.Text := cbbContractor.Items[cbbContractor.ItemIndex];
       cbbAdd.ItemIndex := ImageIndexGetIndex(ContractorList[cbbContractor.ItemIndex]);
    end;
  if (Key = VK_ESCAPE) then pnlAdd.Visible := False;
end;

procedure TTransactionAddFrm.CurrencyChange(Sender: TObject);
begin
  if indexType = Currency_INDEX then
    begin
      edtAdd.Text := cbbCurrency.Items[cbbCurrency.ItemIndex];
      cbbAdd.ItemIndex := ImageIndexGetIndex(CurrencyList[cbbCurrency.ItemIndex]);
    end;
end;

procedure TTransactionAddFrm.CurrencyKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  i : integer;
begin
  if (Key = VK_INSERT) or (Key = VK_DELETE) then
    begin
       btnSub.Enabled := False;
       indexType := Currency_INDEX;
       pnlAdd.Left := cbbCurrency.Left;
       pnlAdd.Top := cbbCurrency.Top + cbbCurrency.Height;
       pnlAdd.Visible := True;
       cbbAdd.Clear;
       cbbAdd.Images := CurrencyImgLst;
       for I := 0 to CurrencyImgLst.Count - 1 do
         cbbAdd.ItemsEx.AddItem('', i, i, i, 0, nil);
       edtAdd.Text := cbbCurrency.Items[cbbCurrency.ItemIndex];
       cbbAdd.ItemIndex := ImageIndexGetIndex(CurrencyList[cbbCurrency.ItemIndex]);
    end;
  if (Key = VK_ESCAPE) then pnlAdd.Visible := False;
end;

procedure TTransactionAddFrm.CurrencyCheckClick(Sender: TObject);
begin
  if CurrencyCheck.Checked then
    cbbCurrency.Enabled := True
  else
    cbbCurrency.Enabled := False;
end;

procedure TTransactionAddFrm.DateTimeEdtChange(Sender: TObject);
begin
  if dtpDateTimeEdt.Date <> FinancyTransaction.Date then
    dtpDateTimeEdt.Color := clWindow
  else
    dtpDateTimeEdt.Color := FirstColor;
end;

procedure TTransactionAddFrm.DescriptionCBoxChange(Sender: TObject);
begin
{  if DescriptionCBox.Text <> FinancyTransaction.Description then
    DescriptionCBox.Color := clWindow
  else
    DescriptionCBox.Color := FirstColor;
 // DescriptionCBox.DroppedDown := True;}
end;

procedure TTransactionAddFrm.DescriptionCBoxExit(Sender: TObject);
begin
//  DescriptionCBox.DroppedDown := False;
end;

procedure TTransactionAddFrm.DiscountEdtChange(Sender: TObject);
begin
  if (StrToFloat(TransactionAddFrm.edtDiscont.Text) <> FinancyTransaction.Discount) or (absProc.Checked <> FinancyTransaction.AbsProc) then
    edtDiscont.Color := clWindow
  else
    edtDiscont.Color := SecondColor;
  ReCalculate;  
end;

procedure TTransactionAddFrm.DiscountEdtClick(Sender: TObject);
begin
  edtDiscont.SelectAll;
end;

procedure TTransactionAddFrm.dtpDateTimeEdtChange(Sender: TObject);
begin
  if dtpDateTimeEdt.Date <> FinancyTransaction.Date then
    dtpDateTimeEdt.Color := clWindow
  else
    dtpDateTimeEdt.Color := SecondColor;
end;

procedure TTransactionAddFrm.edtAddClick(Sender: TObject);
begin
  edtAdd.SelectAll;
end;

procedure TTransactionAddFrm.edtDiscontKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9', ',']) then Key := #0;
  if (Key = ',') and (Pos(',', edtDiscont.Text) <> 0) then Key := #0;
end;

procedure TTransactionAddFrm.edtNumberKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9', ',',#8]) then Key := #0;
  if (Key = ',') and (Pos(',', edtNumber.Text) <> 0) then Key := #0;
end;

procedure TTransactionAddFrm.edtPriceKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9', ',', #8]) then Key := #0;
  if (Key = ',') and (Pos(',', edtPrice.Text) <> 0) then Key := #0;
end;

procedure TTransactionAddFrm.edtSummKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9', ',',#08]) then Key := #0;
  if (Key = ',') and (Pos(',', edtSumm.Text) <> 0) then Key := #0;
end;

procedure TTransactionAddFrm.EventChange(Sender: TObject);
begin
  if cbbEvent.ItemIndex <> FinancyTransaction.Event then
    cbbEvent.Color := clWindow
  else
    cbbEvent.Color := SecondColor;
  if indexType = EVENT_INDEX then
    begin
      edtAdd.Text := cbbEvent.Items[cbbEvent.ItemIndex];
      cbbAdd.ItemIndex := ImageIndexGetIndex(EventList[cbbEvent.ItemIndex]);
    end;
end;

procedure TTransactionAddFrm.EventKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  i : integer;
begin
  if (Key = VK_INSERT) or (Key = VK_DELETE) then
    begin
       btnSub.Enabled := False;
       indexType := EVENT_INDEX;
       pnlAdd.Left := cbbContractor.Left;
       pnlAdd.Top := cbbContractor.Top + cbbContractor.Height;
       pnlAdd.Visible := True;
       cbbAdd.Clear;
       cbbAdd.Images := EventImgLst;
       for I := 0 to EventImgLst.Count - 1 do
         cbbAdd.ItemsEx.AddItem('', i, i, i, 0, nil);
       edtAdd.Text := cbbEvent.Items[cbbEvent.ItemIndex];
       cbbAdd.ItemIndex := ImageIndexGetIndex(EventList[cbbEvent.ItemIndex]);
    end;
  if (Key = VK_ESCAPE) then pnlAdd.Visible := False;
end;

procedure TTransactionAddFrm.FormKeyPress(Sender: TObject; var Key: Char);
begin
 { if key = #27 then Close;
  if Key = #13 then
    Exit;}
end;

procedure TTransactionAddFrm.FormShow(Sender: TObject);
var
  i : Integer;
begin
  lvBill.Clear;
  DescriptionCBox.Items.Clear;
  LoadDescrComboBox(DescriptionCBox, 0);
  LoadDescrComboBox(DescriptionCBox1, 1);
  LoadDescrComboBox(DescriptionCBox2, 2);

  TransactionAddFrm.CalcPrice.tag := 0;
  CalcPrice.Glyph.Create;
  ToolBarImgLst.GetBitmap (TransactionAddFrm.CalcPrice.tag + 4, CalcPrice.Glyph);
  CalcPrice.Glyph.FreeImage;

  cbbAccount.ItemIndex := FinancyTransaction.Account;
  if FinancyTransaction.Flag = TINCOME then
    btnIncoming.Down := True
  else
    begin
      btnSpend.Down := True;
      btnBill.Enabled := True;
    end;
  dtpDateTimeEdt.Date := FinancyTransaction.Date;
  edtPrice.Text := FloatToStr(FinancyTransaction.Price);
  edtNumber.Text := FloatToStr(FinancyTransaction.Number);
  edtDiscont.Text := FloatToStr(FinancyTransaction.Discount);
  absProc.Checked := FinancyTransaction.AbsProc;
  edtSumm.Text := FloatToStr(FinancyTransaction.Summ);
  cbbCurrency.ItemIndex := FinancyTransaction.Currency;
  cbbCategory.ItemIndex := FinancyTransaction.Category;

  DescriptionCBox.Text := DescriptionNameList[FinancyTransaction.Description.Name];
  DescriptionCBox1.Text := DescriptionBrandList[FinancyTransaction.Description.Brand];
  DescriptionCBox2.Text := DescriptionSeriesList[FinancyTransaction.Description.Series];

  priorityBar.Position :=  FinancyTransaction.Priority;
  edtPacking.Text := IntToStr(FinancyTransaction.Packing);
  cbbPersona.ItemIndex := FinancyTransaction.Persona;
  CommentEdt.Text := CommentList[FinancyTransaction.Comment];
  cbbContractor.ItemIndex := FinancyTransaction.Contractor;
  cbbEvent.ItemIndex := FinancyTransaction.Event;
  TBill := FinancyTransaction.BillNumber;
  if FinancyTransaction.BillNumber = 0 then
    begin
      TransactionAddFrm.Height := 512;
      btnBill.Down := False;
    end
  else
    begin
      TempFinancyTransaction := FinancyTransaction;
      TransactionAddFrm.Height := lvBill.Top + lvBill.Height + 35;
      btnBill.Down := True;
      FillBillList(FinancyTransaction.BillNumber);
      FinancyTransaction := TempFinancyTransaction;
    end;
  FinancyTransaction.BillNumber := TBill;
  cbbmeasure.ItemIndex := FinancyTransaction.Measure;
  cbbAccount.Color := FirstColor;
  dtpDateTimeEdt.Color := FirstColor;
  edtPrice.Color := SecondColor;
  edtNumber.Color := SecondColor;
  edtDiscont.Color := SecondColor;
  edtSumm.Color := FirstColor;
  cbbCategory.Color := SecondColor;
  DescriptionCBox.Color := FirstColor;
  cbbPersona.Color := SecondColor;
  CommentEdt.Color := SecondColor;
  cbbContractor.Color := SecondColor;
  cbbEvent.Color := SecondColor;
  cbbmeasure.Color := FirstColor;
  chkStandardItem.Checked := False;
  chkAvto.Checked := False;
  FillAuto;
end;

procedure TTransactionAddFrm.NumberEdtChange(Sender: TObject);
begin
  if StrToFloat(TransactionAddFrm.edtNumber.Text) <> FinancyTransaction.Number then
    edtNumber.Color := clWindow
  else
    edtNumber.Color := SecondColor;
  ReCalculate;  
end;

procedure TTransactionAddFrm.NumberEdtClick(Sender: TObject);
begin
  edtNumber.SelectAll;
end;


//-- Сохраняем данные проверяем и пише в файл
procedure TTransactionAddFrm.OKbtnClick(Sender: TObject);
var
  index : Integer;
begin
  if btnBill.Down and (DBIndex >= TransactionGetCount) then
    begin
      pnlAdd.Visible := False;
      TransactionAddFrm.Hide;
      Exit;                          //-- Просто выход после ввода чека и нажатия ОК
    end;

  FinancyTransaction.Account := cbbAccount.ItemIndex;
  FinancyTransaction.Date := dtpDateTimeEdt.Date;
  if btnIncoming.Down then
    FinancyTransaction.Flag := TINCOME
  else
    if btnSpend.Down then
      FinancyTransaction.Flag := TSPENDING
    else
      begin
         MessageDlg('Случилось невороятное, но ничего страшного', mtInformation, [mbOK], 0);
         Exit;
      end;
  if StrToFloat(TransactionAddFrm.edtPrice.Text) <= 0 then
    begin         //-- Проверяем данные
      MessageDlg('Нулевая или отрицательная стоимость. Заполните обязательное поле', mtInformation, [mbOK], 0);
      edtPrice.Color := clRed;
      Exit;
    end;
  FinancyTransaction.Price := StrToFloat(TransactionAddFrm.edtPrice.Text);
  FinancyTransaction.Number := StrToFloat(TransactionAddFrm.edtNumber.Text);
  if StrToFloat(TransactionAddFrm.edtNumber.Text) <= 0 then
    begin
      MessageDlg('Нулевая или отрицательное количество. Заполните обязательное поле', mtInformation, [mbOK], 0);
      edtNumber.Color := clRed;
      Exit;
    end;
  FinancyTransaction.Discount := StrToFloat(TransactionAddFrm.edtDiscont.Text);
  if StrToFloat(TransactionAddFrm.edtDiscont.Text) < 0 then
  begin
      MessageDlg('Отрицательная скидка невозможна. Заполните обязательное поле', mtInformation, [mbOK], 0);
      edtDiscont.Color := clRed;
      Exit;
    end;
  FinancyTransaction.AbsProc := absProc.Checked;
  FinancyTransaction.Summ := StrToFloat(edtSumm.Text);
  if StrToFloat(edtSumm.Text) <= 0 then
    begin         //-- Проверяем данные
      MessageDlg('Нулевая или отрицательная сумма. Заполните обязательное поле', mtInformation, [mbOK], 0);
      edtSumm.Color := clRed;
      Exit;
    end;
  FinancyTransaction.Currency := cbbCurrency.ItemIndex;
  FinancyTransaction.Category := cbbCategory.ItemIndex;

  if DescriptionCBox.Text = '' then
    begin         //-- Проверяем данные
      MessageDlg('Не задано описание. Заполните обязательное поле', mtInformation, [mbOK], 0);
      DescriptionCBox.Color := clRed;
      Exit;
    end;

  index := DescriptionNameList.IndexOf(Trim(DescriptionCBox.Text));
  if index = -1 then
    FinancyTransaction.Description.Name := DescriptionNameList.Add(Trim(DescriptionCBox.Text))
  else
    FinancyTransaction.Description.Name := Index;

  index := DescriptionBrandList.IndexOf(Trim(DescriptionCBox1.Text));
  if index = -1 then
    FinancyTransaction.Description.Brand := DescriptionBrandList.Add(Trim(DescriptionCBox1.Text))
  else
    FinancyTransaction.Description.Brand := Index;

  index := DescriptionSeriesList.IndexOf(Trim(DescriptionCBox2.Text));
  if index = -1 then
    FinancyTransaction.Description.Series := DescriptionSeriesList.Add(Trim(DescriptionCBox2.Text))
  else
    FinancyTransaction.Description.Series := Index;

  FinancyTransaction.Persona:= cbbPersona.ItemIndex;

  index := CommentList.IndexOf(Trim(CommentEdt.Text));
  if index = -1 then
    FinancyTransaction.Comment := CommentList.Add(Trim(CommentEdt.Text))
  else
    FinancyTransaction.Comment := Index;

  FinancyTransaction.Contractor := cbbContractor.ItemIndex;
  FinancyTransaction.Event := cbbEvent.ItemIndex;
  FinancyTransaction.Measure := cbbmeasure.ItemIndex;
  FinancyTransaction.Priority := priorityBar.Position;
  FinancyTransaction.Packing := StrToInt(edtPacking.Text);
  FinancyTransaction.BillNumber := TBill;
  if not btnBill.Down then FinancyTransaction.BillNumber := 0;
  if FinancyTransaction.BillNumber <> 0 then   //-- Замена по всему чеку
    TransactionChangeByBill(FinancyTransaction.Contractor, FinancyTransaction.Account, FinancyTransaction.BillNumber, FinancyTransaction.Date);

  if chkAvto.Checked then
    begin
      TempFinancyTransaction := FinancyTransaction;
      AutoAdd;
    end;

  if (FinancyTransaction.IDkey = -1) or (FinancyTransaction.IDkey <= TransactionGetMaxIDKey) then
    FinancyTransaction.IDkey := TransactionGetMaxIDKey + 1;
  TransactionSave(DBIndex);
  pnlAdd.Visible := False;
  inc(newRecFromBackup);
  inc(newRecFromSave);
  if newRecFromBackup > maxRecFromBackup then
    if TransactionDoBackUp then newRecFromBackup := 0;
  if newRecFromSave > maxRecFromMainDB then
    if TransactionSaveDB then newRecFromSave := 0;
  TransactionAddFrm.Hide;
end;

procedure TTransactionAddFrm.PersonaChange(Sender: TObject);
begin
  if cbbPersona.ItemIndex <> FinancyTransaction.Persona then
    cbbPersona.Color := clWindow
  else
    cbbPersona.Color := SecondColor;
  if indexType = PERSONA_INDEX then
    begin
      edtAdd.Text := cbbPersona.Items[cbbPersona.ItemIndex];
      cbbAdd.ItemIndex := ImageIndexGetIndex(PersonaList[cbbPersona.ItemIndex]);
    end;
end;

procedure TTransactionAddFrm.PersonaKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  i : integer;
begin
  if (Key = VK_INSERT) or (Key = VK_DELETE) then
    begin
       btnSub.Enabled := False;
       indexType := PERSONA_INDEX;
       pnlAdd.Left := cbbPersona.Left;
       pnlAdd.Top := cbbPersona.Top + cbbPersona.Height;
       pnlAdd.Visible := True;
       cbbAdd.Clear;
       cbbAdd.Images := PersonaImgLst;
       for I := 0 to PersonaImgLst.Count - 1 do
         cbbAdd.ItemsEx.AddItem('', i, i, i, 0, nil);
       edtAdd.Text := cbbPersona.Items[cbbPersona.ItemIndex];
       cbbAdd.ItemIndex := ImageIndexGetIndex(PersonaList[cbbPersona.ItemIndex]);
    end;
  if (Key = VK_ESCAPE) then pnlAdd.Visible := False;
end;

procedure TTransactionAddFrm.PriceEdtChange(Sender: TObject);
begin
  if StrToFloat(TransactionAddFrm.edtPrice.Text) <> FinancyTransaction.Price then
    edtPrice.Color := clWindow
  else
    edtPrice.Color := SecondColor;
  ReCalculate;  
end;

procedure TTransactionAddFrm.PriceEdtClick(Sender: TObject);
begin
  edtPrice.SelectAll;
end;

procedure TTransactionAddFrm.PriceEdtKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9', ',']) then Key := #0;
end;

procedure TTransactionAddFrm.SummEdtChange(Sender: TObject);
begin
  if StrToFloat(edtSumm.Text) <> FinancyTransaction.Summ then
    edtSumm.Color := clWindow
  else
    edtSumm.Color := FirstColor;
  ReCalculate;
end;

procedure TTransactionAddFrm.SummEdtClick(Sender: TObject);
begin
  edtSumm.SelectAll;
end;

procedure TTransactionAddFrm.down1Click(Sender: TObject);
var
  s : string;
begin
  s := DescriptionCBox.SelText;
  DescriptionCBox1.Text := s;
  DescriptionCBox.Text := StringReplace(DescriptionCBox.Text, S, '', [rfIgnoreCase]);
end;

procedure TTransactionAddFrm.down2Click(Sender: TObject);
var
  s : string;
begin
  s := DescriptionCBox.SelText;
  DescriptionCBox2.Text := s;
  DescriptionCBox.Text := StringReplace(DescriptionCBox.Text, S, '', [rfIgnoreCase]);
end;

procedure TTransactionAddFrm.DescriptionCBoxKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if (GetCName(GetTopWindow(0)) = szcAutoSuggestDropdown) and AutoSuggestDropDownVisible then
    Exit;
  if (Key = $28) or (Key = $0D) then DescriptionCBox1.SetFocus;
end;

procedure TTransactionAddFrm.DescriptionCBox1KeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if (GetCName(GetTopWindow(0)) = szcAutoSuggestDropdown) and AutoSuggestDropDownVisible then
    Exit;
  if (Key = $28) or (Key = $0D) then DescriptionCBox2.SetFocus;
  if Key = $26 then DescriptionCBox.SetFocus;
end;

procedure TTransactionAddFrm.DescriptionCBox2KeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if (GetCName(GetTopWindow(0)) = szcAutoSuggestDropdown) and AutoSuggestDropDownVisible then
    Exit;
  if Key = $26 then DescriptionCBox1.SetFocus;
end;

procedure TTransactionAddFrm.CalcPriceClick(Sender: TObject);
begin
  TransactionAddFrm.CalcPrice.tag := TransactionAddFrm.CalcPrice.tag + 1;
  if TransactionAddFrm.CalcPrice.tag > 2 then TransactionAddFrm.CalcPrice.tag :=0;
  CalcPrice.Glyph.Create;
  ToolBarImgLst.GetBitmap (TransactionAddFrm.CalcPrice.tag + 4, CalcPrice.Glyph);
  CalcPrice.Glyph.FreeImage;
  ReCalculate;
end;

procedure TTransactionAddFrm.edtPackingChange(Sender: TObject);
begin
  ReCalculate;
end;

procedure TTransactionAddFrm.absProcClick(Sender: TObject);
begin
  ReCalculate;
end;

end.
