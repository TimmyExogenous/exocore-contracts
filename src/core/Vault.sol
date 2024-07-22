// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ILSTRestakingController} from "../interfaces/ILSTRestakingController.sol";
import {IVault} from "../interfaces/IVault.sol";
import {VaultStorage} from "../storage/VaultStorage.sol";

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title Vault
/// @author ExocoreNetwork
/// @notice Implementation of IVault, used to store user tokens. Each Vault is unique to an
/// underlying token and is controlled by a gateway.
contract Vault is Initializable, VaultStorage, IVault {

    using SafeERC20 for IERC20;

    /// @dev Allows only the gateway to call the function.
    modifier onlyGateway() {
        require(msg.sender == address(gateway), "Vault: caller is not the gateway");
        _;
    }

    /// @dev This constructor disables initialization so that the proxy pattern can be used.
    constructor() {
        _disableInitializers();
    }

    /// @notice Initializes the Vault contract.
    /// @param underlyingToken_ The address of the underlying token.
    /// @param gateway_ The address of the gateway contract.
    function initialize(address underlyingToken_, address gateway_) external initializer {
        require(underlyingToken_ != address(0), "Vault: underlying token can not be empty");
        require(gateway_ != address(0), "VaultStorage: the gateway address should not be empty");

        underlyingToken = IERC20(underlyingToken_);
        gateway = ILSTRestakingController(gateway_);
    }

    /// @inheritdoc IVault
    function getUnderlyingToken() public view returns (address) {
        return address(underlyingToken);
    }

    /// @notice Gets the withdrawable balance of a user.
    /// @param withdrawer Address of the user who wants to withdraw tokens.
    function getWithdrawableBalance(address withdrawer) external view returns (uint256 balance) {
        return withdrawableBalances[withdrawer];
    }

    /// @inheritdoc IVault
    function withdraw(address withdrawer, address recipient, uint256 amount) external onlyGateway {
        require(
            amount <= withdrawableBalances[withdrawer],
            "Vault: withdrawal amount is larger than depositor's withdrawable balance"
        );

        withdrawableBalances[withdrawer] -= amount;
        underlyingToken.safeTransfer(recipient, amount);

        emit WithdrawalSuccess(withdrawer, recipient, amount);
    }

    /// @inheritdoc IVault
    // Though `safeTransferFrom` has arbitrary passed in `depositor` as sender, this function is only callable by
    // `gateway` and `gateway` would make sure only the `msg.sender` would be the depositor.
    // slither-disable-next-line arbitrary-send-erc20
    function deposit(address depositor, uint256 amount) external payable onlyGateway {
        underlyingToken.safeTransferFrom(depositor, address(this), amount);
        totalDepositedPrincipalAmount[depositor] += amount;
    }

    /// @inheritdoc IVault
    function updatePrincipalBalance(address user, uint256 lastlyUpdatedPrincipalBalance) external onlyGateway {
        principalBalances[user] = lastlyUpdatedPrincipalBalance;

        emit PrincipalBalanceUpdated(user, lastlyUpdatedPrincipalBalance);
    }

    /// @inheritdoc IVault
    function updateRewardBalance(address user, uint256 lastlyUpdatedRewardBalance) external onlyGateway {
        rewardBalances[user] = lastlyUpdatedRewardBalance;

        emit RewardBalanceUpdated(user, lastlyUpdatedRewardBalance);
    }

    /// @inheritdoc IVault
    function updateWithdrawableBalance(address user, uint256 unlockPrincipalAmount, uint256 unlockRewardAmount)
        external
        onlyGateway
    {
        uint256 totalDeposited = totalDepositedPrincipalAmount[user];
        require(
            unlockPrincipalAmount <= totalDeposited,
            "Vault: principal unlock amount is larger than the total deposited amount"
        );

        totalUnlockPrincipalAmount[user] += unlockPrincipalAmount;
        require(
            totalUnlockPrincipalAmount[user] <= totalDeposited,
            "Vault: total principal unlock amount is larger than the total deposited amount"
        );

        withdrawableBalances[user] = withdrawableBalances[user] + unlockPrincipalAmount + unlockRewardAmount;

        emit WithdrawableBalanceUpdated(user, unlockPrincipalAmount, unlockRewardAmount);
    }

}
