# RandomShortcutsRev
Random rev of shortcuts (mostly iOS 15.2/15.4 WorkflowKit). By absolutely no means even close to complete, I really just do stuff randomly.

I started this to potentially look into some vulns with Shortcut Signing. iOS 15.0b1 had a rather embarassing bug that was found and published a couple hours after release where you could simply name a unsigned shortcut to .wflow (old file extension) and it would import properly. This made me curious as to how Shortcuts are imported, and if there was any bug that could be triggered not with checking the shortcuts signature, but with the importing itself (such as with 15b1) in Shortcuts. I was not able to find anything - I came *close* and found something that may lead to one (that is, assuming you can even craft an unsigned shortcut that could be importable beginning with AEA1) but have not got anything from it yet. This is why a lot of the classes on here are related to shortcuts signing. I have, however, looked into some various other stuff in WorkflowKit, such as WFBundledActionProvider, the class for loading actions from WFActions.plist.

This reverse engineering project of WorkflowKit.framework is highly incomplete and innaccurate, and I would advise attempting to rely upon it. However - it does still feature some useful info for some methods who's behavior (tmk) have never been documented - hence IMO this may be still useful for some people.


# Shortcuts File Format
On iOS 13, shortcuts are stored in /var/mobile/Library/Shortcuts/Shortcuts.realm. However, iOS 14 changes this to be in Shortcuts.sqlite. On iOS 12/13/14 devices, a shortcut that's stored on a device can be exported as an unsigned .shortcut file by using the Get My Shortcuts action (You can use a Save File action to save the output). iOS 15 is slightly different, however: you can't export shortcuts on device as unsigned shortcuts using Get My Shortcuts, only signed. (Shortcuts in iOS 15 are signed with Apple Encrypted Archives - learn more about them here: https://man.cameronkatri.com/macOS/aea). You can, however, get a unsigned .shortcut from the iCloud API. Let's upload a shortcut to iCloud, and imagine our link is https://www.icloud.com/shortcuts/77dfe31578ac4f6fb084ebb418b34a49. Change /shortcuts/ to /shortcuts/api/records/ (https://www.icloud.com/shortcuts/api/records/77dfe31578ac4f6fb084ebb418b34a49). The value for fields.shortcut.value.downloadURL should be the URL for the unsigned .shortcut (Note: If you opened in Safari, change \/ to / in the URL). After getting the unsigned .shortcut, rename this to a plist and you should be able to easily open this in Xcode (or, use set name to rename to something.plist with Do Not Include File Extension on, and Get Text from that).

So, now lets go over the keys:

* WFWorkflowClientVersion - This is the number that represents the client version that the shortcut was shared on.
* WFWorkflowImportQuestions - The import questions for the shortcut
* WFWorkflowName - Name of the shortcut
* WFWorkflowMinimumClientVersion - The minimum client version the shortcut can be imported in.
* WFWorkflowMinimumClientVersionString - Same thing as WFWorkflowMinimumClientVersion but a string.
* WFWorkflowIcon - The Icon
* WFWorkflowInputContentItemClasses - What the shortcut accepts as input
* WFWorkflowTypes - Hard to explain, use sebj's documentation instead if you want this explained, but you likely won't touch this anyway
* WFWorkflowActions - this is the big one that matters. It's an array of the different shortcut actions.

# Actions
We're going to have a shortcut with a comment action that contains "Chocolate". Let’s take a look at a simple comment action:

<dict>
            <key>WFWorkflowActionIdentifier</key>
            <string>is.workflow.actions.comment</string>
            <key>WFWorkflowActionParameters</key>
            <dict>
                <key>WFCommentActionText</key>
                <string>Chocolate</string>
            </dict>
        </dict>
The value “is.workflow.actions.comment” in the WFWorkflowActionIdentifier indicates that it’s a comment action, and the Chocolate value in the WFCommentActionText key indicates that the Comment action contains the text "Chocolate".

Just a warning for magic variables: these contain an invisible character. Be careful not to accidentally remove it. Here’s an example of what it looks like, with the invisible character replaced with "(INVISIBLE CHARACTER)" (Thanks to ActuallyTaylor for sending me this and helping me figure out where it was!):

<dict>
            <key>WFWorkflowActionIdentifier</key>
            <string>is.workflow.actions.gettext</string>
            <key>WFWorkflowActionParameters</key>
            <dict>
                <key>WFTextActionText</key>
                <dict>
                    <key>Value</key>
                    <dict>
                        <key>attachmentsByRange</key>
                        <dict>
                            <key>{15, 1}</key>
                            <dict>
                                <key>Aggrandizements</key>
                                <array/>
                                <key>Type</key>
                                <string>ExtensionInput</string>
                            </dict>
                        </dict>
                        <key>string</key>
                        <string>Shortcut Input (INVISIBLE CHARACTER)</string>
                    </dict>
                    <key>WFSerializationType</key>
                    <string>WFTextTokenString</string>
                </dict>
            </dict>
        </dict>
