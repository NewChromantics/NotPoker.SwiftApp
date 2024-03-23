import SwiftUI
import NotPokerApi





struct DebugGameView : View
{
	@Binding var state : ClientGameState
	
	
	var body: some View
	{
		let GameName = state.gameType ?? "null"
		return Label("Playing \(GameName)", systemImage: "suit.heart.fill")
	}
}
