;; Consumer Identity Contract
;; This contract manages shopper profiles

;; Map to store consumer profiles
(define-map consumer-profiles principal
  {
    username: (string-utf8 50),
    email-hash: (buff 32),
    created-at: uint,
    last-updated: uint
  }
)

;; Public function for consumers to register
(define-public (register-consumer (username (string-utf8 50)) (email-hash (buff 32)))
  (begin
    (asserts! (is-none (map-get? consumer-profiles tx-sender)) (err u1)) ;; Already registered
    (ok (map-set consumer-profiles tx-sender
      {
        username: username,
        email-hash: email-hash,
        created-at: block-height,
        last-updated: block-height
      }
    ))
  )
)

;; Public function for consumers to update their profile
(define-public (update-profile (username (string-utf8 50)) (email-hash (buff 32)))
  (begin
    (match (map-get? consumer-profiles tx-sender)
      profile (ok (map-set consumer-profiles tx-sender
        {
          username: username,
          email-hash: email-hash,
          created-at: (get created-at profile),
          last-updated: block-height
        }
      ))
      (err u2) ;; Profile not found
    )
  )
)

;; Read-only function to check if a consumer exists
(define-read-only (consumer-exists (consumer principal))
  (is-some (map-get? consumer-profiles consumer))
)

;; Read-only function to get consumer profile
(define-read-only (get-consumer-profile (consumer principal))
  (map-get? consumer-profiles consumer)
)
