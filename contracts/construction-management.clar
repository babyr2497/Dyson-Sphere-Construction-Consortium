;; Construction Management Contract

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u100))
(define-constant ERR_INVALID_PHASE (err u101))
(define-constant ERR_INSUFFICIENT_RESOURCES (err u102))

;; Data variables
(define-data-var current-phase uint u0)
(define-data-var total-resources uint u0)

;; Data maps
(define-map construction-phases
  uint
  { name: (string-ascii 64), resource-requirement: uint }
)

(define-map resource-allocation
  principal
  uint
)

;; Public functions
(define-public (start-next-phase)
  (let
    (
      (next-phase (+ (var-get current-phase) u1))
      (phase-data (unwrap! (map-get? construction-phases next-phase) ERR_INVALID_PHASE))
    )
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    (asserts! (>= (var-get total-resources) (get resource-requirement phase-data)) ERR_INSUFFICIENT_RESOURCES)
    (var-set current-phase next-phase)
    (var-set total-resources (- (var-get total-resources) (get resource-requirement phase-data)))
    (ok next-phase)
  )
)

(define-public (contribute-resources (amount uint))
  (let
    (
      (current-contribution (default-to u0 (map-get? resource-allocation tx-sender)))
    )
    (map-set resource-allocation tx-sender (+ current-contribution amount))
    (var-set total-resources (+ (var-get total-resources) amount))
    (ok amount)
  )
)

;; Read-only functions
(define-read-only (get-current-phase)
  (var-get current-phase)
)

(define-read-only (get-phase-info (phase uint))
  (map-get? construction-phases phase)
)

(define-read-only (get-total-resources)
  (var-get total-resources)
)

(define-read-only (get-contributor-resources (contributor principal))
  (default-to u0 (map-get? resource-allocation contributor))
)

;; Initialize construction phases
(map-set construction-phases u0 { name: "Planning", resource-requirement: u1000000 })
(map-set construction-phases u1 { name: "Foundation", resource-requirement: u5000000 })
(map-set construction-phases u2 { name: "Framework", resource-requirement: u10000000 })
(map-set construction-phases u3 { name: "Paneling", resource-requirement: u20000000 })
(map-set construction-phases u4 { name: "Systems Integration", resource-requirement: u15000000 })
(map-set construction-phases u5 { name: "Testing", resource-requirement: u5000000 })

