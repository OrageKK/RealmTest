//
//  Student.m
//  RealmTest
//
//  Created by 黄坤 on 16/10/26.
//  Copyright © 2016年 oragekk. All rights reserved.
//

#import "Student.h"

@implementation Student

- (NSString *)description
{
    return [NSString stringWithFormat:@"姓名：%@，年龄：%ld", _name,_age];
}

@end
