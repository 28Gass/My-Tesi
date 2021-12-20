// contracts/LoanItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import"./LitemCalendar.sol";
import"./ItemTemplate.sol";
contract LoanItem {
    
    
    Calendar Calendario;
    
  
     mapping(address => bool) public permissions;
     mapping(uint256 => uint256) public Cds;
  
     mapping(address =>Selling[]) public UserSellingItem;
     mapping(uint256=>Selling) public SellingItem;
     mapping(address=>bool) public SellItem;
     uint256 countitem;
     uint256 orders;


     mapping(address =>LItem[]) public UserLoaningItem;
     mapping(address=>bool) public LoanItem;

     mapping(uint256=>PreItem)public PreLItem;
     mapping(uint256=>address[]) public CautionId;

    address public owner;

  struct LItem{
    ItemTemplate Item;
    address addr;
    uint CoinId;
    uint256 price;
    uint256 caution;
    string place;
    } 
    event LoanCreated(
    ItemTemplate Item,
    address addr,
    uint CoinId,
    uint256 price,
    uint256 caution,
    string place,
    uint time
      );
  struct PreItem{
    address from;
    address to;
    address item;
    uint time;
    uint timeS;
    uint timeE;
    uint idOrder;
  }

  event LoanPre(
    address from,
    address to,
    address item,
    uint time,
    uint timeS,
    uint timeE,
    uint idOrder,
    string staus
     );
  

  struct Selling {
    ItemTemplate Item;
    address addr;
    uint256 CoinId;
    uint256 price;
    string  place;
  }
  event SellingCreated(
    ItemTemplate Item,
    address addr,
    uint256 CoinId,
    uint256 price,
    string  place,
    uint256 time
  );
  event SoldItem(
    address from,
    address to,
    uint256 price,
    uint256 time,
    address itemaddr
    );


  constructor(address _owner,Calendar Cad) public  {  
         owner = _owner;
         permissions[owner]= true;
         Calendario = Cad;
         }
    

/*
    modifier propriety(){ 

        require (msg.sender == owner || permissions[msg.sender]== true , "Solo il proprietario");       
        _;
    }*/
     
    function SellIt(address itemaddr,address buyer) public{
      ItemTemplate ItemtoSell = ItemTemplate(itemaddr);
      require(bytes(ItemtoSell._name()).length > 0 );

      if(SellItem[itemaddr]==true){
        address ownerItem = ItemtoSell.ownerOf(ItemtoSell._id());
        ItemtoSell.transfert(buyer);
        require(ItemtoSell.ownerOf(ItemtoSell._id())==buyer); 
        SellItem[itemaddr]=false;
        for(uint i; i <= countitem; i++){
          if(SellingItem[i].addr==itemaddr){
            emit SoldItem(ownerItem,ItemtoSell.ownerOf(ItemtoSell._id()),SellingItem[i].price,Calendario.Time(),itemaddr);
           delete SellingItem[i];
          }
        }
        for(uint i; i< UserSellingItem[ownerItem].length; i++ ){
          if( UserSellingItem[ownerItem][i].addr== itemaddr){
            delete UserSellingItem[ownerItem][i];
          }
      }

    }
  }
    function AddToSellItem(address itemaddr,uint Price, string memory PLace) public 
                                                                             {
      ItemTemplate ItemtoSell = ItemTemplate(itemaddr);

      require(bytes(ItemtoSell._name()).length > 0 );
      require(ItemtoSell.ownerOf(ItemtoSell._id())==msg.sender);
      require(LoanItem[itemaddr]==false,"L'oggetto e in noleggio");      
      Selling memory Temp = Selling(ItemtoSell,itemaddr,0,Price,PLace);
      UserSellingItem[msg.sender].push(Temp);
      countitem++;
      SellingItem[countitem]= Temp;
      SellItem[itemaddr]=true;
  
      emit SellingCreated(ItemtoSell,itemaddr,0,Price,PLace,Calendario.Time());
     
    } 


     function AddToLoanItem(address itemaddr,uint Price,uint caution,uint CoinId, string memory PLace) public 
                                                                             {
      ItemTemplate ItemtoLoan = ItemTemplate(itemaddr);

      require(bytes(ItemtoLoan._name()).length > 0,"1" );
      require(ItemtoLoan.ownerOf(ItemtoLoan._id())==msg.sender,"2");
      
      require(LoanItem[itemaddr]==false,"L'oggetto e in vendita");
      
      LItem memory Temp = LItem(ItemtoLoan,itemaddr,CoinId,Price,caution,PLace);
      UserLoaningItem[msg.sender].push(Temp);
      countitem++;
      
      LoanItem[itemaddr]=true;
      Calendario.setAvailable(ItemtoLoan._id(),"Available");
      emit LoanCreated(ItemtoLoan,itemaddr,0,Price,caution,PLace,Calendario.Time());
     
    } 

   
      function TrasferTest(address _from, address _to,address _item,bool pre,bool acq,uint256 dateS,uint256 dateF,uint256 OrderId) external {

        //aggiungere il metodo che controlla le prenotazioni 
          ItemTemplate ItemtoLoan = ItemTemplate(_item);
          //require(address(_from)!=address(0x0), "address _from is 0x0");
          //require(address(_to)!=address(0x0), "address _to is 0x0");
          require(bytes(ItemtoLoan._name()).length > 0 );
          require(keccak256(bytes(Calendario.Available(ItemtoLoan._id()))) != keccak256(bytes("Waiting")),"token is waiting ");
          
        
          if(PreLItem[OrderId].to==msg.sender &&dateS>0 &&_to == ItemtoLoan.ownerOf(ItemtoLoan._id()) &&!(acq) && !(pre)   && keccak256(bytes(Calendario.Available(ItemtoLoan._id()))) == keccak256(bytes("Busy"))){
            //riconsegna item
            if(Calendario.Back(ItemtoLoan._id(),dateS)){
            

            emit LoanPre(_from,_to,_item,Calendario.Time(),dateS,dateF,orders,"Back-Loan");
            return;
          }
            }
            else if(_to == ItemtoLoan.ownerOf(ItemtoLoan._id())  && keccak256(bytes(Calendario.Available(ItemtoLoan._id()))) == keccak256(bytes("Preordered"))){
              //caso in cui voglio cancellare una prenotazione
              return;
            }
            else if(_from == ItemtoLoan.ownerOf(ItemtoLoan._id())){
              if(pre && !(acq) && dateF>0){
              //prenotazione Noleggio pago la cauzione in anticipo
                      
                if(Calendario.Pre_Order(dateS,dateF,ItemtoLoan._id(),msg.sender)) {

                //UserLoaning[ItemtoLoan._id()].push(msg.sender);
                  //-------------TRANSAZIONE PER LA CAUZIONE-------DA FARE------------
                 CautionId[ItemtoLoan._id()].push(_to);
                 orders++;
                 PreLItem[orders]= PreItem(_from,_to,_item,Calendario.Time(),dateS,dateF,orders);
                 emit LoanPre(_from,_to,_item,Calendario.Time(),dateS,dateF,orders,"Pre-Loan");

                 return;
              }
                return;
            }
              if(!(pre)&& acq && PreLItem[OrderId].to == msg.sender){ 
                  
                    if(Calendario.AcquirePre(ItemtoLoan._id(),msg.sender) && _from==ItemtoLoan.ownerOf(ItemtoLoan._id())){ 
                   //---------pagare il resto dell'oggetto mi serve il coin
                emit LoanPre(_from,_to,_item,Calendario.Time(),dateS,dateF,orders,"Acq-Pre-Loan");
                    return;
                    }
                  
                 
              }

              //noleggio sul momento
              if(dateF>0 && acq && pre && _from==ItemtoLoan.ownerOf(ItemtoLoan._id())){
              if(Calendario.Acquire(ItemtoLoan._id(),msg.sender,dateF)){
                CautionId[ItemtoLoan._id()].push(_to);
                emit LoanPre(_from,_to,_item,Calendario.Time(),dateS,dateF,orders,"Normal-Loan");
            }}}
          return;
      }
  
      

      function ReleseW(address _id,address _usr, uint256 _caution, uint256 orderId ) public{

        ItemTemplate ItemtoRelese = ItemTemplate(_id);
    //si potrebbe gestire il caso in cui la cauzione restituita sia variabile
        require(bytes(ItemtoRelese._name()).length > 0 );
        require(ItemtoRelese.ownerOf(ItemtoRelese._id())==msg.sender);
       
       for(uint256 i; i<CautionId[ItemtoRelese._id()].length;i++){

        //----------------transazione per la resistuzione della cauzione
        if(CautionId[ItemtoRelese._id()][i]==_usr && _usr!=msg.sender){
        Calendario.Relese(ItemtoRelese._id());
        address temp = CautionId[ItemtoRelese._id()][i];
        delete CautionId[ItemtoRelese._id()][i];
        delete LoanItem[_id];
        if(PreLItem[orderId].to==_usr){
          delete PreLItem[orderId];
          for(uint256 k; k < UserLoaningItem[_usr].length;k++){
            if(UserLoaningItem[_id][k].addr==_id){
              delete UserLoaningItem[_id][k];
              return;
            }

          }
        }


         
         }}
         
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









