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
    address public owner;
          bool time;
          uint256 timeI;
          uint256 timeF; 

     mapping(address=>string) public StatusItem;
     mapping(address => mapping(address=>LItem)) public UserLoaningItem;
     mapping(address =>LItem)public ItemData;
     mapping(address => dataR) internal LoanPos;
     mapping(address => mapping(address=>PreItem)) internal PreLItem;


       struct dataR {
        address[] itemAddresses; 
        mapping(address => bool) alreadyIn; 
        mapping(address => uint256)dataS;
   
    }
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
    bool pOwn;
    bool uOwn;
    }

 /*   event ItemEvent(
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
      );*/



  constructor(address _owner,Calendar Cad,TokenFactory tkfactory) public  {  
         owner = _owner;
  
         Calendario = Cad;
         Tkfactory = tkfactory;
         }
    
     function AddToLoanOrSellItem(address itemaddr,address CoinSimb,uint Price,uint caution,string memory PLace,
                                  string memory operation) public  returns(string memory) {
      require(keccak256(bytes(StatusItem[itemaddr])) == keccak256(bytes("")));
      //address x = CoinAdd(CoinSimb); 
      address x = CoinSimb;
      if(x != address(0x0)){
        if( keccak256(bytes(operation)) == keccak256(bytes("LoanItem"))&& itemaddr!= address(0x0)   ){
          ItemTemplate ItemtoLoan = ItemTemplate(itemaddr);
             LItem memory Temp = LItem(ItemtoLoan,itemaddr,x,Price,caution,PLace,"LoaningItem");
             UserLoaningItem[msg.sender][itemaddr]=Temp;   
             ItemData[itemaddr]= Temp;
             StatusItem[itemaddr]="LoaningItem";
             Calendario.setAvailable(ItemtoLoan._id(),"Available");
           //  emit ItemEvent(operation,ItemtoLoan,itemaddr,x,Price,caution,PLace,address(0),address(0),Calendario.Time(),0,0);
             
            return StatusItem[itemaddr];
      }
       else if( keccak256(bytes(operation)) == keccak256(bytes("SellIt"))){
        ItemTemplate ItemtoSell = ItemTemplate(itemaddr);   
        LItem memory Temp = LItem(ItemtoSell,itemaddr,x,Price,caution,PLace,"SellingItem");
        UserLoaningItem[msg.sender][itemaddr]=Temp;
        ItemData[itemaddr]= Temp;
        StatusItem[itemaddr]="Selling";
       // emit ItemEvent(operation,ItemtoSell,itemaddr,x,Price,caution,PLace,address(0),address(0),Calendario.Time(),0,0);
        return StatusItem[itemaddr];
      }
    } 
    return ""; 
  }

   
      function TransferOperation(address _from, address _to,address _item,string memory operation,uint256 dateS,uint256 dateF) external {
          
          ItemTemplate ItemtoLoan = ItemTemplate(_item);
          address ownerItem = ItemtoLoan.ownerOf(ItemtoLoan._id());
          time =false ;
          require(bytes(ItemtoLoan._name()).length > 0 );
                
            //oggetto in vendita
            if(keccak256(bytes(operation)) == keccak256(bytes("Sell"))&& keccak256(bytes(StatusItem[_item])) == keccak256(bytes("Selling"))){
              if(TokenTemplate(UserLoaningItem[_from][_item].CoinSy).transferFrom(_to,ownerItem,UserLoaningItem[_from][_item].price)){
                 require(ItemtoLoan.ownerOf(ItemtoLoan._id())==_from);
                ItemtoLoan.transfert(_to);
                delete StatusItem[_item];
                delete UserLoaningItem[_from][_item];
                delete ItemData[_item]; 
                return;
              }
              }


            if((keccak256(bytes(operation)) == keccak256(bytes("Prenotazione"))||keccak256(bytes(operation)) == keccak256(bytes("OnFly"))) && dateF>0 &&_from == ItemtoLoan.ownerOf(ItemtoLoan._id())
              ){
              if(ownerItem==msg.sender){
                if(TokenTemplate(UserLoaningItem[_from][_item].CoinSy).transferFrom(_to,ownerItem,UserLoaningItem[_from][_item].caution)){  
                    PreLItem[_to][_item].status="Prenotato";
                    return;  
                }}


              if(keccak256(bytes(operation)) == keccak256(bytes("Prenotazione")))
                time = true;
                if(dateS==0){
                timeI=Calendario.Converter(block.timestamp,time);
                } else{
                 timeI=Calendario.Converter(dateS,time);
              
                }
                timeF=Calendario.Converter(dateF,true);


              //prenotazione Noleggio pago la cauzione in anticipo 
               
              
                if(Calendario.Pre_Order(dateS,dateF,ItemtoLoan._id(),_to,ownerItem,time)){
                    PreItem memory Tempo = PreItem(_from,_to,_item,block.timestamp,timeI,timeF,"RPrenotato",false,false);
                    PreLItem[_to][_item]=Tempo;
                    addToPossessed(msg.sender,_item);
                    return;
                  }

                }

                    
                require(keccak256(bytes(Calendario.Available(ItemtoLoan._id()))) != keccak256(bytes("Waiting")));
                
                if(keccak256(bytes(operation)) == keccak256(bytes("Cancella")) && msg.sender==PreLItem[_to][_item].to&&
                 keccak256(bytes(PreLItem[_to][_item].status))!=keccak256(bytes("Ritirato"))){
                
                  PreLItem[_to][_item].status=operation;
                  return;

                }
            /*  if(Calendario.Pre_Order(dateS,dateF,ItemtoLoan._id(),msg.sender,ownerItem)&&dateF>0 && keccak256(bytes(operation)) == keccak256(bytes("OnFly")) && _from==ItemtoLoan.ownerOf(ItemtoLoan._id())){
                 if(TokenTemplate(UserLoaningItem[_from][_item].CoinSy).transferFrom(_to,ownerItem,UserLoaningItem[_from][_item].caution)){
                    PreItem memory Tempo = PreItem(_from,_to,_item,block.timestamp,Calendario.Converter(block.timestamp,false),Calendario.Converter(dateF,true),"Prenotato");
                    PreLItem[_to][_item]=Tempo;
                    addToPossessed(msg.sender,_item);
                    ItemtoLoan.setTempOwn(msg.sender);
              return;
            }
          }*/
          
             
            //riconsegna item  
          if( dateS>0 &&_to == ItemtoLoan.ownerOf(ItemtoLoan._id()) &&   keccak256(bytes(operation)) == keccak256(bytes("Riconsegna")) 
             && keccak256(bytes(PreLItem[msg.sender][_item].status))==keccak256(bytes("Ritirato")) ){                           
            if(Calendario.Back(ItemtoLoan._id(),dateS,false)){
            PreLItem[msg.sender][_item].status="Riconsegnato";
          
            return;
          }
            }
  
              if(keccak256(bytes(operation)) == keccak256(bytes("RitiroPre"))){ 
                    if(PreLItem[_to][_item].to==msg.sender){
                      PreLItem[_to][_item].uOwn=true;
                    
                      }else if(PreLItem[_to][_item].from==msg.sender){
                        PreLItem[_to][_item].pOwn =true;
                         
                      }
                      PreLItem[_to][_item].status="Attesa";
                      if(PreLItem[_to][_item].pOwn && PreLItem[_to][_item].uOwn){
                       if(TokenTemplate(UserLoaningItem[_from][_item].CoinSy).transferFrom(_to,ownerItem,UserLoaningItem[_from][_item].price)&&Calendario.AcquirePre(ItemtoLoan._id(),_to,dateS) && _from==ItemtoLoan.ownerOf(ItemtoLoan._id())){

                          PreLItem[_to][_item].status= "Ritirato";
                          ItemtoLoan.setTempOwn(_to);
                          return;
                      }
                    
                  }
                  return;                  
                  }
  
          require(false,"Operation not working");
      }
  
      function ReleseW(address _id,address _usr, uint256 _caution,bool notpay,bool cancel) public{

        ItemTemplate ItemtoRelese = ItemTemplate(_id);
        uint id=ItemtoRelese._id();
        address ownerItem = ItemtoRelese.ownerOf(id);
        
        require(_caution<=UserLoaningItem[ownerItem][_id].caution);
        require(ItemtoRelese.ownerOf(id)==msg.sender||PreLItem[_usr][_id].to ==msg.sender);
        require( keccak256(bytes( PreLItem[_usr][_id].status))!= keccak256(bytes("Ritirato")));
         if(!cancel){ 
          if(PreLItem[_usr][_id].to==_usr && (PreLItem[_usr][_id].from == msg.sender||PreLItem[_usr][_id].to ==msg.sender)){

             Calendario.deleteOrder(PreLItem[_usr][_id].timeS,PreLItem[_usr][_id].from,id);
             if(ItemtoRelese.temp_own()==_usr){ 
              ItemtoRelese.deleteTOwn();
              Calendario.Relese(id);
            }else{
              Calendario.Back(id,PreLItem[_usr][_id].timeS,true);
            }
              remuvePoss(_usr,_id);
              delete PreLItem[_usr][_id];
              if(notpay)
                return;
            if(TokenTemplate(UserLoaningItem[ownerItem][_id].CoinSy).transferFrom(ownerItem,_usr,_caution))     
              return;     
            }
             return;
       }else if(keccak256(bytes(StatusItem[_id]))==keccak256(bytes("Selling"))|| keccak256(bytes(Calendario.Available(id))) == keccak256(bytes("Available"))){ 
              delete StatusItem[_id];
                delete UserLoaningItem[ownerItem][_id];
                delete ItemData[_id]; 
                return;
      }
     }
       
      
function getAItemData(address item)public view returns(address,address,uint256,uint256,string memory,string memory){
    
    return(ItemData[item].addr,ItemData[item].CoinSy,ItemData[item].price,ItemData[item].caution,ItemData[item].place,
          StatusItem[item]
          );
}

function getPreData(address own,address i)public view returns(address,address,uint,uint,uint,string memory){


return(
  PreLItem[own][i].from,
  PreLItem[own][i].to,
  PreLItem[own][i].time,
  PreLItem[own][i].timeS,
  PreLItem[own][i].timeE,
  PreLItem[own][i].status);
}

function getPermissionPre(address own,address i)public view returns(bool,bool){
  return(
     PreLItem[own][i].pOwn,
     PreLItem[own][i].uOwn
      );
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
            LoanPos[_possessor].dataS[_tokenAddress]=Calendario.Converter(block.timestamp,false);
        }

    }



    }











