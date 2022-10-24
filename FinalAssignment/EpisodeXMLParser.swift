//
//  EpisodeXMLParser.swift
//  FinalAssignment
//
//  Created by user169705 on 6/2/20.
//  Copyright © 2020 Yansong Li. All rights reserved.
//

import Foundation
import UIKit

protocol EpisodeParserDelegate {
 func onFinishedParse(episodes: [Episode])
}
class EpisodeXMLDecoder: NSObject, XMLParserDelegate {
 let ROOT_ELEMENT = "channel"
 let EPISODE_ELEMENT = "item"
 let EPISODE_TITLE_ELEMENT = "title"
 let EPISODE_ENCLOSURE_ELEMENT="enclosure"
 let EPISODE_DESCRIPTION_ELEMENT = "description"
 let EPISODE_DURATION_ELEMENT = "duration"

 var parser: XMLParser?
 var episodes: [Episode] = []
 var currentElement: String?
 var tempEpisode = Episode()
 var tempEnclosure = Enclosure()
 var listener: EpisodeParserDelegate?
    
    func parseEpisodeXMLWithURL(url: String, listener: EpisodeParserDelegate) {
 self.listener = listener

 let xmlURL = URL(string: url.addingPercentEncoding(withAllowedCharacters:
 .urlQueryAllowed)!)
        print(url)
        
        let task = URLSession.shared.dataTask(with: xmlURL!) { (data, response,
 error) in
 if let _ = error {
 print("Error: \(String(describing: error?.localizedDescription))")
 return
 }
self.parser = XMLParser(data: data!)
 self.parser?.delegate = self
 self.parser?.parse()
 }
 task.resume()
 }

 func parser(_ parser: XMLParser, didStartElement elementName: String,
 namespaceURI: String?, qualifiedName qName: String?, attributes
 attributeDict: [String : String] = [:]) {

 currentElement = elementName

 // New book has been started so create a temp book
 if(elementName == EPISODE_ELEMENT) {
 tempEpisode = Episode()
 }
 if(elementName == EPISODE_ENCLOSURE_ELEMENT) {
    tempEnclosure=Enclosure()
    if let url = attributeDict["url"]{
        tempEnclosure.url=url
    }
    if let length = attributeDict["length"]{
        tempEnclosure.length=length
    }
    tempEpisode.enclosure=tempEnclosure
    }
    }
 func parser(_ parser: XMLParser, foundCharacters string: String) {

 let data = string.trimmingCharacters(in:
 CharacterSet.whitespacesAndNewlines)

 if(data.isEmpty) {
 return
 }

 switch currentElement {
 
 case EPISODE_TITLE_ELEMENT:
 tempEpisode.episodeTitle = data
 //print(data)

 case EPISODE_DESCRIPTION_ELEMENT:
 tempEpisode.episodeDescription = data
 //print(data)
case EPISODE_DURATION_ELEMENT:
tempEpisode.duration = data
    print(data)
 default:
 return
 }
 }

 func parser(_ parser: XMLParser, didEndElement elementName: String,
 namespaceURI: String?, qualifiedName qName: String?) {

 // Book has finished so save it
 if(elementName == EPISODE_ELEMENT) {
 episodes.append(tempEpisode)
}
 }

 func parserDidEndDocument(_ parser: XMLParser) {
 listener?.onFinishedParse(episodes: episodes)
 }
}
