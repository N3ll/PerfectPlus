//
//  AllProductsViewController.m
//  Perfect
//
//  Created by Rostislav Dimitrov on 5/14/15.
//  Copyright (c) 2015 Him and Her. All rights reserved.
//

#import "AllProductsViewController.h"
#import "SecondTableViewController.h"
@interface AllProductsViewController ()
@property (strong, nonatomic) IBOutletCollection

(UIButton) NSArray *categories;

@property (strong,nonatomic) NSString *category;

@end



@implementation AllProductsViewController



- (void)viewDidLoad {
    
    
    [super viewDidLoad];
    
    
}

-(IBAction)pressCategory:(UIButton*)sender{
    
    
    NSLog(@"The tag is %ld",(long)sender.tag);
    switch (sender.tag) {
        case 1:
            self.category = @"backpack";
            NSLog(@"backpack");
            break;
        case 2:
            self.category = @"ladybag";
            NSLog(@"ladybag");
            break;
        case 3:
            self.category = @"menbag";
            NSLog(@"menbag");
            break;
        case 4:
            self.category = @"sack";
            NSLog(@"sack");
            break;
        case 5:
            self.category = @"suitcase";
            NSLog(@"suitcase");
            break;
        case 6:
            self.category = @"wallet";
            NSLog(@"wallet");
            break;
            
        default:
            break;
    }
    
    [self performSegueWithIdentifier:@"second" sender:sender];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"second"]) {
        
        SecondTableViewController *dest= (SecondTableViewController*)[segue destinationViewController];
        NSLog(@"%@",self.category);
        dest.categoryForDB = [NSMutableString stringWithString:self.category];
        dest.navigationItem.title = self.category;
    }
    
}


@end
