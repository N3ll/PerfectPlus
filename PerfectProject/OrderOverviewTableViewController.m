//
//  OrderOverviewTableViewController.m
//  PerfectProject
//
//  Created by Nelly Chakarova on 16/05/15.
//  Copyright (c) 2015 Nelly Chakarova. All rights reserved.
//

#import "OrderOverviewTableViewController.h"
#import "DBManager.h"

@interface OrderOverviewTableViewController ()
@property (strong,nonatomic) DBManager *dbManager;
@property (strong,nonatomic) NSArray *arrAllProducts;
@property (nonatomic) BOOL confirmed;

-(void)loadData;

@end

@implementation OrderOverviewTableViewController

-(void)loadData{
    
    //Form the query
    NSString *query =@"SELECT * FROM Ordered";
    
    //Get the results
    if(self.arrAllProducts !=nil){
        self.arrAllProducts = nil;
    }
    
    self.arrAllProducts = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    
    NSLog(@"Number of ordered items in the table %lu",(unsigned long)self.arrAllProducts.count);
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(!self.confirmed){
        
        //Initialize the dbManager object.
        self.dbManager = [[DBManager alloc]initWithDatabaseFilename:@"perfect.sql"];
        
        //loading the data from the db
        [self loadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrAllProducts.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cell for row at..");
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"overviewOrder" forIndexPath:indexPath];
    
    NSInteger indexOfitemNum = [self.dbManager.arrColumnNames indexOfObject:@"itemNum"];
    //    NSInteger indexOfCategory = [self.dbManager.arrColumnNames indexOfObject:@"category"];
    NSInteger indexOfitemName = [self.dbManager.arrColumnNames indexOfObject:@"itemName"];
    NSInteger indexOfPurchasePrice = [self.dbManager.arrColumnNames indexOfObject:@"purchasePrice"];
    NSInteger indexOfResalePrice = [self.dbManager.arrColumnNames indexOfObject:@"resalePrice"];
    NSInteger indexOfQuantity = [self.dbManager.arrColumnNames indexOfObject:@"quantity"];
    
     UIImageView *cellImageView = (UIImageView *)[cell viewWithTag:20];
    // Set the loaded data to the appropriate cell labels.
    UILabel *itemName = (UILabel *)[cell viewWithTag:21];
    UILabel *itemNum = (UILabel *)[cell viewWithTag:22];
    UILabel *purchasePrice = (UILabel *)[cell viewWithTag:23];
    UILabel *resalePrice = (UILabel *)[cell viewWithTag:24];
    UITextField *quantity = (UITextField *)[cell viewWithTag:25];
    
    itemName.text = [NSString stringWithFormat:@"%@", [[self.arrAllProducts objectAtIndex:indexPath.row] objectAtIndex:indexOfitemName]];
    itemNum.text = [NSString stringWithFormat:@"%@", [[self.arrAllProducts objectAtIndex:indexPath.row] objectAtIndex:indexOfitemNum]];
    purchasePrice.text = [NSString stringWithFormat:@"%@", [[self.arrAllProducts objectAtIndex:indexPath.row] objectAtIndex:indexOfPurchasePrice]];
    resalePrice.text = [NSString stringWithFormat:@"%@", [[self.arrAllProducts objectAtIndex:indexPath.row] objectAtIndex:indexOfResalePrice]];
    quantity.text = [NSString stringWithFormat:@"%@", [[self.arrAllProducts objectAtIndex:indexPath.row] objectAtIndex:indexOfQuantity]];
    
    NSString *imageNum = itemNum.text;
    NSMutableString *imageName = [NSMutableString stringWithFormat:@"%@",imageNum];
    cellImageView.image = [UIImage imageNamed:imageName];
    cellImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    //the stepper
    UIStepper *plusMinus = (UIStepper*) [cell viewWithTag:26];
    plusMinus.value = [quantity.text integerValue];
    [plusMinus addTarget:self
                  action:@selector(moreLess:) forControlEvents:UIControlEventValueChanged];
    
    
    return cell;
}

-(void)moreLess: (UIStepper*)sender
{
    UIView *parentCell = sender.superview;
    
    UITextField *quantity = (UITextField *)[parentCell viewWithTag:25];
    
    int value = sender.value;
    NSLog(@"Stepper value %d",value);
    
    
    quantity.text = [NSString stringWithFormat:@"%d",value];
    
    UILabel *itemNum = (UILabel *)[parentCell viewWithTag:22];
    int num = [itemNum.text integerValue];
    
    
    
    NSLog(@"UPDATE Ordered SET quantity=%d WHERE itemNum=%d",value,num);
    
    NSString *query = [NSString stringWithFormat:@"UPDATE Ordered SET quantity=%d WHERE itemNum=%d" ,value,num];
    
    [self.dbManager executeQuery:query];
    NSLog(@"%d",self.dbManager.affectedRows);
    
}

- (IBAction)comfirmOrder:(UIBarButtonItem *)sender {
    
    self.confirmed = YES;
    [self showAlert];
    self.arrAllProducts = nil;
    [self.tableView reloadData];
    
}


- (void) showAlert {
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Order"
                                                                   message:@"Your order was comfirmed."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
