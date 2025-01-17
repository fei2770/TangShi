//
//  TCFoodRecordModel.h
//  TonzeCloud
//
//  Created by vision on 17/3/16.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IngredientModel;
@interface TCFoodRecordModel : NSObject


@property (nonatomic, copy) NSString *name;

@property (nonatomic, assign) NSInteger id;

@property (nonatomic, copy) NSString *time_slot;    //时间段 用餐类别

@property (nonatomic, assign)NSInteger all_calories_record;  //摄入总能量

@property (nonatomic, strong) NSArray<IngredientModel *> *ingredient;

@property (nonatomic, copy) NSString *image_id;

@property (nonatomic, copy) NSString *image_url;

@property (nonatomic, copy) NSString *user_id;

@property (nonatomic, copy) NSString *edit_time;

@property (nonatomic, copy) NSString *feeding_time;   //用餐日期
@property (nonatomic, copy) NSString *add_time;


@end


@interface IngredientModel : NSObject

@property (nonatomic, copy) NSString *diet_record_id;

@property (nonatomic, copy) NSString *ingredient_calories;

@property (nonatomic, assign) NSInteger id;

@property (nonatomic, copy) NSString *ingredient_id;

@property (nonatomic, copy) NSString *ingredient_weight;

@property (nonatomic, copy) NSString *edit_time;

@property (nonatomic, copy) NSString *ingredient_name;

@property (nonatomic, copy) NSString *add_time;

@end

