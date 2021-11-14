// SPDX-License-Identifier: MIT
// compiler version must be greater than or equal to 0.8.4 and less than 0.9.0
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

contract ArticlePunchcard is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    using SafeMath for uint;
    
    uint redemptionCost = .0008 ether;

    struct Punchcard {
        uint redemptionCount;
    }

    mapping(uint => Punchcard) public punchcardBalances;
    mapping(uint => address) public assetToOwner;
    mapping(address => uint) public ownerToAsset;
    mapping(address => mapping(uint => bool)) public ownerToArticles;

    modifier canBuy (uint _qty) {
        require(msg.value == (redemptionCost * _qty), "The amount sent is not equal to the amount required for this purchase");
        _;
    }

    constructor() ERC721("Article NFT Punchcard Concept", "PUNCH") {
        _tokenIds.increment();
    }

    receive() external payable {}
    fallback() external payable {}

    function setRedemptionCost(uint _price) external onlyOwner {
        redemptionCost = _price;
    }

    function getRedemptionCost() public view returns (uint) {
        return redemptionCost;
    }

    function mintPunchcard(uint _qty) internal {
        console.log("getting new token id");
        uint newTokenId = _tokenIds.current();
        _safeMint(msg.sender, newTokenId);
        assetToOwner[newTokenId] = msg.sender;
        ownerToAsset[msg.sender] = newTokenId;
        punchcardBalances[newTokenId] = Punchcard({redemptionCount: _qty});
        _tokenIds.increment();
        console.log("Minting a punchcard for %s with %s redemptions", msg.sender, _qty);
    }

    function purchasePunchcard(uint _qty) external payable canBuy(_qty) {
        // TO DO: require wallet does not alrealdy own a token
        mintPunchcard(_qty);
    }

    function getBalance(uint _tokenId) public view returns (uint) {
        return punchcardBalances[_tokenId].redemptionCount;
    }

    function addRedemptions(uint _qty, uint _tokenId) external payable canBuy(_qty) {
        require(msg.sender == assetToOwner[_tokenId], "You do not own this token");
        uint _ownerToken = ownerToAsset[msg.sender];
        uint _currentBalance = punchcardBalances[_ownerToken].redemptionCount;
        console.log("Current balance is %s", _currentBalance);
        punchcardBalances[_ownerToken].redemptionCount = _currentBalance.add(_qty);
        console.log("New balance is %s", punchcardBalances[_ownerToken].redemptionCount);
    }

    function assignAccessToArticle(uint _articleId) external {
        require(ownerToAsset[msg.sender] > 0, "You do not have a Punchcard. Mint one first");
        uint _tokenId = ownerToAsset[msg.sender];
        uint _currentBalance = punchcardBalances[_tokenId].redemptionCount;
        require(_currentBalance > 0, "You do not have any more redemptions left");
        ownerToArticles[msg.sender][_articleId] = true;
    }

    function accessToArticle(uint _articleId) external view returns (bool) {
        if (ownerToArticles[msg.sender][_articleId]) {
            return true;
        } else {
            return false;
        }
    }

    // TO DO
    // transfer function that only allowed to wallets that do not already have a token
}