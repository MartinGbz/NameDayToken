<div align="center"> 
  <h1> NameDayToken 📅 </h1>
  <p>The ERC-20 token mintable only during its name day and by the owners of the name</p>

[![Twitter Follow](https://img.shields.io/twitter/follow/0xMartinGbz?style=social)](https://twitter.com/0xMartinGbz)

</div>

# Abstract

The NameDayToken contract allow to create ERC-20 tokens that are only:

- mintable by addresses which have an ENS name containing a specific name
- mintable/transferable during the name day

Example: You setup an Alice token that is mintable by all \*alice\*.eth holders and only transferable during Alice's day (16/12 of each year).

# Specifications

## Constructor

- **string name\_** : ERC-20 token name (eg: AliceToken)
- **string symbol\_** : ERC-20 token symbol (eg: ALICE)
- **string dayName\_** : The day name (eg: alice). This name will be used to determine whether the address has an ENS name that contains this nameDay (eg: alice)
- **uint256 nameDayTimestamp\_** : The timestamp of the day when the token will be mintable and transferable (in seconds) (eg: 1702684800)
- **uint256 mintPerUserPerYear\_** : The number of token that an address can mint pear year during the name day (in wei) (eg: 1e20)
- **uint256 maxSupply\_** : The max supply of the token (in wei) (eg: 1e24)

## mint()

- **string ensName** : The ENS name the sender should own. ⚠️ The ENS name should contains the dayName (eg: alicecooper)

## Important notes

⚠️ Subdomains are not supported for now.

# Tests

Test must be run only on sepolia testnet:

`forge test -vv --fork-url https://ethereum-sepolia.publicnode.com`

Tests run on other networks will fail because the ENS owner addresses specified in the tests are only valid on the Sepolia test network.

I use "martinToken" as example in the tests because I ([0xMartinGbz](https://twitter.com/0xMartinGbz)) personnaly own all the ENSs specified in them. This ensures that the tests will always work, as nobody can change the addresses resolution and then cause test issues.

# Disclaimers

The project was created for learning purposes.
