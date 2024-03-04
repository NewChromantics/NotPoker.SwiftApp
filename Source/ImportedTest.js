//console.log("imported file");
function ImportedHello()
{
	return "world";
};

export const One = "one";
export Two = 222;
export const SomeFunction = ImportedHello;
export SomeFunctionResult = SomeFunction();
export default One;
