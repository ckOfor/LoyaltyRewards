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
