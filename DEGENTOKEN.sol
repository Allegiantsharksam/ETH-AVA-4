// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

contract DegenToken {
    string public name;
    string public symbol;
    uint16 public decimals;
    uint256 public totalSupply;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;

    address public owner;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Mint(address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);
    event Redeem(address indexed from, string itemName);

    struct NftItem {
        string name;
        uint256 price;
    }

    mapping(uint256 => NftItem) public nftItems;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    constructor() {
        name = "Degen Gaming Token";
        symbol = "DEGEN";
        decimals = 18;
        totalSupply = 0;
        owner = msg.sender;
        addNftItem(0, "BAG", 200);
        addNftItem(1, "CAP", 100);
        addNftItem(2, "RC CAR", 2000);
        addNftItem(3, "FOOTBALL", 1000);
    }

    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        require(amount <= balances[msg.sender], "Insufficient balance.");

        balances[msg.sender] -= amount;
        balances[recipient] += amount;

        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        require(amount <= balances[sender], "Insufficient balance.");
        require(amount <= allowances[sender][msg.sender], "Insufficient allowance.");

        balances[sender] -= amount;
        balances[recipient] += amount;
        allowances[sender][msg.sender] -= amount;

        emit Transfer(sender, recipient, amount);
        return true;
    }

    function mint(address to, uint256 amount) external onlyOwner {
        totalSupply += amount;
        balances[to] += amount;

        emit Mint(to, amount);
        emit Transfer(address(0), to, amount);
    }

    function burn(uint256 amount) external {
        require(amount <= balances[msg.sender], "Insufficient balance.");

        balances[msg.sender] -= amount;
        totalSupply -= amount;

        emit Burn(msg.sender, amount);
        emit Transfer(msg.sender, address(0), amount);
    }

    function redeem(uint256 itemId) external returns (string memory) {
        require(balances[msg.sender] > 0, "Insufficient balance.");
        require(nftItems[itemId].price > 0, "Invalid item ID.");

        uint256 redemptionAmount = nftItems[itemId].price;
        require(balances[msg.sender] >= redemptionAmount, "Insufficient balance to redeem the item.");

        balances[msg.sender] -= redemptionAmount;

        emit Redeem(msg.sender, nftItems[itemId].name);

        return nftItems[itemId].name;
    }

    function addNftItem(uint256 itemId, string memory itemName, uint256 itemPrice) public onlyOwner {
        nftItems[itemId] = NftItem(itemName, itemPrice);
    }
}
