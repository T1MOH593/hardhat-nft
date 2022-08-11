// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error RandomIpfsNft__NeedMoreETHSent();
error RandomIpfsNft__RangeOutOfBounds();
error RandomIpfsNft__TransferFailed();

contract RandomIpfsNft is VRFConsumerBaseV2, ERC721URIStorage, Ownable {
    // 3 types of rarity: Mops, Kolly, Terrier
    enum Breed {
        MOPS,
        KOLLY,
        TERRIER
    }

    /* Nft variables */
    uint256 private s_counter;
    uint256 private immutable i_mintFee;
    uint256 private constant MAX_CHANCE_VALUE = 100;
    string[3] private s_tokenUris;
    mapping(uint256 => Breed) s_tokenIdToBreed;

    /* VRF helpers */
    mapping(uint256 => address) s_requestIdToAddress;

    /* VRF variables */
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private immutable i_callbackGasLimit;
    uint32 private constant NUM_WORDS = 1;

    /* Events */
    event NftRequested(uint256 indexed requestId, address indexed requester);
    event NftMinted(uint256 indexed tokenId, Breed indexed breed);

    constructor(
        address vrfCoordinator,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callbackGasLimit,
        uint256 mintFee,
        string[3] memory tokenUris
    ) VRFConsumerBaseV2(vrfCoordinator) ERC721("RandomIpfsNft", "RIN") {
        i_gasLane = gasLane;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinator);
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        s_counter = 1;
        i_mintFee = mintFee;
        s_tokenUris = tokenUris;
    }

    function requestRandomNft() external payable {
        if (msg.value < i_mintFee) {
            revert RandomIpfsNft__NeedMoreETHSent();
        }
        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );
        s_requestIdToAddress[requestId] = msg.sender;
        emit NftRequested(requestId, msg.sender);
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        address owner = s_requestIdToAddress[requestId];
        uint256 randomNumber = randomWords[0] % MAX_CHANCE_VALUE;
        Breed breed = getBreedFromRandomNumber(randomNumber);
        uint256 tokenId = s_counter++;
        _safeMint(owner, tokenId);
        _setTokenURI(tokenId, s_tokenUris[uint256(breed)]);
        s_tokenIdToBreed[tokenId] = breed;
        emit NftMinted(tokenId, breed);
    }

    function withdraw() external onlyOwner {
        uint256 amount = address(this).balance;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        if (!success) {
            revert RandomIpfsNft__TransferFailed();
        }
    }

    function getBreedFromRandomNumber(uint256 randomNumber) private pure returns (Breed) {
        uint256[3] memory chanceArray = getChanceArray();
        uint256 cumulativeSum = 0;
        for (uint256 i = 0; i < chanceArray.length; i++) {
            if (randomNumber >= cumulativeSum && randomNumber < chanceArray[i] + cumulativeSum) {
                return Breed(i);
            } else {
                cumulativeSum += chanceArray[i];
            }
        }
        revert RandomIpfsNft__RangeOutOfBounds();
    }

    function getChanceArray() public pure returns (uint256[3] memory) {
        return [10, 30, MAX_CHANCE_VALUE];
    }

    function getCounter() external view returns (uint256) {
        return s_counter;
    }

    function getMintFee() external view returns (uint256) {
        return i_mintFee;
    }

    function getTokenUri(uint256 index) external view returns (string memory) {
        return s_tokenUris[index];
    }

    function getBreed(uint256 tokenId) external view returns (Breed) {
        require(_exists(tokenId));
        return s_tokenIdToBreed[tokenId];
    }

    function getAddressFromRequestId(uint256 requestId) external view returns (address) {
        return s_requestIdToAddress[requestId];
    }
}
