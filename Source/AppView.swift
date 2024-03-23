import SwiftUI
import NotPokerApi




struct GameStateBase : Codable
{
	var GameType : String?
	var Error : String?
	//var Actions : []
	//var BadMode : String?
	
	init()
	{
		Error = nil
		GameType = nil
	}
	
	init(Error: String)
	{
		self.Error = Error
	}
}

public struct ClientGameState /*: ObservableObject*/
{
	/*@Published */var StateJson : String?

	init()
	{
		StateJson = nil
	}
	
	init(_ json:String)
	{
		StateJson = json
	}
	
	
	public var gameType : String?
	{
		let State = GetClientState()
		return State.GameType
	}
	
	func GetClientState() -> GameStateBase
	{
		if ( StateJson == nil )
		{
			return GameStateBase()
		}
		do
		{
			let Client_LastStateJsonData = StateJson!.data(using: .utf8)!
			let State = try JSONDecoder().decode( GameStateBase.self, from: Client_LastStateJsonData )
			return State
		}
		catch
		{
			return GameStateBase(Error:error.localizedDescription)
		}
	}

}


//	we can't have a nullable GameServer as a @StateObject, but we may want to swap it, or allocate late
//	so we wrap it
public class GameServerWrapper : ObservableObject
{
	public var				gameServer : GameServer? = nil
	
	//	client stuff
	@Published public var	startupState : String = "init"
	@Published public var	Client_LastStateJson = ClientGameState()
	
	init()
	{
		
	}
	

	@MainActor	//	changes published variable, so must run on main thread
	func RunClientGame() async throws
	{
		while ( true )
		{
			//	we keep getting states, and we dont really want to overwrite the old one until the UI has finished
			//	but that might be hard to control the UI, or wait for a semaphore...
			//	and the game is setup as STATE, so we can just override it, and the UI just moves along when it wants to
			let NewStateJson = try! await gameServer!.WaitForNextState()
			let NewState = ClientGameState(NewStateJson)
			
			//print("New client state json; gameType = \(NewState.gameType)")
			
			//	gr: temp fix
			if ( NewState.gameType != nil )
			{
				Client_LastStateJson = NewState
				print("New client state json; gameType = \(NewState.gameType)")
			}

			//	if game finished, break
		}
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
			
			
			//	run the game...
			//	gr: this may not really want to be in here (connect), but then... why not!
			try await RunClientGame()
			
			startupState = "Game Finished"
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
			//JavascriptSourceView(filename:"Test_ImportedDefaultIsWrongExport.js")
			

			LoginView(playerUid: $playerUid)
				.frame(maxWidth: .infinity, idealHeight: 40)

			//	need to pick a server/setup a game
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
				GameContainerView( gameServer: server )
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

