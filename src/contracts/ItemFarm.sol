// contracts/LoanItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import"./LitemCalendar.sol";
import"./ItemTemplate.sol";
contract ItemFarm {
    
    string public name = "ItemFarm";
    string  public symbol = "IF";
    
    
  
   mapping(uint => address)public addressById;
   mapping(uint => TokenNFT)public tokenId;
   mapping(uint => ItemTemplate)public ItemById;
   mapping(address => TokenNFT) internal ItemsByAddress;
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
   
    Calendar Calendario;
    
    uint256 public countAttrezzi;
    address[] internal ItemCreatedAddresses;


    event ItemAdded(
      address indexed _from,
      uint256 _timestamp,
      string _name,
      uint id,
      string _logourl
      );






    struct Registry {
        address[] tokenAddresses; //this will contain the addresses of the tokens possessed by an owner
        mapping(address => bool) alreadyIn; //this is just to help in fast checks (to avoid iterating over an array)
    }

    mapping(address => Registry) internal possessedTokens; 


  constructor()  {  
        
         }

      function addNewItem(string memory _imgHash,string memory _description,string memory _imgURL, string memory namef,string memory Url) public {
    
        require(bytes(namef).length > 0);
        require(bytes(_description).length > 0);
        require(bytes(_imgHash).length > 0);
      
        ItemTemplate ItemTemp;

        countAttrezzi++;

     
        ItemTemp = new ItemTemplate(namef,_description,_imgHash,_imgURL,address(this),msg.sender,countAttrezzi,Url);
        
        address _tokenAddress = address(ItemTemp);
        addressById[countAttrezzi]=address(ItemTemp);

        if(possessedTokens[msg.sender].alreadyIn[_tokenAddress] == false){ //else is already correctly populated
            address[] storage newPossessed = possessedTokens[msg.sender].tokenAddresses;
            newPossessed.push(_tokenAddress);
            possessedTokens[msg.sender].tokenAddresses = newPossessed;
            possessedTokens[msg.sender].alreadyIn[_tokenAddress] = true;
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
      return (ItemById[_id]._name(),ItemById[_id]._description(),ItemById[_id]._owner(),ItemById[_id].Url(),address(tokenId[_id].contractAddr));
   
    }
    function getOwnerById(uint _id) public view virtual returns(address){
      return ItemById[_id]._owner();
    }

    function getAllTokenAddresses() public view returns(address[] memory){
        return ItemCreatedAddresses;
    }
   /*   function Urltest(address Nft) public view returns(string memory){
       
        ItemTemplate rick;
        rick = ItemTemplate(Nft);

        return rick.UrlT() ;
    }*/
    function getPossessedTokens(address _possessor) public view returns(address[] memory){
        return possessedTokens[msg.sender].tokenAddresses;
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
        if(possessedTokens[oldown].alreadyIn[_tokenAddress] == true){ //else is already correctly populated
            possessedTokens[oldown].alreadyIn[_tokenAddress] = false;
            address[] storage remuvePossessed = possessedTokens[oldown].tokenAddresses;
            for(uint x; x< remuvePossessed.length;x++){
              if(remuvePossessed[x]==_tokenAddress){
                delete remuvePossessed[x];
                possessedTokens[oldown].tokenAddresses=remuvePossessed; 
              }
            }
        
        } 

      }

      function addToPossessed(address _possessor, address _tokenAddress) public{
        require(ItemTemplate(_tokenAddress)._owner()== _possessor ,
            "_possessor must have some amount of this token to add it to his possessions");
        if(possessedTokens[_possessor].alreadyIn[_tokenAddress] == false){ //else is already correctly populated
            address[] storage newPossessed = possessedTokens[_possessor].tokenAddresses;
            newPossessed.push(_tokenAddress);
            possessedTokens[_possessor].tokenAddresses = newPossessed;
            possessedTokens[_possessor].alreadyIn[_tokenAddress] = true;
        }
    }
}






