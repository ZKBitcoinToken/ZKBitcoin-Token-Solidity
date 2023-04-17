//testing new zkBTC
/**
 *Submitted for verification at Etherscan.io on 2023-04-04
*/

// Arbitrum Bitcoin and Staking (ABAS) - Token and Mining Contract
//
// Distrubtion of Arbitrum Bitcoin and Staking (ABAS) Token is as follows:
// 40% of ABAS Token is distributed as Liquidiy Pools as rewards in the ABASRewards Contract which distributes tokens to users who deposit the Liquidity Pool tokens into the LPRewards contracts.
// +
// 40% of ABAS Token is distributed using ABAS Contract(this Contract) which distributes tokens to users by using Proof of work. Computers solve a complicated problem to gain tokens!
// +
// 20% of ABAS Token is Auctioned in the ABASAuctions Contract which distributes tokens to users who use Ethereum to buy tokens in fair price. Each auction lasts ~12 days. Using the Auctions contract.
// +
// = 100% Of the Token is distributed to the users! No dev fee or premine!
//
	
// Symbol: ABAS
// Decimals: 18 
//
// Total supply: 52,500,001.000000000000000000
//   =
// 21,000,000 tokens goes to Liquidity Providers of the token over 100+ year using Bitcoin distribution!  Helps prevent LP losses!  Uses the ABASRewards!
//   +
// 21,000,000 Mined over 100+ years using Bitcoins Distrubtion halvings every 4 years @ 360 min solves. Uses Proof-oF-Work to distribute the tokens. Public Miner is available.  Uses this contract.
//   +
// 10,500,000 Auctioned over 100+ years into 4 day auctions split fairly among all buyers. ALL Ethereum proceeds go into THIS contract which it fairly distributes to miners and stakers.  Uses the ABASAuctions contract
//  
//
//      
// 50% of the Ethereum from this contract goes to the Miner to pay for the transaction cost and if the token grows enough earn Ethereum per mint!
// 50% of the Ethereum from this contract goes to the Liquidity Providers via ABASRewards Contract.  Helps prevent Impermant Loss! Larger Liquidity!
//
// Max Difficulty of 4 TH/s
// To prevent hashrate griefing at targetTime it is ~0.0001 Ethereum per Mint
// @ 30x targetTime it is ~0.0000033 Ethereum per Mint
// This is done to thwart ASICs and high hashrate machines from griefing / ramping difficulty up to stop FPGA profits
//
// No premine, dev cut, or advantage taken at launch. Public miner available at launch.  100% of the token is given away fairly over 100+ years using Bitcoins model!
//
// Send this contract any ERC20 token and it will become instantly mineable and able to distribute using proof-of-work!
// Donate this contract any NFT and we will also distribute it via Proof of Work to our miners!  
//  
//* 1 token were burned to create the LP pool.
//
// Credits: 0xBitcoin, Vether, Synethix


pragma solidity ^0.8.11;

contract Ownable {
    address public owner;

    event TransferOwnership(address _from, address _to);

    constructor() {
        owner = msg.sender;
        emit TransferOwnership(address(0), msg.sender);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner");
        _;
    }

    function setOwner(address _owner) internal onlyOwner {
        emit TransferOwnership(owner, _owner);
        owner = _owner;
    }
}


library IsContract {
    function isContract(address _addr) internal view returns (bool) {
        bytes32 codehash;
        /* solium-disable-next-line */
        assembly { codehash := extcodehash(_addr) }
        return codehash != bytes32(0) && codehash != bytes32(0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470);
    }
}

// File: contracts/utils/SafeMath.sol

library SafeMath2 {
    function add(uint256 x, uint256 y) internal pure returns (uint256) {
        uint256 z = x + y;
        require(z >= x, "Add overflow");
        return z;
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256) {
        require(x >= y, "Sub underflow");
        return x - y;
    }

    function mult(uint256 x, uint256 y) internal pure returns (uint256) {
        if (x == 0) {
            return 0;
        }

        uint256 z = x * y;
        require(z / x == y, "Mult overflow");
        return z;
    }

    function div(uint256 x, uint256 y) internal pure returns (uint256) {
        require(y != 0, "Div by zero");
        return x / y;
    }

    function divRound(uint256 x, uint256 y) internal pure returns (uint256) {
        require(y != 0, "Div by zero");
        uint256 r = x / y;
        if (x % y != 0) {
            r = r + 1;
        }

        return r;
    }
}

// File: contracts/utils/Math.sol

library ExtendedMath2 {


    //return the smaller of the two inputs (a or b)
    function limitLessThan(uint a, uint b) internal pure returns (uint c) {

        if(a > b) return b;

        return a;

    }
}

// File: contracts/interfaces/IERC20.sol

interface IERC20 {
	function totalSupply() external view returns (uint256);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);
    function approve(address _spender, uint256 _value) external returns (bool success);
    function balanceOf(address _owner) external view returns (uint256 balance);
    
}



contract ArbitrumBitcoinAndStaking is Ownable, IERC20 {

    function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
    
    function onERC1155Received(address, address, uint256, uint256, bytes calldata) external pure returns (bytes4){
	return IERC1155Receiver.onERC1155Received.selector;
	}	
    function onERC1155BatchReceived(address, address, uint256, uint256, bytes calldata) external pure returns (bytes4){
	return IERC1155Receiver.onERC1155Received.selector;
	}
	
    uint public targetTime = 60 * 12;
// SUPPORTING CONTRACTS
    address public AddressAuction;
    ABASAuctionsCT public AuctionsCT;
    address public AddressLPReward;
//Events
    using SafeMath2 for uint256;
    using ExtendedMath2 for uint;
    event Mint(address indexed from, uint reward_amount, uint epochCount, bytes32 newChallengeNumber);
    event MegaMint(address indexed from, uint epochCount, bytes32 newChallengeNumber, uint NumberOfTokensMinted, uint256 TokenMultipler);

// Managment events
    uint256 override public totalSupply = 52500001000000000000000000;
    bytes32 private constant BALANCE_KEY = keccak256("balance");
    //BITCOIN INITALIZE Start
	
    uint _totalSupply = 21000000000000000000000000;
    uint public latestDifficultyPeriodStarted2 = block.timestamp; //BlockTime of last readjustment
    uint public epochCount = 0;//number of 'blocks' mined
	uint public latestreAdjustStarted = block.timestamp; 
    uint public _BLOCKS_PER_READJUSTMENT = 1024; // should be 1024
    uint public  _MAXIMUM_TARGET = 2**234;
    uint public  _MINIMUM_TARGET = _MAXIMUM_TARGET.div(555000000); //Mainnet = 555000000 = 4 TH/s @ 12 minutes
    uint public miningTarget = _MAXIMUM_TARGET.div(200000000000*25);  //1000 million difficulty to start until i enable mining
    
    bytes32 public challengeNumber = block.blockhash(block.number - 1);   //generate a new one when a new reward is minted
    uint public rewardEra = 0;
    uint public maxSupplyForEra = (_totalSupply - _totalSupply.div( 2**(rewardEra + 1)));
    uint public reward_amount = 2;
    
    //Stuff for Functions
	uint public sentToLP = 0; //Total ABAS sent to LP pool
    uint public multipler = 0; //Multiplier on held Ethereum (more we hold less % we distribute)
    uint public oldecount = 0; //Previous block count for ArewardSender function
    uint public previousBlockTime  =  block.timestamp; // Previous Blocktime
    uint public Token2Per=           1000000; //Amount of ETH distributed per mint somewhat
    uint public tokensMinted = 0;			//Tokens Minted only for Miners
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    uint public slowBlocks = 0; //Number of slow blocks (12+ minutes)
    uint public epochOld = 0;  //Epoch count at each readjustment 
    uint public give0x = 0;
    uint public give = 1;
    // metadata
    string public name = "Arbitrum Bitcoin and Staking Token";
    string public constant symbol = "ABAS";
    uint8 public constant decimals = 18;
	
    uint256 lastrun = block.timestamp;
    uint public latestDifficultyPeriodStarted = block.number;
    bool initeds = false;
    
    // mint 1 token to setup LPs
	    constructor() {
    balances[msg.sender] = 1000000000000000000;
    emit Transfer(address(0), msg.sender, 1000000000000000000);
	}

function zinit(address AuctionAddress2, address LPGuild2) public onlyOwner{
        uint x = 21000000000000000000000000; 
        // Only init once
        assert(!initeds);
        initeds = true;
	previousBlockTime = block.timestamp;
	reward_amount = 20 * 10**uint(decimals);
    	rewardEra = 0;
	tokensMinted = 0;
	epochCount = 0;
	epochOld = 0;
	multipler = address(this).balance / (1 * 10 ** 18); 	
	Token2Per = (2** rewardEra) * address(this).balance / (250000 + 250000*(multipler)); //aimed to give about 400 days of reserves

    	miningTarget = _MAXIMUM_TARGET.div(1000);
        latestDifficultyPeriodStarted2 = block.timestamp;
    	_startNewMiningEpoch();
        // Init contract variables and mint
        balances[AuctionAddress2] = x/2;
	
        emit Transfer(address(0), AuctionAddress2, x/2);
	
    	AddressAuction = AuctionAddress2;
        AuctionsCT = ABASAuctionsCT(AddressAuction);
        AddressLPReward = payable(LPGuild2);
		slowBlocks = 1;
        oldecount = epochCount;
	
	setOwner(address(0));
     
    }



	///
	// Managment
	///
/* DONT USE FOR ZKBTC*/
	function ARewardSender() public {
		//runs every _BLOCKS_PER_READJUSTMENT / 8

		multipler = address(this).balance / (1 * 10 ** 18); 	
		Token2Per = (2** rewardEra) * address(this).balance / (250000 + 250000*(multipler)); //aimed to give about 400 days of reserves

		uint256 runs = block.timestamp - lastrun;

		uint256 epochsPast = epochCount - oldecount; //actually epoch
		uint256 runsperepoch = runs / epochsPast;
		if(rewardEra < 8){
			
			targetTime = ((12 * 60) * 2**rewardEra);
		}else{
			reward_amount = ( 20 * 10**uint(decimals)).div( 2**(rewardEra - 7  ) );
		}
		uint256 x = (runsperepoch * 888).divRound(targetTime);
		uint256 ratio = x * 100 / 888;
		uint256 totalOwed;
		
		 if(ratio < 2000){
			totalOwed = (508606*(15*x**2)).div(888 ** 2)+ (9943920 * (x)).div(888);
		 }else {
			totalOwed = (3200000000);
		} 

		uint totalOwedABAS = (epochsPast * reward_amount * totalOwed).div(100000000);
		balances[AddressLPReward] = balances[AddressLPReward].add(totalOwedABAS);
		emit Transfer(address(0), AddressLPReward, totalOwedABAS);
		sentToLP = sentToLP.add(totalOwedABAS);
		if( address(this).balance > (200 * (Token2Per * _BLOCKS_PER_READJUSTMENT)/4)){  // at least enough blocks to rerun this function for both LPRewards and Users
			//IERC20(AddressZeroXBTC).transfer(AddressLPReward, ((epochsPast) * totalOwed * Token2Per * give0xBTC).div(100000000));
          	 address payable to = payable(AddressLPReward);
			 totalOwed = ((epochsPast) * totalOwed * Token2Per * give0x).div(100000000);
           	to.transfer(totalOwed);
           		 give0x = 1 * give;
		}else{
			give0x = 0;
		}
		
		oldecount = epochCount; //actually epoch

		lastrun = block.timestamp;
	}

*/
	//comability function
	function mint(uint256 nonce, bytes32 challenge_digest) public payable returns (bool success) {
		mintTo(nonce, challenge_digest, msg.sender);
		return true;
	}
	
	function mintTo(uint256 nonce, bytes32 challenge_digest, address mintToAddress) public payable returns (uint256 totalOwed) {

		bytes32 digest =  keccak256(abi.encodePacked(challengeNumber, msg.sender, nonce));

		//the challenge digest must match the expected
		require(digest == challenge_digest, "Old challenge_digest or wrong challenge_digest");

		//the digest must be smaller than the target
		require(uint256(digest) < miningTarget, "Digest must be smaller than miningTarget");
		_startNewMiningEpoch();


		
		balances[mintToAddress] = balances[mintToAddress].add(reward_amount);
		
    emit Transfer(address(0), mintToAddress, reward_amount);
		
		tokensMinted = tokensMinted.add(reward_amount);

		emit Mint(mintToAddress, reward_amount, epochCount, challengeNumber );

		return totalOwed;

	}
	
	
	function blocksToReadjust() public view returns (uint blocks){
		if((epochCount - epochOld) == 0){
			if(give == 1){
				return (_BLOCKS_PER_READJUSTMENT);
			}else{
				return (_BLOCKS_PER_READJUSTMENT / 8);
			}
		}
		uint256 blktimestamp = block.timestamp;
		uint TimeSinceLastDifficultyPeriod2 = blktimestamp - latestreAdjustStarted;
		uint adjusDiffTargetTime = targetTime * ((epochCount - epochOld) % (_BLOCKS_PER_READJUSTMENT/8)); 

		if( TimeSinceLastDifficultyPeriod2 > adjusDiffTargetTime)
		{
				blocks = _BLOCKS_PER_READJUSTMENT/8 - ((epochCount - epochOld) % (_BLOCKS_PER_READJUSTMENT/8));
				return (blocks);
		}else{
			    blocks = _BLOCKS_PER_READJUSTMENT - ((epochCount - epochOld) % _BLOCKS_PER_READJUSTMENT);
			    return (blocks);
		}
	
	}


	function _startNewMiningEpoch() internal {


		//if max supply for the era will be exceeded next reward round then enter the new era before that happens
		//15 is the final reward era, almost all tokens minted
		if( tokensMinted.add(reward_amount) > maxSupplyForEra && rewardEra < 15)
		{
			rewardEra = rewardEra + 1;
			maxSupplyForEra = _totalSupply - _totalSupply.div( 2**(rewardEra + 1));
			if(rewardEra < 8){
				_MINIMUM_TARGET	= _MINIMUM_TARGET.div(2);
				targetTime = ((12 * 60) * 2**rewardEra);
				if(rewardEra < 6){
					if(_BLOCKS_PER_READJUSTMENT <= 16){
						_BLOCKS_PER_READJUSTMENT = 8;
					}else{
						_BLOCKS_PER_READJUSTMENT = _BLOCKS_PER_READJUSTMENT / 2;
					}
				}
			}else{
				reward_amount = ( 50 * 10**uint(decimals)).div( 2**(rewardEra - 7  ) );
			}
		}

		//set the next minted supply at which the era will change
		// total supply of MINED tokens is 21000000000000000000000000  because of 18 decimal places

		epochCount = epochCount.add(1);

		//every so often, readjust difficulty. Dont readjust when deploying
		if((epochCount - epochOld) % (_BLOCKS_PER_READJUSTMENT / 8) == 0)
		{
			// ARewardSender(); //DONT USE FOR ZKBTC
			maxSupplyForEra = _totalSupply - _totalSupply.div( 2**(rewardEra + 1));

			uint256 blktimestamp = block.timestamp;
			uint TimeSinceLastDifficultyPeriod2 = blktimestamp - latestreAdjustStarted;
			uint adjusDiffTargetTime = targetTime *  (_BLOCKS_PER_READJUSTMENT / 8) ; 
			latestreAdjustStarted = block.timestamp;

			if( TimeSinceLastDifficultyPeriod2 > adjusDiffTargetTime || (epochCount - epochOld) % _BLOCKS_PER_READJUSTMENT == 0) 
			{
				_reAdjustDifficulty();
			}
		}
    
    
		challengeNumber = block.blockhash(block.number - 1);
 }


	function reAdjustsToWhatDifficulty() public view returns (uint difficulty) {
		if(epochCount - epochOld == 0){
			return _MAXIMUM_TARGET.div(miningTarget);
		}
		uint256 blktimestamp = block.timestamp;
		uint TimeSinceLastDifficultyPeriod2 = blktimestamp - latestDifficultyPeriodStarted2;
		uint epochTotal = epochCount - epochOld;
		uint adjusDiffTargetTime = targetTime *  epochTotal; 
        uint miningTarget2 = 0;
		//if there were less eth blocks passed in time than expected
		if( TimeSinceLastDifficultyPeriod2 < adjusDiffTargetTime )
		{
			uint excess_block_pct = (adjusDiffTargetTime.mult(100)).div( TimeSinceLastDifficultyPeriod2 );
			uint excess_block_pct_extra = excess_block_pct.sub(100).limitLessThan(1000);
			//make it harder 
			miningTarget2 = miningTarget.sub(miningTarget.div(2000).mult(excess_block_pct_extra));   //by up to 50 %
		}else{
			uint shortage_block_pct = (TimeSinceLastDifficultyPeriod2.mult(100)).div( adjusDiffTargetTime );

			uint shortage_block_pct_extra = shortage_block_pct.sub(100).limitLessThan(1000); //always between 0 and 1000
			//make it easier
			miningTarget2 = miningTarget.add(miningTarget.div(500).mult(shortage_block_pct_extra));   //by up to 200 %
		}

		if(miningTarget2 < _MINIMUM_TARGET) //very difficult
		{
			miningTarget2 = _MINIMUM_TARGET;
		}
		if(miningTarget2 > _MAXIMUM_TARGET) //very easy
		{
			miningTarget2 = _MAXIMUM_TARGET;
		}
		difficulty = _MAXIMUM_TARGET.div(miningTarget2);
			return difficulty;
	}


	function _reAdjustDifficulty() internal {
		uint256 blktimestamp = block.timestamp;
		uint TimeSinceLastDifficultyPeriod2 = blktimestamp - latestDifficultyPeriodStarted2;
		uint epochTotal = epochCount - epochOld;
		uint adjusDiffTargetTime = targetTime *  epochTotal; 
		epochOld = epochCount;

		//if there were less eth blocks passed in time than expected
		if( TimeSinceLastDifficultyPeriod2 < adjusDiffTargetTime )
		{
			uint excess_block_pct = (adjusDiffTargetTime.mult(100)).div( TimeSinceLastDifficultyPeriod2 );
			give = 1;
			uint excess_block_pct_extra = excess_block_pct.sub(100).limitLessThan(1000);
			//make it harder 
			miningTarget = miningTarget.sub(miningTarget.div(2000).mult(excess_block_pct_extra));   //by up to 50 %
		}else{
			uint shortage_block_pct = (TimeSinceLastDifficultyPeriod2.mult(100)).div( adjusDiffTargetTime );
			give = 2;
			uint shortage_block_pct_extra = shortage_block_pct.sub(100).limitLessThan(1000); //always between 0 and 1000
			//make it easier
			miningTarget = miningTarget.add(miningTarget.div(500).mult(shortage_block_pct_extra));   //by up to 200 %
		}

		latestDifficultyPeriodStarted2 = blktimestamp;
		latestDifficultyPeriodStarted = block.number;
		if(miningTarget < _MINIMUM_TARGET) //very difficult
		{
			miningTarget = _MINIMUM_TARGET;
		}
		if(miningTarget > _MAXIMUM_TARGET) //very easy
		{
			miningTarget = _MAXIMUM_TARGET;
		}
		
	}


//Stat Functions

	function inflationMined () public view returns (uint YearlyInflation, uint EpochsPerYear, uint RewardsAtTime, uint TimePerEpoch){
		if(epochCount - epochOld == 0){
			return (0, 0, 0, 0);
		}
		uint256 blktimestamp = block.timestamp;
		uint TimeSinceLastDifficultyPeriod2 = blktimestamp - latestDifficultyPeriodStarted2;

        
		TimePerEpoch = TimeSinceLastDifficultyPeriod2 / blocksFromReadjust(); 
		RewardsAtTime = rewardAtTime(TimePerEpoch);
		uint year = 365 * 24 * 60 * 60;
		EpochsPerYear = year / TimePerEpoch;
		YearlyInflation = RewardsAtTime * EpochsPerYear;
		return (YearlyInflation, EpochsPerYear, RewardsAtTime, TimePerEpoch);
	}

	
	function toNextEraDays () public view returns (uint daysToNextEra, uint _maxSupplyForEra, uint _tokensMinted, uint amtDaily){

        (uint totalamt,,,) = inflationMined();
		(amtDaily) = totalamt / 365;
		if(amtDaily == 0){
			return(0,0,0,0);
		}
		daysToNextEra = (maxSupplyForEra - tokensMinted) / amtDaily;
		return (daysToNextEra, maxSupplyForEra, tokensMinted, amtDaily);
	}
	

	function toNextEraEpochs () public view returns ( uint epochs, uint epochTime, uint daysToNextEra){
		if(blocksFromReadjust() == 0){
			return (0,0,0);
        }
		uint256 blktimestamp = block.timestamp;
        uint TimeSinceLastDifficultyPeriod2 = blktimestamp - latestDifficultyPeriodStarted2;
		uint timePerEpoch = TimeSinceLastDifficultyPeriod2 / blocksFromReadjust();
		(uint daysz,,,) = toNextEraDays();
		uint amt = daysz * (60*60*24) / timePerEpoch;
		return (amt, timePerEpoch, daysz);
	}

	//help debug mining software
	function checkMintSolution(uint256 nonce, bytes32 challenge_digest, bytes32 challenge_number, uint testTarget) public view returns (bool success) {
		bytes32 digest = bytes32(keccak256(abi.encodePacked(challenge_number,msg.sender,nonce)));
		if(uint256(digest) > testTarget) revert();

		return (digest == challenge_digest);
	}

	function checkMintSolutionForAddress(uint256 nonce, bytes32 challenge_digest, bytes32 challenge_number, uint testTarget, address sender) public view returns (bool success) {
		bytes32 digest = bytes32(keccak256(abi.encodePacked(challenge_number,sender,nonce)));
		if(uint256(digest) > testTarget) revert();

		return (digest == challenge_digest);
	}


	//this is a recent ethereum block hash, used to prevent pre-mining future blocks
	function getChallengeNumber() public view returns (bytes32) {

		return challengeNumber;

	}

	
	//the number of zeroes the digest of the PoW solution requires.  Auto adjusts
	function getMiningDifficulty() public view returns (uint) {
			return _MAXIMUM_TARGET.div(miningTarget);
	}


	function getMiningTarget() public view returns (uint) {
			return (miningTarget);
	}


	function getMiningMinted() public view returns (uint) {
		return tokensMinted;
	}


	//~21m coins total in minting
	//reward begins at 20 and the same for the first 8 eras (0-7), targetTime doubles to compensate for first 8 eras
	//After rewardEra = 8 it halves the reward every Era after because no more targetTime is added
	function getMiningReward() public view returns (uint) {
		//once we get half way thru the coins, only get 25 per block
		//every reward era, the reward amount halves.

		if(rewardEra < 8){
			return ( 50 * 10**uint(decimals));
		}else{
			return ( 50 * 10**uint(decimals)).div( 2**(rewardEra - 7  ) );
		}
		}


	function getEpoch() public view returns (uint) {

		return epochCount ;

	}


	//help debug mining software
	function getMintDigest(uint256 nonce, bytes32 challenge_digest, bytes32 challenge_number) public view returns (bytes32 digesttest) {

		bytes32 digest =  keccak256(abi.encodePacked(challengeNumber, msg.sender, nonce));

		return digest;

	}


		// ------------------------------------------------------------------------

		// Get the token balance for account `tokenOwner`

		// ------------------------------------------------------------------------

	function balanceOf(address tokenOwner) public override view returns (uint balance) {

		return balances[tokenOwner];

	}


		// ------------------------------------------------------------------------

		// Transfer the balance from token owner's account to `to` account

		// - Owner's account must have sufficient balance to transfer

		// - 0 value transfers are allowed

		// ------------------------------------------------------------------------


	function transfer(address to, uint tokens) public override returns (bool success) {

		balances[msg.sender] = balances[msg.sender].sub(tokens);
		balances[to] = balances[to].add(tokens);

		emit Transfer(msg.sender, to, tokens);

		return true;

	}


		// ------------------------------------------------------------------------

		// Token owner can approve for `spender` to transferFrom(...) `tokens`

		// from the token owner's account

		//

		// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md

		// recommends that there are no checks for the approval double-spend attack

		// as this should be implemented in user interfaces

		// ------------------------------------------------------------------------


	function approve(address spender, uint tokens) public override returns (bool success) {

		allowed[msg.sender][spender] = tokens;

		emit Approval(msg.sender, spender, tokens);

		return true;

	}


		// ------------------------------------------------------------------------

		// Transfer `tokens` from the `from` account to the `to` account

		//

		// The calling account must already have sufficient tokens approve(...)-d

		// for spending from the `from` account and

		// - From account must have sufficient balance to transfer

		// - Spender must have sufficient allowance to transfer

		// - 0 value transfers are allowed

		// ------------------------------------------------------------------------


	function transferFrom(address from, address to, uint tokens) public override returns (bool success) {

		balances[from] = balances[from].sub(tokens);
		allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
		balances[to] = balances[to].add(tokens);

		emit Transfer(from, to, tokens);

		return true;

	}


		// ------------------------------------------------------------------------

		// Returns the amount of tokens approved by the owner that can be

		// transferred to the spender's account

		// ------------------------------------------------------------------------


	function allowance(address tokenOwner, address spender) public override view returns (uint remaining) {

		return allowed[tokenOwner][spender];

	}




	  //Allow ETH to enter
	receive() external payable {

	}


	fallback() external payable {

	}
}

/*
*
* MIT License
* ===========
*
* Copyright (c) 2023 zkBitcoin (zkBTC)
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.   
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*/