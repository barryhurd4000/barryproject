program BarryTestFmx;

uses
  System.StartUpCopy,
  FMX.Forms,
  Main in 'Main.pas' {frmWebScan},
  uScanner in 'uScanner.pas',
  uOutputResult in 'uOutputResult.pas',
  uControl in 'uControl.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmWebScan, frmWebScan);
  Application.Run;
end.
