import SwiftUI
import NotPokerApi


extension Task where Success == Never, Failure == Never 
{
	static func sleep(milliseconds: Int) async
	{
		let Nanos = UInt64(milliseconds * 1_000_000)
		do
		{
			try await Task.sleep(nanoseconds: Nanos)
		}
		catch
		{
		}
	}
}


struct LoginView: View
{
	@Binding var playerUid : PlayerUid?
	
	func StartLogin()
	{
		Task
		{
			await Task.sleep(milliseconds: 50)
			playerUid = PlayerUid("Zaphod")
		}
	}
	
	var body: some View
	{
		if ( playerUid == nil )
		{
			Button(action:StartLogin)
			{
				Label("Log in", systemImage:"person")
					.padding(10)
					.frame(maxWidth: .infinity)
					//.background(Color.red)	//	show clickable area
			}
		}
		else
		{
			Label(" \(playerUid!.Uid)", systemImage:"person.fill")
				.frame(maxWidth: .infinity)
				.padding(10)
		}
		//.padding(5)
	}
}
