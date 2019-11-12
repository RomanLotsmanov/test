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
  MEM                    : Boolean = True;            // ����� ������ ������ ��
  RoundN                 : Integer = -2;              // ������� ���������� ���� ��� ������
  MoneyOutFormat            : byte = 0;
  maxRecFromBackup       : Integer = 3;               //-- ����� ������� ���������� ������ �����
  maxRecFromMainDB       : Integer = 5;               //-- ����� ������� ���������� ������ ������ �����
  maxDayDoFullBackup     : Integer = 3;               //-- ����� ������� ���� ������ ����� ����� � ��������� �����
  FirstColor             : TColor = $00AEC9FF;        //-- ���� ������������� ���� ��� ���������� ����������
  SecondColor            : TColor = $0091FFFF;        //-- ���� ��������������� ���� ��� ���������� ����������
  MonthColor             : TColor = clInfoBk;         //-- ���� ���������� ������ � ���������
  maxSChart              : Integer = 19;              //--
  ColAccDateWidth        : Integer;
  ColAccEventWidth       : Integer = 0;
  ColAccPersonaWidth     : Integer = 0;
  CalendarFontSize       : Integer = 8;               //-- ������ ������ � ���������
  frmOptions             : TfrmOptions;        //-- �����

implementation

{$R *.dfm}

end.
