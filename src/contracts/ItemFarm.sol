// contracts/LoanItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import"./LitemCalendar.sol";
import"./ItemTemplate.sol";
contract ItemFarm {
    
    string public name = "ItemFarm";
    string  public symbol = "IF";
    
    
  

   mapping(uint => TokenNFT)public tokenId;
   mapping(uint => ItemTemplate)public ItemById;

     struct TokenNFT {
      uint id;
      string namet;
      string phots;
      string description;
      string Url;
      address own;
      ItemTemplate contractAddr;
      
      
    }
   
    Calendar Calendario;
    
    uint256 public countAttrezzi;
    address[] internal ItemCreatedAddresses;
   

  constructor() /*public ERC1155("")*/ {  
        
         }

      function addNewItem(string memory _imgHash,string memory _description, string memory namef,address owner,string memory Url) public {
    
        require(bytes(namef).length > 0);
        require(bytes(_description).length > 0);
        require(bytes(_imgHash).length > 0);
      
        ItemTemplate ItemTemp;

        countAttrezzi++;
        
        
     
        ItemTemp = new ItemTemplate(namef,_description,_imgHash,address(this),owner,countAttrezzi,Url);
        
        ItemById[countAttrezzi]= ItemTemp;

        tokenId[countAttrezzi] = TokenNFT(countAttrezzi,namef,_imgHash,_description,Url,owner,ItemTemp);
        
       ItemCreatedAddresses.push(address(ItemTemp));  
    }
    
    function getItemByID(uint _id) public view virtual  returns (string memory,
                                                                      string memory,
                                                                      string memory,
                                                                      string memory
                                                                 
                                                                      ){
      return (ItemById[_id]._name(),ItemById[_id]._description(),ItemById[_id]._imagehash(),ItemById[_id].Url());
   
    }
    function getOwnerById(uint _id) public view virtual returns(address){
      return ItemById[_id].ownerOf(_id);
    }

    function getAllTokenAddresses() public view returns(address[] memory){
        return ItemCreatedAddresses;
    }
    
 


}






