unit Unit3;

interface

uses
  Classes, windows;

type
  TPrnReq = class(TThread)
  private
    { Private declarations }
  protected
    procedure Execute; override;
  public
    Enabled : boolean;
  end;

implementation

uses unit1;

procedure TPrnReq.Execute;
begin
  while not terminated do
     if enabled then
       begin
         try
           MPrnReq;
           sleep(350);
         except
           AddLogStr('Исключительная ситуация в потоке');
         end;  
       end;
end;

end.

 