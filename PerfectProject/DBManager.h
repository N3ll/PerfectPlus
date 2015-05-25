//
//  DBManager.h
//  SQLite3DBSample
//
//  Created by Nelly Chakarova on 15/05/15.
//  Copyright (c) 2015 Nelly Chakarova. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBManager : NSObject

@property (nonatomic,strong) NSMutableArray *arrColumnNames;
@property (nonatomic) int affectedRows;
@property (nonatomic) long long lastIsertedRowID;

-(instancetype) initWithDatabaseFilename:(NSString*)dbFilename;

//This will return a two-dimensional array.
//The first array represents the rows, while each sub-array represents the columns of each row.
-(NSArray*) loadDataFromDB:(NSString*)query;
-(void)executeQuery:(NSString*) query;

@end
