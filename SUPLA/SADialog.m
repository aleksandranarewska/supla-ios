/*
Copyright (C) AC SOFTWARE SP. Z O.O.
This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*/

#import "SADialog.h"

@interface SADialog ()

@end

@implementation SADialog {
    UITapGestureRecognizer *_tapGr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeButtonTouch:)];
    [self.view addGestureRecognizer:_tapGr];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.view.alpha = 0;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [UIView animateWithDuration:0.2 animations:^{
        self.view.alpha = 1;
        self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    } completion:nil];
}

- (IBAction)closeButtonTouch:(id)sender {
    
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *gr = (UITapGestureRecognizer *)sender;
    
        UIView *v = self.view.subviews.firstObject;
        if ([v hitTest:[gr locationInView:v] withEvent:nil] != v) {
         return;
        }
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL finished){
         [self dismissViewControllerAnimated:NO completion:nil];
    }];
    
}

- (void)close {
    [self closeButtonTouch:self];
}

+ (void)showModal:(SADialog*)dialogVC {
    UIViewController *rootVC = UIApplication.sharedApplication.delegate.window.rootViewController;
    dialogVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    if (@available(iOS 13.0, *)) {
        dialogVC.modalInPresentation = YES;
        [rootVC presentViewController:dialogVC animated:NO completion:nil];
    } else {
        [rootVC presentModalViewController:dialogVC animated:NO];
    }
}

@end
