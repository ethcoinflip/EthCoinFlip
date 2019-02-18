pragma solidity >=0.4.22 <0.6.0;

contract CoinFlip {
    
    address private manager;
    uint nonce;
    uint256 jackpot;

    constructor() public {
        manager = msg.sender;
        nonce = 0;
        jackpot = 1000000000000000000;
    }

    function enter() payable public {
        // don't let user enter with less than 0.009 ether
        require(msg.value  > 0.009 ether);
        uint256 amount = msg.value; 
        address payable user = msg.sender;
        if (amount * 1 wei > address(this).balance) {
            // if contract cant afford bet, send money back to user
            user.transfer(amount);
        }
        // try jackpot
        else if (tryJackpot() > 0 && jackpot * 1 wei < address(this).balance) {
            user.transfer(jackpot * 1 wei);
        }
        // if user loses jakcpot, but wins the bet, send them the money
        else if (rand(0,100) < 52 && amount * 2 wei < address(this).balance) {
            user.transfer(amount*2 wei);
        }
        // if user loses bet and jackpot, add wei to jackpot
        jackpot += 100000000000000;
    }
    
    function tryJackpot() private returns (uint256) {
        if (rand(0,1001) == 1000) {
            return 1;
        } 
        else {
            return 0;
        }
    }
    
    // allow contract creator to withdrawal funds but the withdrawal amount must be less than half of the contracts balance
    function withdrawal(address payable adrs, uint256 amount_wei) public restricted {
        require(amount_wei * 1 wei < address(this).balance / 2); 
        adrs.transfer(amount_wei * 1 wei);
    }
    
    //Random Num Generator
    function toBytes(uint256 x) private pure returns (bytes memory b) {
        b = new bytes(32);
        assembly { mstore(add(b, 32), x) }
    }    
    
    function rand(uint min, uint max) private returns (uint) {
        nonce++;
        return uint(keccak256(toBytes(nonce)))%(min+max)-min;
    }
    
    // check contract balance 
    function checkBalance() public view returns(uint256) {
        return address(this).balance;
    }
    
    //check jackpot amount
    function checkJackpot() public view returns(uint256) {
        return jackpot / 1000000000000000000;
    }
    
    // allows creator to deposit funds to contract without playing game
    function deposit() public payable returns(bool) {
        if (msg.value > 0 ether) {
            return true;
        }
        return false;
    }

    modifier restricted() {
        require(msg.sender == manager);
        _;
    }
}