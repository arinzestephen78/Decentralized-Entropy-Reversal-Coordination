;; Universal Heat Death Prevention Coordination Contract
;; Coordinates global efforts against entropy increase

(define-map prevention-initiatives
  { initiative-id: uint }
  {
    name: (string-utf8 64),
    description: (string-utf8 256),
    target-region: (string-utf8 64),
    status: (string-ascii 20),
    coordinator: principal,
    participants: uint
  }
)

(define-map initiative-contributions
  { initiative-id: uint, contributor: principal }
  {
    energy-contributed: uint,
    entropy-reduced: uint,
    contribution-time: uint
  }
)

(define-data-var next-initiative-id uint u0)
(define-data-var global-entropy-level uint u1000)

;; Create a new prevention initiative
(define-public (create-initiative (name (string-utf8 64)) (description (string-utf8 256)) (target-region (string-utf8 64)))
  (let
    ((initiative-id (var-get next-initiative-id)))

    ;; Update the initiative counter
    (var-set next-initiative-id (+ initiative-id u1))

    ;; Store the initiative
    (ok (map-set prevention-initiatives
      { initiative-id: initiative-id }
      {
        name: name,
        description: description,
        target-region: target-region,
        status: "active",
        coordinator: tx-sender,
        participants: u0
      }
    ))
  )
)

;; Contribute to an initiative
(define-public (contribute-to-initiative (initiative-id uint) (energy-amount uint) (entropy-reduction uint))
  (match (map-get? prevention-initiatives { initiative-id: initiative-id })
    initiative
      (begin
        ;; Record the contribution
        (map-set initiative-contributions
          { initiative-id: initiative-id, contributor: tx-sender }
          {
            energy-contributed: energy-amount,
            entropy-reduced: entropy-reduction,
            contribution-time: block-height
          }
        )

        ;; Update the initiative
        (ok (map-set prevention-initiatives
          { initiative-id: initiative-id }
          (merge initiative {
            participants: (+ (get participants initiative) u1)
          })
        )))
    (err u404)
  )
)

;; Update global entropy level
(define-public (update-global-entropy (new-level uint))
  (ok (var-set global-entropy-level new-level))
)

;; Get initiative information
(define-read-only (get-initiative (initiative-id uint))
  (map-get? prevention-initiatives { initiative-id: initiative-id })
)

;; Get contribution information
(define-read-only (get-contribution (initiative-id uint) (contributor principal))
  (map-get? initiative-contributions { initiative-id: initiative-id, contributor: contributor })
)

;; Get global entropy level
(define-read-only (get-global-entropy)
  (var-get global-entropy-level)
)

;; Check if heat death is prevented
(define-read-only (is-heat-death-prevented)
  (< (var-get global-entropy-level) u500)
)

