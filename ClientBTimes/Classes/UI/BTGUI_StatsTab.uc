class BTGUI_StatsTab extends BTGUI_TabBase;

var automated GUIImage Region;

var automated GUIScrollTextBox Summary;
var private string SummaryText;

var() editinline protected BTClient_ClientReplication CRI;

const RegionHeight = 128;
const IconSize = 64;

var editconst protected int CurPos;

var() texture RegionImage;

event Free()
{
    CRI = none;
    super.Free();
}

function PostInitPanel()
{
    CRI = class'BTClient_ClientReplication'.static.GetRep( PlayerOwner() );
}

function InitComponent( GUIController InController, GUIComponent InOwner )
{
    super.InitComponent( InController, InOwner );
    Summary.MyScrollText.NewText = SummaryText;
    Summary.MyScrollBar.AlignThumb();
    Summary.MyScrollBar.UpdateGripPosition( 0 );
}

function ShowPanel( bool bShow )
{
    if( CRI == none )
        CRI = class'BTClient_ClientReplication'.static.GetRep( PlayerOwner() );

    if( CRI == none )
    {
        Log( "ShowPanel, CRI not found!" );
    }
    super.ShowPanel( bShow );
}

function bool InternalOnDraw( Canvas C )
{
    return false;
}

defaultproperties
{
    RegionImage=Material'InterfaceContent.Menu.EditBox'

    Begin Object Class=GUIScrollTextBox Name=oSummary
        bBoundToParent=False
        bScaleToParent=False
        WinWidth=1.0
        WinHeight=0.06
        WinLeft=0.0
        WinTop=0.0
        StyleName="NoBackground"
        bNoTeletype=true
        bNeverFocus=true
    End Object
    Summary=oSummary

    Begin Object class=GUIImage name=oRegion
        bScaleToParent=True
        bBoundToParent=True
        WinWidth=1.0
        WinHeight=0.84
        WinLeft=0.0
        WinTop=0.06
        Image=None
        ImageColor=(R=255,G=255,B=255,A=128)
        ImageRenderStyle=MSTY_Alpha
        ImageStyle=ISTY_Stretched
        OnDraw=InternalOnDraw
    End Object
    Region=oRegion
}
