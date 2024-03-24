import SwiftUI
import NotPokerApi




public struct ClientGameState
{
	var StateJson : String?
	var OnUserClickedActionCallback : (_ ActionReply:ActionReply) throws -> Void

	public func OnUserClickedAction(_ ActionReply:ActionReply) throws
	{
		try OnUserClickedActionCallback( ActionReply )
	}

	init()
	{
		StateJson = nil
		OnUserClickedActionCallback = ClientGameState.DefaultOnUserClickedAction
	}
	
	init(_ json:String, ActionReplyCallback:@escaping (_ ActionReply:ActionReply) throws -> Void)
	{
		StateJson = json
		OnUserClickedActionCallback = ActionReplyCallback
	}
	
	static func DefaultOnUserClickedAction(ActionReply:ActionReply) throws
	{
		let ReplyJsonBytes = try! JSONEncoder().encode(ActionReply)
		let ReplyJson = String(data: ReplyJsonBytes, encoding: .utf8)!
		print("todo: reply action; \(ReplyJson) ")
		throw RuntimeError("todo: handle a throw from the action flow")
	}
	
	
	public var gameType : String?
	{
		let State = GetClientState()
		return State.GameType
	}
	
	func GetState<StateType:GameStateType>() -> StateType
	{
		if ( StateJson == nil )
		{
			return StateType()
		}
		do
		{
			let Client_LastStateJsonData = StateJson!.data(using: .utf8)!
			let State = try JSONDecoder().decode( StateType.self, from: Client_LastStateJsonData )
			return State
		}
		catch
		{
			return StateType(Error:error.localizedDescription)
		}
	}
	
	func GetClientState() -> GameStateBase
	{
		let state : GameStateBase = try GetState()	//	need var with type to infer generic param
		return state
	}

	public var actions : [String: ActionMeta]
	{
		let State = GetClientState()
		if let actions = State.Actions
		{
			return actions.Actions
		}
		return [:]
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
	
	
	//	gr: _maybe_ this should be async
	func SendActionReply(ActionReply:ActionReply) throws
	{
		try gameServer!.SendActionReply( ActionReply )
	}

	@MainActor	//	changes published variable, so must run on main thread
	func RunClientGame() async throws
	{
		while ( true )
		{
			//	we keep getting states, and we dont really want to overwrite the old one until the UI has finished
			//	but that might be hard to control the UI, or wait for a semaphore...
			//	and the game is setup as STATE, so we can just override it, and the UI just moves along when it wants to
			let NewStateJson = try await gameServer!.WaitForNextState()
			let NewState = ClientGameState( NewStateJson, ActionReplyCallback: SendActionReply )
			
			//print("New client state json; gameType = \(NewState.gameType)")
			
			//	gr: temp fix
			if ( NewState.gameType != nil )
			{
				Client_LastStateJson = NewState
				print("New client state json; gameType = \(NewState.gameType)")
			}
			else
			{
				let State = NewState.GetClientState()
				if ( State.Error != nil )
				{
					throw RuntimeError(State.Error!)
				}
				throw RuntimeError("Need all states to have .GameType now \(NewState)")
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
	
	func GameStateView() -> some View
	{
		VStack()
		{
			
			//	need to pick a server/setup a game
			if ( playerUid != nil && server.gameServer == nil )
			{
				Button(action:ConnectToOfflineServer)
				{
					Label("Connect to offline server", systemImage:"network.slash")
						.padding(10)
						.frame(maxWidth: .infinity)
						//.background(Color.red)	//	show clickable area
				}
				.frame(maxWidth: .infinity, idealHeight: 30)
				.padding(10)
				.background( Color("ServerBrowserBackground") )
				.foregroundColor(Color("ServerBrowserForeground"))
				.cornerRadius(12)
				.padding(10)
			}
		
			let GameStateIcon = (server.gameServer==nil) ? "suit.club" : "suit.club.fill"
			Label("State: \(server.startupState)", systemImage:GameStateIcon)
				.padding(10)
			
			if ( server.gameServer != nil )
			{
				GameContainerView( gameServer: server )
					.padding(10)
					.frame(maxWidth: .infinity, maxHeight: .infinity)
					.background( Color("GameBackground") )
					.foregroundColor(Color("GameForeground"))
					.cornerRadius(12)
					.padding(10)
			}
			else
			{
				//	show some splash screen
			}
		}
	}
	
	
	var body: some View
	{
		VStack()
		{
			//JavascriptSourceView(filename:"Games/Minesweeper.js")
			//JavascriptSourceView(filename:"Test_ImportedDefaultIsWrongExport.js")

			LoginView(playerUid: $playerUid)
				.frame(maxWidth: .infinity, idealHeight: 30)
				.padding(10)
				.background( Color("LoginBackground") )
				.foregroundColor(Color("LoginForeground"))
				.cornerRadius(12)
				.padding(10)

			GameStateView()

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

