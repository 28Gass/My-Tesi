
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
    litemadd = await LItemUtils.new(loanitem.address,calendar.address)
    
   
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
        
        await litemadd.Time()
        let time = await litemadd.createtime()
        time = time.toNumber()
        time = time + 14400
        await loanitem.TrasferTest(account[0],account[1],2,1,1,0,time,{from: account[1]})
       
         await loanitem.TrasferTest(account[0],account[1],3,1,1,0,time,{from: account[1]})

        await loanitem.setApprovalForAll(account[0],true,{from: account[1]})//account [1] to account  [0] = true
         aprove = await loanitem.isApprovedForAll(account[1],account[0])
        assert.equal(aprove,true)
        /*
          let arry= await calendar.preOrderOpenGet(2)
          for(let i=0; i<arry.length;i++ ){
                                console.log(" Arry: " + arry[i])
                              }
        let Start =  await calendar.Preorderstart(2,arry[0])
        let End   =  await calendar.Preorderend(2,arry[0])

        console.log("Inizio :" + Start)
        console.log("Fine   :" + End)
        */
        time = time - 14400
        await loanitem.TrasferTest(account[1],account[0],2,0,0,time,0,{from: account[1]})
        
        await loanitem.setApprovalForAll(account[0],false,{from: account[1]})//account [1] to account  [0] = false
        aprove = await loanitem.isApprovedForAll(account[1],account[0])
        assert.equal(aprove,false) 
        /*
             arry= await calendar.preOrderOpenGet(2)
          for(let i=0; i<arry.length;i++ ){
                                console.log(" Arry: " + arry[i])
                              }
         Start =  await calendar.Preorderstart(2,arry[0])
         End   =  await calendar.Preorderend(2,arry[0])

        console.log("Inizio :" + Start)
        console.log("Fine   :" + End)
        
        let ters = await calendar.Available(2)
        assert.equal(ters,"Waiting")
*/
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
            await loanitem.ReleseW(2,account[1],0)

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
          it('account[1] Try to sell this item[8] DA FARE ',async()=>{
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
            describe('TEST  Calendar', async()=>{
                 it('test Cancellazione Prenotazioni scadute--Update--',async()=>{
                
/*------------------Per far funzionare il test mettere i commenti su Time()--------------------
                    all'interno di update(LitmeCalendar.sol) e togliere i commenti della funzione
                    TimeAdd() per poter manipolare il tempo */

                    /*
                  await litemadd.Time()
                   let orario = await litemadd.createtime()
                   let tester1 = await calendar.preOrderOpenGet()
                    orario = await calendar.Converter(orario,true)
                   orario = orario.toNumber()
                   orario =orario +  28800
                    //console.log("Orario1 : "+orario)
                    assert.equal(tester1[0].toNumber(),orario)
                    
                    // console.log("orario :" + orario)
                     orario =orario + 129600 - 28800
                    
                    assert.equal(tester1[2].toNumber(),orario)
                    
                    orario = orario - 129600 + 158400
                  
                     assert.equal(tester1[1].toNumber(),orario)

                    // assert.equal(tester1[2].toNumber(),orario)
                  
                   
                    await calendar.TimeAdd(144000)
                    await calendar.Update()

                   let oner= tester1[0]
                   tester1 = await calendar.preOrderOpenGet()
                   //-------item 8---prenotazione Scaduta---------
                   assert.equal(tester1[0].toNumber(),0)
                  //assert.equal(tester1[2].toNumber(),1637913600)
                   assert.equal(tester1[1].toNumber(),orario)



                   //orario = orario - 158400 + 28800
                   
                
                   let one =  await calendar.Preorderstart(8,oner)

                   assert.equal(one,"0x0000000000000000000000000000000000000000")
                    one =  await calendar.Preorderend(8,oner)
                     assert.equal(one,0)
                     one =  await calendar.Available(8)
                      assert.equal(one,"Waiting")*/
                 })
                     it('Test Acquire preOrder',async()=>{
                    //provo ad acquisire l'ordine dopo aver prenotato ed nel momento in cui arriva l'ora
                    //per far funzionare il test manipolo l'ora quindi bisogna commentare Time() in AcquirePre e 
                    //togliere i commenti in timeAdd() e commentare update()
                  /* let account = await web3.eth.getAccounts()
                           await calendar.Time()
                            let orario = await calendar.time()
                             //console.log("ora1  "+orario)
                           await calendar.TimeAdd(46200)
                      orario = await calendar.time()
                            //console.log("ora2  "+orario)

                   orario = orario.toNumber()

                    //let tester1 = await calendar.preOrderOpenGet()
                    // console.log("tester 0 :" + tester1[0])
                    // console.log("tester 1 :" + tester1[1])
                    // console.log("tester 2 :" + tester1[2])

                    orario = await calendar.Converter(orario,false)
                   
                     await calendar.AcquirePre(8,account[0])

                   let tes = await calendar.Available(8)
                   assert.equal(tes,"Busy")

                    */
                     })

                })

              describe('Preorder with Transaction from LoanItem', async()=>{

                //da implementare 
                /*
                ---Una volta acquisito il pre-ordine sarà uguale ad un'acquisto normale--- LOAN ITEM MA CAUZIONE UNA SOLA VOLTA
                ---Sugli acquisti normali implementare le date in cui si intende tenere l'oggetto---LOANITEM

                ---Cancellazioni preOrdini
                ---prezzi in base ai giorni/slot. LOANITEM AND CALENDAR */
                 

                //Faccio le stesse operazioni Acquire-Prenotazione tramite loanItem che 
                //si interfaccia a calendar
                 it('preOrder from LoanItem',async()=>{

                        let result = await calendar.Available(6)
                        assert.equal(result,"Available")

                        let account = await web3.eth.getAccounts()
                        aprove = await loanitem.isApprovedForAll(account[0],account[2])
                        assert.equal(aprove,false)  
                        await loanitem.setApprovalForAll(account[2],true,{from: account[0]})//account [0] to account  [1] = true
       
                        aprove = await loanitem.isApprovedForAll(account[0],account[2]) 
                        assert.equal(aprove,true) 

                         aprove = await loanitem.isApprovedForAll(account[0],account[3])
                        assert.equal(aprove,false)  
                        await loanitem.setApprovalForAll(account[3],true,{from: account[0]})//account [0] to account  [1] = true
       
                        aprove = await loanitem.isApprovedForAll(account[0],account[3]) 
                        assert.equal(aprove,true) 




                        await litemadd.Time()
                        let orario = await litemadd.createtime();
                        orario = orario.toNumber()
                        orario = orario + 28800   //per due slot + 1 standard

                        await loanitem.GiveToken(account[2],1,web3.utils.toWei("1000000", 'Ether'),{from: account[0]})////100 FToken
                        await loanitem.GiveToken(account[3],1,web3.utils.toWei("1000000", 'Ether'),{from: account[0]})
                        

                        await loanitem.TrasferTest(account[0],account[2],6,1,0,0,orario,{from:account[2]})

                        orarioE = orario +86400
                        orario = orario + 43200
                        await loanitem.TrasferTest(account[0],account[3],6,1,0,orario,orarioE,{from:account[3]})

                        orario = orario - 43200

                        orario = orario - 28800
                        let date2 = orario % 86400
                        date2 = date2 % 14400
                        date2 = orario - date2 + 14400

                     
                        let result3 = await calendar.Available(6)
                        assert.equal(result3,"Preordered")
                        //result3 = await calendar.Preorderstart(6,date2)
                        //assert.equal(result3,account[2])

                        //controllare i bilanci

                        let balance = await loanitem.balanceOf(account[2],6)

                             assert.equal(balance,0)

                 })
                         it('Acquire from LoanItem',async()=>{

                            //per far fuzionare questo test commentare Update in 
                            //acquire pre per poter manimolare il tempo

                            let account = await web3.eth.getAccounts()
                            await calendar.TimeAdd(28800)

                            await loanitem.TrasferTest(account[0],account[2],6,0,1,0,0,{from:account[2]})

                            let result2 = await calendar.Available(6)

                            assert.equal(result2,"Busy")

                             let balance = await loanitem.balanceOf(account[2],6)

                             assert.equal(balance,1)

                            //controllare i bilanci
                            
                            })

                             it('Test back per la riconsegna di item',async()=>{
                                //questo test per funzionare il test sopra deve essere
                                //funzionante.
                                //comprende la riconsegna di un item acquisito quindi con
                                //Avialable=Waiting riconsegna cauzione e cancellazione 
                                //delle varie date
                                let account = await web3.eth.getAccounts()

                                let wow = await calendar.PreorderOpen(6,0)
                                //console.log("Funziona :"+wow)
                                //console.log("Funziona1:"+date1)

                                //let balance = await loanitem.balanceOf(account[2],1)
                                //console.log("Soldi 2:"+ balance)
                                //balance = await loanitem.balanceOf(account[3],1)
                                //console.log("Soldi 3:"+ balance)
                                //balance = await loanitem.balanceOf(account[0],1)
                                //console.log("Soldi 0:"+ balance)


                                await loanitem.TrasferTest(account[2],account[0],6,0,0,wow,0,{from:account[2]})
                                
                                let gava = await calendar.Available(6)

                                assert.equal(gava,"Waiting")


                             })
                         /*
                         it('set Waiting LoanItem fatto sopra',async()=>{

                         })

                         it('Normal acquisto from LoanItem fatto sopra',async()=>{


                            })*/
                         it('relese di oggetti prenotati da Waiting->Available->preOrdered',async()=>{
                            /**/
                              let account = await web3.eth.getAccounts()

                           
                             await loanitem.ReleseW(6,account[2],0,{from: account[0]})

                             let tester= await calendar.Available(6)
            
                            assert.equal(tester,"Preordered")

                            //controllare i bilanci

                            })

              })

})
	})