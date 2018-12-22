///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

#import <Foundation/Foundation.h>

#import "DBSerializableProtocol.h"

@class DBTEAMMemberAddResult;
@class DBTEAMMembersAddJobStatus;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - API Object

///
/// The `MembersAddJobStatus` union.
///
/// This class implements the `DBSerializable` protocol (serialize and
/// deserialize instance methods), which is required for all Obj-C SDK API route
/// objects.
///
@interface DBTEAMMembersAddJobStatus : NSObject <DBSerializable, NSCopying>

#pragma mark - Instance fields

/// The `DBTEAMMembersAddJobStatusTag` enum type represents the possible tag
/// states with which the `DBTEAMMembersAddJobStatus` union can exist.
typedef NS_ENUM(NSInteger, DBTEAMMembersAddJobStatusTag) {
  /// The asynchronous job is still in progress.
  DBTEAMMembersAddJobStatusInProgress,

  /// The asynchronous job has finished. For each member that was specified in
  /// the parameter MembersAddArg that was provided to `membersAdd`, a
  /// corresponding item is returned in this list.
  DBTEAMMembersAddJobStatusComplete,

  /// The asynchronous job returned an error. The string contains an error
  /// message.
  DBTEAMMembersAddJobStatusFailed,

};

/// Represents the union's current tag state.
@property (nonatomic, readonly) DBTEAMMembersAddJobStatusTag tag;

/// The asynchronous job has finished. For each member that was specified in the
/// parameter MembersAddArg that was provided to `membersAdd`, a corresponding
/// item is returned in this list. @note Ensure the `isComplete` method returns
/// true before accessing, otherwise a runtime exception will be raised.
@property (nonatomic, readonly) NSArray<DBTEAMMemberAddResult *> *complete;

/// The asynchronous job returned an error. The string contains an error
/// message. @note Ensure the `isFailed` method returns true before accessing,
/// otherwise a runtime exception will be raised.
@property (nonatomic, readonly, copy) NSString *failed;

#pragma mark - Constructors

///
/// Initializes union class with tag state of "in_progress".
///
/// Description of the "in_progress" tag state: The asynchronous job is still in
/// progress.
///
/// @return An initialized instance.
///
- (instancetype)initWithInProgress;

///
/// Initializes union class with tag state of "complete".
///
/// Description of the "complete" tag state: The asynchronous job has finished.
/// For each member that was specified in the parameter MembersAddArg that was
/// provided to `membersAdd`, a corresponding item is returned in this list.
///
/// @param complete The asynchronous job has finished. For each member that was
/// specified in the parameter MembersAddArg that was provided to `membersAdd`,
/// a corresponding item is returned in this list.
///
/// @return An initialized instance.
///
- (instancetype)initWithComplete:(NSArray<DBTEAMMemberAddResult *> *)complete;

///
/// Initializes union class with tag state of "failed".
///
/// Description of the "failed" tag state: The asynchronous job returned an
/// error. The string contains an error message.
///
/// @param failed The asynchronous job returned an error. The string contains an
/// error message.
///
/// @return An initialized instance.
///
- (instancetype)initWithFailed:(NSString *)failed;

- (instancetype)init NS_UNAVAILABLE;

#pragma mark - Tag state methods

///
/// Retrieves whether the union's current tag state has value "in_progress".
///
/// @return Whether the union's current tag state has value "in_progress".
///
- (BOOL)isInProgress;

///
/// Retrieves whether the union's current tag state has value "complete".
///
/// @note Call this method and ensure it returns true before accessing the
/// `complete` property, otherwise a runtime exception will be thrown.
///
/// @return Whether the union's current tag state has value "complete".
///
- (BOOL)isComplete;

///
/// Retrieves whether the union's current tag state has value "failed".
///
/// @note Call this method and ensure it returns true before accessing the
/// `failed` property, otherwise a runtime exception will be thrown.
///
/// @return Whether the union's current tag state has value "failed".
///
- (BOOL)isFailed;

///
/// Retrieves string value of union's current tag state.
///
/// @return A human-readable string representing the union's current tag state.
///
- (NSString *)tagName;

@end

#pragma mark - Serializer Object

///
/// The serialization class for the `DBTEAMMembersAddJobStatus` union.
///
@interface DBTEAMMembersAddJobStatusSerializer : NSObject

///
/// Serializes `DBTEAMMembersAddJobStatus` instances.
///
/// @param instance An instance of the `DBTEAMMembersAddJobStatus` API object.
///
/// @return A json-compatible dictionary representation of the
/// `DBTEAMMembersAddJobStatus` API object.
///
+ (nullable NSDictionary<NSString *, id> *)serialize:(DBTEAMMembersAddJobStatus *)instance;

///
/// Deserializes `DBTEAMMembersAddJobStatus` instances.
///
/// @param dict A json-compatible dictionary representation of the
/// `DBTEAMMembersAddJobStatus` API object.
///
/// @return An instantiation of the `DBTEAMMembersAddJobStatus` object.
///
+ (DBTEAMMembersAddJobStatus *)deserialize:(NSDictionary<NSString *, id> *)dict;

@end

NS_ASSUME_NONNULL_END
