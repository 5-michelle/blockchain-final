// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
import {FlashLoanSimpleReceiverBase} from "https://github.com/aave/aave-v3-core/blob/master/contracts/flashloan/base/FlashLoanSimpleReceiverBase.sol";
import {IPoolAddressesProvider} from "https://github.com/aave/aave-v3-core/blob/master/contracts/interfaces/IPoolAddressesProvider.sol";
import {IERC20} from "https://github.com/aave/aave-v3-core/blob/master/contracts/dependencies/openzeppelin/contracts/IERC20.sol";
import { SafeMath } from "https://github.com/aave/aave-v3-core/contracts/dependencies/openzeppelin/contracts/SafeMath.sol";

// ----------------------INTERFACE------------------------------
// Uniswap
// Some helper function, it is totally fine if you can finish the lab without using these functions
interface IUniswapV2Router {

    function getAmountsOut(uint amountIn, address[] memory path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] memory path) external view returns (uint[] memory amounts);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external ;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns
     (uint amountToken, uint amountETH, uint liquidity);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (
      uint amountA, uint amountB, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

}

interface IUniswapV2Pair {
  function token0() external view returns (address);

  function token1() external view returns (address);

  function getReserves()
    external
    view
    returns (
      uint112 reserve0,
      uint112 reserve1,
      uint32 blockTimestampLast
    );

  function swap(
    uint amount0Out,
    uint amount1Out,
    address to,
    bytes calldata data
  ) external;
}

interface IUniswapV2Factory {
  function getPair(address token0, address token1) external view returns (address);
}

// ----------------------IMPLEMENTATION------------------------------

contract Flashloan is FlashLoanSimpleReceiverBase {

    address payable owner;

    // TODO: define constants used in the contract including ERC-20 tokens, Uniswap router, Aave address provider, etc.
    //  Aave V3 DAI address (Goerli testnet): 0xDF1742fE5b0bFc12331D8EAec6b478DfDbD31464
    //  Uniswap V2 router address (Goerli testnet): 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
    //    *** Your code here ***
    // put every token's address 
    address public address_A = 0x943161995EB5716d89421BeAfD49c6Cf0241a16d;
    address public address_B = 0xC795776151d42E4704344BBE6d2Fd2AA21Ab8826;

    // DAI and v2router's address are the same for everyone
    address public address_DAI = 0xDF1742fE5b0bFc12331D8EAec6b478DfDbD31464;
    address public router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    // END TODO

    using SafeMath for uint256;

    constructor(address _addressProvider) FlashLoanSimpleReceiverBase(IPoolAddressesProvider(_addressProvider)){
        // TODO: (optional) initialize your contract

        owner = payable(msg.sender);

        // END TODO
    }

    /**
     * Allows users to access liquidity of one reserve or one transaction as long as the amount taken plus fee is returned.
     * @param _asset The address of the asset you want to borrow
     * @param _amount The borrow amount
     **/
    // Doc: https://docs.aave.com/developers/core-contracts/pool#flashloansimple
    function RequestFlashLoan(address _asset, uint256 _amount) public {
        address receiverAddress = address(this);
        address asset = _asset;
        uint256 amount = _amount;
        bytes memory params = "";
        uint16 referralCode = 0;

        // POOL comes from FlashLoanSimpleReceiverBase
        POOL.flashLoanSimple(
            receiverAddress,
            asset,
            amount,
            params,
            referralCode
        );
    }

    /**
     * This function is called after your contract has received the flash loaned amount
     * @param asset The address of the asset you want to borrow
     * @param amount The borrow amount
     * @param premium The borrow fee
     * @param initiator The address initiates this function
     * @param params Arbitrary bytes-encoded params passed from flash loan
     * @return  true or false
     **/
    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    )
        external
        override
        returns (bool)
    {

// -DAI to A-

        IERC20(address_DAI).approve(router, amount);
        
        address[] memory path1;
        path1 = new address[](2);
        path1[0] = address_DAI;
        path1[1] = address_A;

        uint amountsA = IUniswapV2Router(router).swapExactTokensForTokens(
            amount,
            0,
            path1,
            //msg.sender, 合約是拿閃電貸的錢，所以用 address(this) 比較保險
            address(this),
            block.timestamp
            )[1];


// -A to B-
   
        IERC20(address_A).approve(router, amountsA);

        address[] memory path2;
        path2 = new address[](2);
        path2[0] = address_A;
        path2[1] = address_B;
        
        uint amountsB = IUniswapV2Router(router).swapExactTokensForTokens(
            amountsA,
            0,
            path2,
            //msg.sender,
            address(this),
            block.timestamp
            )[1];


// -B to DAI-

        IERC20(address_B).approve(router, amountsB);
        
        address[] memory path3;
        path3 = new address[](2);
        path3[0] = address_B;
        path3[1] = address_DAI;

        uint amountsDAI = IUniswapV2Router(router).swapExactTokensForTokens(
            amountsB,
            0,
            path3,
            //msg.sender,
            address(this),
            block.timestamp
            )[1];           


        // Don't forget to payback the amount of the borrowed asset + flash loan fee 

        uint256 amount_owed = amount + premium;
        IERC20(asset).approve(address(POOL),amount_owed);

        // END TODO
        return true;
    }

    function getBalance(address _tokenAddress) external view returns (uint256) {
        return IERC20(_tokenAddress).balanceOf(address(this));
    }

    function withdraw(address _tokenAddress) external onlyOwner {
        IERC20 token = IERC20(_tokenAddress);
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only the contract owner can call this function"
        );
        _;
    }

    receive() external payable {}

}