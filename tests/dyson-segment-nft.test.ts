import { describe, it, expect, beforeEach } from 'vitest';

// Simulated contract state
let lastSegmentId = 0;
const segmentData = new Map();
const segmentOwners = new Map();

// Simulated contract functions
function mintSegment(location: string, efficiency: number, energyOutput: number, sender: string) {
  if (sender !== 'CONTRACT_OWNER') throw new Error('Not authorized');
  const segmentId = ++lastSegmentId;
  segmentData.set(segmentId, { location, efficiency, energyOutput });
  segmentOwners.set(segmentId, sender);
  return segmentId;
}

function transferSegment(id: number, sender: string, recipient: string) {
  if (segmentOwners.get(id) !== sender) throw new Error('Not authorized');
  segmentOwners.set(id, recipient);
  return true;
}

function getSegmentOwner(id: number) {
  return segmentOwners.get(id);
}

function getSegmentData(id: number) {
  return segmentData.get(id);
}

describe('Dyson Segment NFT Contract', () => {
  beforeEach(() => {
    lastSegmentId = 0;
    segmentData.clear();
    segmentOwners.clear();
  });
  
  it('should mint a new segment', () => {
    const id = mintSegment('Alpha Quadrant', 95, 1000000, 'CONTRACT_OWNER');
    expect(id).toBe(1);
    expect(getSegmentData(id)).toEqual({ location: 'Alpha Quadrant', efficiency: 95, energyOutput: 1000000 });
    expect(getSegmentOwner(id)).toBe('CONTRACT_OWNER');
  });
  
  it('should not allow unauthorized users to mint segments', () => {
    expect(() => mintSegment('Beta Quadrant', 90, 900000, 'user1')).toThrow('Not authorized');
  });
  
  it('should transfer segment ownership', () => {
    const id = mintSegment('Gamma Quadrant', 85, 850000, 'CONTRACT_OWNER');
    transferSegment(id, 'CONTRACT_OWNER', 'user1');
    expect(getSegmentOwner(id)).toBe('user1');
  });
  
  it('should not allow unauthorized transfers', () => {
    const id = mintSegment('Delta Quadrant', 80, 800000, 'CONTRACT_OWNER');
    expect(() => transferSegment(id, 'user1', 'user2')).toThrow('Not authorized');
  });
});

