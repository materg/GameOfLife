unit uSimulation;

interface

uses System.Classes, Windows, Vcl.Graphics, Vcl.ExtCtrls;

const
  IDLE_SLEEP_TIME = 500; // how long to wait in Execute() when the simulation is NOT running
  CellDeadColour: TRGBTriple = (rgbtBlue: 0; rgbtGreen: 0; rgbtRed: 0);
  CellAliveColour: TRGBTriple = (rgbtBlue: 255; rgbtGreen: 255; rgbtRed: 255);

type
  pRGBTripleArray = ^TRGBTripleArray;
  TRGBTripleArray = array [word] OF TRGBTriple;

  TCell = record
    Alive, FlipState: boolean;
  end;

  TCellArray = array of array of TCell;

  TSimulation = class(TThread) // this is a singleton! well, at least it should be. Did I botch that up?
  private
    FPaintTo: TImage; // where to paint?
    FBoard: TCellArray; // our playing board
    FSimulating, FBoardIsATorus: boolean; // object fields are always initialised
    FSize: integer; // size of the array so we don't have to call Length() all the time
    function GetBoardSize: integer;
    procedure WriteBoardSize(const Value: integer);
    procedure Execute; override; // this is where we will do the calculations
    procedure GenerateAndDrawBitmap;
    procedure StepNow;
    function CountNeighbours(x, y: integer): byte;
    // used only internally. Byte is enough, since the max value is 8
    class var _instance: TSimulation;
  public
    class function Create: TSimulation;
    destructor destroy();
    procedure PopulateRandomly(iChanceNominator, iChanceDenominator: integer);
    procedure SingleStep;
    property BoardSize: integer read GetBoardSize write WriteBoardSize;
    property Cells: TCellArray read FBoard; // read-only
    property Active: boolean read FSimulating write FSimulating;
    property isToroidal: boolean read FBoardIsATorus write FBoardIsATorus;
    property PaintTo: TImage read FPaintTo write FPaintTo;
  end;

implementation

{ TSimulation }

function TSimulation.CountNeighbours(x, y: integer): byte;
var
  iMaxIndex: integer;
  // Indexes of all the fields
  ixL, ixD, ixR, ixU: integer; // left, down, right, up
begin
  // Feedback here would be appreciated, this is kinda shit.
  iMaxIndex := Length(FBoard) - 1;
  // Init the result
  result := 0;
  if FBoardIsATorus then
  begin
    // Toroidal solution
    ixL := x - 1;
    ixD := y + 1;
    ixR := x + 1;
    ixU := y - 1;
    if ixL < 0 then
      ixL := iMaxIndex;
    if ixD > iMaxIndex then
      ixD := 0;
    if ixR > iMaxIndex then
      ixR := 0;
    if ixU < 0 then
      ixU := iMaxIndex;

    if FBoard[ixL, y].Alive then
      inc(result);
    if FBoard[ixL, ixU].Alive then
      inc(result);
    if FBoard[ixL, ixD].Alive then
      inc(result);
    if FBoard[ixR, y].Alive then
      inc(result);
    if FBoard[ixR, ixU].Alive then
      inc(result);
    if FBoard[ixR, ixD].Alive then
      inc(result);
    if FBoard[x, ixU].Alive then
      inc(result);
    if FBoard[x, ixD].Alive then
      inc(result);
  end
  else
  begin
    //Empty-cell solution
    if (x > 0) and (FBoard[x - 1, y].Alive) then
      inc(result); // left
    if (x > 0) and (y > 0) and (FBoard[x - 1, y - 1].Alive) then
      inc(result); // left-up
    if (x > 0) and (y < iMaxIndex) and (FBoard[x - 1, y + 1].Alive) then
      inc(result); // left-down
    if (x < iMaxIndex) and (FBoard[x + 1, y].Alive) then
      inc(result); // right
    if (x < iMaxIndex) and (y > 0) and (FBoard[x + 1, y - 1].Alive) then
      inc(result); // right-up
    if (x < iMaxIndex) and (y < iMaxIndex) and (FBoard[x + 1, y + 1].Alive) then
      inc(result); // right-down
    if (y > 0) and (FBoard[x, y - 1].Alive) then
      inc(result); // up
    if (y < iMaxIndex) and (FBoard[x, y + 1].Alive) then
      inc(result); // down
  end;
end;

class function TSimulation.Create: TSimulation;
begin
  // Create a new instance if one doesn't already exist and set its board size to the default 400
  if _instance = nil then
  begin
    _instance := inherited Create(false) as Self;
    // we don't want to change the boardsize of an already exisiting instance, hence this is inside the if..then bloc
    _instance.BoardSize := 400;
  end;
  result := _instance;
end;

destructor TSimulation.destroy;
begin
  _instance := nil;
  inherited;
end;

procedure TSimulation.Execute;
begin
  while not Terminated do
  begin
    // Don't eat all of the CPU, please
    if not FSimulating then
    begin
      Sleep(IDLE_SLEEP_TIME);
      continue;
    end;
    StepNow; // perform the step
    GenerateAndDrawBitmap; // update user view
  end;
end;

procedure TSimulation.GenerateAndDrawBitmap;
var
  Bitmap: TBitmap;
  i, j, iMaxIndex: integer;
  row: pRGBTripleArray;
begin
  // This whole thing needs to be done differently, probably - but for now - it works
  iMaxIndex := FSize - 1; // faster than subtracting in the loop. I think.
  Bitmap := TBitmap.Create;
  try
    Bitmap.PixelFormat := pf24bit;
    Bitmap.Width := FSize; // for now - generate the whole board...
    Bitmap.Height := FSize;
    // Scanline "fun" begins here... This way is much faster than accessing the Pixel[i] property
    for i := 0 to iMaxIndex do
    begin
      row := Bitmap.ScanLine[i];
      for j := 0 to iMaxIndex do
        if FBoard[i, j].Alive then
          row[j] := CellAliveColour
        else
          row[j] := CellDeadColour;
    end;
    // Display the bitmap to user
    Synchronize(
      procedure // anonymous, since we want the Bitmap to be transferred and that's just easier...
      begin
        if Assigned(FPaintTo) then
          FPaintTo.Picture.Graphic := Bitmap;
      end);
  finally
    Bitmap.Free;
  end;
end;

function TSimulation.GetBoardSize: integer;
begin
  result := FSize;
  // Since it's a square, both sides are equal
end;

procedure TSimulation.PopulateRandomly(iChanceNominator, iChanceDenominator: integer);
var
  iRand, i, j, iMaxIndex: integer;
begin
  // Populates the board with a given chance of a cell being alive.
  FSimulating := false; // Stop (pause) the simulation if we're populating
  iMaxIndex := FSize - 1;
  for i := 0 to iMaxIndex do
    for j := 0 to iMaxIndex do
    begin
      iRand := Random(iChanceDenominator) + 1; // since random gives x such that 0 <= X < input
      if iRand <= iChanceNominator then
        FBoard[i, j].Alive := true
      else
        FBoard[i, j].Alive := false
    end;
  GenerateAndDrawBitmap;
end;

procedure TSimulation.SingleStep;
begin
  FSimulating := false; // if someone's doing a single step, pause the simulation.
  StepNow;
  GenerateAndDrawBitmap;
end;

procedure TSimulation.StepNow;
var
  i, j, iMaxIndex, iCellCount: integer;
begin
  // Traverse the whole array and prepare a new generation
  iMaxIndex := FSize - 1;
  for i := 0 to iMaxIndex do
    for j := 0 to iMaxIndex do
    begin
      iCellCount := CountNeighbours(i, j);
      if (FBoard[i, j].Alive) and ((iCellCount >= 4) or (iCellCount <= 1)) then
      begin
        FBoard[i, j].FlipState := true;
      end;
      if (not FBoard[i, j].Alive) and (iCellCount = 3) then
        FBoard[i, j].FlipState := true;
    end;
  // "Activate" the new generation
  for i := 0 to iMaxIndex do
    for j := 0 to iMaxIndex do
      if FBoard[i, j].FlipState then
      begin
        FBoard[i, j].Alive := not FBoard[i, j].Alive;
        FBoard[i, j].FlipState := false; // so it isn't done twice
      end;
end;

procedure TSimulation.WriteBoardSize(const Value: integer);
var
  i, j: integer;
begin
  SetLength(FBoard, Value, Value);
  // Set it all to zeroes (dead) now, since there could be some garbage from the memory
  for i := 0 to (Value - 1) do
    for j := 0 to (Value - 1) do
    begin
      FBoard[i, j].Alive := false;
      FBoard[i, j].FlipState := false;
    end;
  // 0 means dead, 1 means alive
  FSize := Value;
end;

end.
