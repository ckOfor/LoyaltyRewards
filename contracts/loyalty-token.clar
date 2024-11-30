;; Define the fungible token for loyalty points
(define-fungible-token loyalty-token)

;; Define constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-authorized (err u101))
(define-constant err-insufficient-balance (err u102))

;; Define data variables
(define-map businesses principal bool)
(define-map staked-balances principal uint)
(define-map staking-start-time principal uint)

;; Define public functions

;; Register a business
(define-public (register-business (business principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok (map-set businesses business true))))

;; Mint and distribute tokens to a user
(define-public (mint-and-distribute (recipient principal) (amount uint))
  (begin
    (asserts! (is-business tx-sender) err-not-authorized)
    (ft-mint? loyalty-token amount recipient)))

;; Redeem tokens for a reward
(define-public (redeem-tokens (amount uint))
  (begin
    (asserts! (>= (stx-get-balance tx-sender) amount) err-insufficient-balance)
    (ft-burn? loyalty-token amount tx-sender)))

;; Stake tokens for bonus rewards
(define-public (stake-tokens (amount uint))
  (let ((current-stake (default-to u0 (map-get? staked-balances tx-sender))))
    (begin
      (asserts! (>= (stx-get-balance tx-sender) amount) err-insufficient-balance)
      (map-set staked-balances tx-sender (+ current-stake amount))
      (map-set staking-start-time tx-sender block-height)
      (ft-burn? loyalty-token amount tx-sender))))

;; Unstake tokens and claim bonus
(define-public (unstake-tokens)
  (let (
    (staked-amount (default-to u0 (map-get? staked-balances tx-sender)))
    (start-time (default-to u0 (map-get? staking-start-time tx-sender)))
    (staking-period (- block-height start-time))
    (bonus-rate u1) ;; 1% bonus per 100 blocks, adjust as needed
    (bonus-amount (/ (* staked-amount staking-period bonus-rate) u10000))
  )
    (begin
      (map-delete staked-balances tx-sender)
      (map-delete staking-start-time tx-sender)
      (ft-mint? loyalty-token (+ staked-amount bonus-amount) tx-sender))))

;; Read-only functions

;; Check if an address is a registered business
(define-read-only (is-business (address principal))
  (default-to false (map-get? businesses address)))

;; Get the staked balance of an address
(define-read-only (get-staked-balance (address principal))
  (default-to u0 (map-get? staked-balances address)))

;; Get the staking start time of an address
(define-read-only (get-staking-start-time (address principal))
  (default-to u0 (map-get? staking-start-time address)))
