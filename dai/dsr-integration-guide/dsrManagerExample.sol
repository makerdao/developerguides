/**
 DO NOT USE THIS CODE IN PRODUCTION
 THIS IS A DRAFT EXAMPLE OF HOW TO INTERACT WITH THE MAKER PROTOCOL POT CONTRACT
 THIS CODE HAS NOT BEEN TESTED
*/

pragma solidity ^0.5.12;

contract DsrManager {
    function daiBalance(address usr) external returns (uint256 wad);
    function join(address dst, uint256 wad) external;
    function exit(address dst, uint256 wad) external;
    function exitAll(address dst) external;
}

contract GemLike {
    function transferFrom(address,address,uint) external returns (bool);
    function approve(address,uint) external returns (bool);
}

contract DsrExample {
    
    // Contract Interfaces
    DsrManager public dsrM;
    GemLike  public daiToken;
    
    address owner;
    
    event DaiBalance(address indexed src, uint balance);
    
    constructor(address dsrM_, address dai_ ) public {
        dsrM = DsrManager(dsrM_);
        daiToken = GemLike(dai_);
        owner = msg.sender;
        
        //Approving DsrManager to withdraw Dai from this contract        
        daiToken.approve(address(dsrM), uint256(-1));
        
    }
    
    modifier onlyOwner {
        require(msg.sender == owner,
        "Only the contract owner can call this function");
        _;
    }    
    
    function activateDsr(uint wad) public onlyOwner {
        daiToken.transferFrom(msg.sender, address(this), wad);
        dsrM.join(address(this), wad);
    }
    
    function exitDsr(address dst, uint256 wad) public onlyOwner {
        dsrM.exit(dst, wad);
    }
    
    function exitDsrAll(address dst) public onlyOwner {
        dsrM.exitAll(dst);
    }
    
    function DsrBalance() public returns (uint wad) {
        uint balance = dsrM.daiBalance(address(this));
        emit DaiBalance(address(this), balance);
        return balance;
    }
}