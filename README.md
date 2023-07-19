# 🏛️ Forge Standard Library &nbsp; [![CI status](https://github.com/foundry-rs/forge-std/actions/workflows/ci.yml/badge.svg)](https://github.com/foundry-rs/forge-std/actions/workflows/ci.yml)

<u>Forge Std</u> simplifies Forge tests - it comes with everyting you need to get started with [⚒️ Foundry](https://github.com/foundry-rs/foundry).

Explore <u>Forge Std</u> in [📖 Foundry Book](https://book.getfoundry.sh/forge/forge-std.html).

## Install

<u>Forge Std</u> will be pre-installed when you initialize a new project.

Manual:

```bash
forge install foundry-rs/forge-std
```

## Usage

### Test

```solidity
import "forge-std/Test.sol";

contract ExampleTest is Test {
```

### Script

```solidity
import "forge-std/Script.sol";

contract ExampleScript is Script {
```

### Interfaces

```solidity
import "forge-std/interfaces/IExample.sol";

contract Example is IExample {
```

## Examples

### Constants

`TestBase` `ScriptBase`

```solidity
vm.exampleCheat();
```

<sup>*Featured: Activates `exampleCheat`.*</sup>

### Console

`console` `console2` `safeconsole`

```solidity
console.log(example.x());
```

<sup>*Featured: Prints out the value of `x`.*</sup>

### Std Assertions

`StdAssertions`

```solidity
assertEq(example.x(), 1);
```

<sup>*Featured: Checks if `x` equals `1`.*</sup>

### Std Cheats

`StdCheats` `StdCheatsSafe`

```solidity
deployCodeTo("Example.sol", abi.encode(a), EXAMPLE_ADDRESS);
```

<sup>*Featured: Pseudo-deploys `Example` with the constructor argument `a` to the address `EXAMPLE_ADDRESS`.*</sup>

### Std Storage

`stdStorage` `stdStorageSafe`

```solidity
stdstore
    .target(address(example))
    .sig("x()")
    .checked_write(2);
```

<sup>*Featured: Sets the value read by `x` to `2`.*</sup>

### Std Errors

`stdError`

```solidity
vm.expectRevert(stdError.arithmeticError);
```

<sup>*Featured: Checks for the built-in underflow or overflow error.*</sup>

### Std Utils

`StdUtils`

```solidity
a = bound(a, 1, 10);
```

<sup>*Featured: Randomizes `a` in the range `1` through `10`, when `a` is fuzzed.*</sup>

### Std Math

`StdMath`

```solidity
stdMath.abs(a)
```

<sup>*Featured: Returns the absolute value of `a`.*</sup>

### Std Chains

`StdChains`

```solidity
getChain("example_chain").rpcUrl
```

<sup>*Featured: Returns the RPC URL for `example_chain`.*</sup>

### Std Json

`stdJson`

```solidity
exampleJson.readUint(".y")
```

<sup>*Featured: Returns the value of `y` field of `exampleJson` as `uint256`.*</sup>

### Std Invariant

`StdInvariant`

```solidity
excludeContract(address(example));
```

<sup>*Featured: Excludes `example` during stateful fuzzing.*</sup>

### Std Style

`StdStyle`

```solidity
console.log(StdStyle.blue(example.x()));
```

<sup>*Featured: Prints out the value of `x`, in blue color.*</sup>

## License

<u>Forge Std</u> is offered under [MIT](LICENSE-MIT) or [Apache 2.0](LICENSE-APACHE) license.
