;; Simulation Integration Contract

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u100))
(define-constant ERR_INVALID_SIMULATION (err u101))

;; Data variables
(define-data-var last-simulation-id uint u0)

;; Data maps
(define-map simulations
  uint
  { name: (string-ascii 64), parameters: (string-utf8 1024), results: (string-utf8 1024), timestamp: uint }
)

;; Public functions
(define-public (run-simulation (name (string-ascii 64)) (parameters (string-utf8 1024)))
  (let
    (
      (simulation-id (+ (var-get last-simulation-id) u1))
    )
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    (map-set simulations simulation-id { name: name, parameters: parameters, results: "", timestamp: block-height })
    (var-set last-simulation-id simulation-id)
    (ok simulation-id)
  )
)

(define-public (update-simulation-results (simulation-id uint) (results (string-utf8 1024)))
  (let
    (
      (simulation (unwrap! (map-get? simulations simulation-id) ERR_INVALID_SIMULATION))
    )
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    (map-set simulations simulation-id (merge simulation { results: results }))
    (ok true)
  )
)

;; Read-only functions
(define-read-only (get-simulation (id uint))
  (map-get? simulations id)
)

(define-read-only (get-last-simulation-id)
  (var-get last-simulation-id)
)

