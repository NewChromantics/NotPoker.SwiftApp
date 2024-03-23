import SwiftUI
import NotPokerApi


class ActionArgumentValue : Encodable, Decodable, Equatable, Identifiable, Hashable, CustomStringConvertible
{
	var ValueAsString : String

	static func == (lhs: ActionArgumentValue, rhs: ActionArgumentValue) -> Bool
	{
		lhs.ValueAsString == rhs.ValueAsString
	}
	
	func hash(into hasher: inout Hasher) 
	{
		hasher.combine(ValueAsString)
	}
	
	//	each value should be unique, so can use it as a key
	var id : ObjectIdentifier
	{
		return ObjectIdentifier(self)
	}
	
	public var description: String
	{
		return ValueAsString
	}

	init()
	{
		ValueAsString = ""
	}
		
	required init(from decoder: Decoder) throws
	{
		if let int = try? decoder.singleValueContainer().decode(Int.self) {
			ValueAsString = "\(int)"
			return
		}
		
		if let string = try? decoder.singleValueContainer().decode(String.self) {
			ValueAsString = string
			return
		}
		/*
		if let string = try? decoder.singleValueContainer().decode([Int].self) {
			self = .arrayOfInts(string)
			return
		}*/
		
		throw QuantumError.missingValue
	}
	
	enum QuantumError:Error 
	{
		case missingValue
	}
}

public struct ActionMeta : Decodable, CustomStringConvertible
{
	public var description: String
	{
		return "ActionMeta"
	}
	
	var Key : String?
	//var Arguments : [[Int]]	//	array of an array in minesweeper!
	var Arguments : [[ActionArgumentValue]]
	/*
	enum CodingKeys: String, CodingKey
	{
		case isAll = "is_all"
		case values, include
	}
	 */
}

//	https://stackoverflow.com/a/50257595/355753
//	json where we don't know the keys
//	Actions:{ Action1:{}, Action2:{}
public struct ActionList : Decodable
{
	public var Actions: [String: ActionMeta] = [:]
	

	struct ActionKey: CodingKey
	{
		var stringValue: String
		var intValue: Int?
		
		init?(stringValue: String)
		{
			self.stringValue = stringValue
		}

		init?(intValue: Int)
		{
			self.stringValue = "\(intValue)";
			self.intValue = intValue
		}
	}

	public init()
	{
	}
	
	//	manually decode object keys
	public init(from decoder: Decoder) throws
	{
		let container = try decoder.container(keyedBy: ActionKey.self)

		var actions = [String: ActionMeta]()
		
		for key in container.allKeys 
		{
			if let model = try? container.decode(ActionMeta.self, forKey: key)
			{
				actions[key.stringValue] = model
			}
			else if let bool = try? container.decode(Bool.self, forKey: key)
			{
				//self.any = any
			}
		}

		self.Actions = actions
	}
	
}


public struct ClientActionReply : Codable
{
	var Action: String
	var Arguments : [ActionArgumentValue] = []
}

struct GameStateBase : Decodable
{
	var GameType : String?
	var Error : String?
	var Actions = ActionList()
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


public struct ThrowingPobs
{
	var Callback : () throws -> Void
	
	public func CallTheCallback() throws
	{
		try! Callback()
	}
	
	init()
	{
		Callback = ThrowingPobs.DefaultCallback
	}
	
	
	static func DefaultCallback() throws
	{
		throw RuntimeError("default callback bad")
	}
}


public struct ClientGameState
{
	var StateJson : String?
	var OnUserClickedActionCallback : (_ ActionReply:ClientActionReply) throws -> Void

	public func OnUserClickedAction(_ ActionReply:ClientActionReply) throws
	{
		try OnUserClickedActionCallback( ActionReply )
	}

	init()
	{
		StateJson = nil
		OnUserClickedActionCallback = ClientGameState.DefaultOnUserClickedAction
	}
	
	init(_ json:String)
	{
		StateJson = json
		OnUserClickedActionCallback = ClientGameState.DefaultOnUserClickedAction
	}
	
	static func DefaultOnUserClickedAction(ActionReply:ClientActionReply) throws
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

	public var actions : [String: ActionMeta]
	{
		let State = GetClientState()
		return State.Actions.Actions
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

