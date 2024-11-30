import { describe, it, expect, beforeEach, vi } from 'vitest'

// Mock implementation of the smart contract
const loyaltyProgram = {
  businesses: new Map(),
  balances: new Map(),
  stakedBalances: new Map(),
  stakingStartTime: new Map(),
  
  registerBusiness(business) {
    this.businesses.set(business, true)
    return { success: true }
  },
  
  mintAndDistribute(business, recipient, amount) {
    if (!this.businesses.get(business)) return { success: false, error: 'Not authorized' }
    const currentBalance = this.balances.get(recipient) || 0
    this.balances.set(recipient, currentBalance + amount)
    return { success: true }
  },
  
  redeemTokens(user, amount) {
    const balance = this.balances.get(user) || 0
    if (balance < amount) return { success: false, error: 'Insufficient balance' }
    this.balances.set(user, balance - amount)
    return { success: true }
  },
  
  stakeTokens(user, amount) {
    const balance = this.balances.get(user) || 0
    if (balance < amount) return { success: false, error: 'Insufficient balance' }
    const currentStake = this.stakedBalances.get(user) || 0
    this.stakedBalances.set(user, currentStake + amount)
    this.stakingStartTime.set(user, Date.now())
    this.balances.set(user, balance - amount)
    return { success: true }
  },
  
  unstakeTokens(user) {
    const stakedAmount = this.stakedBalances.get(user) || 0
    if (stakedAmount === 0) return { success: false, error: 'No staked tokens' }
    const startTime = this.stakingStartTime.get(user)
    const stakingPeriod = (Date.now() - startTime) / 1000 // in seconds
    const bonusRate = 0.01 // 1% per 100 seconds
    const bonusAmount = Math.floor(stakedAmount * stakingPeriod * bonusRate / 100)
    const totalAmount = stakedAmount + bonusAmount
    this.balances.set(user, (this.balances.get(user) || 0) + totalAmount)
    this.stakedBalances.delete(user)
    this.stakingStartTime.delete(user)
    return { success: true, amount: totalAmount }
  },
  
  isBusiness(address) {
    return this.businesses.get(address) || false
  },
  
  getStakedBalance(address) {
    return this.stakedBalances.get(address) || 0
  },
  
  getStakingStartTime(address) {
    return this.stakingStartTime.get(address) || 0
  }
}

describe('Loyalty Program Smart Contract', () => {
  const owner = 'owner'
  const business = 'business'
  const user = 'user'
  
  beforeEach(() => {
    loyaltyProgram.businesses.clear()
    loyaltyProgram.balances.clear()
    loyaltyProgram.stakedBalances.clear()
    loyaltyProgram.stakingStartTime.clear()
  })
  
  it('should register a business', () => {
    const result = loyaltyProgram.registerBusiness(business)
    expect(result.success).toBe(true)
    expect(loyaltyProgram.isBusiness(business)).toBe(true)
  })
  
  it('should mint and distribute tokens', () => {
    loyaltyProgram.registerBusiness(business)
    const result = loyaltyProgram.mintAndDistribute(business, user, 100)
    expect(result.success).toBe(true)
    expect(loyaltyProgram.balances.get(user)).toBe(100)
  })
  
  it('should allow users to redeem tokens', () => {
    loyaltyProgram.registerBusiness(business)
    loyaltyProgram.mintAndDistribute(business, user, 100)
    const result = loyaltyProgram.redeemTokens(user, 50)
    expect(result.success).toBe(true)
    expect(loyaltyProgram.balances.get(user)).toBe(50)
  })
  
  it('should allow users to stake tokens', () => {
    loyaltyProgram.registerBusiness(business)
    loyaltyProgram.mintAndDistribute(business, user, 100)
    const result = loyaltyProgram.stakeTokens(user, 25)
    expect(result.success).toBe(true)
    expect(loyaltyProgram.getStakedBalance(user)).toBe(25)
    expect(loyaltyProgram.balances.get(user)).toBe(75)
  })
  
  it('should allow users to unstake tokens and claim bonus', () => {
    vi.useFakeTimers()
    loyaltyProgram.registerBusiness(business)
    loyaltyProgram.mintAndDistribute(business, user, 100)
    loyaltyProgram.stakeTokens(user, 50)
    
    // Simulate passage of time (1000 seconds)
    vi.advanceTimersByTime(1000000)
    
    const result = loyaltyProgram.unstakeTokens(user)
    expect(result.success).toBe(true)
    expect(result.amount).toBeGreaterThan(50) // Should include bonus
    
    vi.useRealTimers()
  })
  
  it('should check if an address is a registered business', () => {
    loyaltyProgram.registerBusiness(business)
    expect(loyaltyProgram.isBusiness(business)).toBe(true)
    expect(loyaltyProgram.isBusiness(user)).toBe(false)
  })
  
  it('should get the staked balance of an address', () => {
    loyaltyProgram.registerBusiness(business)
    loyaltyProgram.mintAndDistribute(business, user, 100)
    loyaltyProgram.stakeTokens(user, 75)
    expect(loyaltyProgram.getStakedBalance(user)).toBe(75)
  })
  
  it('should get the staking start time of an address', () => {
    vi.useFakeTimers()
    const now = Date.now()
    loyaltyProgram.registerBusiness(business)
    loyaltyProgram.mintAndDistribute(business, user, 100)
    loyaltyProgram.stakeTokens(user, 50)
    expect(loyaltyProgram.getStakingStartTime(user)).toBe(now)
    vi.useRealTimers()
  })
})
