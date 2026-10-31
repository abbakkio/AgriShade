//
// AgriShadeNet.h
//
// This file was automatically generated and should not be edited.
//

#import <Foundation/Foundation.h>
#import <CoreML/CoreML.h>
#include <stdint.h>
#include <os/log.h>

NS_ASSUME_NONNULL_BEGIN

/// Model Prediction Input Type
API_AVAILABLE(macos(13.0), ios(16.0), watchos(9.0), tvos(16.0)) __attribute__((visibility("hidden")))
@interface AgriShadeNetInput : NSObject<MLFeatureProvider>

/// Input RGB leaf photo (224x224) as color (kCVPixelFormatType_32BGRA) image buffer, 224 pixels wide by 224 pixels high
@property (readwrite, nonatomic) CVPixelBufferRef input_leaf;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithInput_leaf:(CVPixelBufferRef)input_leaf NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)initWithInput_leafFromCGImage:(CGImageRef)input_leaf error:(NSError * _Nullable __autoreleasing * _Nullable)error;

- (nullable instancetype)initWithInput_leafAtURL:(NSURL *)input_leafURL error:(NSError * _Nullable __autoreleasing * _Nullable)error;

-(BOOL)setInput_leafWithCGImage:(CGImageRef)input_leaf error:(NSError * _Nullable __autoreleasing * _Nullable)error ;
-(BOOL)setInput_leafWithURL:(NSURL *)input_leafURL error:(NSError * _Nullable __autoreleasing * _Nullable)error ;
@end

/// Model Prediction Output Type
API_AVAILABLE(macos(13.0), ios(16.0), watchos(9.0), tvos(16.0)) __attribute__((visibility("hidden")))
@interface AgriShadeNetOutput : NSObject<MLFeatureProvider>

/// classLabel as string value
@property (readwrite, nonatomic, strong) NSString * classLabel;

/// classLabel_probs as dictionary of strings to doubles
@property (readwrite, nonatomic, strong) NSDictionary<NSString *, NSNumber *> * classLabel_probs;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithClassLabel:(NSString *)classLabel classLabel_probs:(NSDictionary<NSString *, NSNumber *> *)classLabel_probs NS_DESIGNATED_INITIALIZER;

@end

/// Class for model loading and prediction
API_AVAILABLE(macos(13.0), ios(16.0), watchos(9.0), tvos(16.0)) __attribute__((visibility("hidden")))
@interface AgriShadeNet : NSObject
@property (readonly, nonatomic, nullable) MLModel * model;

/**
    URL of the underlying .mlmodelc directory.
*/
+ (nullable NSURL *)URLOfModelInThisBundle;

/**
    Initialize AgriShadeNet instance from an existing MLModel object.

    Usually the application does not use this initializer unless it makes a subclass of AgriShadeNet.
    Such application may want to use `-[MLModel initWithContentsOfURL:configuration:error:]` and `+URLOfModelInThisBundle` to create a MLModel object to pass-in.
*/
- (instancetype)initWithMLModel:(MLModel *)model NS_DESIGNATED_INITIALIZER;

/**
    Initialize AgriShadeNet instance with the model in this bundle.
*/
- (nullable instancetype)init;

/**
    Initialize AgriShadeNet instance with the model in this bundle.

    @param configuration The model configuration object
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
*/
- (nullable instancetype)initWithConfiguration:(MLModelConfiguration *)configuration error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/**
    Initialize AgriShadeNet instance from the model URL.

    @param modelURL URL to the .mlmodelc directory for AgriShadeNet.
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
*/
- (nullable instancetype)initWithContentsOfURL:(NSURL *)modelURL error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/**
    Initialize AgriShadeNet instance from the model URL.

    @param modelURL URL to the .mlmodelc directory for AgriShadeNet.
    @param configuration The model configuration object
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
*/
- (nullable instancetype)initWithContentsOfURL:(NSURL *)modelURL configuration:(MLModelConfiguration *)configuration error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/**
    Construct AgriShadeNet instance asynchronously with configuration.
    Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

    @param configuration The model configuration
    @param handler When the model load completes successfully or unsuccessfully, the completion handler is invoked with a valid AgriShadeNet instance or NSError object.
*/
+ (void)loadWithConfiguration:(MLModelConfiguration *)configuration completionHandler:(void (^)(AgriShadeNet * _Nullable model, NSError * _Nullable error))handler;

/**
    Construct AgriShadeNet instance asynchronously with URL of .mlmodelc directory and optional configuration.

    Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

    @param modelURL The model URL.
    @param configuration The model configuration
    @param handler When the model load completes successfully or unsuccessfully, the completion handler is invoked with a valid AgriShadeNet instance or NSError object.
*/
+ (void)loadContentsOfURL:(NSURL *)modelURL configuration:(MLModelConfiguration *)configuration completionHandler:(void (^)(AgriShadeNet * _Nullable model, NSError * _Nullable error))handler;

/**
    Make a prediction using the standard interface
    @param input an instance of AgriShadeNetInput to predict from
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
    @return the prediction as AgriShadeNetOutput
*/
- (nullable AgriShadeNetOutput *)predictionFromFeatures:(AgriShadeNetInput *)input error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/**
    Make a prediction using the standard interface
    @param input an instance of AgriShadeNetInput to predict from
    @param options prediction options
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
    @return the prediction as AgriShadeNetOutput
*/
- (nullable AgriShadeNetOutput *)predictionFromFeatures:(AgriShadeNetInput *)input options:(MLPredictionOptions *)options error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/**
    Make an asynchronous prediction using the standard interface
    @param input an instance of AgriShadeNetInput to predict from
    @param completionHandler a block that will be called upon completion of the prediction. error will be nil if no error occurred.
*/
- (void)predictionFromFeatures:(AgriShadeNetInput *)input completionHandler:(void (^)(AgriShadeNetOutput * _Nullable output, NSError * _Nullable error))completionHandler API_AVAILABLE(macos(14.0), ios(17.0), watchos(10.0), tvos(17.0)) __attribute__((visibility("hidden")));

/**
    Make an asynchronous prediction using the standard interface
    @param input an instance of AgriShadeNetInput to predict from
    @param options prediction options
    @param completionHandler a block that will be called upon completion of the prediction. error will be nil if no error occurred.
*/
- (void)predictionFromFeatures:(AgriShadeNetInput *)input options:(MLPredictionOptions *)options completionHandler:(void (^)(AgriShadeNetOutput * _Nullable output, NSError * _Nullable error))completionHandler API_AVAILABLE(macos(14.0), ios(17.0), watchos(10.0), tvos(17.0)) __attribute__((visibility("hidden")));

/**
    Make a prediction using the convenience interface
    @param input_leaf Input RGB leaf photo (224x224) as color (kCVPixelFormatType_32BGRA) image buffer, 224 pixels wide by 224 pixels high
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
    @return the prediction as AgriShadeNetOutput
*/
- (nullable AgriShadeNetOutput *)predictionFromInput_leaf:(CVPixelBufferRef)input_leaf error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/**
    Batch prediction
    @param inputArray array of AgriShadeNetInput instances to obtain predictions from
    @param options prediction options
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
    @return the predictions as NSArray<AgriShadeNetOutput *>
*/
- (nullable NSArray<AgriShadeNetOutput *> *)predictionsFromInputs:(NSArray<AgriShadeNetInput*> *)inputArray options:(MLPredictionOptions *)options error:(NSError * _Nullable __autoreleasing * _Nullable)error;
@end

NS_ASSUME_NONNULL_END
