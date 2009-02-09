unit KM_Settings;
interface
uses Windows, Classes, SysUtils, KromUtils, Math, KM_Defaults;

const MaxWaves = 200;

type
  TGameSettings = class
  private
    fBrightness:byte;
    fAutosave:boolean;
    fFastScroll:boolean; 
    fMouseSpeed:byte;
    fSoundFXVolume:byte;
    fMusicVolume:byte;
    fMusicOnOff:boolean;
    SlidersMin,SlidersMax:byte;
  public
    constructor Create;
    destructor Destroy; override;
    function LoadSettingsFromFile(filename:string):boolean;
    procedure SaveSettingsToFile(filename:string);
    property GetBrightness:byte read fBrightness default 1;
    procedure IncBrightness;
    procedure DecBrightness;
    property IsAutosave:boolean read fAutosave write fAutosave default true;
    property IsFastScroll:boolean read fFastScroll write fFastScroll default false;
    property GetSlidersMin:byte read SlidersMin;
    property GetSlidersMax:byte read SlidersMax;
    procedure SetMouseSpeed(Value:integer);
    procedure SetSoundFXVolume(Value:integer);
    procedure SetMusicVolume(Value:integer);
    property GetMouseSpeed:byte read fMouseSpeed;
    property GetSoundFXVolume:byte read fSoundFXVolume;
    property GetMusicVolume:byte read fMusicVolume;
    property IsMusic:boolean read fMusicOnOff write fMusicOnOff default true;
  end;

{These are mission specific settings and stats}
type
  TMissionSettings = class
  private
    AllowToBuild:array[1..HOUSE_COUNT]of boolean; //Allowance derived from mission script
    BuildReqDone:array[1..HOUSE_COUNT]of boolean; //If building requirements performed
    HouseBuiltCount,HouseLostCount:array[1..HOUSE_COUNT]of word;
    UnitTrainedCount,UnitLostCount:array[1..40]of word;
  public
    constructor Create;
    procedure CreatedHouse(aType:THouseType);
    procedure CreatedUnit(aType:TUnitType);
    procedure DestroyedHouse(aType:THouseType);
    procedure DestroyedUnit(aType:TUnitType);

    procedure UpdateReqDone(aType:THouseType);

    function GetHouseQty(aType:THouseType):integer;
    function GetUnitQty(aType:TUnitType):integer;
    function GetCanBuild(aType:THouseType):boolean;


  end;


var
  fGameSettings: TGameSettings;
  fMissionSettings: TMissionSettings;

implementation
uses KM_Log;

constructor TGameSettings.Create;
begin
  Inherited Create;
  SlidersMin:=1;
  SlidersMax:=20;
  LoadSettingsFromFile(ExeDir+'KaM_Remake_Settings.ini');
end;

destructor TGameSettings.Destroy;
begin
  SaveSettingsToFile(ExeDir+'KaM_Remake_Settings.ini');
  Inherited Destroy;
end;

function TGameSettings.LoadSettingsFromFile(filename:string):boolean;
var f:file;
begin
  Result:=false;
  if not CheckFileExists(filename,true) then exit;
  try
  assignfile(f,filename); reset(f,1);
  blockread(f, fBrightness, 1);
  blockread(f, fAutosave, 1);
  blockread(f, fFastScroll, 1);
  blockread(f, fMouseSpeed, 1);
  blockread(f, fSoundFXVolume, 1);
  blockread(f, fMusicVolume, 1);
  blockread(f, fMusicOnOff, 1);
  closefile(f);
  except end;
  Result:=true;
end;


procedure TGameSettings.SaveSettingsToFile(filename:string);
var f:file;
begin
  assignfile(f,filename); rewrite(f,1);
  blockwrite(f, fBrightness, 1);
  blockwrite(f, fAutosave, 1);
  blockwrite(f, fFastScroll, 1);
  blockwrite(f, fMouseSpeed, 1);
  blockwrite(f, fSoundFXVolume, 1);
  blockwrite(f, fMusicVolume, 1);
  blockwrite(f, fMusicOnOff, 1);
  closefile(f);
end;

procedure TGameSettings.IncBrightness;
begin
  fBrightness:= EnsureRange(fBrightness+1,1,6);
end;

procedure TGameSettings.DecBrightness;
begin
  fBrightness:= EnsureRange(fBrightness-1,1,6);
end;

procedure TGameSettings.SetMouseSpeed(Value:integer);
begin
  fMouseSpeed:=EnsureRange(Value,SlidersMin,SlidersMax);
end;

procedure TGameSettings.SetSoundFXVolume(Value:integer);
begin
  fSoundFXVolume:=EnsureRange(Value,SlidersMin,SlidersMax);
end;

procedure TGameSettings.SetMusicVolume(Value:integer);
begin
  fMusicVolume:=EnsureRange(Value,SlidersMin,SlidersMax);
end;


{ TMissionSettings }
constructor TMissionSettings.Create;
var i:integer;
begin
  Inherited Create;
  for i:=1 to length(AllowToBuild) do AllowToBuild[i]:=true;
end;


procedure TMissionSettings.CreatedHouse(aType:THouseType);
begin
  inc(HouseBuiltCount[byte(aType)]);
  UpdateReqDone(aType);
end;


procedure TMissionSettings.CreatedUnit(aType:TUnitType);
begin
  inc(UnitTrainedCount[byte(aType)]);
end;


procedure TMissionSettings.UpdateReqDone(aType:THouseType);
var i:integer;
begin
  for i:=1 to length(BuildingAllowed[1]) do if BuildingAllowed[byte(aType),i]<>ht_None then
    BuildReqDone[byte(BuildingAllowed[byte(aType),i])]:=true;
end;


procedure TMissionSettings.DestroyedHouse(aType:THouseType);
begin
  inc(HouseLostCount[byte(aType)]);
end;


procedure TMissionSettings.DestroyedUnit(aType:TUnitType);
begin
  inc(UnitLostCount[byte(aType)]);
end;


function TMissionSettings.GetHouseQty(aType:THouseType):integer;
begin
  Result:=HouseBuiltCount[byte(aType)]-HouseLostCount[byte(aType)];
end;


function TMissionSettings.GetUnitQty(aType:TUnitType):integer;
begin
  Result:=UnitTrainedCount[byte(aType)];
end;


function TMissionSettings.GetCanBuild(aType:THouseType):boolean;
begin
  Result:=BuildReqDone[byte(aType)] AND AllowToBuild[byte(aType)];
end;


end.
