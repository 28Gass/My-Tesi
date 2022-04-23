
pragma solidity ^0.8.0;



contract Calendar   {
	 uint256 public time;
    uint256 fusoorario;
    //uint256[] Status;
    //uint256 public Orders;


	  mapping(uint256=>mapping(uint256=>address)) public Preorderstart;
	  mapping(uint256=>mapping(uint256=>uint256)) public Preorderend;
    mapping(uint256 => string) public Available;
    mapping(uint256=>uint256[]) public PreorderOpen;
  	mapping(uint256=>mapping(uint256=>uint256))public suppPreorderOpen;
  	mapping(address=>mapping(uint256=>OrdersInfo))internal AllInfo;

  	struct OrdersInfo{
  		uint256[] AllDates;
  		mapping(uint256=>uint256) supportDate;
  		mapping(uint256=>OrderData) data;
  	}

	  struct OrderData{
	  	uint256 id;
	  	uint256 dataSt;
	  	uint256 dataEn;
	  	address usr;
	  }	


	constructor() public { 
      

	}
  	function Time() public returns(uint256) {
        time = block.timestamp/*+ fusoorario*/;
        return time;
      }
   
      /*function TimeAdd(uint256 i) public {
        
        time = time + i;
      }*/

	function Pre_Order(uint256 dataStart, uint256 dataEnd, uint256 _id,address _usr,address owner)  external returns(bool suc) {
	    Time();
	    if(dataStart==0){
	    dataStart= time;
	  	}
	    suc = false;
	   	require(dataEnd>0,"dataEnd is 0");
	    require(time <= dataStart,"Not possible in the past");
	    require(dataEnd<= time + 2592000,"more than 30gg" );
	    require(dataStart<dataEnd);
	    uint256 date1 = Converter(dataStart,true);
	    uint256 date2 = Converter(dataEnd,true);
			require(date1<date2,"<");//la prenotazione vale almeno se dura 4 ore
	     // if(_id>Orders)
	     //   Orders= _id;
	        if(CheckAvialable(_id,date1,date2)){
		        AllInfo[owner][_id].AllDates.push(date1);
		        AllInfo[owner][_id].supportDate[date1]= AllInfo[owner][_id].AllDates.length -1;
		        OrderData memory temp =OrderData(_id,date1,date2,_usr);
		        AllInfo[owner][_id].data[date1]= temp;
				    PreorderOpen[_id].push(date1);
						suppPreorderOpen[_id][date1]= PreorderOpen[_id].length -1;
						Preorderstart[_id][date1]= _usr;
						Preorderend[_id][date1]=date2;
					if(keccak256(bytes("Available"))==keccak256(bytes(Available[_id])))	
					Available[_id]="Preordered";
							suc = true;
					}
				return suc;
			}

	function CheckAvialable(uint256 idA,uint256 _dataStart, uint256 _dataEnd) public returns(bool ret) {
		
				//in caso in cui sia occupato controllare se le date inserite sia valide per il preorder
		if(keccak256(bytes(Available[idA])) == keccak256(bytes("Preordered"))
			||keccak256(bytes(Available[idA])) == keccak256(bytes("Busy")) 
			|| keccak256(bytes(Available[idA])) == keccak256(bytes("Waiting")) 
			|| keccak256(bytes(Available[idA]))== keccak256(bytes("Available"))){
			ret = true;

				for(uint256 i=0; i < PreorderOpen[idA].length; i++){
				if( PreorderOpen[idA][i]>0 && Preorderstart[idA][PreorderOpen [idA][i]] != address(0x0)){
					if((PreorderOpen[idA][i]<= _dataStart && _dataStart<=Preorderend[idA][PreorderOpen[idA][i]])
						|| (PreorderOpen[idA][i] == _dataStart) || (Preorderend[idA][PreorderOpen[idA][i]] == _dataStart)
						|| (PreorderOpen[idA][i] == _dataEnd )  || (Preorderend[idA][PreorderOpen[idA][i]] == _dataEnd)
						|| (PreorderOpen[idA][i] <= _dataEnd && _dataEnd<=Preorderend[idA][PreorderOpen[idA][i]])
						|| (PreorderOpen[idA][i]<= _dataEnd && _dataEnd<=Preorderend[idA][PreorderOpen[idA][i]])
						|| (_dataStart<= PreorderOpen[idA][i] && Preorderend[idA][PreorderOpen[idA][i]]<=_dataEnd)
						){
						i = PreorderOpen[idA].length;
						ret = false;
						return ret;						
					}

				}
			}


		}
		if(keccak256(bytes(Available[idA])) == keccak256(bytes("Available"))){
		ret = true;
		}
		return ret;

		//creare un evento per data suggerita nel caso l'item non sia disponibile

	}	
	function deleteOrder(uint256 dataStart,address owner, uint256 _id)public{

		    uint256[] storage temprem = AllInfo[owner][_id].AllDates;
		    delete temprem[AllInfo[owner][_id].supportDate[dataStart]];

		    AllInfo[owner][_id].AllDates=temprem;
		    AllInfo[owner][_id].supportDate[dataStart];
       
	}
 function getAllOrder(address owner,uint256 _id)public returns(uint256[] memory){

 	return AllInfo[owner][_id].AllDates;
 }

 function getOrderInfo(address owner,uint256 _id,uint256 dataStart)public returns(uint256,uint256,address){

 			return( AllInfo[owner][_id].data[dataStart].dataSt,AllInfo[owner][_id].data[dataStart].dataEn,AllInfo[owner][_id].data[dataStart].usr);
 }


	function setAvailable(uint256 idA,string memory Status)public returns(bool){
	if(keccak256(bytes(Status)) == keccak256(bytes("Busy"))||keccak256(bytes(Status)) == keccak256(bytes("Available"))||keccak256(bytes(Status)) == keccak256(bytes("Waiting"))||keccak256(bytes(Status)) == keccak256(bytes("Preordered")) ){
			Available[idA]=Status;
			return true;
		
		}
		return false;

			}				
function setFusoOraio()public{
	if (fusoorario==0){
		fusoorario= 3600;
	}
	else{
		fusoorario=0;
	}
}
function Back(uint256 _id1,uint256 _dateS) external returns(bool){

	_dateS = Converter(_dateS,false);
    require(Preorderend[_id1][_dateS]>0,"Errore");
	 if(keccak256(bytes(Available[_id1])) == keccak256(bytes("Busy"))&& _dateS>0){
	  bool k;
          k = setAvailable(_id1,"Waiting"); 
         if(k){
         delete	Preorderstart[_id1][_dateS];
				 delete Preorderend[_id1][_dateS];
				 uint256 i = suppPreorderOpen[_id1][_dateS];
				 	if(PreorderOpen[_id1][i]==_dateS){
				 		delete PreorderOpen[_id1][i];
				 		delete suppPreorderOpen[_id1][_dateS];
				 		return true;
				 	}
         } 
       }
       return false;
}
function Converter(uint256 date, bool next)public view virtual returns(uint256){
     uint256 lest;
     if(next)
     lest = 14400;
    uint256 date1 = date % 86400; //tempo mod giorni
    date1= date1 % 14400;  //mod 4 ore
		date1 = date - date1 + lest; //avro il giorno attuale + a mod di 4 ore
                               //es 6 nov - 0:00 - 4:00 - 8:00 - 12:00 - 16:00 ecc... 
                               //se sono le 17:11 la prenotazione sarà allo slot successivo
                               //alle 20
                               return date1;
}
function AcquirePre(uint256 idP,address usr,uint256 _dateS) public   returns(bool ret){
	ret = false;
  Time();
  			uint256 i = suppPreorderOpen[idP][_dateS];
  			if(Preorderstart[idP][PreorderOpen[idP][i]]==usr ){
  				if( time>=PreorderOpen[idP][i] && ((keccak256(bytes(Available[idP])) == keccak256(bytes("Available")))
  					|| keccak256(bytes(Available[idP])) == keccak256(bytes("Preordered")))){
  				Available[idP]="Busy";							
  				return true;}
  		}
	return ret;
}
function Acquire(address owner,uint256 idP,address usr,uint256 _dataF) public   returns(bool ret){
  Time();
		 uint256 dateSt = Converter(time,false);
   	 _dataF = Converter(_dataF,true);
 				if(_dataF>time && CheckAvialable(idP,dateSt,_dataF)){
        AllInfo[owner][idP].AllDates.push(dateSt);
        AllInfo[owner][idP].supportDate[dateSt]= AllInfo[owner][idP].AllDates.length -1;
        OrderData memory temp =OrderData(idP,dateSt,_dataF,usr);
        AllInfo[owner][idP].data[dateSt]= temp;
         bool k;
      k =  setAvailable(idP,"Busy"); 
      require(k == true, "Non disponibile2");
   		PreorderOpen[idP].push(dateSt);
   		Preorderstart[idP][dateSt]= usr;
		  Preorderend[idP][dateSt]=_dataF;
      return true;
}

return false;}

	
	function preOrderOpenGet(uint256 i) external  view virtual returns(uint256[] memory){
     
  return  PreorderOpen[i];
	}
  function Relese(uint256 _id1) external{
  	

	// require(keccak256(bytes(Available[_id1])) == keccak256(bytes("Waiting")),"Ma cosa");
	  bool k;
	  if(!(CheckAvialable(_id1,time-90000,time+2592000))){//dataS -1 un giorno, dataE + 30gg 
           k = setAvailable(_id1,"Preordered");
          require(k == true, "Non disponibile3");
          }else{
          k = setAvailable(_id1,"Available"); 
          require(k == true, "Non disponibile3");}
}
}
