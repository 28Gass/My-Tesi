// contracts/LoanItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import"./LitemCalendar.sol";
import"./ItemTemplate.sol";
contract ItemFarm {
    
    string public name = "ItemFarm";
    string  public symbol = "IF";
     Calendar Calendario;
    
    
    

   address[] internal ItemCreatedAddresses;
   uint256 public countAttrezzi;
   mapping(uint => address)public addressById;
   mapping(uint => TokenNFT)public tokenId;
   mapping(uint => ItemTemplate)public ItemById;
   mapping(address => TokenNFT) internal ItemsByAddress;
   mapping(address => objectownerList) internal possessedItem;
   
     struct TokenNFT {
      uint id;
      string namet;
      string phots;
      string imgURL;
      string description;
      string Url;
      address own;
      ItemTemplate contractAddr;    
    }
    event ItemAdded(
      address indexed _from,
      uint256 _timestamp,
      string _name,
      uint id,
      string _logourl
      );
    struct objectownerList {
      address[] itemAddresses; 
      mapping(address => bool) possesed; 
    }
     

  constructor()  {  
        
         }

      function addNewItem(string memory _imgHash,
                          string memory _description,
                          string memory _imgURL, 
                          string memory namef,
                          string memory Url) public {
        require(bytes(namef).length > 0); 
        require(bytes(_description).length > 0);
        require(bytes(_imgHash).length > 0);
      
        ItemTemplate ItemTemp;
        countAttrezzi++;

        ItemTemp = new ItemTemplate(namef,_description,_imgHash,_imgURL,address(this),msg.sender,countAttrezzi,Url);
        
        address _tokenAddress = address(ItemTemp);
        addressById[countAttrezzi]=address(ItemTemp);

        if(possessedItem[msg.sender].possesed[_tokenAddress] == false){ 
            address[] storage newPossessed = possessedItem[msg.sender].itemAddresses;
            newPossessed.push(_tokenAddress);
            possessedItem[msg.sender].itemAddresses = newPossessed;
            possessedItem[msg.sender].possesed[_tokenAddress] = true;
        }
        
        ItemById[countAttrezzi]= ItemTemp;
        tokenId[countAttrezzi] = TokenNFT(countAttrezzi,namef,_imgHash,_imgURL,_description,Url,msg.sender,ItemTemp);
        ItemsByAddress[address(ItemTemp)]=TokenNFT(countAttrezzi,namef,_imgHash,_imgURL,_description,Url,msg.sender,ItemTemp);
        ItemCreatedAddresses.push(address(ItemTemp));  

       emit ItemAdded(msg.sender,block.timestamp,namef,countAttrezzi,_imgURL);
    }
    

    function getItemByID(uint _id) public view virtual  returns (string memory,
                                                                      string memory,
                                                                      address,
                                                                      string memory,
                                                                      address
                                                                      ){
      return (ItemById[_id]._name(),ItemById[_id]._description(),
        ItemById[_id]._owner(),ItemById[_id].Url(),address(tokenId[_id].contractAddr));
   
    }
    function getOwnerById(uint _id) public view virtual returns(address){
      return ItemById[_id]._owner();
    }

    function getAllitemAddresses() public view returns(address[] memory){
        return ItemCreatedAddresses;
    }

    function getpossessedItem(address _possessor) public view returns(address[] memory){
        return possessedItem[msg.sender].itemAddresses;
    } 
    function getAddressById(uint _id) public view returns(address){
      return addressById[_id];
    }
       function getTokenByAddress(address tokenAddress) public view
    returns(address, string memory, string memory, string memory, address) { 

    return(
        address(ItemsByAddress[tokenAddress].contractAddr),
        ItemsByAddress[tokenAddress].namet,
        ItemsByAddress[tokenAddress].description,
        ItemsByAddress[tokenAddress].imgURL,
        ItemsByAddress[tokenAddress].own
    );  
    }
      function remuvePoss(address oldown,address _tokenAddress)public{
        require(ItemTemplate(_tokenAddress)._owner()== oldown);
        if(possessedItem[oldown].possesed[_tokenAddress] == true){ //else is already correctly populated
            possessedItem[oldown].possesed[_tokenAddress] = false;
            address[] storage remuvePossessed = possessedItem[oldown].itemAddresses;
            for(uint x; x< remuvePossessed.length;x++){
              if(remuvePossessed[x]==_tokenAddress){
                delete remuvePossessed[x];
                possessedItem[oldown].itemAddresses=remuvePossessed; 
              }
            }
        
        } 

      }

      function addToPossessed(address _possessor, address _tokenAddress) public{
        require(ItemTemplate(_tokenAddress)._owner()== _possessor ,
            "_possessor must have some amount of this token to add it to his possessions");
        if(possessedItem[_possessor].possesed[_tokenAddress] == false){ //else is already correctly populated
            address[] storage newPossessed = possessedItem[_possessor].itemAddresses;
            newPossessed.push(_tokenAddress);
            possessedItem[_possessor].itemAddresses = newPossessed;
            possessedItem[_possessor].possesed[_tokenAddress] = true;
        }
    }
}






