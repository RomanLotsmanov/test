program myFinancy;

uses
  Forms,
  Windows,
  mainForm in 'mainForm.pas' {mainFrm},
  TransactionAdd in 'TransactionAdd.pas' {TransactionAddFrm},
  myMoneyDBEngine in 'myMoneyDBEngine.pas',
  Splash in 'Splash.pas' {SplashFrm},
  about in 'about.pas' {AboutFrm},
  Options in 'Options.pas' {frmOptions};

{$R *.res}

begin
  Application.Initialize;
  SetWindowLong(Application.Handle, GWL_EXSTYLE, GetWindowLong(Application.Handle, GWL_EXSTYLE) or WS_EX_TOOLWINDOW);
//  Application.MainFormOnTaskbar := True;
  Application.Title := 'Учет финансов   v. 1.0.1';
  Application.CreateForm(TSplashFrm, SplashFrm);
  Application.CreateForm(TmainFrm, mainFrm);
  Application.CreateForm(TTransactionAddFrm, TransactionAddFrm);
  Application.CreateForm(TAboutFrm, AboutFrm);
  Application.CreateForm(TfrmOptions, frmOptions);
  Application.Run;
end.
