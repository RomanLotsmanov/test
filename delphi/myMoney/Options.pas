unit Options;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs;

type
  TfrmOptions = class(TForm)
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MEM                    : Boolean = True;            // режим работы движка БД
  RoundN                 : Integer = -2;              // степень округления сумм при выводе
  MoneyOutFormat            : byte = 0;
  maxRecFromBackup       : Integer = 3;               //-- через сколько транзакций делать бэкап
  maxRecFromMainDB       : Integer = 5;               //-- через сколько транзакция делать запись файла
  maxDayDoFullBackup     : Integer = 3;               //-- через сколько дней делать полнй бэкап в отдельную папку
  FirstColor             : TColor = $00AEC9FF;        //-- цвет обязательного поля при добавлении транзакции
  SecondColor            : TColor = $0091FFFF;        //-- цвет необязательного поля при добавлении транзакции
  MonthColor             : TColor = clInfoBk;         //-- цвет выделеного месяца в календаре
  maxSChart              : Integer = 19;              //--
  ColAccDateWidth        : Integer;
  ColAccEventWidth       : Integer = 0;
  ColAccPersonaWidth     : Integer = 0;
  CalendarFontSize       : Integer = 8;               //-- Размер шрифта в календаре
  frmOptions             : TfrmOptions;        //-- форма

implementation

{$R *.dfm}

end.
