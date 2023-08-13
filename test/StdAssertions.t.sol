// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "../src/Test.sol";

contract StdAssertionsTest is Test {
    string constant CUSTOM_ERROR = "guh!";

    bool constant EXPECT_PASS = false;
    bool constant EXPECT_FAIL = true;

    bool constant SHOULD_REVERT = true;
    bool constant SHOULD_RETURN = false;

    bool constant STRICT_REVERT_DATA = true;
    bool constant NON_STRICT_REVERT_DATA = false;

    TestTest t = new TestTest();

    /*//////////////////////////////////////////////////////////////////////////
                                    FAIL(STRING)
    //////////////////////////////////////////////////////////////////////////*/

    function test_ShouldFail() external {
        vm.expectEmit(false, false, false, true);
        emit log_named_string("Error", CUSTOM_ERROR);
        t._fail(CUSTOM_ERROR);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    ASSERT_FALSE
    //////////////////////////////////////////////////////////////////////////*/

    function test_AssertFalse() external {
        t._assertFalse(false, EXPECT);
    }

    function testFail_AssertFalse() external {
        vm.expectEmit(false, false, false, true);
        emit log("Error: Assertion Failed");
        t._assertFalse(true, EXPECT_FAIL);
    }

    function test_AssertFalse_Err() external {
        t._assertFalse(false, CUSTOM_ERROR, EXPECT);
    }

    function testFail_AssertFalse_Err() external {
        vm.expectEmit(false, false, false, true);
        emit log_named_string("Error", CUSTOM_ERROR);
        t._assertFalse(true, CUSTOM_ERROR, EXPECT_FAIL);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    ASSERT_EQ(BOOL)
    //////////////////////////////////////////////////////////////////////////*/

    function testFuzz_AssertEq_Bool(bool a) external {
        t._assertEq(a, a, EXPECT);
    }

    function testFailFuzz_AssertEq_Bool(bool a, bool b) external {
        vm.assume(a != b);

        vm.expectEmit(false, false, false, true);
        emit log("Error: a == b not satisfied [bool]");
        t._assertEq(a, b, EXPECT_FAIL);
    }

    function testFuzz_AssertEq_BoolErr(bool a) external {
        t._assertEq(a, a, CUSTOM_ERROR, EXPECT);
    }

    function testFailFuzz_AssertEq_BoolErr(bool a, bool b) external {
        vm.assume(a != b);

        vm.expectEmit(false, false, false, true);
        emit log_named_string("Error", CUSTOM_ERROR);
        t._assertEq(a, b, CUSTOM_ERROR, EXPECT_FAIL);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    ASSERT_EQ(BYTES)
    //////////////////////////////////////////////////////////////////////////*/

    function testFuzz_AssertEq_Bytes(bytes calldata a) external {
        t._assertEq(a, a, EXPECT);
    }

    function testFailFuzz_AssertEq_Bytes(bytes calldata a, bytes calldata b) external {
        vm.assume(keccak256(a) != keccak256(b));

        vm.expectEmit(false, false, false, true);
        emit log("Error: a == b not satisfied [bytes]");
        t._assertEq(a, b, EXPECT_FAIL);
    }

    function testFuzz_AssertEq_BytesErr(bytes calldata a) external {
        t._assertEq(a, a, CUSTOM_ERROR, EXPECT);
    }

    function testFailFuzz_AssertEq_BytesErr(bytes calldata a, bytes calldata b) external {
        vm.assume(keccak256(a) != keccak256(b));

        vm.expectEmit(false, false, false, true);
        emit log_named_string("Error", CUSTOM_ERROR);
        t._assertEq(a, b, CUSTOM_ERROR, EXPECT_FAIL);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    ASSERT_EQ(ARRAY)
    //////////////////////////////////////////////////////////////////////////*/

    function testFuzz_AssertEq_UintArr(uint256 e0, uint256 e1, uint256 e2) public {
        uint256[] memory a = new uint256[](3);
        a[0] = e0;
        a[1] = e1;
        a[2] = e2;
        uint256[] memory b = new uint256[](3);
        b[0] = e0;
        b[1] = e1;
        b[2] = e2;

        t._assertEq(a, b, EXPECT);
    }

    function testFuzz_AssertEq_IntArr(int256 e0, int256 e1, int256 e2) public {
        int256[] memory a = new int256[](3);
        a[0] = e0;
        a[1] = e1;
        a[2] = e2;
        int256[] memory b = new int256[](3);
        b[0] = e0;
        b[1] = e1;
        b[2] = e2;

        t._assertEq(a, b, EXPECT);
    }

    function testFuzz_AssertEq_AddressArr(address e0, address e1, address e2) public {
        address[] memory a = new address[](3);
        a[0] = e0;
        a[1] = e1;
        a[2] = e2;
        address[] memory b = new address[](3);
        b[0] = e0;
        b[1] = e1;
        b[2] = e2;

        t._assertEq(a, b, EXPECT);
    }

    function testFailFuzz_AssertEq_UintArr(uint256 e1) public {
        vm.assume(e1 != 0);
        uint256[] memory a = new uint256[](3);
        uint256[] memory b = new uint256[](3);
        b[1] = e1;

        vm.expectEmit(false, false, false, true);
        emit log("Error: a == b not satisfied [uint[]]");
        t._assertEq(a, b, EXPECT_FAIL);
    }

    function testFailFuzz_AssertEq_IntArr(int256 e1) public {
        vm.assume(e1 != 0);
        int256[] memory a = new int256[](3);
        int256[] memory b = new int256[](3);
        b[1] = e1;

        vm.expectEmit(false, false, false, true);
        emit log("Error: a == b not satisfied [int[]]");
        t._assertEq(a, b, EXPECT_FAIL);
    }

    function testFailFuzz_AssertEq_AddressArr(address e1) public {
        vm.assume(e1 != address(0));
        address[] memory a = new address[](3);
        address[] memory b = new address[](3);
        b[1] = e1;

        vm.expectEmit(false, false, false, true);
        emit log("Error: a == b not satisfied [address[]]");
        t._assertEq(a, b, EXPECT_FAIL);
    }

    function testFailFuzz_AssertEq_UintArrErr(uint256 e1) public {
        vm.assume(e1 != 0);
        uint256[] memory a = new uint256[](3);
        uint256[] memory b = new uint256[](3);
        b[1] = e1;

        vm.expectEmit(false, false, false, true);
        emit log_named_string("Error", CUSTOM_ERROR);
        vm.expectEmit(false, false, false, true);
        emit log("Error: a == b not satisfied [uint[]]");
        t._assertEq(a, b, CUSTOM_ERROR, EXPECT_FAIL);
    }

    function testFailFuzz_AssertEq_IntArrErr(int256 e1) public {
        vm.assume(e1 != 0);
        int256[] memory a = new int256[](3);
        int256[] memory b = new int256[](3);
        b[1] = e1;

        vm.expectEmit(false, false, false, true);
        emit log_named_string("Error", CUSTOM_ERROR);
        vm.expectEmit(false, false, false, true);
        emit log("Error: a == b not satisfied [int[]]");
        t._assertEq(a, b, CUSTOM_ERROR, EXPECT_FAIL);
    }

    function testFailFuzz_AssertEq_AddressArrErr(address e1) public {
        vm.assume(e1 != address(0));
        address[] memory a = new address[](3);
        address[] memory b = new address[](3);
        b[1] = e1;

        vm.expectEmit(false, false, false, true);
        emit log_named_string("Error", CUSTOM_ERROR);
        vm.expectEmit(false, false, false, true);
        emit log("Error: a == b not satisfied [address[]]");
        t._assertEq(a, b, CUSTOM_ERROR, EXPECT_FAIL);
    }

    function testFailFuzz_AssertEq_UintArrLen(uint256 lenA, uint256 lenB) public {
        vm.assume(lenA != lenB);
        vm.assume(lenA <= 10000);
        vm.assume(lenB <= 10000);
        uint256[] memory a = new uint256[](lenA);
        uint256[] memory b = new uint256[](lenB);

        vm.expectEmit(false, false, false, true);
        emit log("Error: a == b not satisfied [uint[]]");
        t._assertEq(a, b, EXPECT_FAIL);
    }

    function testFailFuzz_AssertEq_IntArrLen(uint256 lenA, uint256 lenB) public {
        vm.assume(lenA != lenB);
        vm.assume(lenA <= 10000);
        vm.assume(lenB <= 10000);
        int256[] memory a = new int256[](lenA);
        int256[] memory b = new int256[](lenB);

        vm.expectEmit(false, false, false, true);
        emit log("Error: a == b not satisfied [int[]]");
        t._assertEq(a, b, EXPECT_FAIL);
    }

    function testFailFuzz_AssertEq_AddressArrLen(uint256 lenA, uint256 lenB) public {
        vm.assume(lenA != lenB);
        vm.assume(lenA <= 10000);
        vm.assume(lenB <= 10000);
        address[] memory a = new address[](lenA);
        address[] memory b = new address[](lenB);

        vm.expectEmit(false, false, false, true);
        emit log("Error: a == b not satisfied [address[]]");
        t._assertEq(a, b, EXPECT_FAIL);
    }

    function testFailFuzz_AssertEq_UintArrErr_Len(uint256 lenA, uint256 lenB) public {
        vm.assume(lenA != lenB);
        vm.assume(lenA <= 10000);
        vm.assume(lenB <= 10000);
        uint256[] memory a = new uint256[](lenA);
        uint256[] memory b = new uint256[](lenB);

        vm.expectEmit(false, false, false, true);
        emit log_named_string("Error", CUSTOM_ERROR);
        vm.expectEmit(false, false, false, true);
        emit log("Error: a == b not satisfied [uint[]]");
        t._assertEq(a, b, CUSTOM_ERROR, EXPECT_FAIL);
    }

    function testFailFuzz_AssertEq_IntArrErr_Len(uint256 lenA, uint256 lenB) public {
        vm.assume(lenA != lenB);
        vm.assume(lenA <= 10000);
        vm.assume(lenB <= 10000);
        int256[] memory a = new int256[](lenA);
        int256[] memory b = new int256[](lenB);

        vm.expectEmit(false, false, false, true);
        emit log_named_string("Error", CUSTOM_ERROR);
        vm.expectEmit(false, false, false, true);
        emit log("Error: a == b not satisfied [int[]]");
        t._assertEq(a, b, CUSTOM_ERROR, EXPECT_FAIL);
    }

    function testFailFuzz_AssertEq_AddressArrErr_Len(uint256 lenA, uint256 lenB) public {
        vm.assume(lenA != lenB);
        vm.assume(lenA <= 10000);
        vm.assume(lenB <= 10000);
        address[] memory a = new address[](lenA);
        address[] memory b = new address[](lenB);

        vm.expectEmit(false, false, false, true);
        emit log_named_string("Error", CUSTOM_ERROR);
        vm.expectEmit(false, false, false, true);
        emit log("Error: a == b not satisfied [address[]]");
        t._assertEq(a, b, CUSTOM_ERROR, EXPECT_FAIL);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    ASSERT_EQ(UINT)
    //////////////////////////////////////////////////////////////////////////*/

    function test_AssertEqUint() public {
        assertEqUint(uint8(1), uint128(1));
        assertEqUint(uint64(2), uint64(2));
    }

    function testFail_AssertEqUint() public {
        assertEqUint(uint64(1), uint96(2));
        assertEqUint(uint160(3), uint160(4));
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    APPROX_EQ_ABS(UINT)
    //////////////////////////////////////////////////////////////////////////*/

    function testFuzz_AssertApproxEqAbs_Uint(uint256 a, uint256 b, uint256 maxDelta) external {
        vm.assume(stdMath.delta(a, b) <= maxDelta);

        t._assertApproxEqAbs(a, b, maxDelta, EXPECT);
    }

    function testFuzz_AssertApproxEqAbs_Uint_Fail(uint256 a, uint256 b, uint256 maxDelta) external {
        vm.assume(stdMath.delta(a, b) > maxDelta);

        vm.expectEmit(false, false, false, true);
        emit log("Error: a ~= b not satisfied [uint]");
        t._assertApproxEqAbs(a, b, maxDelta, EXPECT_FAIL);
    }

    function testFuzz_AssertApproxEqAbs_UintErr(uint256 a, uint256 b, uint256 maxDelta) external {
        vm.assume(stdMath.delta(a, b) <= maxDelta);

        t._assertApproxEqAbs(a, b, maxDelta, CUSTOM_ERROR, EXPECT);
    }

    function testFuzz_AssertApproxEqAbs_UintErr_Fail(uint256 a, uint256 b, uint256 maxDelta) external {
        vm.assume(stdMath.delta(a, b) > maxDelta);

        vm.expectEmit(false, false, false, true);
        emit log_named_string("Error", CUSTOM_ERROR);
        t._assertApproxEqAbs(a, b, maxDelta, CUSTOM_ERROR, EXPECT_FAIL);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    APPROX_EQ_ABS_DECIMAL(UINT)
    //////////////////////////////////////////////////////////////////////////*/

    function testFuzz_AssertApproxEqAbsDecimal_Uint(uint256 a, uint256 b, uint256 maxDelta, uint256 decimals)
        external
    {
        vm.assume(stdMath.delta(a, b) <= maxDelta);

        t._assertApproxEqAbsDecimal(a, b, maxDelta, decimals, EXPECT);
    }

    function testFuzz_AssertApproxEqAbsDecimal_Uint_Fail(uint256 a, uint256 b, uint256 maxDelta, uint256 decimals)
        external
    {
        vm.assume(stdMath.delta(a, b) > maxDelta);

        vm.expectEmit(false, false, false, true);
        emit log("Error: a ~= b not satisfied [uint]");
        t._assertApproxEqAbsDecimal(a, b, maxDelta, decimals, EXPECT_FAIL);
    }

    function testFuzz_AssertApproxEqAbsDecimal_UintErr(uint256 a, uint256 b, uint256 maxDelta, uint256 decimals)
        external
    {
        vm.assume(stdMath.delta(a, b) <= maxDelta);

        t._assertApproxEqAbsDecimal(a, b, maxDelta, decimals, CUSTOM_ERROR, EXPECT);
    }

    function testFuzz_AssertApproxEqAbsDecimal_UintErr_Fail(uint256 a, uint256 b, uint256 maxDelta, uint256 decimals)
        external
    {
        vm.assume(stdMath.delta(a, b) > maxDelta);

        vm.expectEmit(false, false, false, true);
        emit log_named_string("Error", CUSTOM_ERROR);
        t._assertApproxEqAbsDecimal(a, b, maxDelta, decimals, CUSTOM_ERROR, EXPECT_FAIL);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    APPROX_EQ_ABS(INT)
    //////////////////////////////////////////////////////////////////////////*/

    function testFuzz_AssertApproxEqAbs_Int(int256 a, int256 b, uint256 maxDelta) external {
        vm.assume(stdMath.delta(a, b) <= maxDelta);

        t._assertApproxEqAbs(a, b, maxDelta, EXPECT);
    }

    function testFuzz_AssertApproxEqAbs_Int_Fail(int256 a, int256 b, uint256 maxDelta) external {
        vm.assume(stdMath.delta(a, b) > maxDelta);

        vm.expectEmit(false, false, false, true);
        emit log("Error: a ~= b not satisfied [int]");
        t._assertApproxEqAbs(a, b, maxDelta, EXPECT_FAIL);
    }

    function testFuzz_AssertApproxEqAbs_IntErr(int256 a, int256 b, uint256 maxDelta) external {
        vm.assume(stdMath.delta(a, b) <= maxDelta);

        t._assertApproxEqAbs(a, b, maxDelta, CUSTOM_ERROR, EXPECT);
    }

    function testFuzz_AssertApproxEqAbs_IntErr_Fail(int256 a, int256 b, uint256 maxDelta) external {
        vm.assume(stdMath.delta(a, b) > maxDelta);

        vm.expectEmit(false, false, false, true);
        emit log_named_string("Error", CUSTOM_ERROR);
        t._assertApproxEqAbs(a, b, maxDelta, CUSTOM_ERROR, EXPECT_FAIL);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    APPROX_EQ_ABS_DECIMAL(INT)
    //////////////////////////////////////////////////////////////////////////*/

    function testFuzz_AssertApproxEqAbsDecimal_Int(int256 a, int256 b, uint256 maxDelta, uint256 decimals) external {
        vm.assume(stdMath.delta(a, b) <= maxDelta);

        t._assertApproxEqAbsDecimal(a, b, maxDelta, decimals, EXPECT);
    }

    function testFuzz_AssertApproxEqAbsDecimal_Int_Fail(int256 a, int256 b, uint256 maxDelta, uint256 decimals) external {
        vm.assume(stdMath.delta(a, b) > maxDelta);

        vm.expectEmit(false, false, false, true);
        emit log("Error: a ~= b not satisfied [int]");
        t._assertApproxEqAbsDecimal(a, b, maxDelta, decimals, EXPECT_FAIL);
    }

    function testFuzz_AssertApproxEqAbsDecimal_IntErr(int256 a, int256 b, uint256 maxDelta, uint256 decimals)
        external
    {
        vm.assume(stdMath.delta(a, b) <= maxDelta);

        t._assertApproxEqAbsDecimal(a, b, maxDelta, decimals, CUSTOM_ERROR, EXPECT);
    }

    function testFuzz_AssertApproxEqAbsDecimal_IntErr_Fail(int256 a, int256 b, uint256 maxDelta, uint256 decimals)
        external
    {
        vm.assume(stdMath.delta(a, b) > maxDelta);

        vm.expectEmit(false, false, false, true);
        emit log_named_string("Error", CUSTOM_ERROR);
        t._assertApproxEqAbsDecimal(a, b, maxDelta, decimals, CUSTOM_ERROR, EXPECT_FAIL);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    APPROX_EQ_REL(UINT)
    //////////////////////////////////////////////////////////////////////////*/

    function testFuzz_AssertApproxEqRel_Uint(uint256 a, uint256 b, uint256 maxPercentDelta) external {
        vm.assume(a < type(uint128).max && b < type(uint128).max && b != 0);
        vm.assume(stdMath.percentDelta(a, b) <= maxPercentDelta);

        t._assertApproxEqRel(a, b, maxPercentDelta, EXPECT);
    }

    function testFailFuzz_AssertApproxEqRel_Uint(uint256 a, uint256 b, uint256 maxPercentDelta) external {
        vm.assume(a < type(uint128).max && b < type(uint128).max && b != 0);
        vm.assume(stdMath.percentDelta(a, b) > maxPercentDelta);

        vm.expectEmit(false, false, false, true);
        emit log("Error: a ~= b not satisfied [uint]");
        t._assertApproxEqRel(a, b, maxPercentDelta, EXPECT_FAIL);
    }

    function testFuzz_AssertApproxEqRel_UintErr(uint256 a, uint256 b, uint256 maxPercentDelta) external {
        vm.assume(a < type(uint128).max && b < type(uint128).max && b != 0);
        vm.assume(stdMath.percentDelta(a, b) <= maxPercentDelta);

        t._assertApproxEqRel(a, b, maxPercentDelta, CUSTOM_ERROR, EXPECT);
    }

    function testFailFuzz_AssertApproxEqRel_UintErr(uint256 a, uint256 b, uint256 maxPercentDelta) external {
        vm.assume(a < type(uint128).max && b < type(uint128).max && b != 0);
        vm.assume(stdMath.percentDelta(a, b) > maxPercentDelta);

        vm.expectEmit(false, false, false, true);
        emit log_named_string("Error", CUSTOM_ERROR);
        t._assertApproxEqRel(a, b, maxPercentDelta, CUSTOM_ERROR, EXPECT_FAIL);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    APPROX_EQ_REL_DECIMAL(UINT)
    //////////////////////////////////////////////////////////////////////////*/

    function testFuzz_AssertApproxEqRelDecimal_Uint(uint256 a, uint256 b, uint256 maxPercentDelta, uint256 decimals)
        external
    {
        vm.assume(a < type(uint128).max && b < type(uint128).max && b != 0);
        vm.assume(stdMath.percentDelta(a, b) <= maxPercentDelta);

        t._assertApproxEqRelDecimal(a, b, maxPercentDelta, decimals, EXPECT);
    }

    function testFailFuzz_AssertApproxEqRelDecimal_Uint(uint256 a, uint256 b, uint256 maxPercentDelta, uint256 decimals)
        external
    {
        vm.assume(a < type(uint128).max && b < type(uint128).max && b != 0);
        vm.assume(stdMath.percentDelta(a, b) > maxPercentDelta);

        vm.expectEmit(false, false, false, true);
        emit log("Error: a ~= b not satisfied [uint]");
        t._assertApproxEqRelDecimal(a, b, maxPercentDelta, decimals, EXPECT_FAIL);
    }

    function testFuzz_AssertApproxEqRelDecimal_UintErr(uint256 a, uint256 b, uint256 maxPercentDelta, uint256 decimals)
        external
    {
        vm.assume(a < type(uint128).max && b < type(uint128).max && b != 0);
        vm.assume(stdMath.percentDelta(a, b) <= maxPercentDelta);

        t._assertApproxEqRelDecimal(a, b, maxPercentDelta, decimals, CUSTOM_ERROR, EXPECT);
    }

    function testFailFuzz_AssertApproxEqRelDecimal_UintErr(uint256 a, uint256 b, uint256 maxPercentDelta, uint256 decimals)
        external
    {
        vm.assume(a < type(uint128).max && b < type(uint128).max && b != 0);
        vm.assume(stdMath.percentDelta(a, b) > maxPercentDelta);

        vm.expectEmit(false, false, false, true);
        emit log_named_string("Error", CUSTOM_ERROR);
        t._assertApproxEqRelDecimal(a, b, maxPercentDelta, decimals, CUSTOM_ERROR, EXPECT_FAIL);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    APPROX_EQ_REL(INT)
    //////////////////////////////////////////////////////////////////////////*/

    function testFuzz_AssertApproxEqRel_Int(int128 a, int128 b, uint128 maxPercentDelta) external {
        vm.assume(b != 0);
        vm.assume(stdMath.percentDelta(a, b) <= maxPercentDelta);

        t._assertApproxEqRel(a, b, maxPercentDelta, EXPECT);
    }

    function testFailFuzz_AssertApproxEqRel_Int(int128 a, int128 b, uint128 maxPercentDelta) external {
        vm.assume(b != 0);
        vm.assume(stdMath.percentDelta(a, b) > maxPercentDelta);

        vm.expectEmit(false, false, false, true);
        emit log("Error: a ~= b not satisfied [int]");
        t._assertApproxEqRel(a, b, maxPercentDelta, EXPECT_FAIL);
    }

    function testFuzz_AssertApproxEqRel_IntErr(int128 a, int128 b, uint128 maxPercentDelta) external {
        vm.assume(b != 0);
        vm.assume(stdMath.percentDelta(a, b) <= maxPercentDelta);

        t._assertApproxEqRel(a, b, maxPercentDelta, CUSTOM_ERROR, EXPECT);
    }

    function testFailFuzz_AssertApproxEqRel_IntErr(int128 a, int128 b, uint128 maxPercentDelta) external {
        vm.assume(b != 0);
        vm.assume(stdMath.percentDelta(a, b) > maxPercentDelta);

        vm.expectEmit(false, false, false, true);
        emit log_named_string("Error", CUSTOM_ERROR);
        t._assertApproxEqRel(a, b, maxPercentDelta, CUSTOM_ERROR, EXPECT_FAIL);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    APPROX_EQ_REL_DECIMAL(INT)
    //////////////////////////////////////////////////////////////////////////*/

    function testFuzz_AssertApproxEqRelDecimal_Int(int128 a, int128 b, uint128 maxPercentDelta, uint128 decimals)
        external
    {
        vm.assume(b != 0);
        vm.assume(stdMath.percentDelta(a, b) <= maxPercentDelta);

        t._assertApproxEqRelDecimal(a, b, maxPercentDelta, decimals, EXPECT);
    }

    function testFailFuzz_AssertApproxEqRelDecimal_Int(int128 a, int128 b, uint128 maxPercentDelta, uint128 decimals)
        external
    {
        vm.assume(b != 0);
        vm.assume(stdMath.percentDelta(a, b) > maxPercentDelta);

        vm.expectEmit(false, false, false, true);
        emit log("Error: a ~= b not satisfied [int]");
        t._assertApproxEqRelDecimal(a, b, maxPercentDelta, decimals, EXPECT_FAIL);
    }

    function testFuzz_AssertApproxEqRelDecimal_IntErr(int128 a, int128 b, uint128 maxPercentDelta, uint128 decimals)
        external
    {
        vm.assume(b != 0);
        vm.assume(stdMath.percentDelta(a, b) <= maxPercentDelta);

        t._assertApproxEqRelDecimal(a, b, maxPercentDelta, decimals, CUSTOM_ERROR, EXPECT);
    }

    function testFailFuzz_AssertApproxEqRelDecimal_IntErr(int128 a, int128 b, uint128 maxPercentDelta, uint128 decimals)
        external
    {
        vm.assume(b != 0);
        vm.assume(stdMath.percentDelta(a, b) > maxPercentDelta);

        vm.expectEmit(false, false, false, true);
        emit log_named_string("Error", CUSTOM_ERROR);
        t._assertApproxEqRelDecimal(a, b, maxPercentDelta, decimals, CUSTOM_ERROR, EXPECT_FAIL);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    ASSERT_EQ_CALL
    //////////////////////////////////////////////////////////////////////////*/

    function testFuzz_AssertEqCall_Return(
        bytes memory callDataA,
        bytes memory callDataB,
        bytes memory returnData,
        bool strictRevertData
    ) external {
        address targetA = address(new TestMockCall(returnData, SHOULD_RETURN));
        address targetB = address(new TestMockCall(returnData, SHOULD_RETURN));

        t._assertEqCall(targetA, callDataA, targetB, callDataB, strictRevertData, EXPECT);
    }

    function testFailFuzz_AssertEqCall_Return(
        bytes memory callDataA,
        bytes memory callDataB,
        bytes memory returnDataA,
        bytes memory returnDataB,
        bool strictRevertData
    ) external {
        vm.assume(keccak256(returnDataA) != keccak256(returnDataB));

        address targetA = address(new TestMockCall(returnDataA, SHOULD_RETURN));
        address targetB = address(new TestMockCall(returnDataB, SHOULD_RETURN));

        vm.expectEmit(true, true, true, true);
        emit log_named_string("Error", "Call return data does not match");
        t._assertEqCall(targetA, callDataA, targetB, callDataB, strictRevertData, EXPECT_FAIL);
    }

    function testFuzz_AssertEqCall_Revert(
        bytes memory callDataA,
        bytes memory callDataB,
        bytes memory revertDataA,
        bytes memory revertDataB
    ) external {
        address targetA = address(new TestMockCall(revertDataA, SHOULD_REVERT));
        address targetB = address(new TestMockCall(revertDataB, SHOULD_REVERT));

        t._assertEqCall(targetA, callDataA, targetB, callDataB, NON_STRICT_REVERT_DATA, EXPECT);
    }

    function testFailFuzz_AssertEqCall_Revert(
        bytes memory callDataA,
        bytes memory callDataB,
        bytes memory revertDataA,
        bytes memory revertDataB
    ) external {
        vm.assume(keccak256(revertDataA) != keccak256(revertDataB));

        address targetA = address(new TestMockCall(revertDataA, SHOULD_REVERT));
        address targetB = address(new TestMockCall(revertDataB, SHOULD_REVERT));

        vm.expectEmit(true, true, true, true);
        emit log_named_string("Error", "Call revert data does not match");
        t._assertEqCall(targetA, callDataA, targetB, callDataB, STRICT_REVERT_DATA, EXPECT_FAIL);
    }

    function testFailFuzz_AssertEqCall(
        bytes memory callDataA,
        bytes memory callDataB,
        bytes memory returnDataA,
        bytes memory returnDataB,
        bool strictRevertData
    ) external {
        address targetA = address(new TestMockCall(returnDataA, SHOULD_RETURN));
        address targetB = address(new TestMockCall(returnDataB, SHOULD_REVERT));

        vm.expectEmit(true, true, true, true);
        emit log_named_bytes("  Left call return data", returnDataA);
        vm.expectEmit(true, true, true, true);
        emit log_named_bytes(" Right call revert data", returnDataB);
        t._assertEqCall(targetA, callDataA, targetB, callDataB, strictRevertData, EXPECT_FAIL);

        vm.expectEmit(true, true, true, true);
        emit log_named_bytes("  Left call revert data", returnDataB);
        vm.expectEmit(true, true, true, true);
        emit log_named_bytes(" Right call return data", returnDataA);
        t._assertEqCall(targetB, callDataB, targetA, callDataA, strictRevertData, EXPECT_FAIL);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                ASSERT_NOT_EQ(BYTES)
    //////////////////////////////////////////////////////////////////////////*/

    function testFuzz_AssertNotEq_Bytes(bytes32 a, bytes32 b) external {
        vm.assume(a != b);
        t._assertNotEq(a, b, EXPECT);
    }

    function testFailFuzz_AssertNotEq_Bytes(bytes32 a) external {
        vm.expectEmit(false, false, false, true);
        emit log("Error: a != b not satisfied [bytes32]");
        t._assertNotEq(a, a, EXPECT_FAIL);
    }

    function testFuzz_AssertNotEq_BytesErr(bytes32 a, bytes32 b) external {
        vm.assume(a != b);
        t._assertNotEq(a, b, CUSTOM_ERROR, EXPECT);
    }

    function testFailFuzz_AsserNottEq_BytesErr(bytes32 a) external {
        vm.expectEmit(false, false, false, true);
        emit log_named_string("Error", CUSTOM_ERROR);
        t._assertNotEq(a, a, CUSTOM_ERROR, EXPECT_FAIL);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                ASSERT_NOT_EQ(UINT)
    //////////////////////////////////////////////////////////////////////////*/

    function test_AssertNotEqUint() public {
        assertNotEq(uint8(1), uint128(2));
        assertNotEq(uint64(3), uint64(4));
    }

    function testFail_AssertNotEqUint() public {
        assertNotEq(uint64(1), uint96(1));
        assertNotEq(uint160(2), uint160(2));
    }
}

contract TestTest is Test {
    modifier expectFailure(bool expectFail) {
        bool preState = vm.load(HEVM_ADDRESS, bytes32("failed")) != bytes32(0x00);
        _;
        bool postState = vm.load(HEVM_ADDRESS, bytes32("failed")) != bytes32(0x00);

        if (preState == true) {
            return;
        }

        if (expectFail) {
            require(postState == true, "expected failure not triggered");

            // unwind the expected failure
            vm.store(HEVM_ADDRESS, bytes32("failed"), bytes32(uint256(0x00)));
        } else {
            require(postState == false, "unexpected failure was triggered");
        }
    }

    function _fail(string memory err) external expectFailure(true) {
        fail(err);
    }

    function _assertFalse(bool data, bool expectFail) external expectFailure(expectFail) {
        assertFalse(data);
    }

    function _assertFalse(bool data, string memory err, bool expectFail) external expectFailure(expectFail) {
        assertFalse(data, err);
    }

    function _assertEq(bool a, bool b, bool expectFail) external expectFailure(expectFail) {
        assertEq(a, b);
    }

    function _assertEq(bool a, bool b, string memory err, bool expectFail) external expectFailure(expectFail) {
        assertEq(a, b, err);
    }

    function _assertEq(bytes memory a, bytes memory b, bool expectFail) external expectFailure(expectFail) {
        assertEq(a, b);
    }

    function _assertEq(bytes memory a, bytes memory b, string memory err, bool expectFail)
        external
        expectFailure(expectFail)
    {
        assertEq(a, b, err);
    }

    function _assertEq(uint256[] memory a, uint256[] memory b, bool expectFail) external expectFailure(expectFail) {
        assertEq(a, b);
    }

    function _assertEq(int256[] memory a, int256[] memory b, bool expectFail) external expectFailure(expectFail) {
        assertEq(a, b);
    }

    function _assertEq(address[] memory a, address[] memory b, bool expectFail) external expectFailure(expectFail) {
        assertEq(a, b);
    }

    function _assertEq(uint256[] memory a, uint256[] memory b, string memory err, bool expectFail)
        external
        expectFailure(expectFail)
    {
        assertEq(a, b, err);
    }

    function _assertEq(int256[] memory a, int256[] memory b, string memory err, bool expectFail)
        external
        expectFailure(expectFail)
    {
        assertEq(a, b, err);
    }

    function _assertEq(address[] memory a, address[] memory b, string memory err, bool expectFail)
        external
        expectFailure(expectFail)
    {
        assertEq(a, b, err);
    }

    function _assertNotEq(bytes32 a, bytes32 b, bool expectFail) external expectFailure(expectFail) {
        assertNotEq32(a, b);
    }

    function _assertNotEq(bytes32 a, bytes32 b, string memory err, bool expectFail)
        external
        expectFailure(expectFail)
    {
        assertNotEq32(a, b, err);
    }

    function _assertApproxEqAbs(uint256 a, uint256 b, uint256 maxDelta, bool expectFail)
        external
        expectFailure(expectFail)
    {
        assertApproxEqAbs(a, b, maxDelta);
    }

    function _assertApproxEqAbs(uint256 a, uint256 b, uint256 maxDelta, string memory err, bool expectFail)
        external
        expectFailure(expectFail)
    {
        assertApproxEqAbs(a, b, maxDelta, err);
    }

    function _assertApproxEqAbsDecimal(uint256 a, uint256 b, uint256 maxDelta, uint256 decimals, bool expectFail)
        external
        expectFailure(expectFail)
    {
        assertApproxEqAbsDecimal(a, b, maxDelta, decimals);
    }

    function _assertApproxEqAbsDecimal(
        uint256 a,
        uint256 b,
        uint256 maxDelta,
        uint256 decimals,
        string memory err,
        bool expectFail
    ) external expectFailure(expectFail) {
        assertApproxEqAbsDecimal(a, b, maxDelta, decimals, err);
    }

    function _assertApproxEqAbs(int256 a, int256 b, uint256 maxDelta, bool expectFail)
        external
        expectFailure(expectFail)
    {
        assertApproxEqAbs(a, b, maxDelta);
    }

    function _assertApproxEqAbs(int256 a, int256 b, uint256 maxDelta, string memory err, bool expectFail)
        external
        expectFailure(expectFail)
    {
        assertApproxEqAbs(a, b, maxDelta, err);
    }

    function _assertApproxEqAbsDecimal(int256 a, int256 b, uint256 maxDelta, uint256 decimals, bool expectFail)
        external
        expectFailure(expectFail)
    {
        assertApproxEqAbsDecimal(a, b, maxDelta, decimals);
    }

    function _assertApproxEqAbsDecimal(
        int256 a,
        int256 b,
        uint256 maxDelta,
        uint256 decimals,
        string memory err,
        bool expectFail
    ) external expectFailure(expectFail) {
        assertApproxEqAbsDecimal(a, b, maxDelta, decimals, err);
    }

    function _assertApproxEqRel(uint256 a, uint256 b, uint256 maxPercentDelta, bool expectFail)
        external
        expectFailure(expectFail)
    {
        assertApproxEqRel(a, b, maxPercentDelta);
    }

    function _assertApproxEqRel(uint256 a, uint256 b, uint256 maxPercentDelta, string memory err, bool expectFail)
        external
        expectFailure(expectFail)
    {
        assertApproxEqRel(a, b, maxPercentDelta, err);
    }

    function _assertApproxEqRelDecimal(uint256 a, uint256 b, uint256 maxPercentDelta, uint256 decimals, bool expectFail)
        external
        expectFailure(expectFail)
    {
        assertApproxEqRelDecimal(a, b, maxPercentDelta, decimals);
    }

    function _assertApproxEqRelDecimal(
        uint256 a,
        uint256 b,
        uint256 maxPercentDelta,
        uint256 decimals,
        string memory err,
        bool expectFail
    ) external expectFailure(expectFail) {
        assertApproxEqRelDecimal(a, b, maxPercentDelta, decimals, err);
    }

    function _assertApproxEqRel(int256 a, int256 b, uint256 maxPercentDelta, bool expectFail)
        external
        expectFailure(expectFail)
    {
        assertApproxEqRel(a, b, maxPercentDelta);
    }

    function _assertApproxEqRel(int256 a, int256 b, uint256 maxPercentDelta, string memory err, bool expectFail)
        external
        expectFailure(expectFail)
    {
        assertApproxEqRel(a, b, maxPercentDelta, err);
    }

    function _assertApproxEqRelDecimal(int256 a, int256 b, uint256 maxPercentDelta, uint256 decimals, bool expectFail)
        external
        expectFailure(expectFail)
    {
        assertApproxEqRelDecimal(a, b, maxPercentDelta, decimals);
    }

    function _assertApproxEqRelDecimal(
        int256 a,
        int256 b,
        uint256 maxPercentDelta,
        uint256 decimals,
        string memory err,
        bool expectFail
    ) external expectFailure(expectFail) {
        assertApproxEqRelDecimal(a, b, maxPercentDelta, decimals, err);
    }

    function _assertEqCall(
        address targetA,
        bytes memory callDataA,
        address targetB,
        bytes memory callDataB,
        bool strictRevertData,
        bool expectFail
    ) external expectFailure(expectFail) {
        assertEqCall(targetA, callDataA, targetB, callDataB, strictRevertData);
    }
}

contract TestMockCall {
    bytes returnData;
    bool shouldRevert;

    constructor(bytes memory returnData_, bool shouldRevert_) {
        returnData = returnData_;
        shouldRevert = shouldRevert_;
    }

    fallback() external payable {
        bytes memory returnData_ = returnData;

        if (shouldRevert) {
            assembly {
                revert(add(returnData_, 0x20), mload(returnData_))
            }
        } else {
            assembly {
                return(add(returnData_, 0x20), mload(returnData_))
            }
        }
    }
}
