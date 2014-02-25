//
//  AlbumPickerController.m
//
//  Created by ELC on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "ELCAlbumPickerController.h"
#import "ELCImagePickerController.h"
#import "ELCAssetTablePicker.h"

@interface ELCAlbumPickerController ()

@property (nonatomic, strong) ALAssetsLibrary *library;

@end

@implementation ELCAlbumPickerController

//Using auto synthesizers

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self.navigationItem setTitle:NSLocalizedStringFromTable(@"status.loading", @"ELCImagePickerController", @"The title of the image picker while loading albums.")];

    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self.parent action:@selector(cancelImagePicker)];
	[self.navigationItem setRightBarButtonItem:cancelButton];

    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
	self.assetGroups = tempArray;
    
    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
    self.library = assetLibrary;

    // Load Albums into assetGroups
    dispatch_async(dispatch_get_main_queue(), ^
    {
        @autoreleasepool {
        
        // Group enumerator Block
            void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) 
            {
                if (group == nil) {
                    return;
                }
                
                // added fix for camera albums order
                NSString *sGroupPropertyName = (NSString *)[group valueForProperty:ALAssetsGroupPropertyName];
                NSUInteger nType = [[group valueForProperty:ALAssetsGroupPropertyType] intValue];
                
                if ([[sGroupPropertyName lowercaseString] isEqualToString:@"camera roll"] && nType == ALAssetsGroupSavedPhotos) {
                    [self.assetGroups insertObject:group atIndex:0];
                }
                else {
                    [self.assetGroups addObject:group];
                }

                // Reload albums
                [self performSelectorOnMainThread:@selector(reloadTableView) withObject:nil waitUntilDone:YES];
            };
            
			ELCAlbumPickerController *__weak weakSelf = self;
			
            // Group Enumerator Failure Block
            void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
				NSString *title = nil;
				NSString *message = nil;
				
				if ([[error domain] isEqualToString:ALAssetsLibraryErrorDomain])
				{
					if ([error code] == ALAssetsLibraryAccessUserDeniedError)
					{
						title =
						NSLocalizedStringFromTable(@"error.accessDenied.title", @"ELCImagePickerController", @"The title of the error message if there is an error loading photos because access has been denied");
						message =
						NSLocalizedStringFromTable(@"error.accessDenied.userDenied.message", @"ELCImagePickerController", @"The body of the error message if the user has denied access to photos");
					}
					else if ([error code] == ALAssetsLibraryAccessGloballyDeniedError)
					{
						title =
						NSLocalizedStringFromTable(@"error.accessDenied.title", @"ELCImagePickerController", @"The title of the error message if there is an error loading photos because access has been denied");
						message =
						NSLocalizedStringFromTable(@"error.accessDenied.globalDenied.message", @"ELCImagePickerController", @"The body of the error message if the user has denied access to Location Services");
					}
				}
				
				if (!title)
				{
					title =
					[NSString stringWithFormat:
					NSLocalizedStringFromTable(@"error.unknown.title", @"ELCImagePickerController", @"The title of the error message if there is an unknown error"),
					 (long) [error code]];
				}
				
				if (!message)
				{
					message = [error localizedDescription];
					
					if ([[error localizedRecoverySuggestion] length])
					{
						message = [message stringByAppendingFormat:@" - %@",
								   [error localizedRecoverySuggestion]];
					}
				}
				
				[weakSelf.navigationItem setTitle:title];
				
                UIAlertView * alert =
				[[UIAlertView alloc] initWithTitle:title
										   message:message
										  delegate:nil
								 cancelButtonTitle:
				 NSLocalizedStringFromTable(@"alert.ok.button", @"ELCImagePickerController", @"The title of the button to dismiss an alert message.")
								 otherButtonTitles:nil];
                [alert show];
            };
                    
            // Enumerate Albums
            [self.library enumerateGroupsWithTypes:ALAssetsGroupAll
										usingBlock:assetGroupEnumerator
									  failureBlock:assetGroupEnumberatorFailure];
        
        }
    });
}

- (void)reloadTableView
{
	[self.tableView reloadData];
	[self.navigationItem setTitle:NSLocalizedStringFromTable(@"status.selectAnAlbum", @"ELCImagePickerController", @"The title of the image picker when albums are loaded.")];
}

- (BOOL)shouldSelectAsset:(ELCAsset *)asset previousCount:(NSUInteger)previousCount
{
    return [self.parent shouldSelectAsset:asset previousCount:previousCount];
}

- (void)selectedAssets:(NSArray*)assets
{
	[_parent selectedAssets:assets];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.assetGroups count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Get count
    ALAssetsGroup *g = (ALAssetsGroup*)[self.assetGroups objectAtIndex:indexPath.row];
    [g setAssetsFilter:[ALAssetsFilter allPhotos]];
    NSInteger gCount = [g numberOfAssets];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%ld)",[g valueForProperty:ALAssetsGroupPropertyName], (long)gCount];
    [cell.imageView setImage:[UIImage imageWithCGImage:[(ALAssetsGroup*)[self.assetGroups objectAtIndex:indexPath.row] posterImage]]];
	[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	ELCAssetTablePicker *picker = [[ELCAssetTablePicker alloc] initWithNibName: nil bundle: nil];
	picker.parent = self;

    picker.assetGroup = [self.assetGroups objectAtIndex:indexPath.row];
    [picker.assetGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
    
	picker.assetPickerFilterDelegate = self.assetPickerFilterDelegate;
	
	[self.navigationController pushViewController:picker animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 57;
}

@end

