//
//  WFCommon.h
//  UnsigncutsApp
//
//  Created by Snoolie Keffaber on 2023/12/01.
//

#ifndef WFCommon_h
#define WFCommon_h

#import <Foundation/Foundation.h>
#include <os/log.h>

NSBundle *WFCurrentBundle(void);
NSString *WFLocalizedStringForProject(NSString *orig);
NSString *WFLocalizedString(NSString *orig);
NSString *WFLocalizedStringWithKey(NSString *orig, NSString *key);
NSError *WFShortcutPackageFileFailedToSignShortcutFileError(void);
NSError *WFShortcutPackageFileInvalidShortcutFileError(void);
NSError *WFShortcutPackageFileFailedToExtractShortcutFileError(void);
NSString *WFCombinedHashStringFromArray(NSArray *array);

extern os_log_t getWFSecurityLogObject(void);
extern os_log_t getWFGeneralLogObject(void);

#define WFSecurityLog(msg) os_log(getWFSecurityLogObject(), "%s %s", __FUNCTION__, msg);
#define WFSecurityLogF(fmt, ...) os_log(getWFSecurityLogObject(), "%s " fmt, __FUNCTION__, __VA_ARGS__);
#define WFSecurityInfo(msg) os_log_info(getWFSecurityLogObject(), "%s %s", __FUNCTION__, msg);
#define WFSecurityInfoF(fmt, ...) os_log_info(getWFSecurityLogObject(), "%s " fmt, __FUNCTION__, __VA_ARGS__);
#define WFSecurityError(msg) os_log_error(getWFSecurityLogObject(), "%s %s", __FUNCTION__, msg);
#define WFSecurityErrorF(fmt, ...) os_log_error(getWFSecurityLogObject(), "%s " fmt, __FUNCTION__, __VA_ARGS__);

#define WFGeneralLog(msg) os_log(getWFGeneralLogObject(), "%s %s", __FUNCTION__, msg);
#define WFGeneralLogF(fmt, ...) os_log(getWFGeneralLogObject(), "%s " fmt, __FUNCTION__, __VA_ARGS__);
#define WFGeneralInfo(msg) os_log_info(getWFGeneralLogObject(), "%s %s", __FUNCTION__, msg);
#define WFGeneralInfoF(fmt, ...) os_log_info(getWFGeneralLogObject(), "%s " fmt, __FUNCTION__, __VA_ARGS__);
#define WFGeneralError(msg) os_log_error(getWFGeneralLogObject(), "%s %s", __FUNCTION__, msg);
#define WFGeneralErrorF(fmt, ...) os_log_error(getWFGeneralLogObject(), "%s " fmt, __FUNCTION__, __VA_ARGS__);

#endif /* WFCommon_h */
