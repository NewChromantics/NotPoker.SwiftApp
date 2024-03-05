import SwiftUI
import NotPokerApi




struct GameContainerView : View
{
	//	gr: needs to be binding?
	@Binding var gameServer : NotPokerApi.GameServer?
	
	var body: some View
	{
		Label("Game server state", systemImage: "suit.heart.fill")
	}
}


struct BindingViewExample_2_Previews : PreviewProvider
{
	@State static var game : GameServer? = GameServer_Null()

	static var previews: some View
	{
		GameContainerView(gameServer: $game)
	}
}

