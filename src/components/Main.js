import React, { Component } from 'react'
import dai from '../dai.png'
import Identicon from 'identicon.js';

class Main extends Component {
  render() {
    return (

    

<div id="content" className="mt-3">
    
        <table className="table table-borderless text-muted text-center">
          <thead>
            <tr>
              <th scope="col">Attrezzatura disponibile</th>
              <th scope="col">Reward Balance</th>
            </tr>
          </thead>
          <tbody>
            <tr>
           
              <td>{this.props.stakingBalance} Attrezzatura in magazino</td>
              <td>{window.web3.utils.fromWei(this.props.FTokenBalance, 'Ether')} Ftoken</td>
            </tr>
          </tbody>
        </table>


     
<div className="container-fluid mt-5">
        <div className="row">
          <main role="main" className="col-lg-12 ml-auto mr-auto" style={{ maxWidth: '500px' }}>
            <div className="content mr-auto ml-auto">
              <p>&nbsp;</p>
              <h2>Add New Item</h2>
              <form onSubmit={(event) => {
                event.preventDefault()
                const description = this.imageDescription.value
                const name = this.Name.value
                const price = window.web3.utils.toWei(this.Price.value, 'Ether')
                const caution = window.web3.utils.toWei(this.Caution.value, 'Ether')
                this.props.uploadImage(description, name, price, caution)

              }} >
                <input type='file' accept=".jpg, .jpeg, .png, .bmp, .gif" onChange={this.props.captureFile} />
                  <div className="form-group mr-sm-2">
                    <br></br>
                       <input
                        id="Name"
                        type="text"
                        ref={(input) => { this.Name = input }}
                        className="form-control"
                        placeholder="Name Token..."
                        required />

                        <input
                        id="Name"
                        type="text"
                        ref={(input) => { this.Price = input }}
                        className="form-control"
                        placeholder="Price Token..."
                        required />

                        <input
                        id="imageDescription"
                        type="text"
                        ref={(input) => { this.Caution = input }}
                        className="form-control"
                        placeholder="Caution..."
                        required />



                        <input
                        id="imageDescription"
                        type="text"
                        ref={(input) => { this.imageDescription = input }}
                        className="form-control"
                        placeholder="description..."
                        required />

    

                  </div>

                <button type="submit" className="btn btn-primary btn-block btn-lg">Upload!</button>
              </form>
    


               <p>&nbsp;</p>
    

            {this.props.tokenId.map((item,key) =>{
                  
          let test = this.props.Available
    
              return(

                <div className="card mb-4" key={key} >
                    <div className="card-header">
                      <img
                        //className='mr-2'
                        //width='30'
                        //height='30'
                        //src={`data:image/png;base64,${new Identicon(item.phots.author, 30).toString()}`}
                      />
                       <h2><strong className="text-muted">Nome:{item.namet}</strong></h2>

                    </div>
                     <ul id="imageList" className="list-group list-group-flush">
                      <li className="list-group-item">
                        <p className="text-center"><img src={`https://ipfs.infura.io/ipfs/${item.phots.hash}`} style={{ maxWidth: '420px'}}/></p>
                        <p>Descrizione:{item.description}</p>
                         <p>  Prezzo:{window.web3.utils.fromWei(String(item.pricel), 'Ether')} </p>
                         <p>  Cauzione:{window.web3.utils.fromWei(String(item.caution), 'Ether')} </p>
                          <p> Disponibità:{test[key]}</p> 
                      </li>
                      
                       
                    </ul>
                  </div>
              )
         
           })} 

    </div>
          </main>
        </div>
   

      </div>
      </div>
    
);

  }





}

export default Main;



/*
 <p>{tokenId[image.hash]}</p>


    <form className="mb-3" onSubmit={(event) => {
                event.preventDefault()
                let amount
                amount = this.input.value.toString()
                amount = window.web3.utils.toWei(amount, 'Ether')
                 amount = window.web3.utils.numberToHex(amount)
                this.props.sendEther(amount)
              }}>
              <div>
                <label className="float-left"><b>Stake Tokens</b></label>
                <span className="float-right text-muted">
                  Balance: {window.web3.utils.fromWei(this.props.FTokenBalance, 'Ether')}
                </span>
              </div>

 <div className="input-group mb-4">
                <input
                  type="text"
                  ref={(input) => { this.input = input }}
                  className="form-control form-control-lg"
                  placeholder="0"
                  required />
                <div className="input-group-append">
                  <div className="input-group-text">
                    <img src={dai} height='32' alt=""/>
                    &nbsp;&nbsp;&nbsp; mDAI
                  </div>
                </div>
              </div>
              <button type="submit" className="btn btn-primary btn-block btn-lg">STAKE!</button>
            </form>
 
 









 <div className="card mb-4" >

          <div className="card-body">

            <form className="mb-3" onSubmit={(event) => {
                event.preventDefault()
                let amount
                amount = this.input.value.toString()
                amount = window.web3.utils.toWei(amount, 'Ether')
                this.props.stakeTokens1(amount)
              }}>
              <div>
                <label className="float-left"><b>Stake Tokens</b></label>
                <span className="float-right text-muted">
                  Balance: {window.web3.utils.fromWei(this.props.FTokenBalance, 'Ether')}
                </span>
              </div>

 <div className="input-group mb-4">
                <input
                  type="text"
                  ref={(input) => { this.input = input }}
                  className="form-control form-control-lg"
                  placeholder="0"
                  required />
                <div className="input-group-append">
                  <div className="input-group-text">
                    <img src={dai} height='32' alt=""/>
                    &nbsp;&nbsp;&nbsp; mDAI
                  </div>
                </div>
              </div>
              <button type="submit" className="btn btn-primary btn-block btn-lg">STAKE!</button>
            </form>
         <p>&nbsp;</p>
 
 <button
              type="submit"
              className="btn btn-link btn-block btn-sm"
              onClick={(event) => {
                event.preventDefault()
                this.props.unstakeTokens()
              }}>
                UN-STAKE...
              </button>
          </div>
        </div>





*/