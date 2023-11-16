program Minesweeper;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {GameForm};

{$R *.res}

begin
  {$IFDEF DEBUG}
    ReportMemoryLeaksOnShutdown := True;
  {$ENDIF}
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TGameForm, GameForm);
  Application.Run;
end.
