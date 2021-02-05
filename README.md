# asn2json
Javascript ASN.1 schema parser with SMI MACRO extentions for SNMP MIB's


## How to install
### Install with NPM
```shell
npm install asn2json
```

### Install with YARN
```shell
yarn add asn2json
```

## How to use it

```javascript
var asn2json = require('asn2json');
var fs = require('fs');

// Create a new instance of asn2json
var asn = new asn2json();

var data = fs.readFileSync(`[YOUR MIB FILE PATH]`).toString();

var json = asn.parse(data);

console.log(json);
```
