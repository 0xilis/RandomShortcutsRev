//
//  WFCommon.m
//  UnsigncutsApp
//
//  Created by Snoolie Keffaber on 2023/12/01.
//

#include "WFCommon.h"

NSBundle *WFCurrentBundle(void) {
    static NSBundle *bundle;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Dl_info info;
        int can_find_symbol = dladdr(WFCurrentBundle, &info);
        if (can_find_symbol) {
            const char *path_to_our_symbol = info.dli_fbase;
            if (path_to_our_symbol) {
                NSURL *execURL = [[NSURL alloc]initFileURLWithFileSystemRepresentation:path_to_our_symbol isDirectory:NO relativeToURL:nil];
                NSURL *bundleURL = (__bridge NSURL *)(CFBundleCopyBundleURLForExecutableURL((__bridge CFURLRef)(execURL)));
                bundle = [NSBundle bundleWithURL:bundleURL];
            }
        }
    });
    return bundle;
}
NSString *WFLocalizedStringForProject(NSString *orig) {
#if 0
    NSString *key = [NSString stringWithFormat:@"Localizable-%@", @"B298"];
    NSBundle *bundle = [NSBundle bundleForClass:[WFConditionallyCompiledActionProvider class]];
    return [bundle localizedStringForKey:orig value:key table:nil];
#else
    /* placeholder - WFConditionallyCompiledActionProvider not yet implemented */
    return nil;
#endif
}
NSString *WFLocalizedString(NSString *orig) {
    return [WFCurrentBundle() localizedStringForKey:orig value:orig table:nil];
}
NSString *WFLocalizedStringWithKey(NSString *orig, NSString *key) {
    return [WFCurrentBundle() localizedStringForKey:orig value:key table:nil];
}
NSError *WFShortcutPackageFileFailedToSignShortcutFileError(void) {
    return [NSError errorWithDomain:@"WFWorkflowErrorDomain" code:0x4 userInfo:@{
        NSLocalizedDescriptionKey : WFLocalizedString(@"Failed to sign shortcut"),
    }];
}

NSError *WFShortcutPackageFileInvalidShortcutFileError(void) {
    return [NSError errorWithDomain:@"WFWorkflowErrorDomain" code:0x3 userInfo:@{
        NSLocalizedDescriptionKey : WFLocalizedString(@"Invalid shortcut file"),
    }];
}

NSError *WFShortcutPackageFileFailedToExtractShortcutFileError(void) {
    return [NSError errorWithDomain:@"WFWorkflowErrorDomain" code:0x6 userInfo:@{
        NSLocalizedDescriptionKey : WFLocalizedString(@"Failed to extract the shortcut file data"),
    }];
}

NSString *WFCombinedHashStringFromArray(NSArray *array) {
    unsigned long items = [array count];
    if (items) {
        NSMutableString *combinedString;
        for (int i = 0; i < items; i++) {
            if (!combinedString) {
                combinedString = [[NSMutableString alloc]init];
                NSString *string = array[i];
                const char *cstr = [string UTF8String];
                unsigned long len = [string length];
                NSMutableData *data = [NSMutableData dataWithCapacity:len/2];
                for (int j = 0; j < len; j++) {
                    //strtoul();
                }
            }
        }
    }
    return @"FINISH LATER";
}
