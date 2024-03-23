import SwiftUI
import NotPokerApi




struct DebugActionView : View
{
	@Binding var state : ClientGameState	//	passing this to get access to the callbacks
	@State private var selectedValues : [ActionArgumentValue]
	var actionName : String
	var actionMeta : ActionMeta
	@State var ActionError : String? = nil
	
	
	//	todo: handle throwing and display to UI
	func OnRunAction()
	{
		do
		{
			//let ValuesDebug = selectedValues.compactMap({String(describing: $0)}).joined(separator:",")
			//print("Player run action \(key) with \(ValuesDebug)")
			var Reply = ClientActionReply(Action:actionName)
			Reply.Arguments = selectedValues
			try! state.OnUserClickedAction( Reply )
		}
		catch
		{
			ActionError = error.localizedDescription
		}
	}
	
	init(actionName: String, actionMeta: ActionMeta,state:Binding<ClientGameState>)
	{
		self.actionName = actionName
		self.actionMeta = actionMeta
		_state = state

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
		VStack
		{
			Button(action: OnRunAction)
			{
				Label("Action \(actionName)", systemImage: "bolt.fill")
			}
		}
		//	gr: the button isn't clickable on ios when in the same VStack, the pickers get caught...
		VStack
		{
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
			
			if let error = ActionError
			{
				Label("Error: \(error)", systemImage: "exclamationmark.triangle.fill")
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
				DebugActionView( actionName: actionKey, actionMeta: actionMeta, state:$state )
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
