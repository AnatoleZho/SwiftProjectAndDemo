//
//  NetworkRequest.swift
//  UnicomWoHome
//
//  Created by EastElsoft on 2017/11/30.
//  Copyright © 2017年 EastElsoft. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

/* 为闭包声明别名 */
typealias Success = (_ response: JSON) -> ()
typealias Failure = (_ error: Error) -> ()

enum RequestMethod {
    case get
    case post
}

final class NetworkRequest: NSObject {

    static let shareNetworkRequest = NetworkRequest();
    
    // MARK: 获取请求方式
    func getRequestMethod(method: RequestMethod) -> HTTPMethod {
        switch method {
        case .post:
            return HTTPMethod.post
        default:
            return HTTPMethod.get
        }
    }
    
    // MARK: 发起网络请求

    ///   使用 Alamofire 向网络发起 get 请求
    ///
    ///   - Parameters:
    ///   - urlStr: url字符串
    ///   - params: 请求参数
    ///   - success: 返回成功结果
    ///   - failture: 返回失败结果
   public class func getRequest(urlStr:String, params:[String: Any]?, success: @escaping (Success), failure: @escaping (Failure)) {
        let method = shareNetworkRequest.getRequestMethod(method: .get)
    shareNetworkRequest.request(urlStr: urlStr, params: params!, method: method, success: success, failure: failure)
     
    }
    
    
    ///   使用 Alamofire 向网络发起 post 请求
    ///
    ///   - Parameters:
    ///   - urlStr: url字符串
    ///   - params: 请求参数
    ///   - success: 返回成功结果
    ///   - failture: 返回失败结果
  public class func postRequest(urlStr:String, params:[String: Any], success: @escaping (Success), failure: @escaping (Failure)) {
        let method = shareNetworkRequest.getRequestMethod(method: .post)
        shareNetworkRequest.request(urlStr:urlStr, params: params, method: method, success: success, failure: failure)

    }
    
    // MARK: 图片上传
    func upLoadImageRequest(urlString : String, params:[String:String], data: [Data], name: [String],success : @escaping (Success), failture : @escaping (Failure)){
        
        let headers = ["content-type":"multipart/form-data"]
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                //666多张图片上传
                let flag = params["flag"]
                let userId = params["userId"]
                
                multipartFormData.append((flag?.data(using: String.Encoding.utf8)!)!, withName: "flag")
                multipartFormData.append( (userId?.data(using: String.Encoding.utf8)!)!, withName: "userId")
                
                for i in 0..<data.count {
                    multipartFormData.append(data[i], withName: "appPhoto", fileName: name[i], mimeType: "image/png")
                }
        },
            to: urlString,
            headers: headers,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        if let value = response.result.value as? [String: AnyObject]{
                            let json = JSON(value)
                            success(json)
                            print(json)
                        }
                    }
                case .failure(let encodingError):
                    print(encodingError)
                    failture(encodingError)
                }
            }
        )
    }
    
    ///   使用 Alamofire 向网络发起请求
    ///
    ///   - Parameters:
    ///   - urlStr: url字符串
    ///   - params: 请求参数
    ///   - success: 返回成功结果
    ///   - failture: 返回失败结果
    func request(urlStr:String, params:[String: Any]?, method:HTTPMethod, success: @escaping (Success), failure: @escaping (Failure)) {
        
        let headers: HTTPHeaders = [
            "Accept": "application/json",
            //            "Accept": "text/javascript",
            //            "Accept": "text/html",
            //            "Accept": "text/plain"
        ]
        
        print("URLString ======\n", urlStr)
        print("RequestParams======\n", params ?? [:])
        
        
        Alamofire.request(urlStr, method: method, parameters:params, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success( _):
                //当响应成功是，使用临时变量value接受服务器返回的信息并判断是否为[String: AnyObject]类型 如果是那么将其传给其定义方法中的success
                if let value = response.result.value as? [String: AnyObject] {
                    let json = JSON(value)
    
                    success(json )
                    print("json ======\n", json)
                }
                break
                
            case .failure(let error):
                failure(error)
                print("error ======\n", error)
            }
        }
    }
    
    
    //MARK:https证书验证
    func verificationCertificate() -> Void {
        
        let manager = SessionManager.default
        
        manager.delegate.sessionDidReceiveChallenge = { session, challenge in
            
            var disposition: URLSession.AuthChallengeDisposition = .performDefaultHandling
            var credential: URLCredential?
            
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                
                disposition = URLSession.AuthChallengeDisposition.useCredential
                credential = URLCredential.init(trust: challenge.protectionSpace.serverTrust!)
                
            } else {
                if challenge.previousFailureCount > 0 {
                    
                    disposition = .cancelAuthenticationChallenge
                    
                } else {
                    
                    credential = manager.session.configuration.urlCredentialStorage?.defaultCredential(for: challenge.protectionSpace)
                    
                    if credential != nil {
                        disposition = .useCredential
                    }
                }
            }
            
            return (disposition, credential)
        }
        
    }
    
}
