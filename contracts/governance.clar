;; Governance Contract

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u100))
(define-constant ERR_INVALID_VOTE (err u101))
(define-constant ERR_PROPOSAL_NOT_ACTIVE (err u102))

;; Data variables
(define-data-var proposal-id uint u0)

;; Data maps
(define-map proposals
  uint
  { title: (string-ascii 256), description: (string-utf8 1024), votes-for: uint, votes-against: uint, status: (string-ascii 16) }
)

(define-map user-votes
  { user: principal, proposal: uint }
  bool
)

;; Public functions
(define-public (create-proposal (title (string-ascii 256)) (description (string-utf8 1024)))
  (let
    (
      (new-proposal-id (+ (var-get proposal-id) u1))
    )
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    (map-set proposals new-proposal-id { title: title, description: description, votes-for: u0, votes-against: u0, status: "active" })
    (var-set proposal-id new-proposal-id)
    (ok new-proposal-id)
  )
)

(define-public (vote (proposal uint) (vote-for bool))
  (let
    (
      (proposal-data (unwrap! (map-get? proposals proposal) ERR_INVALID_VOTE))
    )
    (asserts! (is-eq (get status proposal-data) "active") ERR_PROPOSAL_NOT_ACTIVE)
    (asserts! (is-none (map-get? user-votes { user: tx-sender, proposal: proposal })) ERR_INVALID_VOTE)
    (map-set user-votes { user: tx-sender, proposal: proposal } vote-for)
    (if vote-for
      (map-set proposals proposal (merge proposal-data { votes-for: (+ (get votes-for proposal-data) u1) }))
      (map-set proposals proposal (merge proposal-data { votes-against: (+ (get votes-against proposal-data) u1) }))
    )
    (ok true)
  )
)

(define-public (close-proposal (proposal uint))
  (let
    (
      (proposal-data (unwrap! (map-get? proposals proposal) ERR_INVALID_VOTE))
    )
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    (asserts! (is-eq (get status proposal-data) "active") ERR_PROPOSAL_NOT_ACTIVE)
    (map-set proposals proposal (merge proposal-data { status: "closed" }))
    (ok true)
  )
)

;; Read-only functions
(define-read-only (get-proposal (id uint))
  (map-get? proposals id)
)

(define-read-only (get-user-vote (user principal) (proposal uint))
  (map-get? user-votes { user: user, proposal: proposal })
)

