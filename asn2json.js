/* Adapted from mibbles LL(r) Grammatica ans1 parse grammar
 * https://github.com/cederberg/mibble/blob/master/src/grammar/asn1.grammar
 *
 * Parser returns a ASN1 Module with definitions -JSON.Stringify friendly
 */
var parser = require('./syntax/parser');

function asn2json() {
    function parse(input) {
        return parser.parse(input)[0];
    }
    this.parse = parse;
}

module.exports = asn2json;
