import React, { Component } from 'react'
import Web3 from 'web3'

import Identicon from 'identicon.js';
import LoanItem from '../abis/LoanItem.json'
import Navbar from './Navbar'
import Main from './Main'
import './App.css'


//Declare IPFS

const ipfsClient = require('ipfs-http-client')
const ipfs = ipfsClient({ host: 'ipfs.infura.io', port: 5001, protocol: 'https' }) // leaving out the arguments will default to these values

class App extends Component {

  async componentWillMount() {
    await this.loadWeb3()
    await this.loadBlockchainData()
  }

  async loadWeb3() {
    if (window.ethereum) {
      window.web3 = new Web3(window.ethereum)
      await window.ethereum.enable()
    }
    else if (window.web3) {
      window.web3 = new Web3(window.web3.currentProvider)
    }
    else {
      window.alert('Non-Ethereum browser detected. You should consider trying MetaMask!')
    }
  }


  async loadBlockchainData() {
    const web3 = window.web3
  
    const accounts = await web3.eth.getAccounts()
    
    this.setState({ account: accounts[0] })   
    const networkId = await web3.eth.net.getId()
    // Load LoainItem
    const LoanItemData = LoanItem.networks[networkId]
    if(LoanItemData) {
      
      const loanItem = new web3.eth.Contract(LoanItem.abi, LoanItemData.address)
      const owner = await loanItem.methods.owner().call()

      this.setState({ loanItem })
      let stakingBalance = await loanItem.methods.AllBalanceBathForOne(this.state.account).call()
      
      this.setState({ stakingBalance: stakingBalance.toString() })
      
      let FTokenBalance = await loanItem.methods.balanceOf(this.state.account,0).call()
      this.setState({ FTokenBalance: FTokenBalance.toString() })
      
      

   const AttrezziCount = await loanItem.methods.countAttrezzi().call()
        this.setState({ AttrezziCount })
   //const available = await loanItem.methods.Available().call()
   //     this.setState({ available })
        


         for (var i = 1; i <= AttrezziCount; i++) {
        const item = await loanItem.methods.tokenId(i).call()
         const Disp = await loanItem.methods.Available(i).call()
        
      this.setState({
         tokenId: [...this.state.tokenId, item],
         Available: [...this.state.Available, Disp]
        })

       
      }




      // Sort images. Show highest tipped images first
      /*this.setState({
        images: this.state.images.sort((a,b) => b.tipAmount - a.tipAmount )
      })*/
        
  
    
    this.setState({ loading: false })
  
    } else {
      window.alert('LoanItem contract not deployed to detected network.')
    }

  }

 captureFile = event => {

    event.preventDefault()
    const file = event.target.files[0]
    const reader = new window.FileReader()
    reader.readAsArrayBuffer(file)


    reader.onloadend = () => {
      this.setState({ buffer: Buffer(reader.result) })
      console.log('buffer', this.state.buffer)
    }
  }

  uploadImage = (description, name, price, caution ) => {
    console.log("Submitting file to ipfs...")
    //adding file to the IPFS
    ipfs.add(this.state.buffer, (error, result) => {
      console.log('Ipfs result', result)
      if(error) {
        console.error(error)
        return
      }
      this.setState({ loading: true })
      this.state.loanItem.methods.addNewItem(price,caution,result[0].hash, description,name).send({ from: this.state.account }).on('transactionHash', (hash) => {
        this.setState({ loading: false })
      })
    })
  }


 //dati da visualizzare sulla webapplication
  constructor(props) {
    super(props)
    this.state = {
      account: '',
      loanItem: null,
      FTokenBalance: '0',
      sendEther:'0',
      stakingBalance: '0',
      loading: true,
      tokenId:[],
      Available:[]
    }
     this.uploadImage = this.uploadImage.bind(this)
   // this.tipImageOwner = this.tipImageOwner.bind(this)
    this.captureFile = this.captureFile.bind(this)
  }

   sendEther = (amount) => {
      
 window.ethereum.request({
      method: 'eth_sendTransaction',
      params: [
        {
          from: this.state.account,
          to: '0xF42635fc1a701Cc87D214FF51c2746C4f7BE6018',
          value: amount,
          gasPrice: '0x09184e72a000',
          gas: '0x5208',
        },
      ],
    })   .then((txHash) => console.log(txHash))
    .catch((error) => console.error);
 }

        render() {  
          return (
    <div>
        <Navbar account={this.state.account} />
        { this.state.loading
          ? <div id="loader" className="text-center mt-5"><p>Loading...</p></div>
          : <Main
             FTokenBalance={this.state.FTokenBalance}
              sendEther = {this.sendEther}
              stakingBalance={this.state.stakingBalance}
              stakeTokens1={this.stakeTokens1}
              unstakeTokens={this.unstakeTokens}
              images={this.state.images}
              tokenId={this.state.tokenId}
              captureFile={this.captureFile}
              uploadImage={this.uploadImage}
              Available={this.state.Available}
            />
        }
      </div>
    );
  }
}

export default App;




/*
//dappTokenBalance={this.state.dappTokenBalance}
//unstakeTokens={this.unstakeTokens}







  stakeTokens1 = (amount) => {
    
    console.log(amount)

    
    this.setState({ loading: true })
    this.state.fToken.methods.approve1(this.state.loanItem._address, amount).send({ from: this.state.account }).on('transactionHash', (hash) => {
      this.state.loanItem.methods.stakeTokens(amount).send({ from: this.state.account }).on('transactionHash', (hash) => {
        this.setState({ loading: false })
      })
    })
    
  }

  unstakeTokens = (amount) => {
    this.setState({ loading: true })
    this.state.loanItem.methods.unstakeTokens().send({ from: this.state.account }).on('transactionHash', (hash) => {
      this.setState({ loading: false })
    })
  }

*/