import SwiftUI
import NotPokerApi



//	we can't have a nullable GameServer as a @StateObject, but we may want to swap it, or allocate late
//	so we wrap it
public class GameServerWrapper : ObservableObject
{
	public var				gameServer : GameServer? = nil
	@Published public var	startupState : String = "init"

	init()
	{
		
	}
	
	@MainActor // as we change published variables, we need to run on the main thread
	public func Connect(player: PlayerUid,serverType:GameServer.Type) async
	{
		do
		{
			startupState = "Allocating game..."
			let newGame = try NotPokerApi.GameServer_Offline(gameType: "Minesweeper")
			startupState = "Joining game..."
			try await newGame.Join(Player: player)
			startupState = "Joined"
			self.gameServer = newGame
			startupState = "Started game"
		}
		catch
		{
			//	show startup error
			startupState = "Error starting game: \(error.localizedDescription)"
		}
	}
}



struct AppView: View
{
	@State var playerUid : PlayerUid?// = PlayerUid("xx")
	@StateObject var server = GameServerWrapper()
	
	func ConnectToOfflineServer()
	{
		Task()
		{
			await server.Connect(player: playerUid!, serverType: GameServer_Offline.self)
		}
	}
	
	var body: some View
	{
		VStack()
		{
			//JavascriptSourceView(filename:"Games/Minesweeper.js")
			JavascriptSourceView(filename:"Test_ImportedDefaultIsWrongExport.js")
			

			LoginView(playerUid: $playerUid)
				.frame(maxWidth: .infinity, idealHeight: 40)

			//	need to pick a server
			if ( playerUid != nil && server.gameServer == nil )
			{
				Button(action:ConnectToOfflineServer)
				{
					Label("Connect to offline server", systemImage:"network.slash")
						.padding(20)
				}
			}
			
			Label("State: \(server.startupState)", systemImage: "suit.club.fill")
				.padding(20)

			if ( server.gameServer != nil )
			{
				GameContainerView( gameServer: $server.gameServer )
					.padding(20)
					.frame(maxWidth: .infinity, maxHeight: .infinity)
					.background( Color("GameBackground") )
					.foregroundColor(Color("GameForeground"))
					.cornerRadius(12)
					.padding(20)
			}
			else
			{
				//	show some splash screen
			}
		}
		.frame(alignment: .top)
	}
}




#Preview 
{
	//ContentView( player: PlayerUid("PreviewPlayer") )
	AppView()
		.frame(minWidth: 200, maxWidth:400,minHeight:300)
}

