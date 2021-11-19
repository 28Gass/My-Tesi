
pragma solidity ^0.8.0;



contract Calendar   {
	
	  mapping(uint256=>mapping(uint256=>address)) public Preorderstart;
	  mapping(uint256=>mapping(uint256=>uint256)) public Preorderend;
    mapping(uint256 => string) public Available;
    uint256 time;
    uint256 fusoorario;
    uint256[] Status;
    string public test;

    mapping(uint256=>uint256[]) public PreorderOpen;
		    

 

	constructor() public { 
      



	}


	function Pre_Order(uint256 dataStart, uint256 dataEnd, uint256 _id)  external {
    time =block.timestamp-10 + fusoorario;
    require(time < dataStart,"Not possible in the past");
    uint256 date1 = dataStart % 86400; //tempo mod giorni
    date1= date1 % 14400;  //mod 4 ore
		date1 = dataStart - date1 + 14400; //avro il giorno attuale + a mod di 4 ore
                               //es 6 nov - 0:00 - 4:00 - 8:00 - 12:00 - 16:00 ecc... 
                               //se sono le 17:11 la prenotazione sarà allo slot successivo
                               //alle 20
    uint256 date2 = dataEnd % 86400; //uguale a prima
    date2= date2 % 14400;            
		date2 = dataEnd - date2 +14400; 

		require(date1<date2,"<");//la prenotazione vale almeno se dura 4 ore
      
        if(CheckAvialable(_id,date1,date2)){
    PreorderOpen[_id].push(date1);
		Preorderstart[_id][date1]= msg.sender;
		Preorderend[_id][date1]=date2;	
		Available[_id]="Preordered";
				
		
				
		}}

	function CheckAvialable(uint256 idA,uint256 _dataStart, uint256 _dataEnd) public returns(bool ret) {
		
				//in caso in cui sia occupato controllare se le date inserite sia valide per il preorder
		if(keccak256(bytes(Available[idA])) == keccak256(bytes("Preordered"))){
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
						test="Sono Qui";
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

	
}