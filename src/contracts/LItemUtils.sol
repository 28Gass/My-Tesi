


// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";


import "./LoanItem.sol";
import"./LitemCalendar.sol";

 contract LItemUtils   {
   address public owner;
   uint256 public createtime;
   LoanItem loanItem;
   Calendar Calendario;
   uint256 fusoorario;
   
   

  constructor() public {  
  
         }

   function Time() external {
        createtime = block.timestamp+ fusoorario;
      }

   function Update() public {
        //createtime = block.timestamp+ fusoorario;
      }

   function setFusoOraio()public{
  if (fusoorario==0){
    fusoorario= 3600;
  }
  else{
    fusoorario=0;
  }
}
      function Declarence(address cal, address item) public{

        loanItem = LoanItem(address(item));
        Calendario = Calendar(address(cal));
      }


}





