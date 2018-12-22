///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

#import <Foundation/Foundation.h>

#import "DBSerializableProtocol.h"

@class DBTEAMApiApp;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - API Object

///
/// The `ApiApp` struct.
///
/// Information on linked third party applications.
///
/// This class implements the `DBSerializable` protocol (serialize and
/// deserialize instance methods), which is required for all Obj-C SDK API route
/// objects.
///
@interface DBTEAMApiApp : NSObject <DBSerializable, NSCopying>

#pragma mark - Instance fields

/// The application unique id.
@property (nonatomic, readonly, copy) NSString *appId;

/// The application name.
@property (nonatomic, readonly, copy) NSString *appName;

/// The application publisher name.
@property (nonatomic, readonly, copy, nullable) NSString *publisher;

/// The publisher's URL.
@property (nonatomic, readonly, copy, nullable) NSString *publisherUrl;

/// The time this application was linked.
@property (nonatomic, readonly, nullable) NSDate *linked;

/// Whether the linked application uses a dedicated folder.
@property (nonatomic, readonly) NSNumber *isAppFolder;

#pragma mark - Constructors

///
/// Full constructor for the struct (exposes all instance variables).
///
/// @param appId The application unique id.
/// @param appName The application name.
/// @param isAppFolder Whether the linked application uses a dedicated folder.
/// @param publisher The application publisher name.
/// @param publisherUrl The publisher's URL.
/// @param linked The time this application was linked.
///
/// @return An initialized instance.
///
- (instancetype)initWithAppId:(NSString *)appId
                      appName:(NSString *)appName
                  isAppFolder:(NSNumber *)isAppFolder
                    publisher:(nullable NSString *)publisher
                 publisherUrl:(nullable NSString *)publisherUrl
                       linked:(nullable NSDate *)linked;

///
/// Convenience constructor (exposes only non-nullable instance variables with
/// no default value).
///
/// @param appId The application unique id.
/// @param appName The application name.
/// @param isAppFolder Whether the linked application uses a dedicated folder.
///
/// @return An initialized instance.
///
- (instancetype)initWithAppId:(NSString *)appId appName:(NSString *)appName isAppFolder:(NSNumber *)isAppFolder;

- (instancetype)init NS_UNAVAILABLE;

@end

#pragma mark - Serializer Object

///
/// The serialization class for the `ApiApp` struct.
///
@interface DBTEAMApiAppSerializer : NSObject

///
/// Serializes `DBTEAMApiApp` instances.
///
/// @param instance An instance of the `DBTEAMApiApp` API object.
///
/// @return A json-compatible dictionary representation of the `DBTEAMApiApp`
/// API object.
///
+ (nullable NSDictionary<NSString *, id> *)serialize:(DBTEAMApiApp *)instance;

///
/// Deserializes `DBTEAMApiApp` instances.
///
/// @param dict A json-compatible dictionary representation of the
/// `DBTEAMApiApp` API object.
///
/// @return An instantiation of the `DBTEAMApiApp` object.
///
+ (DBTEAMApiApp *)deserialize:(NSDictionary<NSString *, id> *)dict;

@end

NS_ASSUME_NONNULL_END
