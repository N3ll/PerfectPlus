//
//  ConfirmDeliveryTableViewController.m
//  PerfectProject
//
//  Created by Nelly Chakarova on 17/05/15.
//  Copyright (c) 2015 Nelly Chakarova. All rights reserved.
//

#import "ConfirmDeliveryTableViewController.h"
#import "DBManager.h"

@interface ConfirmDeliveryTableViewController ()
@property (strong,nonatomic) DBManager *dbManager;
@property (strong,nonatomic) NSArray *arrAllOrderedProducts;
@property (strong,nonatomic) NSArray *arrAllProducts;
@property (nonatomic) BOOL confirmed;

-(void)loadData;

@end

@implementation ConfirmDeliveryTableViewController

-(void)loadData{
    
    NSString *query =@"SELECT * FROM AllProducts";
    
    //Get the results
    if(self.arrAllProducts !=nil){
        self.arrAllProducts = nil;
    }
    
    self.arrAllProducts = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    
    //Form the query
    query =@"SELECT * FROM Ordered";
    
    //Get the results
    if(self.arrAllOrderedProducts !=nil){
        self.arrAllOrderedProducts = nil;
    }
    
    self.arrAllOrderedProducts = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    
    NSLog(@"Number of ordered items to confirm %lu",(unsigned long)self.arrAllOrderedProducts.count);
    
    
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
    NSLog(@"Number of section");
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"Number of rows in section");
    return self.arrAllOrderedProducts.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cell for row at..");
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"deliveryCell" forIndexPath:indexPath];
    
    NSInteger indexOfitemNum = [self.dbManager.arrColumnNames indexOfObject:@"itemNum"];
    //    NSInteger indexOfCategory = [self.dbManager.arrColumnNames indexOfObject:@"category"];
    NSInteger indexOfitemName = [self.dbManager.arrColumnNames indexOfObject:@"itemName"];
    NSInteger indexOfPurchasePrice = [self.dbManager.arrColumnNames indexOfObject:@"purchasePrice"];
    NSInteger indexOfResalePrice = [self.dbManager.arrColumnNames indexOfObject:@"resalePrice"];
    NSInteger indexOfQuantity = [self.dbManager.arrColumnNames indexOfObject:@"quantity"];
    
    // Set the loaded data to the appropriate cell labels.
     UIImageView *cellImageView = (UIImageView *)[cell viewWithTag:30];
    UILabel *itemName = (UILabel *)[cell viewWithTag:31];
    UILabel *itemNum = (UILabel *)[cell viewWithTag:32];
    UILabel *purchasePrice = (UILabel *)[cell viewWithTag:33];
    UILabel *resalePrice = (UILabel *)[cell viewWithTag:34];
    UILabel *orderedQuantity = (UILabel *)[cell viewWithTag:35];
    UITextField *receivedQuantity = (UITextField *)[cell viewWithTag:36];
    
    itemName.text = [NSString stringWithFormat:@"%@", [[self.arrAllOrderedProducts objectAtIndex:indexPath.row] objectAtIndex:indexOfitemName]];
    itemNum.text = [NSString stringWithFormat:@"%@", [[self.arrAllOrderedProducts objectAtIndex:indexPath.row] objectAtIndex:indexOfitemNum]];
    purchasePrice.text = [NSString stringWithFormat:@"%@", [[self.arrAllOrderedProducts objectAtIndex:indexPath.row] objectAtIndex:indexOfPurchasePrice]];
    resalePrice.text = [NSString stringWithFormat:@"%@", [[self.arrAllOrderedProducts objectAtIndex:indexPath.row] objectAtIndex:indexOfResalePrice]];
    orderedQuantity.text = [NSString stringWithFormat:@"%@", [[self.arrAllOrderedProducts objectAtIndex:indexPath.row] objectAtIndex:indexOfQuantity]];
    receivedQuantity.text = [NSString stringWithFormat:@"%@", [[self.arrAllOrderedProducts objectAtIndex:indexPath.row] objectAtIndex:indexOfQuantity]];
    
    NSString *imageNum = itemNum.text;
    NSMutableString *imageName = [NSMutableString stringWithFormat:@"%@",imageNum];
    cellImageView.image = [UIImage imageNamed:imageName];
    cellImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    
    //the stepper
    UIStepper *plusMinus = (UIStepper*) [cell viewWithTag:37];
    plusMinus.value = [receivedQuantity.text integerValue];
    [plusMinus addTarget:self
                  action:@selector(moreLess:) forControlEvents:UIControlEventValueChanged];
    
    
    return cell;
}

-(void)moreLess: (UIStepper*)sender
{
    UIView *parentCell = sender.superview;
    
    UITextField *quantity = (UITextField *)[parentCell viewWithTag:36];
    
    int value = sender.value;
    NSLog(@"Stepper value %d",value);
    
    quantity.text = [NSString stringWithFormat:@"%d",value];
    
    
    UILabel *itemNum = (UILabel *)[parentCell viewWithTag:32];
    int num = [itemNum.text integerValue];
    
    NSLog(@"UPDATE Ordered SET quantity=%d WHERE itemNum=%d",value,num);
    
    NSString *query = [NSString stringWithFormat:@"UPDATE Ordered SET quantity=%d WHERE itemNum=%d" ,value,num];
    
    [self.dbManager executeQuery:query];
    NSLog(@"%d",self.dbManager.affectedRows);
    
}

- (IBAction)confirmDelivery:(UIBarButtonItem *)sender {
    NSLog(@"In confirm Delivery method");
    self.confirmed = YES;
    NSString *query;
    
    self.arrAllOrderedProducts = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:@"SELECT * FROM Ordered"]];
    NSLog(@"ALl products count  %lu",(unsigned long)self.arrAllOrderedProducts.count);
    
    NSArray *currentStocks =  [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:@"SELECT * FROM Current"]];
    NSLog(@"ALl current stocks count  %lu",(unsigned long)currentStocks.count);
    NSLog(@"%@",currentStocks);
    
    
    
    NSMutableArray *allProductsCopy = [NSMutableArray new];
    
    for(int i=0; i < self.arrAllOrderedProducts.count; i++) {
        NSLog(@"%@",self.arrAllOrderedProducts[i]);
        [allProductsCopy addObject: self.arrAllOrderedProducts[i]];
    }
    
    NSLog(@"ALl copy stocks count  %lu",(unsigned long)allProductsCopy.count);
    
    NSMutableArray *toBeRemoved = [[NSMutableArray alloc]init];
    
    for (NSArray *allPr in allProductsCopy) {
        for (NSMutableArray *currentPr in currentStocks) {

            NSLog(@"allPr[0] %@",allPr[0]);
            NSLog(@"currentPr[0] %@",currentPr[0]);
            
            if([allPr[0] integerValue]==[currentPr[0] integerValue]){
                int itemNum = [allPr[0] integerValue];
                NSLog(@"ItemNum %d",itemNum);
                int currentValue = [currentPr[currentPr.count-1] integerValue];
                NSLog(@"currentValue %d",currentValue);
                int valueFromDelivery = [allPr[allPr.count-1] integerValue];
                NSLog(@"valueFromDelivery %d",valueFromDelivery);
                int valueAfterDelivery = currentValue+valueFromDelivery;
                NSLog(@"valueAfterDelivery %d",valueAfterDelivery);
                
                query = [NSString stringWithFormat:@"UPDATE Current SET quantity=%d WHERE itemNum=%d",valueAfterDelivery,itemNum];
                NSLog(@"%@",query);
                [self.dbManager executeQuery:query];
                NSLog(@"Number of affected rows %d",self.dbManager.affectedRows);
                
                //add in the items to be removed the array which contains the same product
                [toBeRemoved addObject:allPr];
            }
            
        }
    }
    
    //remove the already queried products
    [allProductsCopy removeObjectsInArray:toBeRemoved];
    
    if(allProductsCopy.count > 0){
        
        for (NSArray *temp in allProductsCopy) {
            int itemNum = [temp[0] integerValue];
            NSString *category = temp[1];
            NSString *name = temp[2];
            int purchasePr = [temp[3] integerValue];
            int resalePr = [temp[4] integerValue];
            int quantity = [temp[5]integerValue];
            
            query = [NSString stringWithFormat:@"INSERT INTO Current (itemNum,category,itemName,purchasePrice,resalePrice, quantity) values (%d,'%@','%@', %d,%d,%d)",itemNum,category,name,purchasePr,resalePr,quantity];
            NSLog(@"%@",query);
            [self.dbManager executeQuery:query];
            NSLog(@"Number of affected rows %d",self.dbManager.affectedRows);
            
        }
    }
    
    //    query=@"DELETE FROM Ordered";
    //    NSLog(@"%@",query);
    //    [self.dbManager executeQuery:query];
    
    [self showAlert];
    self.arrAllOrderedProducts = nil;
    [self.tableView reloadData];
}


- (void) showAlert {
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Delivery"
                                                                   message:@"Your delivery was comfirmed."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}


@end
