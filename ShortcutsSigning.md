# One way ticket to shortcuts signing

This is all based upon iOS 15.2, so some info may be slightly out of date.

Shortcuts as of iOS 15 has multiple different types of formats. First is the old-but-gold unsigned file format, which are just bplist / xml plist.

However, with the introduction of iOS 15, this brings the introduction to signed shortcut files, that being contact signed and iCloud signed. To my knowledge no one has really publicly documented them / how shortcuts handles these all that much, so I'd figure I'd do it here.

Admittedly I'm not the best at re so some stuff may not be 100% accurate, but I'm confident enough that at the very least a lot of this is and as I have just noted I haven't seen anyone publicly document this, and something's better than nothing I guess /shrug.

# Importing

First let's look at shortcut extraction / importing. iOS 15's WorkflowKit features a brand new class, WFShortcutExtractor, specifically for dealing with extraction. The method for extracting signed shortcut files is [WFShortcutExtractor extractShortcutFile:completion:]. It calls subdataWithRange: and wf_stringWithData: to get the first 4 characters of the shortcut file passed in, and does [isEqualToString:@"AEA1"] on it. (In other words, if the file's first 4 characters are AEA1, it sees it as a signed shortcut file, and if not it sees it as an unsigned file). It then gets wfType and does [WFShortcutExtractor isShortcutFileType:wfType, 0x4] to make sure the wfType is an unsigned shortcut file, and if so, proceeds to call the method for extracting unsigned shortcut files,  [WFShortcutExtractor extractWorkflowFile:completion:]. Normally in the iOS 13/14 days you could set a value in a plist, WFShortcutsFileSharingEnabled, and re-enable importing unsigned shortcut files. However now WFShortcutExtractor ignores this flag unless VCIsInternalBuild() returns true, and obviously it's not like we or a normal user are running an internal build of VoiceShortcutsClient or can. WFShortcutExtractor though also accepts a new argument - allowsOldFormatFile - and this is accepted and would allow us to import unsigned shortcut files without an internal build of VoiceShortcuts. However, to my knowledge there is never a case where allowsOldFormatFile would be set to true.

Because of this I would advise looking at [WFShortcutExtractor extractWorkflowFile:completion:] too much for now, at least not until there are some cases when allowsOldFormatFile might be true or if Apple ever starts accepting WFShortcutsFileSharingEnabled on non-internal builds of VoiceShortcuts.

to be continued
