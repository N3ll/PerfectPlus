//
//  CurrentStocksTableViewController.m
//  PerfectProject
//
//  Created by Nelly Chakarova on 17/05/15.
//  Copyright (c) 2015 Nelly Chakarova. All rights reserved.
//

#import "CurrentStocksTableViewController.h"
#import "DBManager.h"

@interface CurrentStocksTableViewController ()
@property (strong,nonatomic) DBManager *dbManager;
@property (strong,nonatomic) NSArray *arrAllProducts;

-(void)loadData;


@end

@implementation CurrentStocksTableViewController

-(void)loadData{
    
    //Form the query
    NSString *query =[NSString stringWithFormat:@"SELECT * FROM Current WHERE category='%@'",self.categoryForDB];
    NSLog(@"query to take the data %@",query);
    //Get the results
    if(self.arrAllProducts !=nil){
        self.arrAllProducts = nil;
    }
    
    self.arrAllProducts = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    
    NSLog(@"Number of products in category %lu",(unsigned long)self.arrAllProducts.count);
    
    [self.tableView reloadData];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //Initialize the dbManager object.
    self.dbManager = [[DBManager alloc]initWithDatabaseFilename:@"perfect.sql"];
    
    //loading the data from the db
    [self loadData];}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSLog(@"Number of sections");
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSLog(@"Number of rows");
    return self.arrAllProducts.count;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"currentStockCell" forIndexPath:indexPath];
    NSInteger indexOfitemNum = [self.dbManager.arrColumnNames indexOfObject:@"itemNum"];
    //    NSInteger indexOfCategory = [self.dbManager.arrColumnNames indexOfObject:@"category"];
    NSInteger indexOfitemName = [self.dbManager.arrColumnNames indexOfObject:@"itemName"];
    NSInteger indexOfPurchasePrice = [self.dbManager.arrColumnNames indexOfObject:@"purchasePrice"];
    NSInteger indexOfResalePrice = [self.dbManager.arrColumnNames indexOfObject:@"resalePrice"];
     NSInteger indexOfQuantity = [self.dbManager.arrColumnNames indexOfObject:@"quantity"];
    
    
    // Set the loaded data to the appropriate cell labels.
    UIImageView *cellImageView = (UIImageView *)[cell viewWithTag:40];
    UILabel *itemName = (UILabel *)[cell viewWithTag:41];
    UILabel *itemNum = (UILabel *)[cell viewWithTag:42];
    UILabel *purchasePrice = (UILabel *)[cell viewWithTag:43];
    UILabel *resalePrice = (UILabel *)[cell viewWithTag:44];
    UITextField *quantity = (UITextField *)[cell viewWithTag:45];
    
    itemName.text = [NSString stringWithFormat:@"%@", [[self.arrAllProducts objectAtIndex:indexPath.row] objectAtIndex:indexOfitemName]];
    itemNum.text = [NSString stringWithFormat:@"%@", [[self.arrAllProducts objectAtIndex:indexPath.row] objectAtIndex:indexOfitemNum]];
    purchasePrice.text = [NSString stringWithFormat:@"%@", [[self.arrAllProducts objectAtIndex:indexPath.row] objectAtIndex:indexOfPurchasePrice]];
    resalePrice.text = [NSString stringWithFormat:@"%@", [[self.arrAllProducts objectAtIndex:indexPath.row] objectAtIndex:indexOfResalePrice]];
    quantity.text = [NSString stringWithFormat:@"%@", [[self.arrAllProducts objectAtIndex:indexPath.row] objectAtIndex:indexOfQuantity]];
    
    NSString *imageNum = itemNum.text;
    NSMutableString * imageName = [NSMutableString stringWithFormat:@"%@",imageNum];
    cellImageView.image = [UIImage imageNamed:imageName];
    cellImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    return cell;
}

@end
