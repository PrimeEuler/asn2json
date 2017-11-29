var asn2json    = require("../asn2json");
var fs          = require('fs');
var util        = require('util');
var asn         = new asn2json()
var MIB = {
    iso : { 
            'OBJECT IDENTIFIER': { '::=': [ 'root', 1 ] } 
        }
};
function smi2json(mib){
    try{
        var schema = fs.readFileSync("./MIB/" + mib)
        var Module = asn.parse(schema)
        
        var ModuleName  = Object.keys(Module)[0];
        var Definitions = Module[ModuleName].DEFINITIONS
        var identifiers = Object.keys(Definitions);
            identifiers.forEach( function( ObjectId ){
                //replaces outdated DEFINITIONS
                MIB[ObjectId] = Definitions[ObjectId]
            })
         console.log("Parsed : " + mib);
    }catch(e){
         console.log(mib, util.inspect(e, false, 10, true))
    }
}
var Modules = [
    //SNMPv1
    'RFC1155-SMI.mib',
    'RFC1158-MIB.mib',
    'RFC-1212.mib',
    'RFC1213-MIB-II.mib',
    //SNMPv2
    'SNMPv2-SMI.mib',
    'SNMPv2-CONF.mib',
    'SNMPv2-TC.mib',
    'SNMPv2-MIB.mib',
    //Network
    /*
    'ianaiftype-mib.MIB',
    'IF-MIB.MIB',
    'IP-FORWARD-MIB.MIB',
    'RMON-MIB.MIB',
    'INET-ADDRESS-MIB.mib',
    'IP-MIB.MIB',
    'RFC-1215.MIB',
    'BRIDGE-MIB.MIB',
    'BGP4-MIB.MIB',
    'HOST-RESOURCES-MIB.MIB',
    'SNMP-FRAMEWORK-MIB.mib',
    'ENTITY-MIB.MIB',
    'RFC1271-MIB.MIB',
    'TOKEN-RING-RMON-MIB.MIB',
    'RMON2-MIB.MIB',
    'P-BRIDGE-MIB.MIB',
    'Q-BRIDGE-MIB.MIB',
    */
    //CISCO
    /*
    'CISCO-SMI.MIB',
    'CISCO-TC.MIB',
    'CISCO-PRODUCTS-MIB.MIB',
    'OLD-CISCO-TCP-MIB.MIB',
    'OLD-CISCO-TS-MIB.MIB',
    'CISCO-VTP-MIB.MIB',
    'CISCO-CDP-MIB.MIB',
    'CISCO-VLAN-MEMBERSHIP-MIB.MIB',
    'CISCO-METRO-PHY-MIB.MIB',
    'CISCO-CONFIG-MAN-MIB.MIB',
    'CISCO-SYSLOG-MIB.MIB',
    'CISCO-IPSEC-FLOW-MONITOR-MIB.mib',
    'CISCO-ENTITY-SENSOR-MIB.MIB',
    'CISCO-SECURE-SHELL-MIB.MIB'
    */
    //*/
    ].forEach( smi2json )
    
fs.writeFileSync('./MIB.json', JSON.stringify(MIB,null,4) )    
console.log( util.inspect(MIB, false, 10, true))