


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

        function AllBalanceBath(address[] memory _from) external
      //tutti i comodati affidati divisi per utenti _from[1] utente 1 ha ids[0] 
      view
      virtual
      returns (uint256[] memory)
      {
         
        uint256[] memory batchBalances = new uint256[](_from.length);
        for (uint256 i = 0; i < _from.length; ++i) {
          for(uint256 j = 1; j <loanItem.countAttrezzi()+1;++j){
            batchBalances[i] = batchBalances[i] + loanItem.balanceOf(_from[i],loanItem.ids(j));
          }
        }
      return batchBalances;
      }
    
      function AllBalanceBathForOne(address _from) external
      //tutti i comodati affidati divisi per utenti _from[1] utente 1 ha ids[0] 
      view
      virtual
      returns (uint256)
      {
        
        uint256 batchBalances1;        
        for(uint256 j = 1; j <loanItem.countAttrezzi()+1;++j){
          batchBalances1 = batchBalances1 + loanItem.balanceOf(_from,loanItem.ids(j));     
        }  
        return batchBalances1;
      }
      
       function WaitingUsr(uint256 _id) public 
      virtual returns(address){

   for(uint256 i; i<100 + Calendario.Orders();i++){
    if(loanItem.CautionId(_id,i) != address(0x0)){
      i = Calendario.Orders();
      return loanItem.CautionId(_id,i);

   }

    }
   return address(0x0);
    }


}





