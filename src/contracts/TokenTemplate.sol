pragma solidity ^0.8.0;


import "./TokenFactory.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
/**
 * @title TokenTemplate
 * @dev Very simple ERC20 Token that can be minted.
 * It is meant to be used in all crowdsale contracts.
 */
contract TokenTemplate is ERC20 {
    event Debug(string _message);

    address private _owner;
    string private _logoURL;
    string private _logoHash;
    string private _contractHash;
    TokenFactory private _tokenFactory;





    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals,
        string memory logoURL,
        string memory logoHash,
        uint256 totalSupply,
        address owner,
        string memory contractHash,
        address tokenFactoryAddress
    ) ERC20(name,"") public {
        require(owner != address(0), "Owner must be defined");
        _logoURL = logoURL;
        
        if (totalSupply > 0) {
            _mint(owner, totalSupply);
        }

        _owner = owner;
        _contractHash = contractHash;
        _logoHash = logoHash;
        _tokenFactory = TokenFactory(tokenFactoryAddress);
    }

    /**
     * override of erc20 transfer
     */
    function transfer(address recipient, uint256 amount,address owner)public returns (bool) {
        
       
        _transfer(recipient, owner, amount); //call to erc20 standard transfer
        
        _tokenFactory.addToPossessed(recipient, address(this));
        return true;
    }

   

}