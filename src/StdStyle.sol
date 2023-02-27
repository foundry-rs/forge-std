// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import {Vm} from "./Vm.sol";

library StdStyle {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    string constant RED = "\u001b[91m";
    string constant GREEN = "\u001b[92m";
    string constant YELLOW = "\u001b[93m";
    string constant BLUE = "\u001b[94m";
    string constant MAGENTA = "\u001b[95m";
    string constant CYAN = "\u001b[96m";
    string constant BOLD = "\u001b[1m";
    string constant DIM = "\u001b[2m";
    string constant ITALIC = "\u001b[3m";
    string constant UNDERLINE = "\u001b[4m";
    string constant REVERSE = "\u001b[7m";
    string constant RESET = "\u001b[0m";

    function red(string memory self) internal view returns (string memory) {
        return string.concat(RED, self, RESET);
    }

    function red(uint256 self) internal view returns (string memory) {
        return string.concat(RED, vm.toString(self), RESET);
    }

    function red(int256 self) internal view returns (string memory) {
        return string.concat(RED, vm.toString(self), RESET);
    }

    function red(address self) internal view returns (string memory) {
        return string.concat(RED, vm.toString(self), RESET);
    }

    function red(bool self) internal view returns (string memory) {
        return string.concat(RED, vm.toString(self), RESET);
    }

    function green(string memory self) internal view returns (string memory) {
        return string.concat(GREEN, self, RESET);
    }

    function green(uint256 self) internal view returns (string memory) {
        return string.concat(GREEN, vm.toString(self), RESET);
    }

    function green(int256 self) internal view returns (string memory) {
        return string.concat(GREEN, vm.toString(self), RESET);
    }

    function green(address self) internal view returns (string memory) {
        return string.concat(GREEN, vm.toString(self), RESET);
    }

    function green(bool self) internal view returns (string memory) {
        return string.concat(GREEN, vm.toString(self), RESET);
    }

    function yellow(string memory self) internal view returns (string memory) {
        return string.concat(YELLOW, self, RESET);
    }

    function yellow(uint256 self) internal view returns (string memory) {
        return string.concat(YELLOW, vm.toString(self), RESET);
    }

    function yellow(int256 self) internal view returns (string memory) {
        return string.concat(YELLOW, vm.toString(self), RESET);
    }

    function yellow(address self) internal view returns (string memory) {
        return string.concat(YELLOW, vm.toString(self), RESET);
    }

    function yellow(bool self) internal view returns (string memory) {
        return string.concat(YELLOW, vm.toString(self), RESET);
    }

    function blue(string memory self) internal view returns (string memory) {
        return string.concat(BLUE, self, RESET);
    }

    function blue(uint256 self) internal view returns (string memory) {
        return string.concat(BLUE, vm.toString(self), RESET);
    }

    function blue(int256 self) internal view returns (string memory) {
        return string.concat(BLUE, vm.toString(self), RESET);
    }

    function blue(address self) internal view returns (string memory) {
        return string.concat(BLUE, vm.toString(self), RESET);
    }

    function blue(bool self) internal view returns (string memory) {
        return string.concat(BLUE, vm.toString(self), RESET);
    }

    function magenta(string memory self) internal view returns (string memory) {
        return string.concat(MAGENTA, self, RESET);
    }

    function magenta(uint256 self) internal view returns (string memory) {
        return string.concat(MAGENTA, vm.toString(self), RESET);
    }

    function magenta(int256 self) internal view returns (string memory) {
        return string.concat(MAGENTA, vm.toString(self), RESET);
    }

    function magenta(address self) internal view returns (string memory) {
        return string.concat(MAGENTA, vm.toString(self), RESET);
    }

    function magenta(bool self) internal view returns (string memory) {
        return string.concat(MAGENTA, vm.toString(self), RESET);
    }

    function cyan(string memory self) internal view returns (string memory) {
        return string.concat(CYAN, self, RESET);
    }

    function cyan(uint256 self) internal view returns (string memory) {
        return string.concat(CYAN, vm.toString(self), RESET);
    }

    function cyan(int256 self) internal view returns (string memory) {
        return string.concat(CYAN, vm.toString(self), RESET);
    }

    function cyan(address self) internal view returns (string memory) {
        return string.concat(CYAN, vm.toString(self), RESET);
    }

    function cyan(bool self) internal view returns (string memory) {
        return string.concat(CYAN, vm.toString(self), RESET);
    }

    function bold(string memory self) internal view returns (string memory) {
        return string.concat(BOLD, self, RESET);
    }

    function bold(uint256 self) internal view returns (string memory) {
        return string.concat(BOLD, vm.toString(self), RESET);
    }

    function bold(int256 self) internal view returns (string memory) {
        return string.concat(BOLD, vm.toString(self), RESET);
    }

    function bold(address self) internal view returns (string memory) {
        return string.concat(BOLD, vm.toString(self), RESET);
    }

    function bold(bool self) internal view returns (string memory) {
        return string.concat(BOLD, vm.toString(self), RESET);
    }

    function dim(string memory self) internal view returns (string memory) {
        return string.concat(DIM, self, RESET);
    }

    function dim(uint256 self) internal view returns (string memory) {
        return string.concat(DIM, vm.toString(self), RESET);
    }

    function dim(int256 self) internal view returns (string memory) {
        return string.concat(DIM, vm.toString(self), RESET);
    }

    function dim(address self) internal view returns (string memory) {
        return string.concat(DIM, vm.toString(self), RESET);
    }

    function dim(bool self) internal view returns (string memory) {
        return string.concat(DIM, vm.toString(self), RESET);
    }

    function italic(string memory self) internal view returns (string memory) {
        return string.concat(ITALIC, self, RESET);
    }

    function italic(uint256 self) internal view returns (string memory) {
        return string.concat(ITALIC, vm.toString(self), RESET);
    }

    function italic(int256 self) internal view returns (string memory) {
        return string.concat(ITALIC, vm.toString(self), RESET);
    }

    function italic(address self) internal view returns (string memory) {
        return string.concat(ITALIC, vm.toString(self), RESET);
    }

    function italic(bool self) internal view returns (string memory) {
        return string.concat(ITALIC, vm.toString(self), RESET);
    }

    function underline(string memory self) internal view returns (string memory) {
        return string.concat(UNDERLINE, self, RESET);
    }

    function underline(uint256 self) internal view returns (string memory) {
        return string.concat(UNDERLINE, vm.toString(self), RESET);
    }

    function underline(int256 self) internal view returns (string memory) {
        return string.concat(UNDERLINE, vm.toString(self), RESET);
    }

    function underline(address self) internal view returns (string memory) {
        return string.concat(UNDERLINE, vm.toString(self), RESET);
    }

    function underline(bool self) internal view returns (string memory) {
        return string.concat(UNDERLINE, vm.toString(self), RESET);
    }

    function reverse(string memory self) internal view returns (string memory) {
        return string.concat(REVERSE, self, RESET);
    }

    function reverse(uint256 self) internal view returns (string memory) {
        return string.concat(REVERSE, vm.toString(self), RESET);
    }

    function reverse(int256 self) internal view returns (string memory) {
        return string.concat(REVERSE, vm.toString(self), RESET);
    }

    function reverse(address self) internal view returns (string memory) {
        return string.concat(REVERSE, vm.toString(self), RESET);
    }

    function reverse(bool self) internal view returns (string memory) {
        return string.concat(REVERSE, vm.toString(self), RESET);
    }
}
