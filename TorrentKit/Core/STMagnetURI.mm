//
//  STMagnetURI.m
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 6/29/19.
//  Copyright © 2019 Danylo Kostyshyn. All rights reserved.
//

#import "STMagnetURI.h"

#import "libtorrent/torrent_info.hpp"
#import "libtorrent/add_torrent_params.hpp"
#import "libtorrent/magnet_uri.hpp"
#import "libtorrent/string_view.hpp"

@interface STMagnetURI ()
@property (readwrite, strong, nonatomic) NSURL *magnetURI;
@end

@implementation STMagnetURI

- (instancetype)initWithMagnetURI:(NSURL *)magnetURI {
    self = [self init];
    if (self) {
        _magnetURI = magnetURI;
    }
    return self;
}

#pragma mark - STDownloadable

- (void)configureAddTorrentParams:(void *)params {
    lt::add_torrent_params *_params = (lt::add_torrent_params *)params;
    _params->flags |= libtorrent::torrent_flags::sequential_download;
    lt::error_code ec;
    lt::string_view uri = lt::string_view([self.magnetURI.absoluteString UTF8String]);
    lt::parse_magnet_uri(uri, (*_params), ec);
    if (ec.failed()) {
        NSLog(@"%s, error_code: %s", __FUNCTION__, ec.message().c_str());
    }
}

@end
