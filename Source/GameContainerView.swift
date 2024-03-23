import SwiftUI
import NotPokerApi




struct GameContainerView : View
{
	//	gr: needs to be binding?
	//@Binding var gameServer : GameServerWrapper
	@StateObject var gameServer : GameServerWrapper

	
	var body: some View
	{
		if let game = gameServer.Client_LastStateJson.gameType
		{
			Label("Playing \(game)", systemImage: "suit.heart.fill")
		}
		else
		{
			Label("Waiting for game...", systemImage: "suit.heart.fill")
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

