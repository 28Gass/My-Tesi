

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
  
  await deployer.deploy(LItemUtils,loanitem.address,litemcalend.address);
  const litemadd = await LItemUtils.deployed()

 
  
    //wait loanitem.addNewItem(1,"1","0.5")/*,"Primo Item"*/
    //await loanitem.addNewItem(1,"2","0.6")/*,"Secondo Item"*/
    //await loanitem.addNewItem(1,"3","0.7")/*,"terzo Item"*/
    //await loanitem.addNewItem(1,"4","0.8")/*,"Quarto Item"*/
    //await loanitem.addNewItem(10,"5","0.9")/*,"Quinto Item"*/

  //await loanitem.TrasferTest(accounts[0],accounts[1],0,1);

//await loanitem.uploadImage('abc123','Image description')




//await loanitem.GiveToken(accounts[1],1)





 

   


};


