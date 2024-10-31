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
