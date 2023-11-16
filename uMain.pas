unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, System.Generics.Collections;

type
  TCoordinates = record
    X: UInt8;
    Y: UInt8;
  end;

  TMineButton = class(TBitBtn)
    procedure userClick(Sender: TObject);
    procedure mouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure mouseIndiDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    private
      FisBomb: Boolean;
      FbombIndicator: UInt8;
      Fcoordinates: TCoordinates;
      Indicator: TLabel;
      Neighbours: TList<TMineButton>;
      function isInBounds(Coordinate: Integer): Boolean;
    public
      constructor Create(AOwner: TComponent; X: UInt8; Y: UInt8; bombChance: Float32); overload;
      procedure calcBombIndicator;
      procedure explode;
      procedure Free; overload;
      procedure addNeighbour(Neighbour: TMineButton);
      procedure remNeighbour(Neighbour: TMineButton);
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
begin
  SetLength(MineField,20,20);
  for Y := 0 to Length(MineField)-1 do begin
    for X := 0 to Length(MineField[Y])-1 do begin
      MineField[Y][X] := TMineButton.Create(Self,X,Y,0.15);
    end;
  end;

  for Y := 0 to Length(MineField)-1 do begin
    for X := 0 to Length(MineField[Y])-1 do begin
      MineField[Y][X].calcBombIndicator;
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
  Self.OnMouseDown := mouseDown;

  Neighbours := TList<TMineButton>.Create;
  //Add Neighbour references

  //Links
  if X > 0 then begin
    GameForm.MineField[Y][X-1].addNeighbour(Self);
    addNeighbour(GameForm.MineField[Y][X-1]);
  end;

  //Oben Links
  if (X > 0) and (Y > 0) then begin
    GameForm.MineField[Y-1][X-1].addNeighbour(Self);
    addNeighbour(GameForm.MineField[Y-1][X-1]);
  end;

  //Oben
  if Y > 0 then begin
    GameForm.MineField[Y-1][X].addNeighbour(Self);
    addNeighbour(GameForm.MineField[Y-1][X]);
  end;

  //Oben Rechts
  if (X < Length(GameForm.MineField[0])-1) and (Y > 0) then begin
    GameForm.MineField[Y-1][X+1].addNeighbour(Self);
    addNeighbour(GameForm.MineField[Y-1][X+1]);
  end;
end;

procedure TMineButton.addNeighbour(Neighbour: TMineButton);
begin
  Neighbours.Add(Neighbour);
end;

procedure TMineButton.remNeighbour(Neighbour: TMineButton);
begin
  Neighbours.Remove(Neighbour);
end;

procedure TMineButton.calcBombIndicator;
var
  Neighbour: TMineButton;
begin
  for Neighbour in Neighbours do
    if Neighbour.isBomb then Inc(FbombIndicator);
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
var
  Neighbour: TMineButton;

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
  Exit;
 end;

 if Enabled and (Indicator = nil) then begin
   if FbombIndicator < 1 then begin
    Enabled := False;
    for Neighbour in Neighbours do begin
      Neighbour.remNeighbour(Self);
      Neighbour.userClick(Self);
    end;

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
var
  Neighbour: TMineButton;
begin
  Enabled := False;
  if Indicator <> nil then FreeAndNil(Indicator);
  Indicator := TLabel.Create(Self);
  with Indicator do begin
    Parent := Self;
    Align := alClient;
    Alignment := taCenter;
    Layout := tlCenter;
    Caption := '%';
    Font.Color := clWebOrange;
  end;
  for Neighbour in Neighbours do Neighbour.remNeighbour(Self);
end;

procedure TMineButton.mouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then begin
    Indicator := TLabel.Create(Self);
    with Indicator do begin
      Parent := Self;
      Align := alClient;
      Alignment := taCenter;
      Layout := tlCenter;
      Caption := '#';
      Font.Color := clBlack;
      OnMouseDown := mouseIndiDown;
    end;
  end else if Button = mbLeft then begin
    if Indicator = nil then userClick(Sender)
    else Indicator.BringToFront;
  end;
end;

procedure TMineButton.mouseIndiDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
    FreeAndNil(Indicator);
end;

function TMineButton.isBomb: Boolean;
begin
  Result := FisBomb;
end;

procedure TMineButton.Free;
begin
  Neighbours.Clear;
  Neighbours.Free;
  inherited Free;
end;
end.
