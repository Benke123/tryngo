//
//  CategoryPopover.m
//  tryngo
//
//  Created by michail on 24/03/15.
//  Copyright (c) 2015 Rhinoda. All rights reserved.
//

#import "CategoryPopover.h"

@implementation CategoryPopover {
    int tag;
    UIDevice *currentDevice;
    float heightCell;
    NSArray *contentArray;
}

- (id)initWithFrame:(CGRect)frame andTag:(int)_index andContent:(NSArray *)_contentArray
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        tag = _index;
        contentArray = _contentArray;
        currentDevice = [UIDevice currentDevice];
        if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            heightCell = 50;
        }
        if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            heightCell = 80;
        }
        [self setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.7f]];
        UIButton *backgroundButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backgroundButton setFrame:self.frame];
        [backgroundButton addTarget:self action:@selector(pressBackground) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:backgroundButton];
        [self create];
    }
    return self;
}

-(void)create {
    CGRect sizeTableView;
    if (tag == 0) {
        int count;
        if (contentArray.count > 8) {
            count = 8;
        } else {
            count = contentArray.count;
        }
        sizeTableView.size.height = contentArray.count * heightCell;
    } else if (tag == 1) {
        sizeTableView.size.height = heightCell * 8;
    }
    sizeTableView.size.width = self.frame.size.width * 2 / 3;
    sizeTableView.origin.x = (self.frame.size.width - sizeTableView.size.width) / 2;
    sizeTableView.origin.y = (self.frame.size.height - sizeTableView.size.height) / 2;
    
    UITableView *tableView;
    if (tag == 0) {
        tableView = [[UITableView alloc] initWithFrame:sizeTableView style:UITableViewStylePlain];
    } else if (tag == 1) {
        tableView = [[UITableView alloc] initWithFrame:sizeTableView style:UITableViewStyleGrouped];
    }
    [tableView setBackgroundColor:[UIColor whiteColor]];
    [tableView setSeparatorColor:[UIColor colorWithRed:32.0f/255.0f green:137.0f/255.0f blue:198.0f/255.0f alpha:1.0f]];
    [tableView setRowHeight:heightCell];
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView.layer setBorderColor:[UIColor colorWithRed:32.0f/255.0f green:137.0f/255.0f blue:198.0f/255.0f alpha:1.0f].CGColor];
    [tableView.layer setBorderWidth:1];
    [tableView.layer setCornerRadius:4];
    [self addSubview:tableView];
}

-(void)pressBackground {
    [self.delegate removePopup];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int sectionsCount;
    if (tag == 0) {
        sectionsCount = 1;
    } else {
        sectionsCount = contentArray.count;
    }
    return sectionsCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = 0;
    if (tag == 0) {
        @try {
            count = [contentArray count];
        } @catch (NSException *e) {
            count = 0;
        }
    } else {
        NSArray *curentArray = [[contentArray objectAtIndex:section] objectForKey:@"array"];
        count = curentArray.count;
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:CellIdentifier];
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        cell.textLabel.font = [FONT regularFontWithSize:13];
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        cell.textLabel.font = [FONT regularFontWithSize:27];
    }
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    
    if (tag == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = [contentArray objectAtIndex:indexPath.row];
        } else {
            cell.textLabel.text = [[contentArray objectAtIndex:indexPath.row] objectForKey:@"name"];
        }
    } else {
        NSDictionary *curentDictionary = [contentArray objectAtIndex:indexPath.section];
        NSString *text = [[[curentDictionary objectForKey:@"array"] allValues] objectAtIndex:indexPath.row];
 //       cell.textLabel.text = [curentArray objectAtIndex:indexPath.row];
        cell.textLabel.text = text;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tag == 0) {
        NSString *name;
        if (indexPath.row == 0) {
            name = @"Service type";
        } else {
            name = [[contentArray objectAtIndex:indexPath.row] objectForKey:@"name"];
        }
        [self.delegate selectCategory:indexPath.row andType:tag andName:name];
    } else if (tag == 1) {
        NSDictionary *curentDictionary = [contentArray objectAtIndex:indexPath.section];
        NSString *index = [[[curentDictionary objectForKey:@"array"] allKeys] objectAtIndex:indexPath.row];
        NSString *name = [[[curentDictionary objectForKey:@"array"] allValues] objectAtIndex:indexPath.row];
        [self.delegate selectCategory:[index intValue] andType:tag andName:name];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title;
    if (tag == 0) {
        title = @"";
    } else if (tag == 1) {
        title = [NSString stringWithFormat:@"%@", [[contentArray objectAtIndex:section] objectForKey:@"title"]];
    }
    return title;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    
    
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        header.textLabel.font = [FONT boldFontWithSize:13];
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        header.textLabel.font = [FONT boldFontWithSize:27];
    }
    header.textLabel.textAlignment = NSTextAlignmentCenter;
    CGRect headerFrame = header.frame;
    header.textLabel.frame = headerFrame;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
