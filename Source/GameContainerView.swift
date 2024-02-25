import SwiftUI
import NotPokerApi




struct GameContainerView : View
{
	var gameServer : NotPokerApi.GameServer
	
	var body: some View
	{
		Label("Game server state", systemImage: "suit.club.fill")
	}
}

#Preview 
{
	return GameContainerView( gameServer: GameServer_Null() )
}

