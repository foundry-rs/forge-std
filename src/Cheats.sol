// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "./Storage.sol";
import "./Vm.sol";

// Wrappers around Cheats to avoid footguns
contract Cheats {
    using stdStorage for StdStorage;

    StdStorage private stdstore;
    Vm private constant vm_cheats = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));


    // Skip forward or rewind time by the specified number of seconds
    function skip(uint256 time) internal virtual {
        vm_cheats.warp(block.timestamp + time);
    }

    function rewind(uint256 time) internal virtual {
        vm_cheats.warp(block.timestamp - time);
    }

    // Setup a prank from an address that has some ether
    function hoax(address who) internal virtual {
        vm_cheats.deal(who, 1 << 128);
        vm_cheats.prank(who);
    }

    function hoax(address who, uint256 give) internal virtual {
        vm_cheats.deal(who, give);
        vm_cheats.prank(who);
    }

    function hoax(address who, address origin) internal virtual {
        vm_cheats.deal(who, 1 << 128);
        vm_cheats.prank(who, origin);
    }

    function hoax(address who, address origin, uint256 give) internal virtual {
        vm_cheats.deal(who, give);
        vm_cheats.prank(who, origin);
    }

    // Start perpetual prank from an address that has some ether
    function startHoax(address who) internal virtual {
        vm_cheats.deal(who, 1 << 128);
        vm_cheats.startPrank(who);
    }

    function startHoax(address who, uint256 give) internal virtual {
        vm_cheats.deal(who, give);
        vm_cheats.startPrank(who);
    }

    // Start perpetual prank from an address that has some ether
    // tx.origin is set to the origin parameter
    function startHoax(address who, address origin) internal virtual {
        vm_cheats.deal(who, 1 << 128);
        vm_cheats.startPrank(who, origin);
    }

    function startHoax(address who, address origin, uint256 give) internal virtual {
        vm_cheats.deal(who, give);
        vm_cheats.startPrank(who, origin);
    }

    function changePrank(address who) internal virtual {
        vm_cheats.stopPrank();
        vm_cheats.startPrank(who);
    }

    // The same as Vm's `deal`
    // Use the alternative signature for ERC20 tokens
    function deal(address to, uint256 give) internal virtual {
        vm_cheats.deal(to, give);
    }

    // Set the balance of an account for any ERC20 token
    // Use the alternative signature to update `totalSupply`
    function deal(address token, address to, uint256 give) internal virtual {
        deal(token, to, give, false);
    }

    function deal(address token, address to, uint256 give, bool adjust) internal virtual {
        // get current balance
        (, bytes memory balData) = token.call(abi.encodeWithSelector(0x70a08231, to));
        uint256 prevBal = abi.decode(balData, (uint256));

        // update balance
        stdstore
            .target(token)
            .sig(0x70a08231)
            .with_key(to)
            .checked_write(give);

        // update total supply
        if(adjust){
            (, bytes memory totSupData) = token.call(abi.encodeWithSelector(0x18160ddd));
            uint256 totSup = abi.decode(totSupData, (uint256));
            if(give < prevBal) {
                totSup -= (prevBal - give);
            } else {
                totSup += (give - prevBal);
            }
            stdstore
                .target(token)
                .sig(0x18160ddd)
                .checked_write(totSup);
        }
    }

    // Deploy a contract by fetching the contract bytecode from
    // the artifacts directory
    // e.g. `deployCode(code, abi.encode(arg1,arg2,arg3))`
    function deployCode(string memory what, bytes memory args)
        internal virtual
        returns (address addr)
    {
        bytes memory bytecode = abi.encodePacked(vm_cheats.getCode(what), args);
        /// @solidity memory-safe-assembly
        assembly {
            addr := create(0, add(bytecode, 0x20), mload(bytecode))
        }

        require(
            addr != address(0),
            "Test deployCode(string,bytes): Deployment failed."
        );
    }

    function deployCode(string memory what)
        internal virtual
        returns (address addr)
    {
        bytes memory bytecode = vm_cheats.getCode(what);
        /// @solidity memory-safe-assembly
        assembly {
            addr := create(0, add(bytecode, 0x20), mload(bytecode))
        }

        require(
            addr != address(0),
            "Test deployCode(string): Deployment failed."
        );
    }
}