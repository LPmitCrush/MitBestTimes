//==============================================================================
// Coded by Eliot aka Eliot van uytfanghe.
// Copyright (C) 2007-2008.
//==============================================================================
class BTClient_MapVotingPage extends MapVotingPage;

var automated GUIButton b_Random;
var automated GUIEditBox MapNameFilter;
var automated GUILabel FilterLabel;
var automated BTClient_MapPanel MapPanel;

var automated GUILabel GameTypeFilter;
var automated BTGUI_ComboBox ComboGameType;

// Removed i_FrameBG access
function InitComponent( GUIController MyController, GUIComponent MyOwner )
{
    super(PopupPageBase).InitComponent( MyController, MyOwner );
    t_WindowTitle.SetCaption(WindowName);
    if ( bMoveAllowed )
    {
        t_WindowTitle.bAcceptsInput = true;
        t_WindowTitle.MouseCursorIndex = HeaderMouseCursorIndex;
    }
    AddSystemMenu();

    MVRI = VotingReplicationInfo(PlayerOwner().VoteReplicationInfo);
    // Turn pause off if currently paused (stops replication)
    if(PlayerOwner() != None && PlayerOwner().Level.Pauser != None)
        PlayerOwner().SetPause(false);
}

// Removed i_FrameBG access
function bool AlignFrame(Canvas C)
{
    return bInit;
}

function AddSystemMenu()
{
    b_ExitButton = GUIButton(t_WindowTitle.AddComponent( "XInterface.GUIButton" ));
    b_ExitButton.Style = Controller.GetStyle( "BTCloseButton", t_WindowTitle.FontScale );
    b_ExitButton.OnClick = XButtonClicked;
    b_ExitButton.bNeverFocus=true;
    b_ExitButton.FocusInstead = t_WindowTitle;
    b_ExitButton.RenderWeight=1.0;
    b_ExitButton.bScaleToParent=false;
    b_ExitButton.bAutoShrink=false;
    b_ExitButton.OnPreDraw = SystemMenuPreDraw;
    b_ExitButton.Caption = "X";

    // Do not want OnClick() called from MousePressed()
    b_ExitButton.bRepeatClick = False;
}

function bool SystemMenuPreDraw(canvas Canvas)
{
    BackgroundColor = class'BTClient_Config'.static.FindSavedData().CTable;
    b_ExitButton.SetPosition( t_WindowTitle.ActualLeft() + t_WindowTitle.ActualWidth() - b_ExitButton.ActualWidth(), t_WindowTitle.ActualTop(), t_WindowTitle.ActualHeight(), t_WindowTitle.ActualHeight(), true);
    return true;
}

// Ugly ugly ugly...
function bool InternalOnPanelBackgroundDraw( Canvas C )
{
    C.SetPos( MapPanel.ActualLeft(), MapPanel.ActualTop() );
    C.DrawColor = class'BTClient_Config'.static.FindSavedData().CTable;
    C.DrawTile( Texture'BTScoreBoardBG', MapPanel.ActualWidth(), MapPanel.ActualHeight(), 0, 0, 256, 256 );
    return false;
}

function InternalOnReceiveMapInfo( VotingHandler.MapVoteMapList mapInfo )
{
    local int l;

    if( BTClient_MapVoteMultiColumnList(lb_MapListBox.List).IsFiltered( MVRI, ComboGameType.GetIndex(), mapInfo.MapName ) )
        return;

    l = BTClient_MapVoteMultiColumnList(lb_MapListBox.List).MapVoteData.Length;
    BTClient_MapVoteMultiColumnList(lb_MapListBox.List).MapVoteData.Insert(l,1);
    BTClient_MapVoteMultiColumnList(lb_MapListBox.List).MapVoteData[l] = MVRI.MapList.Length - 1;
    BTClient_MapVoteMultiColumnList(lb_MapListBox.List).AddedItem();
}

// >> Ugly copy from MapVotingPage, necessary to add a few specific modifications to it!.
function InternalOnOpen()
{
    local int i, d;

    if( MVRI == none || (MVRI != none && !MVRI.bMapVote) )
    {
        Controller.OpenMenu("GUI2K4.GUI2K4QuestionPage");
        GUIQuestionPage(Controller.TopPage()).SetupQuestion(lmsgMapVotingDisabled, QBTN_Ok, QBTN_Ok);
        GUIQuestionPage(Controller.TopPage()).OnButtonClick = OnOkButtonClick;
        return;
    }

    if( MVRI.GameConfig.Length < MVRI.GameConfigCount )
    {
        Controller.OpenMenu("GUI2K4.GUI2K4QuestionPage");
        GUIQuestionPage( Controller.TopPage() ).SetupQuestion( lmsgReplicationNotFinished, QBTN_Ok, QBTN_Ok );
        GUIQuestionPage( Controller.TopPage() ).OnButtonClick = OnOkButtonClick;
        return;
    }

    MapPanel.OnDraw = InternalOnPanelBackgroundDraw;
    BTClient_VRI(MVRI).OnReceiveMapInfo = InternalOnReceiveMapInfo;

    for( i=0; i<MVRI.GameConfig.Length; i++ )
        ComboGameType.AddItem( MVRI.GameConfig[i].GameName, none, string(i));
    ComboGameType.List.SortList();

    // set starting gametype to current
    d = ComboGameType.List.FindExtra(string(MVRI.CurrentGameConfig));
    if( d > -1 )
        ComboGameType.SetIndex(d);

    t_WindowTitle.Caption = t_WindowTitle.Caption@"("$lmsgMode[MVRI.Mode]$")";

    lb_MapListBox.LoadList(MVRI);
    MapVoteCountMultiColumnList(lb_VoteCountListBox.List).LoadList(MVRI);

    lb_VoteCountListBox.List.OnDblClick = MapListDblClick;
    lb_VoteCountListBox.List.bDropTarget = True;

    lb_MapListBox.List.OnDblClick = MapListDblClick;
    lb_MaplistBox.List.bDropSource = True;
    lb_MaplistBox.List.OnChange = MapSelectionChanged;
    ComboGameType.OnChange = GameTypeChanged;
    // f_Chat.OnSubmit = Submit;

    // lb_MaplistBox.MyScrollBar.MyIncreaseButton.Style = Controller.GetStyle("BTButton", lb_MaplistBox.MyScrollBar.MyIncreaseButton.FontScale);
    // lb_MaplistBox.MyScrollBar.MyDecreaseButton.Style = Controller.GetStyle("BTButton", lb_MaplistBox.MyScrollBar.MyDecreaseButton.FontScale);
    // lb_MaplistBox.MyScrollBar.MyGripButton.Style = Controller.GetStyle("BTButton", lb_MaplistBox.MyScrollBar.MyGripButton.FontScale);
    // lb_MaplistBox.MyScrollBar.MyScrollZone.Style = Controller.GetStyle("BTButton", lb_MaplistBox.MyScrollBar.MyScrollZone.FontScale);
}

function GameTypeChanged(GUIComponent Sender)
{
    local int GameTypeIndex;

    GameTypeIndex = int(ComboGameType.GetExtra());
    if( GameTypeIndex > -1 )
    {
        lb_MapListBox.ChangeGameType( GameTypeIndex );
        lb_MapListBox.List.OnDblClick = MapListDblClick;
        MapNameFilter.SetText( "" );
    }
}

function bool RandomClicked( GUIComponent sender )
{
    local int GameConfigIndex;
    local int randomMapIndex;
    local int generationAttempts;
    local BTClient_MapVoteMultiColumnList list;

    list = BTClient_MapVoteMultiColumnList(lb_MaplistBox.List);

    rng:
    randomMapIndex = Rand( list.MapVoteData.Length );
    if( !MVRI.MapList[list.MapVoteData[randomMapIndex]].bEnabled && !PlayerOwner().PlayerReplicationInfo.bAdmin )
    {
        if( generationAttempts >= 100 )
        {
            PlayerOwner().ClientMessage(lmsgMapDisabled);
            return false;
        }

        ++ generationAttempts;
        goto rng;
    }

    GameConfigIndex = int(ComboGameType.GetExtra());
    if( GameConfigIndex > -1 )
    {
        MVRI.SendMapVote( list.MapVoteData[randomMapIndex], GameConfigIndex );
    }
    return true;
}

function InternalOnFilterChange( GUIComponent sender )
{
    local string filter;

    filter = MapNameFilter.GetText();
    BTClient_MapVoteMultiColumnList(lb_MaplistBox.List).OnFilterVotingList( sender, filter, int(ComboGameType.GetExtra()) );
}

function MapSelectionChanged( GUIComponent sender )
{
    MapPanel.OnMapSelected( sender, BTClient_MapVoteMultiColumnList(lb_MapListBox.List).GetSelectedMapName() );
}

function bool AlignBK(Canvas C)
{
    return false;
}

// Fix co_Gametype -> ComboGameType
function SendVote(GUIComponent Sender)
{
    local int MapIndex,GameConfigIndex;

    if( Sender == lb_VoteCountListBox.List )
    {
        MapIndex = MapVoteCountMultiColumnList(lb_VoteCountListBox.List).GetSelectedMapIndex();
        if( MapIndex > -1)
        {
            GameConfigIndex = MapVoteCountMultiColumnList(lb_VoteCountListBox.List).GetSelectedGameConfigIndex();
            if(MVRI.MapList[MapIndex].bEnabled || PlayerOwner().PlayerReplicationInfo.bAdmin)
                MVRI.SendMapVote(MapIndex,GameConfigIndex);
            else
                PlayerOwner().ClientMessage(lmsgMapDisabled);
        }
    }
    else
    {
        MapIndex = MapVoteMultiColumnList(lb_MapListBox.List).GetSelectedMapIndex();
        if( MapIndex > -1)
        {
            GameConfigIndex = int(ComboGameType.GetExtra());
            if(MVRI.MapList[MapIndex].bEnabled || PlayerOwner().PlayerReplicationInfo.bAdmin)
                MVRI.SendMapVote(MapIndex,GameConfigIndex);
            else
                PlayerOwner().ClientMessage(lmsgMapDisabled);
        }
    }
}

defaultproperties
{
    i_FrameBG=none
    Background=Texture'BTScoreBoardBG'
    BackgroundRStyle=MSTY_Normal

    WinLeft=0.1
    WinTop=0.1
    WinWidth=0.8
    WinHeight=0.8

    Begin Object Class=BTClient_MapVoteMultiColumnListBox Name=MapListBox
        WinWidth=0.99000
        WinHeight=0.624000
        WinLeft=0.0050000
        WinTop=0.060000
        bVisibleWhenEmpty=true
        bScaleToParent=True
        bBoundToParent=True
        FontScale=FNS_Small
        begin object class=BTClient_MultiColumnListHeader name=oHeader
            // BarStyleName=""
        end object
        Header=oHeader
    End Object
    lb_MapListBox=MapListBox

    begin object class=BTClient_MapPanel name=oMapInfo
        WinWidth=0.560000
        WinHeight=0.260500
        WinLeft=0.005000
        WinTop=0.730000
        bScaleToParent=True
        bBoundToParent=True
    end object
    MapPanel=oMapInfo

    Begin Object Class=BTClient_MapVoteCountMultiColumnListBox Name=VoteCountListBox
        WinWidth=0.425000
        WinHeight=0.260500
        WinLeft=0.570000
        WinTop=0.73
        bVisibleWhenEmpty=true
        bScaleToParent=True
        bBoundToParent=True
        FontScale=FNS_Small
        HeaderColumnPerc(0)=0.30
        HeaderColumnPerc(1)=0.55
        HeaderColumnPerc(2)=0.15
        begin object class=BTClient_MultiColumnListHeader name=oHeaderTwo
            // BarStyleName=""
        end object
        Header=oHeaderTwo
    End Object
    lb_VoteCountListBox=VoteCountListBox

    begin object class=GUILabel name=oFilterLabel
        WinTop=0.69
        WinHeight=0.035000
        WinWidth=0.07
        WinLeft=0.005
        bScaleToParent=True
        bBoundToParent=True
        Caption="Search"
        TextColor=(R=255,G=255,B=255,A=255)
        TextAlign=TXTA_Center
        bTransparent=false
        FontScale=FNS_Small
        StyleName="BTLabel"
    end object
    FilterLabel=oFilterLabel

    begin object class=GUIEditBox name=oMapNameFilter
        WinTop=0.69
        WinHeight=0.035000
        WinWidth=0.485
        WinLeft=0.080
        bScaleToParent=True
        bBoundToParent=True
        OnChange=InternalOnFilterChange
        StyleName="BTEditBox"
    end object
    MapNameFilter=oMapNameFilter

    begin object class=GUILabel name=oGameTypeFilter
        WinWidth=0.075
        WinHeight=0.035000
        WinLeft=0.57
        WinTop=0.69
        bScaleToParent=True
        bBoundToParent=True
        Caption="Mode"
        TextColor=(R=255,G=255,B=255,A=255)
        TextAlign=TXTA_Center
        bTransparent=false
        FontScale=FNS_Small
        StyleName="BTLabel"
    end object
    GameTypeFilter=oGameTypeFilter

    Begin Object class=BTGUI_ComboBox Name=GameTypeCombo
        WinWidth=0.245000
        WinHeight=0.035000
        WinLeft=0.650000
        WinTop=0.690000
        bScaleToParent=true
        bBoundToParent=true
        bIgnoreChangeWhenTyping=true
        bReadOnly=true
    End Object
    ComboGameType=GameTypeCombo
    co_Gametype=none

    Begin Object class=GUIButton Name=oRandomButton
        WinWidth=0.095000
        WinHeight=0.035000
        WinLeft=0.90000
        WinTop=0.690000
        Caption="Random"
        bScaleToParent=True
        bBoundToParent=true
        OnClick=RandomClicked
        StyleName="BTButton"
    End Object
    b_Random=oRandomButton

    // Begin Object Class=BTClient_MapVoteFooter Name=MatchSetupFooter
    //     WinWidth=0.530000
    //     WinHeight=0.251406
    //     WinLeft=0.450000
    //     WinTop=0.726457
    //     TabOrder=10
    //     RenderWeight=0.5
    //     bBoundToParent=True
    //     bScaleToParent=True
    // End Object
    f_Chat=none
    i_MapCountListBackground=none
    i_MapListBackground=none

    Begin Object Class=GUIHeader Name=TitleBar
        WinLeft=0.0
        WinWidth=1.0
        WinTop=0.0
        WinHeight=0.04
        RenderWeight=0.1
        FontScale=FNS_Large
        Justification=TXTA_Left
        TextIndent=4
        bUseTextHeight=false
        bAcceptsInput=True
        bNeverFocus=False
        bBoundToParent=true
        bScaleToParent=true
        OnMousePressed=FloatingMousePressed
        OnMouseRelease=FloatingMouseRelease
        ScalingType=SCALE_X
        StyleName="BTHeader"
    End Object
    t_WindowTitle=TitleBar
}
