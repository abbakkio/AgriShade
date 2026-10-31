//
// AgriShadeNet.m
//
// This file was automatically generated and should not be edited.
//

#if !__has_feature(objc_arc)
#error This file must be compiled with automatic reference counting enabled (-fobjc-arc)
#endif

#import "AgriShadeNet.h"

@implementation AgriShadeNetInput

- (instancetype)initWithInput_leaf:(CVPixelBufferRef)input_leaf {
    self = [super init];
    if (self) {
        _input_leaf = input_leaf;
        CVPixelBufferRetain(_input_leaf);
    }
    return self;
}

- (void)dealloc {
    CVPixelBufferRelease(_input_leaf);
}

- (nullable instancetype)initWithInput_leafFromCGImage:(CGImageRef)input_leaf error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    if (self) {
        NSError *localError;
        BOOL result = YES;
        id retVal = nil;
        @autoreleasepool {
            do {
                MLFeatureValue * __input_leaf = [MLFeatureValue featureValueWithCGImage:input_leaf pixelsWide:224 pixelsHigh:224 pixelFormatType:kCVPixelFormatType_32ARGB options:nil error:&localError];
                if (__input_leaf == nil) {
                    result = NO;
                    break;
                }
                retVal = [self initWithInput_leaf:(CVPixelBufferRef)__input_leaf.imageBufferValue];
            }
            while(0);
        }
        if (error != NULL) {
            *error = localError;
        }
        return result ? retVal : nil;
    }
    return self;
}

- (nullable instancetype)initWithInput_leafAtURL:(NSURL *)input_leafURL error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    if (self) {
        NSError *localError;
        BOOL result = YES;
        id retVal = nil;
        @autoreleasepool {
            do {
                MLFeatureValue * __input_leaf = [MLFeatureValue featureValueWithImageAtURL:input_leafURL pixelsWide:224 pixelsHigh:224 pixelFormatType:kCVPixelFormatType_32ARGB options:nil error:&localError];
                if (__input_leaf == nil) {
                    result = NO;
                    break;
                }
                retVal = [self initWithInput_leaf:(CVPixelBufferRef)__input_leaf.imageBufferValue];
            }
            while(0);
        }
        if (error != NULL) {
            *error = localError;
        }
        return result ? retVal : nil;
    }
    return self;
}

-(BOOL)setInput_leafWithCGImage:(CGImageRef)input_leaf error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    NSError *localError;
    BOOL result = NO;
    @autoreleasepool {
        MLFeatureValue * __input_leaf = [MLFeatureValue featureValueWithCGImage:input_leaf pixelsWide:224 pixelsHigh:224 pixelFormatType:kCVPixelFormatType_32ARGB options:nil error:&localError];
        if (__input_leaf != nil) {
            CVPixelBufferRelease(self.input_leaf);
            self.input_leaf =  (CVPixelBufferRef)__input_leaf.imageBufferValue;
            CVPixelBufferRetain(self.input_leaf);
            result = YES;
        }
    }
    if (error != NULL) {
        *error = localError;
    }
    return result;
}

-(BOOL)setInput_leafWithURL:(NSURL *)input_leafURL error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    NSError *localError;
    BOOL result = NO;
    @autoreleasepool {
        MLFeatureValue * __input_leaf = [MLFeatureValue featureValueWithImageAtURL:input_leafURL pixelsWide:224 pixelsHigh:224 pixelFormatType:kCVPixelFormatType_32ARGB options:nil error:&localError];
        if (__input_leaf != nil) {
            CVPixelBufferRelease(self.input_leaf);
            self.input_leaf =  (CVPixelBufferRef)__input_leaf.imageBufferValue;
            CVPixelBufferRetain(self.input_leaf);
            result = YES;
        }
    }
    if (error != NULL) {
        *error = localError;
    }
    return result;
}

- (NSSet<NSString *> *)featureNames {
    return [NSSet setWithArray:@[@"input_leaf"]];
}

- (nullable MLFeatureValue *)featureValueForName:(NSString *)featureName {
    if ([featureName isEqualToString:@"input_leaf"]) {
        return [MLFeatureValue featureValueWithPixelBuffer:self.input_leaf];
    }
    return nil;
}

@end

@implementation AgriShadeNetOutput

- (instancetype)initWithClassLabel:(NSString *)classLabel classLabel_probs:(NSDictionary<NSString *, NSNumber *> *)classLabel_probs {
    self = [super init];
    if (self) {
        _classLabel = classLabel;
        _classLabel_probs = classLabel_probs;
    }
    return self;
}

- (NSSet<NSString *> *)featureNames {
    return [NSSet setWithArray:@[@"classLabel", @"classLabel_probs"]];
}

- (nullable MLFeatureValue *)featureValueForName:(NSString *)featureName {
    if ([featureName isEqualToString:@"classLabel"]) {
        return [MLFeatureValue featureValueWithString:self.classLabel];
    }
    if ([featureName isEqualToString:@"classLabel_probs"]) {
        return [MLFeatureValue featureValueWithDictionary:self.classLabel_probs error:nil];
    }
    return nil;
}

@end

@implementation AgriShadeNet


/**
    URL of the underlying .mlmodelc directory.
*/
+ (nullable NSURL *)URLOfModelInThisBundle {
    NSString *assetPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"AgriShadeNet" ofType:@"mlmodelc"];
    if (nil == assetPath) { os_log_error(OS_LOG_DEFAULT, "Could not load AgriShadeNet.mlmodelc in the bundle resource"); return nil; }
    return [NSURL fileURLWithPath:assetPath];
}


/**
    Initialize AgriShadeNet instance from an existing MLModel object.

    Usually the application does not use this initializer unless it makes a subclass of AgriShadeNet.
    Such application may want to use `-[MLModel initWithContentsOfURL:configuration:error:]` and `+URLOfModelInThisBundle` to create a MLModel object to pass-in.
*/
- (instancetype)initWithMLModel:(MLModel *)model {
    if (model == nil) {
        return nil;
    }
    self = [super init];
    if (self != nil) {
        _model = model;
    }
    return self;
}


/**
    Initialize AgriShadeNet instance with the model in this bundle.
*/
- (nullable instancetype)init {
    return [self initWithContentsOfURL:(NSURL * _Nonnull)self.class.URLOfModelInThisBundle error:nil];
}


/**
    Initialize AgriShadeNet instance with the model in this bundle.

    @param configuration The model configuration object
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
*/
- (nullable instancetype)initWithConfiguration:(MLModelConfiguration *)configuration error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    return [self initWithContentsOfURL:(NSURL * _Nonnull)self.class.URLOfModelInThisBundle configuration:configuration error:error];
}


/**
    Initialize AgriShadeNet instance from the model URL.

    @param modelURL URL to the .mlmodelc directory for AgriShadeNet.
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
*/
- (nullable instancetype)initWithContentsOfURL:(NSURL *)modelURL error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    MLModel *model = [MLModel modelWithContentsOfURL:modelURL error:error];
    if (model == nil) { return nil; }
    return [self initWithMLModel:model];
}


/**
    Initialize AgriShadeNet instance from the model URL.

    @param modelURL URL to the .mlmodelc directory for AgriShadeNet.
    @param configuration The model configuration object
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
*/
- (nullable instancetype)initWithContentsOfURL:(NSURL *)modelURL configuration:(MLModelConfiguration *)configuration error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    MLModel *model = [MLModel modelWithContentsOfURL:modelURL configuration:configuration error:error];
    if (model == nil) { return nil; }
    return [self initWithMLModel:model];
}


/**
    Construct AgriShadeNet instance asynchronously with configuration.
    Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

    @param configuration The model configuration
    @param handler When the model load completes successfully or unsuccessfully, the completion handler is invoked with a valid AgriShadeNet instance or NSError object.
*/
+ (void)loadWithConfiguration:(MLModelConfiguration *)configuration completionHandler:(void (^)(AgriShadeNet * _Nullable model, NSError * _Nullable error))handler {
    [self loadContentsOfURL:(NSURL * _Nonnull)[self URLOfModelInThisBundle]
              configuration:configuration
          completionHandler:handler];
}


/**
    Construct AgriShadeNet instance asynchronously with URL of .mlmodelc directory and optional configuration.

    Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

    @param modelURL The model URL.
    @param configuration The model configuration
    @param handler When the model load completes successfully or unsuccessfully, the completion handler is invoked with a valid AgriShadeNet instance or NSError object.
*/
+ (void)loadContentsOfURL:(NSURL *)modelURL configuration:(MLModelConfiguration *)configuration completionHandler:(void (^)(AgriShadeNet * _Nullable model, NSError * _Nullable error))handler {
    [MLModel loadContentsOfURL:modelURL
                 configuration:configuration
             completionHandler:^(MLModel *model, NSError *error) {
        if (model != nil) {
            AgriShadeNet *typedModel = [[AgriShadeNet alloc] initWithMLModel:model];
            handler(typedModel, nil);
        } else {
            handler(nil, error);
        }
    }];
}

- (nullable AgriShadeNetOutput *)predictionFromFeatures:(AgriShadeNetInput *)input error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    return [self predictionFromFeatures:input options:[[MLPredictionOptions alloc] init] error:error];
}

- (nullable AgriShadeNetOutput *)predictionFromFeatures:(AgriShadeNetInput *)input options:(MLPredictionOptions *)options error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    id<MLFeatureProvider> outFeatures = [self.model predictionFromFeatures:input options:options error:error];
    if (!outFeatures) { return nil; }
    return [[AgriShadeNetOutput alloc] initWithClassLabel:(NSString *)[outFeatures featureValueForName:@"classLabel"].stringValue classLabel_probs:(NSDictionary<NSString *, NSNumber *> *)[outFeatures featureValueForName:@"classLabel_probs"].dictionaryValue];
}

- (void)predictionFromFeatures:(AgriShadeNetInput *)input completionHandler:(void (^)(AgriShadeNetOutput * _Nullable output, NSError * _Nullable error))completionHandler {
    [self.model predictionFromFeatures:input completionHandler:^(id<MLFeatureProvider> prediction, NSError *predictionError) {
        if (prediction != nil) {
            AgriShadeNetOutput *output = [[AgriShadeNetOutput alloc] initWithClassLabel:(NSString *)[prediction featureValueForName:@"classLabel"].stringValue classLabel_probs:(NSDictionary<NSString *, NSNumber *> *)[prediction featureValueForName:@"classLabel_probs"].dictionaryValue];
            completionHandler(output, predictionError);
        } else {
            completionHandler(nil, predictionError);
        }
    }];
}

- (void)predictionFromFeatures:(AgriShadeNetInput *)input options:(MLPredictionOptions *)options completionHandler:(void (^)(AgriShadeNetOutput * _Nullable output, NSError * _Nullable error))completionHandler {
    [self.model predictionFromFeatures:input options:options completionHandler:^(id<MLFeatureProvider> prediction, NSError *predictionError) {
        if (prediction != nil) {
            AgriShadeNetOutput *output = [[AgriShadeNetOutput alloc] initWithClassLabel:(NSString *)[prediction featureValueForName:@"classLabel"].stringValue classLabel_probs:(NSDictionary<NSString *, NSNumber *> *)[prediction featureValueForName:@"classLabel_probs"].dictionaryValue];
            completionHandler(output, predictionError);
        } else {
            completionHandler(nil, predictionError);
        }
    }];
}

- (nullable AgriShadeNetOutput *)predictionFromInput_leaf:(CVPixelBufferRef)input_leaf error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    AgriShadeNetInput *input_ = [[AgriShadeNetInput alloc] initWithInput_leaf:input_leaf];
    return [self predictionFromFeatures:input_ error:error];
}

- (nullable NSArray<AgriShadeNetOutput *> *)predictionsFromInputs:(NSArray<AgriShadeNetInput*> *)inputArray options:(MLPredictionOptions *)options error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    id<MLBatchProvider> inBatch = [[MLArrayBatchProvider alloc] initWithFeatureProviderArray:inputArray];
    id<MLBatchProvider> outBatch = [self.model predictionsFromBatch:inBatch options:options error:error];
    if (!outBatch) { return nil; }
    NSMutableArray<AgriShadeNetOutput*> *results = [NSMutableArray arrayWithCapacity:(NSUInteger)outBatch.count];
    for (NSInteger i = 0; i < outBatch.count; i++) {
        id<MLFeatureProvider> resultProvider = [outBatch featuresAtIndex:i];
        AgriShadeNetOutput * result = [[AgriShadeNetOutput alloc] initWithClassLabel:(NSString *)[resultProvider featureValueForName:@"classLabel"].stringValue classLabel_probs:(NSDictionary<NSString *, NSNumber *> *)[resultProvider featureValueForName:@"classLabel_probs"].dictionaryValue];
        [results addObject:result];
    }
    return results;
}

@end
