///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

#import <Foundation/Foundation.h>

#import "DBSHARINGUserMembershipInfo.h"
#import "DBSerializableProtocol.h"

@class DBSEENSTATEPlatformType;
@class DBSHARINGAccessLevel;
@class DBSHARINGMemberPermission;
@class DBSHARINGUserFileMembershipInfo;
@class DBSHARINGUserInfo;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - API Object

///
/// The `UserFileMembershipInfo` struct.
///
/// The information about a user member of the shared content with an appended
/// last seen timestamp.
///
/// This class implements the `DBSerializable` protocol (serialize and
/// deserialize instance methods), which is required for all Obj-C SDK API route
/// objects.
///
@interface DBSHARINGUserFileMembershipInfo : DBSHARINGUserMembershipInfo <DBSerializable, NSCopying>

#pragma mark - Instance fields

/// The UTC timestamp of when the user has last seen the content, if they have.
@property (nonatomic, readonly, nullable) NSDate *timeLastSeen;

/// The platform on which the user has last seen the content, or unknown.
@property (nonatomic, readonly, nullable) DBSEENSTATEPlatformType *platformType;

#pragma mark - Constructors

///
/// Full constructor for the struct (exposes all instance variables).
///
/// @param accessType The access type for this member. It contains inherited
/// access type from parent folder, and acquired access type from this folder.
/// @param user The account information for the membership user.
/// @param permissions The permissions that requesting user has on this member.
/// The set of permissions corresponds to the MemberActions in the request.
/// @param initials Never set.
/// @param isInherited True if the member has access from a parent folder.
/// @param timeLastSeen The UTC timestamp of when the user has last seen the
/// content, if they have.
/// @param platformType The platform on which the user has last seen the
/// content, or unknown.
///
/// @return An initialized instance.
///
- (instancetype)initWithAccessType:(DBSHARINGAccessLevel *)accessType
                              user:(DBSHARINGUserInfo *)user
                       permissions:(nullable NSArray<DBSHARINGMemberPermission *> *)permissions
                          initials:(nullable NSString *)initials
                       isInherited:(nullable NSNumber *)isInherited
                      timeLastSeen:(nullable NSDate *)timeLastSeen
                      platformType:(nullable DBSEENSTATEPlatformType *)platformType;

///
/// Convenience constructor (exposes only non-nullable instance variables with
/// no default value).
///
/// @param accessType The access type for this member. It contains inherited
/// access type from parent folder, and acquired access type from this folder.
/// @param user The account information for the membership user.
///
/// @return An initialized instance.
///
- (instancetype)initWithAccessType:(DBSHARINGAccessLevel *)accessType user:(DBSHARINGUserInfo *)user;

@end

#pragma mark - Serializer Object

///
/// The serialization class for the `UserFileMembershipInfo` struct.
///
@interface DBSHARINGUserFileMembershipInfoSerializer : NSObject

///
/// Serializes `DBSHARINGUserFileMembershipInfo` instances.
///
/// @param instance An instance of the `DBSHARINGUserFileMembershipInfo` API
/// object.
///
/// @return A json-compatible dictionary representation of the
/// `DBSHARINGUserFileMembershipInfo` API object.
///
+ (nullable NSDictionary<NSString *, id> *)serialize:(DBSHARINGUserFileMembershipInfo *)instance;

///
/// Deserializes `DBSHARINGUserFileMembershipInfo` instances.
///
/// @param dict A json-compatible dictionary representation of the
/// `DBSHARINGUserFileMembershipInfo` API object.
///
/// @return An instantiation of the `DBSHARINGUserFileMembershipInfo` object.
///
+ (DBSHARINGUserFileMembershipInfo *)deserialize:(NSDictionary<NSString *, id> *)dict;

@end

NS_ASSUME_NONNULL_END
