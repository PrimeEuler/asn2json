/* https://github.com/cederberg/mibble/blob/master/src/grammar/asn1.grammar
 * asn1.grammar
 *
 * This work is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published
 * by the Free Software Foundation; either version 2 of the License,
 * or (at your option) any later version.
 *
 * This work is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
 * USA
 *
 * Copyright (c) 2004-2009 Per Cederberg. All rights reserved.
 */

//%header%
/*
GRAMMARTYPE = "LL"

DESCRIPTION = "A grammar for the ASN.1 format, with SNMP macro extensions. The
               grammar is partly derived from the yacc and lex sources of
               'snacc'--a free ASN.1 to C or C++ compiler. Other parts of the
               grammar comes from RFC 1155, 1212, 1215, 1902, 1903, and 1904.
               This grammar should be able to correctly parse Internet MIBs."

AUTHOR      = "Per Cederberg"
VERSION     = "2.9"
DATE        = "12 March 2009"

LICENSE     = "This work is free software; you can redistribute it and/or modify
               it under the terms of the GNU General Public License as published
               by the Free Software Foundation; either version 2 of the License,
               or (at your option) any later version.

               This work is distributed in the hope that it will be useful, but
               WITHOUT ANY WARRANTY; without even the implied warranty of
               MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
               General Public License for more details.

               You should have received a copy of the GNU General Public License
               along with this program; if not, write to the Free Software
               Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
               USA"

COPYRIGHT   = "Copyright (c) 2004-2009 Per Cederberg. All rights reserved."
*/

//%tokens%




//%productions%

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *
 *  Module def/import/export productions
 *
 */

{
    //var _       = require('lodash');
    var util        = require('util');
    var COMMENTS = /--([^\n\r-]|-[^\n\r-])*(--|-?[\n\r])/g ;
    var DEFINITIONS = {}
    var MODULE = {}
    
    function merge_options(obj1,obj2){
        var obj3 = {};
        for (var attrname in obj1) { obj3[attrname] = obj1[attrname]; }
        for (var attrname in obj2) { obj3[attrname] = obj2[attrname]; }
        return obj3;
    }
    
    
    
    Array.prototype.clean = function(deleteValue,bool) {
        var ob = {};
      for (var i = 0; i < this.length; i++) {
        if (this[i] == deleteValue) {         
          this.splice(i, 1);
          i--;
        }
        /*
        if(_.isObject(this[i])){
            _.merge(ob,this[i])
        }
        */
        if(typeof this[i] === 'object'){
         ob = merge_options(ob,this[i])
          
           //console.log( ob)
        }
        
      }
      //console.log(util.inspect(ob, false, 10, true))
      if(bool){
          return ob
      }else
      if(this && this.length == 1){
          return this[0]
      }else{
          return this;
      }
      
    };
    
    var join = function(array){
        try{
            return array.join("").replace(/,/g,"").replace(/\n/g,"").trim()
        }catch(e){
            //console.log(util.inspect(e, false, 10, true))
            return array
        }
    }
    
    var lineArray = function (a){
        function trim(element, index, array) {
           array[index] = element.trim();
        }
        a = a.split(/\n/g)
		if(a.length === 1){
			a = a[0].split(/\r/g)
		}
        a.forEach(trim)
        return a
    }
}


Start = ModuleDefinition+ ;

ModuleDefinition = _ a:ModuleIdentifier  "DEFINITIONS" _  TagDefault?
                    _ "::=" _ "BEGIN" _ ModuleBody _ "END" _
 {
        MODULE[a]={ "DEFINITIONS":DEFINITIONS } 
     return MODULE
 };

ModuleIdentifier = a:(a:IDENTIFIER_STRING{ return join(a) }) _ b:ObjectIdentifierValue?
{
    if(b){
        b = join(b)
    }
    return a
};

ModuleReference = ( a:IDENTIFIER_STRING{ return join(a)} ) "." ;

TagDefault = "EXPLICIT" _ "TAGS"
           / "IMPLICIT" _ "TAGS" 
           / "AUTOMATIC" _ "TAGS";

ModuleBody = a:ExportList? b:ImportList? c:AssignmentList
{
    
    return [a,b,c].clean(null);
};

ExportList = "EXPORTS" _ a: SymbolList* _ ";" _ 
{
    DEFINITIONS.EXPORTS = a;
    return { "EXPORTS" : a }
};

ImportList = "IMPORTS" _ a: SymbolsFromModule*  _ ";" _ 
{
    DEFINITIONS.IMPORTS = { "FROM" : a };
    return { "IMPORTS" : { "FROM" : a } }
};

SymbolsFromModule = a:SymbolList _ "FROM" _ b:ModuleIdentifier
{ 
    var c = { }
    c[ b ] = a 
    return c
};

SymbolList = a:Symbol _ b:("," _ c:Symbol{ return c })*
{
    return [a].concat(b).clean(null)
};

Symbol = a:IDENTIFIER_STRING{ return join(a) }
       / DefinedMacroName ;

AssignmentList = Assignment+ ;

Assignment = a:MacroDefinition _ ";"?   { return a }
           / b:TypeAssignment _ ";"?    { return b }
           / c:ValueAssignment _ ";"?   {  return c };

MacroDefinition = a : MacroReference _ "MACRO" _ "::="  b:MacroBody
{
    DEFINITIONS[a]= { "TYPE NOTATION":{}, "VALUE NOTATION":{} }
    var c={}
        c[a] = join(b)
    return c
};

MacroReference = //IDENTIFIER_STRING
                DefinedMacroName ;

MacroBody = _ "BEGIN" MacroBodyElement+ "END" _
           // ModuleReference _ MacroReference ;
MacroBodyOperator = "("
                 / ")"
                 / "|"
                 / "::=";
                 
MacroBodyElement = MacroBodyOperator
                 / "INTEGER"
                 / "REAL"
                 / "BOOLEAN"
                 / "NULL"
                 / "BIT"
                 / "OCTET"
                 / "STRING"
                 / "OBJECT"
                 / "IDENTIFIER"
                 / "VALUE"
                 / "TYPE" _ "NOTATION" 
                 / "VALUE" _ "NOTATION"
                 / IDENTIFIER_STRING 
                 / QUOTED_STRING 
                 / [ \t\n\r\f\x0b\x17\x18\x19\x1a]

                 



/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *
 *  Type notation productions
 *
 */

TypeAssignment = a:(a:IDENTIFIER_STRING{return join(a)}) _ "::=" _ b:Type
{
    DEFINITIONS[a]=b
    var c = {};
        c[a] = b
    return c
};

Type = BuiltinType
     / DefinedMacroType 
     / DefinedType

DefinedType = ModuleReference? a:(a:IDENTIFIER_STRING {return join(a)} ) _ b:ValueOrConstraintList?
{
    return [a,b].clean(null);
};

BuiltinType = NullType
			// ChoiceType
            / BooleanType
            / RealType
            / IntegerType
            / ObjectIdentifierType
            / StringType
            / BitStringType
            / BitsType
            / SequenceType
            / SequenceOfType
            / SetType
            / SetOfType
            / ChoiceType
            / EnumeratedType
            / SelectionType
            / TaggedType
            / AnyType ;

NullType    = "NULL";
BooleanType = "BOOLEAN";
RealType    = "REAL";
IntegerType = "INTEGER" _ a:ValueOrConstraintList?
{
    return [ "INTEGER" , a ].clean(null)
};

ObjectIdentifierType = "OBJECT" _ "IDENTIFIER"
{
    return "OBJECT IDENTIFIER"
} ;

StringType = "OCTET" _ "STRING" _ a:ConstraintList?
{
    return [ "OCTET STRING" , a ].clean(null)
};

BitStringType = "BIT" _ "STRING" _ a: ValueOrConstraintList?
{
    return [ "BIT STRING" , a ].clean(null)
};

BitsType = "BITS" _ a : ValueOrConstraintList?
{
    return [ "BITS" , a  ].clean(null)
};

SequenceType = "SEQUENCE" _ "{" a : ElementTypeList? "}"
{
    return  { "SEQUENCE" : a }
};

SequenceOfType = a: ("SEQUENCE" _ ConstraintList? _ "OF") _ b :Type 
{
    return [ "SEQUENCE OF" , b ]
    //EDIT FOR SMI compiler
};

SetType = "SET" _ "{" _ a : ElementTypeList? _ "}"
{
    return { "SET" : a }
};

SetOfType = a:("SET" _ SizeConstraint? _ "OF") _ b : Type
{
    return { "SET OF": b }
};

ChoiceType = "CHOICE" _ "{"  _ a : ElementTypeList _  "}"
{
    return { "CHOICE" : a }
};

EnumeratedType = "ENUMERATED" _ a : NamedNumberList 
{
    return { "ENUMERATED" : a }
};

SelectionType = ( a: IDENTIFIER_STRING { return a} ) _ "<" _ Type ;

TaggedType = a:Tag _ b:ExplicitOrImplicitTag? _ c:Type 
{
    var d = {}
        d[a] = [b,c].clean(null)
    //return d
    a.definition = b;
    a.type = c;
    return a
};

Tag = "[" a:Class? _ b:NUMBER_STRING _ "]"
{
    return { tag:{ class:a , number:parseInt(join(b)) } }
};

Class = "UNIVERSAL"         // 1
      / "APPLICATION"       // 2
      / "CONTEXT-SPECIFIC"  // 3
      / "PRIVATE"           // 4

ExplicitOrImplicitTag = "EXPLICIT"
                      / "IMPLICIT" ;

AnyType = "ANY"
        / "ANY" _ "DEFINED" _ "BY" _ (a:IDENTIFIER_STRING { return a} ) ;

ElementTypeList = a:ElementType b:("," c:ElementType { return c})*
{
    return [a].concat(b).clean(null)
};

ElementType = _ a:(a:IDENTIFIER_STRING{ return join(a)} )? _ b : Type _ c:OptionalOrDefaultElement? { return [a,b,c].clean(null) }
            / _ IDENTIFIER_STRING? _ "COMPONENTS" _ "OF" _ Type ;

OptionalOrDefaultElement = "OPTIONAL"
                         / "DEFAULT" _ IDENTIFIER_STRING? _ Value ;

ValueOrConstraintList = NamedNumberList
                      / ConstraintList ;

NamedNumberList = "{" _ a:NamedNumber b:(_"," _ c:NamedNumber{return c})* _ "}"
{
    return [a].concat(b).clean(null,true)
};

NamedNumber = a:(a:IDENTIFIER_STRING{ return join(a)} )  _ "(" _ b:Number _  ")"
{
    var c = {}
        //c[a] = b
        c[b] = a
    return c
};

Number = NumberValue
       / BinaryValue
       / HexadecimalValue
       / DefinedValue ;

ConstraintList = "(" _ a:Constraint _ b:("|" _ c:Constraint { return c})* _ ")"
{
    return [a].concat(b).clean(null)
};

Constraint = 
            SizeConstraint
           / ValueConstraint
           / AlphabetConstraint
           / ContainedTypeConstraint
           / InnerTypeConstraint ;

ValueConstraintList = "(" _ a:ValueConstraint _ b:("|" _ c:ValueConstraint{ return c})* _ ")"
{
    return [a].concat(b).clean(null)
};

ValueConstraint = a:LowerEndPoint _ b:ValueRange?
{
    if(!b){ 
        return a;
    }else{
        return { min:a , max:b }
    }
};

ValueRange = "<"? _ ".." _ "<"? a:UpperEndPoint _ 
{
    return a
};

LowerEndPoint = Value
              / "MIN" ;

UpperEndPoint = Value
              / "MAX" ;

SizeConstraint = "SIZE" _ a:ValueConstraintList
{
    return { "SIZE" : a }
};

AlphabetConstraint =  "FROM" _ a:ValueConstraintList
{
    return { "FROM" : a }
};

ContainedTypeConstraint = "INCLUDES" _ Type ;

InnerTypeConstraint = "WITH" _ "COMPONENT" _ ValueOrConstraintList
                    / "WITH" _ "COMPONENTS" _ ComponentsList ;

ComponentsList = "{" _ ComponentConstraint _ ComponentsListTail* _ "}"
               / "{" "..." ComponentsListTail+ "}" ;

ComponentsListTail = "," ComponentConstraint? ;

ComponentConstraint = (a:IDENTIFIER_STRING{ return join(a)} ) _ ComponentValuePresence?
                    / ComponentValuePresence ;

ComponentValuePresence = ValueOrConstraintList _ ComponentPresence?
                       / ComponentPresence ;

ComponentPresence = "PRESENT"
                  / "ABSENT"
                  / "OPTIONAL" ;



/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *
 *  Value notation productions
 *
 */

ValueAssignment = a:(a:IDENTIFIER_STRING{ return join(a)} ) _ b:Type _ "::=" _ c:Value
{
    
    if(typeof b === 'string'){
        var bb = {}
        bb[b] = {'::=':c}
        //bb[b].VALUE = c
        b = bb;
    }else{
        /*
        var MacroName = Object.keys(b)[0];
        var ob;
        switch(MacroName){
            case "MODULE-IDENTITY":     
                //console.log(b)
                break;
            case "OBJECT-IDENTITY":     
                //console.log(b)
                break;
            case "OBJECT-TYPE":         
                ob = b["OBJECT-TYPE"].SYNTAX
                b.call = function(buffer){
                    return ob;
                }
                break;
            case "NOTIFICATION-TYPE":   
                ob = b["NOTIFICATION-TYPE"].OBJECTS
                b.call = function (){
                    if(typeof ob === 'string'){
                        return DEFINITIONS[a]
                    }else{
                        var ref = {}
                        ob.forEach(function(id){
                            ref[id] = DEFINITIONS[id]
                        })
                        return ref
                    }
                    
                }
                break;
            
            case "TRAP-TYPE":  
                //console.log(b)
                break;
            case "TEXTUAL-CONVENTION": 
                ob = b["TEXTUAL-CONVENTION"].SYNTAX
                b.call = function(buffer){
                    return ob;
                }
                break;
            case "OBJECT-GROUP":        
                ob = b["OBJECT-GROUP"].OBJECTS
                b.call = function (){
                    if(typeof ob === 'string'){
                        return DEFINITIONS[a]
                    }else{
                        var ref = {}
                        ob.forEach(function(id){
                            ref[id] = DEFINITIONS[id]
                        })
                        return ref
                    }
                    
                }
                break;
            case "NOTIFICATION-GROUP":  
                ob = b["NOTIFICATION-GROUP"].NOTIFICATIONS
                b.call = function (){
                    if(typeof ob === 'string'){
                        return DEFINITIONS[a]
                    }else{
                        var ref = {}
                        ob.forEach(function(id){
                            ref[id] = DEFINITIONS[id]
                        })
                        return ref
                    }
                    
                }
                break;

            case "MODULE-COMPLIANCE":   
                //console.log(b)
                break;
            case "AGENT-CAPABILITIES":  
                //console.log(b)
                break;
        }
        */
        
        b[Object.keys(b)[0]]['::='] = c
        //b.VALUE = c
    }
    
    
    DEFINITIONS[a]=b//{ TYPE: b, VALUE: c }
    //console.log(util.inspect(b, false, 10, true))
    var d = {};
        d[a] = { TYPE: b, VALUE: c }
    return d
};

Value =  DefinedValue 
        / BuiltinValue;

DefinedValue = ModuleReference? _ a:(a:IDENTIFIER_STRING{ return join(a)} )
{
    return a
};

BuiltinValue = NullValue
             / BooleanValue
             / SpecialRealValue
             / NumberValue
             / BinaryValue
             / HexadecimalValue
             / StringValue
             / BitOrObjectIdentifierValue 

NullValue = "NULL" 

BooleanValue = "TRUE"
             / "FALSE" 

SpecialRealValue = "PLUS-INFINITY"
                 / "MINUS-INFINITY" 

NumberValue = a:"-"? b:NUMBER_STRING 
{ 
    if(a){
        return parseInt( a + join(b) )
    }else{
        return parseInt( join(b) )
    }
    
} ;

BinaryValue = a:BINARY_STRING{ return join(a)} ;

HexadecimalValue = a:HEXADECIMAL_STRING{ return join(a)} ;

StringValue = QUOTED_STRING ;

BitOrObjectIdentifierValue = NameValueList ;

BitValue = NameValueList ;

ObjectIdentifierValue = NameValueList ;

NameValueList = "{" _ a:NameValueComponent* _ "}"
{
    return a
};

NameValueComponent = ","? _ a:NameOrNumber _
{
    return a;
};
//possible fuckery
NameOrNumber = a : (ns:NUMBER_STRING { return parseInt(join(ns)) } )
             // IDENTIFIER_STRING
             /  a :(str:IDENTIFIER_STRING { return join(str) } ) _ 
                b :("(" ns:NUMBER_STRING  ")"{ return parseInt(join(ns)) } / "(" dv:DefinedValue ")" { return dv } )? 
{ 
        //console.log(a,b)
		if(b){
            return [a,b]
        }else{
            return a
        }
}

             // NameAndNumber ;

NameAndNumber = IDENTIFIER_STRING _ "(" NUMBER_STRING ")"
              / IDENTIFIER_STRING _ "(" DefinedValue ")" ;



/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *
 *  Macro Syntax definitions
 *
 */

DefinedMacroType = SnmpModuleIdentityMacroType
                 / SnmpObjectIdentityMacroType
                 / SnmpObjectTypeMacroType
                 / SnmpNotificationTypeMacroType
                 / SnmpTrapTypeMacroType
                 / SnmpTextualConventionMacroType
                 / SnmpObjectGroupMacroType
                 / SnmpNotificationGroupMacroType
                 / SnmpModuleComplianceMacroType
                 / SnmpAgentCapabilitiesMacroType ;

DefinedMacroName = "MODULE-IDENTITY"
                 / "OBJECT-IDENTITY"
                 / "OBJECT-TYPE"
                 / "NOTIFICATION-TYPE"
                 / "TRAP-TYPE"
                 / "TEXTUAL-CONVENTION"
                 / "OBJECT-GROUP"
                 / "NOTIFICATION-GROUP"
                 / "MODULE-COMPLIANCE"
                 / "AGENT-CAPABILITIES" ;

SnmpModuleIdentityMacroType = "MODULE-IDENTITY" _
                              a:SnmpUpdatePart    _
                              b:SnmpOrganizationPart  _
                              c:SnmpContactPart       _
                              d:SnmpDescrPart         _
                              e:SnmpRevisionPart*     _
{
    return { "MODULE-IDENTITY" : [a,b,c,d,e].clean(null,true) }
};

SnmpObjectIdentityMacroType = "OBJECT-IDENTITY" _
                              a:SnmpStatusPart _
                              b:SnmpDescrPart _
                              c:SnmpReferPart? _
{
  return { "OBJECT-IDENTITY":[a,b,c].clean(null,true) } 
};

SnmpObjectTypeMacroType = "OBJECT-TYPE" _
                          a:SnmpSyntaxPart _
                          b:SnmpUnitsPart? _
                          c:SnmpAccessPart _
                          d:SnmpStatusPart _
                          e:SnmpDescrPart? _
                          f:SnmpReferPart? _
                          g:SnmpIndexPart? _
                          h:SnmpDefValPart? _
{
  return { "OBJECT-TYPE" : [a,b,c,d,e,f,g,h].clean(null,true) }
};

SnmpNotificationTypeMacroType = "NOTIFICATION-TYPE" _
                                a:SnmpObjectsPart? _
                                b:SnmpStatusPart _
                                c:SnmpDescrPart _
                                d:SnmpReferPart? _
{
    return { "NOTIFICATION-TYPE" : [a,b,c,d].clean(null,true) }
};

SnmpTrapTypeMacroType = "TRAP-TYPE" _
                        a:SnmpEnterprisePart _
                        b:SnmpVarPart? _
                        c:SnmpDescrPart? _
                        d:SnmpReferPart? _ 
{
    return { "TRAP-TYPE" : [a,b,c,d].clean(null,true)}
};

SnmpTextualConventionMacroType = "TEXTUAL-CONVENTION" _
                                 a:SnmpDisplayPart? _
                                 b:SnmpStatusPart _
                                 c:SnmpDescrPart _
                                 d:SnmpReferPart? _
                                 e:SnmpSyntaxPart _
{
    return { "TEXTUAL-CONVENTION" : [a,b,c,d,e].clean(null,true) }
};

SnmpObjectGroupMacroType = "OBJECT-GROUP" _
                           a:SnmpObjectsPart _
                           b:SnmpStatusPart _
                           c:SnmpDescrPart _
                           d:SnmpReferPart? _ 
{
    return { "OBJECT-GROUP" : [a,b,c,d].clean(null,true) }
};

SnmpNotificationGroupMacroType = "NOTIFICATION-GROUP" _
                                 a:SnmpNotificationsPart _
                                 b:SnmpStatusPart _
                                 c:SnmpDescrPart _
                                 d:SnmpReferPart? _
{
    return { "NOTIFICATION-GROUP" : [a,b,c,d].clean(null,true) }
};

SnmpModuleComplianceMacroType = "MODULE-COMPLIANCE" _
                                a:SnmpStatusPart _
                                b:SnmpDescrPart _
                                c:SnmpReferPart? _
                                d:SnmpModulePart+ _ 
{
    return { "MODULE-COMPLIANCE" : [a,b,c,d].clean(null,true) }
};

SnmpAgentCapabilitiesMacroType = "AGENT-CAPABILITIES" _
                                 a:SnmpProductReleasePart _
                                 b:SnmpStatusPart _
                                 c:SnmpDescrPart _
                                 d:SnmpReferPart? _
                                 e:SnmpModuleSupportPart* _
{
    return { "AGENT-CAPABILITIES" : [a,b,c,d,e].clean(null,true) }
};

SnmpUpdatePart = "LAST-UPDATED" _ a : QUOTED_STRING
{
    return { "LAST-UPDATED" : lineArray(a) }
};

SnmpOrganizationPart = "ORGANIZATION" _ a : QUOTED_STRING
{
    return { "ORGANIZATION" : lineArray(a) }
};

SnmpContactPart = "CONTACT-INFO" _ a : QUOTED_STRING 
{
    return { "CONTACT-INFO" : lineArray(a) }
};

SnmpDescrPart = "DESCRIPTION" _ a : QUOTED_STRING 
{

    return { "DESCRIPTION" : lineArray(a) }
};

SnmpRevisionPart = "REVISION" _ a : Value _
                   "DESCRIPTION" _ b : QUOTED_STRING _
{
   return { "REVISION" : a , "DESCRIPTION" : lineArray(b)}
};

SnmpStatusPart = "STATUS" _ a :(a:IDENTIFIER_STRING { return join(a) } )
{
    return { "STATUS" : a }
};

SnmpReferPart = "REFERENCE" _ a : QUOTED_STRING 
{
    return { "REFERENCE" : lineArray(a) } 
};

SnmpSyntaxPart = "SYNTAX" _ a : Type
{
    return { "SYNTAX" : a }
};

SnmpUnitsPart = "UNITS" _ a : QUOTED_STRING
{
    return { "UNITS" : lineArray(a) }
};

SnmpAccessPart = "ACCESS"     _ a :(a:IDENTIFIER_STRING { return join(a) } ){ return { "ACCESS":a }  }
               / "MAX-ACCESS" _ a :(a:IDENTIFIER_STRING { return join(a) } ){ return { "MAX-ACCESS":a }  }
               / "MIN-ACCESS" _ a :(a:IDENTIFIER_STRING { return join(a) } ){ return { "MIN-ACCESS":a }  } ;

SnmpIndexPart = "INDEX" _ "{" _ a : IndexValueList _ "}"{ return { "INDEX":a }  }
              / "AUGMENTS" _ "{" _ a : Value _ "}"      { return { "AUGMENTS":a }  };

IndexValueList = a : IndexValue _ b:("," _ c:IndexValue { return c })*
{
    return [a].concat(b).clean(null)
};

IndexValue = Value
           / "IMPLIED" _ a:Value { return { "IMPLIED" : a } }
           / IndexType ;

IndexType = IntegerType
          / StringType
          / ObjectIdentifierType ;

SnmpDefValPart = "DEFVAL" _ "{" _ a :Value _ "}"
{
    return { "DEFVAL" : a }
};

SnmpObjectsPart = "OBJECTS" _ "{" _ a :ValueList _ "}"
{
    return { "OBJECTS" : a } 
};

ValueList = a: Value b :("," c :Value { return c } )*
{
    return [a].concat(b).clean(null)
};

SnmpEnterprisePart = "ENTERPRISE" _ a : Value 
{
    return { "ENTERPRISE" : a }
} ;

SnmpVarPart = "VARIABLES" _ "{" _ a : ValueList _ "}"
{
    return { "VARIABLES" : a }
};

SnmpDisplayPart = "DISPLAY-HINT" _ a : QUOTED_STRING 
{
    return { "DISPLAY-HINT" : lineArray(a) } 
};

SnmpNotificationsPart = "NOTIFICATIONS" _ "{" _ a :ValueList _ "}"
{
    return { "NOTIFICATIONS" : a } 
};

SnmpModulePart = "MODULE" _ 
                 a:SnmpModuleImport? _
                 b:SnmpMandatoryPart? _
                 c:SnmpCompliancePart* _
{
    return { "MODULE" : [a,b,c].clean(null) }
};

SnmpModuleImport = !"GROUP" a:ModuleIdentifier
{
    return a;
};

SnmpMandatoryPart = "MANDATORY-GROUPS" _ "{" _ a : ValueList _ "}"
{
    return { "MANDATORY-GROUPS" : a }
};

SnmpCompliancePart = ComplianceGroup
                    / ComplianceObject;

ComplianceGroup = "GROUP" _ 
                  a : Value _
                  b : SnmpDescrPart _ 
{
  return [{ "GROUP" : a  },b].clean(null,true)
  //var g = { "GROUP" : a  }
  //_.merge(g,b)
  //return g
};

ComplianceObject = "OBJECT" _ 
                   a:Value _
                   b:SnmpSyntaxPart? _
                   c:SnmpWriteSyntaxPart? _
                   d:SnmpAccessPart? _
                   e:SnmpDescrPart _
{
   return [ { "OBJECT" : a },b,c,d,e].clean(null,true)
};

SnmpWriteSyntaxPart = "WRITE-SYNTAX" _ a : Type
{
    return { "WRITE-SYNTAX" : a } 
};

SnmpProductReleasePart = "PRODUCT-RELEASE" _ a : QUOTED_STRING
{
    return { "PRODUCT-RELEASE" : lineArray(a) } 
};

SnmpModuleSupportPart = "SUPPORTS" _ 
                        a:SnmpModuleImport _
                        "INCLUDES" _  "{" _ 
                        b:ValueList _ "}" _
                        c:SnmpVariationPart*
{
    return [ { "SUPPORTS" : a } , { "INCLUDES" : b } , c ].clean(null,true)
};

SnmpVariationPart = "VARIATION" _ 
                    a:Value _
                    b:SnmpSyntaxPart? _
                    c:SnmpWriteSyntaxPart? _
                    d:SnmpAccessPart? _
                    e:SnmpCreationPart? _
                    f:SnmpDefValPart? _
                    g:SnmpDescrPart _
{
    return [{ "VARIATION" : a},b,c,d,e,f,g].clean(null,true)
};

SnmpCreationPart = "CREATION-REQUIRES" _ "{" _ ValueList _ "}" _ 
{
    return { "CREATION-REQUIRES" : ValueList }
};


DOT                          = "."
DOUBLE_DOT                   = ".."
TRIPLE_DOT                   = "..."
COMMA                        = ","
SEMI_COLON                   = ";"
LEFT_PAREN                   = "("
RIGHT_PAREN                  = ")"
LEFT_BRACE                   = "{"
RIGHT_BRACE                  = "}"
LEFT_BRACKET                 = "["
RIGHT_BRACKET                = "]"
MINUS                        = "-"
LESS_THAN                    = "<"
VERTICAL_BAR                 = "|"
DEFINITION                   = "::="

DEFINITIONS                  = "DEFINITIONS"
EXPLICIT                     = "EXPLICIT"
IMPLICIT                     = "IMPLICIT"
TAGS                         = "TAGS"
BEGIN                        = "BEGIN"
END                          = "END"
EXPORTS                      = "EXPORTS"
IMPORTS                      = "IMPORTS"
FROM                         = "FROM"
MACRO                        = "MACRO"

INTEGER                      = "INTEGER"
REAL                         = "REAL"
BOOLEAN                      = "BOOLEAN"
NULL                         = "NULL"
BIT                          = "BIT"
OCTET                        = "OCTET"
STRING                       = "STRING"
ENUMERATED                   = "ENUMERATED"
SEQUENCE                     = "SEQUENCE"
SET                          = "SET"
OF                           = "OF"
CHOICE                       = "CHOICE"
UNIVERSAL                    = "UNIVERSAL"
APPLICATION                  = "APPLICATION"
PRIVATE                      = "PRIVATE"
ANY                          = "ANY"
DEFINED                      = "DEFINED"
BY                           = "BY"
OBJECT                       = "OBJECT"
IDENTIFIER                   = "IDENTIFIER"
INCLUDES                     = "INCLUDES"
MIN                          = "MIN"
MAX                          = "MAX"
SIZE                         = "SIZE"
WITH                         = "WITH"
COMPONENT                    = "COMPONENT"
COMPONENTS                   = "COMPONENTS"
PRESENT                      = "PRESENT"
ABSENT                       = "ABSENT"
OPTIONAL                     = "OPTIONAL"
DEFAULT                      = "DEFAULT"
TRUE                         = "TRUE"
FALSE                        = "FALSE"
PLUS_INFINITY                = "PLUS-INFINITY"
MINUS_INFINITY               = "MINUS-INFINITY"

MODULE_IDENTITY              = "MODULE-IDENTITY"
OBJECT_IDENTITY              = "OBJECT-IDENTITY"
OBJECT_TYPE                  = "OBJECT-TYPE"
NOTIFICATION_TYPE            = "NOTIFICATION-TYPE"
TRAP_TYPE                    = "TRAP-TYPE"
TEXTUAL_CONVENTION           = "TEXTUAL-CONVENTION"
OBJECT_GROUP                 = "OBJECT-GROUP"
NOTIFICATION_GROUP           = "NOTIFICATION-GROUP"
MODULE_COMPLIANCE            = "MODULE-COMPLIANCE"
AGENT_CAPABILITIES           = "AGENT-CAPABILITIES"
LAST_UPDATED                 = "LAST-UPDATED"
ORGANIZATION                 = "ORGANIZATION"
CONTACT_INFO                 = "CONTACT-INFO"
DESCRIPTION                  = "DESCRIPTION"
REVISION                     = "REVISION"
STATUS                       = "STATUS"
REFERENCE                    = "REFERENCE"
SYNTAX                       = "SYNTAX"
BITS                         = "BITS"
UNITS                        = "UNITS"
ACCESS                       = "ACCESS"
MAX_ACCESS                   = "MAX-ACCESS"
MIN_ACCESS                   = "MIN-ACCESS"
INDEX                        = "INDEX"
AUGMENTS                     = "AUGMENTS"
IMPLIED                      = "IMPLIED"
DEFVAL                       = "DEFVAL"
OBJECTS                      = "OBJECTS"
ENTERPRISE                   = "ENTERPRISE"
VARIABLES                    = "VARIABLES"
DISPLAY_HINT                 = "DISPLAY-HINT"
NOTIFICATIONS                = "NOTIFICATIONS"
MODULE                       = "MODULE"
MANDATORY_GROUPS             = "MANDATORY-GROUPS"
GROUP                        = "GROUP"
WRITE_SYNTAX                 = "WRITE-SYNTAX"
PRODUCT_RELEASE              = "PRODUCT-RELEASE"
SUPPORTS                     = "SUPPORTS"
VARIATION                    = "VARIATION"
CREATION_REQUIRES            = "CREATION-REQUIRES"

BINARY_STRING                = "'" [0-1]+ "'" ('B'/'b')
HEXADECIMAL_STRING           = "'" [0-9A-Fa-f]+ "'" ('h'/'H')
//HEXADECIMAL_STRING			 = [0-9a-fA-F]+
QUOTED_STRING = '"' quote: NotQuote* '"' { return quote.join("")}
NotQuote = !'"' char: . {return char}
IDENTIFIER_STRING            =!"END" [a-zA-Z][a-zA-Z0-9-_]*
NUMBER_STRING                = [0-9]+

_ "WHITESPACE"               = [ \t\n\r\f\x0b\x17\x18\x19\x1a]*
COMMENT                      = '--([^\n\r-]|-[^\n\r-])*(--|-?[\n\r])'
