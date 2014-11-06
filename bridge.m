//
//  bridge.m
//  remote-paper-prototyper-ios
//
//  Created by Kevin Chen on 11/6/14.
//  Copyright (c) 2014 aspin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MeteorClient.h"
#import "ObjectiveDDP.h"
#import <ObjectiveDDP/MeteorClient.h>


MeteorClient* initializeMeteor(NSString* version, NSString* endpoint) {
    MeteorClient *meteorClient = [[MeteorClient alloc] initWithDDPVersion:version];
    ObjectiveDDP *ddp = [[ObjectiveDDP alloc] initWithURLString:endpoint delegate:meteorClient];
    meteorClient.ddp = ddp;
    [meteorClient.ddp connectWebSocket];
    return meteorClient;
}