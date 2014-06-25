program Life;

uses
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  Vcl.Forms,
  uFrmMain in 'Source\uFrmMain.pas' {frmMain},
  uSimulation in 'Source\uSimulation.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Game of Life';
  Application.CreateForm(TfrmMain, frmMain);
  //Initialise things that cannot be done in onCreate();
  uFrmMain.unitInit;
  Application.Run;
end.
