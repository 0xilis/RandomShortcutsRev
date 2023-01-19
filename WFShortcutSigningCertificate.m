#import <Foundation/Foundation.h>
#import "WFShortcutSigningCertificate.h"

@implementation WFShortcutSigningCertificate
-(id)generateAuthData {
  return SecCertificateCopyData([self certificate]);
}
@end
