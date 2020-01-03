class BTGUI_Account extends BTGUI_TabBase;

var automated GUIButton b_TradeCurrency;
var automated GUIEditBox eb_TradePlayer, eb_TradeAmount;

function bool InternalOnClick( GUIComponent sender )
{
    PlayerOwner().ConsoleCommand( "CloseDialog" );
    if( sender == b_TradeCurrency )
    {
        if( eb_TradePlayer.GetText() == "" )
        {
            PlayerOwner().ClientMessage( "Please specifiy a player's name!" );
            return false;
        }

        if( eb_TradeAmount.GetText() == "" )
        {
            PlayerOwner().ClientMessage( "Please enter amount of money that you want to give!" );
            return false;
        }

        if( int(eb_TradeAmount.GetText()) <= 0 )
        {
            PlayerOwner().ClientMessage( "Please send more than 0$!" );
            return false;
        }

        PlayerOwner().ConsoleCommand( "TradeMoney" @ eb_TradePlayer.GetText() @ int(eb_TradeAmount.GetText()) );
        return true;
    }
    return false;
}

defaultproperties
{
    Begin Object class=GUIButton name=oTradeCurrency
        Caption="Trade Money"
        WinTop=0.01
        WinLeft=0.0
        WinWidth=0.25
        WinHeight=0.05
        OnClick=InternalOnClick
        Hint="Trade currency with the specified player."
    End Object
    b_TradeCurrency=oTradeCurrency

    Begin Object class=GUIEditBox name=oTradePlayer
        bScaleToParent=True
        bBoundToParent=True
        WinTop=0.01
        WinLeft=0.26
        WinWidth=0.25
        WinHeight=0.05
        Hint="Player Name"
    End Object
    eb_TradePlayer=oTradePlayer

    Begin Object class=GUIEditBox name=oTradeAmount
        bScaleToParent=True
        bBoundToParent=True
        WinTop=0.01
        WinLeft=0.52
        WinWidth=0.25
        WinHeight=0.05
        Hint="Money (20% of this will be used as fee!)"
    End Object
    eb_TradeAmount=oTradeAmount
}