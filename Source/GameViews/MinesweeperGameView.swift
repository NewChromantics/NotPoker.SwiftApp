import SwiftUI
import NotPokerApi



struct MinesweeperGameView : View
{
	@Binding var state : ClientGameState
	
	
	var body: some View
	{
		Label("Minesweeper!", systemImage: "flag.checkered")
	}
}
