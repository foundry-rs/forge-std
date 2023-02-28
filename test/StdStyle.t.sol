// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "../src/Test.sol";

contract StdStyleTest is Test {
    function testStyleColor() public view {
        console2.log(StdStyle.red("StdStyle.red String Test"));
        console2.log(StdStyle.red(uint256(10e18)));
        console2.log(StdStyle.red(int256(-10e18)));
        console2.log(StdStyle.red(true));
        console2.log(StdStyle.red(address(0)));
        console2.log(StdStyle.green("StdStyle.green String Test"));
        console2.log(StdStyle.green(uint256(10e18)));
        console2.log(StdStyle.green(int256(-10e18)));
        console2.log(StdStyle.green(true));
        console2.log(StdStyle.green(address(0)));
        console2.log(StdStyle.yellow("StdStyle.yellow String Test"));
        console2.log(StdStyle.yellow(uint256(10e18)));
        console2.log(StdStyle.yellow(int256(-10e18)));
        console2.log(StdStyle.yellow(true));
        console2.log(StdStyle.yellow(address(0)));
        console2.log(StdStyle.blue("StdStyle.blue String Test"));
        console2.log(StdStyle.blue(uint256(10e18)));
        console2.log(StdStyle.blue(int256(-10e18)));
        console2.log(StdStyle.blue(true));
        console2.log(StdStyle.blue(address(0)));
        console2.log(StdStyle.magenta("StdStyle.magenta String Test"));
        console2.log(StdStyle.magenta(uint256(10e18)));
        console2.log(StdStyle.magenta(int256(-10e18)));
        console2.log(StdStyle.magenta(true));
        console2.log(StdStyle.magenta(address(0)));
        console2.log(StdStyle.cyan("StdStyle.cyan String Test"));
        console2.log(StdStyle.cyan(uint256(10e18)));
        console2.log(StdStyle.cyan(int256(-10e18)));
        console2.log(StdStyle.cyan(true));
        console2.log(StdStyle.cyan(address(0)));
    }

    function testStyleFontWeight() public view {
        console2.log(StdStyle.bold("StdStyle.bold String Test"));
        console2.log(StdStyle.bold(uint256(10e18)));
        console2.log(StdStyle.bold(int256(-10e18)));
        console2.log(StdStyle.bold(address(0)));
        console2.log(StdStyle.bold(true));
        console2.log(StdStyle.dim("StdStyle.dim String Test"));
        console2.log(StdStyle.dim(uint256(10e18)));
        console2.log(StdStyle.dim(int256(-10e18)));
        console2.log(StdStyle.dim(address(0)));
        console2.log(StdStyle.dim(true));
        console2.log(StdStyle.italic("StdStyle.italic String Test"));
        console2.log(StdStyle.italic(uint256(10e18)));
        console2.log(StdStyle.italic(int256(-10e18)));
        console2.log(StdStyle.italic(address(0)));
        console2.log(StdStyle.italic(true));
        console2.log(StdStyle.underline("StdStyle.underline String Test"));
        console2.log(StdStyle.underline(uint256(10e18)));
        console2.log(StdStyle.underline(int256(-10e18)));
        console2.log(StdStyle.underline(address(0)));
        console2.log(StdStyle.underline(true));
        console2.log(StdStyle.inverse("StdStyle.inverse String Test"));
        console2.log(StdStyle.inverse(uint256(10e18)));
        console2.log(StdStyle.inverse(int256(-10e18)));
        console2.log(StdStyle.inverse(address(0)));
        console2.log(StdStyle.inverse(true));
    }

    function testStyleCombined() public view {
        console2.log(StdStyle.red(StdStyle.bold("Red Bold String Test")));
        console2.log(StdStyle.green(StdStyle.dim(uint256(10e18))));
        console2.log(StdStyle.yellow(StdStyle.italic(int256(-10e18))));
        console2.log(StdStyle.blue(StdStyle.underline(address(0))));
        console2.log(StdStyle.magenta(StdStyle.inverse(true)));
    }

    function testStyleCustom() public view {
        console2.log(h1("Custom Style 1"));
        console2.log(h2("Custom Style 2"));
    }

    function h1(string memory a) private pure returns (string memory) {
        return StdStyle.cyan(StdStyle.inverse(StdStyle.bold(a)));
    }

    function h2(string memory a) private pure returns (string memory) {
        return StdStyle.magenta(StdStyle.bold(StdStyle.underline(a)));
    }
}
