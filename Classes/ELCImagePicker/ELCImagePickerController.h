//
//  ELCImagePickerController.h
//  ELCImagePickerDemo
//
//  Created by ELC on 9/9/10.
//  Copyright 2010 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELCAssetSelectionDelegate.h"

@class ELCImagePickerController;
@class ELCAlbumPickerController;

@protocol ELCImagePickerControllerDelegate <UINavigationControllerDelegate>

/**
 * Called with the picker the images were selected from, as well as an array of dictionary's
 * containing keys for ALAssetPropertyLocation, ALAssetPropertyType, 
 * UIImagePickerControllerOriginalImage, and UIImagePickerControllerReferenceURL.
 * @param picker
 * @param info An NSArray containing dictionary's with the key UIImagePickerControllerOriginalImage, which is a rotated, and sized for the screen 'default representation' of the image selected. If you want to get the original image, use the UIImagePickerControllerReferenceURL key.
 */
- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info;

/**
 * Called when image selection was cancelled, by tapping the 'Cancel' BarButtonItem.
 */
- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker;

@end

@interface ELCImagePickerController : UINavigationController <ELCAssetSelectionDelegate>

@property (nonatomic, weak) id<ELCImagePickerControllerDelegate> imagePickerDelegate;
@property (nonatomic, assign) NSInteger maximumImagesCount;

/**
 * The title of the alert message if the user attempts to select more than
 * \c maximumImagesCount images.
 *
 * Default: 'Too Many Images'
 */
@property (nonatomic, copy) NSString *exceededNumberOfImagesAlertTitle;

/**
 * The body of the alert message if the user attempts to select more than
 * \c maximumImagesCount images.
 *
 * Default: 'You can only choose up to \c %ld photos at a time.'
 */
@property (nonatomic, copy) NSString *exceededNumberOfImagesAlertBody;

/**
 * The title of the alert message if the user attempts to select a photo
 * stream photo that has not been downloaded to the device.
 *
 * Default: 'Photo Not Available'
 */
@property (nonatomic, copy) NSString *photoStreamPhotoUnavailableTitle;

/**
 * The body of the alert message if the user attempts to select a photo
 * stream photo that has not been downloaded to the device.
 *
 * Default: 'This photo has not been downloaded from iCloud Photo Stream.
 * You can download it by viewing it in Photos.app first.'
 */
@property (nonatomic, copy) NSString *photoStreamPhotoUnavailableBody;

/**
 * The title of the button to dismiss alert messages.
 *
 * Default: 'OK'
 */
@property (nonatomic, copy) NSString *okButtonTitle;

/**
 * YES if the picker should return the original image,
 * or NO for an image suitable for displaying full screen on the device.
 */
@property (nonatomic, assign) BOOL returnsOriginalImage;

- (id)initImagePicker;
- (void)cancelImagePicker;

@end

