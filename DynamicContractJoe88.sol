// SPDX-License-Identifier: MIT

pragma solidity >=0.8.9 <0.9.0;

import 'erc721a/contracts/ERC721A.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/cryptography/MerkleProof.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';

contract DynamicContractJoe88 is ERC721A, Ownable, ReentrancyGuard {

  using Strings for uint256;

  uint256 public maxCharLimit = 120;

  bytes32 public merkleRoot;
  mapping(address => bool) public whitelistClaimed;

  //string public uriPrefix = '';
  string public uriSuffix = '.json';
  string public hiddenMetadataUri;
  string public phase0MetadataUri;
  string public phase1MetadataUri;
  string public phase2MetadataUri;
  string public phase3MetadataUri;
  string public phase4MetadataUri;
  //string public phase5MetadataUri;
  // string public phase6MetadataUri;
  
  uint256 public cost;
  uint256 public maxSupply;
  uint256 public maxMintAmountPerTx;

  bool public paused = true;
  bool public whitelistMintEnabled = false;
  bool public revealed = false;

//struct for message
  struct Page { 
      string message;
   }

  mapping (uint256 => Page) public pages;

//struct for w count
  struct Level { 
      uint256 count;
   }

  mapping (uint256 => Level) public levels;

//struct for w count
  struct Run { 
      uint256 lastRun;
   }

  mapping (uint256 => Run) public runs;
 
 
  constructor(
    string memory _tokenName,
    string memory _tokenSymbol,
    uint256 _cost,
    uint256 _maxSupply,
    uint256 _maxMintAmountPerTx,

    string memory _hiddenMetadataUri,
    string memory _phase0MetadataUri,
    string memory _phase1MetadataUri,
    string memory _phase2MetadataUri,
    string memory _phase3MetadataUri,
    string memory _phase4MetadataUri
    //string memory _phase5MetadataUri
    // string memory _phase6MetadataUri
  ) ERC721A(_tokenName, _tokenSymbol) {
    cost = _cost;
    maxSupply = _maxSupply;
    maxMintAmountPerTx = _maxMintAmountPerTx;
    setHiddenMetadataUri(_hiddenMetadataUri);
    setphase0MetadataUri(_phase0MetadataUri);
    setphase1MetadataUri(_phase1MetadataUri);
    setphase2MetadataUri(_phase2MetadataUri);
    setphase3MetadataUri(_phase3MetadataUri);
    setphase4MetadataUri(_phase4MetadataUri);
    //setphase5MetadataUri(_phase5MetadataUri);
    // setphase6MetadataUri(_phase6MetadataUri);
  }

  modifier mintCompliance(uint256 _mintAmount) {
    require(_mintAmount > 0 && _mintAmount <= maxMintAmountPerTx, 'Invalid mint amount!');
    require(totalSupply() + _mintAmount <= maxSupply, 'Max supply exceeded!');
    _;
  }

  modifier mintPriceCompliance(uint256 _mintAmount) {
    require(msg.value >= cost * _mintAmount, 'Insufficient funds!');
    _;
  }

  function whitelistMint(uint256 _mintAmount, bytes32[] calldata _merkleProof) public payable mintCompliance(_mintAmount) mintPriceCompliance(_mintAmount) {
    // Verify whitelist requirements
    require(whitelistMintEnabled, 'The whitelist sale is not enabled!');
    require(!whitelistClaimed[_msgSender()], 'Address already claimed!');
    bytes32 leaf = keccak256(abi.encodePacked(_msgSender()));
    require(MerkleProof.verify(_merkleProof, merkleRoot, leaf), 'Invalid proof!');

    whitelistClaimed[_msgSender()] = true;
    _safeMint(_msgSender(), _mintAmount);
  }

  function mint(uint256 _mintAmount) public payable mintCompliance(_mintAmount) mintPriceCompliance(_mintAmount) {
    require(!paused, 'The contract is paused!');
    uint256 supply = totalSupply();
    require(supply + 1 <= 20000, "Max supply reached");

    Page memory newPage = Page("");
    pages[supply + 1] = newPage;

    Level memory newLevel = Level(0);
    levels[supply + 1] = newLevel;

    Run memory newRun = Run(0);
    runs[supply + 1] = newRun;

    _safeMint(_msgSender(), _mintAmount);
  }
  
  function mintForAddress(uint256 _mintAmount, address _receiver) public mintCompliance(_mintAmount) onlyOwner {
    _safeMint(_receiver, _mintAmount);
  }

  function walletOfOwner(address _owner) public view returns (uint256[] memory) {
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory ownedTokenIds = new uint256[](ownerTokenCount);
    uint256 currentTokenId = _startTokenId();
    uint256 ownedTokenIndex = 0;
    address latestOwnerAddress;

    while (ownedTokenIndex < ownerTokenCount && currentTokenId <= maxSupply) {
      TokenOwnership memory ownership = _ownerships[currentTokenId];

      if (!ownership.burned && ownership.addr != address(0)) {
        latestOwnerAddress = ownership.addr;
      }

      if (latestOwnerAddress == _owner) {
        ownedTokenIds[ownedTokenIndex] = currentTokenId;

        ownedTokenIndex++;
      }

      currentTokenId++;
    }

    return ownedTokenIds;
  }

  function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

  function tokenURI(uint256 _tokenId) public view virtual override returns (string memory test) {
    require(_exists(_tokenId), 'ERC721Metadata: URI query for nonexistent token');
    Level storage currentLevel = levels[_tokenId];

    //sRo
    if(currentLevel.count == 0) {
      return string(abi.encodePacked(phase0MetadataUri, _tokenId.toString(), uriSuffix));
    }
    
    //sRa
    if(currentLevel.count == 1) {
      return string(abi.encodePacked(phase1MetadataUri, _tokenId.toString(), uriSuffix));
    }

    //sSun Gen
    if(currentLevel.count == 2) {
      return string(abi.encodePacked(phase2MetadataUri, _tokenId.toString(), uriSuffix));
    }

    //mlRa
    if(currentLevel.count == 3) {
      return string(abi.encodePacked(phase3MetadataUri, _tokenId.toString(), uriSuffix));
    }

    //mlSun Gen
    if(currentLevel.count == 4) {
      return string(abi.encodePacked(phase4MetadataUri, _tokenId.toString(), uriSuffix));
    }

    //final Gen
    if(currentLevel.count == 5) {
      return string(abi.encodePacked(hiddenMetadataUri, _tokenId.toString(), uriSuffix));
    }

    // //mlSun Gen
    // if(currentLevel.count == 5) {
    //   string memory currentBaseURI = _baseURI();
    //   return bytes(currentBaseURI).length > 0
    //       ? string(abi.encodePacked(currentBaseURI, _tokenId.toString(), uriSuffix))
    //       : '';
    // }

    // //Ssun Gen
    // if(currentLevel.count == 6) {
    //   return string(abi.encodePacked(phase6MetadataUri, _tokenId.toString(), uriSuffix));
    // }

    // //Ssun Gen
    // string memory currentBaseURI = _baseURI();
    // return bytes(currentBaseURI).length > 0
    //     ? string(abi.encodePacked(currentBaseURI, _tokenId.toString(), uriSuffix))
    //     : '';
  }

  function setRevealed(bool _state) public onlyOwner {
    revealed = _state;
  }

  function setCost(uint256 _cost) public onlyOwner {
    cost = _cost;
  }

  function setMaxMintAmountPerTx(uint256 _maxMintAmountPerTx) public onlyOwner {
    maxMintAmountPerTx = _maxMintAmountPerTx;
  }

  function setHiddenMetadataUri(string memory _hiddenMetadataUri) public onlyOwner {
    hiddenMetadataUri = _hiddenMetadataUri;
  }

  function setphase0MetadataUri(string memory _phase0MetadataUri) public onlyOwner {
    phase0MetadataUri = _phase0MetadataUri;
  }

  function setphase1MetadataUri(string memory _phase1MetadataUri) public onlyOwner {
    phase1MetadataUri = _phase1MetadataUri;
  }

  function setphase2MetadataUri(string memory _phase2MetadataUri) public onlyOwner {
    phase2MetadataUri = _phase2MetadataUri;
  }

  function setphase3MetadataUri(string memory _phase3MetadataUri) public onlyOwner {
    phase3MetadataUri = _phase3MetadataUri;
  }

  function setphase4MetadataUri(string memory _phase4MetadataUri) public onlyOwner {
    phase4MetadataUri = _phase4MetadataUri;
  }

  // function setphase5MetadataUri(string memory _phase5MetadataUri) public onlyOwner {
  //   phase5MetadataUri = _phase5MetadataUri;
  // }

  // function setphase6MetadataUri(string memory _phase6MetadataUri) public onlyOwner {
  //   phase6MetadataUri = _phase6MetadataUri;
  // }

  // function setUriPrefix(string memory _uriPrefix) public onlyOwner {
  //   uriPrefix = _uriPrefix;
  // }

  function setPaused(bool _state) public onlyOwner {
    paused = _state;
  }

  function setUriSuffix(string memory _uriSuffix) public onlyOwner {
    uriSuffix = _uriSuffix;
  }


  function setMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
    merkleRoot = _merkleRoot;
  }

  function setWhitelistMintEnabled(bool _state) public onlyOwner {
    whitelistMintEnabled = _state;
  }

  function setMessage(uint256 _tokenId, string memory _newMessage) public {
    require(msg.sender == ownerOf(_tokenId), "You are not the owner of this NFT.");
    bytes memory strBytes = bytes(_newMessage);
    require(strBytes.length <= maxCharLimit, "Message is too long.");
    Page storage currentPage = pages[_tokenId];
    currentPage.message = _newMessage;
  }

   function readMessage(uint256 _tokenId) public view returns (string memory message){
    Page memory currentPage = pages[_tokenId];
    return currentPage.message;
  }

  function setLevel(uint256 _tokenId) public {
    require(msg.sender == ownerOf(_tokenId), "You are not the owner of this NFT.");
    Run storage currentRun = runs[_tokenId];
    require(block.timestamp - currentRun.lastRun > 2 minutes, 'Need to wait 5 minutes');
    
    
    Level storage currentLevel = levels[_tokenId];
    currentLevel.count = (currentLevel.count + 1);

    if(currentLevel.count >= 5) {
      currentLevel.count = 0;
    }


    currentRun.lastRun = block.timestamp;
  }

  function stopW(uint256 _tokenId) public {
    require(msg.sender == ownerOf(_tokenId), "You are not the owner of this NFT.");
    Run storage currentRun = runs[_tokenId];
    require(block.timestamp - currentRun.lastRun > 1 minutes, 'Need to wait 5 minutes');
    
    
    Level storage currentLevel = levels[_tokenId];
    currentLevel.count = (currentLevel.count + 1);

    currentRun.lastRun = block.timestamp;
  }

   function readLevel(uint256 _tokenId) public view returns (uint256 level){
    Level memory currentLevel = levels[_tokenId];
    return currentLevel.count;
  }

   function readLastRunDelta(uint256 _tokenId) public view returns (uint256 timeDelta){
    Run storage currentRun = runs[_tokenId];
    uint256 currentTime = block.timestamp;
    return (currentTime - currentRun.lastRun);
   }

  function withdraw() public onlyOwner nonReentrant {
    // This will transfer the remaining contract balance to the owner.
    // Do not remove this otherwise you will not be able to withdraw the funds.
    // =============================================================================
    (bool os, ) = payable(owner()).call{value: address(this).balance}('');
    require(os);
    // =============================================================================
  }

  // function _baseURI() internal view virtual override returns (string memory) {
  //   return uriPrefix;
  // }
}