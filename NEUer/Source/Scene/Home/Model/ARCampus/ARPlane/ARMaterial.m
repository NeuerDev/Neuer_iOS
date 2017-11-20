//
//  PBRMaterial.m
//  arkit-by-example
//
//  Created by md on 6/15/17.
//  Copyright © 2017 ruanestudios. All rights reserved.
//

#import "ARMaterial.h"

static NSMutableDictionary *materials;

@implementation ARMaterial

+ (void)init {
    materials = [NSMutableDictionary new];
}

+ (SCNMaterial *)materialNamed:(NSString *)name {
    
    SCNMaterial *mat = materials[name];
    if (mat) {
        return mat;
    }
    
    mat = [SCNMaterial new];
    mat.lightingModelName = SCNLightingModelPhysicallyBased;
    mat.diffuse.contents = [[UIImage imageNamed:name] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    mat.roughness.contents = [[UIImage imageNamed:name] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    mat.metalness.contents = [[UIImage imageNamed:name] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    mat.normal.contents = [[UIImage imageNamed:name] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    mat.diffuse.wrapS = SCNWrapModeRepeat;
    mat.diffuse.wrapT = SCNWrapModeRepeat;
    mat.roughness.wrapS = SCNWrapModeRepeat;
    mat.roughness.wrapT = SCNWrapModeRepeat;
    mat.metalness.wrapS = SCNWrapModeRepeat;
    mat.metalness.wrapT = SCNWrapModeRepeat;
    mat.normal.wrapS = SCNWrapModeRepeat;
    mat.normal.wrapT = SCNWrapModeRepeat;
    
    materials[name] = mat;
    return mat;
}

@end
