// SPDX-License-Identifier: MIT
// elcharitas Smart Contracts (github.com/elcharitas)

pragma solidity ^0.8.6;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';

contract MangaMinter is ERC721 {

  // the address of this NFT publisher
  address public publisher;

  // the cost set by publisher of NFT
  uint public txFeeAmount;

  // list of addresses which should not pay any fee
  mapping(address => bool) public excludedList;

  // the uri to metadata stored on ipfs
  string public tokenUri;

  constructor(
    address _publisher,
    uint _txFeeAmount
  ) ERC721('MangaKo', 'MGK') {
    publisher = _publisher;
    txFeeAmount = _txFeeAmount;
    excludedList[_publisher] = true;
  }

  function setExcluded(address excluded, bool status) external {
    require(msg.sender == publisher, 'only publisher can exclude');
    excludedList[excluded] = status;
  }

  function mint(address owner, string memory tokenDataUri) external {
    setTokenUri(tokenDataUri);
    _mint(owner, 0);
  }

  function setTokenUri(string memory uri) public {
    tokenUri = uri;
  }

  function tokenURI(uint256 tokenId) 
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(bytes(tokenUri).length > 0, 'Set token URI first');
    require(_exists(tokenId), 'The  token does not exist');
    return tokenUri;
  }

  function transferFrom(
    address from, 
    address to, 
    uint256 tokenId
  ) public override {
     require(
       _isApprovedOrOwner(_msgSender(), tokenId), 
       'ERC721: transfer caller is not owner nor approved'
     );
     if(excludedList[from] == false) {
      _payTxFee(from);
     }
     _transfer(from, to, tokenId);
  }

  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId
   ) public override {
     if(excludedList[from] == false) {
       _payTxFee(from);
     }
     safeTransferFrom(from, to, tokenId, '');
   }

  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId,
    bytes memory _data
  ) public override {
    require(
      _isApprovedOrOwner(_msgSender(), tokenId), 
      'ERC721: transfer caller is not owner nor approved'
    );
    if(excludedList[from] == false) {
      _payTxFee(from);
    }
    _safeTransfer(from, to, tokenId, _data);
  }

  function _payTxFee(address from) internal {
    (bool paidRoyalty,) = payable(publisher).call{value: address(this).balance * 5 / 100}("");
    require(paidRoyalty);

    (bool paidOwner,) = payable(from).call{value: address(this).balance}("");
    require(paidOwner);
  }
}
