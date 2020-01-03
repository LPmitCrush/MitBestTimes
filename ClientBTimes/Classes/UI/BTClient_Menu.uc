//==============================================================================
// BTClient_Menu.uc (C) 2005-2019 Eliot and .:..:. All Rights Reserved
//==============================================================================
class BTClient_Menu extends MidGamePanel
    config(ClientBTimes);

var automated GUITabControl c_Tabs;

struct sBTTab
{
    var() string Caption;
    var() class<BTGUI_TabBase> TabClass;
    var() string Hint;
    var() GUIStyles Style;
};

var protected array<sBTTab> BTTabs;

event Free()
{
    local int i;

    for( i = 0; i < BTTabs.Length; ++ i )
    {
        BTTabs[i].Style = none;
    }
    super.Free();
}

function InternalOnChange( GUIComponent sender );

function PostInitPanel()
{
    local int i;
    local BTGUI_TabBase tab;

    for( i = 0; i < BTTabs.Length; ++ i )
    {
        tab = BTGUI_TabBase(c_Tabs.AddTab( BTTabs[i].Caption, string(BTTabs[i].TabClass),, BTTabs[i].Hint, true ));
        tab.PostInitPanel();
    }
}

defaultproperties
{
    WinWidth=0.600000
    WinHeight=1.000000
    WinLeft=0.100000
    WinTop=0.100000

    BTTabs(0)=(Caption="Settings",TabClass=class'BTGUI_Settings',Hint="Edit your BestTimes settings!")
    BTTabs(1)=(Caption="Trophies",TabClass=class'BTGUI_Trophies',Hint="Claim your trophies!")
    BTTabs(2)=(Caption="Achievements",TabClass=class'BTGUI_Achievements',Hint="View your achievements!")
    BTTabs(3)=(Caption="Inventory",TabClass=class'BTGUI_PlayerInventory',Hint="Manage your items")

    Begin Object class=GUITabControl name=oPageTabs
        WinWidth=0.98
        WinLeft=0.01
        WinTop=0.01
        WinHeight=0.05
        TabHeight=0.04
        bFillBackground=true
        bFillSpace=false
        bAcceptsInput=true
        bDockPanels=true
        OnChange=InternalOnChange
        BackgroundStyleName="TabBackground"
        BackgroundImage=FinalBlend'AW-2004Particles.Energy.BeamHitFinal'
    End Object
    c_Tabs=oPageTabs
}
