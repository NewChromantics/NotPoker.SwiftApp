import SwiftUI
import NotPokerApi



public struct MinesweeperGameState : GameStateType
{
	public var GameType: String?
	public var Error: String?
	public var Actions: NotPokerApi.ActionList?
	public var Map : [[ActionArgumentValue]]
	
	public init()
	{
		Error = nil
		GameType = nil
		Map = []
	}

	public var MapWidth : Int
	{
		return Map[0].count
	}
	public var MapHeight : Int
	{
		return Map.count
	}
	public func MapValueAt(_ x:Int,_ y:Int) -> String
	{
		let Value = Map[x][y]
		return Value.description
	}

	public init(Error: String)
	{
		self.Error = Error
		Map = []
	}
}


struct CellItem: Identifiable
{
	let ContentRect : CGRect
	let id = UUID()
	let MapX : Int
	let MapY : Int

}

func getSquareGrid(ContentSize: CGSize, MapWidth: Int, MapHeight:Int) -> [CellItem]
{
	var CellArray: [CellItem] = []
	let rectWidth = round( ContentSize.width/CGFloat(MapWidth) )
	let rectHeight = round( ContentSize.height/CGFloat(MapHeight) )
	let rectangleSize = min( rectWidth, rectHeight )
	
	for row in 0...MapHeight - 1
	{
		for column in 0...MapWidth - 1 
		{
			let CellRect = CGRect( x:CGFloat(column) * rectangleSize, y: CGFloat(row) * rectangleSize, width: rectangleSize, height: rectangleSize )
			let Cell = CellItem( ContentRect: CellRect, MapX: column, MapY: row)
			CellArray.append(Cell)
		}
	}
	return CellArray
}

struct MinesweeperGameView : View
{
	@Binding var baseState : ClientGameState
	
	func OnTappedCell(_ MapX:Int,_ MapY:Int)
	{
		//	gr: should only be enabling this if your turn
		var Action = ActionReply(Action:"PickCoord")
		let Arg0 = ActionArgumentValue(MapX)
		let Arg1 = ActionArgumentValue(MapY)
		Action.ActionArguments = [Arg0,Arg1]
		print("Tapped \(MapX) \(MapY)")
		do
		{
			try baseState.OnUserClickedAction(Action)
		}
		catch
		{
			print(error.localizedDescription)
		}
	}
	
	func MapView(_ state:MinesweeperGameState) -> some View
	{
		let MapWidth = state.MapWidth
		let MapHeight = state.MapHeight
		return VStack()
		{
			GeometryReader
			{
				geometry in
				let Cells: [CellItem] = getSquareGrid(ContentSize: geometry.size, MapWidth:MapWidth, MapHeight:MapHeight)
				ForEach(Cells)
				{
					Cell in
					let CellValue = state.MapValueAt(Cell.MapX,Cell.MapY)
					ZStack()
					{
						RoundedRectangle(cornerRadius: 3, style: .continuous)
							.fill( Color("GameForeground") )
							.padding(2)
						Text("\(CellValue)")
							.foregroundColor( Color("GameBackground") )
							.allowsHitTesting(false)
					}
					.frame( width: Cell.ContentRect.width, height: Cell.ContentRect.height, alignment: .center)
					.offset( x: Cell.ContentRect.minX, y: Cell.ContentRect.minY )
					.onTapGesture
					{
						OnTappedCell(Cell.MapX,Cell.MapY)
					}
				}
			}
			.frame(alignment: .center)
		}
	}
	
	
	var body: some View
	{
		let State : MinesweeperGameState = baseState.GetState()	//	typed variable infers the generic arg
		Label("Minesweeper! \(State.MapWidth)x\(State.MapHeight)", systemImage: "flag.checkered")
		MapView(State)
	}
}
