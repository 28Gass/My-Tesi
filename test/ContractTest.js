
const LoanItem = artifacts.require("LoanItem");
const LItemUtils = artifacts.require("LItemUtils");
const LItemCalendar = artifacts.require("Calendar");
const TokenTemplate = artifacts.require("ItemTemplate")
const Itemfarm = artifacts.require("ItemFarm");

contract('ItemFarm', (owner) => {
 let loanitem
 let operator
 let aprove
 let calendar
 let itemfarm
const ipfsClient = require('ipfs-http-client')
const ipfs = ipfsClient({ host: 'ipfs.infura.io', port: 5001, protocol: 'https' }) // leaving out the arguments will default to these va
 	before(async()=> {
 	//LOAD Contracts
 	let account = await web3.eth.getAccounts()
    calendar= await  LItemCalendar.new()
    loanitem = await LoanItem.new(account[0],calendar.address)
    litemadd = await LItemUtils.new()
    
    itemfarm = await Itemfarm.new()

   
   

    await itemfarm.addNewItem("1233","5att","Primo Item",account[0],"")
    await itemfarm.addNewItem("1234","4att","Secondo Item",account[0],"")
    await itemfarm.addNewItem("1235","3att","terzo Item",account[1],"")
    await itemfarm.addNewItem("1236","2att","Quarto Item",account[2],"",{from: account[2]})
    await itemfarm.addNewItem("1237","1att","Quinto Item",account[2],"")
   
    })
    describe('Erc721 ', async()=>{
      it('has created', async () => {
        let account = await web3.eth.getAccounts()
        let NFT = await itemfarm.getAllTokenAddresses()

        assert.equal(NFT.length,5)

       const Result = await itemfarm.getItemByID(1)
       let {0: Name, 1: Description, 2: Image, 3: Url }  = Result 
       let owner = await itemfarm.getOwnerById(1)

       assert.equal(Name,"Primo Item")
       assert.equal(Description,"5att")        
       assert.equal(Image,"1233")
       assert.equal(Url,"data:application/json;base64,eyJuYW1lIjpQcmltbyBJdGVtIiwiZGVzY3JpcHRpb24iOjVhdHQiLCJJbWFnZSI6MTIzMyIsImlkIjoAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAASIsIk93bmVyIjox0Z5+ApYWMWHpLv/UbrjbbZm83SIsfSw=/1G64222ZvN0iLH0=")
       assert.equal(owner, account[0])
               })
      it('Add and Sell', async () => {
        let account = await web3.eth.getAccounts()
        let NFT = await itemfarm.getAllTokenAddresses()

        let tester = await loanitem.SellItem(NFT[0])
        assert.equal(tester,false)
        
        const Result = await itemfarm.getItemByID(1)
        let {0: Name, 1: Description, 2: Image, 3: Url }  = Result 
        let owner = await itemfarm.getOwnerById(1)
        assert.equal(owner,account[0])

        await loanitem.AddToSellItem(NFT[0],5,"Casa Mia",{from: account[0]})

        tester = await loanitem.SellItem(NFT[0])
        assert.equal(tester,true)
        
        await loanitem.SellIt(NFT[0],account[1])

       const Result2 = await itemfarm.getItemByID(1)
        let {0: Name2, 1: Description2, 2: Image2, 3: Url2 }  = Result

        owner = await itemfarm.getOwnerById(1)
        assert.equal(owner,account[1])

        tester = await loanitem.SellItem(NFT[0])
        assert.equal(tester,false)

    
})
      it('AddLoan', async () => {
        let account = await web3.eth.getAccounts()
        let NFT = await itemfarm.getAllTokenAddresses()



        await loanitem.AddToLoanItem(NFT[3],5,2,0,"Casa Mia",{from: account[2]})

        let result = await loanitem.LoanItem(NFT[3])
        assert.equal(result,true)

        result = await calendar.Available(4)
        assert.equal(result,"Available")
      })
       it('Pre-LoanItem ', async () => {
        let account = await web3.eth.getAccounts()
        let NFT = await itemfarm.getAllTokenAddresses()

             await calendar.Time()
             let time = await calendar.time()
            let timend = time.toNumber()
            timend = timend  + 72000
            time = time.toNumber()
            time = time + 28800         

        await loanitem.TrasferTest(account[2],account[3],NFT[3],true,false,time,timend,0,{from:account[3]})

        let result = await calendar.Available(4)
        assert.equal(result,"Preordered")

        let jkl = await loanitem.CautionId(4,0)
        assert.equal(jkl,account[3])
       // jkl = await loanitem.UserLoaning(4,0)
       // assert.equal(jkl,account[3])

        
        let tesf = await itemfarm.Urltest(NFT[3])

        console.log("Ciao Gesù "+ tesf)

         


       })
   it('Acquire-LoanItem ', async () => {
          //provo ad acquisire l'ordine dopo aver prenotato ed nel momento in cui arriva l'ora
          //per far funzionare il test manipolo l'ora quindi bisogna commentare Time() in AcquirePre e 
          //togliere i commenti in timeAdd() e commentare update()

          /*     let account = await web3.eth.getAccounts()
          let NFT = await itemfarm.getAllTokenAddresses()          

          await calendar.TimeAdd(50000)

          await loanitem.TrasferTest(account[2],account[3],NFT[3],false,true,0,0,1,{from:account[3]})

          let result = await calendar.Available(4)
          assert.equal(result,"Busy")*/

      
        })
        it('Back-LoanItem ', async () => {
       /*   let account = await web3.eth.getAccounts()
          let NFT = await itemfarm.getAllTokenAddresses() 
          
          let time = await calendar.time()
          time  = time.toNumber()
          time = time + 28800

          let improve = await calendar.Converter(time,true)

          await loanitem.TrasferTest(account[3],account[2],NFT[3],false,false,improve,0,1,{from:account[3]})

           let result = await calendar.Available(4)
          assert.equal(result,"Waiting")*/

        })
        it('Relese-LoanItem ', async () => {
        /*  let account = await web3.eth.getAccounts()
          let NFT = await itemfarm.getAllTokenAddresses() 

          await loanitem.ReleseW(NFT[3],account[3],0,1,{from:account[2]})

          let result = await calendar.Available(4)
          assert.equal(result,"Available")         

          result = await loanitem.CautionId(4,0)
          assert.equal(result,"0x0000000000000000000000000000000000000000")

          result = await loanitem.LoanItem(NFT[3])
          assert.equal(result,false)

          
          //result = await loanitem.PreLItem(1).to()   
          //assert.equal(result,"0x0000000000000000000000000000000000000000")  

          //result = await loanitem.UserLoaningItem(1,0).addr()
          //assert.equal(result,"0x0000000000000000000000000000000000000000")   */   

        })
      })
      /*  describe('Time Test', async()=>{
         it('time ',async()=>{
             await litemadd.Time()
             let time = await litemadd.createtime()
             console.log("            "+time.toString())
async function test() {
             console.log("            +"+'start timer');
  await new Promise(resolve => setTimeout(resolve, 2000));
             console.log("            +"+'after 2 second');
  await litemadd.Time()
              time = await litemadd.createtime()
             console.log("            +"+time.toString())
}
await test();
    

 })
         it('time adding test',async()=>{
            await litemadd.setFusoOraio()
            await litemadd.Time()
            let time = await litemadd.createtime()
            let account = await web3.eth.getAccounts()
             let timend = time.toNumber() 
              timend = timend + 10
              time = time.toNumber()
              time = time  //fuso orario
              console.log("           time:   "+time)
              console.log("           timend: "+timend)
             
           //await loanitem.Preorder(time,timend,5)
            
            //let teme1 = await loanitem.Preorderstart(5,time)
            //assert.equal(teme1,account[0])

            //teme1 = await loanitem.Preorderstart(5,time+1)
            //assert.equal(teme1,account[0])

            teme2 = await litemadd.createtime()
       

            let test = time % 86400 //secondi in 24 ore
            let test1 = test % 14400 //secondi in 4 ore

            console.log("           divisione giorni:   "+test)
            console.log("           divisione in 4 ore: "+test1 )
           
           test = time - test
            console.log("           giorno attuale a mezza notte:     "+test)
           let test2 = time - test1 
           console.log("           giorno attuale a diviso a 4 ore:  "+test2)
            test1 =test2 + 14400
           console.log("           giorno attuale allo slot successivo:  "+test1)
            // await new Promise(resolve => setTimeout(resolve, 4000));

            })
        
         })

describe('TEST PRE-ORDINI Calendar', async()=>{
         it('Test Pre-Order item 8',async()=>{
            await litemadd.Time()
            let time = await litemadd.createtime()
            let account = await web3.eth.getAccounts()
            let timend = time.toNumber()
            timend = timend  + 72000
            time = time.toNumber()
            time = time + 28800 

            let Ava = await calendar.Available(1)
            assert.equal(Ava,"")

            Ava = await calendar.Available(8)
            assert.equal(Ava,"Available")

            await calendar.Pre_Order(time,timend,8,account[0])

            Ava = await calendar.Available(8)
            assert.equal(Ava,"Preordered")


            let date1 = time % 86400
            date1 = date1 % 14400
            date1 = time - date1 + 14400

            //console.log("data Inizio :" + date1)
  
            let date2 = timend % 86400
            date2 = date2 % 14400
            date2 = timend - date2 + 14400


            let set = await calendar.Preorderstart(8,date1)
            assert.equal(set,account[0])
            set = await calendar.Preorderend(8,date1)
            assert.equal(set,date2)
            //prenotazione riuscita
        
         
             
        

         })
           it('Provo a prenotare item 8 con le stesse date',async()=>{
            let account = await web3.eth.getAccounts()
            await litemadd.Time()
            let time = await litemadd.createtime()

            let timend = time.toNumber()
            timend = timend + 72000
            time = time.toNumber()
            time = time + 28800

       
            let date1 = time % 86400
            date1 = date1 % 14400
            date1 = time - date1 + 14400
  
            let date2 = timend % 86400
            date2 = date2 % 14400
            date2 = timend - date2 + 14400
            
          
            let set = await calendar.Preorderstart(8,date1)
            assert.equal(set,account[0])
            set = await calendar.Preorderend(8,date1)
            assert.equal(set,date2)

        

            let Ava = await calendar.Available(8)
            assert.equal(Ava,"Preordered")    

             await calendar.Pre_Order(time,timend,8,account[1])
             //ute 1 prova a prenotare un oggetto già prenotato
             set = await calendar.Preorderstart(8,date1)
             assert.equal(set,account[0]) //ute 1 non riesce a prenotare 


           })
            it('Provo a prenotare con dataStart e dataEnd diversi ',async()=>{

        

             //    <-----account0------> item 8 
            //            <-----account1------>  farò questo

            let account = await web3.eth.getAccounts()
            await litemadd.Time()
            let time = await litemadd.createtime()

            let timend = time.toNumber()
            timend = timend + 86400
            time = time.toNumber()
            time = time + 43200
            

       
            let date1 = time % 86400
            date1 = date1 % 14400
            date1 = time - date1 + 14400 
  
            let date2 = timend % 86400
            date2 = date2 % 14400
            date2 = timend - date2 + 14400

            await calendar.Pre_Order(time,timend,8,account[1])
            set = await calendar.Preorderstart(8,date1)
            assert.equal(set,"0x0000000000000000000000000000000000000000")
            //prenotazione non riuscita 

                //    <-----account0------> item 8 
            // <-----account1------>  farò questo

           time = await litemadd.createtime()

            timend = time.toNumber()
            timend = timend + 43200
            time = time.toNumber()
            time = time + 14400
            

       
             date1 = time % 86400
            date1 = date1 % 14400
            date1 = time - date1 + 14400 
  
         date2 = timend % 86400
            date2 = date2 % 14400
            date2 = timend - date2 + 14400

            await calendar.Pre_Order(time,timend,8,account[1])
            set = await calendar.Preorderstart(8,date1)
            assert.equal(set,"0x0000000000000000000000000000000000000000")
            //pre_ordine non riuscito


            })
            it('Provo a prenotare in una finestra più piccola',async()=>{
        // <--------account0--------> item 8 
        //   <----account1---->  proverò a fare questo
             let account = await web3.eth.getAccounts()
            await litemadd.Time()
            let time = await litemadd.createtime()

            let timend = time.toNumber()
            timend = timend + 57600
            time = time.toNumber()
            time = time + 43200
            

       
            let date1 = time % 86400
            date1 = date1 % 14400
            date1 = time - date1 + 14400 
  
            let date2 = timend % 86400
            date2 = date2 % 14400
            date2 = timend - date2 + 14400

             await calendar.Pre_Order(time,timend,8,account[1])
            set = await calendar.Preorderstart(8,date1)
            assert.equal(set,"0x0000000000000000000000000000000000000000")
            //pre ordine non riuscito

            })
              it('Provo a prenotare in una finestra più grande',async()=>{
                    // <--------account0--------> item 8 
        //   <--------------account1-------------------->  proverò a fare questo

                  let account = await web3.eth.getAccounts()
            await litemadd.Time()
            let time = await litemadd.createtime()

            let timend = time.toNumber()
            timend = timend + 86400
            time = time.toNumber()
            time = time + 14400
            

       
            let date1 = time % 86400
            date1 = date1 % 14400
            date1 = time - date1 + 14400 
  
            let date2 = timend % 86400
            date2 = date2 % 14400
            date2 = timend - date2 + 14400

             await calendar.Pre_Order(time,timend,8,account[1])
            set = await calendar.Preorderstart(8,date1)
            assert.equal(set,"0x0000000000000000000000000000000000000000")
            //pre ordine non riuscito 

              })

             it('Provo a prenotare più avanti',async()=>{


            let account = await web3.eth.getAccounts()
            await litemadd.Time()
            let time = await litemadd.createtime()

            let timend = time.toNumber()
            timend = timend + 172800
            time = time.toNumber()
            time = time + 158400 
            
            let date1 = time % 86400
            date1 = date1 % 14400
            date1 = time - date1 + 14400 
  
            let date2 = timend % 86400
            date2 = date2 % 14400
            date2 = timend - date2 + 14400


             await calendar.Pre_Order(time,timend,8,account[1])
            set = await calendar.Preorderstart(8,date1)
            assert.equal(set,account[1])
            //prenotazione riuscita

             })
                 it('Provo a in mezzo altre due finestre',async()=>{

                    //<-----------------> <-----provo questo------->  <--------------------->

                let account = await web3.eth.getAccounts()
                await litemadd.Time()
                let time = await litemadd.createtime()

                let timend = time.toNumber()
            timend = timend + 144000
            time = time.toNumber()
            time = time + 129600
            

       
            let date1 = time % 86400
            date1 = date1 % 14400
            date1 = time - date1 + 14400 
  
            let date2 = timend % 86400
            date2 = date2 % 14400
            date2 = timend - date2 + 14400

               await calendar.Pre_Order(time,timend,8,account[2])
            set = await calendar.Preorderstart(8,date1)
            assert.equal(set,account[2])
            //pre_ordine riuscito

                 })
            it('Provo a collidere su due finestre',async()=>{

                //<-------------->            <------------->
              //             <-------------------->
            
               let account = await web3.eth.getAccounts()
                await litemadd.Time()
                let time = await litemadd.createtime()

                let timend = time.toNumber()
            timend = timend + 172800
            time = time.toNumber()
            time = time + 43200

             let date1 = time % 86400
            date1 = date1 % 14400
            date1 = time - date1 + 14400 
  
            let date2 = timend % 86400
            date2 = date2 % 14400
            date2 = timend - date2 + 14400

             await calendar.Pre_Order(time,timend,8,account[3])
            set = await calendar.Preorderstart(8,date1)

             assert.equal(set,"0x0000000000000000000000000000000000000000")
                //pre ordine non riuscito
            })
             })
*/
 })
contract('LoanItem', (owner) => {
 

 })
