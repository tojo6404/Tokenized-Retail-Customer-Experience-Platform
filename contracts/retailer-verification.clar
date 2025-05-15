;; Retailer Verification Contract
;; This contract validates legitimate merchants on the platform

(define-data-var admin principal tx-sender)

;; Map to store verified retailers
(define-map verified-retailers principal
  {
    name: (string-utf8 100),
    website: (string-utf8 100),
    verified-at: uint,
    active: bool
  }
)

;; Public function to verify a retailer (admin only)
(define-public (verify-retailer (retailer principal) (name (string-utf8 100)) (website (string-utf8 100)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1)) ;; Only admin can verify
    (ok (map-set verified-retailers retailer
      {
        name: name,
        website: website,
        verified-at: block-height,
        active: true
      }
    ))
  )
)

;; Public function to check if a retailer is verified
(define-read-only (is-verified (retailer principal))
  (match (map-get? verified-retailers retailer)
    verified-data (and (get active verified-data) true)
    false
  )
)

;; Public function to suspend a retailer (admin only)
(define-public (suspend-retailer (retailer principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1)) ;; Only admin can suspend
    (match (map-get? verified-retailers retailer)
      verified-data (ok (map-set verified-retailers retailer
        (merge verified-data { active: false })
      ))
      (err u2) ;; Retailer not found
    )
  )
)

;; Public function to transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1)) ;; Only current admin can transfer
    (ok (var-set admin new-admin))
  )
)
