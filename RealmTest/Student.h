//
//  Student.h
//  RealmTest
//
//  Created by 黄坤 on 16/10/26.
//  Copyright © 2016年 oragekk. All rights reserved.
//

#import <Realm/Realm.h>

@interface Student : RLMObject
@property NSString *name;
@property NSInteger age;
@end
