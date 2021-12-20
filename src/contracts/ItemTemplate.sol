pragma solidity ^0.8.0;


import "./ItemFarm.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

/**
 * The ItemTemplate is ERC721 contract does this and that...
 */

 contract ItemTemplate is ERC721 /*ERC721Enumerable,Ownable*/ {
 	address public _owner;
 	string public _name;
 	string public _description;
 	string public _imagehash;
 	string public Url;
  ItemFarm itemfarm;
 	uint public _id;
  


  constructor(string memory Name,
  			  string memory description,
  			  string memory ImageHash,
  			  address Loanitem,
  			  address owner,
  			  uint id,
          string memory URL ) 
  			public ERC721(Name,ImageHash) {
  	

  	_name = Name;
  	_description = description;
  	_imagehash = ImageHash;
  	_owner = owner;
  	//loanitem = LoanItem(Loanitem);
  	_id = id;
    Url = URL;
  	//da aggiungere metadati json URL
  	//_MinterAdded(_owner);


  	_mint(_owner,_id);

  	//_MinterRemoved(_owner);    
  }
    function transfert(address buyer)public returns(bool res)  {
      _transfer(_owner,buyer,_id);
      _owner = ownerOf(_id);
      res = true;

    }
    
}
