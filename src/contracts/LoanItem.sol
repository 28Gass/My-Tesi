// contracts/LoanItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import"./LitemCalendar.sol";
contract LoanItem is ERC1155{
    
    string public name = "LoanItem";
    string  public symbol = "LI";
    Calendar Calendario;
    
    address[] public stakers;
    mapping(address => uint) public stakingBalance;
    mapping(address => bool) public hasStaked;
    mapping(address => bool) public isStaking;
    
   
     mapping(uint => Image)public images;
     mapping(uint => TokenNFT)public tokenId;
     mapping(uint256=>address[]) public CautionId;
     mapping(uint256 => uint256) public ids;

     mapping(address => bool) public permissions;

     mapping(uint256 => CoinFT) public CoinId;
     mapping(uint256 => uint256) public Cds;
   


    struct Image {
      uint id;
      string hash;
      string description;
      uint tokenId;
      address author;
    }

    event ImageCreated(
      uint id,
      string hash,
      string description,
      uint tokenId,
      address  author
      );

     struct TokenNFT {
      uint id;
      Image  phots;
      string description;
      string namet;
      uint256 pricel;
      uint256 caution;
      uint256 Cid;
      
    }
    event TokenNFTCreated(
      uint id,
      Image  phots,
      string description,
      string namet,
      uint256 pricel,
      uint256 caution,
      uint256 Cid
      );

     struct CoinFT {
      uint id;
      //Image  phots;
      string description;
      string namec;
    }
    event CoinFTCreated(
      uint id,
      //Image  phots,
      string description,
      string namec
      );


    uint256 public countAttrezzi;
    uint256 public imageCount;
    address public owner;
   

  constructor(address _owner,Calendar Cad) public ERC1155("") {  
         owner = _owner;
         permissions[owner]= true;
         Calendario = Cad;
         }
    


 // function addMoreCoin()public{}


  function addNewCoin( uint256 value,string memory Name,string memory description )external {
          require (msg.sender == owner || permissions[msg.sender]== true , "Solo il proprietario");
          require(bytes(Name).length>0);
          require(value>0);
          countAttrezzi++;
         _mint(msg.sender, countAttrezzi, value, "");
          Cds[countAttrezzi]= countAttrezzi;
          CoinId[countAttrezzi]= CoinFT(countAttrezzi,description,Name);
          emit CoinFTCreated(countAttrezzi,description,Name);
      } 



    modifier propriety(){ 

        require (msg.sender == owner || permissions[msg.sender]== true , "Solo il proprietario");       
        _;
    }
      function setPermissions(address ute,bool setting) external propriety {

      
        permissions[ute]= setting;

      }
    

      function addNewItem(uint256 price,uint256 caution,string memory _imgHash,string memory _description, string memory namef,uint256 Cid) external propriety {
     
      
        require(caution > 0);
        require(bytes(namef).length > 0);
        require((price) > 0);
        require(bytes(_description).length > 0);
        require(bytes(_imgHash).length > 0);
        require(msg.sender != address(0x0));
        require(bytes(CoinId[Cid].namec).length > 0,"Coin Not exist");//controllo che il coin esiste aggiungere che il coin esiste

        imageCount ++;
        countAttrezzi++;
       
        Calendario.setAvailable(countAttrezzi,"Available"); 
     

      
        ids[countAttrezzi]=countAttrezzi;
          
        _mint(msg.sender, ids[countAttrezzi], 1, "");
  
  
        images[imageCount] = Image(imageCount,_imgHash,_description,0,owner);
        tokenId[countAttrezzi] = TokenNFT(countAttrezzi,images[imageCount],_description,namef,price,caution,Cid);
        //causa l'evento 
        emit ImageCreated(imageCount,_imgHash,_description,0,owner);
        emit TokenNFTCreated(countAttrezzi,images[imageCount],_description,namef,price,caution,Cid);    
    }
   
      function TrasferTest(address _from, address _to, uint256 _id,bool pre,bool acq,uint256 dateS,uint256 dateF) external {

        //aggiungere il metodo che controlla le prenotazioni 

          //require(address(_from)!=address(0x0), "address _from is 0x0");
          //require(address(_to)!=address(0x0), "address _to is 0x0");
          require(keccak256(bytes(tokenId[_id].namet))> 0, "token not true");  
          require(keccak256(bytes(Calendario.Available(_id))) != keccak256(bytes("Waiting")),"token is waiting ");
          
          if(dateS>0 &&_to == owner  && keccak256(bytes(Calendario.Available(_id))) == keccak256(bytes("Busy"))){
            //riconsegna item
            if(Calendario.Back(_id,dateS)){
            safeTransferFrom( _from,_to, _id,1,"");
            //CautionId[_id].push(_from);
            return;
          }
            }
            else if(_to == owner  && keccak256(bytes(Calendario.Available(_id))) == keccak256(bytes("Preordered"))){
              //caso in cui voglio cancellare una prenotazione
              return;
            }
            else if(_from == owner/*&& Calendario.CheckAvialable()*/){
              if(pre && !(acq) && dateF>0){//preOrder pago la cauzione in anticipo
                      
                if(Calendario.Pre_Order(dateS,dateF,_id,msg.sender)) {
                 safeTransferFrom( _to,_from,tokenId[_id].Cid,tokenId[_id].caution,"");
                 CautionId[_id].push(_to);
                 return;
              }
                return;
            }
              if(acq && !(pre)){ 

                for(uint256 i; i < CautionId[_id].length;i++){
                if(CautionId[_id][i]== msg.sender){
                //per fare l'acquire di un oggetto prenotato devo verificare la data inizio
                //e poi pagare l'oggetto 
                if(Calendario.AcquirePre(_id,msg.sender)){
                   safeTransferFrom( _to,_from,tokenId[_id].Cid,tokenId[_id].pricel,"");
                   safeTransferFrom( _from,_to, _id,1,"");
                    return;
              }}}
                
              }

              //in caso di acquisto normale 
              if(dateF>0 && acq && pre){
              if(Calendario.Acquire(_id,msg.sender,dateF)){
              safeTransferFrom( _to,_from,tokenId[_id].Cid,tokenId[_id].pricel+tokenId[_id].caution,"");  
              safeTransferFrom( _from,_to, _id,1,"");
              CautionId[_id].push(_to);
            }}}
          return;
      }
  
      
      function GiveToken(address _to,uint256 coin,uint256 value) external propriety {
        safeTransferFrom( msg.sender,_to, coin,100000000000000000000,"");
      }

      function ReleseW(uint256 _id,address _usr, uint256 _caution )  external propriety{
    //si potrebbe gestire il caso in cui la cauzione restituita sia variabile
        require(_id>0,"");
        require(_id<=countAttrezzi,"item not exists");
        require(ids[_id]>0,"Token not exists" );
       

       
       for(uint256 i; i<CautionId[_id].length;i++){
        if(CautionId[_id][i]==_usr && _usr!=msg.sender){
        safeTransferFrom( msg.sender,_usr, tokenId[_id].Cid, tokenId[_id].caution,"");
        Calendario.Relese(_id);
        delete CautionId[_id][i];
         return;
         }}
         
      }
    
   
    }









