import SwiftUI
import NotPokerApi

import Collections



struct DebugGameView : View
{
	@Binding var state : ClientGameState

	@State private var numberOfPeople = "0"
	
	func OnRunAction(_ actionKey:String)
	{
		print("Player run action \(actionKey)")
	}
	
	var body: some View
	{
		let GameName = state.gameType ?? "null"
		Label("Playing \(GameName)", systemImage: "suit.heart.fill")
		
		//	if actions are present, render them as options
		List
		{
			let dict = state.actions
			let orderedDict = OrderedDictionary(uniqueKeys: dict.keys, values: dict.values)
			ForEach( Array(orderedDict), id: \.key)
			{
				key, value in
				HStack()
				{
					Button(action: { OnRunAction(key) } )
					{
						Label("Action \(key)", systemImage: "suit.heart")
					}
					
					
					
					//Text(value.description)
					//ForEach( Array(value.Arguments) )
					ForEach(0..<value.Arguments.count, id: \.self)
					{
						ArgumentIndex in
						let Values = value.Arguments[ArgumentIndex]
						
						Picker("Arg#\(ArgumentIndex)", selection: $numberOfPeople)
						{
							ForEach( Values )
							{
								value in
								Text("\(value.description)").tag(value.description)
							}
						}
					}
					
				}
			}
		}
		.foregroundColor(Color.black)
		
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
