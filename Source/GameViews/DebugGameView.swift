import SwiftUI
import NotPokerApi



extension Array {
	mutating func resize(to size: Int, with filler: Element) {
		let sizeDifference = size - count
		guard sizeDifference != 0 else {
			return
		}
		if sizeDifference > 0 {
			self.append(contentsOf: Array<Element>(repeating: filler, count: sizeDifference));
		}
		else {
			self.removeLast(sizeDifference * -1) //*-1 because sizeDifference is negative
		}
	}

	func resized(to size: Int, with filler: Element) -> Array {
		var selfCopy = self;
		selfCopy.resize(to: size, with: filler)
		return selfCopy
	}
}


struct DebugActionView : View
{
	//	gr: mega bodge...
	@State private var selectedValues : [ActionArgumentValue]
	var key : String
	var actionMeta : ActionMeta
	
	
	func OnRunAction()
	{
		let ValuesDebug = selectedValues.compactMap({String(describing: $0)}).joined(separator:",")
		print("Player run action \(key) with \(ValuesDebug)")
	}
	
	init(key: String, actionMeta: ActionMeta)
	{
		self.key = key
		self.actionMeta = actionMeta

		//	gr: I dont get why i cant modify self.selectedValues here...
		var defaultValues : [ActionArgumentValue] = []
		for index in 0..<actionMeta.Arguments.count
		{
			let ArgumentValues = actionMeta.Arguments[index]
			let DefaultSelectonValue = ArgumentValues[0]
			print("default for \(index) = \(DefaultSelectonValue)")
			defaultValues.append(DefaultSelectonValue)
		}
		selectedValues = defaultValues
	}
	
	var body: some View
	{
		HStack()
		{
			Button(action: OnRunAction)
			{
				Label("Action \(key)", systemImage: "suit.heart")
			}
			
			//Text(value.description)
			//ForEach( Array(value.Arguments) )
			ForEach(0..<actionMeta.Arguments.count, id: \.self)
			{
				ArgumentIndex in
				let Values = actionMeta.Arguments[ArgumentIndex]
				
				Picker("Arg#\(ArgumentIndex)", selection: $selectedValues[ArgumentIndex])
				{
					ForEach( Values )
					{
						value in
						Text("\(value.description)").tag(value)
					}
				}
			}
			
		}
	}
}


struct DebugGameView : View
{
	@Binding var state : ClientGameState

		
	var body: some View
	{
		let GameName = state.gameType ?? "null"
		Label("Playing \(GameName)", systemImage: "suit.heart.fill")
		
		//	if actions are present, render them as options
		List
		{
			ForEach( Array(state.actions), id: \.key)
			{
				actionKey, actionMeta in
				DebugActionView( key: actionKey, actionMeta: actionMeta )
			}
		}
		
		//	show the raw json
		ScrollView
		{
			Text(state.StateJson ?? "{}")
				.padding(20)
				.frame(maxWidth: .infinity,maxHeight:.infinity, alignment:.topLeading)
				.textSelection(.enabled)
				.background(Color("SourceBackground"))
				.foregroundColor(Color("SourceForeground"))
				.padding(0)
		}
		
	}
}
