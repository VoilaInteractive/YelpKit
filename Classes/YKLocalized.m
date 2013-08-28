//
//  YKLocalized.m
//  YelpIPhone
//
//  Created by Gabriel Handford on 11/18/08.
//  Copyright 2008 Yelp. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import "YKLocalized.h"
#import "YKDefines.h"


#include <math.h>

#define kDefaultTableName @"Localizable"
static NSString *gDefaultTableName = kDefaultTableName;

@implementation NSBundle (YKLocalized)

// Get resource cache
+ (NSMutableDictionary *)yelp_localizationResourceCache {
  static NSMutableDictionary *LocalizationResourceCache = nil;
  @synchronized([YKLocalized class]) {
    if (!LocalizationResourceCache) LocalizationResourceCache = [[NSMutableDictionary alloc] init];
  }
  return LocalizationResourceCache;
}

+ (NSMutableDictionary *)yelp_pathForResourceCache {
  static NSMutableDictionary *PathForResourceCache = nil;
  @synchronized([YKLocalized class]) {    
    if (!PathForResourceCache) PathForResourceCache = [[NSMutableDictionary alloc] init];
  }
  return PathForResourceCache;
}

// Clear resource cache
+ (void)yelp_clearCache {
  [[self yelp_localizationResourceCache] removeAllObjects];
}

// Cached version of path for resource
- (NSString *)yelp_pathForResource:(NSString *)tableName localization:(NSString *)localization {
  if ([localization isEqual:@"en_US"]) localization = @"en";
  NSString *key = [[NSString alloc] initWithFormat:@"%@%@", tableName, localization];
  id resource = [NSBundle yelp_pathForResourceCache][key];
  if ([resource isEqual:[NSNull null]]) {
    [key release];
    return nil;
  }
  
  if (!resource) {
    resource = [self pathForResource:tableName ofType:@"strings" inDirectory:nil forLocalization:localization];
    [NSBundle yelp_pathForResourceCache][key] = (resource ? resource : [NSNull null]);
  }
  
  [key release];
  return (NSString *)resource;
}

- (NSDictionary *)yelp_loadResourceForTableName:(NSString *)tableName localization:(NSString *)localization {
  NSDictionary *dict = nil;
  if ([localization isEqual:@"en_US"]) localization = @"en";
  NSString *key = [[NSString alloc] initWithFormat:@"%@%@", tableName, localization];  
  dict = [NSBundle yelp_localizationResourceCache][key];
  if (!dict) {
    NSString *resource = [self yelp_pathForResource:tableName localization:localization];
    if (!resource) {
      [key release];
      return nil;
    }
    dict = [[NSDictionary alloc] initWithContentsOfFile:resource];
    [NSBundle yelp_localizationResourceCache][key] = dict;
    [dict release];
  }
  [key release];
  return dict;
}

// Look for string with localization string
- (NSString *)yelp_stringForKey:(NSString *)key tableName:(NSString *)tableName localization:(NSString *)localization {
  if (!localization) localization = [YKLocalized languageCode];

  
  NSDictionary *dict = [self yelp_loadResourceForTableName:tableName localization:localization];
  return dict[key];
}

- (NSString *)yelp_preferredLanguageForTableName:(NSString *)tableName {
  static NSString *LanguageCode = nil;
  if (LanguageCode) return LanguageCode;
  
  for (NSString *languageCode in [NSLocale preferredLanguages]) {
    // Check if we have a bundle with this preferred language code
    if (!![self yelp_loadResourceForTableName:tableName localization:languageCode]) {
      LanguageCode = [languageCode copy];
      break;
    }
  }
  if (!LanguageCode) LanguageCode = @"en";
  return LanguageCode;
}

// Patched localized string.
- (NSString *)yelp_localizedStringForKey:(NSString *)key value:(NSString *)value tableName:(NSString *)tableName {
  if (!key) {
    YKDebug(@"Trying to localize nil key, (with value=%@, tableName=%@)", value, tableName);
    return nil;
  }

  NSString *localizedString = [YKLocalized localizationCache][key];
  if (localizedString) return localizedString;
  
  if (!tableName) tableName = gDefaultTableName; // Default file is Localizable.strings

  localizedString = [self yelp_localizedStringForKey:key tableName:tableName];
  
  if (!localizedString) {
    localizedString = value;
  }

  if (!localizedString) {
    localizedString = key;
  }
   
  if (localizedString) {
    [YKLocalized localizationCache][key] = localizedString;
  }
  
  return localizedString;
}

- (NSString *)yelp_localizedStringForKey:(NSString *)key tableName:(NSString *)tableName {
  NSString *localizedString = [self yelp_stringForKey:key tableName:tableName localization:[YKLocalized localeIdentifier]];
  
  // If not found, check preferredLanguages
  if (!localizedString)
    localizedString = [self yelp_stringForKey:key tableName:tableName localization:[self yelp_preferredLanguageForTableName:tableName]];
  
  return localizedString;
}

- (NSString *)yelp_localizedStringForKey:(NSString *)key tableName:(NSString *)tableName locale:(NSString *)locale {
  if (!tableName) tableName = gDefaultTableName; // Default file is Localizable.strings
  NSString *localizedString = [self yelp_stringForKey:key tableName:tableName localization:locale];

  // If not found, use the language code
  if (!localizedString && [locale length] == 5) {
    NSString *languageCode = [locale substringToIndex:2];
    localizedString = [self yelp_stringForKey:key tableName:tableName localization:languageCode];
  }

  // If not found, use the current locale instead of the locale passed in
  if (!localizedString) {
    localizedString = [self yelp_localizedStringForKey:key tableName:tableName];
  }

  if (!localizedString) {
    localizedString = key;
  }
  return localizedString;
}


@end

@implementation YKLocalized

static NSMutableDictionary *gLocalizationCache = nil;
static NSString *gLocaleIdentifier = nil;
static NSSet *gSupportedLanguages = nil;
static NSString *gLanguageCode = nil;
static NSString *gMockCountryCode = nil;
static NSSet *gSupportedCountries = nil;

+ (NSMutableDictionary *)localizationCache {
  @synchronized([YKLocalized class]) {
    if (!gLocalizationCache) gLocalizationCache = [[NSMutableDictionary alloc] init];
  }
  return gLocalizationCache;
}

+ (void)clearCache {
  [NSBundle yelp_clearCache];
  [gLocalizationCache release];
  gLocalizationCache = nil;
  [gLocaleIdentifier release];
  gLocaleIdentifier = nil;
  [gLanguageCode release];
  gLanguageCode = nil;
}

+ (NSString *)localize:(NSString *)key tableName:(NSString *)tableName value:(NSString *)value {
  return NSLocalizedStringWithDefaultValue(key, tableName, [NSBundle bundleForClass:[self class]], value, @"");
}

+ (NSString *)localize:(NSString *)key tableName:(NSString *)tableName locale:(NSString *)locale {
  return NSLocalizedStringForLocale(key, tableName, [NSBundle bundleForClass:[self class]], locale);
}

+ (void)setDefaultTableName:(NSString *)defaultTableName {
  [gDefaultTableName release];
  gDefaultTableName = (defaultTableName ? [defaultTableName copy] : kDefaultTableName);
}

+ (BOOL)isMetric {
  return [self isMetric:[NSLocale currentLocale]];
}

+ (BOOL)isMetric:(id)locale {
  // Override metric for GB (use miles)
  if ([[self countryCode] isEqualToString:@"GB"]) return NO;
  
  return [locale[NSLocaleUsesMetricSystem] boolValue];
}

+ (NSString *)currencySymbol {
  return [[NSLocale currentLocale] objectForKey:NSLocaleCurrencySymbol];
}

+ (NSString *)localeIdentifier {
  if (!gLocaleIdentifier) {
    NSString *countryCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    if (countryCode) gLocaleIdentifier = [[NSString stringWithFormat:@"%@_%@", [YKLocalized languageCode], countryCode] retain];
    else gLocaleIdentifier = [[YKLocalized languageCode] retain];
    YKDebug(@"gLocaleIdentifier: %@", gLocaleIdentifier);
  }
  return gLocaleIdentifier;
}

+ (NSSet *)supportedLanguages {
  return gSupportedLanguages;
}

+ (void)setSupportedLanguages:(NSSet *)supportedLanguages {
  [supportedLanguages retain];
  [gSupportedLanguages release];
  gSupportedLanguages = supportedLanguages;
}

+ (NSString *)countryCode {
  if (gMockCountryCode) return gMockCountryCode;
  NSString *currentCountryCode = [[NSLocale autoupdatingCurrentLocale] objectForKey:NSLocaleCountryCode];
  if (!gSupportedCountries || [gSupportedCountries containsObject:currentCountryCode]) return currentCountryCode;
  return nil;
}

+ (void)setMockCountryCode:(NSString *)countryCode {
  [countryCode retain];
  [gMockCountryCode release];
  gMockCountryCode = countryCode;
}

+ (void)disableMockCountryCode {
  [gMockCountryCode release];
  gMockCountryCode = nil;
}

+ (void)setSupportedCountries:(NSSet *)supportedCountries {
  [supportedCountries retain];
  [gSupportedCountries release];
  gSupportedCountries = supportedCountries;
}

+ (NSSet *)supportedCountries {
  return gSupportedCountries;
}

+ (NSString *)languageCode {
  if (!gLanguageCode) {
    NSArray *preferredLanguages = [NSLocale preferredLanguages];
    NSSet *supportedLanguages = [YKLocalized supportedLanguages];
    for (NSString *language in preferredLanguages) {
      if (!supportedLanguages || [supportedLanguages containsObject:language]) {
        gLanguageCode = [language retain];
        return gLanguageCode;
      }
    }
    gLanguageCode = [@"en" retain];
  }
  return gLanguageCode;
}

+ (BOOL)isCountryCode:(NSString *)code {
  NSString *countryCode = [self countryCode];
  return (countryCode && [countryCode compare:code options:NSCaseInsensitiveSearch] == NSOrderedSame);
}

+ (NSString *)localizedPath:(NSString *)name ofType:(NSString *)type {
  NSString *localeIdentifier = [YKLocalized localeIdentifier];
  
  NSString *resourcePath = [[NSBundle mainBundle] pathForResource:name ofType:type inDirectory:nil forLocalization:localeIdentifier];
  // Try a localization for the language code
  if (!resourcePath) resourcePath = [[NSBundle mainBundle] pathForResource:name ofType:type inDirectory:nil forLocalization:[YKLocalized languageCode]];
  // Try localizing based on 'en'
  if (!resourcePath) resourcePath = [[NSBundle mainBundle] pathForResource:name ofType:type inDirectory:nil forLocalization:@"en"];
  // If a localized version was found, remove the base resource path
  if (resourcePath) {
    NSString *baseResourcePath = [[NSBundle mainBundle] resourcePath];
    resourcePath = [resourcePath substringFromIndex:[baseResourcePath length] + 1];
  // Otherwise just return the filename
  } else {
    resourcePath = [NSString stringWithFormat:@"%@.%@", name, type];
  }
  return resourcePath;
}

+ (NSString *)localizedListFromStrings:(NSArray */*of NSString*/)strings {
  if (!strings || ([strings count] <= 0)) return nil;
  if ([strings count] == 1) return strings[0];
  if ([strings count] == 2) {
    return [NSString stringWithFormat:@"%@ %@ %@", strings[0], YKLocalizedString(@"and"), strings[1], nil];
  }
  NSMutableString *localizedList = [[[NSMutableString alloc] initWithString:strings[0]] autorelease];
  for (NSInteger i = 1; i < [strings count]; i++) {
    if (i == ([strings count] - 1)) [localizedList appendFormat:@" %@ ", YKLocalizedString(@"and"), nil];
    else [localizedList appendString:@", "];
    [localizedList appendString:strings[i]];
  }
  return localizedList;
}

+ (NSDateFormatter *)dateFormatter {
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setLocale:[YKLocalized currentLocale]];
  return [formatter autorelease];
}

+ (NSLocale *)currentLocale {
  NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:[YKLocalized localeIdentifier]];
  return [locale autorelease];
}

@end

