//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "LMPageView.h"

@implementation LMPageView
{
    NSMutableArray *_pages;

    NSArray *_constraints;
}

+ (BOOL)requiresConstraintBasedLayout
{
    return YES;
}

#define INIT {\
    _pages = [NSMutableArray new];\
    [super setPagingEnabled:YES];\
    [super setShowsHorizontalScrollIndicator:NO];\
    [super setShowsVerticalScrollIndicator:NO];\
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (self) INIT

    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];

    if (self) INIT

    return self;
}

- (NSArray *)pages
{
    return [_pages copy];
}

- (void)addPage:(UIView *)page
{
    [self insertPage:page atIndex:[_pages count]];
}

- (void)insertPage:(UIView *)page atIndex:(NSUInteger)index
{
    if ([_pages indexOfObject:page] == NSNotFound) {
        [page setTranslatesAutoresizingMaskIntoConstraints:NO];

        [self addSubview:page];

        [_pages insertObject:page atIndex:index];

        [self invalidateIntrinsicContentSize];
        [self setNeedsUpdateConstraints];
    } else {
        [NSException raise:NSInvalidArgumentException format:@"View is already a page."];
    }
}

- (void)removePage:(UIView *)page
{
    NSUInteger index = [_pages indexOfObject:page];

    if (index != NSNotFound) {
        [_pages removeObjectAtIndex:index];

        [self invalidateIntrinsicContentSize];
        [self setNeedsUpdateConstraints];
    }
}

- (void)willRemoveSubview:(UIView *)subview
{
    [self removePage:subview];

    [super willRemoveSubview:subview];
}

- (void)setNeedsUpdateConstraints
{
    if (_constraints != nil) {
        [NSLayoutConstraint deactivateConstraints:_constraints];

        _constraints = nil;
    }

    [super setNeedsUpdateConstraints];
}

- (void)updateConstraints
{
    if (_constraints == nil) {
        if ([_pages count] > 0) {
            NSMutableArray *constraints = [NSMutableArray new];

            UIView *previousPage = nil;

            for (UIView *page in _pages) {
                // Align to siblings
                if (previousPage == nil) {
                    [constraints addObject:[NSLayoutConstraint constraintWithItem:page attribute:NSLayoutAttributeLeft
                        relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft
                        multiplier:1 constant:0]];
                } else {
                    [constraints addObject:[NSLayoutConstraint constraintWithItem:page attribute:NSLayoutAttributeLeft
                        relatedBy:NSLayoutRelationEqual toItem:previousPage attribute:NSLayoutAttributeRight
                        multiplier:1 constant:0]];
                }

                // Align to parent
                [constraints addObject:[NSLayoutConstraint constraintWithItem:page attribute:NSLayoutAttributeTop
                    relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop
                    multiplier:1 constant:0]];

                [constraints addObject:[NSLayoutConstraint constraintWithItem:page attribute:NSLayoutAttributeBottom
                    relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom
                    multiplier:1 constant:0]];

                // Match page width/height to page view width/height
                [constraints addObject:[NSLayoutConstraint constraintWithItem:page attribute:NSLayoutAttributeWidth
                    relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth
                    multiplier:1 constant:0]];

                [constraints addObject:[NSLayoutConstraint constraintWithItem:page attribute:NSLayoutAttributeHeight
                    relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight
                    multiplier:1 constant:0]];

                previousPage = page;
            }

            // Align final view to trailing edge
            if (previousPage != nil) {
                [constraints addObject:[NSLayoutConstraint constraintWithItem:previousPage attribute:NSLayoutAttributeRight
                    relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight
                    multiplier:1 constant:0]];
            }

            _constraints = constraints;
        }

        if (_constraints != nil) {
            [NSLayoutConstraint activateConstraints:_constraints];
        }
    }

    [super updateConstraints];
}

- (void)appendMarkupElementView:(UIView *)view
{
    [self addPage:view];
}

@end
