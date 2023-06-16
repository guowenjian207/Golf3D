//
//  ScrollPlayer.h
//  ScrollPlayer
//
//  Created by bytedance on 2021/5/20.
//

#ifndef ScrollPlayer_h
#define ScrollPlayer_h

typedef NS_ENUM(NSUInteger, ScrollPlayerType) {
    ScrollPlayerTypeLocal,
    ScrollPlayerTypeSystem,
    ScrollPlayerTypeSingle,
    ScrollPlayerTypeScreenRecord,
    ScrollPlayerTypePosted
};

typedef NS_ENUM(NSUInteger, ScrollPlayerMode) {
    ScrollPlayerModeNormal,
    ScrollPlayerModeFramePlay,
    ScrollPlayerModeEdit
};

#endif /* ScrollPlayer_h */
