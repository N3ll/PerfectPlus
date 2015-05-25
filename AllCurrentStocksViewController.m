//
//  AllCurrentStocksViewController.m
//  PerfectProject
//
//  Created by Nelly Chakarova on 17/05/15.
//  Copyright (c) 2015 Nelly Chakarova. All rights reserved.
//

#import "AllCurrentStocksViewController.h"
#import "DBManager.h"
#import "CurrentStocksTableViewController.h"

@interface AllCurrentStocksViewController ()

@property (strong,nonatomic) NSString *category;
@property (strong,nonatomic) DBManager *dbManager;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *categories;


@end

@implementation AllCurrentStocksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Initialize the dbManager object.
    self.dbManager = [[DBManager alloc]initWithDatabaseFilename:@"perfect.sql"];
    
    NSString *query = @"SELECT DISTINCT category FROM Current";
    NSLog(@"%@",query);
    NSArray *buttons= [[NSArray alloc]initWithArray:[self.dbManager loadDataFromDB:query]];
    
    
    for (NSArray *temp in buttons) {
        NSString *category = [NSString stringWithFormat:@"%@",temp[0]];
        if ([category isEqualToString: @"backpack"]) {
            UIButton *backpack =(UIButton*)[self.view viewWithTag:90];
            backpack.enabled=YES;
        } else if ([category isEqualToString: @"ladybag"]) {
            UIButton *ladybag =(UIButton*)[self.view viewWithTag:91];
            ladybag.enabled=YES;
        }  else if ([category isEqualToString: @"menbag"]) {
            UIButton *menbag =(UIButton*)[self.view viewWithTag:92];
            menbag.enabled=YES;
        }  else if ([category isEqualToString: @"sack"]) {
            UIButton *sack =(UIButton*)[self.view viewWithTag:93];
            sack.enabled=YES;
        } else if ([category isEqualToString: @"suitcase"]) {
            UIButton *suitcase =(UIButton*)[self.view viewWithTag:94];
            suitcase.enabled=YES;
        } else if ([category isEqualToString: @"wallet"]) {
            UIButton *wallet =(UIButton*)[self.view viewWithTag:95];
            wallet.enabled=YES;
        }
    }
}

-(IBAction)pressCategory:(UIButton*)sender{
    NSLog(@"The tag is %ld",(long)sender.tag);
    switch (sender.tag) {
        case 90:
            self.category = @"backpack";
            NSLog(@"backpack");
            break;
        case 91:
            self.category = @"ladybag";
            NSLog(@"ladybag");
            break;
        case 92:
            self.category = @"menbag";
            NSLog(@"menbag");
            break;
        case 93:
            self.category = @"sack";
            NSLog(@"sack");
            break;
        case 94:
            self.category = @"suitcase";
            NSLog(@"suitcase");
            break;
        case 95:
            self.category = @"wallet";
            NSLog(@"wallet");
            break;
            
        default:
            break;
    }
    
    NSLog(@"First");
    [self performSegueWithIdentifier:@"currentStocks" sender:sender];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"Second");
    if([segue.identifier isEqualToString:@"currentStocks"]){
        CurrentStocksTableViewController *dest= (CurrentStocksTableViewController*)[segue destinationViewController];
        dest.categoryForDB = [NSMutableString stringWithString:self.category];
        dest.navigationItem.title = self.category;
    }
}

@end
