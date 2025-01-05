import { describe, it, expect, beforeEach } from 'vitest';

// Simulated contract state
let currentPhase = 0;
let totalResources = 0;
const constructionPhases = new Map([
  [0, { name: "Planning", resourceRequirement: 1000000 }],
  [1, { name: "Foundation", resourceRequirement: 5000000 }],
  [2, { name: "Framework", resourceRequirement: 10000000 }],
  [3, { name: "Paneling", resourceRequirement: 20000000 }],
  [4, { name: "Systems Integration", resourceRequirement: 15000000 }],
  [5, { name: "Testing", resourceRequirement: 5000000 }]
]);
const resourceAllocation = new Map();

// Simulated contract functions
function startNextPhase(sender: string) {
  if (sender !== 'CONTRACT_OWNER') throw new Error('Not authorized');
  const nextPhase = currentPhase + 1;
  const phaseData = constructionPhases.get(nextPhase);
  if (!phaseData) throw new Error('Invalid phase');
  if (totalResources < phaseData.resourceRequirement) throw new Error('Insufficient resources');
  currentPhase = nextPhase;
  totalResources -= phaseData.resourceRequirement;
  return nextPhase;
}

function contributeResources(amount: number, sender: string) {
  const currentContribution = resourceAllocation.get(sender) || 0;
  resourceAllocation.set(sender, currentContribution + amount);
  totalResources += amount;
  return amount;
}

describe('Construction Management Contract', () => {
  beforeEach(() => {
    currentPhase = 0;
    totalResources = 0;
    resourceAllocation.clear();
  });
  
  it('should start the next phase when enough resources are available', () => {
    contributeResources(2000000, 'user1');
    expect(startNextPhase('CONTRACT_OWNER')).toBe(1);
    expect(currentPhase).toBe(1);
    expect(totalResources).toBe(1000000);
  });
  
  it('should not start the next phase with insufficient resources', () => {
    contributeResources(500000, 'user1');
    expect(() => startNextPhase('CONTRACT_OWNER')).toThrow('Insufficient resources');
  });
  
  it('should not allow unauthorized users to start the next phase', () => {
    contributeResources(2000000, 'user1');
    expect(() => startNextPhase('user1')).toThrow('Not authorized');
  });
  
  it('should allow users to contribute resources', () => {
    expect(contributeResources(1000000, 'user1')).toBe(1000000);
    expect(totalResources).toBe(1000000);
    expect(resourceAllocation.get('user1')).toBe(1000000);
  });
});

