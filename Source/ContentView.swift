import SwiftUI
import NotPokerApi



struct AppView: View
{
	var body: some View
	{
		ContentView( player: PlayerUid("App player") )
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.background( Color("AppBackground") )
			.foregroundColor(Color("AppForeground"))
	}
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
	public func Load(player: PlayerUid) async throws
	{
		do
		{
			let newGame = GameServer_Offline()
			try await newGame.Join(Player: player)
			self.gameServer = newGame
		}
		catch
		{
			//	show startup error
			startupError = error.localizedDescription
		}
	}
}



struct ContentView: View
{
	public var player : PlayerUid
	@StateObject var gameServer = GameServerWrapper()
	var startupError : String?
	{
		return gameServer.startupError
	}

	func InitGame()
	{
		Task()
		{
			try await gameServer.Load(player: player)
		}
	}
	
	var body: some View
	{
		EmptyView()
			.onAppear()
			{
				InitGame()
			}

		VStack()
		{
			if startupError != nil
			{
				Label("Startup error \(startupError!)", systemImage: "exclamationmark.triangle.fill")
			}
			
			if let game = gameServer as? NotPokerApi.GameServer
			{
				GameContainerView(gameServer: game)
			}
			else
			{
				Label("Connecting to game...", systemImage: "suit.spade")
			}
		}
	}
}

#Preview 
{
	//ContentView( player: PlayerUid("PreviewPlayer") )
	AppView()
}

