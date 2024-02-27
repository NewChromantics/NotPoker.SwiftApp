console.log("imported file");

function ImportedHello()
{
	return "world";
};

exports.One = "one";
exports.Two = 222;
exports.SomeFunction = ImportedHello;
exports.SomeFunctionResult = exports.SomeFunction();

console.log(`typeof exports.SomeFunction=${typeof exports.SomeFunction}`);

console.log(`imported file exports=${JSON.stringify(exports)}`);
