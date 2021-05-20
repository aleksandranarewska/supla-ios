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

#import <Foundation/Foundation.h>
#import "proto.h"

NS_ASSUME_NONNULL_BEGIN

@interface SAZWaveWakeupSettingsReport : NSObject
@property (nonatomic, readonly)int resultCode;
@property (nonatomic, readonly)int minimumSec;
@property (nonatomic, readonly)int maximumSec;
@property (nonatomic, readonly)int valueSec;
@property (nonatomic, readonly)int intervalStepSec;

- (id)initWithResultCode:(int)code andReport:(TCalCfg_ZWave_WakeupSettingsReport*)report;
- (void)setValueSec:(int)valueSec;
+ (SAZWaveWakeupSettingsReport*) reportWithResultCode:(int)code andReport:(TCalCfg_ZWave_WakeupSettingsReport*)report;
+ (SAZWaveWakeupSettingsReport *)notificationToProgressReport:(NSNotification *)notification;
@end

NS_ASSUME_NONNULL_END
