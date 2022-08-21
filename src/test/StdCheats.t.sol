// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "../Test.sol";

contract StdCheatsTest is Test {
    Bar test;

    function setUp() public {
        test = new Bar();
    }

    function testSkip() public {
        vm.warp(100);
        skip(25);
        assertEq(block.timestamp, 125);
    }

    function testRewind() public {
        vm.warp(100);
        rewind(25);
        assertEq(block.timestamp, 75);
    }

    function testHoax() public {
        hoax(address(1337));
        test.bar{value: 100}(address(1337));
    }

    function testHoaxOrigin() public {
        hoax(address(1337), address(1337));
        test.origin{value: 100}(address(1337));
    }

    function testHoaxDifferentAddresses() public {
        hoax(address(1337), address(7331));
        test.origin{value: 100}(address(1337), address(7331));
    }

    function testStartHoax() public {
        startHoax(address(1337));
        test.bar{value: 100}(address(1337));
        test.bar{value: 100}(address(1337));
        vm.stopPrank();
        test.bar(address(this));
    }

    function testStartHoaxOrigin() public {
        startHoax(address(1337), address(1337));
        test.origin{value: 100}(address(1337));
        test.origin{value: 100}(address(1337));
        vm.stopPrank();
        test.bar(address(this));
    }

    function testChangePrank() public {
        vm.startPrank(address(1337));
        test.bar(address(1337));
        changePrank(address(0xdead));
        test.bar(address(0xdead));
        changePrank(address(1337));
        test.bar(address(1337));
        vm.stopPrank();
    }

    function testDeal() public {
        deal(address(this), 1 ether);
        assertEq(address(this).balance, 1 ether);
    }

    function testDealToken() public {
        Bar barToken = new Bar();
        address bar = address(barToken);
        deal(bar, address(this), 10000e18);
        assertEq(barToken.balanceOf(address(this)), 10000e18);
    }

    function testDealTokenAdjustTS() public {
        Bar barToken = new Bar();
        address bar = address(barToken);
        deal(bar, address(this), 10000e18, true);
        assertEq(barToken.balanceOf(address(this)), 10000e18);
        assertEq(barToken.totalSupply(), 20000e18);
        deal(bar, address(this), 0, true);
        assertEq(barToken.balanceOf(address(this)), 0);
        assertEq(barToken.totalSupply(), 10000e18);
    }

    function testBound() public {
        assertEq(bound(5, 0, 4), 0);
        assertEq(bound(0, 69, 69), 69);
        assertEq(bound(0, 68, 69), 68);
        assertEq(bound(10, 150, 190), 160);
        assertEq(bound(300, 2800, 3200), 3100);
        assertEq(bound(9999, 1337, 6666), 6006);
    }

    function testCannotBoundMaxLessThanMin() public {
        vm.expectRevert(bytes("Test bound(uint256,uint256,uint256): Max is less than min."));
        bound(5, 100, 10);
    }

    function testBound(
        uint256 num,
        uint256 min,
        uint256 max
    ) public {
        if (min > max) (min, max) = (max, min);

        uint256 bounded = bound(num, min, max);

        assertGe(bounded, min);
        assertLe(bounded, max);
    }

    function testBoundUint256Max() public {
        assertEq(bound(0, type(uint256).max - 1, type(uint256).max), type(uint256).max - 1);
        assertEq(bound(1, type(uint256).max - 1, type(uint256).max), type(uint256).max);
    }

    function testCannotBoundMaxLessThanMin(
        uint256 num,
        uint256 min,
        uint256 max
    ) public {
        vm.assume(min > max);
        vm.expectRevert(bytes("Test bound(uint256,uint256,uint256): Max is less than min."));
        bound(num, min, max);
    }

    function testDeployCode() public {
        address deployed = deployCode("StdCheats.t.sol:StdCheatsTest", bytes(""));
        assertEq(string(getCode(deployed)), string(getCode(address(this))));
    }

    function testDeployCodeNoArgs() public {
        address deployed = deployCode("StdCheats.t.sol:StdCheatsTest");
        assertEq(string(getCode(deployed)), string(getCode(address(this))));
    }

    // We need that payable constructor in order to send ETH on construction
    constructor() payable {}

    function testDeployCodeVal() public {
        address deployed = deployCode("StdCheats.t.sol:StdCheatsTest", bytes(""), 1 ether);
        assertEq(string(getCode(deployed)), string(getCode(address(this))));
	assertEq(deployed.balance, 1 ether);
    }

    function testDeployCodeValNoArgs() public {
        address deployed = deployCode("StdCheats.t.sol:StdCheatsTest", 1 ether);
        assertEq(string(getCode(deployed)), string(getCode(address(this))));
	assertEq(deployed.balance, 1 ether);
    }

    // We need this so we can call "this.deployCode" rather than "deployCode" directly
    function deployCodeHelper(string memory what) external {
        deployCode(what);
    }

    function testDeployCodeFail() public {
        vm.expectRevert(bytes("Test deployCode(string): Deployment failed."));
        this.deployCodeHelper("StdCheats.t.sol:RevertingContract");
    }

    function getCode(address who) internal view returns (bytes memory o_code) {
        /// @solidity memory-safe-assembly
        assembly {
            // retrieve the size of the code, this needs assembly
            let size := extcodesize(who)
            // allocate output byte array - this could also be done without assembly
            // by using o_code = new bytes(size)
            o_code := mload(0x40)
            // new "memory end" including padding
            mstore(0x40, add(o_code, and(add(add(size, 0x20), 0x1f), not(0x1f))))
            // store length in memory
            mstore(o_code, size)
            // actually retrieve the code, this needs assembly
            extcodecopy(who, add(o_code, 0x20), 0, size)
        }
    }


    function testParseJsonTxDetail() public {
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/src/test/fixtures/broadcast.log.json");
        JsonParser parser = new JsonParser(path);
        parser.readJson();
        bytes32 data = parser.readBytes32(".transactions[0].hash");
        bytes memory transactionDetails = parser.parseRaw(".transactions[2].tx");
        rawEIP1559TransactionDetail memory rawTxDetail = abi.decode(transactionDetails, (rawEIP1559TransactionDetail));
        EIP1559TransactionDetail memory txDetail = rawToConvertedEIP1559Detail(rawTxDetail);
        assertEq(txDetail.from, 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
        assertEq(txDetail.to, 0x4e59b44847b379578588920cA78FbF26c0B4956C);
        assertEq(txDetail.data, hex'000000000000000000000000000000000000000000000000000000000000053960806040526000805460ff1916600190811782555534801561002057600080fd5b506103c5806100306000396000f3fe608060405234801561001057600080fd5b506004361061007d5760003560e01c8063371303c01161005b578063371303c0146100c3578063afe29f71146100cb578063ba414fa6146100de578063fa7626d41461010057600080fd5b80630d3a6aee146100825780631e91f8cb1461009e57806323e99187146100ac575b600080fd5b61008b60015481565b6040519081526020015b60405180910390f35b604051338152602001610095565b61008b6100ba36600461022e565b60009392505050565b61008b61010d565b61008b6100d9366004610316565b61012b565b6000546100f090610100900460ff1681565b6040519015158152602001610095565b6000546100f09060ff1681565b600060018060008282546101219190610345565b9250508190555090565b600080805b838110156101c357735fbdb2315678afecb367f032d93f642f64180aa363baf2f8686040518163ffffffff1660e01b8152600401602060405180830381865af4158015610181573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906101a5919061035d565b6101af9083610345565b9150806101bb81610376565b915050610130565b507f0b2e13ff20ac7b474198655583edf70dedd2c1dc980e329c4fbb2fc0748b796b60405161020a906020808252600490820152636865726560e01b604082015260600190565b60405180910390a192915050565b634e487b7160e01b600052604160045260246000fd5b60008060006060848603121561024357600080fd5b833592506020808501356001600160a01b038116811461026257600080fd5b9250604085013567ffffffffffffffff8082111561027f57600080fd5b818701915087601f83011261029357600080fd5b8135818111156102a5576102a5610218565b8060051b604051601f19603f830116810181811085821117156102ca576102ca610218565b60405291825284820192508381018501918a8311156102e857600080fd5b938501935b82851015610306578435845293850193928501926102ed565b8096505050505050509250925092565b60006020828403121561032857600080fd5b5035919050565b634e487b7160e01b600052601160045260246000fd5b600082198211156103585761035861032f565b500190565b60006020828403121561036f57600080fd5b5051919050565b6000600182016103885761038861032f565b506001019056fea26469706673582212206ec8dbffdf9df942b121e9668779a5a488c48a4d57bb7e7d14762554b1f9242864736f6c634300080e0033');
        assertEq(txDetail.nonce, 2);
        assertEq(txDetail.txType, 2);
        assertEq(txDetail.gas, 372708);
        assertEq(txDetail.value, 0);
    }
}

contract Bar {
    constructor() {
        /// `DEAL` STDCHEAT
        totalSupply = 10000e18;
        balanceOf[address(this)] = totalSupply;
    }

    /// `HOAX` STDCHEATS
    function bar(address expectedSender) public payable {
        require(msg.sender == expectedSender, "!prank");
    }
    function origin(address expectedSender) public payable {
        require(msg.sender == expectedSender, "!prank");
        require(tx.origin == expectedSender, "!prank");
    }
    function origin(address expectedSender, address expectedOrigin) public payable {
        require(msg.sender == expectedSender, "!prank");
        require(tx.origin == expectedOrigin, "!prank");
    }

    /// `DEAL` STDCHEAT
    mapping (address => uint256) public balanceOf;
    uint256 public totalSupply;
}

contract RevertingContract {
    constructor() {
        revert();
    }
}

