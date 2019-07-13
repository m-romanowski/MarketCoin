pragma solidity >= 0.5.0 < 0.6.0;

import "./SafeMath.sol";
import "./usingOraclize.sol";

contract MarketCoin is usingOraclize {
    // Use SafeMath library for uint256
    using SafeMath for uint256;

    //
    // VARIABLES
    //
    bool public oraclizeRecursiveQuery;
    address owner;
    address updater;

    //
    // EVENTS
    //
    event LogNewOraclizeQuery(string _message);
    event LogNewPrice(bytes32 _currency, uint256 _price, uint256 _timestamp);

    constructor() public payable {
        oraclize_setProof(proofType_Android | proofStorage_IPFS);

        // Remove that before production.
        // OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);

        // Set default values.
        owner = msg.sender;
        updater = msg.sender;
        oraclizeRecursiveQuery = false;

        // Initialize coins array for 3 currencies.
        // There u can use e.g. https://min-api.cryptocompare.com/ API for oraclize.
        currencies[bytes32("pln")] = Currency(0,
            "", true); // pln
        currencies[bytes32("eur")] = Currency(0,
            "", true); // eur
        currencies[bytes32("usd")] = Currency(0,
            "", true); // usd
    }

    // Store currency details: price, api (for oraclize queries), mark currency as existing.
    struct Currency {
        uint256 price; // Currency price in wei.
        string api; // Currency api for oraclize queries.
        bool init; // Check if currency already exists.
    }

    mapping(bytes32 => Currency) currencies;

    // Store oraclize query callback function details.
    struct OraclizeCallback {
        bytes32 currency; // Currency type, e.g. usd.
        uint256 timestamp; // Delay to the next oraclize query.
    }

    mapping(bytes32 => OraclizeCallback) oraclizeCallback;

    //
    // SERVER SUPPORT
    //

    /* Update currency price.
     * @param {bytes32} _currency - currency type in bytes32 format, e.g. usd => "0x757364"
     * @param {uint256} _value - given currency price in wei
     */
    function manualUpdate(bytes32 _currency, uint256 _value) external {
        require(currencies[_currency].init, "Cannot find given currency");
        require(msg.sender == updater, "Function for the smart contract updater");

        // Update currency price.
        currencies[_currency].price = _value;

        // Emit a new event with updated price.
        emit LogNewPrice(_currency, _value, now);
    }

    //
    // ORACLIZE SUPPORT
    //

    /* Oraclize callback function.
     * @param {bytes32} _queryId - oraclize query id
     * @param {string} - result from a oraclize query
     * @param {bytes} - authenticity proofs, https://docs.oraclize.it/#ethereum-quick-start-authenticity-proofs
     */
    function __callback(bytes32 _queryId, string memory _result, bytes memory _proof) public {
        require(msg.sender == oraclize_cbAddress(), "Callback function error");

        // Recursive update.
        if(oraclizeRecursiveQuery) {
            oraclizeUpdate(oraclizeCallback[_queryId].currency, oraclizeCallback[_queryId].timestamp);
        }

        // Update price.
        currencies[oraclizeCallback[_queryId].currency].price = toWei(_result);

        // Emit a new event with updated price.
        emit LogNewPrice(oraclizeCallback[_queryId].currency, currencies[oraclizeCallback[_queryId].currency].price, now);
    }

    /* Runs a new oraclize query.
     * @param {bytes32} _currency - currency type in bytes32 format, e.g. usd => "0x757364"
     * @param {uint256} _timestamp - delay to execute oraclize query.
     */
    function oraclizeUpdate(bytes32 _currency, uint256 _timestamp) public payable {
        require(currencies[_currency].init, "Cannot find given currency");

        // Check if there (in smart contract) is enough money.
        if (oraclize_getPrice("URL") > address(this).balance) {
            emit LogNewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee!");
        } else {
            emit LogNewOraclizeQuery("Oraclize query was sent, standing by for the answer...");

            // For query id.
            bytes32 queryId;

            // Check if oraclize_query should be called with a delay.
            if(_timestamp > 0) {
                queryId = oraclize_query(_timestamp, "URL", currencies[_currency].api); // Delay to next update
            } else {
                queryId = oraclize_query("URL", currencies[_currency].api); // Without delay.
            }

            // Save query details - query id and delay timestamp.
            oraclizeCallback[queryId] = OraclizeCallback(_currency, _timestamp);
        }
    }

    //
    // UTILS
    //

    /* Convert given string value to wei.
     * @param {string} _value - pric in a string format, e.g. "650.50"
     * @return {uint256} - converted value to wei
     */
    function toWei(string memory _value) public pure returns (uint256) {
        // Convert string to int, e.g. "650.50" => 65050
        uint256 valueInt = parseInt(_value, 2);

        // Convert price to wei (e.g. from $0.01, 0.01 pln)
        uint256 dividend = 1;
        uint256 weiValue = dividend.mul(1e18).div(valueInt);

        return weiValue;
    }

    /* Donations for a smart contract.
     */
    function sendEtherToSmartContract() external payable {
        require(msg.value > 0, "Not enough funds");
    }

    //
    // GETTERS
    //

    /* Gives currency details.
     * @param {bytes32} _currency - currency type, e.g. usd
     * @return {uint256, string} - current currency price, api
     */
    function getCurrencyDetails(bytes32 _currency) external view returns(uint256, string memory) {
        require(currencies[_currency].init, "Cannot find given currency");

        Currency memory currency = currencies[_currency];

        return(
            currency.price,
            currency.api
        );
    }

    /* Return current pln price.
     */
    function PLN() external view returns(uint256) {
        return currencies[bytes32("pln")].price;
    }

    /* Return current eur price.
     */
    function EUR() external view returns(uint256) {
        return currencies[bytes32("eur")].price;
    }

    /* Return current usd price.
     */
    function USD() external view returns(uint256) {
        return currencies[bytes32("usd")].price;
    }

    /* Return current gbp price.
     */
    function GBP() external view returns(uint256) {
        return currencies[bytes32("gbp")].price;
    }

    /* Gives currency price.
     * @param {bytes32} _currency - currency type, e.g. usd
     * @return {uint256} - current currency price
     */
    function getCurrencyPrice(bytes32 _currency) external view returns(uint256) {
        require(currencies[_currency].init, "Cannot find given currency");

        return currencies[_currency].price;
    }

    //
    // DEVELOPERS
    //

    /* Change smart contract owner.
     * @param {address} _owner - new smart contract owner address
     */
    function changeContractOwner(address _owner) external {
        require(msg.sender == owner, "Function for the smart contract developers");

        // Update a new smart contract owner.
        owner = _owner;
    }

    /* Add a new currency.
     * @param {bytes32} _currency - new currency type, e.g. usd
     * @param {string} _api - api for oraclize query update
     */
    function addCurrency(bytes32 _currency, string calldata _api) external {
        require(msg.sender == owner, "Function for the smart contract developers");
        require(currencies[_currency].init, "This currency already exists");

        // Set a new currency.
        currencies[_currency] = Currency(0, _api, true);
    }

    /* Change currency api.
     * @param {bytes32} _currency - currency type, e.g. usd
     * @param {string} _api - api for oraclize query update
     */
    function changeCurrencyAPI(bytes32 _currency, string calldata _api) external {
        require(msg.sender == owner, "Function for the smart contract developers");
        require(!currencies[_currency].init, "Cannot find given currency");

        // Set a new currency api.
        currencies[_currency].api = _api;
    }

    /* Enable / disable recursive oraclize updates.
     * @param {bool} _type - true / false (enable / disable)
     */
    function oraclizeSetRecursiveOption(bool _type) external {
        require(msg.sender == owner, "Function for the smart contract developers");

        oraclizeRecursiveQuery = _type;
    }

    /* Get smart contract balance.
     */
    function getSmartContractBalance() external view returns (uint256) {
        require(msg.sender == owner, "Function for the smart contract developers");

        return address(this).balance;
    }
}
