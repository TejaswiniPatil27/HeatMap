//
//  CommonData.swift
//  HeatMap
//
//  Created by Tejaswini Kotagi on 19/07/22.
//

import Foundation

enum ApplicationEnvironment: String {
    case development
    case uat
    case production
    case live
    case local
}
enum ErrorMessage {
    static let connectionError = "Could not connect to server"
    static let invalidResponse = "Something went wrong. Please try again later."
}

class CommonData: NSObject, URLSessionDelegate {
    static let sharedInstance = CommonData()
    let baseURL : String!
    let currentApplicationEnvironment: ApplicationEnvironment!
    
//   private override init() {
//        self.currentApplicationEnvironment = ApplicationEnvironment.live
//        switch self.currentApplicationEnvironment {
//        case .development:
//            self.baseUrl = ""
//        case .uat:
//            self.baseUrl = ""
//        case .production:
//            self.baseUrl = ""
//        case .live:
//            self.baseUrl = ""
//        case .local:
//            self.baseUrl = ""
//        default:
//            print("None URL")
//        }
//        super.init()
//    }
    
    //MARK: - Initializer
    private override init() {
        self.currentApplicationEnvironment = ApplicationEnvironment.live
        switch self.currentApplicationEnvironment {
        case .development?:
            print("\(#function) Development")
            self.baseURL = ""
        case .uat?:
            print("\(#function) UAT")
            self.baseURL = ""
        case .live?:
            print("\(#function) Live")
            self.baseURL = ""
        case .production?:
            print("\(#function) Production")
            self.baseURL = ""
        case .local:
            print("\(#function) Local")
            self.baseURL = ""
        default:
            print("\(#function) Default (Development)")
            self.baseURL = ""
        }
        super.init()
        
    }
    var sharedSession: URLSession {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60
        config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        config.httpAdditionalHeaders = ["Cache-Control" : "no-cache"]
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }
    
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    func getHTTPBodyFromDict(_ dict: Any, boundary: String, token: String) -> Data {
        do {
//            let paramJSON = CommonData.getStringFromData(try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions.init(rawValue: 0)))
//            let paramDict = ["data" : paramJSON]

            let paramDict = dict

            print("\(CommonData.getStringFromData(try JSONSerialization.data(withJSONObject: paramDict, options: JSONSerialization.WritingOptions.init(rawValue: 0))))")

//            return createBodyWithParameters(parameters: ["data" : CommonData.getStringFromData(try JSONSerialization.data(withJSONObject: paramDict, options: JSONSerialization.WritingOptions.init(rawValue: 0))).encryptedString()], filePathKey: nil, imageDataKey: nil, boundary: boundary)

            return "data=\(CommonData.getStringFromData(try JSONSerialization.data(withJSONObject: paramDict, options: JSONSerialization.WritingOptions.init(rawValue: 0))))".data(using: .utf8) ?? Data()
        } catch {
            return Data()
        }
    }
    
    static func getStringFromData(_ data: Data?) -> String {
        guard let validData = data else { return "" }
        return String(data: validData, encoding: String.Encoding.utf8) ?? ""
    }

    static func getJSONForObject(_ object: Any) -> String {
        do {
            let data = try JSONSerialization.data(withJSONObject: object, options: .init(rawValue: 0))
            return CommonData.getStringFromData(data)
        } catch {
            return ""
        }
    }
    
    func getJsonData( completionBlock: @escaping(_ isSuccess: Bool, _ responseString: String,_ otp: String) -> ()) {
        guard let url = URL(string: "   ") else {
            completionBlock(false, "Invalid URL", "")
            return
        }
        print("getOTPForMobileNo--->\(#function)---\(url)")
//        CommonData.addLoader()
//        CustomLoader.instance.showLoaderView()
        let paramDict = ["" : ""] as [String: Any]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = generateBoundaryString()
        request.addValue("application/x-www-form-urlencoded",
                         forHTTPHeaderField: "Content-Type")

        let token = "\(Int(Date().timeIntervalSince1970))"
        request.httpBody = getHTTPBodyFromDict(paramDict, boundary: boundary, token: token)

        print("\(#function) : body : \(CommonData.getStringFromData(request.httpBody))")

        let dataTask = sharedSession.dataTask(with: request) { (responseData, urlResponse, error) in
            
            if error == nil {
                let data = responseData
                print("data---\(String(describing: data))")
                if  let responseDict = try? JSONSerialization.jsonObject(with: data! , options: .init(rawValue: 0)) as? [String : Any] {
//                    if let status = responseDict["Status"]as? String, status.lowercased() == "true" {
                        DispatchQueue.main.async {
                            print("responseDict\(String(describing: responseDict))")
                            completionBlock(true, responseDict["Message"] as? String ??  "OTP Generated", responseDict["otp"] as? String ?? "")
                        }
//                    }
//                    else {
//                        print("\(#function) : error : \(responseDict["Message"] ?? "NA")")
//                        DispatchQueue.main.async {
//                            completionBlock(false, responseDict["Message"] as? String ?? "Error", "" )
//                        }
//                    }
                } else {
                    print("\(#function) : error--\(String(describing: error?.localizedDescription))")
                    DispatchQueue.main.async {
                        completionBlock(false, String(describing: error?.localizedDescription) , "")
                    }
                }
            } else {
                print("\(#function) : error--- \(error?.localizedDescription ?? "N/A")")
                DispatchQueue.main.async {
                    completionBlock(false, ErrorMessage.connectionError, "")
                }
            }

//            CommonData.removeLoader()
//            CustomLoader.instance.hideLoaderView()
        }
        dataTask.resume()
    }
}
