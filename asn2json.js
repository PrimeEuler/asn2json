var PEG         = require("pegjs");
var fs          = require('fs');
var grammar     = fs.readFileSync( __dirname + '/asn1.pegjs').toString();
/* Adapted from mibbles LL(r) Grammatica ans1 parse grammar
 * https://github.com/cederberg/mibble/blob/master/src/grammar/asn1.grammar
 *
 * Parser returns a ASN1 Module with definitions -JSON.Stringify friendly
 */
var parser      = PEG.generate(grammar, { trace: false });
function asn2json(){
    function parse(input){
        var COMMENTS    = /--([^\n\r-]|-[^\n\r-])*(--|-?[\n\r])/g ;
        input = input.toString().replace(COMMENTS,"");
        return parser.parse(input)[0];
    }
    this.parse = parse;
}
module.exports = asn2json;
