import SwiftUI
import NotPokerApi

import Collections



struct DebugActionView : View
{
	@State private var selectedValue = ActionArgumentValue()
	var key : String
	var actionMeta : ActionMeta
	
	
	func OnRunAction(_ actionKey:String)
	{
		print("Player run action \(actionKey)")
	}
	
	
	var body: some View
	{
		HStack()
		{
			Button(action: { OnRunAction(key) } )
			{
				Label("Action \(key)", systemImage: "suit.heart")
			}
			
			//Text(value.description)
			//ForEach( Array(value.Arguments) )
			ForEach(0..<actionMeta.Arguments.count, id: \.self)
			{
				ArgumentIndex in
				let Values = actionMeta.Arguments[ArgumentIndex]
				
				Picker("Arg#\(ArgumentIndex)", selection: $selectedValue)
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
