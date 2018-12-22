///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

#import <Foundation/Foundation.h>

#import "DBSerializableProtocol.h"

@class DBFILEPROPERTIESPropertiesSearchMode;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - API Object

///
/// The `PropertiesSearchMode` union.
///
/// This class implements the `DBSerializable` protocol (serialize and
/// deserialize instance methods), which is required for all Obj-C SDK API route
/// objects.
///
@interface DBFILEPROPERTIESPropertiesSearchMode : NSObject <DBSerializable, NSCopying>

#pragma mark - Instance fields

/// The `DBFILEPROPERTIESPropertiesSearchModeTag` enum type represents the
/// possible tag states with which the `DBFILEPROPERTIESPropertiesSearchMode`
/// union can exist.
typedef NS_ENUM(NSInteger, DBFILEPROPERTIESPropertiesSearchModeTag) {
  /// Search for a value associated with this field name.
  DBFILEPROPERTIESPropertiesSearchModeFieldName,

  /// (no description).
  DBFILEPROPERTIESPropertiesSearchModeOther,

};

/// Represents the union's current tag state.
@property (nonatomic, readonly) DBFILEPROPERTIESPropertiesSearchModeTag tag;

/// Search for a value associated with this field name. @note Ensure the
/// `isFieldName` method returns true before accessing, otherwise a runtime
/// exception will be raised.
@property (nonatomic, readonly, copy) NSString *fieldName;

#pragma mark - Constructors

///
/// Initializes union class with tag state of "field_name".
///
/// Description of the "field_name" tag state: Search for a value associated
/// with this field name.
///
/// @param fieldName Search for a value associated with this field name.
///
/// @return An initialized instance.
///
- (instancetype)initWithFieldName:(NSString *)fieldName;

///
/// Initializes union class with tag state of "other".
///
/// @return An initialized instance.
///
- (instancetype)initWithOther;

- (instancetype)init NS_UNAVAILABLE;

#pragma mark - Tag state methods

///
/// Retrieves whether the union's current tag state has value "field_name".
///
/// @note Call this method and ensure it returns true before accessing the
/// `fieldName` property, otherwise a runtime exception will be thrown.
///
/// @return Whether the union's current tag state has value "field_name".
///
- (BOOL)isFieldName;

///
/// Retrieves whether the union's current tag state has value "other".
///
/// @return Whether the union's current tag state has value "other".
///
- (BOOL)isOther;

///
/// Retrieves string value of union's current tag state.
///
/// @return A human-readable string representing the union's current tag state.
///
- (NSString *)tagName;

@end

#pragma mark - Serializer Object

///
/// The serialization class for the `DBFILEPROPERTIESPropertiesSearchMode`
/// union.
///
@interface DBFILEPROPERTIESPropertiesSearchModeSerializer : NSObject

///
/// Serializes `DBFILEPROPERTIESPropertiesSearchMode` instances.
///
/// @param instance An instance of the `DBFILEPROPERTIESPropertiesSearchMode`
/// API object.
///
/// @return A json-compatible dictionary representation of the
/// `DBFILEPROPERTIESPropertiesSearchMode` API object.
///
+ (nullable NSDictionary<NSString *, id> *)serialize:(DBFILEPROPERTIESPropertiesSearchMode *)instance;

///
/// Deserializes `DBFILEPROPERTIESPropertiesSearchMode` instances.
///
/// @param dict A json-compatible dictionary representation of the
/// `DBFILEPROPERTIESPropertiesSearchMode` API object.
///
/// @return An instantiation of the `DBFILEPROPERTIESPropertiesSearchMode`
/// object.
///
+ (DBFILEPROPERTIESPropertiesSearchMode *)deserialize:(NSDictionary<NSString *, id> *)dict;

@end

NS_ASSUME_NONNULL_END
