//
//  ELCImagePickerController.m
//  ELCImagePickerDemo
//
//  Created by ELC on 9/9/10.
//  Copyright 2010 ELC Technologies. All rights reserved.
//

#import "ELCImagePickerController.h"
#import "ELCAsset.h"
#import "ELCAssetCell.h"
#import "ELCAssetTablePicker.h"
#import "ELCAlbumPickerController.h"
#import <CoreLocation/CoreLocation.h>

@implementation ELCImagePickerController

//Using auto synthesizers

- (id)initImagePicker
{
    ELCAlbumPickerController *albumPicker = [[ELCAlbumPickerController alloc] initWithStyle:UITableViewStylePlain];
    
    self = [super initWithRootViewController:albumPicker];
    if (self) {
        self.maximumImagesCount = 4;
        [albumPicker setParent:self];
    }
    return self;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        self.maximumImagesCount = 4;
    }
    return self;
}

- (void)cancelImagePicker
{
	if ([_imagePickerDelegate respondsToSelector:@selector(elcImagePickerControllerDidCancel:)]) {
		[_imagePickerDelegate performSelector:@selector(elcImagePickerControllerDidCancel:) withObject:self];
	}
}

- (BOOL)shouldSelectAsset:(ELCAsset *)asset previousCount:(NSUInteger)previousCount
{
	// Check if asset is availble. Photo stream photos that have not been
	// downloaded to device returns nil on defaultRepresentation, and we've
	// no way to trigger the download
	if (![[asset asset] defaultRepresentation])
	{
		UIAlertView *alert =
		[[UIAlertView alloc] initWithTitle:self.photoStreamPhotoUnavailableTitle
								   message:self.photoStreamPhotoUnavailableBody
								  delegate:nil
						 cancelButtonTitle:self.okButtonTitle
						 otherButtonTitles:nil];
		[alert show];
		
		return NO;
	}
	
    BOOL shouldSelect = previousCount < self.maximumImagesCount;
    if (!shouldSelect) {
        NSString *title = [NSString stringWithFormat:self.exceededNumberOfImagesAlertTitle, self.maximumImagesCount];
        NSString *message = [NSString stringWithFormat:self.exceededNumberOfImagesAlertBody, self.maximumImagesCount];
        [[[UIAlertView alloc] initWithTitle:title
                                    message:message
                                   delegate:nil
                          cancelButtonTitle:self.okButtonTitle
                          otherButtonTitles:nil] show];
    }
    return shouldSelect;
}

- (void)selectedAssets:(NSArray *)assets
{
	NSMutableArray *returnArray = [[NSMutableArray alloc] init];
	
	for(ALAsset *asset in assets) {
		id obj = [asset valueForProperty:ALAssetPropertyType];
		if (!obj) {
			continue;
		}
		NSMutableDictionary *workingDictionary = [[NSMutableDictionary alloc] init];
		
		CLLocation* wgs84Location = [asset valueForProperty:ALAssetPropertyLocation];
		if (wgs84Location) {
			[workingDictionary setObject:wgs84Location forKey:ALAssetPropertyLocation];
		}
        
        [workingDictionary setObject:obj forKey:UIImagePickerControllerMediaType];

        //This method returns nil for assets from a shared photo stream that are not yet available locally. If the asset becomes available in the future, an ALAssetsLibraryChangedNotification notification is posted.
        ALAssetRepresentation *assetRep = [asset defaultRepresentation];

        if(assetRep != nil) {
            CGImageRef imgRef = nil;
            //defaultRepresentation returns image as it appears in photo picker, rotated and sized,
            //so use UIImageOrientationUp when creating our image below.
            UIImageOrientation orientation = UIImageOrientationUp;
            
            if (_returnsOriginalImage) {
                imgRef = [assetRep fullResolutionImage];
                orientation = (UIImageOrientation) [assetRep orientation];
            } else {
                imgRef = [assetRep fullScreenImage];
            }
            UIImage *img = [UIImage imageWithCGImage:imgRef
                                               scale:1.0f
                                         orientation:orientation];
            [workingDictionary setObject:img forKey:UIImagePickerControllerOriginalImage];
            [workingDictionary setObject:[[asset valueForProperty:ALAssetPropertyURLs] valueForKey:[[[asset valueForProperty:ALAssetPropertyURLs] allKeys] objectAtIndex:0]] forKey:UIImagePickerControllerReferenceURL];
            
            [returnArray addObject:workingDictionary];
        }
		
	}    
	if (_imagePickerDelegate != nil && [_imagePickerDelegate respondsToSelector:@selector(elcImagePickerController:didFinishPickingMediaWithInfo:)]) {
		[_imagePickerDelegate performSelector:@selector(elcImagePickerController:didFinishPickingMediaWithInfo:) withObject:self withObject:returnArray];
	} else {
        [self popToRootViewControllerAnimated:NO];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    } else {
        return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
    }
}

#pragma mark - 

- (NSString *)exceededNumberOfImagesAlertTitle
{
	if (!_exceededNumberOfImagesAlertTitle)
	{
		_exceededNumberOfImagesAlertTitle =
		[NSString stringWithFormat:NSLocalizedString(@"Too Many Images", nil),
		 (long) self.maximumImagesCount];
	}

	return _exceededNumberOfImagesAlertTitle;
}

- (NSString *)exceededNumberOfImagesAlertBody
{
	if (!_exceededNumberOfImagesAlertBody)
	{
		_exceededNumberOfImagesAlertBody =
		[NSString stringWithFormat:
		 NSLocalizedString(@"You can only choose up to %ld photos at a time.", nil),
		 (long) self.maximumImagesCount];
	}

	return _exceededNumberOfImagesAlertBody;
}

- (NSString *)photoStreamPhotoUnavailableTitle
{
	if (!_photoStreamPhotoUnavailableTitle)
	{
		_photoStreamPhotoUnavailableTitle =
		NSLocalizedString(@"Photo Not Available", nil);
	}

	return _photoStreamPhotoUnavailableTitle;
}

- (NSString *)photoStreamPhotoUnavailableBody
{
	if (!_photoStreamPhotoUnavailableBody)
	{
		_photoStreamPhotoUnavailableBody =
		NSLocalizedString(@"This photo has not been downloaded from iCloud Photo Stream. You can download it by viewing it in Photos.app first.", nil);
	}

	return _photoStreamPhotoUnavailableBody;
}

- (NSString *)okButtonTitle
{
	if (!_okButtonTitle)
	{
		_okButtonTitle =
		NSLocalizedString(@"OK", nil);
	}
	
	return _okButtonTitle;
}

@end
