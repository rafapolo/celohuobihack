// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/// @title MOEDAO
/// @author Segun Ogundipe David
/// adapted by @author Rafael Polo

// todo: in a future version this contract should hold it's vault addr/wallet

contract MOEDAO is ReentrancyGuard, AccessControl {
    bytes32 public constant CONTRIBUTOR_ROLE = keccak256("CONTRIBUTOR");
    bytes32 public constant STAKEHOLDER_ROLE = keccak256("STAKEHOLDER");
    // Constant variable that holds the number of days a proposal can be voted on in seconds.
    // `weeks` is a suffix provided by solidity. It translates to the total seconds in a week.
    uint32 constant minimumVotingPeriod = 1 weeks;
    // This variable is incremented everytime a new charity proposal is added.
    // It is needed to iterate through the charty proposals as solidity doesn't provide a way to step through mappings.
    uint256 numOfProposals;
    

    /// @notice Holds all the charity proposals made in the DAO.
    mapping(uint256 => CharityProposal) private charityProposals;
    /// @notice Holds all the stakeholders' address and their total contributions.
    mapping(address => uint256[]) private stakeholderVotes;
    /// @notice Holds all the contributors' address and their total contributions.
    mapping(address => uint256) private contributors;
    /// Holds all the stakeholders' address and their total contributions.
    mapping(address => uint256) private stakeholders;

    /// @notice A new type definition that holds the necessary variables that makes up a charity proposal.
    struct CharityProposal {
        uint256 id;
        uint256 amount;
        uint256 livePeriod;
        uint256 votesFor;
        uint256 votesAgainst;
        string description;
        bool votingPassed;
        bool paid;
        address payable charityAddress;
        address proposer;
        address paidBy;
    }

    /// @notice Event that is emitted when a contribution is received.
    /// @param fromAddress The address the contribution came from.
    /// @param amount The amount of celo that was sent.
    event ContributionReceived(address indexed fromAddress, uint256 amount);
    /// @notice Event that is emitted when a new proposal is added to the list of proposals.
    /// @param proposer The address of the contributer/stakeholder that created the proposal.
    /// @param amount The amount that is requested for.
    event NewCharityProposal(address indexed proposer, uint256 amount);
    /// @notice Event that is emitted when payment is made to a charity.
    /// @param stakeholder The stakeholder tha made the payment.
    /// @param charityAddress The charity that payment was made to.
    /// @param amount The amount that was paid.
    event PaymentTransfered(
        address indexed stakeholder,
        address indexed charityAddress,
        uint256 amount
    );

    modifier onlyStakeholder(string memory message) {
        require(hasRole(STAKEHOLDER_ROLE, msg.sender), message);
        _;
    }

    modifier onlyContributor(string memory message) {
        require(hasRole(CONTRIBUTOR_ROLE, msg.sender), message);
        _;
    }

    /// @notice Adds a new proposal to the `charityProposals` mapping.
    /// @param description A brief description of why the proposal should be voted for.
    /// @param charityAddress The address of the charity.
    /// @param amount The amount of celo.
    function createProposal(
        string calldata description,
        address charityAddress,
        uint256 amount
    )
        external
        onlyStakeholder("Only stakeholders are allowed to create proposals")
    {
        uint256 proposalId = numOfProposals++;
        CharityProposal storage proposal = charityProposals[proposalId];
        proposal.id = proposalId;
        proposal.proposer = payable(msg.sender);
        proposal.description = description;
        proposal.charityAddress = payable(charityAddress);
        proposal.amount = amount;
        proposal.livePeriod = block.timestamp + minimumVotingPeriod;

        emit NewCharityProposal(msg.sender, amount);
    }

    /// @notice Vote for a particular proposal. Only stakeholders are allowed to vote.
    /// @param proposalId The id of the charity proposal being voted for.
    /// @param supportProposal true to vote for and false against.
    function vote(uint256 proposalId, bool supportProposal)
        external
        onlyStakeholder("Only stakeholders are allowed to vote")
    {
        CharityProposal storage charityProposal = charityProposals[proposalId];

        votable(charityProposal);

        if (supportProposal) charityProposal.votesFor++;
        else charityProposal.votesAgainst++;

        stakeholderVotes[msg.sender].push(charityProposal.id);
    }

    /// @notice Contains some conditionals that validate a proposal to be voted on.
    /// @param charityProposal a parameter just like in doxygen (must be followed by parameter name)
    function votable(CharityProposal storage charityProposal) private {
        if (
            charityProposal.votingPassed ||
            charityProposal.livePeriod <= block.timestamp
        ) {
            charityProposal.votingPassed = true;
            revert("Voting period has passed on this proposal");
        }

        uint256[] memory tempVotes = stakeholderVotes[msg.sender];
        for (uint256 votes = 0; votes < tempVotes.length; votes++) {
            if (charityProposal.id == tempVotes[votes])
                revert("This stakeholder already voted on this proposal");
        }
    }

    /// @notice This function makes payent to a Charity after the voting period of the proposal. Can only be called by a Stakeholder.
    /// @param proposalId The id of the proposal to pay to.
    function payCharity(uint256 proposalId)
        external
        onlyStakeholder("Only stakeholders are allowed to make payments")
    {
        CharityProposal storage charityProposal = charityProposals[proposalId];

        if (charityProposal.paid)
            revert("Payment has been made to this charity");

        if (charityProposal.votesFor <= charityProposal.votesAgainst)
            revert(
                "The proposal does not have the required amount of votes to pass"
            );

        charityProposal.paid = true;
        charityProposal.paidBy = msg.sender;

        emit PaymentTransfered(
            msg.sender,
            charityProposal.charityAddress,
            charityProposal.amount
        );

        return charityProposal.charityAddress.transfer(charityProposal.amount);
    }

    receive() external payable {
        emit ContributionReceived(msg.sender, msg.value);
    }

    /// @notice This function adds a new stakeholder if the total contribution is >= 5 celo
    function makeStakeholder(uint256 amount) external {
        address account = msg.sender;
        uint256 amountContributed = amount;
        if (!hasRole(STAKEHOLDER_ROLE, account)) {
            uint256 totalContributed =
                contributors[account] + amountContributed;
            if (totalContributed >= 5 ether) {
                stakeholders[account] = totalContributed;
                contributors[account] += amountContributed;
                _setupRole(STAKEHOLDER_ROLE, account);
                _setupRole(CONTRIBUTOR_ROLE, account);
            } else {
                contributors[account] += amountContributed;
                _setupRole(CONTRIBUTOR_ROLE, account);
            }
        } else {
            contributors[account] += amountContributed;
            stakeholders[account] += amountContributed;
        }
    }

    function getProposals()
        public
        view
        returns (CharityProposal[] memory props)
    {
        props = new CharityProposal[](numOfProposals);

        for (uint256 index = 0; index < numOfProposals; index++) {
            props[index] = charityProposals[index];
        }
    }

    function getProposal(uint256 proposalId)
        public
        view
        returns (CharityProposal memory)
    {
        return charityProposals[proposalId];
    }

    function getStakeholderVotes()
        public
        view
        onlyStakeholder("User is not a stakeholder")
        returns (uint256[] memory)
    {
        return stakeholderVotes[msg.sender];
    }

    function getStakeholderBalance()
        public
        view
        onlyStakeholder("User is not a stakeholder")
        returns (uint256)
    {
        return stakeholders[msg.sender];
    }

    function isStakeholder() public view returns (bool) {
        return stakeholders[msg.sender] > 0;
    }

    function getContributorBalance()
        public
        view
        onlyContributor("User is not a contributor")
        returns (uint256)
    {
        return contributors[msg.sender];
    }

    function isContributor() public view returns (bool) {
        return contributors[msg.sender] > 0;
    }
}
