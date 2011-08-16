#import "TestExCommand.h"
#import "ExParser.h"

@implementation TestExCommand

- (void)test010_SetCommand
{
	NSError *error = nil;
	ExCommand *ex = [[ExParser sharedParser] parse:@"w" error:&error];
	STAssertNotNil(ex, nil);
	STAssertNil(error, nil);
	STAssertEqualObjects(ex.mapping.name, @"write", nil);
	STAssertEquals(ex.mapping.action, @selector(ex_write:), nil);
}

- (void)test011_NonexistentSimpleCommand
{
	NSError *error = nil;
	ExCommand *ex = [[ExParser sharedParser] parse:@"foo bar baz" error:&error];
	STAssertNil(ex, nil);
	STAssertNotNil(error, nil);
}

- (void)test20_AbsoluteAddress
{
	ExAddress *addr;
	NSScanner *scan = [NSScanner scannerWithString:@"17"];
	STAssertTrue([ExParser parseRange:scan intoAddress:&addr], nil);
	STAssertEquals(addr.type, ExAddressAbsolute, nil);
	STAssertEquals(addr.line, 17LL, nil);
	STAssertEquals(addr.offset, 0LL, nil);
}

- (void)test20_LastLineAddress
{
	ExAddress *addr;
	NSScanner *scan = [NSScanner scannerWithString:@"$"];
	STAssertTrue([ExParser parseRange:scan intoAddress:&addr], nil);
	STAssertEquals(addr.type, ExAddressAbsolute, nil);
	STAssertEquals(addr.line, -1LL, nil);
	STAssertEquals(addr.offset, 0LL, nil);
}

- (void)test20_MarkAddress
{
	ExAddress *addr;
	NSScanner *scan = [NSScanner scannerWithString:@"'x"];
	STAssertTrue([ExParser parseRange:scan intoAddress:&addr], nil);
	STAssertEquals(addr.type, ExAddressMark, nil);
	STAssertEquals(addr.mark, (unichar)'x', nil);
	STAssertEquals(addr.offset, 0LL, nil);
}

- (void)test20_Search
{
	ExAddress *addr;
	NSScanner *scan = [NSScanner scannerWithString:@"/pattern/"];
	STAssertTrue([ExParser parseRange:scan intoAddress:&addr], nil);
	STAssertEquals(addr.type, ExAddressSearch, nil);
	STAssertEqualObjects(addr.pattern, @"pattern", nil);
	STAssertEquals(addr.backwards, NO, nil);
	STAssertEquals(addr.offset, 0LL, nil);
}

- (void)test20_SearchNoTerminator
{
	ExAddress *addr;
	NSScanner *scan = [NSScanner scannerWithString:@"/pattern"];
	STAssertTrue([ExParser parseRange:scan intoAddress:&addr], nil);
	STAssertEquals(addr.type, ExAddressSearch, nil);
	STAssertEqualObjects(addr.pattern, @"pattern", nil);
	STAssertEquals(addr.backwards, NO, nil);
	STAssertEquals(addr.offset, 0LL, nil);
}

- (void)test20_BackwardsSearch
{
	ExAddress *addr;
	NSScanner *scan = [NSScanner scannerWithString:@"?pattern?"];
	STAssertTrue([ExParser parseRange:scan intoAddress:&addr], nil);
	STAssertEquals(addr.type, ExAddressSearch, nil);
	STAssertEqualObjects(addr.pattern, @"pattern", nil);
	STAssertEquals(addr.backwards, YES, nil);
	STAssertEquals(addr.offset, 0LL, nil);
}

- (void)test20_BackwardsSearchNoTerminator
{
	ExAddress *addr;
	NSScanner *scan = [NSScanner scannerWithString:@"?pattern"];
	STAssertTrue([ExParser parseRange:scan intoAddress:&addr], nil);
	STAssertEquals(addr.type, ExAddressSearch, nil);
	STAssertEqualObjects(addr.pattern, @"pattern", nil);
	STAssertEquals(addr.backwards, YES, nil);
	STAssertEquals(addr.offset, 0LL, nil);
}

- (void)test20_CurrentPosition
{
	ExAddress *addr;
	NSScanner *scan = [NSScanner scannerWithString:@"."];
	STAssertTrue([ExParser parseRange:scan intoAddress:&addr], nil);
	STAssertEquals(addr.type, ExAddressCurrent, nil);
	STAssertEquals(addr.offset, 0LL, nil);
}

- (void)test20_CurrentPositionPlusOffset
{
	ExAddress *addr;
	NSScanner *scan = [NSScanner scannerWithString:@".+7"];
	STAssertTrue([ExParser parseRange:scan intoAddress:&addr], nil);
	STAssertEquals(addr.type, ExAddressCurrent, nil);
	STAssertEquals(addr.offset, 7LL, nil);
}

- (void)test20_ImplicitCurrentPostionPlusOffset
{
	ExAddress *addr;
	NSScanner *scan = [NSScanner scannerWithString:@"+7"];
	STAssertTrue([ExParser parseRange:scan intoAddress:&addr], nil);
	STAssertEquals(addr.type, ExAddressRelative, nil);
	STAssertEquals(addr.offset, 7LL, nil);
}

- (void)test20_ImplicitCurrentPostionMinusOffset
{
	ExAddress *addr;
	NSScanner *scan = [NSScanner scannerWithString:@"-7"];
	STAssertTrue([ExParser parseRange:scan intoAddress:&addr], nil);
	STAssertEquals(addr.type, ExAddressRelative, nil);
	STAssertEquals(addr.offset, -7LL, nil);
}

- (void)test20_ImplicitCurrentPostionMinusOffset2
{
	ExAddress *addr;
	NSScanner *scan = [NSScanner scannerWithString:@"^7"];
	STAssertTrue([ExParser parseRange:scan intoAddress:&addr], nil);
	STAssertEquals(addr.type, ExAddressRelative, nil);
	STAssertEquals(addr.offset, -7LL, nil);
}

- (void)test20_AdditiveOffsets
{
	ExAddress *addr;
	NSScanner *scan = [NSScanner scannerWithString:@"2 2 3p"];
	STAssertTrue([ExParser parseRange:scan intoAddress:&addr], nil);
	STAssertEquals(addr.type, ExAddressAbsolute, nil);
	STAssertEquals(addr.line, 2LL, nil);
	STAssertEquals(addr.offset, 5LL, nil);
}

- (void)test20_OffsetsWithOnlySigns
{
	ExAddress *addr;
	NSScanner *scan = [NSScanner scannerWithString:@"3 - 2"];
	STAssertTrue([ExParser parseRange:scan intoAddress:&addr], nil);
	STAssertEquals(addr.type, ExAddressAbsolute, nil);
	STAssertEquals(addr.line, 3LL, nil);
	STAssertEquals(addr.offset, 1LL, nil);
}

- (void)test20_SearchWithAdditiveOffsets
{
	ExAddress *addr;
	NSScanner *scan = [NSScanner scannerWithString:@"/pattern/2 2 2"];
	STAssertTrue([ExParser parseRange:scan intoAddress:&addr], nil);
	STAssertEquals(addr.type, ExAddressSearch, nil);
	STAssertEqualObjects(addr.pattern, @"pattern", nil);
	STAssertEquals(addr.backwards, NO, nil);
	STAssertEquals(addr.offset, 6LL, nil);
}



- (void)test30_WholeFile
{
	ExAddress *addr1, *addr2;
	NSScanner *scan = [NSScanner scannerWithString:@"%"];
	STAssertEquals([ExParser parseRange:scan intoAddress:&addr1 otherAddress:&addr2], 2, nil);
	STAssertEquals(addr1.type, ExAddressAbsolute, nil);
	STAssertEquals(addr1.line, 1LL, nil);
	STAssertEquals(addr1.offset, 0LL, nil);
	STAssertEquals(addr2.type, ExAddressAbsolute, nil);
	STAssertEquals(addr2.line, -1LL, nil);
	STAssertEquals(addr2.offset, 0LL, nil);
}

- (void)test30_AbsoluteCommaAbsolute
{
	ExAddress *addr1, *addr2;
	NSScanner *scan = [NSScanner scannerWithString:@"1,2"];
	STAssertEquals([ExParser parseRange:scan intoAddress:&addr1 otherAddress:&addr2], 2, nil);
	STAssertEquals(addr1.type, ExAddressAbsolute, nil);
	STAssertEquals(addr1.line, 1LL, nil);
	STAssertEquals(addr1.offset, 0LL, nil);
	STAssertEquals(addr2.type, ExAddressAbsolute, nil);
	STAssertEquals(addr2.line, 2LL, nil);
	STAssertEquals(addr2.offset, 0LL, nil);
}

- (void)test30_AbsoluteCommaSearch
{
	ExAddress *addr1, *addr2;
	NSScanner *scan = [NSScanner scannerWithString:@"3,/pattern/"];
	STAssertEquals([ExParser parseRange:scan intoAddress:&addr1 otherAddress:&addr2], 2, nil);
	STAssertEquals(addr1.type, ExAddressAbsolute, nil);
	STAssertEquals(addr1.line, 3LL, nil);
	STAssertEquals(addr1.offset, 0LL, nil);
	STAssertEquals(addr2.type, ExAddressSearch, nil);
	STAssertEqualObjects(addr2.pattern, @"pattern", nil);
	STAssertEquals(addr2.backwards, NO, nil);
	STAssertEquals(addr2.offset, 0LL, nil);
}



- (void)test40_singleComment
{
	NSError *error = nil;
	ExCommand *ex = [[ExParser sharedParser] parse:@":\"foo|set" error:&error];
	// "
	STAssertNotNil(ex, nil);
	STAssertNil(error, nil);
	STAssertEqualObjects(ex.mapping.name, @"#", nil);
	STAssertTrue(ex.mapping.action == @selector(ex_goto:), nil);
}

- (void)test50_AddressExtraColonCommand
{
	NSError *error = nil;
	ExCommand *ex = [[ExParser sharedParser] parse:@":3,5:eval" error:&error];
	STAssertNotNil(ex, nil);
	STAssertNil(error, nil);
	STAssertEquals(ex.naddr, 2ULL, nil);
	STAssertNotNil(ex.addr1, nil);
	STAssertNotNil(ex.addr2, nil);
	STAssertEquals(ex.addr1.type, ExAddressAbsolute, nil);
	STAssertEquals(ex.addr2.type, ExAddressAbsolute, nil);
	STAssertEqualObjects(ex.mapping.name, @"eval", nil);
	STAssertEquals(ex.mapping.action, @selector(ex_eval:), nil);
}

- (void)test60_semicolonDelimitedRange
{
	NSError *error = nil;
	ExCommand *ex = [[ExParser sharedParser] parse:@"  :3;/pattern/d" error:&error];
	STAssertNotNil(ex, nil);
	STAssertNil(error, nil);
	STAssertEqualObjects(ex.mapping.name, @"delete", nil);
	STAssertEquals(ex.mapping.action, @selector(ex_delete:), nil);

	STAssertEquals(ex.naddr, 2ULL, nil);
	STAssertEquals([ex addr1].type, ExAddressAbsolute, nil);
	STAssertEquals([ex addr1].line, 3LL, nil);
	STAssertEquals([ex addr1].offset, 0LL, nil);
	STAssertEquals([ex addr2].type, ExAddressSearch, nil);
	STAssertEqualObjects([ex addr2].pattern, @"pattern", nil);
	STAssertEquals([ex addr2].backwards, NO, nil);
	STAssertEquals([ex addr2].offset, 0LL, nil);

}

#if 0
- (void)test60_OneAddressCommandWithTwoAddresses
{
	ExCommand *ex = [[ExCommand alloc] initWithString:@"'a,5pu"];
	STAssertNotNil(ex, nil);
	STAssertEqualObjects(ex.method, @"ex_put", nil);
	STAssertEquals(ex.naddr, 1ULL, nil);
	STAssertEquals([ex addr1].type, ExAddressAbsolute, nil);
	STAssertEquals([ex addr1].line, 5LL, nil);
}

- (void)test60_OneAddressCommandWithZeroAddresses
{
	ExCommand *ex = [[ExCommand alloc] initWithString:@"put"];
	STAssertNotNil(ex, nil);
	STAssertEqualObjects(ex.method, @"ex_put", nil);
	STAssertEquals(ex.naddr, 1ULL, nil);
	STAssertEquals([ex addr1].type, ExAddressCurrent, nil);
}



- (void)test70_GlobalCommandWithStringArgument
{
	ExCommand *ex = [[ExCommand alloc] initWithString:@":g/pattern/:p"];
	STAssertNotNil(ex, nil);
	STAssertEqualObjects(ex.name, @"g", nil);
	STAssertEqualObjects(ex.method, @"ex_global", nil);
	STAssertEqualObjects(ex.string, @"/pattern/:p", nil);
}

- (void)test70_CopyToLineZero
{
	ExCommand *ex = [[ExCommand alloc] initWithString:@"-,+t0"];
	STAssertNotNil(ex, nil);
	STAssertEqualObjects(ex.name, @"t", nil);
	STAssertEqualObjects(ex.method, @"ex_copy", nil);
	STAssertEquals(ex.naddr, 2ULL, nil);
	STAssertEquals([ex line].type, ExAddressAbsolute, nil);
	STAssertEquals([ex line].line, 0LL, nil);
	STAssertEquals([ex line].offset, 0LL, nil);
}

- (void)test70_MoveCommandWithDestinationAddress
{
	ExCommand *ex = [[ExCommand alloc] initWithString:@"20,.m$"];
	STAssertNotNil(ex, nil);
	STAssertEqualObjects(ex.name, @"m", nil);
	STAssertEqualObjects(ex.method, @"ex_move", nil);
	STAssertEquals(ex.naddr, 2ULL, nil);
	STAssertEquals([ex addr1].type, ExAddressAbsolute, nil);
	STAssertEquals([ex addr2].type, ExAddressCurrent, nil);
	STAssertEquals([ex line].type, ExAddressAbsolute, nil);
	STAssertEquals([ex line].line, -1LL, nil);
	STAssertEquals([ex line].offset, 0LL, nil);
}

- (void)test70_MoveCommandWithDestinationAddressAndOffset
{
	ExCommand *ex = [[ExCommand alloc] initWithString:@"226,$m.-2"];
	STAssertNotNil(ex, nil);
	STAssertEqualObjects(ex.name, @"m", nil);
	STAssertEqualObjects(ex.method, @"ex_move", nil);
	STAssertEquals(ex.naddr, 2ULL, nil);
	STAssertEquals([ex addr1].type, ExAddressAbsolute, nil);
	STAssertEquals([ex addr2].type, ExAddressAbsolute, nil);
	STAssertEquals([ex line].type, ExAddressCurrent, nil);
	STAssertEquals([ex line].offset, -2LL, nil);
}

- (void)test70_EditCommandWithPlusCommand
{
	ExCommand *ex = [[ExCommand alloc] initWithString:@"edit +25|s/abc/ABC/ file.c"];
	STAssertNotNil(ex, nil);
	STAssertEqualObjects(ex.name, @"edit", nil);
	STAssertEqualObjects(ex.method, @"ex_edit", nil);
	STAssertEqualObjects(ex.plus_command, @"25|s/abc/ABC/", nil);
	STAssertEqualObjects(ex.filename, @"file.c", nil);
}

- (void)test80_BangCommand
{
	ExCommand *ex = [[ExCommand alloc] initWithString:@"!ls"];
	STAssertNotNil(ex, nil);
	STAssertEqualObjects(ex.name, @"!", nil);
	STAssertEqualObjects(ex.method, @"ex_bang", nil);
	STAssertEqualObjects(ex.string, @"ls", nil);
}

- (void)test80_BangCommandWithShellPipe
{
	ExCommand *ex = [[ExCommand alloc] initWithString:@"!ls -1 | grep .m"];
	STAssertNotNil(ex, nil);
	STAssertEqualObjects(ex.name, @"!", nil);
	STAssertEqualObjects(ex.method, @"ex_bang", nil);
	STAssertEqualObjects(ex.string, @"ls -1 | grep .m", nil);
}
#endif

@end
