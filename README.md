# 📱 MobileShop — Solidity Smart Contract

A simple decentralized mobile shop smart contract built with **Solidity**.

This project demonstrates how to create, store, sell, and transfer ownership of products on the Ethereum-compatible blockchain using a Solidity smart contract.

---

## 🚀 Overview

**MobileShop** is a basic blockchain-based marketplace where users can:

* Create a product
* Set a price for the product
* Store product information on-chain
* Purchase an existing product
* Transfer product ownership to the buyer
* Transfer ETH to the seller
* Track product creation and sales through blockchain events

The project is designed as a simple example for learning **Solidity, mappings, structs, payable functions, events, and ETH transfers**.

---

## 🛠️ Technologies

* **Solidity:** `^0.8.34`
* **Blockchain:** Ethereum / EVM-compatible networks
* **Smart Contract:** Solidity
* **License:** MIT

---

## 📦 Contract Structure

The main contract is:

```solidity
contract MobileShop
```

It contains a product counter, product mapping, product creation functionality, and product sales functionality.

---

## 🧱 Product Structure

Each product is represented using the following `struct`:

```solidity
struct product {
    uint id;
    string name;
    uint price;
    bool sold;
    address payable owner;
}
```

### Product Fields

| Field   | Type              | Description                                 |
| ------- | ----------------- | ------------------------------------------- |
| `id`    | `uint`            | Unique product ID                           |
| `name`  | `string`          | Product name                                |
| `price` | `uint`            | Product price in wei                        |
| `sold`  | `bool`            | Indicates whether the product has been sold |
| `owner` | `address payable` | Current owner/seller of the product         |

---

## 🗃️ Product Storage

Products are stored using a Solidity mapping:

```solidity
mapping(uint => product) public products;
```

The product ID is used as the key.

For example:

```text
products[1]
products[2]
products[3]
```

Because the mapping is declared as `public`, Solidity automatically generates a getter that allows product information to be read from outside the contract.

---

## 🔢 Product Counter

The contract maintains a counter:

```solidity
uint public counter = 0;
```

Every time a new product is created:

```solidity
counter++;
```

The new value becomes the product's unique ID.

---

# 🛒 Creating a Product

Products can be created using:

```solidity
function CreateProduct(
    string memory _name,
    uint _price
) public
```

### Parameters

| Parameter | Description          |
| --------- | -------------------- |
| `_name`   | Name of the product  |
| `_price`  | Product price in wei |

### Validation

The function checks that the product name is not empty:

```solidity
require(
    bytes(_name).length > 0,
    "err: please enter the name of the product"
);
```

It also checks that the price is greater than zero:

```solidity
require(
    _price > 0,
    "err: please enter the price of the product"
);
```

After validation, a new product is created:

```solidity
products[counter] = product(
    counter,
    _name,
    _price,
    false,
    payable(msg.sender)
);
```

The address that creates the product becomes its owner.

---

# 💰 Buying a Product

Products can be purchased using:

```solidity
function SalesProduct(uint _id) public payable
```

Because the function is marked as:

```solidity
payable
```

the buyer can send ETH along with the transaction.

---

## 🔍 Product Validation

The contract first loads the selected product:

```solidity
product memory selectedProduct = products[_id];
```

Then it verifies that the product ID exists:

```solidity
require(
    selectedProduct.id > 0 && selectedProduct.id <= counter,
    "err: id is not valid"
);
```

---

## 👤 Seller Identification

The current product owner is stored as the seller:

```solidity
address payable seller = selectedProduct.owner;
```

The contract also prevents the owner from purchasing their own product:

```solidity
require(
    msg.sender != seller,
    "err: ower can not buy"
);
```

---

## 💵 ETH Payment

The buyer must send an amount greater than the product price:

```solidity
require(
    msg.value > selectedProduct.price,
    "err: ETH is not valid"
);
```

> **Important:** The current implementation uses `>` rather than `>=`.
> Therefore, sending exactly the listed price will cause the transaction to revert.

---

## 🔄 Ownership Transfer

After a successful purchase, ownership is transferred to the buyer:

```solidity
selectedProduct.owner = payable(msg.sender);
selectedProduct.sold = true;
```

Then the updated product is stored back in the mapping:

```solidity
products[_id] = selectedProduct;
```

The buyer therefore becomes the new owner.

---

# 💸 ETH Transfer

The contract transfers the ETH sent by the buyer to the seller:

```solidity
(bool success, ) = seller.call{value: msg.value}("");
```

The transaction is reverted if the transfer fails:

```solidity
require(
    success,
    "ETH transfer failed"
);
```

The contract uses `.call{value: ...}("")` for ETH transfer rather than the deprecated `transfer()` method.

---

# 📢 Events

The contract defines two events.

### Product Creation

```solidity
event createProduct(
    uint _id,
    string _name,
    uint _price,
    address payable _owner,
    bool _sold
);
```

This event is emitted whenever a new product is created.

---

### Product Sale

```solidity
event salesProduct(
    uint _id,
    string _name,
    uint _price,
    address payable _owner,
    bool _sold
);
```

This event is emitted after a product is successfully sold.

Events can be used by frontend applications to monitor blockchain activity without continuously reading the entire contract state.

---

# 🔄 Contract Workflow

The general workflow is:

```text
User
  │
  ▼
CreateProduct()
  │
  ▼
Product stored on blockchain
  │
  ▼
Another user calls SalesProduct()
  │
  ▼
Product validation
  │
  ▼
ETH sent with transaction
  │
  ▼
Ownership transferred
  │
  ▼
ETH transferred to seller
  │
  ▼
salesProduct event emitted
```

---

# 🧪 Example

Suppose Alice creates a product:

```solidity
CreateProduct("iPhone 17", 1 ether)
```

The contract stores something similar to:

```text
ID:       1
Name:     iPhone 17
Price:    1 ETH
Sold:     false
Owner:    Alice
```

Bob can then purchase the product by calling:

```solidity
SalesProduct{value: 1.1 ether}(1)
```

After the transaction:

```text
ID:       1
Name:     iPhone 17
Price:    1 ETH
Sold:     true
Owner:    Bob
```

And the `1.1 ETH` sent with the transaction is transferred to Alice.

---

# ⚠️ Current Limitations

This contract is intentionally simple and is mainly designed for learning purposes.

Before using it in a production marketplace, several areas should be improved.

### 1. Payment Amount

The current implementation requires:

```solidity
msg.value > selectedProduct.price
```

This means the buyer can pay more than the listed price.

A production marketplace would typically use:

```solidity
msg.value == selectedProduct.price
```

or explicitly handle overpayments and refunds.

---

### 2. Sold Products

The contract sets:

```solidity
selectedProduct.sold = true;
```

after a sale, but the current purchase function does not explicitly prevent a product marked as sold from being purchased again.

A production implementation should add a validation such as:

```solidity
require(
    !selectedProduct.sold,
    "Product already sold"
);
```

---

### 3. Product Deletion / Cancellation

There is currently no functionality for:

* Deleting a product
* Canceling a listing
* Updating the price
* Updating the product name
* Removing a product from sale

These features could be added in future versions.

---

### 4. Access Control

There is currently no administrator or role-management system.

For a larger marketplace, access control could be implemented using role-based permissions.

---

### 5. Security

Before deploying this contract with real funds, it should be thoroughly tested and audited.

Important areas include:

* Reentrancy protection
* Payment validation
* Product state validation
* Access control
* Ownership management
* Failed ETH transfers
* Unexpected contract interactions

---

# 🧰 Deployment

The contract can be compiled and deployed using tools such as:

* Remix IDE
* Hardhat
* Foundry
* Truffle

For example, using **Remix IDE**:

1. Open Remix.
2. Create `MobileShop.sol`.
3. Paste the contract code.
4. Select Solidity compiler `0.8.34`.
5. Compile the contract.
6. Select a wallet/account in the Deploy & Run Transactions section.
7. Deploy the contract.
8. Interact with `CreateProduct` and `SalesProduct`.

---

# 📖 Learning Topics

This project demonstrates several important Solidity concepts:

```text
Structs
   ↓
Mappings
   ↓
Functions
   ↓
msg.sender
   ↓
msg.value
   ↓
payable
   ↓
Events
   ↓
ETH Transfers
   ↓
Blockchain State
```

It is particularly useful for understanding how a simple decentralized marketplace can be implemented using Solidity.

---

# 🔮 Future Improvements

Possible improvements for future versions:

* [ ] Product availability validation
* [ ] Exact payment validation
* [ ] Product price updates
* [ ] Product cancellation
* [ ] Product deletion
* [ ] Seller withdrawal system
* [ ] Reentrancy protection
* [ ] Access control
* [ ] Product descriptions
* [ ] Product images / IPFS integration
* [ ] Frontend integration
* [ ] MetaMask integration
* [ ] Automated tests
* [ ] Deployment scripts
* [ ] Support for multiple EVM networks

---

# 📄 License

This project is licensed under the **MIT License**.

You are free to use, modify, and distribute this project according to the terms of the license.

---

## 👨‍💻 Author

**Sina Saniei**

Computer Engineering | AI | Blockchain | Web Development

---

⭐ If you found this project useful for learning Solidity and blockchain development, feel free to star the repository.
