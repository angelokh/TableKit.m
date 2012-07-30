//
//  TKGlobals.h
//  Shopinion
//
//  Created by Macbook Pro on 7/30/12.
//  Copyright (c) 2012 Sparkover. All rights reserved.
//

///////////////////////////////////////////////////////////////////////////////////////////////////
//
// ARC on iOS 4 and 5 
//

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0 && !defined (TK_DONT_USE_ARC_WEAK_FEATURE)

#define tk_weak   weak
#define __tk_weak __weak
#define tk_nil(x)


#else

#define tk_weak   unsafe_unretained
#define __tk_weak __unsafe_unretained
#define tk_nil(x) x = nil

#endif