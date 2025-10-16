// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title POIPOI
 * @dev Gold-backed stablecoin pegged to 1 gram of gold
 * @notice 1 POI = 1 gram of gold
 * @author POIPOI Team
 */
contract POIPOI is ERC20, Ownable, Pausable, ReentrancyGuard {
    // Events
    event TokensMinted(address indexed to, uint256 amount, uint256 goldPrice);
    event TokensBurned(address indexed from, uint256 amount, uint256 goldPrice);
    event EmergencyStop(bool stopped);

    // Constants
    uint256 public constant DECIMALS = 18;
    uint256 public constant INITIAL_SUPPLY = 0; // No initial supply, all tokens minted through manager

    // State variables
    address public manager; // Only the manager contract can mint/burn tokens
    bool public emergencyStopped = false;

    // Modifiers
    modifier onlyManager() {
        require(msg.sender == manager, "POIPOI: Only manager can call this function");
        _;
    }

    modifier notEmergencyStopped() {
        require(!emergencyStopped, "POIPOI: Contract is emergency stopped");
        _;
    }

    /**
     * @dev Constructor sets the initial owner and manager
     * @param _manager Address of the POIPOIManager contract
     */
    constructor(address _manager) ERC20("POIPOI", "POI") Ownable(msg.sender) {
        require(_manager != address(0), "POIPOI: Manager address cannot be zero");
        manager = _manager;
    }

    /**
     * @dev Mint POI tokens to a specific address
     * @param to Address to mint tokens to
     * @param amount Amount of tokens to mint (in wei)
     * @param goldPrice Current gold price for event logging
     */
    function mint(address to, uint256 amount, uint256 goldPrice)
        external
        onlyManager
        notEmergencyStopped
        whenNotPaused
        nonReentrant
    {
        require(to != address(0), "POIPOI: Cannot mint to zero address");
        require(amount > 0, "POIPOI: Amount must be greater than zero");

        _mint(to, amount);
        emit TokensMinted(to, amount, goldPrice);
    }

    /**
     * @dev Burn POI tokens from a specific address
     * @param from Address to burn tokens from
     * @param amount Amount of tokens to burn (in wei)
     * @param goldPrice Current gold price for event logging
     */
    function burn(address from, uint256 amount, uint256 goldPrice)
        external
        onlyManager
        notEmergencyStopped
        whenNotPaused
        nonReentrant
    {
        require(from != address(0), "POIPOI: Cannot burn from zero address");
        require(amount > 0, "POIPOI: Amount must be greater than zero");
        require(balanceOf(from) >= amount, "POIPOI: Insufficient balance to burn");

        _burn(from, amount);
        emit TokensBurned(from, amount, goldPrice);
    }

    /**
     * @dev Update the manager contract address
     * @param _manager New manager contract address
     */
    function updateManager(address _manager) external onlyOwner {
        require(_manager != address(0), "POIPOI: Manager address cannot be zero");
        manager = _manager;
    }

    /**
     * @dev Emergency stop function to halt all operations
     * @param stopped True to stop, false to resume
     */
    function setEmergencyStop(bool stopped) external onlyOwner {
        emergencyStopped = stopped;
        emit EmergencyStop(stopped);
    }

    /**
     * @dev Pause the contract
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @dev Unpause the contract
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @dev Override decimals to return 18 (standard for ERC20)
     */
    function decimals() public pure override returns (uint8) {
        return 18;
    }

    /**
     * @dev Get the current manager address
     */
    function getManager() external view returns (address) {
        return manager;
    }

    /**
     * @dev Check if contract is in emergency state
     */
    function isEmergencyStopped() external view returns (bool) {
        return emergencyStopped;
    }
}
