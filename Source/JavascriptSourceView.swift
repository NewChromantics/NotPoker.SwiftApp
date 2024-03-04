import SwiftUI
import NotPokerApi



struct RuntimeError: LocalizedError
{
	let description: String

	init(_ description: String) {
		self.description = description
	}

	var errorDescription: String? {
		description
	}
}



struct JavascriptSourceView : View
{
	@State var filename : String = "ImportedTest.js"
	@State var url : URL? = nil
	@State var source : String = ""
	@State var loadError : String?

	func LoadSource(_ filename:String)
	{
		do
		{
			url = Bundle.main.url(forResource: filename, withExtension: "")
			if ( url == nil )
			{
				throw RuntimeError("File \(filename) not found")
			}
			let fileContent = try String(contentsOf: url!)
			
			source = NotPokerApi.RewriteES6ImportsAndExports(fileContent, importFunctionName: JavascriptModule.ImportModuleFunctionSymbol, exportSymbolName: JavascriptModule.ModuleExportsSymbol, replacementNewLines:true )

			loadError = nil
		}
		catch
		{
			loadError = error.localizedDescription
		}
	}
	
	var body: some View
	{
		TextField("Filename", text:$filename)
			.onChange(of: filename)
			{
				LoadSource(filename)
			}
			.onAppear()
			{
				LoadSource(filename)
			}
			
		if ( url != nil )
		{
			Label(url!.absoluteString,systemImage: "square.stack")
				.padding(10)
				.background(.yellow)
				.padding(10)
				.textSelection(.enabled)
		}
		if ( loadError != nil )
		{
			Label(loadError!,systemImage: "exclamationmark.triangle.fill")
				.padding(10)
				.background(.red)
				.padding(10)
				.textSelection(.enabled)
		}
		ScrollView
		{
			Text(source)
				.padding(20)
				.frame(maxWidth: .infinity,maxHeight:.infinity, alignment:.topLeading)
				.textSelection(.enabled)
				.background(.white)
				.padding(0)
		}
	}
}

#Preview 
{
	JavascriptSourceView()
}

