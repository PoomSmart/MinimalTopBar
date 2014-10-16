#import <PhotoLibrary/PhotoLibrary.h>

@interface CAMFlashButton (Addition)
- (void)_updateLabelVisibilityAnimated:(BOOL)animated;
@end

%hook CAMFlashButton

%new
- (void)_updateLabelVisibilityAnimated:(BOOL)animated
{
	BOOL expanded = self.expanded;
	CGFloat alpha = expanded ? 1 : 0;
	[UIView animateWithDuration:animated ? [UIView pl_setHiddenAnimationDuration] : 0 animations:^{
		self._offLabel.alpha = alpha;
		self._onLabel.alpha = alpha;
		self._autoLabel.alpha = alpha;
		self._landscapeFeatureLabel.alpha = alpha;
	}];
}

- (void)_expandAnimated:(BOOL)animated
{
	%orig;
	[self _updateLabelVisibilityAnimated:animated];
}

- (void)_collapseAndSetMode:(int)mode animated:(BOOL)animated
{
	%orig;
	[self _updateLabelVisibilityAnimated:animated];
}

- (void)_performHighlightAnimation
{
	%orig;
	[self _updateLabelVisibilityAnimated:YES];
}

- (void)setOrientation:(int)orientation animated:(BOOL)animated
{
	%orig;
	[self _updateLabelVisibilityAnimated:animated];
}

- (void)_updateText
{
	%orig;
	[self _updateLabelVisibilityAnimated:NO];
}

- (void)_computeLayoutAndApply:(BOOL)apply
{
	%orig;
	if (apply)
		[self _updateLabelVisibilityAnimated:NO];
}

%end

@interface CAMHDRButton (Addition)
- (void)_showLabels:(BOOL)show animated:(BOOL)animated;
- (void)_shortenLabelAnimated:(BOOL)animated;
@end

%hook CAMHDRButton

%new
- (void)_showLabels:(BOOL)show animated:(BOOL)animated
{
	CGFloat alpha = show ? 1 : 0;
	[UIView animateWithDuration:animated ? [UIView pl_setHiddenAnimationDuration] : 0 animations:^{
		self._onLabel.alpha = alpha;
		self._offLabel.alpha = alpha;
		self._autoLabel.alpha = alpha;
	}];
}

%new
- (void)_shortenLabelAnimated:(BOOL)animated
{
	BOOL expanded = self.expanded;
	BOOL landscape = self.orientation == 3 || self.orientation == 4;
	NSString *defaultText = [self _localizedString:[self _featureTextForLandscape]];
	if (!landscape) {
		[self _showLabels:YES animated:animated];
		self._onLabel.text = expanded ? [self _localizedString:[self _onLabelTextForLandscape:landscape]] : defaultText;
		self._offLabel.text = expanded ? [self _localizedString:[self _offLabelTextForLandscape:landscape]] : defaultText;
		self._autoLabel.text = expanded ? [self _localizedString:[self _autoLabelTextForLandscape:landscape]] : defaultText;
	} else
		[self _showLabels:expanded animated:animated];
}

- (void)_updateText
{
	%orig;
	[self _shortenLabelAnimated:YES];
}

- (void)_expandAnimated:(BOOL)animated
{
	%orig;
	[self _shortenLabelAnimated:animated];
}

- (void)_collapseAndSetMode:(int)mode animated:(BOOL)animated
{
	%orig;
	[self _shortenLabelAnimated:animated];
}

- (void)_performHighlightAnimation
{
  %orig;
  [self _shortenLabelAnimated:YES];
}

- (void)setOrientation:(int)orientation animated:(BOOL)animated
{
  %orig;
  [self _shortenLabelAnimated:animated];
}

- (void)_computeLayoutAndApply:(BOOL)apply
{
  %orig;
  if (apply)
    [self _shortenLabelAnimated:NO];
}

%end

%ctor
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  dlopen("/System/Library/PrivateFrameworks/PhotoLibrary.framework/PhotoLibrary", RTLD_LAZY);
  %init;
  [pool drain];
}
