//
//  XMLParsable.swift
//  Recipe
//
//  Created by Shing Yien on 28/11/2020.
//

import Foundation

protocol XMLParsable {
    func isSupported(elementName: String) -> Bool
    func parse(elementName: String, attributeDict: [String: String])
    func parse(elementName: String, value: String)
}

class CustomXMLParser: NSObject, XMLParserDelegate {
    var xmlParser: XMLParser?
    var dataParser: XMLParsable?
    var callback: ((XMLParsable) -> Void)?
    var currentElementName: String?
    
    func parseXML(data: Data, dataParser: XMLParsable, callback: @escaping (XMLParsable) -> Void) {
        self.dataParser = dataParser
        self.callback = callback
        self.xmlParser = XMLParser(data: data)
        xmlParser?.delegate = self
        
        xmlParser?.parse()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if let parser = dataParser, parser.isSupported(elementName: elementName) {
            self.currentElementName = elementName
                
            parser.parse(elementName: elementName, attributeDict: attributeDict)
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        self.currentElementName = nil
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if let elementName = self.currentElementName, let parser = dataParser {
            parser.parse(elementName: elementName, value: string)
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        if let callback = self.callback, let parser = dataParser {
            callback(parser)
        }
    }
}
