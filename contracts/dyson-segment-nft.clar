;; Dyson Segment NFT Contract

(define-non-fungible-token dyson-segment uint)

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u100))
(define-constant ERR_SEGMENT_NOT_FOUND (err u101))

;; Data variables
(define-data-var last-segment-id uint u0)

;; Data maps
(define-map segment-data
  uint
  { location: (string-ascii 64), efficiency: uint, energy-output: uint }
)

;; Public functions
(define-public (mint-segment (location (string-ascii 64)) (efficiency uint) (energy-output uint))
  (let
    (
      (segment-id (+ (var-get last-segment-id) u1))
    )
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    (try! (nft-mint? dyson-segment segment-id tx-sender))
    (map-set segment-data segment-id { location: location, efficiency: efficiency, energy-output: energy-output })
    (var-set last-segment-id segment-id)
    (ok segment-id)
  )
)

(define-public (transfer-segment (id uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender (unwrap! (nft-get-owner? dyson-segment id) ERR_SEGMENT_NOT_FOUND)) ERR_NOT_AUTHORIZED)
    (try! (nft-transfer? dyson-segment id tx-sender recipient))
    (ok true)
  )
)

;; Read-only functions
(define-read-only (get-segment-owner (id uint))
  (nft-get-owner? dyson-segment id)
)

(define-read-only (get-segment-data (id uint))
  (map-get? segment-data id)
)

(define-read-only (get-last-segment-id)
  (var-get last-segment-id)
)

