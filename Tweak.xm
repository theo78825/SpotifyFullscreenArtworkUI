//MIT License
//
//Copyright (c) 2017 Sam Albert
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.
//
////////////////////////
// The code has not been cleaned up. I am aware there are better ways to do this
// but I am new to tweak development so either don’t know how or don’t have time.
// Thanks to Gh0stbyte for some code contribution
////////////////////////


#import <UIKit/UIKit.h>

double screenWidth = [UIScreen mainScreen].bounds.size.width;
CGSize screenWidthCG = {[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.width};
double screenHeight = [UIScreen mainScreen].bounds.size.height;
double remain = screenHeight - screenWidth; //292
CGPoint artworkCenter = {0,35}; //20,70
double halfHeight = [UIScreen mainScreen].bounds.size.height/2;
double var1 = [UIScreen mainScreen].bounds.size.height/2 - [UIScreen mainScreen].bounds.size.width/2;
double var2 = [UIScreen mainScreen].bounds.size.width-[UIScreen mainScreen].bounds.size.height/2;
double iPhone7Plus = 414;
double iPhone7PlusZoom = 375;
double iPhone7 = 375;
double iPhone7Zoom = 320;
double iPhone5S = 320;
double iPadMini4Portrait = 768;
double iPadMini4Landscape = 1024;




//Size for the now playing artwork. The first number is width and the second is height.
CGSize newSize = {[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.width};
@interface MSHJelloViewConfig : NSObject
-(bool)enabled;
@property (nonatomic, assign) UIColor *waveColor;
@property (nonatomic, assign) UIColor *subwaveColor;
@end
@interface MSHJelloView : NSObject
@property (nonatomic, assign) MSHJelloViewConfig *config;
@end
@interface MSHJelloLayer
@property (nonatomic, assign) CGColorRef backgroundColor;
@property (nonatomic, assign) CGColorRef borderColor;
@property (nonatomic, assign) CGColorRef strokeColor;
@property (nonatomic, assign) CGColorRef fillColor;
@end
@interface UIView (Hello)
-(void)setFrameSize:(CGSize)frameSize;
-(void)initWithFrame:(CGRect)frame;
-(void)layoutSubviews;
@end
@interface SPTGeniusNowPlayingViewControllerImpl : UIViewController 
@end
@interface SPTNowPlayingCoverArtController : UIViewController 
@end
@interface SPTNowPlayingCoverArtImageContentView : UIImageView
@end
@interface SPTNowPlayingCoverArtView : NSObject
@property (nonatomic, assign) UIView *view;
@end
@interface SPTNowPlayingPlaybackController
-(bool)isPaused;
@end




//Setting the size of the artwork
%hook SPTNowPlayingCoverArtImageContentView
-(void)setImageURL:(id)URL image:(id)image imageSize:(CGSize)size {	
	%orig(URL, image, newSize); 
}
%end
%hook SPTNowPlayingCoverArtController
-(id)nowPlayingCoverArtView:(id)artView contentForCell:(id)cell cellSize:(CGSize)size relativePage:(long)page {return %orig(artView, cell, newSize, page); 	//self.view.autoresizesSubviews = NO;
}
-(id)nowPlayingCoverArtViewContentForStagedContextCell:(id)cell cellSize:(CGSize)size {return %orig(cell, newSize); }

%end

%hook SPTNowPlayingCoverArtViewCell
-(CGSize)cellSize { return newSize; }
-(CGSize)fullscreenSize { 
	return newSize; 
}
%end
%hook SPTQueueViewControllerImplementation
-(CGSize)preferredContentSize { return newSize; }
%end
%hook SPTGeniusCardContainerView 
-(CGSize)introLogoSize { return newSize; }
%end
%hook SPTGeniusNowPlayingViewCoverArtView
-(CGRect)frame { return CGRectMake(0,0,newSize.width, newSize.height);}
-(NSRect)bounds { return CGRectMake(0,0,newSize.width, newSize.height);}
-(CGSize)size { return newSize; }
%end
%hook SPTGeniusNowPlayingViewControllerImpl
-(void)viewWillLayoutSubviews {	
	%orig;	
	[self.view setFrameSize:newSize]; }
-(bool)isGeniusEnabled { return FALSE; }
%end

%hook SPTGeniusFeatureImplementation
-(bool) isGeniusEnabled { return FALSE; }
%end

%hook SPTGeniusService
-(bool) geniusProxyIsEnabled { return FALSE; }
-(bool) enabled { return FALSE; }
%end


///////////////////////////////////
//Mitsuha Fix (Make sure wave layers show)
///////////////////////////////////

///////////////////////////////////
//Config
//Amount of points the wave will have.
#define PointCount 10
//Width of the stroke on the wave.
#define StrokeWidth 1.0





//The size of the stroke of color around the wave. 
%hook MSHJelloLayer
-(CGFloat)lineWidth {
	return StrokeWidth;
}
%end

//Grab an instance of the SPTNOwPlayingPlaybackController to check if media is playing.
SPTNowPlayingPlaybackController *playbackController;
%hook SPTNowPlayingPlaybackController
-(id)initWithPlayer:(id)player trackPosition:(id)position adsManager:(id)manager trackMetadataQueue:(id)queue {
	playbackController = %orig;
	return playbackController;
}
%end
%hook MSHJelloView
-(MSHJelloLayer*)subwaveLayer {
	if([self.config.subwaveColor CGColor]) {
		%orig.fillColor = [self.config.subwaveColor CGColor];
		return %orig;
	}
	else {
		return %orig;
	}
}

-(MSHJelloLayer*)waveLayer {
	if([self.config.waveColor CGColor]) {
		%orig.fillColor = [self.config.waveColor CGColor];
		return %orig;
	}
	else {
		return %orig;
	}
}

-(id)initWithFrame:(CGRect)frame andConfig:(id)config {
	return %orig(CGRectMake(0,100,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height), config);
}

%end
MSHJelloViewConfig *mitsuha;
%hook MSHJelloViewConfig
// Grab an instance of Mitsuha
-(id)initWithDictionary:(id)dictionary {
	mitsuha = %orig;
	return mitsuha;
}
%end
%hook SPTNowPlayingCoverArtView

-(NSRect)bounds { 
	// Mitsuha causes the artwork to shift and must be compensated for
	// Ideally this would be simplified to ‘align to top’ but am unsure how to do this
	if ([mitsuha enabled]) {
		if(screenWidth == iPhone7PlusZoom) {
		return CGRectMake(0, 15,[UIScreen mainScreen].bounds.size.height/2,[UIScreen mainScreen].bounds.size.height/2); 
		}
		if(screenWidth == iPhone7Plus) {
		return CGRectMake(0, 18,[UIScreen mainScreen].bounds.size.height/2,[UIScreen mainScreen].bounds.size.height/2); 
		}
		else if(screenWidth == iPhone7Zoom) {
		return CGRectMake(0, 10.5,[UIScreen mainScreen].bounds.size.height/2,[UIScreen mainScreen].bounds.size.height/2); 
		}
		else if(screenWidth == iPhone7) {
		return CGRectMake(0, 15,[UIScreen mainScreen].bounds.size.height/2,[UIScreen mainScreen].bounds.size.height/2); 
		}
		else if(screenWidth == iPhone5S) {
		return CGRectMake(0, 10.5,[UIScreen mainScreen].bounds.size.height/2,[UIScreen mainScreen].bounds.size.height/2); 
		}
		else if(screenWidth == iPadMini4Portrait) {
		return CGRectMake(0, -55,[UIScreen mainScreen].bounds.size.height/2,[UIScreen mainScreen].bounds.size.height/2); 
		}
		//else if(screenWidth == iPadMini4Landscape) {
		//return CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.height/2,[UIScreen mainScreen].bounds.size.height/2); 
		//}
		else {
		return CGRectMake(0, 9,[UIScreen mainScreen].bounds.size.height/2,[UIScreen mainScreen].bounds.size.height/2); 
		}
	}
	else {
	// https://www.paintcodeapp.com/news/ultimate-guide-to-iphone-resolutions
	if(screenWidth == iPhone7PlusZoom) {
	return CGRectMake(0, 50,[UIScreen mainScreen].bounds.size.height/2,[UIScreen mainScreen].bounds.size.height/2); 
	}
	else if(screenWidth == iPhone7Plus) {
	return CGRectMake(0, 60,[UIScreen mainScreen].bounds.size.height/2,[UIScreen mainScreen].bounds.size.height/2); 
	}
	else if(screenWidth == iPhone7Zoom) {
	return CGRectMake(0, 35,[UIScreen mainScreen].bounds.size.height/2,[UIScreen mainScreen].bounds.size.height/2); 
	}
	else if(screenWidth == iPhone7) {
	return CGRectMake(0, 50,[UIScreen mainScreen].bounds.size.height/2,[UIScreen mainScreen].bounds.size.height/2); 
	}
	else if(screenWidth == iPhone5S) {
	return CGRectMake(0, 35,[UIScreen mainScreen].bounds.size.height/2,[UIScreen mainScreen].bounds.size.height/2); 
	}
	else if(screenWidth == iPadMini4Portrait) {
	return CGRectMake(0, 11,[UIScreen mainScreen].bounds.size.height/2,[UIScreen mainScreen].bounds.size.height/2); 
	}
	//else if(screenWidth == iPadMini4Landscape) {
	//return CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.height/2,[UIScreen mainScreen].bounds.size.height/2); 
	//}
	else {
	return CGRectMake(0, 30,[UIScreen mainScreen].bounds.size.height/2,[UIScreen mainScreen].bounds.size.height/2); 
	}}
}


%end



