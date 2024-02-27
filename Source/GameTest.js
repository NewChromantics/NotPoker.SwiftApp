let Module = ImportModule(`ImportedTest.js`)

console.log("js post import...");
console.log(`Module=${JSON.stringify(Module)}`);
console.log(`Module.Thing=${Module.Thing}`);
console.log(`typeof Module.SomeFunction=${typeof Module.SomeFunction}`);
console.log(`Module.SomeFunction()=${Module.SomeFunction()}`);

//	import { ImportedHello } from
let ImportedHello = Module.SomeFunction;

async function AsyncHello()
{
	throw `I am an exception string`;
}

/*
module.exports =
{
	Hello,
};
*/

//	will fail module init
//return 123;
