<div align="center"> 
  <h1> NameDayToken 🥳 </h1>
  <p>The ERC-20 token mintable only during its name day and by the name owners</p>

[![Twitter Follow](https://img.shields.io/twitter/follow/0xMartinGbz?style=social)](https://twitter.com/0xMartinGbz)

</div>

# Abstract

- The **NameDayToken** is an ERC-20 contract mintable by addresses with specific ENS names and transferable only during the specific name day.

  Example: You setup an Alice token that is mintable by all \*alice\*.eth holders and only transferable during Alice's day (16/12 of each year).

- The **NameDayTokenFactory** contract allow you to deploy a NameDayToken easily.

# Specifications

## NameDayToken

### Constructor

- **string name\_** : ERC-20 token name (eg: AliceToken)
- **string symbol\_** : ERC-20 token symbol (eg: ALICE)
- **string dayName\_** : The day name (eg: alice). This name will be used to determine whether the address has an ENS name that contains this nameDay (eg: alice)
- **uint256 nameDayTimestamp\_** : The timestamp of the day when the token will be mintable and transferable (in seconds) (eg: 1702684800)
- **uint256 mintPerUserPerYear\_** : The number of token that an address can mint pear year during the name day (in wei) (eg: 1e20)
- **uint256 maxSupply\_** : The max supply of the token (in wei) (eg: 1e24)

### mint()

Allows mint _`mintPerUserPerYear`_ NameDayToken.

#### Parameters:

- **string ensName** : The ENS name the sender should own. ⚠️ The ENS name should contains the dayName (eg: alicecooper)

## NameDayTokenFactory

### deployToken()

Allows you to deploy a NameDayToken

#### Parameters:

- all the arguments of the [NameDayToken contrsuctor](#constructor).

# Tests

Test must be run only on sepolia testnet:

`forge test -vv --fork-url https://ethereum-sepolia.publicnode.com`

Tests run on other networks will fail because the ENS owner addresses specified in the tests are only valid on the Sepolia test network.

I use "martinToken" as example in the tests because I ([0xMartinGbz](https://twitter.com/0xMartinGbz)) personnaly own all the Sepolia ENSs specified in them. This ensures that the tests will always work, as nobody can change the addresses resolution and then cause test issues.

# Important notes

⚠️ Subdomains are not supported for now.

# Disclaimers

The project has been created for learning purposes only.
