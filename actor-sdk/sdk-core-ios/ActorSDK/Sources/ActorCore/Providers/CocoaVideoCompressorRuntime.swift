//
//  CocoaVideoCompressorRuntime.swift
//  ActorSDK
//
//  Created by Diego Ferreira da Silva on 29/01/2018.
//  Copyright © 2018 Steve Kite. All rights reserved.
//

import Foundation

class CocoaVideoCompressorRuntime: NSObject, ARVideoCompressorRuntime {
    
    func compressVideo(_ rid: jlong, withOriginalPath originalPath: String!, withSender sender: ARActorRef!, withCallback progressCallback: ARCompressorProgressListener!) -> ARPromise! {
        let fileName = URL(fileURLWithPath: originalPath).lastPathComponent
        return ARPromise.success(ImActorRuntimeVideoCompressedVideo(rid: rid, withFileName: fileName, withFilePath: originalPath, withSender: sender))
    }
}
