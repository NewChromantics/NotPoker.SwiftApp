console.log("imported file");

function ImportedHello()
{
	return "world";
};

__exports.One = "one";
__exports.Two = 222;
__exports.SomeFunction = ImportedHello;
__exports.SomeFunctionResult = __exports.SomeFunction();

console.log(`typeof exports.SomeFunction=${typeof __exports.SomeFunction}`);

console.log(`imported file exports=${JSON.stringify(__exports)}`);
