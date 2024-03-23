import SwiftUI
import NotPokerApi





struct GameContainerView : View
{
	//	gr: needs to be binding?
	//@Binding var gameServer : GameServerWrapper
	@StateObject var gameServer : GameServerWrapper

	
	func WaitingForGameView() -> some View
	{
		Label("Waiting for game...", systemImage: "suit.heart.fill")
	}
	
	
	var body: some View
	{
		switch gameServer.Client_LastStateJson.gameType
		{
		case nil:
			WaitingForGameView()
			
		case "Minesweeper":
			MinesweeperGameView( state: $gameServer.Client_LastStateJson )
			
		default:
			DebugGameView( state: $gameServer.Client_LastStateJson )
		}
	}
}

/*
struct BindingViewExample_2_Previews : PreviewProvider
{
	@State static var game : GameServer? = GameServer_Null()

	static var previews: some View
	{
		GameContainerView(gameServer: $game)
			.frame(width: 200,height: 100)
	}
}
*/

