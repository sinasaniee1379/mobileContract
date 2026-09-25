// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;
contract MobileShop{
    uint public counter = 0;
    struct product{
        uint id;
        string name;
        uint price;
        bool sold;
        address payable owner;
    }

    mapping(uint => product) public products;
    // ==========================================
    
    event createProduct(uint _id , string _name ,uint _price ,address payable _owner ,bool _sold);
    event salesProduct(uint _id , string _name ,uint _price ,address payable _owner ,bool _sold);

    //  =========================================

    function CreateProduct( string memory _name, uint _price) public{
        require(bytes(_name).length>0,"err: please enter the name of the product");
        require(_price>0,"err: please enter the price of the product");
        counter++;
        products[counter] = product(counter,_name,_price, false,payable(msg.sender));
        emit createProduct(counter ,_name, _price, payable(msg.sender), false);
    }

    function SalesProduct(uint _id) public payable {

        product memory selectedProduct = products[_id];
        require(selectedProduct.id>0 && selectedProduct.id <= counter,"err: id is not valid");
        address payable seller = selectedProduct.owner;
        require(msg.value > selectedProduct.price, "err: ETH is not valid");
        require(msg.sender != seller , "err: ower can not buy");

        selectedProduct.owner=payable(msg.sender);
        selectedProduct.sold=true;
        products[_id] = selectedProduct;

        (bool success, ) = seller.call{value: msg.value}("");
        require(success, "ETH transfer failed");

        emit salesProduct(_id, selectedProduct.name, selectedProduct.price, selectedProduct.owner, selectedProduct.sold);
    }

}