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
        return red(vm.toString(self));
    }

    function red(int256 self) internal view returns (string memory) {
        return red(vm.toString(self));
    }

    function red(address self) internal view returns (string memory) {
        return red(vm.toString(self));
    }

    function red(bool self) internal view returns (string memory) {
        return red(vm.toString(self));
    }

    function green(string memory self) internal view returns (string memory) {
        return string.concat(GREEN, self, RESET);
    }

    function green(uint256 self) internal view returns (string memory) {
        return green(vm.toString(self));
    }

    function green(int256 self) internal view returns (string memory) {
        return green(vm.toString(self));
    }

    function green(address self) internal view returns (string memory) {
        return green(vm.toString(self));
    }

    function green(bool self) internal view returns (string memory) {
        return green(vm.toString(self));
    }

    function yellow(string memory self) internal view returns (string memory) {
        return string.concat(YELLOW, self, RESET);
    }

    function yellow(uint256 self) internal view returns (string memory) {
        return yellow(vm.toString(self));
    }

    function yellow(int256 self) internal view returns (string memory) {
        return yellow(vm.toString(self));
    }

    function yellow(address self) internal view returns (string memory) {
        return yellow(vm.toString(self));
    }

    function yellow(bool self) internal view returns (string memory) {
        return yellow(vm.toString(self));
    }

    function blue(string memory self) internal view returns (string memory) {
        return string.concat(BLUE, self, RESET);
    }

    function blue(uint256 self) internal view returns (string memory) {
        return blue(vm.toString(self));
    }

    function blue(int256 self) internal view returns (string memory) {
        return blue(vm.toString(self));
    }

    function blue(address self) internal view returns (string memory) {
        return blue(vm.toString(self));
    }

    function blue(bool self) internal view returns (string memory) {
        return blue(vm.toString(self));
    }

    function magenta(string memory self) internal view returns (string memory) {
        return string.concat(MAGENTA, self, RESET);
    }

    function magenta(uint256 self) internal view returns (string memory) {
        return magenta(vm.toString(self));
    }

    function magenta(int256 self) internal view returns (string memory) {
        return magenta(vm.toString(self));
    }

    function magenta(address self) internal view returns (string memory) {
        return magenta(vm.toString(self));
    }

    function magenta(bool self) internal view returns (string memory) {
        return magenta(vm.toString(self));
    }

    function cyan(string memory self) internal view returns (string memory) {
        return string.concat(CYAN, self, RESET);
    }

    function cyan(uint256 self) internal view returns (string memory) {
        return cyan(vm.toString(self));
    }

    function cyan(int256 self) internal view returns (string memory) {
        return cyan(vm.toString(self));
    }

    function cyan(address self) internal view returns (string memory) {
        return cyan(vm.toString(self));
    }

    function cyan(bool self) internal view returns (string memory) {
        return cyan(vm.toString(self));
    }

    function bold(string memory self) internal view returns (string memory) {
        return string.concat(BOLD, self, RESET);
    }

    function bold(uint256 self) internal view returns (string memory) {
        return bold(vm.toString(self));
    }

    function bold(int256 self) internal view returns (string memory) {
        return bold(vm.toString(self));
    }

    function bold(address self) internal view returns (string memory) {
        return bold(vm.toString(self));
    }

    function bold(bool self) internal view returns (string memory) {
        return bold(vm.toString(self));
    }

    function dim(string memory self) internal view returns (string memory) {
        return string.concat(DIM, self, RESET);
    }

    function dim(uint256 self) internal view returns (string memory) {
        return dim(vm.toString(self));
    }

    function dim(int256 self) internal view returns (string memory) {
        return dim(vm.toString(self));
    }

    function dim(address self) internal view returns (string memory) {
        return dim(vm.toString(self));
    }

    function dim(bool self) internal view returns (string memory) {
        return dim(vm.toString(self));
    }

    function italic(string memory self) internal view returns (string memory) {
        return string.concat(ITALIC, self, RESET);
    }

    function italic(uint256 self) internal view returns (string memory) {
        return italic(vm.toString(self));
    }

    function italic(int256 self) internal view returns (string memory) {
        return italic(vm.toString(self));
    }

    function italic(address self) internal view returns (string memory) {
        return italic(vm.toString(self));
    }

    function italic(bool self) internal view returns (string memory) {
        return italic(vm.toString(self));
    }

    function underline(string memory self) internal view returns (string memory) {
        return string.concat(UNDERLINE, self, RESET);
    }

    function underline(uint256 self) internal view returns (string memory) {
        return underline(vm.toString(self));
    }

    function underline(int256 self) internal view returns (string memory) {
        return underline(vm.toString(self));
    }

    function underline(address self) internal view returns (string memory) {
        return underline(vm.toString(self));
    }

    function underline(bool self) internal view returns (string memory) {
        return underline(vm.toString(self));
    }

    function reverse(string memory self) internal view returns (string memory) {
        return string.concat(REVERSE, self, RESET);
    }

    function reverse(uint256 self) internal view returns (string memory) {
        return reverse(vm.toString(self));
    }

    function reverse(int256 self) internal view returns (string memory) {
        return reverse(vm.toString(self));
    }

    function reverse(address self) internal view returns (string memory) {
        return reverse(vm.toString(self));
    }

    function reverse(bool self) internal view returns (string memory) {
        return reverse(vm.toString(self));
    }
}
