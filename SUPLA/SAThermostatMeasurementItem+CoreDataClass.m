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

#import "SAThermostatMeasurementItem+CoreDataClass.h"

@implementation SAThermostatMeasurementItem

-(NSDecimalNumber*)getTemperatureForKey:(NSString*)key withObject:(NSDictionary*)object {
   NSString *str = [object valueForKey:key];
    if (str != nil && ![str isKindOfClass:[NSNull class]]) {
        double temperature = [str doubleValue];
        if (temperature > -273) {
            return [[NSDecimalNumber alloc] initWithDouble:temperature];
        }
    }
    return nil;
}

- (void) assignJSONObject:(NSDictionary *)object {
    [super assignJSONObject:object];
    
    self.is_on = [self boolValueForKey:@"on" withObject:object];
    self.measured = [self getTemperatureForKey:@"measured_temperature" withObject:object];
    self.preset = [self getTemperatureForKey:@"preset_temperature" withObject:object];
}

@end
