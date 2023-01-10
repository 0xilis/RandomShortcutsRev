# RandomShortcutsRev
Random rev of shortcuts (mostly iOS 15.2 WorkflowKit)

# Shortcuts CLI tool signing
For signing, the shortcuts cli tool on macos just uses WFP2PSignedShortcutFileExporter (contact signed) and WFiCloudShortcutFileExporter (iCloud Signed) from the WorkflowKit private framework.

# Unsigned shortcut importing
On iOS 13/14, the WFShortcutsFileSharingEnabled flag (/var/mobile/Library/Preferences/com.apple.shortcuts or com.apple.siri.shortcuts idk) enabled will re-enable the ability to import unsigned shortcut files.

On iOS 15, this flag is ignored when importing except on internal builds of VoiceShortcuts (uses VCIsInternalBuild() funciton from /System/Library/PrivateFrameworks/VoiceShortcutsClient.framework). WFShortcutExtractor *does* have an allowsOldFormatFile property which is also checked in regular builds, but it's default value is 0.

WFShortcutExtractor  extractShortcutFile:completion: will use isEqualToString to check if the file contains "AEA1" to determine if a shortcut is a signed shortcut file or not.
