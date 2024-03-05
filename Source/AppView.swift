import SwiftUI
import NotPokerApi

public struct ServerState /*: Decodable*/
{
	public var error : String?
}


//	we can't have a nullable GameServer as a @StateObject, but we may want to swap it, or allocate late
//	so we wrap it
public class GameServerWrapper : ObservableObject
{
	public var				gameServer : GameServer? = nil
	@Published public var	startupError : String? = nil

	init()
	{
		
	}
	
	@MainActor // as we change published variables, we need to run on the main thread
	public func Load(player: PlayerUid) async
	{
		do
		{
			let newGame = try GameServer_Offline()
			try await newGame.Join(Player: player)
			self.gameServer = newGame
			startupError = nil
		}
		catch
		{
			//	show startup error
			print("Error starting game: \(error.localizedDescription)")
			startupError = error.localizedDescription
		}
	}
}



class ServerWrapper : ObservableObject
{
	public var				server : GameServer? = nil
	@Published public var	state = ServerState()
	public var				error : String?
	{
		return state.error
	}
	
	@MainActor // as we change published variables, we need to run on the main thread
	public func Connect(player: PlayerUid,serverType:GameServer.Type) async
	{
		do
		{
			await Task.sleep(milliseconds: 300)
			server = try GameServer_Offline()
			try await server?.Join(Player: player)
			state.error = nil
		}
		catch
		{
			state.error = error.localizedDescription
		}
	}
}

struct AppView: View
{
	@State var playerUid : PlayerUid?// = PlayerUid("xx")
	@StateObject var server = ServerWrapper()
	
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

			LoginView(playerUid: $playerUid)
				.frame(maxWidth: .infinity, idealHeight: 40)

			//	need to pick a server
			if ( playerUid != nil && server.server == nil )
			{
				Button(action:ConnectToOfflineServer)
				{
					Label("Connect to offline server", systemImage:"network.slash")
				}
			}
			
			if ( server.server != nil )
			{
				GameContainerView( gameServer: $server.server )
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

