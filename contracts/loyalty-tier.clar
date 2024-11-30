;; Loyalty Tier Contract

;; Define constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-tier (err u101))
(define-constant err-invalid-parameter (err u102))

;; Define data maps
(define-map user-tiers principal uint)
(define-map tier-requirements uint uint)
(define-map tier-multipliers uint uint)

;; Define public functions

;; Set tier requirements (only contract owner)
(define-public (set-tier-requirement (tier uint) (required-balance uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (and (> tier u0) (<= tier u5)) err-invalid-parameter)
    (ok (map-set tier-requirements tier required-balance))))

;; Set tier multipliers (only contract owner)
(define-public (set-tier-multiplier (tier uint) (multiplier uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (and (> tier u0) (<= tier u5)) err-invalid-parameter)
    (asserts! (and (>= multiplier u100) (<= multiplier u200)) err-invalid-parameter)
    (ok (map-set tier-multipliers tier multiplier))))

;; Update user tier based on their balance
(define-public (update-user-tier (user principal) (balance uint))
  (let (
    (current-tier (default-to u0 (map-get? user-tiers user)))
    (new-tier (determine-tier balance))
  )
    (begin
      (asserts! (>= new-tier current-tier) err-invalid-tier)
      (ok (map-set user-tiers user new-tier)))))

;; Get adjusted amount based on user's tier
(define-public (get-adjusted-amount (user principal) (base-amount uint))
  (let (
    (user-tier (default-to u0 (map-get? user-tiers user)))
    (multiplier (default-to u100 (map-get? tier-multipliers user-tier)))
    (adjusted-amount (/ (* base-amount multiplier) u100))
  )
    (ok adjusted-amount)))

;; Read-only functions

;; Get user's current tier
(define-read-only (get-user-tier (user principal))
  (default-to u0 (map-get? user-tiers user)))

;; Get tier requirement
(define-read-only (get-tier-requirement (tier uint))
  (default-to u0 (map-get? tier-requirements tier)))

;; Get tier multiplier
(define-read-only (get-tier-multiplier (tier uint))
  (default-to u100 (map-get? tier-multipliers tier)))

;; Determine tier based on balance
(define-private (determine-tier (balance uint))
  (if (>= balance (default-to u0 (map-get? tier-requirements u5)))
    u5
    (if (>= balance (default-to u0 (map-get? tier-requirements u4)))
      u4
      (if (>= balance (default-to u0 (map-get? tier-requirements u3)))
        u3
        (if (>= balance (default-to u0 (map-get? tier-requirements u2)))
          u2
          (if (>= balance (default-to u0 (map-get? tier-requirements u1)))
            u1
            u0))))))
