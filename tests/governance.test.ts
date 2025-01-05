import { describe, it, expect, beforeEach } from 'vitest';

// Simulated contract state
let proposalId = 0;
const proposals = new Map();
const userVotes = new Map();

// Simulated contract functions
function createProposal(title: string, description: string, sender: string) {
  if (sender !== 'CONTRACT_OWNER') throw new Error('Not authorized');
  const newProposalId = ++proposalId;
  proposals.set(newProposalId, { title, description, votesFor: 0, votesAgainst: 0, status: 'active' });
  return newProposalId;
}

function vote(proposal: number, voteFor: boolean, sender: string) {
  const proposalData = proposals.get(proposal);
  if (!proposalData) throw new Error('Invalid vote');
  if (proposalData.status !== 'active') throw new Error('Proposal not active');
  const voteKey = `${sender}-${proposal}`;
  if (userVotes.has(voteKey)) throw new Error('Invalid vote');
  userVotes.set(voteKey, voteFor);
  if (voteFor) {
    proposalData.votesFor++;
  } else {
    proposalData.votesAgainst++;
  }
  proposals.set(proposal, proposalData);
  return true;
}

function closeProposal(proposal: number, sender: string) {
  if (sender !== 'CONTRACT_OWNER') throw new Error('Not authorized');
  const proposalData = proposals.get(proposal);
  if (!proposalData) throw new Error('Invalid proposal');
  if (proposalData.status !== 'active') throw new Error('Proposal not active');
  proposalData.status = 'closed';
  proposals.set(proposal, proposalData);
  return true;
}

describe('Governance Contract', () => {
  beforeEach(() => {
    proposalId = 0;
    proposals.clear();
    userVotes.clear();
  });
  
  it('should create a new proposal', () => {
    const id = createProposal('Increase energy output', 'Proposal to increase Dyson sphere energy output by 10%', 'CONTRACT_OWNER');
    expect(id).toBe(1);
    expect(proposals.get(id)).toEqual({
      title: 'Increase energy output',
      description: 'Proposal to increase Dyson sphere energy output by 10%',
      votesFor: 0,
      votesAgainst: 0,
      status: 'active'
    });
  });
  
  it('should not allow unauthorized users to create proposals', () => {
    expect(() => createProposal('Unauthorized proposal', 'This should fail', 'user1')).toThrow('Not authorized');
  });
  
  it('should allow users to vote on active proposals', () => {
    const id = createProposal('Test proposal', 'Proposal for testing', 'CONTRACT_OWNER');
    expect(vote(id, true, 'user1')).toBe(true);
    expect(proposals.get(id).votesFor).toBe(1);
    expect(vote(id, false, 'user2')).toBe(true);
    expect(proposals.get(id).votesAgainst).toBe(1);
  });
  
  it('should not allow users to vote twice on the same proposal', () => {
    const id = createProposal('Test proposal', 'Proposal for testing', 'CONTRACT_OWNER');
    vote(id, true, 'user1');
    expect(() => vote(id, false, 'user1')).toThrow('Invalid vote');
  });
  
  it('should close proposals', () => {
    const id = createProposal('Test proposal', 'Proposal for testing', 'CONTRACT_OWNER');
    closeProposal(id, 'CONTRACT_OWNER');
    expect(proposals.get(id).status).toBe('closed');
  });
  
  it('should not allow voting on closed proposals', () => {
    const id = createProposal('Test proposal', 'Proposal for testing', 'CONTRACT_OWNER');
    closeProposal(id, 'CONTRACT_OWNER');
    expect(() => vote(id, true, 'user1')).toThrow('Proposal not active');
  });
});

