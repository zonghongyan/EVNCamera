//
//  NSString+EVNExt.h
//  EVNCamera
//
//  Created by developer on 2017/6/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (EVNExt)

/**
 \~chinese
 校验字符串是否有效，若有效返回YES，否则返回NO
 
 \~english
 Returns YES if the string is valid
 */
- (BOOL)isValid;

/**
 校验字符串是否为非空且有效，若有效返回YES，否则返回NO
 */
- (BOOL)isNonNullValid;

/**
 校验字符串是否为非空且有效，若有效返回YES，否则返回NO
 */
+ (BOOL)isNonNullValid:(nullable NSString *)string;

/**
 当字符串无效时转为空字符串代替
 */
+ (NSString *)emptyConversion:(nullable NSString *)string;

/// 当字符串无效时转为 "--" 字符串代替
+ (NSString *)doubleBarConversion:(nullable NSString *)string;

/**
 \~chinese
 校验字符串是否是手机号，若是返回YES，否则返回NO
 
 \~english
 Returns YES if the string is phone number
 */
- (BOOL)isPhoneNumberValid;

/**
 \~chinese
 校验字符串是否是邮箱地址，若是返回YES，否则返回NO
 
 \~english
 Returns YES if the string is email adress
 */
- (BOOL)isEmailAdressValid;

/**
 \~chinese
 获取限定约束下字符串范围大小
 
 \~english
 Returns the size of the string if it were rendered with the specified constraints.
 
 @param font          The font to use for computing the string size. 字体大小
 
 @param size          The maximum acceptable size for the string. This value is
 used to calculate where line breaks and wrapping would occur.
 
 @param lineBreakMode The line break options for computing the size of the string.
 For a list of possible values, see NSLineBreakMode. 换行模式
 
 @return              The width and height of the resulting string's bounding box.
 These values may be rounded up to the nearest whole number.
 */
- (CGSize)sizeWithFont:(UIFont *)font size:(CGSize)size mode:(NSLineBreakMode)lineBreakMode;

/**
 \~chinese
 获取单行字符串限定字体下字符串宽度
 
 \~english
 Returns the width of the string if it were to be rendered with the specified
 font on a single line.
 
 @param font  The font to use for computing the string width.
 
 @return      The width of the resulting string's bounding box. These values may be
 rounded up to the nearest whole number.
 */
- (CGFloat)widthWithFont:(UIFont *)font;

/**
 \~chinese
 获取限定约束下字符串高度
 
 \~english
 Returns the height of the string if it were rendered with the specified constraints.
 
 @param font   The font to use for computing the string size.
 
 @param width  The maximum acceptable width for the string. This value is used
 to calculate where line breaks and wrapping would occur.
 
 @return       The height of the resulting string's bounding box. These values
 may be rounded up to the nearest whole number.
 */
- (CGFloat)heightWithFont:(UIFont *)font width:(CGFloat)width;

/**
 \~chinese
 正则匹配方法
 
 \~english
 Whether it can match the regular expression

 @param regex The regular expression 正则表达式
 @return YES if can match the regex; otherwise, NO. 是否匹配成功
 */
- (BOOL)matchesRegex:(NSString *)regex;

/**
 \~chinese
 正则匹配，附带正则匹配规则
 
 \~english
 Whether it can match the regular expression
 
 @param regex  The regular expression
 @param options     The matching options to report.
 @return YES if can match the regex; otherwise, NO.
 
 NSRegularExpressionCaseInsensitive             = 1 << 0,   // 不区分大小写的
 NSRegularExpressionAllowCommentsAndWhitespace  = 1 << 1,   // 忽略空格和# -
 NSRegularExpressionIgnoreMetacharacters        = 1 << 2,   // 整体化
 NSRegularExpressionDotMatchesLineSeparators    = 1 << 3,   // 匹配任何字符，包括行分隔符
 NSRegularExpressionAnchorsMatchLines           = 1 << 4,   // 允许^和$在匹配的开始和结束行
 NSRegularExpressionUseUnixLineSeparators       = 1 << 5,   // (查找范围为整个的话无效)
 NSRegularExpressionUseUnicodeWordBoundaries    = 1 << 6    // (查找范围为整个的话无效)
 */
- (BOOL)matchesRegex:(NSString *)regex options:(NSRegularExpressionOptions)options;

/**
 \~english
 Match the regular expression, and executes a given block using each object in the matches.
 
 @param regex    The regular expression
 @param options  The matching options to report.
 @param block    The block to apply to elements in the array of matches.
 The block takes four arguments:
 match: The match substring.
 matchRange: The matching options.
 stop: A reference to a Boolean value. The block can set the value
 to YES to stop further processing of the array. The stop
 argument is an out-only argument. You should only ever set
 this Boolean to YES within the Block.
 */
- (void)enumerateRegexMatches:(NSString *)regex
                      options:(NSRegularExpressionOptions)options
                   usingBlock:(void (^)(NSString *match, NSRange matchRange, BOOL *stop))block;

/**
 \~chinese
 返回正则匹配后的新字符串
 
 \~english
 Returns a new string containing matching regular expressions replaced with the template string.
 
 @param regex       The regular expression
 @param options     The matching options to report.
 @param replacement The substitution template used when replacing matching instances.
 
 @return A string with matching regular expressions replaced by the template string.
 */
- (NSString *)stringByReplacingRegex:(NSString *)regex
                             options:(NSRegularExpressionOptions)options
                          withString:(NSString *)replacement;

/**
 \~chinese
 去除字符串前后空格和下划线特殊字符
 
 \~english
 Trim blank characters (space and newline) in head and tail.
 @return the trimmed string.
 */
- (NSString *)stringByTrim;

/**
 \~chinese
 校验是否包含某个字符串
 
 \~english
 Returns YES if the target string is contained within the receiver.
 @param string A string to test the the receiver.
 
 @discussion Apple has implemented this method in iOS8.
 */
- (BOOL)containsString:(NSString *)string;


/**
 \~chinese
 获取字符串range范围
 
 \~english
 Returns NSMakeRange(0, self.length).
 */
- (NSRange)rangeOfAll;

/**
 \~chinese
 返回一个UUID字符串
 
 \~english
 Returns a new UUID NSString
 e.g. "D1178E50-2A4D-4F1F-9BD3-F6AAB00E06B1"
 */
+ (NSString *)stringWithUUID;

@end

NS_ASSUME_NONNULL_END
