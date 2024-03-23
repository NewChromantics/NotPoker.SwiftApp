import ImportedDefault from 'ImportedTest.js'
import {One,Two} from 'ImportedTest.js'

console.log(`One=${One}`);
console.log(`Two=${Two}`);

//	new default
export default class CorrectExport extends ImportedDefault
{
}

