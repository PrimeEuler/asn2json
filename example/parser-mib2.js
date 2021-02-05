var asn2json = require('../asn2json');
var fs = require('fs');

// Create a new instance of asn2json
var asn = new asn2json();

var data = fs.readFileSync(`${__dirname}/../SMI/MIB/RFC-1212.mib`).toString();

var json = asn.parse(data);

console.log(json);
