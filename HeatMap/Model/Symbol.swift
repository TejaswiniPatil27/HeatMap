//
//  Symbol.swift
//  HeatMap
//
//  Created by Tejaswini Kotagi on 20/07/22.
//

import Foundation

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let symbol = try Symbol(json)

//
// To read values from URLs:
//
//   let task = URLSession.shared.symbolTask(with: url) { symbol, response, error in
//     if let symbol = symbol {
//       ...
//     }
//   }
//   task.resume()

import Foundation

// MARK: - Symbol
struct Symbol: Codable {
    let l, lu, s, sc: String
}

// MARK: Symbol convenience initializers and mutators

extension Symbol {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Symbol.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        l: String? = nil,
        lu: String? = nil,
        s: String? = nil,
        sc: String? = nil
    ) -> Symbol {
        return Symbol(
            l: l ?? self.l,
            lu: lu ?? self.lu,
            s: s ?? self.s,
            sc: sc ?? self.sc
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Helper functions for creating encoders and decoders

func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}

// MARK: - URLSession response handlers

extension URLSession {
    fileprivate func codableTask<T: Codable>(with url: URL, completionHandler: @escaping (T?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return self.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completionHandler(nil, response, error)
                return
            }
            completionHandler(try? newJSONDecoder().decode(T.self, from: data), response, nil)
        }
    }

    func symbolTask(with url: URL, completionHandler: @escaping (Symbol?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return self.codableTask(with: url, completionHandler: completionHandler)
    }
}
