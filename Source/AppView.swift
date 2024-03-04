import SwiftUI
import NotPokerApi



struct AppView: View
{
	var body: some View
	{
		//JavascriptSourceView(filename:"Games/Minesweeper.js")
		
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
			await gameServer.Load(player: player)
		}
	}
	
	var body: some View
	{
		if startupError != nil
		{
			Label("Startup error \(startupError!)", systemImage: "exclamationmark.triangle.fill")
				.padding(8)	//	inner padding
				.background(Color("ErrorBackground"))
				.foregroundColor(Color("ErrorForeground"))
				.cornerRadius(4)
				.padding(4)	//	outer padding
		}
		

		VStack()
		{
			if let game = gameServer as? NotPokerApi.GameServer
			{
				GameContainerView(gameServer: game)
			}
			else
			{
				Label("Waiting for game...", systemImage: "suit.club.fill")
			}
		}
		.padding(40)	//	inner padding
		.frame(minWidth: 100,minHeight: 100)
		.background(Color("GameBackground"))
		.foregroundColor(Color("GameForeground"))
		.background()
		.cornerRadius(12)
		.padding(20)	//	outerpadding
		.onAppear()
		{
			InitGame()
		}


	}
}

#Preview 
{
	//ContentView( player: PlayerUid("PreviewPlayer") )
	AppView()
}

