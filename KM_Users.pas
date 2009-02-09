unit KM_Users;

interface
uses
  classes, KromUtils, KM_Units, KM_Houses, KM_DeliverQueue, KM_Defaults, Windows, SysUtils;
type
  TUserControlType = (uct_User, uct_Computer);

  TKMUser = class(TObject)
  private
    fUserName: TPlayerID;
  public
    constructor Create(const aOwner:TPlayerID);
  end;

  TKMUserControl = class(TObject)
  private
    fUser: TKMUser;
  public
    constructor Create(const aOwner:TPlayerID);
    destructor Destroy; override;
  end;

  TKMUserUserControl = class(TKMUserControl)

  end;

  TKMUserComputerControl = class(TKMUserControl)

  end;

  TKMUserControlList = class(TKMList)
  private
    fUnits: TKMUnitsCollection;
    fHouses: TKMHousesCollection;
    fDeliverList: TKMDeliverQueue;
    fBuildList: TKMBuildingQueue;
    function GetCtrl(Index: Integer): TKMUserControl;
    function UserByName(const aOwner:TPlayerID): TKMUser;
    function GetSelHouse: TKMHouse;
    procedure SetSelHouse(ASelHouse:TKMHouse);
  public
    constructor Create();
    destructor Destroy; override;
    function Add(const aOwner:TPlayerID; aControlType: TUserControlType): TKMUserControl;
    property Ctrl[Index: Integer]: TKMUserControl read GetCtrl;
  public
    SelectedUnit: TKMUnit;
    function AddUnit(const aOwner: TPlayerID; aUnitType: TUnitType; Position: TKMPoint): TKMUnit;
    procedure AddHouse(aHouseType: THouseType; aLoc: TKMPoint; aOwner: TPlayerID);
    procedure AddRoadPlan(aLoc: TKMPoint; aMarkup:TMarkup);
    function AddHousePlan(aHouseType: THouseType; aLoc: TKMPoint; aOwner: TPlayerID):boolean;
    procedure RemHouse(Position: TKMPoint);
    procedure RemPlan(Position: TKMPoint);
    function FindEmptyHouse(aUnitType:TUnitType): TKMHouse;
    function FindHouse(aType:THouseType; X,Y:word): TKMHouse;
    function UnitsHitTest(X, Y: Integer; const UT:TUnitType = ut_Any): TKMUnit;
    procedure GetUnitLocations(aOwner:TPlayerID; out Loc:TKMPointList);
    function HousesHitTest(X, Y: Integer): TKMHouse;
    property SelectedHouse: TKMHouse read GetSelHouse write SetSelHouse;
    property DeliverList:TKMDeliverQueue read fDeliverList;
    property BuildList:TKMBuildingQueue read fBuildList;
  public
    procedure UpdateState;
    procedure Paint;
  end;

var
  ControlList: TKMUserControlList;

implementation

uses
  KM_Terrain;

{ TKMUserList }

function TKMUserControlList.Add(const aOwner:TPlayerID; aControlType: TUserControlType): TKMUserControl;
begin
  case aControlType of
    uct_User:
      Result:= TKMUserUserControl.Create(aOwner);
    uct_Computer:
      Result:= TKMUserComputerControl.Create(aOwner);
  else
    Result:= nil;
  end;
  if Result <> nil then
    Inherited Add(Result);
end;

function TKMUserControlList.AddUnit(const aOwner: TPlayerID; aUnitType: TUnitType; Position: TKMPoint): TKMUnit;
begin
    Result:=fUnits.Add(aOwner, aUnitType, Position.X, Position.Y);
end;


procedure TKMUserControlList.AddHouse(aHouseType: THouseType; aLoc: TKMPoint; aOwner: TPlayerID);
var xo:integer;
begin
  xo:=HouseDAT[byte(aHouseType)].EntranceOffsetX;
  fHouses.AddHouse(aHouseType, aLoc.X-xo, aLoc.Y, aOwner)
end;


procedure TKMUserControlList.AddRoadPlan(aLoc: TKMPoint; aMarkup:TMarkup);
begin
  if not fTerrain.CanPlaceRoad(aLoc,aMarkup) then exit;
  fTerrain.SetMarkup(aLoc, aMarkup);
  case aMarkup of
    mu_RoadPlan: BuildList.AddNewRoad(aLoc, fdt_Road);
    mu_FieldPlan: BuildList.AddNewRoad(aLoc, fdt_Field);
    mu_WinePlan: BuildList.AddNewRoad(aLoc, fdt_Wine);
    else Assert(false,'Wrong markup');
  end;
end;

function TKMUserControlList.AddHousePlan(aHouseType: THouseType; aLoc: TKMPoint; aOwner: TPlayerID):boolean;
var KMHouse:TKMHouse;
begin
  Result:=false;
  aLoc.X:=aLoc.X-HouseDAT[byte(aHouseType)].EntranceOffsetX;
  if not fTerrain.CanPlaceHouse(aLoc,aHouseType) then exit;
  KMHouse:=fHouses.AddPlan(aHouseType, aLoc.X, aLoc.Y, aOwner);
  fTerrain.SetHousePlan(aLoc, aHouseType, fdt_HousePlan);
  fTerrain.SetTileOwnership(aLoc,aHouseType, play_1);
  BuildList.AddNewHousePlan(KMHouse);
  Result:=true;
end;

procedure TKMUserControlList.RemHouse(Position: TKMPoint);
begin
  fHouses.Rem(Position.X, Position.Y);
end;

procedure TKMUserControlList.RemPlan(Position: TKMPoint);
begin
  if BuildList.RemRoad(Position) then
    fTerrain.RemMarkup(Position);
end;

function TKMUserControlList.FindEmptyHouse(aUnitType:TUnitType): TKMHouse;
begin
  Result:=fHouses.FindEmptyHouse(aUnitType);
end;

function TKMUserControlList.FindHouse(aType:THouseType; X,Y:word): TKMHouse;
begin
  Result:=fHouses.FindHouse(aType, X, Y);
end;

constructor TKMUserControlList.Create();
begin
  fUnits:= TKMUnitsCollection.Create;
  fHouses:= TKMHousesCollection.Create;
  fDeliverList:= TKMDeliverQueue.Create;
  fBuildList:= TKMBuildingQueue.Create;
end;

destructor TKMUserControlList.Destroy;
begin
  fUnits.Free;
  fHouses.Free;
  fDeliverList.Free;
  fBuildList.Free;
  inherited;
end;

function TKMUserControlList.GetCtrl(Index: Integer): TKMUserControl;
begin
  Result:= TKMUserControl(Items[Index]);
end;

procedure TKMUserControlList.Paint;
begin
  fUnits.Paint;
  fHouses.Paint;
end;

function TKMUserControlList.UnitsHitTest(X, Y: Integer; const UT:TUnitType = ut_Any): TKMUnit;
begin
  Result:= fUnits.HitTest(X, Y, UT);
end;

procedure TKMUserControlList.GetUnitLocations(aOwner:TPlayerID; out Loc:TKMPointList);
begin
  fUnits.GetLocations(aOwner,Loc);
end;

function TKMUserControlList.HousesHitTest(X, Y: Integer): TKMHouse;
begin
  Result:= fHouses.HitTest(X, Y);
end;

procedure TKMUserControlList.UpdateState;
begin
  fUnits.UpdateState;
  fHouses.UpdateState;
end;

function TKMUserControlList.UserByName(const aOwner:TPlayerID): TKMUser;
var
  I: Integer;
begin
  Result:= nil;
  for I := 0 to Count - 1 do
    if (Ctrl[I].fUser.fUserName=aOwner) then
    begin
      Result:= Ctrl[I].fUser;
      Exit;
    end;
end;

function TKMUserControlList.GetSelHouse: TKMHouse; begin result:=fHouses.SelectedHouse; end;
procedure TKMUserControlList.SetSelHouse(ASelHouse:TKMHouse); begin fHouses.SelectedHouse := ASelHouse; end;

{ TKMUser }

constructor TKMUser.Create(const aOwner:TPlayerID);
begin
  Inherited Create;
  fUserName:= aOwner;
end;


{ TKMUserControl }

constructor TKMUserControl.Create(const aOwner:TPlayerID);
begin
  Inherited Create;
  fUser:= TKMUser.Create(aOwner);
end;

destructor TKMUserControl.Destroy;
begin
  fUser.Free;
  inherited;
end;

end.
