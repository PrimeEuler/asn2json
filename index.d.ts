// Type definitions for asn2json 0.0.2
declare module 'asn2json';

declare class asn2json {
    /**
     * Parse to Json a MIB File Content
     * @param input MIB File Content
     * @returns Object with all MIB definitions 
     */
    public parse(input: string | Buffer): any;
}

export default asn2json;