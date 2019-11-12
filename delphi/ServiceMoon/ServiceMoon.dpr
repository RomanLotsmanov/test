program ServiceMoon;

uses
  Forms,
  moon in 'moon.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Service monitor';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
