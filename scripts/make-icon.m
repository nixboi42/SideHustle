#import <AppKit/AppKit.h>

int main(int argc,const char **argv) {@autoreleasepool {
    if(argc!=2)return 64;
    NSString *folder=@(argv[1]);
    for(NSNumber *base in @[@16,@32,@128,@256,@512])for(NSNumber *factor in @[@1,@2]) {
        NSInteger size=base.integerValue*factor.integerValue;
        NSBitmapImageRep *bitmap=[[NSBitmapImageRep alloc]initWithBitmapDataPlanes:NULL pixelsWide:size pixelsHigh:size bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO colorSpaceName:NSDeviceRGBColorSpace bytesPerRow:0 bitsPerPixel:0];
        NSGraphicsContext *context=[NSGraphicsContext graphicsContextWithBitmapImageRep:bitmap];
        [NSGraphicsContext saveGraphicsState];NSGraphicsContext.currentContext=context;
        NSAffineTransform *transform=[NSAffineTransform transform];[transform scaleBy:(CGFloat)size/1024];[transform concat];
        NSBezierPath *background=[NSBezierPath bezierPathWithRoundedRect:NSMakeRect(40,40,944,944) xRadius:210 yRadius:210];
        NSGradient *gradient=[[NSGradient alloc]initWithStartingColor:[NSColor colorWithSRGBRed:0.25 green:0.37 blue:0.93 alpha:1] endingColor:[NSColor colorWithSRGBRed:0.55 green:0.28 blue:0.88 alpha:1]];
        [gradient drawInBezierPath:background angle:45];
        [NSColor.whiteColor setStroke];
        NSBezierPath *monitor=[NSBezierPath bezierPathWithRoundedRect:NSMakeRect(180,330,530,400) xRadius:34 yRadius:34];monitor.lineWidth=28;[monitor stroke];
        NSBezierPath *stand=[NSBezierPath bezierPath];[stand moveToPoint:NSMakePoint(445,330)];[stand lineToPoint:NSMakePoint(445,250)];[stand moveToPoint:NSMakePoint(345,250)];[stand lineToPoint:NSMakePoint(545,250)];stand.lineWidth=28;stand.lineCapStyle=NSLineCapStyleRound;[stand stroke];
        NSBezierPath *tablet=[NSBezierPath bezierPathWithRoundedRect:NSMakeRect(600,210,245,360) xRadius:35 yRadius:35];
        [[NSColor colorWithSRGBRed:0.36 green:0.29 blue:0.82 alpha:1]setFill];[tablet fill];tablet.lineWidth=26;[tablet stroke];
        [[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(708,229,25,25)]fill];
        [NSGraphicsContext restoreGraphicsState];
        NSString *name=[NSString stringWithFormat:@"icon_%@x%@%@.png",base,base,factor.integerValue==2?@"@2x":@""];
        NSData *png=[bitmap representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
        if(![png writeToFile:[folder stringByAppendingPathComponent:name] atomically:YES])return 1;
    }
    return 0;
}}
