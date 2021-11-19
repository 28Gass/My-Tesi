
const LoanItem = artifacts.require("LoanItem");
const LItemUtils = artifacts.require("LItemUtils");
const LItemCalendar = artifacts.require("Calendar");


contract('LoanItem', (owner) => {
 let loanitem
 let operator
 let aprove
 let calendar
const ipfsClient = require('ipfs-http-client')
const ipfs = ipfsClient({ host: 'ipfs.infura.io', port: 5001, protocol: 'https' }) // leaving out the arguments will default to these va
 	before(async()=> {
 	//LOAD Contracts
 	let account = await web3.eth.getAccounts()
    calendar= await  LItemCalendar.new()
    loanitem = await LoanItem.new(account[0],calendar.address)
    litemadd = await LItemUtils.new(loanitem.address)
    
   
   await loanitem.addNewCoin(web3.utils.toWei("1000000", 'Ether'),"FToken","best Token",{from: account[0]});

    await loanitem.addNewItem(web3.utils.toWei("1", 'Ether'),web3.utils.toWei("0.5", 'Ether'),"1233","5att","Primo Item",1)/*,*/
    await loanitem.addNewItem(web3.utils.toWei("2", 'Ether'),web3.utils.toWei("0.5", 'Ether'),"1234","4att","Secondo Item",1)/*,*/
    await loanitem.addNewItem(web3.utils.toWei("3", 'Ether'),web3.utils.toWei("0.5", 'Ether'),"1235","3att","terzo Item",1)/*,""*/
    await loanitem.addNewItem(web3.utils.toWei("4", 'Ether'),web3.utils.toWei("0.5", 'Ether'),"1236","2att","Quarto Item",1)/*,""*/
    await loanitem.addNewItem(web3.utils.toWei("5", 'Ether'),web3.utils.toWei("0.5", 'Ether'),"1237","1att","Quinto Item",1)/*,*/

    
    await loanitem.GiveToken(account[1],1,web3.utils.toWei("1000000", 'Ether'),{from: account[0]})////100 FToken
    })
    //test contratto caricato con successo  
    it('has a name', async () => {
      let account = await web3.eth.getAccounts()
      const name = await loanitem.name()
      assert.equal(name, 'LoanItem')
      let owner = await loanitem.owner()
      assert.equal(owner,account[0] )    // il proprietario è il primo account[0]
    }) 
    describe('New Coin Test', async()=>{
      it('has created', async () => {
        let account = await web3.eth.getAccounts()
        let balance = await loanitem.balanceOf(account[0],1)       
        assert.equal(web3.utils.fromWei(balance, 'Ether'),999900)
      })
      it('has a name', async () => {
        let account = await web3.eth.getAccounts()
        let name = await loanitem.CoinId(1)
        assert.equal(name.namec,"FToken")
      })
    })
     

//se ha l'autoriazzazione a fare transazioni
   describe('Transaction Test', async()=>{
     
     it('Approved?', async () => {
       //test per la approvazione per trasferire i token  
        let account = await web3.eth.getAccounts()
        aprove = await loanitem.isApprovedForAll(account[0],account[1])
        assert.equal(aprove,false)  
       await loanitem.setApprovalForAll(account[1],true,{from: account[0]})//account [0] to account  [1] = true
       
        aprove = await loanitem.isApprovedForAll(account[0],account[1]) 
        assert.equal(aprove,true) 

        await loanitem.TrasferTest(account[0],account[1],2,{from: account[1]})
       
         await loanitem.TrasferTest(account[0],account[1],3,{from: account[1]})

        await loanitem.setApprovalForAll(account[0],true,{from: account[1]})//account [1] to account  [0] = true
         aprove = await loanitem.isApprovedForAll(account[1],account[0])
        assert.equal(aprove,true)

        await loanitem.TrasferTest(account[1],account[0],2,{from: account[1]})
        
        await loanitem.setApprovalForAll(account[0],false,{from: account[1]})//account [1] to account  [0] = false
        aprove = await loanitem.isApprovedForAll(account[1],account[0])
        assert.equal(aprove,false) 
        })
     
    // test controllo il bilancio dopo una transazione
   it('contract test trasfer', async () => {
    	let account = await web3.eth.getAccounts()
        let balance = await loanitem.balanceOf(account[1],3)    
        assert.equal(balance, 1)
        balance = await loanitem.balanceOf(account[0],2)
        assert.equal(balance, 1)
        balance = await loanitem.balanceOf(account[0],3)
        assert.equal(balance, 0)
         balance = await loanitem.balanceOf(account[0],4)
        assert.equal(balance, 1)
         balance = await loanitem.balanceOf(account[0],5)
        assert.equal(balance, 1)
         balance = await loanitem.balanceOf(account[0],6)
        assert.equal(balance, 1)
 })      
   //controllo il bilancio totali degli atrezzi di ogni singolo utente
      it ('contract BalanceBath test', async() =>{
        let account = await web3.eth.getAccounts()
        let bath = await litemadd.AllBalanceBath(account)
        assert.equal(bath[0], 4)
        assert.equal(bath[1], 1)
        assert.equal(bath[2], 0)
      let bath1 = await litemadd.AllBalanceBathForOne(account[0])//metodo per un solo utente
      assert.equal(bath1, 4)
})

 describe('Token Propieties', async()=>{
        it('Id is correct',async()=>{

            let token = await loanitem.tokenId(2)
            assert.equal(token.id,2)
            token = await loanitem.tokenId(3)
            assert.equal(token.id,3)
            token = await loanitem.tokenId(4)
            assert.equal(token.id,4)
            token = await loanitem.tokenId(5)
            assert.equal(token.id,5)
            token = await loanitem.tokenId(6)
            assert.equal(token.id,6)
        })
       it('Image test',async()=>{
            let token = await loanitem.tokenId(2)
            assert.equal(token.phots.hash,"1233") 

       })
       it('Name',async()=>{
            let token = await loanitem.tokenId(2)
            assert.equal(token.namet,"Primo Item") 

       })
       it('describe',async()=>{
            let token = await loanitem.tokenId(2)
            assert.equal(token.description,"5att") 

       })

    it('Price',async()=>{
            let token = await loanitem.tokenId(2)
            assert.equal(web3.utils.fromWei(token.pricel, 'Ether'),1) 

       })
     it('Caution',async()=>{
            let token = await loanitem.tokenId(2)
            assert.equal(web3.utils.fromWei(token.caution, 'Ether'),"0.5") 

       })
     it('Available',async()=>{  //controllo di avialable dopo le transazioni avvenute in Approve
            let account = await web3.eth.getAccounts()
            let token = await calendar.Available(2)
            assert.equal(token,"Waiting") 
            token = await calendar.Available(3)
             assert.equal(token,"Busy")
            token = await calendar.Available(4)
            assert.equal(token,"Available")
            token = await calendar.Available(5)
            assert.equal(token,"Available")
            token = await calendar.Available(6)
            assert.equal(token,"Available")
            
      })
     it('Coin Id',async()=>{
            let token = await loanitem.tokenId(2)
            assert.equal(token.Cid,1) 

       })
      })
   
     describe('fToken balance', async()=>{
         it('account[1]',async()=>{
            let account = await web3.eth.getAccounts()
            let balnce = await loanitem.balanceOf(account[1],1)
                assert.equal(web3.utils.fromWei(balnce, 'Ether'),96)
           })  
            it('account[0]',async()=>{
            let account = await web3.eth.getAccounts()    
            balnce = await loanitem.balanceOf(account[0],1)
            assert.equal(web3.utils.fromWei(balnce, 'Ether'),999904)
                    })
     }) 
   //questa operazione può essere eseguita solo dall'owner
     describe('Relese Item Waiting to Available and caution', async()=>{
        it('Item 1 ',async()=>{
            let account = await web3.eth.getAccounts()
            await loanitem.ReleseW(2,0)
            let balnce = await loanitem.balanceOf(account[1],1)
             assert.equal(web3.utils.fromWei(balnce, 'Ether'),96.5)
             balnce = await loanitem.balanceOf(account[0],1)
             assert.equal(web3.utils.fromWei(balnce, 'Ether'),999903.5)
             let disp = await calendar.Available(2)
             assert.equal(disp,"Available")
           })
        it('test error fungible ',async()=>{
            //await loanitem.ReleseW(1,0)   //---work
            // await loanitem.addNewItem(1,1,"555","test","Tester",2)//--work
        })
    })
     describe('Set permissions More Owner', async()=>{
         it('account[1] set true ',async()=>{
            let account = await web3.eth.getAccounts()
            await loanitem.setPermissions(account[1], true,{from: account[0]})        
            let permes = await loanitem.permissions(account[1])
            assert.equal(permes,true)
         })
          it('account[1] create new Coin ',async()=>{
            let account = await web3.eth.getAccounts()
            await loanitem.addNewCoin(web3.utils.toWei("100000", 'Ether'),"PippoCoin","Best Coin",{from: account[1]})
            let name = await loanitem.CoinId(7)
            assert.equal(name.namec,"PippoCoin")
            let balance = await loanitem.balanceOf(account[1],7)
            assert.equal(web3.utils.fromWei(balance, 'Ether'),100000)
         })                           
          it('account[1] create new Item ',async()=>{
             let account = await web3.eth.getAccounts()
            await loanitem.addNewItem(web3.utils.toWei("6", 'Ether'),web3.utils.toWei("0.6", 'Ether'),"1236","3att","Sesto Item",1,{from: account[1]})/*,*/
            let balance = await loanitem.balanceOf(account[1],8)
            assert.equal(balance,1)
            let prova = await loanitem.tokenId(8)
            assert.equal(prova.namet,"Sesto Item")
          })  
        
     })
     describe('Time Test', async()=>{
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

            await calendar.Pre_Order(time,timend,8)

            Ava = await calendar.Available(8)
            assert.equal(Ava,"Preordered")


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

             await calendar.Pre_Order(time,timend,8,{from:account[1]})
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

            await calendar.Pre_Order(time,timend,8,{from:account[1]})
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

            await calendar.Pre_Order(time,timend,8,{from:account[1]})
            set = await calendar.Preorderstart(8,date1)
            assert.equal(set,"0x0000000000000000000000000000000000000000")


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

             await calendar.Pre_Order(time,timend,8,{from:account[1]})
            set = await calendar.Preorderstart(8,date1)
            assert.equal(set,"0x0000000000000000000000000000000000000000")

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

             await calendar.Pre_Order(time,timend,8,{from:account[1]})
            set = await calendar.Preorderstart(8,date1)
            assert.equal(set,"0x0000000000000000000000000000000000000000")

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


             await calendar.Pre_Order(time,timend,8,{from:account[1]})
            set = await calendar.Preorderstart(8,date1)
            assert.equal(set,account[1])


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

               await calendar.Pre_Order(time,timend,8,{from:account[2]})
            set = await calendar.Preorderstart(8,date1)
            assert.equal(set,account[2])


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

             await calendar.Pre_Order(time,timend,8,{from:account[3]})
            set = await calendar.Preorderstart(8,date1)

             assert.equal(set,"0x0000000000000000000000000000000000000000")

            })
             })

              describe('Preorder with Transaction link LoanItem to Calendar', async()=>{

                //da implementare 
                /*--Quando volgio prenotare da loanItem bisognerà pagare la cauzione in anticipo---
                ----controllare con una funzione update controlla le varie scadenze sopratutto un pre-ordine non ritirato---  
                Una volta acquisito il pre-ordine sarà uguale ad un'acquisto normale---
                Sugli acquisti normali implementare le date in cui si intende tenere l'oggetto---
                prezzi in base ai giorni/slot. */
                 it('',async()=>{})

              })

})
	})