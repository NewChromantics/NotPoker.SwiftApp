let Module = ImportModule(`ImportedTest.js`)

console.log(`Module=${Module}`);

//console.log("What");

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
return 123;
