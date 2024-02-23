# Reversing Contact Signed Shortcuts

### Introduction

About 2 years ago, I made a previous blog about the shortcuts file format. At the time, shortcuts were all unsigned plain plists (although some can also be binary plists).

Signed Shortcuts were a relatively new concept, and pretty undocumented at the time (and they still are). I really just glanced over them, confirming they exist and briefly glossing over the funny oversight in the first beta of iOS 15 that allowed you to import unsigned shortcuts that was very quickly found and sadly patched.

At the time, I wasn't that knowledgable about reverse engineering, apple platforms or programming in general really, and as much as I wanted to look into them, I could not. Now however, I have gained a lot more knowledge than previously, and since no one else seems to be looking into shortcuts signing (if someone else is, tell me!) I have decided to look into shortcut signing again. At the time, given the Shortcuts team oversight as well as many other pretty funny oversights ex the permission bypass, the extract archive dot notation vuln, and the hidden action vuln, I assumed that there must have been *some* flaw with it. However after pouring in many painful hours of research, I apologize to the Shortcuts team, because shortcut signing (at least, contact signing, what I have been looking into the most) seems incredibly secure, as well as the importing process.

The main reasons why I wanted to look into shortcuts signing was to get embed-ables to work on-device again somehow, without the need of a Mac, but another big reason was wanting to figure out some way to replicate the signing process on other non-apple platforms such as Linux. Unfortunately, signed shortcuts are made with Apple's closed source, proprietary, and also extremely undocumented and mysterious **Apple Encrypted Archive**. They're also compressed with LZFSE, which while is more documented than AEA, is still also something that I don't know much about. With that being said, it is definitely possible to, with a painful amount of effort, make a tool that contact signs shortcuts on other platforms, but it would require a lot of reversing of libAppleArchive which is above my skill level for now...

With that being said, another barrier until recently was WorkflowKit, the private framework that provides the main backend behind the Shortcuts app iOS 13+ (technically iirc it was added in iOS 12 but barely did anything back then, although the embedded into app framework WorkflowAppKit does seem to have some similarities to what would become WorkflowKit). The shortcuts CLI tool on macOS is basically just a wrapper around WorkflowKit methods which had the actual code for signing shortcuts. Since WorkflowKit is obviously closed source and only available on Apple platforms, you can't really use its methods in a Linux binary. That, however, has recently changed; about a year ago I began my first ever serious reverse engineering effort, the WorkflowKit decompilation. While I have also touched around some other parts of WorkflowKit, I have been especially focused upon signing specifically. It was pretty awful initially, there are still some methods in the WorkflowKit decompilation that I haven't retouched upon in months that are pretty awful and I really had no idea what I was doing at the time, but over time my skills improved and my decompilation improved as well. I think the biggest achievement I was proud of was a few months back, when I finalized the first big method relating to signing, `WFShortcutPackageFile`'s `preformShortcutDataExtractionWithCompletion:`. Upon hooking the original function with the decomp in Simulator, I was surprised to see it actually work fully. (Well OK, there is still an issue with shortcuts not being able to import it due to a weird invalid Source error, but it's pretty much 99% accurate everywhere else, I have checked the temp directory and it does correctly extract the unsigned shortcut, and whenever I purposely trigger errors it seems to fail in the same spots that the regular method does). That method is what extracts contact signed shortcuts you import into unsigned shortcuts, as well as calls the validation methods that make sure it's signed. That gave me motivation to look back at many of my bad failed attempts at decompiling some methods and redo them into great versions. I have now pretty much decompiled almost every method WorkflowKit has that relates to contact signed shortcuts, as well as made many great discoveries about how they work. With my knowledge, I have made a MIT open source library that uses libAppleArchive as well as Security to sign shortcuts **without the use of WorkflowKit**. It's called libshortcutsign, and while it's still primitive at the moment does allows you to verify contact signed shortcuts, sign contact signed shortcuts with the private key and the auth data, extract auth data from a contact signed shortcut, and extract the unsigned shortcut from a signed shortcut. You can find it here: [https://github.com/0xilis/libshortcutsign](https://github.com/0xilis/libshortcutsign). While it does only work on non-apple platforms due to it using libAppleArchive and Security (with the exception of auth_data_from_shortcut, currently the only function that is libAppleArchive-less), since it technically doesn't use any private frameworks, I guess I have achieved something: If, for whatever reason, you want to mess with contact signed shortcuts in an App Store app, then this allows you to without using any private frameworks (albeit you would need to have the user dump their Apple ID identity certificates on their Mac, which I'm not completely sure would be compliant...).

You can find my decompilation of many WorkflowKit methods here: [https://github.com/0xilis/RandomShortcutsRev](https://github.com/0xilis/RandomShortcutsRev). To see the exact process of how contact signed shortcuts are signed, check `WFP2PSignedShortcutFileExporter`'s `exportWorkflowWithCompletion`. For importing, you can check `WFShortcutExtractor`'s `extractShortcutFile`, but the main method relating to contact signed importing you should focus on is `WFShortcutPackageFile`'s `preformShortcutDataExtractionWithCompletion `. Also, feel free to check on libshortcutsign as well. If you have any questions regarding shortcut contact signing, feel free to ask me and I'll *try* to provide you with my best answer. With that being said, let's finally talk about signing.

### Contact Signed Shortcuts

Signed Shortcuts are Apple Encrypted Archives. In a signed shortcut, it will contain a context field, AEA_CONTEXT_FIELD_AUTH_DATA. I have already mentioned that I have not really reversed libAppleArchive much as it's above my skill level, but one thing I did figure out from a hex editor was how this field is stored in signed shortcuts (both iCloud signed and contact signed). I'm not exactly sure if this is universal for AEA or specific to signed shortcuts, but you can find the length of the auth data in the bytes 9 to 12 of a signed shortcut. As an example, here's the first 16 bytes of a signed shortcut file:

`41 45 41 31 00 00 00 00 68 1A 00 00 62 70 6C 69`

Bytes 12 and 11 are blank. Bytes 9 and 10 are filled however; byte 10 is 1A and byte 9 is 68. This means the context field will be 0x1A68 in size, which is 6760. Thankfully for us, the auth data is not compressed at all, meaning we don't even have to decompress it, just copy bytes 0xB to 0xB+field_size, pass it into [NSData dataWithBytesNoCopy:length:], and enjoy our extracted AEA auth data. libshortcutsign has a function for this, auth_data_from_shortcut.

After we extracted the auth data, let's read it! This will be a plist, containing the signing info. You can do `[NSPropertyListSerialization propertyListWithData:authData options:0 format:0 error:nil]` do convert it into a NSDictionary. Here's the important fields that are relating to contact signed in particular:

* `AppleIDCertificateChain` - The Apple ID Cert chain. The first element will be your SFAppleIDIdentity certificate, with the 2nd being your intermediate certificate. 
* `SigningPublicKey` - The signing public key. This isn't actually used for any sort of verification (at least, to my knowledge), but rather will be used to decrypt the shortcut.
* `SigningPublicKeySignature` - The signature of the public key, signed by the first certificate of the Apple ID Certificate chain.
* `AppleIDValidationRecord` - Contains information about who signed it. The particular fields to take note of are `AltDSID`, which is used to identify the user, as well as `validatedEmailHashes` and `validatedPhoneHashes`, which are an array of SHA256 hashes linked to the Apple ID of the person who shared it. These are used to check if it's someone in your contacts, however the `AltDSID` is checked to see if you shared it; if it's equal to you, then it detects that you shared it, and assuming validation passed will let you import it even if private sharing is not enabled.

### How Shortcuts Contact Signs a Shortcut

Whenever you contact sign a shortcut, `generateSignedShortcutFileRepresentationWithAccount:` generates a 256-bit elliptic curve key. Here's the key generation:

```objc
NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
mutableDict[(__bridge id)kSecAttrKeyType] = (__bridge id)kSecAttrKeyTypeECSECPrimeRandom;
mutableDict[(__bridge id)kSecAttrKeySizeInBits] = @256;
mutableDict[(__bridge id)kSecAttrIsPermanent] = @NO;
SecKeyRef daKey = SecKeyCreateRandomKey((__bridge CFDictionaryRef)mutableDict, 0);
```

This key will be used for encryption / decryption. It then generates the auth data from it, which it uses the public key generated as the signing public key in the context (and of course signs it). The unsigned shortcut is also stored in a directory, where it is named "Shortcut.wflow". It then uses the key generated as a private key in X963 representation to encrypt the AEA of the directory (which is also compressed under LZFSE). I should also mention it uses `"TYP,PAT,LNK,DEV,DAT,MOD,FLG,MTM,BTM,CTM,HLC,CLC"` for the AAFieldKeySet; I'm not that knowledgable of how exactly that's used, but mentioning it in case someone else knows and if it's important.

### Validation

When shortcuts checks the signature of a contact signed shortcut, the first step for validation isn't actually `validateWithCompletion:` but rather `contextWithAuthData:`. (Note: If the auth data contains `SigningCertificateChain`, then it's an iCloud shortcut and shortcuts generates the context from it, with this method not doing verification but waiting for the `validateWithCompletion:` call for validation instead). It verifies the public key is signed correctly via this line:

```objc
Boolean isVerified = SecKeyVerifySignature(publicKeyOfFirstCertificateInChain, kSecKeyAlgorithmRSASignatureMessagePSSSHA256, (__bridge CFDataRef)signingPublicKey, (__bridge CFDataRef)signingPublicKeySignature, nil);
```

Next, it both verifies and gets the Apple ID Validation Record in one `SecCMSVerifyCopyDataAndAttributes` call. It must match the `SecPolicyCreateAppleIDValidationRecordSigningPolicy` policy. After that, it then validates the trust via `SecTrustEvaluateAsync`, and also checks the `Version` key in the validation record to make sure it's 100 or below. (Note: trust evaluation is not implemented by libshortcutsign yet)

The next step of validation is `validateAppleIDCertificatesWithError`, which is called by `validateWithCompletion`. This checks the policy and trust of the certificates. Here's the code, not including logs or return errors:

```objc
-(BOOL)validateAppleIDCertificatesWithError:(NSError**)err {
    NSArray <WFShortcutSigningCertificate *>* signingCertificateChain = [self appleIDCertificateChain];
    /* if_map is from IntentsFoundation.framework */
    NSArray* certificates = [signingCertificateChain if_map:^(WFShortcutSigningCertificate *item){
      [item certificate]; //WFShortcutSigningCertificate
    }];
    if (certificates) {
        SecPolicyRef policy = SecPolicyCreateAppleIDAuthorityPolicy();
        SecPolicySetOptionsValue(policy,kSecPolicyCheckTemporalValidity,kCFBooleanFalse);
        if (policy) {
            SecTrustRef trust;
            OSStatus res = SecTrustCreateWithCertificates((__bridge CFArrayRef)certificates, policy, &trust);
            if (res == 0) {
                if (trust) {
                    CFErrorRef trustErr;
                    if (SecTrustEvaluateWithError(trust, &trustErr) == 0) {
                        CFErrorDomain domain = CFErrorGetDomain(trustErr);
                        if (CFEqual(domain, NSOSStatusErrorDomain)) {
                            if (CFErrorGetCode(trustErr) == errSecCertificateExpired) {
                                /* cert is valid if we reached here */
                                return YES;
                            }
                        }
                    } else {
                        /* cert is valid if we reached here */
                        return YES;
                    }
                }
            }
        }
    }
    return NO;
}
```

As you can see, one notable thing about it is that even if the certificate expired, Shortcuts will allow it anyway.

The final step of contact-signed validation is just checking the Apple ID Validation Record and seeing if the AltDSID matches the users, or if it doesn't and private sharing is enabled, check the SHA256 email and phone number hashes listed to see if they match with anyone in your contacts. Unsigncuts is a tweak I made forever ago that has a option that disables email/phone hash checking for importing a contact signed shortcut even if they weren't in your contacts, for example.

But wait... **if the auth data really only verifies the public key, can't we just copy over the auth data from a contact signed shortcut shared by someone else?**

Well... *kind of yes*, but in reality no. I demo this in [https://github.com/0xilis/WorkflowKit-KeyMismatch-PoC](https://github.com/0xilis/WorkflowKit-KeyMismatch-PoC). At first, this seems like it works, as in it passes all validation methods. But wait, shortcuts seems to... crash? Checking the crash log reveals libAppleArchive crashes with `AAArchiveStreamProcess`->`decodeStreamReadHeader`->`decodeStreamRefillBuffer`->`AAByteStreamRead`. What's going on?

Well, with the little libAppleArchive research I did, I found that an AAByteStream is a struct with multiple fields. Sadly, the headers don't reveal much about the structs so I had to do a bit of painful RE of libAppleArchive, but I was able to figure out the first item of the struct will be a AAByteStreamFileDesc struct, the second item will be a pointer to a function to close the steam (ex if `AAFileStreamOpenWithPath` was used, it's to the `aaFileStreamClose` function), but the thing to take note of is the third item is a pointer to a function to handle reading of the stream. When `AAByteStream` is caused, the function that causes our crash, it is trying to jump to the function pointer for reading the stream in the struct that was passed in. If we do a little bit of digging, `AEADecryptionInputStreamOpen`, what should be returning a AAByteStream to use as the decryption input stream, is instead returning nil. AADecodeArchiveInputStreamOpen is making a AAArchiveStream off of the nil pointer, and when Shortcuts reaches `AAArchiveStreamProcess` to attempt to decode and decrypt the archive, it eventually tries to read the decryption stream; however, since AEADecryptionInputStreamOpen failed, we won't have a pointer on our struct, meaning it will attempt to jump to ???? and crash.

Basically, even if we passed validation, we used a different key to encrypt us rather than the one present on `signingPublicKey`. Because of this, the decryption stream will fail to open, and we can't decrypt the shortcut data. We can't just regenerate a new key to use for the context of someone else's contact signed shortcut, because we don't have their certificate that was used to sign the public key.

(I should note that WorkflowKit *should* show an error instead of just flat out crashing, but that isn't a security vuln but just an annoying bug. Not sure if the bug is with libAppleArchive and it should be checking that the decryption stream is not nil and return an error if so or if it's with WorkflowKit and it should be checking for nil, but either way libshortcutsign doesn't have this issue and properly returns a negative error value if there is a key mismatch that prevents a decryption.)

### Possible Vulns?

I could not find any flaws in the shortcut contact signing process, I have to congratulate the team behind it because it does look pretty damn secure. I don't really see much potential for an unfound vuln in shortcut signing; at least, not in iOS 15.2 WorkflowKit, which is what I have been RE'ing. But I should mention other possible ideas for where there may be vulns, but I highly doubt that there are any here:

* If someone can potentially make it decrypt with a different key than listed in the context, then there would be a vuln. Anyone would be able to generate their own key, copy the auth data of another shortcut which would include the original public key, but malform the AEA in a way to force it to use their own key. It doesn't look there is much chance of this being possible however, and this would likely require someone to decompile a chunk of libAppleArchive to check for any possible ways to do this, which is honestly just not worth the effort, especially for something that is more than likely not present.
* A vulnerability in Security.framework; **HA, good luck.** Security.framework has been heavily audited already and, fitting its name, is pretty damn secure. If you actually find something that would allow you to fakesign shortcut files here, you've honestly earned it.
* Some weird vuln in libAppleArchive itself. Doubt if there is one that it would be usable.
* Apple updating the validation/extraction process in the future for no reason at all and messing up.
* Some vuln in iCloud signing, doubt there is one.
* Nothing in the sign checking process itself but someone accidentally making you able to import unsigned shortcuts. This may seem unlikely but it's actually been the only type mentioned here that actually has happened in the past.
* (macOS ONLY, so this one really doesn't interest me) I'm not exactly sure if this would be counted as a vuln, but shortcuts allows you to import automator files on macOS and have them be converted into shortcut actions. Automator files however are unsigned. Maybe there's some way to malform a automator file to trick shortcuts into using a shortcut exclusive action?

### iOS 15 Developer Beta 1's Signing Bypass

This is extremely stupid.

Found on literally the day 15b1 released, on accident, it was found by someone on reddit that if you rename an unsigned shortcut to use the .wflow file extension instead of .shortcut, it just... imports it. I have no idea how this happened, and don't have the WorkflowKit binary of 15b1 to inspect it for myself, but it's honestly pretty funny and a big oversight. It was very quickly patched next beta.

However, another similar vuln was found also by someone on reddit, though this time for the macOS 12.0 beta, where if you dragged in an unsigned shortcut a certain way, it would just... add it. If I remember correctly a shortcuts team member themselves may have replied that it wasn't intended in the post, but anyways it was patched the next beta.

Maybe in the future, another bypass akin to this will be found. However, to my knowledge, all of these type of bypasses were only ever found (publicly) in the developer betas for macOS 12.0 / iOS 15.0. I should mention that I at least (don't believe) that the WFDefaultShortcuts are signed, but those are just hardcoded iCloud links in WorkflowKit.framework, so I don't think that really brings any bad news.

*TL:DR; Bring embed-ables officially, you cowards.*

- Snoolie K / 0xilis
