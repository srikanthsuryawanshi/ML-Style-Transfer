//
//  MLTrainer.swift
//  MLCustomFilter
//
//  Created by Srikanth SP on 05/09/22.
//

import Foundation
import CoreML
import CreateML
import Combine
import UIKit
import Vision

enum Constants {
    enum Path {
        static let trainingImagesDir = Bundle.main.resourceURL?.appendingPathComponent("TrainingData")
        static let validationImagesDir = Bundle.main.resourceURL?.appendingPathComponent("ValidationData")
        static var documentsDir: URL = {
            return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        }()
        static let sessionDir = documentsDir.appendingPathComponent("Session", isDirectory: true)
        static let modelFileName = "customfilter.mlmodel"
    }
}

struct MLTrainer {
    private static var subscriptions = Set<AnyCancellable>()
    static func trainModel(using styleImage: URL, validationImage: URL, sessionDir: URL, parameters: TrainParameterModel, onCompletion: @escaping (URL?) -> Void) {
        let dataSource = MLStyleTransfer.DataSource.images(
            styleImage: styleImage,
            contentDirectory: Constants.Path.trainingImagesDir ?? Bundle.main.bundleURL,
            processingOption: nil)
        let sessionParams = MLTrainingSessionParameters(
            sessionDirectory: sessionDir,
            reportInterval: parameters.sessionReportInterval,
            checkpointInterval: parameters.sessionCheckpointInterval,
            iterations: parameters.sessionIterations)

        let modelParams = MLStyleTransfer.ModelParameters(
            algorithm: .cnnLite,
            validation: .content(validationImage),
            maxIterations: parameters.maxIterations,
            textelDensity: parameters.textelDensity,
            styleStrength: parameters.styleStrength)
        
        guard let job = try? MLStyleTransfer.train(
            trainingData: dataSource,
            parameters: modelParams,
            sessionParameters: sessionParams) else {
            onCompletion(nil)
            return
        }
        
        let modelPath = sessionDir.appendingPathComponent(Constants.Path.modelFileName)
        job.result.sink(receiveCompletion: { result in
            debugPrint(result)
        }, receiveValue: { model in
            do {
                try model.write(to: modelPath)
                onCompletion(modelPath)
                return
            } catch {
                debugPrint("Error saving ML Model: \(error.localizedDescription)")
            }
            onCompletion(nil)
        })
        .store(in: &subscriptions)
    }
    
    static func predictUsingModel(_ modelPath: URL, inputImage: UIImage, completion: @escaping (UIImage?) -> Void) {
        
        guard
            let compiledModel = try? MLModel.compileModel(at: modelPath),
            let mlModel = try? MLModel.init(contentsOf: compiledModel)
        else {
            debugPrint("Error reading the ML Model")
            return completion(nil)
        }
        
        let imageOptions: [MLFeatureValue.ImageOption: Any] = [
            .cropAndScale: VNImageCropAndScaleOption.centerCrop.rawValue
        ]
        guard
            let cgImage = inputImage.cgImage,
            let imageConstraint = mlModel.modelDescription.inputDescriptionsByName["image"]?.imageConstraint,
            let inputImg = try? MLFeatureValue(cgImage: cgImage, constraint: imageConstraint, options: imageOptions),
            let inputImage = try? MLDictionaryFeatureProvider(dictionary: ["image": inputImg])
        else {
            return completion(nil)
        }
        
        guard
          let stylizedImage = try? mlModel.prediction(from: inputImage),
          let imgBuffer = stylizedImage.featureValue(for: "stylizedImage")?.imageBufferValue
        else {
          return completion(nil)
        }
        let stylizedUIImage = UIImage(withCVImageBuffer: imgBuffer)
        return completion(stylizedUIImage)
    }
}
