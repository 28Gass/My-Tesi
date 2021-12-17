

const LItemUtils = artifacts.require("LItemUtils");
const LoanItem = artifacts.require("LoanItem")
const LItemCalendar = artifacts.require("Calendar");
const ipfsClient = require('ipfs-http-client')
const ipfs = ipfsClient({ host: 'ipfs.infura.io', port: 5001, protocol: 'https' }) // leaving out the arguments will default to these values


module.exports = async function(deployer,network, accounts) {
 
   await deployer.deploy(LItemCalendar);
  const litemcalend = await LItemCalendar.deployed();

  let account = await web3.eth.getAccounts();

  await deployer.deploy(LoanItem,accounts[0],litemcalend.address);
  const loanitem = await LoanItem.deployed();
  
  await deployer.deploy(LItemUtils);
  const litemadd = await LItemUtils.deployed()

  /*
    console.log("Address: " + loanitem.address)
    console.log("Address: " + litemadd.address)
    console.log("Address: " + litemcalend.address)*/

  //------------------------------------------------------------------------//



    await loanitem.addNewCoin(web3.utils.toWei("1000000", 'Ether'),"FToken","best Token",{from: account[0]});
    await loanitem.addNewItem(web3.utils.toWei("1", 'Ether'),web3.utils.toWei("0.5", 'Ether'),"1233","5att","Primo Item",1)/*,*/
    await loanitem.addNewItem(web3.utils.toWei("2", 'Ether'),web3.utils.toWei("0.5", 'Ether'),"1234","4att","Secondo Item",1)/*,*/
    await loanitem.addNewItem(web3.utils.toWei("3", 'Ether'),web3.utils.toWei("0.5", 'Ether'),"1235","3att","terzo Item",1)/*,""*/
    await loanitem.addNewItem(web3.utils.toWei("4", 'Ether'),web3.utils.toWei("0.5", 'Ether'),"1236","2att","Quarto Item",1)/*,""*/
    await loanitem.addNewItem(web3.utils.toWei("5", 'Ether'),web3.utils.toWei("0.5", 'Ether'),"1237","1att","Quinto Item",1)/*,*/

    
    await loanitem.GiveToken(account[1],1,web3.utils.toWei("1000000", 'Ether'),{from: account[0]})////100 FToken

    await loanitem.setApprovalForAll(account[1],true,{from: account[0]})


//_____Acquisto normale___________
     await litemadd.Time()
     let time = await litemadd.createtime()
     time = time.toNumber()
     time = time + 14400
     await loanitem.TrasferTest(account[0],account[1],2,1,1,0,time,{from: account[1]})

     time = time - 14400
     await loanitem.TrasferTest(account[1],account[0],2,0,0,time,0,{from: account[1]})

     await loanitem.setApprovalForAll(account[0],false,{from: account[1]})


     //await litemadd.AllWaiting()




  
    //wait loanitem.addNewItem(1,"1","0.5")/*,"Primo Item"*/
    //await loanitem.addNewItem(1,"2","0.6")/*,"Secondo Item"*/
    //await loanitem.addNewItem(1,"3","0.7")/*,"terzo Item"*/
    //await loanitem.addNewItem(1,"4","0.8")/*,"Quarto Item"*/
    //await loanitem.addNewItem(10,"5","0.9")/*,"Quinto Item"*/

  //await loanitem.TrasferTest(accounts[0],accounts[1],0,1);

//await loanitem.uploadImage('abc123','Image description')




//await loanitem.GiveToken(accounts[1],1)





 

   


};


