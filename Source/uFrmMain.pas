unit uFrmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Winapi.ShellApi, Vcl.ExtCtrls, Vcl.ImgList,
  uSimulation;

type
  TfrmMain = class(TForm)
    lblGithub: TLabel;
    pCanvas: TPanel;
    iCanvas: TImage;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    eBoardSideLen: TEdit;
    Button1: TButton;
    GroupBox2: TGroupBox;
    Label2: TLabel;
    eRandSeed: TEdit;
    Label3: TLabel;
    eChanceNominator: TEdit;
    eChanceDenominator: TEdit;
    Label4: TLabel;
    btnPopulate: TButton;
    GroupBox3: TGroupBox;
    ilButtons: TImageList;
    btnOn: TButton;
    btnPause: TButton;
    btnStep: TButton;
    btnSetSeed: TButton;
    GroupBox4: TGroupBox;
    rbEmptySolution: TRadioButton;
    rbTorusSolution: TRadioButton;
    procedure lblGithubClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure btnPopulateClick(Sender: TObject);
    procedure btnSetSeedClick(Sender: TObject);
    procedure rbEmptySolutionClick(Sender: TObject);
    procedure rbTorusSolutionClick(Sender: TObject);
    procedure btnStepClick(Sender: TObject);
    procedure btnPauseClick(Sender: TObject);
    procedure btnOnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;
procedure unitInit; // export

implementation

{$R *.dfm}

procedure unitInit; // called from project source
begin
  Randomize; // ugh, american spelling. Set a "random" seed
  frmMain.eRandSeed.Text := IntToStr(RandSeed); // show the seed in the edit provided
  // Assign the picture field
  TSimulation.Create.PaintTo := frmMain.iCanvas;
end;

procedure TfrmMain.Button1Click(Sender: TObject);
var
  tmpInt: integer;
begin
  // Even though we have "numbers only" an empty string would still be allowed
  if TryStrToInt(eBoardSideLen.Text, tmpInt) then
    TSimulation.Create.BoardSize := tmpInt;
  // Thanks to the singleton pattern, we don't need to store the instance in a global variable!
end;

procedure TfrmMain.btnOnClick(Sender: TObject);
begin
TSimulation.Create.Active := true;
end;

procedure TfrmMain.btnPauseClick(Sender: TObject);
begin
TSimulation.Create.Active := false;
end;

procedure TfrmMain.btnPopulateClick(Sender: TObject);
begin
  // Check whether the chance is specified correctly
  if (eChanceNominator.Text = '') or (eChanceNominator.Text = '') then
  begin
    messagebox(Handle, 'Please specify a valid "cell is alive" chance.' + #13 + 'For example - 1 in 2',
      'Error', MB_ok + MB_ICONERROR);
    exit;
  end;
  // Again, "numbers only" is on, so just casting is fine.
  TSimulation.Create.PopulateRandomly(StrTOInt(eChanceNominator.Text), StrTOInt(eChanceDenominator.Text)
    ); // remember - it's a singleton
end;

procedure TfrmMain.btnSetSeedClick(Sender: TObject);
begin
  // Let's hope the randseed is not empty
  if eRandSeed.Text = '' then
  begin
    messagebox(Handle, 'Please specify the seed!', 'Error', MB_ok + MB_ICONERROR);
    exit;
  end;
  // Since we know that we have "numbers only" on, we can just safely cast the string
  RandSeed := StrTOInt(eRandSeed.Text);
end;

procedure TfrmMain.btnStepClick(Sender: TObject);
begin
TSimulation.Create.SingleStep;
end;

procedure TfrmMain.lblGithubClick(Sender: TObject);
begin
  // Simply open the github page
  ShellExecute(0, 'open', 'https://github.com/materg/GameOfLife', '', '', 0);
end;

procedure TfrmMain.rbEmptySolutionClick(Sender: TObject);
begin
  TSimulation.Create.isToroidal := false;
end;

procedure TfrmMain.rbTorusSolutionClick(Sender: TObject);
begin
  TSimulation.Create.isToroidal := true;
end;

end.
