///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

#import <Foundation/Foundation.h>

#import "DBSerializableProtocol.h"

@class DBTEAMGroupAccessType;
@class DBTEAMMemberAccess;
@class DBTEAMUserSelectorArg;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - API Object

///
/// The `MemberAccess` struct.
///
/// Specify access type a member should have when joined to a group.
///
/// This class implements the `DBSerializable` protocol (serialize and
/// deserialize instance methods), which is required for all Obj-C SDK API route
/// objects.
///
@interface DBTEAMMemberAccess : NSObject <DBSerializable, NSCopying>

#pragma mark - Instance fields

/// Identity of a user.
@property (nonatomic, readonly) DBTEAMUserSelectorArg *user;

/// Access type.
@property (nonatomic, readonly) DBTEAMGroupAccessType *accessType;

#pragma mark - Constructors

///
/// Full constructor for the struct (exposes all instance variables).
///
/// @param user Identity of a user.
/// @param accessType Access type.
///
/// @return An initialized instance.
///
- (instancetype)initWithUser:(DBTEAMUserSelectorArg *)user accessType:(DBTEAMGroupAccessType *)accessType;

- (instancetype)init NS_UNAVAILABLE;

@end

#pragma mark - Serializer Object

///
/// The serialization class for the `MemberAccess` struct.
///
@interface DBTEAMMemberAccessSerializer : NSObject

///
/// Serializes `DBTEAMMemberAccess` instances.
///
/// @param instance An instance of the `DBTEAMMemberAccess` API object.
///
/// @return A json-compatible dictionary representation of the
/// `DBTEAMMemberAccess` API object.
///
+ (nullable NSDictionary<NSString *, id> *)serialize:(DBTEAMMemberAccess *)instance;

///
/// Deserializes `DBTEAMMemberAccess` instances.
///
/// @param dict A json-compatible dictionary representation of the
/// `DBTEAMMemberAccess` API object.
///
/// @return An instantiation of the `DBTEAMMemberAccess` object.
///
+ (DBTEAMMemberAccess *)deserialize:(NSDictionary<NSString *, id> *)dict;

@end

NS_ASSUME_NONNULL_END
