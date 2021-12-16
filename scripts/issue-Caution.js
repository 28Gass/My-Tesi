const LoanItem = artifacts.require('LoanItem')
const LItemUtils = artifacts.require('LItemUtils')
const LItemCalendar = artifacts.require("Calendar");

module.exports = async function(callback) {
  let account = await web3.eth.getAccounts();
  let loanitem = await LoanItem.deployed()
  let litemutils = await LItemUtils.deployed()
  const litemcalend = await LItemCalendar.deployed();
 
 await litemutils.Time()
 let ter = await litemutils.createtime()

/* 
console.log(loanitem.address)
console.log(litemutils.address)
console.log(litemcalend.address)*/







  let g = await loanitem.countAttrezzi()
  let i = 0  
  let arr

   for(; i < g;i++){
    l = await litemcalend.Available(i)
    if(l=="Waiting"){
      console.log("Item "+ i + ":" + " Waiting" + '\n'  )
   
    }
 }   
  //let caution = await litemutils.WaitingUsr(k)
  //console.log("hELLO: " + caution)

/*
let k=0
let jh = await litemcalend.Orders()
 for(;k < g; k++ ){
    let caution = await litemutils.WaitingUsr(k)
      if(caution!="0x0000000000000000000000000000000000000000") {
        await loanitem.ReleseW(k,caution,0)
      }

 }*/
   



  //await loanitem.ReleseW()
  // Code goes here...
  
  callback()
 }

