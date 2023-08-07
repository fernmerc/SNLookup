//
//  Lookup.swift
//  SN Lookup
//
//  Created by Fernando Mercado on 8/6/23.
//

import Foundation

struct SerialResponse: Decodable {
    let Status: String
    let Version: String
    let Lookup: Dictionary<String, String>
}

func lookupSN(_ link: String, _ sids: String) async throws -> SerialResponse {
    struct SerialRequest: Encodable {
        let Get: String
        let Version: String
        let Sid: Array<String>
    }
    
    //    // Valid SID: 00001af3c8e6, 00001c945661
    //    // Invalid SID: 00012345678
    
    let encoder = JSONEncoder()
    let serialRequest = try encoder.encode(SerialRequest(Get: "Serial", Version: "1.0", Sid: [sids]))
    
    let url = URL(string: link)
    var request = URLRequest(url: url!)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    // make POST request
    let (data, response) = try await URLSession.shared.upload(for: request, from: serialRequest)
    
    if let httpResponse = response as? HTTPURLResponse {
        print("Status Code: \(httpResponse.statusCode)")
        if httpResponse.statusCode != 200 {
            return SerialResponse(Status: "\(httpResponse.statusCode)", Version: "1.0", Lookup: [:])
        }
    }
    print("HTTPURLResponse:",response)
    print("Response body:", String(decoding: data, as: UTF8.self))
    
    return try JSONDecoder().decode(SerialResponse.self, from: data)
}
