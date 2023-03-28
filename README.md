# RandomShortcutsRev
2
Random rev of shortcuts (mostly iOS 15.2/15.4 WorkflowKit). By absolutely no means even close to complete, I really just do stuff randomly.
3
​
4
I started this to potentially look into some vulns with Shortcut Signing. iOS 15.0b1 had a rather embarassing bug that was found and published a couple hours after release where you could simply name a unsigned shortcut to .wflow (old file extension) and it would import properly. This made me curious as to how Shortcuts are imported, and if there was any bug that could be triggered not with checking the shortcuts signature, but with the importing itself (such as with 15b1) in Shortcuts. I was not able to find anything - I came *close* and found something that may lead to one (that is, assuming you can even craft an unsigned shortcut that could be importable beginning with AEA1) but have not got anything from it yet. This is why a lot of the classes on here are related to shortcuts signing. I have, however, looked into some various other stuff in WorkflowKit, such as WFBundledActionProvider, the class for loading actions from WFActions.plist.
5
​
6
This reverse engineering project of WorkflowKit.framework is highly incomplete and innaccurate, and I would advise attempting to rely upon it. However - it does still feature some useful info for some methods who's behavior (tmk) have never been documented - hence IMO this may be still useful for some people.
7
​
8
​
9
# Shortcuts File Format
10
On iOS 13, shortcuts are stored in /var/mobile/Library/Shortcuts/Shortcuts.realm. However, iOS 14 changes this to be in Shortcuts.sqlite. On iOS 12/13/14 devices, a shortcut that's stored on a device can be exported as an unsigned .shortcut file by using the Get My Shortcuts action (You can use a Save File action to save the output). iOS 15 is slightly different, however: you can't export shortcuts on device as unsigned shortcuts using Get My Shortcuts, only signed. (Shortcuts in iOS 15 are signed with Apple Encrypted Archives - learn more about them here: https://man.cameronkatri.com/macOS/aea). You can, however, get a unsigned .shortcut from the iCloud API. Let's upload a shortcut to iCloud, and imagine our link is https://www.icloud.com/shortcuts/77dfe31578ac4f6fb084ebb418b34a49. Change /shortcuts/ to /shortcuts/api/records/ (https://www.icloud.com/shortcuts/api/records/77dfe31578ac4f6fb084ebb418b34a49). The value for fields.shortcut.value.downloadURL should be the URL for the unsigned .shortcut (Note: If you opened in Safari, change \/ to / in the URL). After getting the unsigned .shortcut, rename this to a plist and you should be able to easily open this in Xcode (or, use set name to rename to something.plist with Do Not Include File Extension on, and Get Text from that).
11
​
12
So, now lets go over the keys:
13
​
14
* WFWorkflowClientVersion - This is the number that represents the client version that the shortcut was shared on.
15
* WFWorkflowImportQuestions - The import questions for the shortcut
16
* WFWorkflowName - Name of the shortcut (Seems to be ignored on most modern versions of shortcuts)
17
* WFWorkflowMinimumClientVersion - The minimum client version the shortcut can be imported in.
18
* WFWorkflowMinimumClientVersionString - Same thing as WFWorkflowMinimumClientVersion but a string.
19
* WFWorkflowIcon - The Icon
20
* WFWorkflowInputContentItemClasses - What the shortcut accepts as input
21
* WFWorkflowTypes - Hard to explain, use sebj's documentation instead if you want this explained, but you likely won't touch this anyway
22
* WFWorkflowActions - this is the big one that matters. It's an array of the different shortcut actions.
23
​
24
# Actions
25
We're going to have a shortcut with a comment action that contains "Chocolate". Let’s take a look at a simple comment action:
26
​
```plist
27
<dict>
28
            <key>WFWorkflowActionIdentifier</key>
29
            <string>is.workflow.actions.comment</string>
30
            <key>WFWorkflowActionParameters</key>
31
            <dict>
32
                <key>WFCommentActionText</key>
33
                <string>Chocolate</string>
34
            </dict>
35
        </dict>
```
36
The value “is.workflow.actions.comment” in the WFWorkflowActionIdentifier indicates that it’s a comment action, and the Chocolate value in the WFCommentActionText key indicates that the Comment action contains the text "Chocolate".
37
​
38
Just a warning for magic variables: these contain an invisible character. Be careful not to accidentally remove it. Here’s an example of what it looks like, with the invisible character replaced with "(INVISIBLE CHARACTER)" (Thanks to ActuallyTaylor for sending me this and helping me figure out where it was!):
39
​```plist
40
<dict>
41
            <key>WFWorkflowActionIdentifier</key>
42
            <string>is.workflow.actions.gettext</string>
43
            <key>WFWorkflowActionParameters</key>
44
            <dict>
45
                <key>WFTextActionText</key>
46
                <dict>
47
                    <key>Value</key>
48
                    <dict>
49
                        <key>attachmentsByRange</key>
50
                        <dict>
51
                            <key>{15, 1}</key>
52
                            <dict>
53
                                <key>Aggrandizements</key>
54
                                <array/>
55
                                <key>Type</key>
56
                                <string>ExtensionInput</string>
57
                            </dict>
58
                        </dict>
59
                        <key>string</key>
60
                        <string>Shortcut Input (INVISIBLE CHARACTER)</string>
61
                    </dict>
62
                    <key>WFSerializationType</key>
63
                    <string>WFTextTokenString</string>
64
                </dict>
65
            </dict>
66
        </dict>
```

# WFActions.plist

`/System/Library/PrivateFrameworks/WorkflowKit.framework/WFActions.plist` is the location of the WFActions.plist file. This file is a list of the default actions that is loaded by the `WFBundledActionProvider` class. Here's an example of the flashlight action and how it looks in it:

```plist
<key>is.workflow.actions.flashlight</key>
<dict>
 <key>Attribution</key>
 <string>Flashlight</string>
 <key>InputPassthrough</key>
 <true/>
 <key>ActionKeywords</key>
 <array>
  <string>flash</string>
  <string>torch</string>
  <string>turn</string>
 </array>
 <dict>
  <key>BundleIdentifier</key>
  <string>com.apple.Preferences</string>
 </dict>
 <key>ActionClass</key>
 <string>WFHandleCustomIntentAction</string>
 <key>ParameterOverrides</key>
 <dict>
  <key>Key</key>
  <string>WFFlashlightLevel</string>
  <key>RequiredResources</key>
  <array>
   <key>WFParameterKey</key>
   <string>state</string>
   <key>WFParameterRelation</key>
   <string>!=</string>
   <key>WFResourceClass</key>
   <string>WFParameterRelationResource</string>
   <key>WFParameterValue</key>
   <integer>0</integer>
   <key>RequiredResources</key>
   <array>
   <key>WFResourceClass</key>
   <string>WFParameterRelationResource</string>
   <key>WFParameterValue</key>
   <string>set</string>
  <key>WFParameterKey</key>
  <string>operation</string>
 </array>
</array> 
</dict>
 <key>Subcategory</key>
 <string>Device</string>
 <key>Category</key>
 <string>Scripting</string>
 <key>ParameterSummary</key>
 <dict>
  <key>operation,state</key>
  <string>${operation} flashlight ${state}</string>
  <key>operation,state,WFFlashlightLevel</key>
  <string>${operation} flashlight ${state}</string>
  <key>operation,WFFlashlightLevel</key>
  <string>${operation} flashlight</string>


 </dict>
 <key>IconName</key>
 <string>Flashlight.png</string>
 <key>IntentIdentifier</key>
 <string>sirikit.intents.custom.com.apple.ActionKit.BundledIntentHandler.WFSetFlashlightIntent</string>
</dict>
```

So - the overlying key following the dict for the action is its action identifier - `is.workflow.actions.flashlight`. Another thing to note is `ActionClass`, which is used by WFBundledActionProvider to use as the class for the action.

# Types of shortcuts

Unsigned Shortcuts - Aka, the normal file format for iOS 14 and below, can be a binary plist or xml plist. Not importable by normal means on iOS 15+.
Contact-Signed Shortcuts - A AEA (Apple Encrypted Archive) shortcut that is only openable by some of your contacts.
iCloud-Signed Shortcuts - A AEA (Apple Encrypted Archive) shortcut that can be opened by anyone. It contains the iCloud ID of the signed shortcut.
Default Shortcuts - In `/System/Library/PrivateFrameworks/WorkflowKit.framework/WFDefaultShortcuts.plist`, there is a plist containing iCloud identifiers of shortcuts to be used as default. What's interesting is that this is the only shortcut file type I could find (tmk, with exception of automator to shortcut conversion on macOS) that is importable and does not sign check, but not like you're going to change this file anyway so no security risk there.
iCloud Shared Shortcuts (WFSharedShortcut) - iCloud Signed Shortcut.
Gallery Shortcuts (WFGalleryShortcuts) - Yes, these are different from default shortcuts. Basically same thing as iCloud Shared Shortcuts (which are iCloud Signed Shortcuts).
