#import "FilePickerPlugin.h"
#import <Cocoa/Cocoa.h>

@implementation FilePickerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"file_picker"
            binaryMessenger:[registrar messenger]];
  FilePickerPlugin* instance = [[FilePickerPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"pickFile" isEqualToString:call.method]) {
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO];
    
    NSArray* allowedExtensions = @[@"json", @"characterbook", @"character", @"race", @"chax"];
    [panel setAllowedFileTypes:allowedExtensions];
    
    if ([panel runModal] == NSModalResponseOK) {
      NSString* path = [[[panel URLs] firstObject] path];
      result(path);
    } else {
      result(nil);
    }
  } else {
    result(FlutterMethodNotImplemented);
  }
}
@end