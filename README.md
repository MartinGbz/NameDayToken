# NameDayToken 📅

## The ERC-20 token transferable only during its name day and by the owners of the name.

The NameDayToken contract allow to create ERC-20 tokens that are only:

- mintable by addresses that have an ENS name beginning with a specific name
- transferable during the name day

Example: You setup an Alice token that is mintable by all \*alice\*.eth holders and transferable during Alice's day (16/12 of each year).

## Specifications

### Constructor

- **string name\_** : ERC-20 token name (eg: AliceToken)
- **string symbol\_** : ERC-20 token symbol (eg: ALICE)
- **string dayName\_** : The day name (eg: alice). This name will be used to determine if the address has ENS name that start with this dayName (eg: alice)
- **uint256 nameDayTimestamp\_** : The timestamp of the day when the token will be mintable and transferable (eg: 1702684800)
- **uint256 mintPerUserPerYear\_** : The number of token that an address can mint pear year during the name day (eg: 100)
- **uint256 maxSupply\_** : The max supply of the token (eg: 1e24)

### mint()

- **string ensName** : The ENS name the sender should own. ⚠️ The ENS name should start with the dayName (eg: alicecooper)

</br>

⚠️ Subdomains are not supported for now.

The project was created for learning purposes.
