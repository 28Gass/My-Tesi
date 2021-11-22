
pragma solidity ^0.8.0;



contract Calendar   {
	
	  mapping(uint256=>mapping(uint256=>address)) public Preorderstart;
	  mapping(uint256=>mapping(uint256=>uint256)) public Preorderend;
    mapping(uint256 => string) public Available;
    uint256 time;
    uint256 fusoorario;
    uint256[] Status;

    mapping(uint256=>uint256[]) public PreorderOpen;
		    

 

	constructor() public { 
      



	}
  	function Time() internal {
        time = block.timestamp+ fusoorario;
      }


	function Pre_Order(uint256 dataStart, uint256 dataEnd, uint256 _id)  external returns(bool suc) {
    suc = false;
    time =block.timestamp-10 + fusoorario;
    require(time < dataStart,"Not possible in the past");
    uint256 date1 = Converter(dataStart,true);
    uint256 date2 = Converter(dataEnd,true);

		require(date1<date2,"<");//la prenotazione vale almeno se dura 4 ore
      
        if(CheckAvialable(_id,date1,date2)){
    PreorderOpen[_id].push(date1);
		Preorderstart[_id][date1]= msg.sender;
		Preorderend[_id][date1]=date2;	
		Available[_id]="Preordered";
				suc = true;
		}
		return suc;
		}

	function CheckAvialable(uint256 idA,uint256 _dataStart, uint256 _dataEnd) public returns(bool ret) {
		
				//in caso in cui sia occupato controllare se le date inserite sia valide per il preorder
		if(keccak256(bytes(Available[idA])) == keccak256(bytes("Preordered"))||keccak256(bytes(Available[idA])) == keccak256(bytes("Busy"))){
			ret = true;

				for(uint256 i=0; i < PreorderOpen[idA].length; i++){
				if( PreorderOpen[idA][i]>0 ){
					if((PreorderOpen[idA][i]<= _dataStart && _dataStart<=Preorderend[idA][PreorderOpen[idA][i]])
						|| (PreorderOpen[idA][i] == _dataStart) || (Preorderend[idA][PreorderOpen[idA][i]] == _dataStart)
						|| (PreorderOpen[idA][i] == _dataEnd )  || (Preorderend[idA][PreorderOpen[idA][i]] == _dataEnd)
						|| (PreorderOpen[idA][i] <= _dataEnd && _dataEnd<=Preorderend[idA][PreorderOpen[idA][i]])
						|| (PreorderOpen[idA][i]<= _dataEnd && _dataEnd<=Preorderend[idA][PreorderOpen[idA][i]])
						|| (_dataStart<= PreorderOpen[idA][i] && Preorderend[idA][PreorderOpen[idA][i]]<=_dataEnd)
						){
						ret = false;
						i = PreorderOpen[idA].length;
					}

				}
			}

		/*
			for(uint256 i=_dataStart;i <= _dataEnd;i= i + 14400){
				if(Preorderstart[idA][i]!=address(0x0) || Preorderend[idA][i]==i){
					ret =false;
					test="Sono Qui";

				}
			}*/
		}
		if(keccak256(bytes(Available[idA])) == keccak256(bytes("Available"))){
		ret = true;
		}
		return ret;

		//creare un evento per data suggerita nel caso l'item non sia disponibile

	}	
	function Update()internal {
				
			}
	function setAvailable(uint256 idA,string memory Status)public returns(bool){
	if(keccak256(bytes(Status)) == keccak256(bytes("Busy"))||keccak256(bytes(Status)) == keccak256(bytes("Available"))||keccak256(bytes(Status)) == keccak256(bytes("Waiting")) ){
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
function Relese(uint256 _id1) external{
	 require(keccak256(bytes(Available[_id1])) == keccak256(bytes("Waiting")));
	  bool k;
          k = setAvailable(_id1,"Available"); 
          require(k == true, "Non disponibile3");
}
function Converter(uint256 date, bool next)public returns(uint256){
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
function AcquirePre(uint256 _dateS,uint256 idP) public returns(bool ret){
	ret = false;
	Time();
  
  uint256 time1 = Converter(time,false);
//PreorderOpen verificare la data che ci sia come il proprietario del pre-ordine sia 
//quello giusto



}
	
}