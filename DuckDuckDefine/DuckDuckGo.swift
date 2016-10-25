/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import Foundation
import Alamofire
import SwiftyJSON


struct Definition {
  let title: String
  let description: String
  let imageURL: NSURL?
}

class DuckDuckGo {
  
  enum ResultType: String {
    case Answer = "A"
    case Exclusive = "E"    // Exclusive results include special cases like calculations

    func parseDefinitionFromJSON(json: JSON) -> Definition {
        switch self {
        case .Answer:
            let heading = json["Heading"].stringValue
            let abstract = json["AbstractText"].stringValue
            let imageURL = NSURL(string: json["Image"].stringValue)
            
            return Definition(title: heading, description: abstract, imageURL: imageURL)
        case .Exclusive:
            let answer = json["Answer"].stringValue
            
            return Definition(title: "Answer", description: answer, imageURL: nil)
        }
    }
    
    }
//  func performSearch(_ searchTerm: String, completion: ((_ definition: Definition?) -> Void)) {
//    completion(nil)
//  }
    
    func performSearch(searchTerm: String, completion: @escaping ((_: Definition?) -> Void)) {
        // 1
        let parameters: [String:Any] = ["q": searchTerm, "format": "json", "pretty": 1,
                                              "no_html": 1, "skip_disambig": 1]
        
        // 2
        Alamofire.request("https://api.duckduckgo.com", parameters: parameters).responseJSON { response in
            switch response.result{
            case .failure( _):            // 3
                completion(nil)
            case .success( _):
                let  json = JSON(response.result.value)
                // 5
                if let jsonType = json["Type"].string, let resultType = ResultType(rawValue: jsonType) {
                    
                    // 6
                    let definition = resultType.parseDefinitionFromJSON(json: json)
                    completion( definition)
                }
            }
            
                   }
    }
}
