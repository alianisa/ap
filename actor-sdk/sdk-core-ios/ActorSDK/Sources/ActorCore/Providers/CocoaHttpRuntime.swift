//
//  Copyright (c) 2014-2016 Actor LLC. <https://actor.im>
//

import Foundation
import Reachability
import Alamofire

open class CocoaHttpRuntime: NSObject, ARHttpRuntime {
    
   let queue1:OperationQueue = OperationQueue()
//    let session:URLSession = URLSession()


//    //: ### Create background queue
    let queue = DispatchQueue.global(qos: .background)
//
//    //: ### Computed variable
//    var time:DispatchTime! {
//        return DispatchTime.now() + 1.0 // seconds
//    }

//    let configuration = URLSessionConfiguration.background(withIdentifier: "com.uzalo.ios.background")
//    let sessionManager = Alamofire.SessionManager(configuration: self.configuration)
    
//    public static func someBackgroundTask(timer:Timer) {
//        DispatchQueue.global(qos: DispatchQoS.background.qosClass).async {
//            print("do some background task")
//
//            DispatchQueue.main.async {
//                print("update some UI")
//            }
//        }
//    }
    
//    var timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
//        timer in
//        CocoaHttpRuntime.someBackgroundTask(timer: timer)
//    }
    
    public func beginBackgroundTask() -> UIBackgroundTaskIdentifier {
        return UIApplication.shared.beginBackgroundTask(expirationHandler: {})
    }
    
    public func endBackgroundTask(taskID: UIBackgroundTaskIdentifier) {
        UIApplication.shared.endBackgroundTask(taskID)
    }
    
    private static var Manager : Alamofire.SessionManager = {
        // Create the server trust policies
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            "https://alo-cdn1.messenger.uz": .disableEvaluation
        ]
        // Create custom manager
        //let configuration = URLSessionConfiguration.default
        let configuration = URLSessionConfiguration.background(withIdentifier: "com.uzalo.ios.background")
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        let man = Alamofire.SessionManager(
            configuration: URLSessionConfiguration.default,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
        return man
    }()

//    private let queue = DispatchQueue.global(qos: .utility)
    deinit {
        Alamofire.SessionManager.default.session.finishTasksAndInvalidate()
    }
    

    
    public func getMethodWithUrl(_ url: String!, withStartOffset startOffset: jint, withSize size: jint, withTotalSize totalSize: jint) -> ARPromise! {

        return ARPromise { (resolver) in

            let header = "bytes=\(startOffset)-\(min(startOffset + size, totalSize))"
            let request = NSMutableURLRequest(url: URL(string: url)!)
            request.httpShouldHandleCookies = false
            request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
            request.setValue(header, forHTTPHeaderField: "Range")
            request.httpMethod = "GET"

            //            timer.timeInterval(1)
            self.download(request: request as URLRequest, completionHandler:{ (data: Data?, response: HTTPURLResponse?) -> Void in
                if let respHttp = response {
                    if (respHttp.statusCode >= 200 && respHttp.statusCode < 300) {

                        resolver.result(ARHTTPResponse(code: jint(respHttp.statusCode), withContent: data!.toJavaBytes()))
                    } else {
                        resolver.error(ARHTTPError(int: jint(respHttp.statusCode)))
                    }
                } else {
                    resolver.error(ARHTTPError(int: 0))
                }
            })

        }
    }
    
//    public func getMethodWithUrl(_ url: String!, withStartOffset startOffset: jint, withSize size: jint, withTotalSize totalSize: jint) -> ARPromise! {
//        
//        return ARPromise { (resolver) in
//            
//            let header = "bytes=\(startOffset)-\(min(startOffset + size, totalSize))"
//            let request = NSMutableURLRequest(url: URL(string: url)!)
//            request.httpShouldHandleCookies = false
//            request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
//            request.setValue(header, forHTTPHeaderField: "Range")
//            request.httpMethod = "GET"
//            
//            NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: self.queue1, completionHandler:{ (response: URLResponse?, data: Data?, error: Error?) -> Void in
//                if let respHttp = response as? HTTPURLResponse {
//                    if (respHttp.statusCode >= 200 && respHttp.statusCode < 300) {
//                        resolver.result(ARHTTPResponse(code: jint(respHttp.statusCode), withContent: data!.toJavaBytes()))
//                    } else {
//                        resolver.error(ARHTTPError(int: jint(respHttp.statusCode)))
//                    }
//                } else {
//                    resolver.error(ARHTTPError(int: 0))
//                }
//            })
//        }
//    }
    
    public func putMethod(withUrl url: String!, withContents contents: IOSByteArray!) -> ARPromise! {
        return ARPromise { (resolver) in
            let request = NSMutableURLRequest(url: URL(string: url)!)
            request.httpShouldHandleCookies = false
            request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
            request.httpMethod = "PUT"
            request.httpBody = contents.toNSData()
            request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
            
            self.download(request: request as URLRequest, completionHandler:{ (data: Data?, response: HTTPURLResponse?) -> Void in
                if let respHttp = response {
                    if (respHttp.statusCode >= 200 && respHttp.statusCode < 300) {
                        
                        resolver.result(ARHTTPResponse(code: jint(respHttp.statusCode), withContent: nil))
                    } else {
                        resolver.error(ARHTTPError(int: jint(respHttp.statusCode)))
                    }
                } else {
                    resolver.error(ARHTTPError(int: 0))
                }
            })

        }
    }

    func download(request: URLRequest, completionHandler: @escaping (Data?, HTTPURLResponse?) -> Void) {
        
        CocoaHttpRuntime.Manager.request(request)
            .validate()
            .responseData(queue: self.queue)  { response in

                let statusCode = response.response
                if let data = response.result.value {
                    DispatchQueue.main.async {
                        completionHandler(data, statusCode)
                        log("data: \(data)")
                    }
                    
                } else {

                }

        }
    }
}


