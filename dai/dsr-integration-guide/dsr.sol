/**
 DO NOT USE THIS CODE IN PRODUCTION
 THIS IS A DRAFT EXAMPLE OF HOW TO INTERACT WITH THE MAKER PROTOCOL POT CONTRACT
 THIS CODE HAS NOT BEEN TESTED
*/

pragma solidity >=0.5.12;

contract PotLike {
    function chi() external view returns (uint256);
    function rho() external returns (uint256);
    function drip() external returns (uint256);
    function join(uint256) external;
    function exit(uint256) external;
    function pie(address) public view returns (uint256);

}

contract JoinLike {
    function join(address, uint256) external;
    function exit(address, uint256) external;
    function vat() public returns (VatLike);
    function dai() public returns (GemLike);

}

contract GemLike {
    function transferFrom(address,address,uint256) external returns (bool);
    function approve(address,uint256) external returns (bool);
}

contract VatLike {
    function hope(address) external;
    function dai(address) public view returns (uint256);

}

contract DSR {

    // Contract interfaces
    PotLike  public pot;
    JoinLike public daiJoin;
    GemLike  public daiToken;
    VatLike  public vat;

    address owner;


    // Supporting Math functions
    uint256 constant RAY = 10 ** 27;
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x);
    }
    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x);
    }
    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    constructor(address pot_, address join_, address dai_, address vat_) public {
        owner    = msg.sender;
        pot      = PotLike(pot_);
        daiJoin  = JoinLike(join_);
        daiToken = GemLike(dai_);
        vat      = VatLike(vat_);

        vat.hope(join_);
        vat.hope(pot_);

        daiToken.approve(join_, uint256(-1));
    }

    modifier onlyOwner {
        require(msg.sender == owner,
        "Only the contract owner can call this function");
        _;
    }

    function join(uint256 wad) public onlyOwner {
        uint256 chi = (now > pot.rho()) ? pot.drip() : pot.chi();
        daiToken.transferFrom(msg.sender, address(this), wad);
        daiJoin.join(address(this), wad);
        pot.join(mul(wad, RAY) / chi);
    }

    function exit(uint256 wad) public onlyOwner {
        uint256 chi = (now > pot.rho()) ? pot.drip() : pot.chi();
        pot.exit(mul(wad, RAY) / chi);
        daiJoin.exit(msg.sender, daiJoin.vat().dai(address(this)) / RAY);
    }

    function exitAll() public onlyOwner {
        if (now > pot.rho()) pot.drip();
        pot.exit(pot.pie(address(this)));
        daiJoin.exit(msg.sender, daiJoin.vat().dai(address(this)) / RAY);
    }

    function balance() public view returns (uint256) {
       uint256 pie = pot.pie(address(this));
       uint256 chi = pot.chi();
       return pie * chi / RAY;
    }
}
