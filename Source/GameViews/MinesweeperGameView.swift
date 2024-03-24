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
	public func MapValueAt(_ x:Int,_ y:Int) -> ActionArgumentValue
	{
		let Value = Map[x][y]
		return Value
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

func getSquareGrid(ContentRect:GeometryProxy, MapWidth: Int, MapHeight:Int) -> ([CellItem],CGRect)
{
	let ContentSize = ContentRect.size
	var ContentX = ContentRect.frame(in: .local).minX
	var ContentY = ContentRect.frame(in: .local).minY
	var CellArray: [CellItem] = []
	let rectWidth = round( ContentSize.width/CGFloat(MapWidth) )
	let rectHeight = round( ContentSize.height/CGFloat(MapHeight) )
	let rectangleSize = min( rectWidth, rectHeight )
	
	let GridRect = CGRect( x:ContentX, y:ContentY, width:CGFloat(MapWidth)*rectangleSize, height:CGFloat(MapHeight)*rectangleSize )

	//	center
	ContentX += (ContentSize.width - GridRect.width) / 2
	ContentY += (ContentSize.height - GridRect.height) / 2

	for row in 0...MapHeight - 1
	{
		for column in 0...MapWidth - 1 
		{
			var CellX = CGFloat(column) * rectangleSize
			var CellY = CGFloat(row) * rectangleSize
			CellX += ContentX
			CellY += ContentY
			let CellRect = CGRect( x:CellX, y:CellY, width: rectangleSize, height: rectangleSize )
			
			let Cell = CellItem( ContentRect: CellRect, MapX: column, MapY: row)
			CellArray.append(Cell)
		}
	}
	
	
	return (CellArray,GridRect)
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
	
	func GetCellBackgroundColour(_ value:ActionArgumentValue) -> Color
	{
		switch value.description
		{
		case "?":	return Color("MinesweeperCell_?")
		case "0":	return Color("MinesweeperCell_0")
		case "1":	return Color("MinesweeperCell_1")
		case "2":	return Color("MinesweeperCell_2")
		case "3":	return Color("MinesweeperCell_3")
		case "4":	return Color("MinesweeperCell_4")
		case "5":	return Color("MinesweeperCell_5")
		case "6":	return Color("MinesweeperCell_6")
		case "7":	return Color("MinesweeperCell_7")
		case "8":	return Color("MinesweeperCell_8")
			//	user's name = bomb
		default:	return Color("MinesweeperCell_Bomb")
		}
	}
	
	func GetCellForegroundColour(_ value:ActionArgumentValue) -> Color
	{
		switch value.description
		{
		case "?",
			"0",
			"1",
			"2",
			"3",
			"4",
			"5",
			"6",
			"7",
			"8":
			return Color("MinesweeperCell_Foreground")
			//	user's name = bomb
		default:	return Color("MinesweeperCell_BombForeground")
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
				let (Cells,GridRect) = getSquareGrid(ContentRect: geometry, MapWidth:MapWidth, MapHeight:MapHeight)
					ForEach(Cells)
					{
						Cell in
						let CellValue = state.MapValueAt(Cell.MapX,Cell.MapY)
						ZStack()
						{
							RoundedRectangle(cornerRadius: 3, style: .continuous)
								.fill( GetCellBackgroundColour(CellValue) )
								.padding(2)
							Text("\(CellValue.description)")
								.foregroundColor( GetCellForegroundColour(CellValue) )
								.allowsHitTesting(false)
						}
						.frame( width: Cell.ContentRect.width, height: Cell.ContentRect.height/*, alignment: .center*/)
						.offset( x: Cell.ContentRect.minX, y: Cell.ContentRect.minY )
						.onTapGesture
						{
							OnTappedCell(Cell.MapX,Cell.MapY)
						}
					}
				
			}
		}
		//.background(Color.blue)
	}
	
	
	var body: some View
	{
		let State : MinesweeperGameState = baseState.GetState()	//	typed variable infers the generic arg
		Label("Minesweeper! \(State.MapWidth)x\(State.MapHeight)", systemImage: "flag.checkered")
		MapView(State)
	}
}
