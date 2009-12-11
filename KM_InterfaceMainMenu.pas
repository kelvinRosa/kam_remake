unit KM_InterfaceMainMenu;
interface
uses MMSystem, SysUtils, KromUtils, KromOGLUtils, Math, Classes, Controls, StrUtils, OpenGL,
  KM_Controls, KM_Defaults, KM_LoadDAT, Windows, KM_Settings;


type TKMMainMenuInterface = class
  private
    ScreenX,ScreenY:word;
    OffX,OffY:integer;
    SingleMap_Top:integer; //Top map in list
    SingleMap_Selected:integer; //Selected map
    SingleMapsInfo:TKMMapsInfo;
    MapEdSizeX,MapEdSizeY:integer; //Map Editor map size
    OldFullScreen:boolean;
    OldResolution:word;
  protected
    KMPanel_Main1:TKMPanel;
      L:array[1..20]of TKMLabel;
    KMPanel_MainMenu:TKMPanel;
      KMPanel_MainButtons:TKMPanel;
      KMImage_MainMenuBG,KMImage_MainMenu1,KMImage_MainMenu3:TKMImage; //Menu background
      KMButton_MainMenuTutor,KMButton_MainMenuTSK,KMButton_MainMenuTPR,
      KMButton_MainMenuSingle,KMButton_MainMenuLoad,KMButton_MainMenuMulti,
      KMButton_MainMenuMapEd,
      KMButton_MainMenuOptions,KMButton_MainMenuCredit,KMButton_MainMenuQuit:TKMButton;
      KMLabel_Version:TKMLabel;
    KMPanel_Single:TKMPanel;
      KMImage_SingleBG:TKMImage;
      KMPanel_SingleList,KMPanel_SingleDesc:TKMPanel;
      KMButton_SingleHeadMode,KMButton_SingleHeadTeams,KMButton_SingleHeadTitle,KMButton_SingleHeadSize,KMButton_SingleHeadNix:TKMButton;
      KMBevel_SingleBG:array[1..MENU_SP_MAPS_COUNT,1..4]of TKMBevel;
      KMButton_SingleMode:array[1..MENU_SP_MAPS_COUNT]of TKMImage;
      KMButton_SinglePlayers,KMButton_SingleSize:array[1..MENU_SP_MAPS_COUNT]of TKMLabel;
      KMLabel_SingleTitle1,KMLabel_SingleTitle2:array[1..MENU_SP_MAPS_COUNT]of TKMLabel;
      KMScrollBar_SingleMaps:TKMScrollBar;
      KMShape_SingleMap:TKMShape;
      KMImage_SingleScroll1:TKMImage;
      KMLabel_SingleTitle,KMLabel_SingleDesc:TKMLabel;
      KMLabel_SingleCondTyp,KMLabel_SingleCondWin,KMLabel_SingleCondDef:TKMLabel;
      KMLabel_SingleAllies,KMLabel_SingleEnemies:TKMLabel;
      KMButton_SingleBack,KMButton_SingleStart:TKMButton;
    KMPanel_Load:TKMPanel;
      KMImage_LoadBG:TKMImage;
      KMButton_Load:array[1..SAVEGAME_COUNT] of TKMButton;
      KMLabel_LoadResult:TKMLabel;
      KMButton_LoadBack:TKMButton;
    KMPanel_MapEd:TKMPanel;
      Image_MapEd_BG:TKMImage;
      KMPanel_MapEd_SizeXY:TKMPanel;
      CheckBox_MapEd_SizeX,CheckBox_MapEd_SizeY:array[1..MAPSIZE_COUNT] of TKMCheckBox;
      Button_MapEd_Start,Button_MapEdBack:TKMButton;
    KMPanel_Options:TKMPanel;
      Image_Options_BG:TKMImage;
      Label_Options_MouseSpeed,Label_Options_SFX,Label_Options_Music,Label_Options_MusicOn:TKMLabel;
      Ratio_Options_Mouse,Ratio_Options_SFX,Ratio_Options_Music:TKMRatioRow;
      Button_Options_MusicOn,Button_Options_Back:TKMButton;
      KMPanel_Options_Lang:TKMPanel;
        CheckBox_Options_Lang:array[1..LocalesCount] of TKMCheckBox;
      KMPanel_Options_Res:TKMPanel;
        CheckBox_Options_FullScreen:TKMCheckBox;
        CheckBox_Options_Resolution:array[1..RESOLUTION_COUNT] of TKMCheckBox;
        KMButton_Options_ResApply:TKMButton;
    KMPanel_Credits:TKMPanel;
      KMImage_CreditsBG:TKMImage;
      KMLabel_Credits:TKMLabel;
      KMButton_CreditsBack:TKMButton;
    KMPanel_Loading:TKMPanel;
      KMImage_LoadingBG:TKMImage;
      KMLabel_Loading:TKMLabel;
    KMPanel_Error:TKMPanel;
      KMImage_ErrorBG:TKMImage;
      KMLabel_Error:TKMLabel;
      Button_ErrorBack:TKMButton;
    KMPanel_Results:TKMPanel;
      KMImage_ResultsBG:TKMImage;
      Label_Results_Result:TKMLabel;
      KMPanel_Stats:TKMPanel;
      Label_Stat:array[1..9]of TKMLabel;
      KMButton_ResultsBack:TKMButton;
  private
    procedure Create_MainMenu_Page;
    procedure Create_Single_Page;
    procedure Create_Load_Page;
    procedure Create_MapEditor_Page;
    procedure Create_Options_Page(aGameSettings:TGameSettings);
    procedure Create_Credits_Page;
    procedure Create_Loading_Page;
    procedure Create_Error_Page;
    procedure Create_Results_Page;
    procedure SwitchMenuPage(Sender: TObject);
    procedure MainMenu_PlayTutorial(Sender: TObject);
    procedure SingleMap_PopulateList();
    procedure SingleMap_RefreshList();
    procedure SingleMap_ScrollChange(Sender: TObject);
    procedure SingleMap_SelectMap(Sender: TObject);
    procedure SingleMap_Start(Sender: TObject);
    procedure Load_Click(Sender: TObject);
    procedure MapEditor_Start(Sender: TObject);
    procedure Options_Change(Sender: TObject);
    procedure MapEd_Change(Sender: TObject);
  public
    MyControls: TKMControlsCollection;
    constructor Create(X,Y:word; aGameSettings:TGameSettings);
    destructor Destroy; override;
    procedure SetScreenSize(X,Y:word);
    procedure ShowScreen_Loading(Text:string);
    procedure ShowScreen_Error(Text:string);
    procedure ShowScreen_Main();
    procedure ShowScreen_Options();
    procedure ShowScreen_Results(Msg:gr_Message);
    procedure Fill_Results();
  public
    procedure UpdateState;
    procedure Paint;
end;


implementation
uses KM_Unit1, KM_Render, KM_LoadLib, KM_Game, KM_SoundFX, KM_PlayersCollection, KM_CommonTypes, Forms;


constructor TKMMainMenuInterface.Create(X,Y:word; aGameSettings:TGameSettings);
//var i:integer;
begin
inherited Create;

  fLog.AssertToLog(fTextLibrary<>nil, 'fTextLibrary should be initialized before MainMenuInterface');

  MyControls := TKMControlsCollection.Create;
  ScreenX := min(X,MENU_DESIGN_X);
  ScreenY := min(Y,MENU_DESIGN_Y);
  OffX := (X-MENU_DESIGN_X) div 2;
  OffY := (Y-MENU_DESIGN_Y) div 2;
  SingleMap_Top := 1;
  SingleMap_Selected := 1;
  MapEdSizeX := 64;
  MapEdSizeY := 64;

  KMPanel_Main1 := MyControls.AddPanel(nil,OffX,OffY,ScreenX,ScreenY); //Parent Panel for whole menu

  Create_MainMenu_Page;
  Create_Single_Page;
  Create_Load_Page;
  Create_MapEditor_Page;
  Create_Options_Page(aGameSettings);
  Create_Credits_Page;
  Create_Loading_Page;
  Create_Error_Page;
  Create_Results_Page;

  {for i:=1 to length(FontFiles) do
    L[i]:=MyControls.AddLabel(KMPanel_Main1,550,280+i*20,160,30,FontFiles[i]+' This is a test string for KaM Remake',TKMFont(i),kaLeft);
  //}

  //Show version info on every page
  KMLabel_Version := MyControls.AddLabel(KMPanel_Main1,8,8,100,30,GAME_VERSION+' / OpenGL '+fRender.GetRendererVersion,fnt_Antiqua,kaLeft);

  SwitchMenuPage(nil);
  //ShowScreen_Results(); //Put here page you would like to debug
end;


destructor TKMMainMenuInterface.Destroy;
begin
  FreeAndNil(SingleMapsInfo);
  FreeAndNil(MyControls);
  inherited;
end;


procedure TKMMainMenuInterface.SetScreenSize(X, Y:word);
begin
  ScreenX := X;
  ScreenY := Y;
end;


procedure TKMMainMenuInterface.ShowScreen_Loading(Text:string);
begin
  KMLabel_Loading.Caption:=Text;
  SwitchMenuPage(KMPanel_Loading);
end;


procedure TKMMainMenuInterface.ShowScreen_Error(Text:string);
begin
  KMLabel_Error.Caption:=Text;
  SwitchMenuPage(KMPanel_Error);
end;


procedure TKMMainMenuInterface.ShowScreen_Main();
begin
  SwitchMenuPage(nil);
end;


procedure TKMMainMenuInterface.ShowScreen_Options();
begin
  SwitchMenuPage(KMButton_MainMenuOptions);
end;


procedure TKMMainMenuInterface.ShowScreen_Results(Msg:gr_Message);
begin
  case Msg of
    gr_Win:    Label_Results_Result.Caption := fTextLibrary.GetSetupString(111);
    gr_Defeat: Label_Results_Result.Caption := fTextLibrary.GetSetupString(112);
    gr_Cancel: Label_Results_Result.Caption := 'Mission canceled';
    else       Label_Results_Result.Caption := '<<<LEER>>>'; //Thats string used in all Synetic games for missing texts =)
  end;
  SwitchMenuPage(KMPanel_Results);
end;


procedure TKMMainMenuInterface.Fill_Results();
begin
  if (MyPlayer=nil) or (MyPlayer.fMissionSettings=nil) then exit;

  Label_Stat[1].Caption := inttostr(MyPlayer.fMissionSettings.GetUnitsLost);
  Label_Stat[2].Caption := inttostr(MyPlayer.fMissionSettings.GetUnitsKilled);
  Label_Stat[3].Caption := inttostr(MyPlayer.fMissionSettings.GetHousesLost);
  Label_Stat[4].Caption := inttostr(MyPlayer.fMissionSettings.GetHousesDestroyed);
  Label_Stat[5].Caption := inttostr(MyPlayer.fMissionSettings.GetHousesConstructed);
  Label_Stat[6].Caption := inttostr(MyPlayer.fMissionSettings.GetUnitsTrained);
  Label_Stat[7].Caption := inttostr(MyPlayer.fMissionSettings.GetWeaponsProduced);
  Label_Stat[8].Caption := inttostr(MyPlayer.fMissionSettings.GetSoldiersTrained);
  Label_Stat[9].Caption := int2time(fGame.GetMissionTime);
end;


procedure TKMMainMenuInterface.Create_MainMenu_Page;
begin
  KMPanel_MainMenu:=MyControls.AddPanel(KMPanel_Main1,0,0,ScreenX,ScreenY);
    KMImage_MainMenuBG:=MyControls.AddImage(KMPanel_MainMenu,0,0,ScreenX,ScreenY,2,6);
    KMImage_MainMenuBG.FillArea;
    KMImage_MainMenu1:=MyControls.AddImage(KMPanel_MainMenu,120,80,423,164,4,5);
    KMImage_MainMenu3:=MyControls.AddImage(KMPanel_MainMenu,635,220,round(207*1.3),round(295*1.3),6,6);
    KMImage_MainMenu3.FillArea;

    KMPanel_MainButtons:=MyControls.AddPanel(KMPanel_MainMenu,155,280,350,400);
      KMButton_MainMenuTutor  :=MyControls.AddButton(KMPanel_MainButtons,0,  0,350,30,fTextLibrary.GetSetupString( 3),fnt_Metal,bsMenu);
      KMButton_MainMenuTSK    :=MyControls.AddButton(KMPanel_MainButtons,0, 40,350,30,fTextLibrary.GetSetupString( 1),fnt_Metal,bsMenu);
      KMButton_MainMenuTPR    :=MyControls.AddButton(KMPanel_MainButtons,0, 80,350,30,fTextLibrary.GetSetupString( 2),fnt_Metal,bsMenu);
      KMButton_MainMenuSingle :=MyControls.AddButton(KMPanel_MainButtons,0,120,350,30,fTextLibrary.GetSetupString( 4),fnt_Metal,bsMenu);
      KMButton_MainMenuLoad   :=MyControls.AddButton(KMPanel_MainButtons,0,160,350,30,fTextLibrary.GetSetupString(10),fnt_Metal,bsMenu);
      KMButton_MainMenuMulti  :=MyControls.AddButton(KMPanel_MainButtons,0,200,350,30,fTextLibrary.GetSetupString(11),fnt_Metal,bsMenu);
      KMButton_MainMenuMapEd  :=MyControls.AddButton(KMPanel_MainButtons,0,240,350,30,'Map Editor',fnt_Metal,bsMenu);
      KMButton_MainMenuOptions:=MyControls.AddButton(KMPanel_MainButtons,0,280,350,30,fTextLibrary.GetSetupString(12),fnt_Metal,bsMenu);
      KMButton_MainMenuCredit :=MyControls.AddButton(KMPanel_MainButtons,0,320,350,30,fTextLibrary.GetSetupString(13),fnt_Metal,bsMenu);
      KMButton_MainMenuQuit   :=MyControls.AddButton(KMPanel_MainButtons,0,400,350,30,fTextLibrary.GetSetupString(14),fnt_Metal,bsMenu);
      KMButton_MainMenuTutor.OnClick    := MainMenu_PlayTutorial;
      KMButton_MainMenuSingle.OnClick   := SwitchMenuPage;
      KMButton_MainMenuLoad.OnClick     := SwitchMenuPage;
      KMButton_MainMenuMapEd.OnClick    := SwitchMenuPage;
      KMButton_MainMenuOptions.OnClick  := SwitchMenuPage;
      KMButton_MainMenuCredit.OnClick   := SwitchMenuPage;
      KMButton_MainMenuQuit.OnClick     := Form1.Exit1.OnClick;
      if not SHOW_MAPED_IN_MENU then KMButton_MainMenuMapEd.Hide; //Let it be created, but hidden, I guess there's no need to seriously block it
      KMButton_MainMenuTSK.Disable;
      KMButton_MainMenuTPR.Disable;
      KMButton_MainMenuMulti.Disable;
      //KMButton_MainMenuCredit.Disable;
end;


procedure TKMMainMenuInterface.Create_Single_Page;
var i,k:integer;
begin
  SingleMapsInfo:=TKMMapsInfo.Create;

  KMPanel_Single:=MyControls.AddPanel(KMPanel_Main1,0,0,ScreenX,ScreenY);

    KMImage_SingleBG:=MyControls.AddImage(KMPanel_Single,0,0,ScreenX,ScreenY,2,6);
    KMImage_SingleBG.FillArea;

    KMPanel_SingleList:=MyControls.AddPanel(KMPanel_Single,512+22,84,445,600);

      KMButton_SingleHeadMode :=MyControls.AddButton(KMPanel_SingleList,  0,0, 40,40,42,4,bsMenu);
      KMButton_SingleHeadTeams:=MyControls.AddButton(KMPanel_SingleList, 40,0, 40,40,31,4,bsMenu);
      KMButton_SingleHeadTitle:=MyControls.AddButton(KMPanel_SingleList, 80,0,300,40,'Title',fnt_Metal,bsMenu);
      KMButton_SingleHeadSize :=MyControls.AddButton(KMPanel_SingleList,380,0, 40,40,'Size',fnt_Metal,bsMenu);
      KMButton_SingleHeadNix  :=MyControls.AddButton(KMPanel_SingleList,420,0, 25,40,'',fnt_Game,bsMenu);
      KMButton_SingleHeadNix.Disable;
      for i:=1 to MENU_SP_MAPS_COUNT do
      begin
        KMBevel_SingleBG[i,1]:=MyControls.AddBevel(KMPanel_SingleList,0,  40+(i-1)*40,40,40);
        KMBevel_SingleBG[i,2]:=MyControls.AddBevel(KMPanel_SingleList,40, 40+(i-1)*40,40,40);
        KMBevel_SingleBG[i,3]:=MyControls.AddBevel(KMPanel_SingleList,80, 40+(i-1)*40,300,40);
        KMBevel_SingleBG[i,4]:=MyControls.AddBevel(KMPanel_SingleList,380,40+(i-1)*40,40,40);
        for k:=1 to length(KMBevel_SingleBG[i]) do
        begin
          KMBevel_SingleBG[i,k].Tag:=i;
          KMBevel_SingleBG[i,k].OnClick:=SingleMap_SelectMap;
        end;
        KMButton_SingleMode[i]   :=MyControls.AddImage(KMPanel_SingleList,  0   ,40+(i-1)*40,40,40,28);
        KMButton_SinglePlayers[i]:=MyControls.AddLabel(KMPanel_SingleList, 40+20,40+(i-1)*40+14,40,40,'0',fnt_Metal, kaCenter);
        KMLabel_SingleTitle1[i]  :=MyControls.AddLabel(KMPanel_SingleList, 80+6 ,40+5+(i-1)*40,40,40,'<<<LEER>>>',fnt_Metal, kaLeft);
        KMLabel_SingleTitle2[i]  :=MyControls.AddLabel(KMPanel_SingleList, 80+6 ,40+22+(i-1)*40,40,40,'<<<LEER>>>',fnt_Game, kaLeft);
        KMButton_SingleSize[i]   :=MyControls.AddLabel(KMPanel_SingleList,380+20,40+(i-1)*40+14,40,40,'0',fnt_Metal, kaCenter);
      end;

      KMScrollBar_SingleMaps:=MyControls.AddScrollBar(KMPanel_SingleList,420,40,25,MENU_SP_MAPS_COUNT*40,bsMenu);
      KMScrollBar_SingleMaps.OnChange:=SingleMap_ScrollChange;

      KMShape_SingleMap:=MyControls.AddShape(KMPanel_SingleList,0,40,420,40,$FFFFFF00);

    KMPanel_SingleDesc:=MyControls.AddPanel(KMPanel_Single,45,84,445,600);

      MyControls.AddBevel(KMPanel_SingleDesc,0,0,445,220);

      //KMImage_SingleScroll1:=MyControls.AddImage(KMPanel_SingleDesc,0,0,445,220,15,5);
      //KMImage_SingleScroll1.StretchImage:=true;
      //KMImage_SingleScroll1.Height:=220; //Need to reset it after stretching is enabled, cos it can't stretch down by default

      KMLabel_SingleTitle:=MyControls.AddLabel(KMPanel_SingleDesc,445 div 2,35,420,180,'',fnt_Outline, kaCenter);
      KMLabel_SingleTitle.AutoWrap:=true;

      KMLabel_SingleDesc:=MyControls.AddLabel(KMPanel_SingleDesc,15,60,420,160,'',fnt_Metal, kaLeft);
      KMLabel_SingleDesc.AutoWrap:=true;

      MyControls.AddBevel(KMPanel_SingleDesc,125,230,192,192);

      MyControls.AddBevel(KMPanel_SingleDesc,0,428,445,20);
      KMLabel_SingleCondTyp:=MyControls.AddLabel(KMPanel_SingleDesc,8,431,445,20,'Mission type: ',fnt_Metal, kaLeft);
      MyControls.AddBevel(KMPanel_SingleDesc,0,450,445,20);
      KMLabel_SingleCondWin:=MyControls.AddLabel(KMPanel_SingleDesc,8,453,445,20,'Win condition: ',fnt_Metal, kaLeft);
      MyControls.AddBevel(KMPanel_SingleDesc,0,472,445,20);
      KMLabel_SingleCondDef:=MyControls.AddLabel(KMPanel_SingleDesc,8,475,445,20,'Defeat condition: ',fnt_Metal, kaLeft);
      MyControls.AddBevel(KMPanel_SingleDesc,0,494,445,20);
      KMLabel_SingleAllies:=MyControls.AddLabel(KMPanel_SingleDesc,8,497,445,20,'Allies: ',fnt_Metal, kaLeft);
      MyControls.AddBevel(KMPanel_SingleDesc,0,516,445,20);
      KMLabel_SingleEnemies:=MyControls.AddLabel(KMPanel_SingleDesc,8,519,445,20,'Enemies: ',fnt_Metal, kaLeft);

    KMButton_SingleBack := MyControls.AddButton(KMPanel_Single, 45, 650, 220, 30, fTextLibrary.GetSetupString(9), fnt_Metal, bsMenu);
    KMButton_SingleBack.OnClick := SwitchMenuPage;
    KMButton_SingleStart := MyControls.AddButton(KMPanel_Single, 270, 650, 220, 30, fTextLibrary.GetSetupString(8), fnt_Metal, bsMenu);
    KMButton_SingleStart.OnClick := SingleMap_Start;
end;


procedure TKMMainMenuInterface.Create_Load_Page;
var i:integer;
begin
  KMPanel_Load:=MyControls.AddPanel(KMPanel_Main1,0,0,ScreenX,ScreenY);
    KMImage_LoadBG:=MyControls.AddImage(KMPanel_Load,0,0,ScreenX,ScreenY,2,6);
    KMImage_LoadBG.FillArea;

    for i:=1 to SAVEGAME_COUNT do
    begin
      KMButton_Load[i]:=MyControls.AddButton(KMPanel_Load,100,100+i*40,180,30,'Slot '+inttostr(i),fnt_Metal, bsMenu);
      KMButton_Load[i].Tag:=i; //To simplify usage
      KMButton_Load[i].OnClick:=Load_Click;
    end;

    KMLabel_LoadResult:=MyControls.AddLabel(KMPanel_Load,124,130,100,30,'Debug',fnt_Metal,kaLeft); //Debug string

    KMButton_LoadBack := MyControls.AddButton(KMPanel_Load, 145, 650, 224, 30, fTextLibrary.GetSetupString(9), fnt_Metal, bsMenu);
    KMButton_LoadBack.OnClick := SwitchMenuPage;
end;


procedure TKMMainMenuInterface.Create_MapEditor_Page;
var i:integer;
begin
  KMPanel_MapEd:=MyControls.AddPanel(KMPanel_Main1,0,0,ScreenX,ScreenY);
    Image_MapEd_BG:=MyControls.AddImage(KMPanel_MapEd,0,0,ScreenX,ScreenY,2,6);
    Image_MapEd_BG.FillArea;

    //Should contain options to make a map from scratch, load map from file, generate random preset

    KMPanel_MapEd_SizeXY := MyControls.AddPanel(KMPanel_MapEd, 45, 100, 150, 300);
      MyControls.AddLabel(KMPanel_MapEd_SizeXY, 6, 0, 100, 30, 'Map size X:Y', fnt_Outline, kaLeft);
      MyControls.AddBevel(KMPanel_MapEd_SizeXY, 0, 20, 200, 10 + MAPSIZE_COUNT*20);
      for i:=1 to MAPSIZE_COUNT do
      begin
        CheckBox_MapEd_SizeX[i] := MyControls.AddCheckBox(KMPanel_MapEd_SizeXY, 8, 27+(i-1)*20, 100, 30, inttostr(MapSize[i]),fnt_Metal);
        CheckBox_MapEd_SizeY[i] := MyControls.AddCheckBox(KMPanel_MapEd_SizeXY, 68, 27+(i-1)*20, 100, 30, inttostr(MapSize[i]),fnt_Metal);
        CheckBox_MapEd_SizeX[i].OnClick := MapEd_Change;
        CheckBox_MapEd_SizeY[i].OnClick := MapEd_Change;
      end;

    Button_MapEdBack := MyControls.AddButton(KMPanel_MapEd, 145, 650, 220, 30, fTextLibrary.GetSetupString(9), fnt_Metal, bsMenu);
    Button_MapEdBack.OnClick := SwitchMenuPage;
    Button_MapEd_Start := MyControls.AddButton(KMPanel_MapEd, 370, 650, 220, 30, 'Create New Map', fnt_Metal, bsMenu);
    Button_MapEd_Start.OnClick := MapEditor_Start;
end;


procedure TKMMainMenuInterface.Create_Options_Page(aGameSettings:TGameSettings);
var i:integer;
begin
  KMPanel_Options:=MyControls.AddPanel(KMPanel_Main1,0,0,ScreenX,ScreenY);
    Image_Options_BG:=MyControls.AddImage(KMPanel_Options,0,0,ScreenX,ScreenY,2,6);
    Image_Options_BG.FillArea;

    Label_Options_MouseSpeed:=MyControls.AddLabel(KMPanel_Options,124,130,100,30,fTextLibrary.GetTextString(192),fnt_Metal,kaLeft);
    Label_Options_MouseSpeed.Disable;
    Ratio_Options_Mouse:=MyControls.AddRatioRow(KMPanel_Options,118,150,160,20,aGameSettings.GetSlidersMin,aGameSettings.GetSlidersMax);
    Ratio_Options_Mouse.Disable;
    Label_Options_SFX:=MyControls.AddLabel(KMPanel_Options,124,178,100,30,fTextLibrary.GetTextString(194),fnt_Metal,kaLeft);
    Ratio_Options_SFX:=MyControls.AddRatioRow(KMPanel_Options,118,198,160,20,aGameSettings.GetSlidersMin,aGameSettings.GetSlidersMax);
    Label_Options_Music:=MyControls.AddLabel(KMPanel_Options,124,226,100,30,fTextLibrary.GetTextString(196),fnt_Metal,kaLeft);
    Ratio_Options_Music:=MyControls.AddRatioRow(KMPanel_Options,118,246,160,20,aGameSettings.GetSlidersMin,aGameSettings.GetSlidersMax);

    Label_Options_MusicOn:=MyControls.AddLabel(KMPanel_Options,200,280,100,30,fTextLibrary.GetTextString(197),fnt_Metal,kaCenter);
    Button_Options_MusicOn:=MyControls.AddButton(KMPanel_Options,118,300,180,30,'',fnt_Metal, bsMenu);
    Button_Options_MusicOn.OnClick:=Options_Change;

    KMPanel_Options_Lang:=MyControls.AddPanel(KMPanel_Options,400,130,150,40+LocalesCount*20);
      MyControls.AddLabel(KMPanel_Options_Lang,6,0,100,30,'Language:',fnt_Outline,kaLeft);
      MyControls.AddBevel(KMPanel_Options_Lang,0,20,150,10+LocalesCount*20);

      for i:=1 to LocalesCount do
      begin
        CheckBox_Options_Lang[i]:=MyControls.AddCheckBox(KMPanel_Options_Lang,8,27+(i-1)*20,100,30,Locales[i,2],fnt_Metal);
        CheckBox_Options_Lang[i].OnClick:=Options_Change;
      end;

    KMPanel_Options_Res:=MyControls.AddPanel(KMPanel_Options,400,300,150,300);
      //Resolution selector
      MyControls.AddLabel(KMPanel_Options_Res,6,0,100,30,fTextLibrary.GetSetupString(20),fnt_Outline,kaLeft);
      MyControls.AddBevel(KMPanel_Options_Res,0,20,150,10+RESOLUTION_COUNT*20);
      for i:=1 to RESOLUTION_COUNT do
      begin
        CheckBox_Options_Resolution[i]:=MyControls.AddCheckBox(KMPanel_Options_Res,8,27+(i-1)*20,100,30,Format('%dx%d',[SupportedResolutions[i,1],SupportedResolutions[i,2],SupportedRefreshRates[i]]),fnt_Metal);
        CheckBox_Options_Resolution[i].Enabled:=(SupportedRefreshRates[i] > 0);
        CheckBox_Options_Resolution[i].OnClick:=Options_Change;
      end;

      CheckBox_Options_FullScreen:=MyControls.AddCheckBox(KMPanel_Options_Res,8,38+RESOLUTION_COUNT*20,100,30,'Fullscreen',fnt_Metal);
      CheckBox_Options_FullScreen.OnClick:=Options_Change;

      KMButton_Options_ResApply:=MyControls.AddButton(KMPanel_Options_Res,0,58+RESOLUTION_COUNT*20,150,30,'Apply',fnt_Metal, bsMenu);
      KMButton_Options_ResApply.OnClick:=Options_Change;
      KMButton_Options_ResApply.Disable;

    Ratio_Options_Mouse.Position:=aGameSettings.GetMouseSpeed;
    Ratio_Options_SFX.Position  :=aGameSettings.GetSoundFXVolume;
    Ratio_Options_Music.Position:=aGameSettings.GetMusicVolume;

    if aGameSettings.IsMusic then Button_Options_MusicOn.Caption:=fTextLibrary.GetTextString(201)
                             else Button_Options_MusicOn.Caption:=fTextLibrary.GetTextString(199);

    for i:=1 to KMPanel_Options.ChildCount do
    if TKMControl(KMPanel_Options.Childs[i]) is TKMRatioRow then
    begin
      TKMControl(KMPanel_Options.Childs[i]).OnClick:=Options_Change;
      TKMControl(KMPanel_Options.Childs[i]).OnChange:=Options_Change;
    end;

    Button_Options_Back:=MyControls.AddButton(KMPanel_Options,145,650,220,30,fTextLibrary.GetSetupString(9),fnt_Metal,bsMenu);
    Button_Options_Back.OnClick:=SwitchMenuPage;
end;


procedure TKMMainMenuInterface.Create_Credits_Page;
begin
  KMPanel_Credits:=MyControls.AddPanel(KMPanel_Main1,0,0,ScreenX,ScreenY);
    KMImage_CreditsBG:=MyControls.AddImage(KMPanel_Credits,0,0,ScreenX,ScreenY,2,6);
    KMImage_CreditsBG.FillArea;
    KMLabel_Credits:=MyControls.AddLabel(KMPanel_Credits,ScreenX div 2,ScreenY,100,30,fTextLibrary.GetSetupString(300),fnt_Grey,kaCenter);
    KMButton_CreditsBack:=MyControls.AddButton(KMPanel_Credits,100,640,224,30,fTextLibrary.GetSetupString(9),fnt_Metal,bsMenu);
    KMButton_CreditsBack.OnClick:=SwitchMenuPage;
end;


procedure TKMMainMenuInterface.Create_Loading_Page;
begin
  KMPanel_Loading:=MyControls.AddPanel(KMPanel_Main1,0,0,ScreenX,ScreenY);
    KMImage_LoadingBG:=MyControls.AddImage(KMPanel_Loading,0,0,ScreenX,ScreenY,2,6);
    KMImage_LoadingBG.FillArea;
    MyControls.AddLabel(KMPanel_Loading,ScreenX div 2,ScreenY div 2 - 20,100,30,'Loading... Please wait',fnt_Outline,kaCenter);
    KMLabel_Loading:=MyControls.AddLabel(KMPanel_Loading,ScreenX div 2,ScreenY div 2+10,100,30,'...',fnt_Grey,kaCenter);
end;


procedure TKMMainMenuInterface.Create_Error_Page;
begin
  KMPanel_Error:=MyControls.AddPanel(KMPanel_Main1,0,0,ScreenX,ScreenY);
    KMImage_ErrorBG:=MyControls.AddImage(KMPanel_Error,0,0,ScreenX,ScreenY,2,6);
    KMImage_ErrorBG.FillArea;
    MyControls.AddLabel(KMPanel_Error,ScreenX div 2,ScreenY div 2 - 20,100,30,'Error has occured...',fnt_Outline,kaCenter);
    KMLabel_Error:=MyControls.AddLabel(KMPanel_Error,ScreenX div 2,ScreenY div 2+10,100,30,'...',fnt_Grey,kaCenter);
    Button_ErrorBack:=MyControls.AddButton(KMPanel_Error,100,640,224,30,fTextLibrary.GetSetupString(9),fnt_Metal,bsMenu);
    Button_ErrorBack.OnClick:=SwitchMenuPage;
end;


procedure TKMMainMenuInterface.Create_Results_Page;
var i:integer; Adv:integer;
begin
  KMPanel_Results:=MyControls.AddPanel(KMPanel_Main1,0,0,ScreenX,ScreenY);
    KMImage_ResultsBG:=MyControls.AddImage(KMPanel_Results,0,0,ScreenX,ScreenY,7,5);
    KMImage_ResultsBG.FillArea;

    Label_Results_Result:=MyControls.AddLabel(KMPanel_Results,512,200,100,30,'<<<LEER>>>',fnt_Metal,kaCenter);

    KMPanel_Stats:=MyControls.AddPanel(KMPanel_Results,80,240,400,400);
    Adv:=0;
    for i:=1 to 9 do
    begin
      inc(Adv,25);
      if i in [3,6,7,9] then inc(Adv,15);
      MyControls.AddLabel(KMPanel_Stats,0,Adv,100,30,fTextLibrary.GetSetupString(112+i),fnt_Metal,kaLeft);
      Label_Stat[i]:=MyControls.AddLabel(KMPanel_Stats,340,Adv,100,30,'00',fnt_Metal,kaRight);
    end;

    KMButton_ResultsBack:=MyControls.AddButton(KMPanel_Results,100,640,224,30,fTextLibrary.GetSetupString(9),fnt_Metal,bsMenu);
    KMButton_ResultsBack.OnClick:=SwitchMenuPage;
end;


procedure TKMMainMenuInterface.SwitchMenuPage(Sender: TObject);
var i:integer;
begin
  //First thing - hide all existing pages
  for i:=1 to KMPanel_Main1.ChildCount do
    if KMPanel_Main1.Childs[i] is TKMPanel then
      KMPanel_Main1.Childs[i].Hide;

  {Return to MainMenu if Sender unspecified}
  if Sender=nil then KMPanel_MainMenu.Show;

  {Return to MainMenu}
  if (Sender=KMButton_CreditsBack)or
     (Sender=KMButton_SingleBack)or
     (Sender=KMButton_LoadBack)or
     (Sender=Button_MapEdBack)or
     (Sender=Button_ErrorBack)or
     (Sender=KMButton_ResultsBack) then
    KMPanel_MainMenu.Show;

  {Return to MainMenu and restore resolution changes}
  if Sender=Button_Options_Back then begin
    fGame.fGameSettings.IsFullScreen := OldFullScreen;
    fGame.fGameSettings.SetResolutionID := OldResolution;
    KMPanel_MainMenu.Show;
  end;

  {Show SingleMap menu}
  if Sender=KMButton_MainMenuSingle then begin
    SingleMap_PopulateList();
    SingleMap_RefreshList();
    KMPanel_Single.Show;
  end;

  {Show Load menu}
  if Sender=KMButton_MainMenuLoad then begin
    //Load_PopulateList();
    KMPanel_Load.Show;
  end;

  {Show MapEditor menu}
  if Sender=KMButton_MainMenuMapEd then begin
    MapEd_Change(nil);
    KMPanel_MapEd.Show;
  end;

  {Show Options menu}
  if Sender=KMButton_MainMenuOptions then begin
    OldFullScreen := fGame.fGameSettings.IsFullScreen;
    OldResolution := fGame.fGameSettings.GetResolutionID;
    Options_Change(nil);
    KMPanel_Options.Show;
  end;

  {Show Credits}
  if Sender=KMButton_MainMenuCredit then begin
    KMPanel_Credits.Show;
    KMLabel_Credits.Top := ScreenY;
    KMLabel_Credits.SmoothScrollToTop := TimeGetTime; //Set initial position
  end;

  {Show Loading... screen}
  if Sender=KMPanel_Loading then
    KMPanel_Loading.Show;

  {Show Error... screen}
  if Sender=KMPanel_Error then
    KMPanel_Error.Show;

  {Show Results screen}
  if Sender=KMPanel_Results then //This page can be accessed only by itself
    KMPanel_Results.Show;

  { Save settings when leaving options, if needed }
  if Sender=Button_Options_Back then
    if fGame.fGameSettings.GetNeedsSave then
      fGame.fGameSettings.SaveSettings;
end;


procedure TKMMainMenuInterface.MainMenu_PlayTutorial(Sender: TObject);
begin
  fLog.AssertToLog(Sender=KMButton_MainMenuTutor,'not KMButton_MainMenuTutor');
  fGame.StartGame(ExeDir+'data\mission\mission0.dat', 'Tutorial');
end;


procedure TKMMainMenuInterface.SingleMap_PopulateList();
begin
  SingleMapsInfo.ScanSingleMapsFolder('');
end;


procedure TKMMainMenuInterface.SingleMap_RefreshList();
var i,ci:integer;
begin
//  SingleMapsInfo.ScanSingleMapsFolder('');

  for i:=1 to MENU_SP_MAPS_COUNT do begin
    ci:=SingleMap_Top+i-1;
    if ci>SingleMapsInfo.GetMapCount then begin
      KMButton_SingleMode[i].TexID:=0;
      KMButton_SinglePlayers[i].Caption:='';
      KMLabel_SingleTitle1[i].Caption:='';
      KMLabel_SingleTitle2[i].Caption:='';
      KMButton_SingleSize[i].Caption:='';
    end else begin
      KMButton_SingleMode[i].TexID:=28+byte(not SingleMapsInfo.IsFight(ci))*14;
      KMButton_SinglePlayers[i].Caption:=inttostr(SingleMapsInfo.GetPlayerCount(ci));
      KMLabel_SingleTitle1[i].Caption:=SingleMapsInfo.GetTitle(ci);
      KMLabel_SingleTitle2[i].Caption:=SingleMapsInfo.GetSmallDesc(ci);
      KMButton_SingleSize[i].Caption:=SingleMapsInfo.GetMapSize(ci);
    end;
  end;

  KMScrollBar_SingleMaps.MinValue := 1;
  KMScrollBar_SingleMaps.MaxValue := max(1, SingleMapsInfo.GetMapCount - MENU_SP_MAPS_COUNT);
  KMScrollBar_SingleMaps.Position := EnsureRange(KMScrollBar_SingleMaps.Position,KMScrollBar_SingleMaps.MinValue,KMScrollBar_SingleMaps.MaxValue);

  SingleMap_SelectMap(KMBevel_SingleBG[1,3]); //Select first map
end;


procedure TKMMainMenuInterface.SingleMap_ScrollChange(Sender: TObject);
begin
  SingleMap_Top:=KMScrollBar_SingleMaps.Position;
  SingleMap_RefreshList();
end;


procedure TKMMainMenuInterface.SingleMap_SelectMap(Sender: TObject);
var i:integer;
begin           
  i:=TKMControl(Sender).Tag;

  KMShape_SingleMap.Top:=KMBevel_SingleBG[1,3].Top+KMBevel_SingleBG[i,3].Height*(i-1);

  SingleMap_Selected:=SingleMap_Top+i-1;
  KMLabel_SingleTitle.Caption:=SingleMapsInfo.GetTitle(SingleMap_Selected);
  KMLabel_SingleDesc.Caption:=SingleMapsInfo.GetBigDesc(SingleMap_Selected);

  KMLabel_SingleCondTyp.Caption:='Mission type: '+SingleMapsInfo.GetTyp(SingleMap_Selected);
  KMLabel_SingleCondWin.Caption:='Win condition: '+SingleMapsInfo.GetWin(SingleMap_Selected);
  KMLabel_SingleCondDef.Caption:='Defeat condition: '+SingleMapsInfo.GetDefeat(SingleMap_Selected);
end;


procedure TKMMainMenuInterface.SingleMap_Start(Sender: TObject);
var MissionPath:string;
begin
  fLog.AssertToLog(Sender=KMButton_SingleStart,'not KMButton_SingleStart');
  if not InRange(SingleMap_Selected, 1, SingleMapsInfo.GetMapCount) then exit;
  MissionPath := ExeDir+'Maps\'+SingleMapsInfo.GetFolder(SingleMap_Selected)+'\'+SingleMapsInfo.GetMissionFile(SingleMap_Selected);
  fGame.StartGame(MissionPath,SingleMapsInfo.GetTitle(SingleMap_Selected)); //Provide mission filename and title here
end;


procedure TKMMainMenuInterface.Load_Click(Sender: TObject);
begin
  KMLabel_LoadResult.Caption:=fGame.Load(TKMControl(Sender).Tag);
end;


procedure TKMMainMenuInterface.MapEditor_Start(Sender: TObject);
begin
  fLog.AssertToLog(Sender = Button_MapEd_Start,'not Button_MapEd_Start');
  fGame.StartMapEditor('', MapEdSizeX, MapEdSizeY); //Provide mission filename here, Mapsize will be ignored if map exists
end;


procedure TKMMainMenuInterface.Options_Change(Sender: TObject);
var i:integer;
begin
  if Sender = Ratio_Options_Mouse then fGame.fGameSettings.SetMouseSpeed(Ratio_Options_Mouse.Position);
  if Sender = Ratio_Options_SFX   then fGame.fGameSettings.SetSoundFXVolume(Ratio_Options_SFX.Position);
  if Sender = Ratio_Options_Music then fGame.fGameSettings.SetMusicVolume(Ratio_Options_Music.Position);
  if Sender = Button_Options_MusicOn then fGame.fGameSettings.IsMusic := not fGame.fGameSettings.IsMusic;

  if fGame.fGameSettings.IsMusic then Button_Options_MusicOn.Caption:=fTextLibrary.GetTextString(201)
                                 else Button_Options_MusicOn.Caption:=fTextLibrary.GetTextString(199);

  for i:=1 to LocalesCount do
    if Sender = CheckBox_Options_Lang[i] then begin
      fGame.fGameSettings.SetLocale := Locales[i,1];
      ShowScreen_Loading('Loading new locale');
      fRender.Render; //Force to repaint loading screen
      fGame.ToggleLocale;
      exit;
    end;

  for i:=1 to LocalesCount do
    CheckBox_Options_Lang[i].Checked := LowerCase(fGame.fGameSettings.GetLocale) = LowerCase(Locales[i,1]);

  //@Krom: Yes, I think it should be a proper control in a KaM style. Just text [x] doesn't look great.
  //       Some kind of box with an outline, darkened background and shadow maybe, similar to other controls.

  if Sender = KMButton_Options_ResApply then begin //Apply resolution changes
    OldFullScreen := fGame.fGameSettings.IsFullScreen; //memorize just in case (it will be niled on re-init anyway)
    OldResolution := fGame.fGameSettings.GetResolutionID;
    fGame.ToggleFullScreen(fGame.fGameSettings.IsFullScreen,true);
    exit;
  end;

  if Sender = CheckBox_Options_FullScreen then
    fGame.fGameSettings.IsFullScreen := not fGame.fGameSettings.IsFullScreen;

  for i:=1 to RESOLUTION_COUNT do
    if Sender = CheckBox_Options_Resolution[i] then
      fGame.fGameSettings.SetResolutionID := i;

  CheckBox_Options_FullScreen.Checked := fGame.fGameSettings.IsFullScreen;
  for i:=1 to RESOLUTION_COUNT do begin
    CheckBox_Options_Resolution[i].Checked := (i = fGame.fGameSettings.GetResolutionID);
    CheckBox_Options_Resolution[i].Enabled := (SupportedRefreshRates[i] > 0) AND fGame.fGameSettings.IsFullScreen;
  end;

  //Make button enabled only if new resolution/mode differs from old
  KMButton_Options_ResApply.Enabled := (OldFullScreen <> fGame.fGameSettings.IsFullScreen) or (OldResolution <> fGame.fGameSettings.GetResolutionID);

end;


procedure TKMMainMenuInterface.MapEd_Change(Sender: TObject);
var i:integer;
begin
  //Find out new map dimensions
  for i:=1 to MAPSIZE_COUNT do
  begin
    if Sender = CheckBox_MapEd_SizeX[i] then MapEdSizeX := MapSize[i];
    if Sender = CheckBox_MapEd_SizeY[i] then MapEdSizeY := MapSize[i];
  end;
  //Put checkmarks
  for i:=1 to MAPSIZE_COUNT do
  begin
    CheckBox_MapEd_SizeX[i].Checked := MapEdSizeX = MapSize[i];
    CheckBox_MapEd_SizeY[i].Checked := MapEdSizeY = MapSize[i];
  end;
end;



{Should update anything we want to be updated, obviously}
procedure TKMMainMenuInterface.UpdateState;
begin
  //
end;


procedure TKMMainMenuInterface.Paint;
begin
  MyControls.Paint;
end;



end.
