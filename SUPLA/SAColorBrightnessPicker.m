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
#import "SAColorBrightnessPicker.h"

#define DEGREES_TO_RADIANS(degrees)((M_PI * degrees)/180)

#define ACTIVE_ARROW_NONE         0
#define ACTIVE_ARROW_COLOR        1
#define ACTIVE_ARROW_BRIGHTNESS   2

@implementation SAColorBrightnessPicker {
    
    BOOL initialized;
    
    NSArray *_colorMarkers;
    NSArray *_brightnessMarkers;
    BOOL _moving;
    BOOL _colorWheelVisible;
    BOOL _circleInsteadArrow;
    BOOL _colorfulBrightnessWheel;
    
    CGPoint _arrowTop;
    CGPoint _inversedArrowTop;
    
    float _arrowHeight;
    
    UIColor *_color;
    float _brightness;
    float _colorAngle;
    
    float lastPanAngle;
    char activeArrow;
    
    CGPoint _colorIndCentralPoint;
    CGPoint _brightnessIndCentralPoint;
    float _indRadius;
    
    UIPanGestureRecognizer *_gr;
}

@synthesize delegate;

-(BOOL)moving {
    return _moving;
}

-(void)pickerInit {
    
    if ( initialized )
        return;
    
    _gr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    
    [_gr setMinimumNumberOfTouches:1];
    [_gr setMaximumNumberOfTouches:1];
    
    [self addGestureRecognizer:_gr];
    
    _colorWheelVisible = YES;
    _colorfulBrightnessWheel = YES;
    _brightness = 0;
    _color = [UIColor colorWithRed:0 green:255 blue:0 alpha:1];
    
    initialized = YES;
}

-(id)init {
    
    self = [super init];
    
    if ( self != nil ) {
        [self pickerInit];
    }
    
    return self;
}

-(id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if ( self != nil ) {
        [self pickerInit];
    }
    
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    
    if ( self != nil ) {
        [self pickerInit];
    }
    
    
    return self;
}

-(void)setArrowHeight:(float)arrowHeight {
    _arrowHeight = arrowHeight;
    [self setNeedsDisplay];
}

-(void)setColorWheelVisible:(BOOL)colorWheelVisible {
    
    _colorWheelVisible = colorWheelVisible;
    [self setNeedsDisplay];
}

-(BOOL)colorWheelVisible {
    return _colorWheelVisible;
}

-(void)setCircleInsteadArrow:(BOOL)circleInsteadArrow {
    _circleInsteadArrow = circleInsteadArrow;
    [self setNeedsDisplay];
}

-(BOOL)circleInsteadArrow {
    return _circleInsteadArrow;
}

-(void)setColorfulBrightnessWheel:(BOOL)colorfulBrightnessWheel {
    _colorfulBrightnessWheel = colorfulBrightnessWheel;
    [self setNeedsDisplay];
}

-(BOOL)colorfulBrightnessWheel {
    return _colorfulBrightnessWheel;
}

-(UIColor*)color {
    return _color;
}

-(float)colorToAngle:(UIColor *)color {
    
    CGFloat hue;
    CGFloat saturation;
    
    [color getHue:&hue saturation:&saturation brightness:nil alpha:nil];
    
    float angle = 360*hue;
    angle = 360 - angle;
    
    return [self addAngle:90 toAngle:angle];
}

-(void)setColor:(UIColor *)color {
    
    _color = color;
    _colorAngle = [self colorToAngle:color];
    
    if ( self.colorWheelVisible ) {
        [self setNeedsDisplay];
    }
}

-(float)brightness {
    return _brightness;
}

-(void)setBrightness:(float)brightness {
    
    _brightness = brightness;
    [self setNeedsDisplay];
    
}

-(NSArray*)colorMarkers {
    return _colorMarkers;
}

-(void)setColorMarkers:(NSArray *)colorMarkers {
    _colorMarkers = colorMarkers;
    [self setNeedsDisplay];
}

-(NSArray*)brightnessMarkers {
    return _brightnessMarkers;
}

-(void)setBrightnessMarkers:(NSArray *)brightnessMarkers {
    _brightnessMarkers = brightnessMarkers;
    [self setNeedsDisplay];
}

-(float)addAngle:(float)angle toAngle:(float)source {
    
    angle = source + angle;
    
    if ( angle > 360 )
        angle = fmod(angle, 360);
    
    if ( angle<0 ) {
        
        angle*=-1;
        
        if ( angle > 360 )
            angle = fmod(angle, 360);
        
        angle = 360 - angle;
    }
    
    return angle;
}


-(UIColor*)calculateColorForAngle:(float)angle baseColor:(UIColor *)base_color {
    
    if ( base_color == nil ) {
        
        angle = 360 - angle;
        return [UIColor colorWithHue:angle/360.00 saturation:1 brightness:1 alpha:1];
        
    } else {
        
        if ( angle > 0 ) {
            
            angle += 60;
            
            if ( angle > 360 )
                angle = 360;
            
        }
        
        CGFloat hue;
        CGFloat saturation;
        
        [base_color getHue:&hue saturation:&saturation brightness:nil alpha:nil];
        
        return [UIColor colorWithHue:hue saturation:saturation brightness:angle/360 alpha:1];
    }
}

- (void)drawMarkers:(NSArray*)markers withRadius:(int)radius markerSize:(float)markerSize brightness:(BOOL)brightness ctx:(CGContextRef)ctx {
    
    CGRect rect;
    float angle;
    id obj;
    
    if (markers==nil) {
        return;
    }
    
    for(int a=0;a<markers.count;a++) {
        angle = 0;
        obj = [markers objectAtIndex:a];
        
        if (brightness) {
            
            if ([obj isKindOfClass:[NSNumber class]]) {
                float b = [obj intValue];
                
                if (b < 0.5) {
                    b = 0.5;
                } else if (b > 99.5) {
                    b = 99.5;
                }
                
                angle = b*3.6;
            }
            
        } else if ([obj isKindOfClass:[UIColor class]]) {
            angle = [self colorToAngle:obj];
        }
        
        angle = DEGREES_TO_RADIANS([self addAngle:270 toAngle:angle]);
        
        rect.origin.x = cosf(angle) * radius - markerSize/2;
        rect.origin.y = sinf(angle) * radius - markerSize/2;
        rect.size.height = markerSize;
        rect.size.width = rect.size.height;
        
        CGContextAddEllipseInRect(ctx, rect);
        CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
        CGContextFillPath(ctx);
        
        CGContextSetLineWidth(ctx, markerSize/8);
        CGContextAddEllipseInRect(ctx, rect);
        CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
        CGContextStrokePath(ctx);
    }
}

-(void)drawWheelWithRadius:(int)wheel_radius wheelWidth:(int)wheel_width baseColor:(UIColor *)base_color {
    
    int steps = 255;
    float angle_step = 360.00/steps;
    
    UIBezierPath *aPath = [UIBezierPath bezierPath];
    aPath.lineWidth = 1;
    
    
    for(int a=0;a<steps;a++) {
        
        [aPath removeAllPoints];
        
        float angle1 = a*angle_step;
        float angle2 = (a+1)*angle_step;
        
        UIColor *color = [self calculateColorForAngle:angle1 baseColor:base_color];
        
        if ( base_color != nil ) {
            
            angle1 = [self addAngle:270 toAngle:angle1];
            angle2 = [self addAngle:270 toAngle:angle2];
            
        }
        
        [color setFill];
        [color setStroke];
        
        float x = cosf(DEGREES_TO_RADIANS(angle1))*wheel_radius;
        float y = sinf(DEGREES_TO_RADIANS(angle1))*wheel_radius;
        
        [aPath moveToPoint:CGPointMake(x, y)];
        
        x = cosf(DEGREES_TO_RADIANS(angle1))*(wheel_radius+wheel_width);
        y = sinf(DEGREES_TO_RADIANS(angle1))*(wheel_radius+wheel_width);
        
        [aPath addLineToPoint:CGPointMake(x, y)];
        
        
        x = cosf(DEGREES_TO_RADIANS(angle2))*wheel_radius;
        y = sinf(DEGREES_TO_RADIANS(angle2))*wheel_radius;
        
        [aPath moveToPoint:CGPointMake(x, y)];
        
        x = cosf(DEGREES_TO_RADIANS(angle2))*(wheel_radius+wheel_width);
        y = sinf(DEGREES_TO_RADIANS(angle2))*(wheel_radius+wheel_width);
        
        [aPath addLineToPoint:CGPointMake(x, y)];
        
        
        [aPath addArcWithCenter:CGPointMake(0, 0) radius:wheel_radius+wheel_width startAngle:DEGREES_TO_RADIANS(angle2) endAngle:DEGREES_TO_RADIANS(angle1) clockwise:NO];
        [aPath addArcWithCenter:CGPointMake(0, 0) radius:wheel_radius startAngle:DEGREES_TO_RADIANS(angle1) endAngle:DEGREES_TO_RADIANS(angle2) clockwise:YES];
        
        [aPath closePath];
        [aPath fill];
        [aPath stroke];
        
    }
    
}

-(CGPoint)drawCircleWithAngle:(float)angle positionRadius:(int)positionRadius circleRadius:(int)circleRadius color:(UIColor *)color borderColor:(UIColor*)borderColor ctx:(CGContextRef)ctx {
    
    angle = DEGREES_TO_RADIANS(angle);
    
    CGRect rect;
    rect.origin.x = cosf(angle) * positionRadius - circleRadius;
    rect.origin.y = sinf(angle) * positionRadius - circleRadius;
    rect.size.height = circleRadius * 2;
    rect.size.width = rect.size.height;
    
    CGContextAddEllipseInRect(ctx, rect);
    CGContextSetFillColorWithColor(ctx, color.CGColor);
    CGContextFillPath(ctx);
    
    CGContextSetLineWidth(ctx, 2);
    rect.origin.x += 2;
    rect.origin.y += 2;
    rect.size.height -= 4;
    rect.size.width -= 4;
    CGContextAddEllipseInRect(ctx, rect);
    CGContextSetStrokeColorWithColor(ctx, borderColor.CGColor);
    CGContextStrokePath(ctx);
    
    return CGPointMake(rect.origin.x + circleRadius, rect.origin.y + circleRadius);
}

-(CGPoint)drawArrowWithAngle:(float)angle wheelRadius:(int)wheel_radius wheelWidth:(int)wheel_width inverse:(BOOL)inverse color:(UIColor *)color borderColor:(UIColor*)borderColor {
    
    [borderColor setStroke];
    [color setFill];
    
    angle = DEGREES_TO_RADIANS(angle);
    
    float arrowHeight_a = _arrowHeight;
    float arrowHeight_b = arrowHeight_a * 0.6;
    arrowHeight_a -= arrowHeight_b;
    
    float offset = (arrowHeight_a * 0.30);
    int inv = 1;
    
    if ( inverse ) {
        
        wheel_width = 0;
        inv = -1;
        
    } else {
        offset *= -1;
    }
    
    
    float topX = cosf(angle) * (wheel_radius+wheel_width+offset);
    float topY = sinf(angle) * (wheel_radius+wheel_width+offset);
    
    if ( inverse ) {
        _inversedArrowTop.x = topX;
        _inversedArrowTop.y = topY;
    } else {
        _arrowTop.x = topX;
        _arrowTop.y = topY;
    }
    
    float arrowRad = DEGREES_TO_RADIANS(40);
    
    float leftX = topX + cosf(angle+arrowRad)*arrowHeight_a*inv;
    float leftY = topY + sinf(angle+arrowRad)*arrowHeight_a*inv;
    
    float rightX = topX + cosf(angle-arrowRad)*arrowHeight_a*inv;
    float rightY = topY + sinf(angle-arrowRad)*arrowHeight_a*inv;
    
    float backRad = angle;
    
    float backLeftX = leftX + cosf(backRad)*arrowHeight_b*inv;
    float backLeftY = leftY + sinf(backRad)*arrowHeight_b*inv;
    
    float backRightX = rightX + cosf(backRad)*arrowHeight_b*inv;
    float backRightY = rightY + sinf(backRad)*arrowHeight_b*inv;
    
    UIBezierPath *aPath = [UIBezierPath bezierPath];
    aPath.lineWidth = 0.5;
    
    [aPath moveToPoint:CGPointMake(topX, topY)];
    [aPath addLineToPoint:CGPointMake(leftX, leftY)];
    [aPath addLineToPoint:CGPointMake(backLeftX, backLeftY)];
    [aPath addLineToPoint:CGPointMake(backRightX, backRightY)];
    [aPath addLineToPoint:CGPointMake(rightX, rightY)];
    
    [aPath closePath];
    [aPath stroke];
    [aPath fill];
    
    return CGPointMake(cosf(angle) * (wheel_radius+wheel_width+offset+_arrowHeight/2* (inverse ? -1 : 1)),
                       sinf(angle) * (wheel_radius+wheel_width+offset+_arrowHeight/2* (inverse ? -1 : 1)));
}

-(CGPoint)drawIndicatorWithAngle:(float)angle wheelRadius:(int)wheel_radius wheelWidth:(int)wheel_width inverse:(BOOL)inverse color:(UIColor *)color borderColor:(UIColor*)borderColor ctx:(CGContextRef)ctx {
    
    angle = [self addAngle:270 toAngle:angle];
    
    if (_circleInsteadArrow) {
        return [self drawCircleWithAngle:angle positionRadius:wheel_radius+wheel_width/2 circleRadius:wheel_width/2 color:color borderColor:borderColor ctx:ctx];
    }
    
    return [self drawArrowWithAngle:angle wheelRadius:wheel_radius wheelWidth:wheel_width inverse:inverse color:color borderColor:borderColor];
}

-(void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetShouldAntialias(ctx, YES);
    
    float wheelWidth;
    
    CGRect r = self.bounds;
    CGContextTranslateCTM(ctx, r.size.width/2, r.size.height/2);
    
    float radius = r.size.width > r.size.height ? r.size.height : r.size.width;
    
    if (_circleInsteadArrow) {
        wheelWidth = radius / (_colorWheelVisible ? 3.50 : 7.0);
        [self setArrowHeight: 0.00];
    } else {
        wheelWidth = radius / 10.00;
        [self setArrowHeight:wheelWidth * 0.9];
    }

    radius /= 2;
    radius -= wheelWidth;
    radius -= _arrowHeight;
    
    float brightness_angle = _brightness*3.6;
    float color_brightness_angle = brightness_angle;
    
    if (_circleInsteadArrow
        && (!_colorfulBrightnessWheel || !_colorWheelVisible)) {
        if (color_brightness_angle < 4) {
            color_brightness_angle = 4;
        } else if (color_brightness_angle > 250) {
            color_brightness_angle = 250;
        }
    }
    
    UIColor *brightness_ind_color = [self calculateColorForAngle:color_brightness_angle baseColor:_colorWheelVisible
                                     && _colorfulBrightnessWheel ? _color: [UIColor blackColor]];
    UIColor *ind_border_color = _circleInsteadArrow ? [UIColor whiteColor] : [UIColor blackColor];
    UIColor *brightness_base_color = _colorfulBrightnessWheel && _colorWheelVisible ? _color : [UIColor blackColor];
    
    if ( _colorWheelVisible ) {
        wheelWidth /= 2;
    }
    
    float markerSize = wheelWidth/(_circleInsteadArrow ? 5 : 3);
    
    [self drawWheelWithRadius:radius wheelWidth:wheelWidth baseColor:brightness_base_color];
    _brightnessIndCentralPoint = [self drawIndicatorWithAngle:brightness_angle wheelRadius:radius
                     wheelWidth:wheelWidth inverse:_colorWheelVisible color:brightness_ind_color
                     borderColor:ind_border_color ctx:ctx];
    [self drawMarkers:self.brightnessMarkers withRadius:radius+wheelWidth/2 markerSize:markerSize brightness:YES ctx:ctx];
    
    if ( _colorWheelVisible ) {
        radius+=wheelWidth;
        
        [self drawWheelWithRadius:radius wheelWidth:wheelWidth baseColor:nil];
        _colorIndCentralPoint = [self drawIndicatorWithAngle:_colorAngle wheelRadius:radius
                          wheelWidth:wheelWidth inverse:NO color:_color borderColor:ind_border_color ctx:ctx];
        [self drawMarkers:self.colorMarkers withRadius:radius+wheelWidth/2
               markerSize:markerSize brightness:NO ctx:ctx];
    }
    
    _indRadius = (_circleInsteadArrow ? wheelWidth : _arrowHeight) / 2;
}

-(float)angleForPoint:(CGPoint)point {
    
    CGRect r = self.bounds;
    
    r.origin.x = r.size.width / 2;
    r.origin.y = r.size.height / 2;
    
    float angle = atan2f(r.origin.y - point.y, r.origin.x - point.x) * 180.0 / M_PI;
    
    if ( angle < 0 )
        angle = 360 + angle;
    
    return angle;
    
}

- (BOOL)touchOverIndicator:(CGPoint)touch_point centralPoint:(CGPoint)central_point {
    NSLog(@"%f,%f,%f,%f,%f", central_point.x, touch_point.x, central_point.y, touch_point.y, sqrtf(pow(central_point.x - touch_point.x , 2) + pow(central_point.y - touch_point.y , 2)));
    return sqrtf(pow(central_point.x - touch_point.x , 2) + pow(central_point.y - touch_point.y , 2)) <= _indRadius;
}

-(UIView *) hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    CGPoint transPoint = point;
    transPoint.x -= self.bounds.size.width / 2;
    transPoint.y -= self.bounds.size.height / 2;
    
    activeArrow = ACTIVE_ARROW_NONE;
    _moving = NO;
    
    if ( _colorWheelVisible ) {
        if ( [self touchOverIndicator:transPoint centralPoint:_colorIndCentralPoint] ) {
            activeArrow = ACTIVE_ARROW_COLOR;
        } else if ( [self touchOverIndicator:transPoint centralPoint:_brightnessIndCentralPoint] ) {
            activeArrow = ACTIVE_ARROW_BRIGHTNESS;
        }
        
    } else  if ( [self touchOverIndicator:transPoint centralPoint:_brightnessIndCentralPoint] ) {
        activeArrow = ACTIVE_ARROW_BRIGHTNESS;
    }
    
    if ( activeArrow != ACTIVE_ARROW_NONE ) {
        
        lastPanAngle = [self angleForPoint:point];
        
        _moving = YES;
        return self;
    }

    return nil;
}


- (void)handlePan:(UIPanGestureRecognizer *)gr {
    
    if ( gr.state == UIGestureRecognizerStateEnded) {
        
        _moving = NO;
        
        if ( delegate != nil )
            [delegate cbPickerMoveEnded: self];
        
        return;
    }
    
    if ( activeArrow != ACTIVE_ARROW_NONE ) {
        
        CGPoint touch_point = [gr locationInView:self];
        
        CGRect r = self.bounds;
        
        r.origin.x = r.size.width / 2;
        r.origin.y = r.size.height / 2;
        
        float angle = [self angleForPoint:touch_point];
        
        if ( angle < 0 )
            angle = 360+angle;
        
        float angle_offset;
        
        if ( angle < 100 && lastPanAngle > 300 ) {
            angle_offset = (angle + 360 - lastPanAngle) * -1;
            
        } else if ( angle > 300 && lastPanAngle < 100 ) {
            angle_offset = lastPanAngle + 360 - angle;
            
        } else {
            angle_offset = lastPanAngle-angle;
        }
        
        
        angle_offset*=-1;
        
        if ( activeArrow == ACTIVE_ARROW_COLOR ) {
            
            UIColor *color;
            
            _colorAngle = [self addAngle:angle_offset toAngle:_colorAngle];
            color = [self calculateColorForAngle:[self addAngle:270 toAngle:_colorAngle] baseColor:nil];
            
            if ( [color isEqual:_color] == NO ) {
                _color = color;
                
                if ( delegate != nil )
                    [delegate cbPickerDataChanged: self];
            }
            
        } else if ( activeArrow == ACTIVE_ARROW_BRIGHTNESS ) {
            
            float brightness = _brightness;
            
            angle_offset = angle_offset * 100 / 360;
            brightness += angle_offset;
            
            if ( brightness > 100 )
                brightness = 100;
            
            if ( brightness < 0 )
                brightness = 0;
            
            if ( brightness != _brightness ) {
                _brightness = brightness;
                
                if ( delegate != nil )
                    [delegate cbPickerDataChanged: self];
            }
            
        }
        
        [self setNeedsDisplay];
        lastPanAngle = angle;
        
    }
}

@end

