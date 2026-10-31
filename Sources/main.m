#import <Cocoa/Cocoa.h>
#import <ServiceManagement/ServiceManagement.h>
#import "SCBridge.h"

static NSString *const PreferredKey=@"PreferredDeviceUUID";
static NSString *const AutoKey=@"ConnectOnceOnLaunch";

@interface SCApp : NSObject <NSApplicationDelegate, NSWindowDelegate>
@property(nonatomic) BOOL safePreview;
@end

@implementation SCApp {
    SCNativeBackend *_backend;
    SCSession *_session;
    NSWindow *_window;
    NSStatusItem *_statusItem;
    NSTextField *_status;
    NSTextField *_detail;
    NSPopUpButton *_devices;
    NSButton *_connect;
    NSButton *_disconnect;
    NSButton *_refresh;
    NSButton *_automatic;
    NSButton *_login;
    NSTextField *_loginStatus;
    NSArray<SCPeer *> *_peers;
    NSMutableArray<NSDictionary *> *_events;
    NSTimer *_timer;
    BOOL _autoConsumed;
    NSDate *_autoDeadline;
    NSString *_message;
}
- (NSButton *)button:(NSString *)title action:(SEL)action {
    return [NSButton buttonWithTitle:title target:self action:action];
}
- (NSTextField *)label:(NSString *)text size:(CGFloat)size color:(NSColor *)color {
    NSTextField *field=[NSTextField wrappingLabelWithString:text];
    field.font=[NSFont systemFontOfSize:size];field.textColor=color;
    field.preferredMaxLayoutWidth=470;return field;
}
- (void)applicationDidFinishLaunching:(NSNotification *)note {
    (void)note;_events=[NSMutableArray array];_peers=@[];
    _autoConsumed=self.safePreview;_autoDeadline=[NSDate dateWithTimeIntervalSinceNow:600];
    NSError *error=nil;_backend=[[SCNativeBackend alloc]initWithError:&error];
    _session=[[SCSession alloc]initWithBackend:_backend timeout:30];
    __weak SCApp *weakSelf=self;
    _session.changed=^(NSString *status){
        SCApp *app=weakSelf;if(!app)return;
        [app showStatus:status];
        if(!app->_session.busy)[app refresh:nil];
    };
    _session.record=^(NSDictionary *event){[weakSelf record:event];};
    [self buildMenu];[self buildWindow];
    [self showStatus:error.localizedDescription?:@"Ready. Choose your iPad to connect."];
    if(_backend)[self refresh:nil];
    _timer=[NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(poll:) userInfo:nil repeats:YES];
    // A login launch stays in the menu bar. Manual launch opens the controls.
    BOOL loginLaunch=[NSAppleEventManager.sharedAppleEventManager.currentAppleEvent paramDescriptorForKeyword:keyAEPropData].enumCodeValue==keyAELaunchedAsLogInItem;
    if(!loginLaunch || self.safePreview)[self showWindow:nil];
}
- (void)buildMenu {
    _statusItem=[NSStatusBar.systemStatusBar statusItemWithLength:NSVariableStatusItemLength];
    _statusItem.button.image=[NSImage imageWithSystemSymbolName:@"display.2" accessibilityDescription:@"SideHustle"];
    NSMenu *menu=[NSMenu new];
    for(NSArray *entry in @[@[@"SideHustle…",NSStringFromSelector(@selector(showWindow:)),@""],@[@"Display Settings…",NSStringFromSelector(@selector(openDisplays:)),@""],@[@"Quit SideHustle",NSStringFromSelector(@selector(quit:)),@"q"]]) {
        NSMenuItem *item=[[NSMenuItem alloc]initWithTitle:entry[0] action:NSSelectorFromString(entry[1]) keyEquivalent:entry[2]];
        item.target=self;[menu addItem:item];
    }
    _statusItem.menu=menu;
    NSMenu *main=[NSMenu new];NSMenuItem *root=[NSMenuItem new];[main addItem:root];
    NSMenu *application=[NSMenu new];root.submenu=application;
    NSMenuItem *quit=[[NSMenuItem alloc]initWithTitle:@"Quit SideHustle" action:@selector(quit:) keyEquivalent:@"q"];quit.target=self;
    [application addItem:quit];NSApp.mainMenu=main;
}
- (void)buildWindow {
    _window=[[NSWindow alloc]initWithContentRect:NSMakeRect(0,0,550,590) styleMask:NSWindowStyleMaskTitled|NSWindowStyleMaskClosable|NSWindowStyleMaskMiniaturizable backing:NSBackingStoreBuffered defer:NO];
    _window.title=@"SideHustle";_window.delegate=self;_window.releasedWhenClosed=NO;[_window center];
    NSStackView *stack=[NSStackView new];stack.orientation=NSUserInterfaceLayoutOrientationVertical;
    stack.alignment=NSLayoutAttributeLeading;stack.spacing=14;stack.translatesAutoresizingMaskIntoConstraints=NO;
    [_window.contentView addSubview:stack];
    [NSLayoutConstraint activateConstraints:@[[stack.leadingAnchor constraintEqualToAnchor:_window.contentView.leadingAnchor constant:30],[stack.trailingAnchor constraintEqualToAnchor:_window.contentView.trailingAnchor constant:-30],[stack.topAnchor constraintEqualToAnchor:_window.contentView.topAnchor constant:28]]];
    NSTextField *title=[self label:@"Your iPad. One click away." size:25 color:NSColor.labelColor];title.font=[NSFont boldSystemFontOfSize:25];[stack addArrangedSubview:title];
    [stack addArrangedSubview:[self label:@"Connect through native Sidecar. Keep the standard menu when it already works." size:13 color:NSColor.secondaryLabelColor]];
    _status=[self label:@"Checking this Mac…" size:14 color:NSColor.labelColor];[stack addArrangedSubview:_status];
    _devices=[[NSPopUpButton alloc]initWithFrame:NSZeroRect pullsDown:NO];_devices.target=self;_devices.action=@selector(selectDevice:);
    [_devices.widthAnchor constraintEqualToConstant:470].active=YES;[stack addArrangedSubview:_devices];
    _detail=[self label:@"No iPad selected." size:12 color:NSColor.secondaryLabelColor];[stack addArrangedSubview:_detail];
    _connect=[self button:@"Connect" action:@selector(connect:)];_connect.bezelStyle=NSBezelStyleRounded;
    _disconnect=[self button:@"Disconnect" action:@selector(disconnect:)];
    _refresh=[self button:@"Refresh" action:@selector(refresh:)];
    NSStackView *actions=[NSStackView stackViewWithViews:@[_connect,_disconnect,_refresh]];actions.spacing=10;[stack addArrangedSubview:actions];
    [stack addArrangedSubview:[self label:@"Make it convenient" size:15 color:NSColor.labelColor]];
    _automatic=[NSButton checkboxWithTitle:@"Connect to this iPad once when the app opens" target:self action:@selector(changeAutomatic:)];
    _automatic.state=[NSUserDefaults.standardUserDefaults boolForKey:AutoKey]?NSControlStateValueOn:NSControlStateValueOff;[stack addArrangedSubview:_automatic];
    [stack addArrangedSubview:[self label:@"Waits up to 10 minutes for your chosen iPad. Makes one attempt; never takes over an existing session." size:12 color:NSColor.secondaryLabelColor]];
    _login=[NSButton checkboxWithTitle:@"Open at login" target:self action:@selector(changeLogin:)];[stack addArrangedSubview:_login];
    _loginStatus=[self label:@"" size:12 color:NSColor.secondaryLabelColor];[stack addArrangedSubview:_loginStatus];
    NSStackView *links=[NSStackView stackViewWithViews:@[[self button:@"Display Settings…" action:@selector(openDisplays:)],[self button:@"Login Items…" action:@selector(openLogin:)],[self button:@"Save Diagnostics…" action:@selector(saveDiagnostics:)]]];links.spacing=8;[stack addArrangedSubview:links];
    [stack addArrangedSubview:[self label:@"Use the same Apple Account with 2FA. For USB, unlock the iPad and trust this Mac. Quitting leaves an established Sidecar session running." size:12 color:NSColor.secondaryLabelColor]];
    [stack addArrangedSubview:[self label:@"Preview • macOS build 26B123 • No system patch required" size:11 color:NSColor.tertiaryLabelColor]];
    [self updateLogin];
}
- (void)record:(NSDictionary *)event {
    NSMutableDictionary *entry=[event mutableCopy];entry[@"timeUTC"]=[[NSISO8601DateFormatter new]stringFromDate:NSDate.date];
    [_events addObject:entry];if(_events.count>100)[_events removeObjectAtIndex:0];
}
- (void)showStatus:(NSString *)message { _message=[message copy];_status.stringValue=message;[self updateControls]; }
- (SCPeer *)selectedPeer {
    NSInteger i=_devices.indexOfSelectedItem;return i>=0 && (NSUInteger)i<_peers.count?_peers[(NSUInteger)i]:nil;
}
- (void)updateControls {
    SCPeer *peer=[self selectedPeer];BOOL busy=_session.busy;
    _connect.enabled=!self.safePreview && _backend && peer && !peer.connected && !busy && !_session.blocked && [_backend connectedCount]==0;
    _disconnect.enabled=!self.safePreview && _backend && peer.connected && !busy;
    _refresh.enabled=_backend && !busy;_devices.enabled=_backend && !busy && _peers.count>0;
    _automatic.enabled=!self.safePreview && _backend && peer && !busy;
    _login.enabled=!self.safePreview;
    _detail.stringValue=peer?[NSString stringWithFormat:@"%@ · %@%@",peer.model,peer.connected?@"Connected":@"Available",peer.nativeEligible?@"":@" · Native model list excludes this iPad"]:@"Connect and unlock your iPad, then refresh.";
    _statusItem.button.toolTip=busy?@"SideHustle — working":([_backend connectedCount]?@"SideHustle — Sidecar connected":@"SideHustle");
}
- (void)refresh:(id)sender {
    (void)sender;if(!_backend||_session.busy)return;
    NSError *error=nil;NSArray *peers=[_backend peersWithError:&error];
    if(!peers) {_peers=@[];[_devices removeAllItems];_autoConsumed=YES;[self showStatus:error.localizedDescription];return;}
    NSString *preferred=[NSUserDefaults.standardUserDefaults stringForKey:PreferredKey];
    _peers=peers;[_devices removeAllItems];NSInteger selection=-1;
    for(SCPeer *peer in peers) {
        // Names stay in local UI; never included in diagnostic exports.
        NSString *title=[NSString stringWithFormat:@"%@ — %@%@",peer.name,peer.model,peer.connected?@" (connected)":@""];
        [_devices.menu addItem:[[NSMenuItem alloc]initWithTitle:title action:NULL keyEquivalent:@""]];
        if([peer.identifier isEqualToString:preferred])selection=(NSInteger)_devices.numberOfItems-1;
    }
    if(selection>=0)[_devices selectItemAtIndex:selection];
    [self record:@{@"event":@"discovery",@"eligibleIPadCount":@(peers.count),@"connectedCount":@([_backend connectedCount])}];
    [self updateControls];
    if(!_autoConsumed && [NSUserDefaults.standardUserDefaults boolForKey:AutoKey]) {
        if(_autoDeadline.timeIntervalSinceNow<=0) {_autoConsumed=YES;[self showStatus:@"Startup connection window ended. You can connect manually."];}
        else if([_backend connectedCount]>0) {_autoConsumed=YES;[self showStatus:@"Sidecar is already connected. Your session was left as it is."];}
        else if(selection>=0) {_autoConsumed=YES;[self connect:nil];}
    }
}
- (void)poll:(NSTimer *)timer {(void)timer;[self refresh:nil];[self updateLogin];}
- (void)selectDevice:(id)sender {
    (void)sender;if(self.safePreview)return;SCPeer *peer=[self selectedPeer];if(!peer)return;
    [NSUserDefaults.standardUserDefaults setObject:peer.identifier forKey:PreferredKey];[self updateControls];
}
- (SCPeer *)freshSelection {
    NSString *identifier=[self selectedPeer].identifier;if(!identifier)return nil;
    NSError *error=nil;NSArray *peers=[_backend peersWithError:&error];
    if(!peers) {[self showStatus:error.localizedDescription];return nil;}
    NSMutableArray *matches=[NSMutableArray array];
    for(SCPeer *p in peers)if([p.identifier isEqualToString:identifier])[matches addObject:p];
    if(matches.count!=1){[self showStatus:@"The selected iPad is no longer uniquely available. Refresh and select it again."];return nil;}
    return matches[0];
}
- (void)connect:(id)sender {
    (void)sender;if(self.safePreview){[self showStatus:@"Read-only preview: connection requests are disabled."];return;}
    if(_session.busy||_session.blocked)return;
    SCPeer *peer=[self freshSelection];if(!peer)return;
    _autoConsumed=YES;[NSUserDefaults.standardUserDefaults setObject:peer.identifier forKey:PreferredKey];
    [_session connect:peer];
}
- (void)disconnect:(id)sender {
    (void)sender;if(self.safePreview){[self showStatus:@"Read-only preview: disconnection requests are disabled."];return;}
    if(_session.busy)return;SCPeer *peer=[self freshSelection];if(!peer)return;
    _autoConsumed=YES;[_session disconnect:peer];
}
- (void)changeAutomatic:(NSButton *)sender {
    if(self.safePreview)return;
    BOOL enabled=sender.state==NSControlStateValueOn;SCPeer *peer=[self selectedPeer];
    if(enabled && !peer){sender.state=NSControlStateValueOff;return;}
    if(enabled)[NSUserDefaults.standardUserDefaults setObject:peer.identifier forKey:PreferredKey];
    [NSUserDefaults.standardUserDefaults setBool:enabled forKey:AutoKey];
    // Applies on next launch; never turns a preference click into a connection.
    _autoConsumed=YES;[self showStatus:enabled?@"Startup connection enabled for your selected iPad. Applies next time the app opens.":@"Automatic connection is off."];
}
- (void)updateLogin {
    SMAppServiceStatus status=SMAppService.mainAppService.status;
    _login.state=status==SMAppServiceStatusEnabled || status==SMAppServiceStatusRequiresApproval?NSControlStateValueOn:NSControlStateValueOff;
    _loginStatus.stringValue=status==SMAppServiceStatusRequiresApproval?@"Approval is needed in System Settings → Login Items.":(status==SMAppServiceStatusEnabled?@"macOS will open this app at login.":@"Optional. Move the app to Applications before enabling.");
}
- (void)changeLogin:(NSButton *)sender {
    if(self.safePreview)return;NSError *error=nil;
    if(sender.state==NSControlStateValueOn) {
        NSString *path=NSBundle.mainBundle.bundlePath;
        NSString *userApps=[NSHomeDirectory()stringByAppendingPathComponent:@"Applications/"];
        if(![path hasPrefix:@"/Applications/"] && ![path hasPrefix:userApps]) {
            [self showStatus:@"Move SideHustle to Applications first, then enable Open at login."];[self updateLogin];return;
        }
        [SMAppService.mainAppService registerAndReturnError:&error];
    } else [SMAppService.mainAppService unregisterAndReturnError:&error];
    if(error)[self showStatus:[NSString stringWithFormat:@"Login item could not be changed (%@, %ld). Check Login Items in System Settings.",error.domain,(long)error.code]];
    [self updateLogin];
}
- (void)showWindow:(id)sender {(void)sender;[_window makeKeyAndOrderFront:nil];[NSApp activateIgnoringOtherApps:YES];}
- (void)openDisplays:(id)sender {(void)sender;[NSWorkspace.sharedWorkspace openURL:[NSURL URLWithString:@"x-apple.systempreferences:com.apple.Displays-Settings.extension"]];}
- (void)openLogin:(id)sender {(void)sender;[SMAppService openSystemSettingsLoginItems];}
- (void)saveDiagnostics:(id)sender {
    (void)sender;NSSavePanel *panel=[NSSavePanel savePanel];panel.nameFieldStringValue=@"SideHustle-diagnostics.json";
    [panel beginSheetModalForWindow:_window completionHandler:^(NSModalResponse result){
        if(result!=NSModalResponseOK)return;
        NSDictionary *diagnostics=@{@"appVersion":@"0.1.0",@"macOSBuild":self->_backend.build?:@"unsupported",@"readOnlyPreview":@(self.safePreview),@"events":self->_events,@"privacy":@"No device names, identifiers, account details, raw logs, stream keys, or NSError descriptions."};
        NSData *data=[NSJSONSerialization dataWithJSONObject:diagnostics options:NSJSONWritingPrettyPrinted|NSJSONWritingSortedKeys error:NULL];
        NSError *error=nil;if(![data writeToURL:panel.URL options:NSDataWritingAtomic error:&error])[self showStatus:@"Could not save diagnostics. Choose a writable location."];
    }];
}
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    (void)sender;if(_session.busy){[self showWindow:nil];[self showStatus:@"Wait for the pending operation and its cleanup before quitting."];return NSTerminateCancel;}
    return NSTerminateNow;
}
- (void)quit:(id)sender {(void)sender;[NSApp terminate:nil];}
- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)visible {(void)sender;if(!visible)[self showWindow:nil];return YES;}
- (BOOL)windowShouldClose:(NSWindow *)sender {(void)sender;[_window orderOut:nil];return NO;}
@end

int main(int argc,const char **argv) { @autoreleasepool {
    BOOL check=argc==2 && !strcmp(argv[1],"--self-check");
    BOOL preview=argc==2 && !strcmp(argv[1],"--safe-preview");
    if(argc>1&&!check&&!preview){fprintf(stderr,"Usage: SideHustle [--self-check | --safe-preview]\n");return 64;}
    if(check) {
        NSError *error=nil;SCNativeBackend *backend=[[SCNativeBackend alloc]initWithError:&error];
        NSArray *peers=backend?[backend peersWithError:&error]:nil;
        NSMutableArray *models=[NSMutableArray array];
        for(SCPeer *peer in peers)[models addObject:@{@"model":peer.model,@"nativeEligible":@(peer.nativeEligible),@"connected":@(peer.connected)}];
        NSDictionary *output=@{@"compatible":@(backend!=nil && peers!=nil),@"errorDomain":error.domain?:@"",@"errorCode":@(error.code),@"peers":models,@"connectedCount":@([backend connectedCount]),@"connectionRequests":@0,@"preferenceWrites":@0};
        NSData *data=[NSJSONSerialization dataWithJSONObject:output options:NSJSONWritingSortedKeys error:NULL];
        puts([[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding].UTF8String);return error?1:0;
    }
    NSApplication *application=NSApplication.sharedApplication;
    [application setActivationPolicy:NSApplicationActivationPolicyAccessory];
    SCApp *delegate=[SCApp new];delegate.safePreview=preview;application.delegate=delegate;[application run];
    return 0;
}}
