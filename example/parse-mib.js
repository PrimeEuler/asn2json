const util = require('util')
const asn2json = require("../asn2json");
const fs = require('fs');

// Create a new instance of asn2json
var asn = new asn2json();

// Parse a MIB
var json = asn.parse( fs.readFileSync("../SMI/MIB/RFC-1212.mib") );

// Print entire object
console.log(util.inspect(json, {showHidden: false, colors: true, depth: null}));

// Print only the RFC-1212 Definitions
console.log(util.inspect(json["RFC-1212"].DEFINITIONS, {showHidden: false, colors: true, depth: null}));
