//
//  DBManager.m
//  SQLite3DBSample
//
//  Created by Nelly Chakarova on 15/05/15.
//  Copyright (c) 2015 Nelly Chakarova. All rights reserved.
//

#import "DBManager.h"
#import <sqlite3.h>

@interface DBManager()

@property (nonatomic,strong) NSString *documentsDirectory;
@property (nonatomic,strong) NSString *databaseFilename;
@property (nonatomic,strong) NSMutableArray *arrResults;

-(void) copyDatabaseIntoDocumentsDirectory;

-(void)runQuery:(const char*)query isQueryExecutable:(BOOL)queryExecutable;

@end

@implementation DBManager

-(instancetype)initWithDatabaseFilename:(NSString *)dbFilename{
    NSLog(@"Init db");
    self = [super init];
    
    if(self){
        //Set the documents directory path to the documentsDirectory property.
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        self.documentsDirectory = [paths objectAtIndex:0];
        
        //keep the database filename.
        self.databaseFilename = dbFilename;
        
        //copy the database file into the document directory if necessary
        [self copyDatabaseIntoDocumentsDirectory];
        
        
        NSArray *check = [self loadDataFromDB:@"Select * from AllProducts"];
        if(check.count == 0){
            
            [self createData];
        }
    }
    return self;
}

-(void)copyDatabaseIntoDocumentsDirectory{
    
    // Check if the database file exists in the documents directory.
    NSString *destinationPath = [self.documentsDirectory stringByAppendingPathComponent:self.databaseFilename];
    if (![[NSFileManager defaultManager] fileExistsAtPath:destinationPath]) {
        // The database file does not exist in the documents directory, so copy it from the main bundle now.
        NSString *sourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:self.databaseFilename];
        NSError *error;
        [[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:destinationPath error:&error];
        
        // Check if any error occurred during copying and display it.
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
}

-(void)runQuery:(const char *)query isQueryExecutable:(BOOL)queryExecutable{
    NSLog(@"In query");
    //Create a sqlite object.
    sqlite3 *sqlite3Database;
    
    //Set the database file path.
    NSString *databasePath = [self.documentsDirectory stringByAppendingPathComponent:self.databaseFilename];
    
    
    //Initialize the results array
    if(self.arrResults !=nil){
        [self.arrResults removeAllObjects];
        self.arrResults = nil;
    }
    
    self.arrResults = [[NSMutableArray alloc]init];
    
    //Initialize the column names array.
    
    if(self.arrColumnNames!=nil){
        [self.arrColumnNames removeAllObjects];
        self.arrColumnNames = nil;
    }
    
    self.arrColumnNames = [[NSMutableArray alloc]init];
    
    //Open the database.
    BOOL operDatabaseResult = sqlite3_open([databasePath UTF8String], &sqlite3Database);
    if(operDatabaseResult == SQLITE_OK){
        //Declare a sqlite3_stmt object in which will be stored the query after having been compiled into a SQLite statement.
        sqlite3_stmt *compiledStatement;
        
        
        //Load all data from database to memery.
        BOOL prepareStatementResult = sqlite3_prepare_v2(sqlite3Database, query, -1, &compiledStatement, NULL);
        //        NSLog(@"%@",compiledStatement);
        if(prepareStatementResult == SQLITE_OK){
            //Check if the query is non-executable.
            if(!queryExecutable){
                //in this case data should be loaded from the database.
                
                //Declare an array to keep the data for each fetched row.
                NSMutableArray *arrDatarow;
                
                //Loop through the results and add them to the results array row by row
                while (sqlite3_step(compiledStatement)== SQLITE_ROW) {
                    //Initialize the mutable array that will contain the data of a fetched row
                    arrDatarow = [[NSMutableArray alloc]init];
                    
                    //Get the total number of columns.
                    int totalColumns = sqlite3_column_count(compiledStatement);
                    
                    //Go through all columns adn fetch each column data.
                    
                    for(int i = 0; i<totalColumns;i++){
                        //Convert the column data to text (characters).
                        char *dbDataAsChars = (char*) sqlite3_column_text(compiledStatement, i);
                        // If there are contents in the currenct column (field) then add them to the current row array.
                        if (dbDataAsChars != NULL) {
                            //Convert the characters to string
                            [arrDatarow addObject:[NSString stringWithUTF8String:dbDataAsChars]];
                        }
                        //Keep the current column name.
                        if(self.arrColumnNames.count !=totalColumns){
                            dbDataAsChars = (char*)sqlite3_column_name(compiledStatement, i);
                            [self.arrColumnNames addObject:[NSString stringWithUTF8String:dbDataAsChars]];
                        }
                    }
                    //Store each fetch data row in the results array, but first check if there is actually data.
                    if (arrDatarow.count > 0) {
                        [self.arrResults addObject:arrDatarow];
                    }
                }
                NSLog(@"Number of items in arrRsult from query method %lu",(unsigned long)self.arrResults.count);
            } else{
                //This is the case of an executable query (insert, update, delete)
                
                //Execute the query
                
                int executeQueryResults = sqlite3_step(compiledStatement);
                if(executeQueryResults == SQLITE_DONE){
                    
                    //Keep the affected rows
                    self.affectedRows = sqlite3_changes(sqlite3Database);
                    
                    //Keep the last inserted row ID.
                    self.lastIsertedRowID = sqlite3_last_insert_rowid(sqlite3Database);
                }else{
                    //If could not execute the query show the error on the debuger.
                    NSLog(@"DB Error: %s", sqlite3_errmsg(sqlite3Database));
                }
            }
        } else{
            //If the database cannot be opened then show the error in the debuger
            NSLog(@"%s", sqlite3_errmsg(sqlite3Database));
        }
        
        //Release the compiled statament from memory.
        sqlite3_finalize(compiledStatement);
    }
}

-(NSArray *)loadDataFromDB:(NSString *)query{
    //Run the query and indicate that is not executable.
    //The query is converted to a char* objects.
    [self runQuery:[query UTF8String] isQueryExecutable:NO];
    
    //Returned the loaded reluts.
    return (NSArray*) self.arrResults;
}

-(void)executeQuery:(NSString *)query{
    //Run the query and indicate that is exacutable.
    [self runQuery:[query UTF8String] isQueryExecutable:YES];
}

-(void)createData{
    NSString *q = @"insert into AllProducts(itemNum,category,itemName,purchasePrice,resalePrice) values (5,'sack','Small sack',5,15)";
    
    //Execute the query
    [self executeQuery:q];
    
    //If the query was successfully executed pop the view controller.
    if(self.affectedRows !=0){
        NSLog(@"Query was executed successfully.Affected rows = %d",self.affectedRows);
        //Pop the view controller.
    }else{
        NSLog(@"Could not execute the query");
    }
    
    q = @"insert into AllProducts(itemNum,category,itemName,purchasePrice,resalePrice) values (1,'backpack','Small Backpack',2,10)";
    
    //Execute the query
    [self executeQuery:q];
    
    //If the query was successfully executed pop the view controller.
    if(self.affectedRows !=0){
        NSLog(@"Query was executed successfully.Affected rows = %d",self.affectedRows);
        //Pop the view controller.
    }else{
        NSLog(@"Could not execute the query");
    }
    
    q = @"insert into AllProducts(itemNum,category,itemName,purchasePrice,resalePrice) values (9,'backpack','Big Backpack',10,30)";
    
    //Execute the query
    [self executeQuery:q];
    
    //If the query was successfully executed pop the view controller.
    if(self.affectedRows !=0){
        NSLog(@"Query was executed successfully.Affected rows = %d",self.affectedRows);
        //Pop the view controller.
    }else{
        NSLog(@"Could not execute the query");
    }
    
    
    q = @"insert into AllProducts(itemNum,category,itemName,purchasePrice,resalePrice) values (2,'ladybag','Red bag',10,20)";
    
    //Execute the query
    [self executeQuery:q];
    
    //If the query was successfully executed pop the view controller.
    if(self.affectedRows !=0){
        NSLog(@"Query was executed successfully.Affected rows = %d",self.affectedRows);
        //Pop the view controller.
    }else{
        NSLog(@"Could not execute the query");
    }
    
    q = @"insert into AllProducts(itemNum,category,itemName,purchasePrice,resalePrice) values (3,'menbag','Businessman',16,30)";
    
    //Execute the query
    [self executeQuery:q];
    
    //If the query was successfully executed pop the view controller.
    if(self.affectedRows !=0){
        NSLog(@"Query was executed successfully.Affected rows = %d",self.affectedRows);
        //Pop the view controller.
    }else{
        NSLog(@"Could not execute the query");
    }
    
    q = @"insert into AllProducts(itemNum,category,itemName,purchasePrice,resalePrice) values (4,'suitcase','Big Cruiser',40,60)";
    
    //Execute the query
    [self executeQuery:q];
    
    //If the query was successfully executed pop the view controller.
    if(self.affectedRows !=0){
        NSLog(@"Query was executed successfully.Affected rows = %d",self.affectedRows);
        //Pop the view controller.
    }else{
        NSLog(@"Could not execute the query");
    }
    
    q = @"insert into AllProducts(itemNum,category,itemName,purchasePrice,resalePrice) values (6,'wallet','Pink Wallet',5,16)";
    
    //Execute the query
    [self executeQuery:q];
    
    //If the query was successfully executed pop the view controller.
    if(self.affectedRows !=0){
        NSLog(@"Query was executed successfully.Affected rows = %d",self.affectedRows);
        //Pop the view controller.
    }else{
        NSLog(@"Could not execute the query");
    }
    
    q = @"insert into Current(itemNum,category,itemName,purchasePrice,resalePrice,quantity) values (6,'wallet','Purple wallet',12,25,3)";
    
    //Execute the query
    [self executeQuery:q];
    
    //If the query was successfully executed pop the view controller.
    if(self.affectedRows !=0){
        NSLog(@"Query was executed successfully.Affected rows = %d",self.affectedRows);
        //Pop the view controller.
    }else{
        NSLog(@"Could not execute the query");
    }
    
    
    q = @"insert into Current(itemNum,category,itemName,purchasePrice,resalePrice,quantity) values (7,'wallet','Yellow wallet',10,20,1)";
    
    //Execute the query
    [self executeQuery:q];
    
    //If the query was successfully executed pop the view controller.
    if(self.affectedRows !=0){
        NSLog(@"Query was executed successfully.Affected rows = %d",self.affectedRows);
        //Pop the view controller.
    }else{
        NSLog(@"Could not execute the query");
    }
    
    q = @"insert into Current(itemNum,category,itemName,purchasePrice,resalePrice,quantity) values (8,'sack','Large sack',60,70,2)";
    
    //Execute the query
    [self executeQuery:q];
    
    //If the query was successfully executed pop the view controller.
    if(self.affectedRows !=0){
        NSLog(@"Query was executed successfully.Affected rows = %d",self.affectedRows);
        //Pop the view controller.
    }else{
        NSLog(@"Could not execute the query");
    }
    
}




@end
