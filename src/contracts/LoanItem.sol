// contracts/LoanItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import"./LitemCalendar.sol";
import"./ItemTemplate.sol";
import"./TokenFactory.sol";
import"./TokenTemplate.sol";
contract LoanItem {
    
    
    Calendar Calendario;
    TokenFactory Tkfactory;  
  
     mapping(address => bool) public permissions;
     mapping(uint256 => uint256) public Cds;
  
     uint256 orders;
     
     mapping(address=>string) public StatusItem;
     mapping(address =>LItem[]) public UserLoaningItem;
     
     mapping(address=>PreItem[])public PreLItem;
     mapping(uint256=>address[]) public CautionId;

    address public owner;

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
         permissions[owner]= true;
         Calendario = Cad;
         Tkfactory = tkfactory;
         }
    

 function CoinAdd(string memory Symbl)internal returns(address) {
    address x;
    (x,,,,,,)= Tkfactory.getToken(Symbl);
    //require(x!=address(0x0));
    return x;
 }
  
  function find(address itemaddr,address owner,bool cas) internal returns(uint256) {
    if(cas){
     for(uint j; j<PreLItem[owner].length;j++){
        if(PreLItem[owner][j].item== itemaddr){
          return j;
    }}
    return 0;}
    for(uint i; i<UserLoaningItem[owner].length;i++){
        if(UserLoaningItem[owner][i].addr== itemaddr){
          return i;
        }

    }
    return 0;
  }

     function AddToLoanOrSellItem(address itemaddr,string memory CoinSimb,uint Price,uint caution,string memory PLace,
                                  string memory operation) public {
      require(keccak256(bytes(StatusItem[itemaddr])) == keccak256(bytes("")),"L'oggetto e occupato per altro ");
      address x = CoinAdd(CoinSimb); 
      if(x != address(0x0)){
        if( keccak256(bytes(operation)) == keccak256(bytes("LoanItem"))&& itemaddr!= address(0x0)   ){
          ItemTemplate ItemtoLoan = ItemTemplate(itemaddr);
          require(bytes(ItemtoLoan._name()).length > 0,"1" );
          require(ItemtoLoan.ownerOf(ItemtoLoan._id())==msg.sender,"2");
             LItem memory Temp = LItem(ItemtoLoan,itemaddr,x,Price,caution,PLace,"LoaningItem");
             UserLoaningItem[msg.sender].push(Temp);   
             // LoaningItem.push(temp)
             //implementare la cancellazione nella relese
             StatusItem[itemaddr]="LoaningItem";
             Calendario.setAvailable(ItemtoLoan._id(),"Available");
             emit ItemEvent(operation,ItemtoLoan,itemaddr,x,Price,caution,PLace,address(0),address(0),Calendario.Time(),0,0);
             return;
    

      }
       else if( keccak256(bytes(operation)) == keccak256(bytes("SellIt"))){
        ItemTemplate ItemtoSell = ItemTemplate(itemaddr);
        require(bytes(ItemtoSell._name()).length > 0 );
        require(ItemtoSell.ownerOf(ItemtoSell._id())==msg.sender);     
        LItem memory Temp = LItem(ItemtoSell,itemaddr,x,Price,caution,PLace,"SellingItem");
        UserLoaningItem[msg.sender].push(Temp);
        StatusItem[itemaddr]="Selling";
        emit ItemEvent(operation,ItemtoSell,itemaddr,x,Price,caution,PLace,address(0),address(0),Calendario.Time(),0,0);
        return;
      }
    } 
  }

   
      function TrasferTest(address _from, address _to,address _item,string memory operation,uint256 dateS,uint256 dateF) external {

    
          ItemTemplate ItemtoLoan = ItemTemplate(_item);
          require(bytes(ItemtoLoan._name()).length > 0 );
          require(keccak256(bytes(Calendario.Available(ItemtoLoan._id()))) != keccak256(bytes("Waiting")),"token is waiting ");
          uint iner;
          iner = find(_item,_from,false);
            if(keccak256(bytes(operation)) == keccak256(bytes("Sell"))&& keccak256(bytes(StatusItem[_item])) == keccak256(bytes("Selling"))){
              ItemTemplate ItemtoSell = ItemTemplate(_item);
              address ownerItem = ItemtoSell.ownerOf(ItemtoSell._id());
              if(TokenTemplate(UserLoaningItem[_from][iner].CoinSy).transfer(_to,UserLoaningItem[_from][iner].price,owner)){
                ItemtoSell.transfert(_to);
                require(ItemtoSell.ownerOf(ItemtoSell._id())==_to); 
                delete StatusItem[_item];
                delete UserLoaningItem[_from][iner]; 
              }

                return;
              }


          if( dateS>0 &&_to == ItemtoLoan.ownerOf(ItemtoLoan._id()) &&   keccak256(bytes(operation)) == keccak256(bytes("Riconsegna")) 

            && keccak256(bytes(Calendario.Available(ItemtoLoan._id()))) == keccak256(bytes("Busy"))){
            //riconsegna item
            if(Calendario.Back(ItemtoLoan._id(),dateS)){
            

          //  emit LoanPre(_from,_to,_item,Calendario.Time(),dateS,dateF,orders,"Back-Loan");
            return;
          }
            }
           /* else if(_to == ItemtoLoan.ownerOf(ItemtoLoan._id())  && keccak256(bytes(Calendario.Available(ItemtoLoan._id()))) == keccak256(bytes("Preordered"))){
              //caso in cui voglio cancellare una prenotazione
              return;
            }*/
            
            if(keccak256(bytes(operation)) == keccak256(bytes("Prenotazione")) && dateF>0 &&_from == ItemtoLoan.ownerOf(ItemtoLoan._id())){
              //prenotazione Noleggio pago la cauzione in anticipo   
             
                if(TokenTemplate(UserLoaningItem[_from][iner].CoinSy).balanceOf(_to)>=UserLoaningItem[_from][iner].caution ){
                  if(Calendario.Pre_Order(dateS,dateF,ItemtoLoan._id(),msg.sender)) {
                    TokenTemplate(UserLoaningItem[_from][iner].CoinSy).transfer(_to,UserLoaningItem[_from][iner].caution,_from);
                    CautionId[ItemtoLoan._id()].push(_to); 
                  //  emit ItemEvent(operation,address(0),_item,UserLoaningItem[_from][iner].CoinSy,0,0,"",address(0),address(0),Calendario.Time(),0,0);
                    PreItem memory Tempo = PreItem(_from,_to,_item,block.timestamp,dateS,dateF);
                    PreLItem[_to].push(Tempo);
                    return;
                  }
                return;
                }  
            return;
            }
              if(keccak256(bytes(operation)) == keccak256(bytes("RitiroPre")) /*&& PreLItem[OrderId].to == msg.sender*/){ 
                  if(TokenTemplate(UserLoaningItem[_from][iner].CoinSy).balanceOf(_to)>=UserLoaningItem[_from][iner].price ){
                    if(Calendario.AcquirePre(ItemtoLoan._id(),msg.sender) && _from==ItemtoLoan.ownerOf(ItemtoLoan._id())){ 
                  
                //emit LoanPre(_from,_to,_item,Calendario.Time(),dateS,dateF,orders,"Acq-Pre-Loan");
                    TokenTemplate(UserLoaningItem[_from][iner].CoinSy).transfer(_to,UserLoaningItem[_from][iner].price,_from);
                 
                    }
                  }
                  return;
                 
              }

              //noleggio sul momento
              if(dateF>0 && keccak256(bytes(operation)) == keccak256(bytes("OnFly")) && _from==ItemtoLoan.ownerOf(ItemtoLoan._id())){
              if(Calendario.Acquire(ItemtoLoan._id(),msg.sender,dateF)){
                CautionId[ItemtoLoan._id()].push(_to);
               // emit LoanPre(_from,_to,_item,Calendario.Time(),dateS,dateF,orders,"Normal-Loan");
              return;
            }
          }

          return;
      }
  
      

      function ReleseW(address _id,address _usr, uint256 _caution ) public{

        ItemTemplate ItemtoRelese = ItemTemplate(_id);
    //si potrebbe gestire il caso in cui la cauzione restituita sia variabile
        require(bytes(ItemtoRelese._name()).length > 0 ,"5");
        require(ItemtoRelese.ownerOf(ItemtoRelese._id())==msg.sender,"6");
       
       for(uint256 i; i<CautionId[ItemtoRelese._id()].length;i++){

              
        if(CautionId[ItemtoRelese._id()][i]==_usr && _usr!=msg.sender){
        Calendario.Relese(ItemtoRelese._id());
        address temp = CautionId[ItemtoRelese._id()][i];
        delete CautionId[ItemtoRelese._id()][i];
        delete StatusItem[_id];
        uint iner = find(_id,msg.sender,false);
        if(_caution>0){
        //approve
        TokenTemplate(UserLoaningItem[msg.sender][iner].CoinSy).transfer(msg.sender,_caution,_usr);
        }else{
        //approve
        TokenTemplate(UserLoaningItem[msg.sender][iner].CoinSy).transfer(msg.sender,UserLoaningItem[msg.sender][iner].caution,_usr);
      } 
        uint k;
          k = find(_id,_usr,true);
          delete PreLItem[_usr][k];


            }  
         }
       }
         
      
      /*
    function WaitingUsr(uint256 _id) public returns(address){
   
   for(uint256 i; i<Calendario.Orders();i++){
    if(CautionId[_id][i] != address(0x0)){
      i = Calendario.Orders();
      return CautionId[_id][i];

   }

    }
   return address(0x0);
    }*/
    }









