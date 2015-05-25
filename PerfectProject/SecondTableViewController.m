//
//  SecondTableViewController.m
//  Perfect
//
//  Created by Nelly Chakarova on 16/05/15.
//  Copyright (c) 2015 Him and Her. All rights reserved.
//

#import "SecondTableViewController.h"
#import "DBManager.h"

@interface SecondTableViewController ()
@property (strong,nonatomic) DBManager *dbManager;
@property (strong,nonatomic) NSArray *arrAllProducts;

-(void)loadData;


@end

@implementation SecondTableViewController

-(void)loadData{
    
    //Form the query
    NSString *query =[NSString stringWithFormat:@"SELECT * FROM Allproducts WHERE category='%@'",self.categoryForDB];
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
    // Do any additional setup after loading the view.
    
    //Initialize the dbManager object.
    self.dbManager = [[DBManager alloc]initWithDatabaseFilename:@"perfect.sql"];
    
    //loading the data from the db
    [self loadData];
    
}

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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellSecond" forIndexPath:indexPath];
    NSInteger indexOfitemNum = [self.dbManager.arrColumnNames indexOfObject:@"itemNum"];
    //    NSInteger indexOfCategory = [self.dbManager.arrColumnNames indexOfObject:@"category"];
    NSInteger indexOfitemName = [self.dbManager.arrColumnNames indexOfObject:@"itemName"];
    NSInteger indexOfPurchasePrice = [self.dbManager.arrColumnNames indexOfObject:@"purchasePrice"];
    NSInteger indexOfResalePrice = [self.dbManager.arrColumnNames indexOfObject:@"resalePrice"];
    
    // Set the loaded data to the appropriate cell labels.
    UIImageView *cellImageView = (UIImageView *)[cell viewWithTag:10];
    UILabel *itemName = (UILabel *)[cell viewWithTag:11];
    UILabel *itemNum = (UILabel *)[cell viewWithTag:12];
    UILabel *purchasePrice = (UILabel *)[cell viewWithTag:13];
    UILabel *resalePrice = (UILabel *)[cell viewWithTag:14];
    
    //    UITextField *quantity = (UITextField *)[cell viewWithTag:15];
    
    itemName.text = [NSString stringWithFormat:@"%@", [[self.arrAllProducts objectAtIndex:indexPath.row] objectAtIndex:indexOfitemName]];
    itemNum.text = [NSString stringWithFormat:@"%@", [[self.arrAllProducts objectAtIndex:indexPath.row] objectAtIndex:indexOfitemNum]];
    purchasePrice.text = [NSString stringWithFormat:@"%@", [[self.arrAllProducts objectAtIndex:indexPath.row] objectAtIndex:indexOfPurchasePrice]];
    resalePrice.text = [NSString stringWithFormat:@"%@", [[self.arrAllProducts objectAtIndex:indexPath.row] objectAtIndex:indexOfResalePrice]];
    
    NSString *imageNum = itemNum.text;
    NSMutableString *imageName = [NSMutableString stringWithFormat:@"%@",imageNum];
    cellImageView.image = [UIImage imageNamed:imageName];
    cellImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    //the buttOn
    UIButton *add = (UIButton*) [cell viewWithTag:16];
    [add addTarget:self
            action:@selector(addOrder:) forControlEvents:UIControlEventTouchDown];
    
    return cell;
}

-(void)addOrder: (UIButton*)sender
{
    UIView *parentCell = sender.superview;
    
    UILabel *itemName = (UILabel *)[parentCell viewWithTag:11];
    NSString *name = itemName.text;
    
    UILabel *itemNum = (UILabel *)[parentCell viewWithTag:12];
    int num = [itemNum.text integerValue];
    
    UILabel *purchasePrice = (UILabel *)[parentCell viewWithTag:13];
    int purchasePr = [purchasePrice.text integerValue];
    
    UILabel *resalePrice = (UILabel *)[parentCell viewWithTag:14];
    int resalePr = [resalePrice.text integerValue];
    
    UITextField *quantity = (UITextField *)[parentCell viewWithTag:15];
    int ordered = [quantity.text integerValue];
    
    quantity.enabled=NO;
    
    
    
    NSLog(@"INSERT INTO Ordered (itemNum,category,itemName,purchasePrice,resalePrice, quantity) values (%d,'%@','%@', %d,%d,%d)",num,self.categoryForDB,name,purchasePr,resalePr,ordered);
    
    NSString *query = [NSString stringWithFormat:@"INSERT INTO Ordered (itemNum,category,itemName,purchasePrice,resalePrice, quantity) values (%d,'%@','%@', %d,%d,%d)",num,self.categoryForDB,name,purchasePr,resalePr,ordered];
    
    [self.dbManager executeQuery:query];
    
    query = @"SELECT * FROM Ordered";
    
    NSArray *allOrdered = [self.dbManager loadDataFromDB:query];
    for (NSString *a in allOrdered) {
        NSLog(@"%@",a);
    }
}



/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
