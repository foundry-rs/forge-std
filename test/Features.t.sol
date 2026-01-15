// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.8.20 <0.9.0;

import {Test} from "../src/Test.sol";
import {
    forge,
    scenario,
    ScenarioBuilder,
    ScenarioResult,
    expect,
    Expectation,
    mock,
    MockSetup,
    gas,
    GasProfile,
    GasReport,
    trace,
    CallNode
} from "../src/Forge.sol";

import {ScenarioLib, ScenarioResultLib} from "../src/Scenario.sol";
import {ExpectLib} from "../src/Expect.sol";
import {MockLib} from "../src/Mock.sol";
import {GasLib, GasComparison} from "../src/Gas.sol";

/// @notice Simple token for testing
contract SimpleToken {
    mapping(address => uint256) public balanceOf;
    uint256 public totalSupply;

    function mint(address to, uint256 amount) external {
        balanceOf[to] += amount;
        totalSupply += amount;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }
}

contract FeaturesTest is Test {
    using ScenarioLib for ScenarioBuilder;
    using ScenarioResultLib for ScenarioResult;
    using ExpectLib for Expectation;
    using MockLib for MockSetup;
    using GasLib for GasProfile;
    using GasLib for GasReport;

    SimpleToken token;

    function setUp() public {
        token = new SimpleToken();
    }

    // ═══════════════════════════════════════════════════════════════════════
    // SCENARIO TESTS
    // ═══════════════════════════════════════════════════════════════════════

    function test_ScenarioBuilder() public {
        // Build a test scenario with named actors
        ScenarioResult memory s = scenario.create("Token Transfer Test")
            .withActor("alice", 10 ether)
            .withActor("bob", 5 ether)
            .atBlock(1000)
            .build();

        // Verify actors were created
        assertNotEq(s.getActorAddress("alice"), address(0));
        assertNotEq(s.getActorAddress("bob"), address(0));
        assertNotEq(s.getActorAddress("alice"), s.getActorAddress("bob"));

        // Act as alice
        s.asActor("alice");
        // Note: msg.sender check doesn't work inside the same call frame
        // The prank affects subsequent external calls
        s.stopActor();
    }

    function test_ScenarioTimeManipulation() public {
        ScenarioResult memory s = scenario.create("Time Test")
            .atTimestamp(1000)
            .build();

        assertEq(block.timestamp, 1000);

        s.skipTime(100);
        assertEq(block.timestamp, 1100);

        s.rewindTime(50);
        assertEq(block.timestamp, 1050);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // GAS PROFILING TESTS
    // ═══════════════════════════════════════════════════════════════════════

    function test_GasProfiling() public {
        token.mint(address(this), 1000);

        // Profile a transfer
        GasReport memory r = gas.measure(
            "token transfer",
            address(token),
            abi.encodeCall(token.transfer, (address(0xBEEF), 100))
        );

        assertTrue(r.success);
        assertGt(r.gasUsed, 0);

        // Log the report
        GasLib.log(r);
    }

    function test_GasComparison() public {
        token.mint(address(this), 2000);

        // Measure two different operations
        uint256 snapshot1 = vm.snapshotState();

        GasReport memory r1 = gas.measure(
            "small transfer",
            address(token),
            abi.encodeCall(token.transfer, (address(0xBEEF), 1))
        );

        vm.revertToState(snapshot1);
        token.mint(address(this), 2000);

        GasReport memory r2 = gas.measure(
            "large transfer",
            address(token),
            abi.encodeCall(token.transfer, (address(0xBEEF), 1000))
        );

        // Compare them
        GasComparison memory comparison = gas.compare(r1, r2);

        // Both should use similar gas (ERC20 transfer cost is constant)
        assertLt(
            comparison.difference > 0 ? uint256(comparison.difference) : uint256(-comparison.difference),
            1000 // Should be within 1000 gas
        );
    }

    // ═══════════════════════════════════════════════════════════════════════
    // MOCK TESTS
    // ═══════════════════════════════════════════════════════════════════════

    function test_MockBasic() public {
        address mockToken = address(0x1234);

        // Create a mock that returns a specific balance
        MockSetup memory m = mock.create(mockToken)
            .whenCalled(bytes4(keccak256("balanceOf(address)")))
            .withAnyArgs()
            .returnsUint(1000 ether);

        m.setup();

        // Call the mock
        (bool success, bytes memory data) = mockToken.staticcall(
            abi.encodeWithSignature("balanceOf(address)", address(this))
        );

        assertTrue(success);
        assertEq(abi.decode(data, (uint256)), 1000 ether);
    }

    function test_MockRevert() public {
        address mockToken = address(0x5678);

        // Create a mock that reverts
        MockSetup memory m = mock.create(mockToken)
            .whenCalled(bytes4(keccak256("transfer(address,uint256)")))
            .withAnyArgs()
            .reverts();

        m.setup();

        // Call should revert
        (bool success,) = mockToken.call(
            abi.encodeWithSignature("transfer(address,uint256)", address(0xBEEF), 100)
        );

        assertFalse(success);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // TRACE TESTS
    // ═══════════════════════════════════════════════════════════════════════

    function test_TraceCapture() public {
        token.mint(address(this), 1000);

        // Capture a call
        (CallNode memory node, bool success, bytes memory returnData) = trace.captureCall(
            address(token),
            abi.encodeCall(token.transfer, (address(0xBEEF), 100))
        );

        assertTrue(success);
        assertTrue(abi.decode(returnData, (bool)));

        assertEq(node.to, address(token));
        assertEq(bytes32(node.selector), bytes32(token.transfer.selector));
        assertGt(node.gasUsed, 0);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // EXPLICIT ASSERTION TESTS ()
    // ═══════════════════════════════════════════════════════════════════════

    function test_Assertions() public pure {
        assertEq(uint256(1), uint256(1));
        assertEq(int256(-1), int256(-1));
        assertEq(address(0x1), address(0x1));
        assertEq(bytes32(uint256(1)), bytes32(uint256(1)));
        assertEq(true, true);
        assertEq(string("hello"), string("hello"));

        assertNotEq(uint256(1), uint256(2));
        assertNotEq(address(0x1), address(0x2));

        assertGt(uint256(2), uint256(1));
        assertGe(uint256(2), uint256(2));
        assertLt(uint256(1), uint256(2));
        assertLe(uint256(2), uint256(2));
    }
}
