//
// AgriShadeNet.swift
//
// This file was automatically generated and should not be edited.
//

import CoreML


/// Model Prediction Input Type
@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *)
class AgriShadeNetInput : MLFeatureProvider {

    /// Input RGB leaf photo (224x224) as color (kCVPixelFormatType_32BGRA) image buffer, 224 pixels wide by 224 pixels high
    var input_leaf: CVPixelBuffer

    var featureNames: Set<String> { ["input_leaf"] }

    func featureValue(for featureName: String) -> MLFeatureValue? {
        if featureName == "input_leaf" {
            return MLFeatureValue(pixelBuffer: input_leaf)
        }
        return nil
    }

    init(input_leaf: CVPixelBuffer) {
        self.input_leaf = input_leaf
    }

    convenience init(input_leafWith input_leaf: CGImage) throws {
        self.init(input_leaf: try MLFeatureValue(cgImage: input_leaf, pixelsWide: 224, pixelsHigh: 224, pixelFormatType: kCVPixelFormatType_32ARGB, options: nil).imageBufferValue!)
    }

    convenience init(input_leafAt input_leaf: URL) throws {
        self.init(input_leaf: try MLFeatureValue(imageAt: input_leaf, pixelsWide: 224, pixelsHigh: 224, pixelFormatType: kCVPixelFormatType_32ARGB, options: nil).imageBufferValue!)
    }

    func setInput_leaf(with input_leaf: CGImage) throws  {
        self.input_leaf = try MLFeatureValue(cgImage: input_leaf, pixelsWide: 224, pixelsHigh: 224, pixelFormatType: kCVPixelFormatType_32ARGB, options: nil).imageBufferValue!
    }

    func setInput_leaf(with input_leaf: URL) throws  {
        self.input_leaf = try MLFeatureValue(imageAt: input_leaf, pixelsWide: 224, pixelsHigh: 224, pixelFormatType: kCVPixelFormatType_32ARGB, options: nil).imageBufferValue!
    }

}


/// Model Prediction Output Type
@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *)
class AgriShadeNetOutput : MLFeatureProvider {

    /// Source provided by CoreML
    private let provider : MLFeatureProvider

    /// classLabel as string value
    var classLabel: String {
        provider.featureValue(for: "classLabel")!.stringValue
    }

    /// classLabel_probs as dictionary of strings to doubles
    var classLabel_probs: [String : Double] {
        provider.featureValue(for: "classLabel_probs")!.dictionaryValue as! [String : Double]
    }

    var featureNames: Set<String> {
        provider.featureNames
    }

    func featureValue(for featureName: String) -> MLFeatureValue? {
        provider.featureValue(for: featureName)
    }

    init(classLabel: String, classLabel_probs: [String : Double]) {
        self.provider = try! MLDictionaryFeatureProvider(dictionary: ["classLabel" : MLFeatureValue(string: classLabel), "classLabel_probs" : MLFeatureValue(dictionary: classLabel_probs as [AnyHashable : NSNumber])])
    }

    init(features: MLFeatureProvider) {
        self.provider = features
    }
}


/// Class for model loading and prediction
@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *)
class AgriShadeNet {
    let model: MLModel

    /// URL of model assuming it was installed in the same bundle as this class
    class var urlOfModelInThisBundle : URL {
        let bundle = Bundle(for: self)
        return bundle.url(forResource: "AgriShadeNet", withExtension:"mlmodelc")!
    }

    /**
        Construct AgriShadeNet instance with an existing MLModel object.

        Usually the application does not use this initializer unless it makes a subclass of AgriShadeNet.
        Such application may want to use `MLModel(contentsOfURL:configuration:)` and `AgriShadeNet.urlOfModelInThisBundle` to create a MLModel object to pass-in.

        - parameters:
          - model: MLModel object
    */
    init(model: MLModel) {
        self.model = model
    }

    /**
        Construct a model with configuration

        - parameters:
           - configuration: the desired model configuration

        - throws: an NSError object that describes the problem
    */
    convenience init(configuration: MLModelConfiguration = MLModelConfiguration()) throws {
        try self.init(contentsOf: type(of:self).urlOfModelInThisBundle, configuration: configuration)
    }

    /**
        Construct AgriShadeNet instance with explicit path to mlmodelc file
        - parameters:
           - modelURL: the file url of the model

        - throws: an NSError object that describes the problem
    */
    convenience init(contentsOf modelURL: URL) throws {
        try self.init(model: MLModel(contentsOf: modelURL))
    }

    /**
        Construct a model with URL of the .mlmodelc directory and configuration

        - parameters:
           - modelURL: the file url of the model
           - configuration: the desired model configuration

        - throws: an NSError object that describes the problem
    */
    convenience init(contentsOf modelURL: URL, configuration: MLModelConfiguration) throws {
        try self.init(model: MLModel(contentsOf: modelURL, configuration: configuration))
    }

    /**
        Construct AgriShadeNet instance asynchronously with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - configuration: the desired model configuration
          - handler: the completion handler to be called when the model loading completes successfully or unsuccessfully
    */
    class func load(configuration: MLModelConfiguration = MLModelConfiguration(), completionHandler handler: @escaping (Swift.Result<AgriShadeNet, Error>) -> Void) {
        load(contentsOf: self.urlOfModelInThisBundle, configuration: configuration, completionHandler: handler)
    }

    /**
        Construct AgriShadeNet instance asynchronously with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - configuration: the desired model configuration
    */
    class func load(configuration: MLModelConfiguration = MLModelConfiguration()) async throws -> AgriShadeNet {
        try await load(contentsOf: self.urlOfModelInThisBundle, configuration: configuration)
    }

    /**
        Construct AgriShadeNet instance asynchronously with URL of the .mlmodelc directory with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - modelURL: the URL to the model
          - configuration: the desired model configuration
          - handler: the completion handler to be called when the model loading completes successfully or unsuccessfully
    */
    class func load(contentsOf modelURL: URL, configuration: MLModelConfiguration = MLModelConfiguration(), completionHandler handler: @escaping (Swift.Result<AgriShadeNet, Error>) -> Void) {
        MLModel.load(contentsOf: modelURL, configuration: configuration) { result in
            switch result {
            case .failure(let error):
                handler(.failure(error))
            case .success(let model):
                handler(.success(AgriShadeNet(model: model)))
            }
        }
    }

    /**
        Construct AgriShadeNet instance asynchronously with URL of the .mlmodelc directory with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - modelURL: the URL to the model
          - configuration: the desired model configuration
    */
    class func load(contentsOf modelURL: URL, configuration: MLModelConfiguration = MLModelConfiguration()) async throws -> AgriShadeNet {
        let model = try await MLModel.load(contentsOf: modelURL, configuration: configuration)
        return AgriShadeNet(model: model)
    }

    /**
        Make a prediction using the structured interface

        It uses the default function if the model has multiple functions.

        - parameters:
           - input: the input to the prediction as AgriShadeNetInput

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as AgriShadeNetOutput
    */
    func prediction(input: AgriShadeNetInput) throws -> AgriShadeNetOutput {
        try prediction(input: input, options: MLPredictionOptions())
    }

    /**
        Make a prediction using the structured interface

        It uses the default function if the model has multiple functions.

        - parameters:
           - input: the input to the prediction as AgriShadeNetInput
           - options: prediction options

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as AgriShadeNetOutput
    */
    func prediction(input: AgriShadeNetInput, options: MLPredictionOptions) throws -> AgriShadeNetOutput {
        let outFeatures = try model.prediction(from: input, options: options)
        return AgriShadeNetOutput(features: outFeatures)
    }

    /**
        Make an asynchronous prediction using the structured interface

        It uses the default function if the model has multiple functions.

        - parameters:
           - input: the input to the prediction as AgriShadeNetInput
           - options: prediction options

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as AgriShadeNetOutput
    */
    @available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
    func prediction(input: AgriShadeNetInput, options: MLPredictionOptions = MLPredictionOptions()) async throws -> AgriShadeNetOutput {
        let outFeatures = try await model.prediction(from: input, options: options)
        return AgriShadeNetOutput(features: outFeatures)
    }

    /**
        Make a prediction using the convenience interface

        It uses the default function if the model has multiple functions.

        - parameters:
            - input_leaf: Input RGB leaf photo (224x224) as color (kCVPixelFormatType_32BGRA) image buffer, 224 pixels wide by 224 pixels high

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as AgriShadeNetOutput
    */
    func prediction(input_leaf: CVPixelBuffer) throws -> AgriShadeNetOutput {
        let input_ = AgriShadeNetInput(input_leaf: input_leaf)
        return try prediction(input: input_)
    }

    /**
        Make a batch prediction using the structured interface

        It uses the default function if the model has multiple functions.

        - parameters:
           - inputs: the inputs to the prediction as [AgriShadeNetInput]
           - options: prediction options

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as [AgriShadeNetOutput]
    */
    func predictions(inputs: [AgriShadeNetInput], options: MLPredictionOptions = MLPredictionOptions()) throws -> [AgriShadeNetOutput] {
        let batchIn = MLArrayBatchProvider(array: inputs)
        let batchOut = try model.predictions(from: batchIn, options: options)
        var results : [AgriShadeNetOutput] = []
        results.reserveCapacity(inputs.count)
        for i in 0..<batchOut.count {
            let outProvider = batchOut.features(at: i)
            let result =  AgriShadeNetOutput(features: outProvider)
            results.append(result)
        }
        return results
    }
}
