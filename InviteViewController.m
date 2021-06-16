//
//  InviteViewController.m
//  POP
//
//  Created by KingTon on 9/4/17.
//  Copyright © 2017 salentro. All rights reserved.
//

#import "InviteViewController.h"
#import "ContactsViewController.h"
@interface InviteViewController ()

@end

@implementation InviteViewController {
    int selected_item;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section ==0) {
        return 4;
    }else if(section ==1) {
        return 0;
    }
    
    return 0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    int row = (int)indexPath.row;
    UITableViewCell *cell;
    if (indexPath.section ==0){
         if(row ==0) {
            cell =(UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"cell_setting"];
            UIImageView *view = (UIImageView *)[cell viewWithTag:1];
            view.image = [UIImage imageNamed:@"facebook.png"];
            ((UILabel*)[cell viewWithTag:2]).text = @"Invite Facebook Friends";
        }else if(row ==1) {
            cell =(UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"cell_setting1"];
            UIImageView *view = (UIImageView *)[cell viewWithTag:3];
            view.image = [UIImage imageNamed:@"twitter.png"];
            ((UILabel*)[cell viewWithTag:4]).text = @"Invite Twitter Followers";
        }else if(row ==2) {
            cell =(UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"cell_setting2"];
            UIImageView *view = (UIImageView *)[cell viewWithTag:5];
            view.image = [UIImage imageNamed:@"instagram.png"];
            ((UILabel*)[cell viewWithTag:6]).text = @"Invite Instagram Followers";
        }else if(row ==3) {
            cell =(UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"cell_setting3"];
            UIImageView *view = (UIImageView *)[cell viewWithTag:7];
            view.image = [UIImage imageNamed:@"contact.png"];
            ((UILabel*)[cell viewWithTag:8]).text = @"Invite Contacts";
        }
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.table_view deselectRowAtIndexPath:indexPath animated:NO];
    selected_item = (int)indexPath.row;
    if (indexPath.section ==0) {
        if (indexPath.row == 3) {
            ContactsViewController * send = [self.storyboard instantiateViewControllerWithIdentifier:@"ContactsViewController"];
            [self.navigationController pushViewController:send animated:NO];
        }
    }
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return @"";
    if (section == 1)
        return @"";
    return @"undefined";
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section ==0) {
        return 60;
    }else if (section ==1) {
        return 320;
    }
    return 0;
}

@end
