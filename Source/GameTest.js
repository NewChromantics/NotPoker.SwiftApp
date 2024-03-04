//let Module = __ImportModule(`ImportedTest.js`)
import * as Module from "ImportedTest.js"
import {One} from "ImportedTest.js"
import ModuleDefault from 'ImportedTest.js'

let importfrom = "This shouldn't match";

console.log("js post import...");
console.log(`Module=${JSON.stringify(Module)}`);
console.log(`typeof Module.SomeFunction=${typeof Module.SomeFunction}`);
console.log(`Module.SomeFunction()=${Module.SomeFunction()}`);

export let ImportedHello = Module.SomeFunction;

async function AsyncHello()
{
	throw `I am an exception string (One=${One})`;
}

import Minesweeper from 'Games/Minesweeper.js'

//	will fail module init
//return 123;
