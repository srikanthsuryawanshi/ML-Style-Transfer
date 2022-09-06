//
//  MLFIlter.swift
//  MLCustomFilter
//
//  Created by Srikanth SP on 05/09/22.
//

import Foundation
import UIKit

struct TrainParameterModel {
    var maxIterations: Int = 200
    var textelDensity: Int = 128
    var styleStrength: Int = 5
    var sessionIterations: Int = 100
    var sessionReportInterval: Int = 50
    var sessionCheckpointInterval: Int = 25
}

struct MLFilter {
    static func applyFilter(filterImage: UIImage, selectedImage: UIImage, completion: @escaping (UIImage?) -> Void ) {
        let sessionID = UUID()
        let sessionDir = Constants.Path.sessionDir.appendingPathComponent(sessionID.uuidString, isDirectory: true)
        debugPrint("Starting session in directory: \(sessionDir)")
        
        let selectedImagePath = Constants.Path.documentsDir.appendingPathComponent("selected.jpeg")
        let filterImagePath = Constants.Path.documentsDir.appendingPathComponent("filterImage.jpeg")
        guard
          let imageUrl = selectedImage.saveImage(path: selectedImagePath),
          let filterUrl = filterImage.saveImage(path: filterImagePath)
        else {
          debugPrint("Error Saving the image to disk.")
          return completion(nil)
        }
        
        
        do {
          try FileManager.default.createDirectory(at: sessionDir, withIntermediateDirectories: true)
        } catch {
          debugPrint("Error creating directory: \(error.localizedDescription)")
          return completion(nil)
        }
        
        let modelParams = TrainParameterModel()
        // TRAIN
        MLTrainer.trainModel(using: filterUrl, validationImage: imageUrl, sessionDir: sessionDir, parameters: modelParams) { imagePath in
            guard let imagePath = imagePath else {
              debugPrint("Error creating the ML model.")
              return completion(nil)
            }
         // PREDICT
            MLTrainer.predictUsingModel(imagePath, inputImage: selectedImage) { image in
                completion(image)
            }
        }
    }
}
