import {Yield} from `./Games/PromiseQueue.js`

let Server_Game = null;
let Client_PlayerUid = null;

async function Allocate(GameName)
{
	const Module = __ImportModule(`./Games/${GameName}.js`);
	console.log(`imported module; ${JSON.stringify(Module)}`);
	console.log(`imported module keys; ${Object.keys(Module)}`);
	const GameConstructor = Module.default;
	console.log(`Allocating game; ${GameConstructor.name}`);
	const NewGame = new GameConstructor( console.log );
	Server_Game = NewGame;

	return Server_Game;
}

async function WaitForNextGameState()
{
	await Yield(1000);
	
	const NewState = {};
	NewState.Test = "Hello";
	
	return JSON.stringify(NewState);
}

async function AddPlayer(PlayerUid)
{
	if ( !Server_Game )
		throw `No game running`;
	
	const result = "added player ok";
	/*
	const Result = await Server_Game.AddPlayer(PlayerUid);
	*/
	//	set only if successfully joined
	Client_PlayerUid = PlayerUid;
	
	return Result;
}
