// contracts/LoanItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import"./LitemCalendar.sol";
import"./ItemTemplate.sol";
import"./TokenFactory.sol";
import"./TokenTemplate.sol";
contract LoanItem {
    
    
    Calendar public Calendario;
    TokenFactory public Tkfactory;  
  
     
     mapping(address=>string) public StatusItem;
     mapping(address => mapping(address=>LItem)) public UserLoaningItem;
     mapping(address =>LItem)public ItemData;
 
    address public owner;

       struct dataR {
        address[] itemAddresses; //this will contain the addresses of the tokens possessed by an owner
        mapping(address => bool) alreadyIn; //this is just to help in fast checks (to avoid iterating over an array)
        mapping(address => uint256)dataS;
       // mapping(address => operation)
    }

    mapping(address => dataR) internal LoanPos; 

 //   mapping(address => Registry) internal LoanPre; 
  //  mapping(uint256 => PreItem) internal PreLItem;

  mapping(address => mapping(address=>PreItem)) internal PreLItem;



  struct LItem{
    ItemTemplate Item;
    address addr;
    address CoinSy;
    uint256 price;
    uint256 caution;
    string place;
    string operation;
    }
    
  struct PreItem{
    address from;
    address to;
    address item;
    uint time;
    uint timeS;
    uint timeE;
    string status;
    }



    event ItemEvent(
    string operation,
    ItemTemplate Item,
    address addr,
    address CoinSy,
    uint256 price,
    uint256 caution,
    string place,
    address from,
    address to,
    uint time,
    uint timeS,
    uint timeE
      );





  constructor(address _owner,Calendar Cad,TokenFactory tkfactory) public  {  
         owner = _owner;
       //  permissions[owner]= true;
         Calendario = Cad;
         Tkfactory = tkfactory;
         }
    

  


     function AddToLoanOrSellItem(address itemaddr,address CoinSimb,uint Price,uint caution,string memory PLace,
                                  string memory operation) public  returns(string memory) {
      require(keccak256(bytes(StatusItem[itemaddr])) == keccak256(bytes("")),"L'oggetto e occupato per altro ");
      //address x = CoinAdd(CoinSimb); 
      address x = CoinSimb;
      if(x != address(0x0)){
        if( keccak256(bytes(operation)) == keccak256(bytes("LoanItem"))&& itemaddr!= address(0x0)   ){
          ItemTemplate ItemtoLoan = ItemTemplate(itemaddr);
          //require(bytes(ItemtoLoan._name()).length > 0,"1" );
          //require(ItemtoLoan.ownerOf(ItemtoLoan._id())==msg.sender,"2");
             LItem memory Temp = LItem(ItemtoLoan,itemaddr,x,Price,caution,PLace,"LoaningItem");
             UserLoaningItem[msg.sender][itemaddr]=Temp;   
             ItemData[itemaddr]= Temp;
             // LoaningItem.push(temp)
             //implementare la cancellazione nella relese
             StatusItem[itemaddr]="LoaningItem";
             //itemLoanSell.push(itemaddr);
             Calendario.setAvailable(ItemtoLoan._id(),"Available");
             emit ItemEvent(operation,ItemtoLoan,itemaddr,x,Price,caution,PLace,address(0),address(0),Calendario.Time(),0,0);
             
            return StatusItem[itemaddr];

      }
       else if( keccak256(bytes(operation)) == keccak256(bytes("SellIt"))){
        ItemTemplate ItemtoSell = ItemTemplate(itemaddr);

        //require(bytes(ItemtoSell._name()).length > 0 );
        //require(ItemtoSell.ownerOf(ItemtoSell._id())==msg.sender);     
        LItem memory Temp = LItem(ItemtoSell,itemaddr,x,Price,caution,PLace,"SellingItem");
        UserLoaningItem[msg.sender][itemaddr]=Temp;
        ItemData[itemaddr]= Temp;
        StatusItem[itemaddr]="Selling";
        //itemLoanSell.push(itemaddr);
        emit ItemEvent(operation,ItemtoSell,itemaddr,x,Price,caution,PLace,address(0),address(0),Calendario.Time(),0,0);
        //return "Selling";
        return StatusItem[itemaddr];
      }
    } 
    return ""; 
  }

   
      function TrasferTest(address _from, address _to,address _item,string memory operation,uint256 dateS,uint256 dateF) external {
          ItemTemplate ItemtoSell = ItemTemplate(_item);
          address ownerItem = ItemtoSell.ownerOf(ItemtoSell._id());
          ItemTemplate ItemtoLoan = ItemTemplate(_item);
          require(bytes(ItemtoLoan._name()).length > 0 );
          require(keccak256(bytes(Calendario.Available(ItemtoLoan._id()))) != keccak256(bytes("Waiting")),"token is waiting ");
         // uint iner;
         // iner = find(_item,_from,false);
          //uint k = find(_item,msg.sender,true);

            if(keccak256(bytes(operation)) == keccak256(bytes("Sell"))&& keccak256(bytes(StatusItem[_item])) == keccak256(bytes("Selling"))){
              ItemTemplate ItemtoSell = ItemTemplate(_item);
              
            if(TokenTemplate(UserLoaningItem[_from][_item].CoinSy).transferFrom(_to,ownerItem,UserLoaningItem[_from][_item].price)){
                 require(ItemtoSell.ownerOf(ItemtoSell._id())==_from);
                ItemtoSell.transfert(_to);
                delete StatusItem[_item];
                delete UserLoaningItem[_from][_item];
                delete ItemData[_item]; 
              }

                return;
              }


          if( dateS>0 &&_to == ItemtoLoan.ownerOf(ItemtoLoan._id()) &&   keccak256(bytes(operation)) == keccak256(bytes("Riconsegna")) 

            && keccak256(bytes(Calendario.Available(ItemtoLoan._id()))) == keccak256(bytes("Busy")) && keccak256(bytes(PreLItem[msg.sender][_item].status))==keccak256(bytes("Ritirato")) ){
            //riconsegna item
            if(Calendario.Back(ItemtoLoan._id(),dateS)){
            //remuvePoss(_item);
            PreLItem[msg.sender][_item].status="Riconsegnato";
          //  emit LoanPre(_from,_to,_item,Calendario.Time(),dateS,dateF,orders,"Back-Loan");
            return;
          }
            }
      
            
            if(keccak256(bytes(operation)) == keccak256(bytes("Prenotazione")) && dateF>0 &&_from == ItemtoLoan.ownerOf(ItemtoLoan._id())){
              //prenotazione Noleggio pago la cauzione in anticipo   
             
                if(TokenTemplate(UserLoaningItem[_from][_item].CoinSy).transferFrom(_to,ownerItem,UserLoaningItem[_from][_item].caution)){
                  if(Calendario.Pre_Order(dateS,dateF,ItemtoLoan._id(),msg.sender,ownerItem)) {
                   // TokenTemplate(UserLoaningItem[_from][iner].CoinSy).transfer(_to,UserLoaningItem[_from][iner].caution,_from);
                   // CautionId[ItemtoLoan._id()].push(_to); 
                  //  emit ItemEvent(operation,address(0),_item,UserLoaningItem[_from][iner].CoinSy,0,0,"",address(0),address(0),Calendario.Time(),0,0);
                    ItemtoLoan.setTempOwn(msg.sender);
                    PreItem memory Tempo = PreItem(_from,_to,_item,block.timestamp,Calendario.Converter(dateS,true),Calendario.Converter(dateF,true),"Prenotato");
                    PreLItem[_to][_item]=Tempo;
                    addToPossessed(msg.sender,_item);
                    return;
                  }
                return;
                }  
            return;
            }
             
              if(keccak256(bytes(operation)) == keccak256(bytes("RitiroPre")) /*&& PreLItem[msg.sender][_item].to == msg.sender &&keccak256(bytes(PreLItem[msg.sender][_item].status))==keccak256(bytes("Prenotato"))*/ ){ 
                 
                    if(Calendario.AcquirePre(ItemtoLoan._id(),msg.sender,dateS) && _from==ItemtoLoan.ownerOf(ItemtoLoan._id())){ 
                       if(TokenTemplate(UserLoaningItem[_from][_item].CoinSy).transferFrom(_to,ownerItem,UserLoaningItem[_from][_item].price)){
                    //addToPossessed(msg.sender,_item);
                    PreLItem[msg.sender][_item].status= "Ritirato";
                    ItemtoLoan.setTempOwn(msg.sender);
                //emit LoanPre(_from,_to,_item,Calendario.Time(),dateS,dateF,orders,"Acq-Pre-Loan");
                 //   TokenTemplate(UserLoaningItem[_from][iner].CoinSy).transfer(_to,UserLoaningItem[_from][iner].price,_from);
                 
                    }
                  }
                  return;
                 
              }

              //noleggio sul momento
             
              if(dateF>0 && keccak256(bytes(operation)) == keccak256(bytes("OnFly")) && _from==ItemtoLoan.ownerOf(ItemtoLoan._id())){
              if(Calendario.Acquire(_from,ItemtoLoan._id(),msg.sender,dateF)){
                 if(TokenTemplate(UserLoaningItem[_from][_item].CoinSy).transferFrom(_to,ownerItem,UserLoaningItem[_from][_item].price+UserLoaningItem[_from][_item].caution)){
                    PreItem memory Tempo = PreItem(_from,_to,_item,block.timestamp,Calendario.Converter(block.timestamp,false),Calendario.Converter(dateF,true),"Ritirato");
                    PreLItem[_to][_item]=Tempo;
                //CautionId[ItemtoLoan._id()].push(_to);
                addToPossessed(msg.sender,_item);
                ItemtoLoan.setTempOwn(msg.sender);
               // emit LoanPre(_from,_to,_item,Calendario.Time(),dateS,dateF,orders,"Normal-Loan");
              return;
            }
          }}

          return;
      }
  
      

      function ReleseW(address _id,address _usr, uint256 _caution ) public{

        ItemTemplate ItemtoRelese = ItemTemplate(_id);
        address ownerItem = ItemtoRelese.ownerOf(ItemtoRelese._id());
        uint id=ItemtoRelese._id();

    //si potrebbe gestire il caso in cui la cauzione restituita sia variabile
        require(bytes(ItemtoRelese._name()).length > 0);
        require(ItemtoRelese.ownerOf(id)==msg.sender);
   
   
        if(TokenTemplate(UserLoaningItem[ownerItem][_id].CoinSy).transferFrom(ownerItem,_usr,UserLoaningItem[ownerItem][_id].caution)){         
        if(PreLItem[_usr][_id].to==_usr && _usr!=msg.sender && PreLItem[_usr][_id].from == msg.sender){
          
          Calendario.Relese(id);
          Calendario.deleteOrder(PreLItem[_usr][_id].timeS,msg.sender,ItemtoRelese._id());
     
        if(_caution>0){
        
        }else{
      
      } 
         ItemtoRelese.deleteTOwn();
        remuvePoss(_usr,_id);
          delete PreLItem[_usr][_id];
   
        return;
       
            }  
          }
  
         return;
       }
         
      




function getAItemData(address item)public view returns(address,address,uint256,uint256,string memory,string memory){
    
    return(ItemData[item].addr,ItemData[item].CoinSy,ItemData[item].price,ItemData[item].caution,ItemData[item].place,
          StatusItem[item]
          );
}

function getPreData(address own,address i)public view returns(address,address,uint,uint,uint,string memory){


return(PreLItem[own][i].from,PreLItem[own][i].to,PreLItem[own][i].time,PreLItem[own][i].timeS,PreLItem[own][i].timeE,PreLItem[own][i].status);


}

function getPossessedLoans() public view returns(address[] memory){

        return LoanPos[msg.sender].itemAddresses;
  
    } 

     function remuvePoss(address oldown,address _tokenAddress)public{
       
        if(LoanPos[oldown].alreadyIn[_tokenAddress] == true){ //else is already correctly populated
            LoanPos[oldown].alreadyIn[_tokenAddress] = false;
            address[] storage remuvePossessed = LoanPos[oldown].itemAddresses;
            for(uint x; x< remuvePossessed.length;x++){
              if(remuvePossessed[x]==_tokenAddress){
                delete remuvePossessed[x];
                LoanPos[oldown].itemAddresses=remuvePossessed; 
              }
            }
        
        } 

      }

      function addToPossessed(address _possessor, address _tokenAddress) public{
       // require(ItemTemplate(_tokenAddress)._owner()== _possessor ,
        //    "_possessor must have some amount of this token to add it to his possessions");
        if(LoanPos[_possessor].alreadyIn[_tokenAddress] == false){ //else is already correctly populated
            address[] storage newPossessed = LoanPos[_possessor].itemAddresses;
            newPossessed.push(_tokenAddress);
            LoanPos[_possessor].itemAddresses = newPossessed;
            LoanPos[_possessor].alreadyIn[_tokenAddress] = true;
            LoanPos[msg.sender].dataS[_tokenAddress]=Calendario.Converter(block.timestamp,false);
        }

    }



    }











