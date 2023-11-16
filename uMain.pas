unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons;

type
  TCoordinates = record
    X: UInt8;
    Y: UInt8;
  end;

  TMineButton = class(TBitBtn)
    procedure userClick(Sender: TObject);
    private
      FisBomb: Boolean;
      FbombIndicator: UInt8;
      Fcoordinates: TCoordinates;
      Indicator: TLabel;
      function isInBounds(Coordinate: Integer): Boolean;
    public
      constructor Create(AOwner: TComponent; X: UInt8; Y: UInt8; bombChance: Float32); overload;
      procedure checkNeighbour(checkForBombs: Boolean = False);
      procedure explode;
      function isBomb: Boolean;
  end;

  TMineField = array of array of TMineButton;

  TGameForm = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    MineField: TMineField;
  public
    procedure explodeAll;
  end;

var
  GameForm: TGameForm;

implementation

{$R *.dfm}

procedure TGameForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
  X,Y: Integer;
begin
  for Y := 0 to Length(MineField)-1 do begin
    for X := 0 to Length(MineField[Y])-1 do begin
      MineField[Y][X].Free;
    end;
  end;
  SetLength(MineField,0,0);
end;

procedure TGameForm.FormCreate(Sender: TObject);
var
  Y: Integer;
  X: Integer;
  NumOfBombs: Integer;
begin
  NumOfBombs := 20;
  SetLength(MineField,20,20);
  for Y := 0 to Length(MineField)-1 do begin
    for X := 0 to Length(MineField[Y])-1 do begin
      MineField[Y][X] := TMineButton.Create(Self,X,Y,0.15);
    end;
  end;

  for Y := 0 to Length(MineField)-1 do begin
    for X := 0 to Length(MineField[Y])-1 do begin
      MineField[Y][X].checkNeighbour(True);
    end;
  end;

  Self.Width := MineField[Length(MineField)-1][Length(MineField[Length(MineField)-1])-1].Left+135;
  Self.Height := MineField[Length(MineField)-1][Length(MineField[Length(MineField)-1])-1].Top+175;
end;

procedure TGameForm.explodeAll;
var
  X,Y: Integer;
begin
  for Y := 0 to Length(MineField)-1 do begin
    for X := 0 to Length(MineField[Y])-1 do begin
      if MineField[Y][X].isBomb then MineField[Y][X].explode;
      MineField[Y][X].OnClick := nil;
    end;
  end;
  SetLength(MineField,0,0);
end;

{ TMineButton }

constructor TMineButton.Create(AOwner: TComponent; X: UInt8; Y: UInt8; bombChance: Float32);
begin
  inherited Create(AOwner);
  Fcoordinates.X := X;
  Fcoordinates.Y := Y;
  FisBomb := Random < bombChance;
  Top := Y * 50;
  Left := X * 50;
  Width := 50;
  Height := 50;
  Parent := AOwner as TWinControl;
  Self.OnClick := userClick;
end;

procedure TMineButton.checkNeighbour(checkForBombs: Boolean = False);
begin
if FisBomb then FbombIndicator := 255 else begin

 //Check Topleft
 if isInBounds(Fcoordinates.Y-1) and isInBounds(Fcoordinates.X-1) then begin
  if checkForBombs then begin
    if GameForm.MineField[Fcoordinates.Y-1][Fcoordinates.X-1].isBomb then Inc(FbombIndicator);
  end;
 end;
 //Check Top
 if isInBounds(Fcoordinates.Y-1) then begin
  if checkForBombs then begin
    if GameForm.MineField[Fcoordinates.Y-1][Fcoordinates.X].isBomb then Inc(FbombIndicator);
  end else GameForm.MineField[Fcoordinates.Y-1][Fcoordinates.X].userClick(Self);
 end;
 //Check Topright
 if isInBounds(Fcoordinates.Y-1) and isInBounds(Fcoordinates.X+1) then begin
  if checkForBombs then begin
    if GameForm.MineField[Fcoordinates.Y-1][Fcoordinates.X+1].isBomb then Inc(FbombIndicator);
  end;
 end;
 //Check Left
 if isInBounds(Fcoordinates.X-1) then begin
  if checkForBombs then begin
    if GameForm.MineField[Fcoordinates.Y][Fcoordinates.X-1].isBomb then Inc(FbombIndicator);
  end else GameForm.MineField[Fcoordinates.Y][Fcoordinates.X-1].userClick(Self);
 end;
 //Check Right
 if isInBounds(Fcoordinates.X+1) then begin
  if checkForBombs then begin
    if GameForm.MineField[Fcoordinates.Y][Fcoordinates.X+1].isBomb then Inc(FbombIndicator);
  end else GameForm.MineField[Fcoordinates.Y][Fcoordinates.X+1].userClick(Self);
 end;
 //Check Bottomleft
 if isInBounds(Fcoordinates.Y+1) and isInBounds(Fcoordinates.X-1) then begin
  if checkForBombs then begin
    if GameForm.MineField[Fcoordinates.Y+1][Fcoordinates.X-1].isBomb then Inc(FbombIndicator);
  end;
 end;
 //Check Bottom
 if isInBounds(Fcoordinates.Y+1) then begin
  if checkForBombs then begin
    if GameForm.MineField[Fcoordinates.Y+1][Fcoordinates.X].isBomb then Inc(FbombIndicator);
  end else GameForm.MineField[Fcoordinates.Y+1][Fcoordinates.X].userClick(Self);
 end;
 //Check Bottomright
 if isInBounds(Fcoordinates.Y+1) and isInBounds(Fcoordinates.X+1) then begin
  if checkForBombs then begin
    if GameForm.MineField[Fcoordinates.Y+1][Fcoordinates.X+1].isBomb then Inc(FbombIndicator);
  end;
 end;
end;
end;

function TMineButton.isInBounds(Coordinate: Integer): Boolean;
var
  MinCoord, MaxCoord: Integer;
begin
  MinCoord := 0;
  MaxCoord := Length(GameForm.MineField)-1;

  Result := (Coordinate >= MinCoord) and (Coordinate <= MaxCoord);
end;

procedure TMineButton.userClick(Sender: TObject);
  function _getColor: TColor;
  begin
    case FbombIndicator of
      1: Result := clBlue;
      2: Result := clGreen;
      3: Result := clRed;
      4: Result := clPurple;
      5: Result := clBlack;
      6: Result := clGray;
      7: Result := clMaroon;
      8: Result := clWebTurquoise;
    end;
  end;
begin
 if FisBomb then begin
  GameForm.explodeAll;
  Abort;
 end;

 if Enabled then begin
   if FbombIndicator < 1 then begin
    Enabled := False;
    checkNeighbour;
   end else begin
    Enabled := False;
    Indicator := TLabel.Create(Self);
    with Indicator do begin
      Parent := Self;
      Align := alClient;
      Alignment := taCenter;
      Layout := tlCenter;
      Caption := IntToStr(FbombIndicator);
      Font.Color := _getColor;
    end;
   end;
 end;
end;

procedure TMineButton.explode;
begin
  Enabled := False;
  Indicator := TLabel.Create(Self);
  with Indicator do begin
    Parent := Self;
    Align := alClient;
    Alignment := taCenter;
    Layout := tlCenter;
    Caption := '%';
    Font.Color := clWebOrange;
  end;
end;

function TMineButton.isBomb: Boolean;
begin
  Result := FisBomb;
end;

end.
