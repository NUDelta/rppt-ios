//
//  RPPTScreenCapturerIO.h
//  RPPT
//
//  Created by Andrew Finke on 12/12/17.
//  Copyright © 2017 aspin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Foundation/Foundation.h>
#import <OpenTok/OpenTok.h>

@protocol OTVideoCapture;

// defines for image scaling
// From https://bugs.chromium.org/p/webrtc/issues/detail?id=4643#c7 :
// Don't send any image larger than 1280px on either edge. Additionally, don't
// send any image with dimensions %16 != 0
#define MAX_EDGE_SIZE_LIMIT 1280.0f
#define EDGE_DIMENSION_COMMON_FACTOR 16.0f

/**
 * Periodically sends video frames to an OpenTok Publisher by rendering the
 * CALayer for a UIView.
 */
@interface RPPTScreenCapturer : NSObject <OTVideoCapture>

// private: declared here for testing scaling & padding function
+ (void)dimensionsForInputSize:(CGSize)input
                 containerSize:(CGSize*)destContainerSize
                      drawRect:(CGRect*)destDrawRect;

@end
