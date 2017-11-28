(define-module (www reports)
  #:use-module (oop goops)
  #:use-module (srfi srfi-1)
  #:use-module (ice-9 ftw)
  #:use-module (ice-9 match)
  #:use-module (sjson)
  #:use-module (sjson utils)
  #:use-module (commonmark)
  #:export (render-implementation-reports
            load-all-implementation-reports
            additional-report-notes))

(define-class <test-item> ()
  (sym #:init-keyword #:sym
       #:getter test-item-sym)
  (req-level #:init-keyword #:req-level
             #:getter test-item-req-level)
  (desc #:init-keyword #:desc
        #:getter test-item-desc)
  (subitems #:init-keyword #:subitems
            #:getter test-item-subitems
            #:init-value '()))

(define req-levels
  '(MAY MUST SHOULD NON-NORMATIVE))
(define (req-level? obj)
  (member obj req-levels))

(define* (test-item sym req-level desc
                #:key (subitems '()))
  (make <test-item>
    #:sym sym #:req-level req-level #:desc desc
    #:subitems (build-test-items subitems)))

(define (build-test-items lst)
  (map (lambda (args) (apply test-item args)) lst))

(define c2s-server-items
  (build-test-items
   `(;;; MUST
     (outbox:accepts-activities
      MUST
      "Accepts Activity Objects")
     (outbox:accepts-non-activity-objects
      MUST
      "Accepts non-Activity Objects, and converts to Create Activities per 7.1.1")
     (outbox:removes-bto-and-bcc
      MUST
      "Removes the `bto` and `bcc` properties from Objects before storage and delivery")
     (outbox:ignores-id
      MUST
      "Ignores 'id' on submitted objects, and generates a new id instead")
     (outbox:responds-201-created
      MUST
      "Responds with status code 201 Created")
     (outbox:location-header
      MUST
      "Response includes Location header whose value is id of new object, unless the Activity is transient")

     ;; (outbox:upload-media
     ;;  MUST
     ;;  "Accepts Uploaded Media in submissions"
     ;;  #:subitems ((outbox:upload-media:file-parameter
     ;;               MUST
     ;;               "accepts uploadedMedia file parameter")
     ;;              (outbox:upload-media:object-parameter
     ;;               MUST
     ;;               "accepts uploadedMedia object parameter")
     ;;              (outbox:upload-media:201-or-202-status
     ;;               MUST
     ;;               "Responds with status code of 201 Created or 202 Accepted as described in 6.")
     ;;              (outbox:upload-media:location-header
     ;;               MUST
     ;;               "Response contains a Location header pointing to the to-be-created object's id.")
     ;;              (outbox:upload-media:appends-id
     ;;               MUST
     ;;               "Appends an id property to the new object")
     ;;              (outbox:upload-media:url
     ;;               SHOULD
     ;;               "After receiving submission with uploaded media, the server should include the upload's new URL in the submitted object's url property")))
     (outbox:update
      MUST
      "Update"
      ;; #:subitems ((outbox:update:check-authorized
      ;;              MUST
      ;;              "Server takes care to be sure that the Update is authorized to modify its object before modifying the server's stored copy"))
      #:subitems ((outbox:update:partial
                   NON-NORMATIVE
                   "Supports partial updates in client-to-server protocol (but not server-to-server)")))

    ;;; SHOULD
     ;; (outbox:not-trust-submitted
     ;;  SHOULD
     ;;  "Server does not trust client submitted content")
     ;; (outbox:validate-content
     ;;  SHOULD
     ;;  "Validate the content they receive to avoid content spoofing attacks.")
     ;; (outbox:do-not-overload
     ;;  SHOULD
     ;;  "Take care not to overload other servers with delivery submissions")
     (outbox:create
      SHOULD
      "Create"
      #:subitems ((outbox:create:merges-audience-properties
                   SHOULD
                   "merges audience properties (to, bto, cc, bcc, audience) with the Create's 'object's audience properties")
                  (outbox:create:actor-to-attributed-to
                   SHOULD
                   "Create's actor property is copied to be the value of .object.attributedTo")))
     (outbox:follow
      SHOULD
      "Follow"
      #:subitems ((outbox:follow:adds-followed-object
                   SHOULD
                   "Adds followed object to the actor's Following Collection")))
     (outbox:add
      SHOULD
      "Add"
      #:subitems ((outbox:add:adds-object-to-target
                   SHOULD
                   "Adds object to the target Collection, unless not allowed due to requirements in 7.5")))
     (outbox:remove
      SHOULD
      "Remove"
      #:subitems ((outbox:remove:removes-from-target
                   SHOULD
                   "Remove object from the target Collection, unless not allowed due to requirements in 7.5")))
     (outbox:like
      SHOULD
      "Like"
      #:subitems ((outbox:like:adds-object-to-liked
                   SHOULD
                   "Adds the object to the actor's Liked Collection.")))
     (outbox:block
      SHOULD
      "Block"
      #:subitems ((outbox:block:prevent-interaction-with-actor
                   SHOULD
                   "Prevent the blocked object from interacting with any object posted by the actor.")))

     (outbox:undo
      NON-NORMATIVE
      "Supports the Undo activity in the client-to-server protocol"
      #:subitems ((outbox:undo:ensures-activity-and-actor-are-same
                   MUST
                   "Ensures that the activity and actor are the same in activity being undone."))))))


(define server-inbox-delivery
  (build-test-items
   `(;;; MUST
     (inbox:delivery:performs-delivery
      MUST
      "Performs delivery on all Activities posted to the outbox")
     (inbox:delivery:addressing
      MUST
      "Utilizes `to`, `bto`, `cc`, and `bcc` to determine delivery recipients.")
     (inbox:delivery:adds-id
      MUST
      "Provides an `id` all Activities sent to other servers, unless the activity is intentionally transient.")
     (inbox:delivery:submit-with-credentials
      MUST
      "Dereferences delivery targets with the submitting user's credentials")
     (inbox:delivery:deliver-to-collection
      MUST
      "Delivers to all items in recipients that are Collections or OrderedCollections"
      #:subitems ((inbox:delivery:deliver-to-collection:recursively
                   MUST
                   "Applies the above, recursively if the Collection contains Collections, and limits recursion depth >= 1")))
     (inbox:delivery:delivers-with-object-for-certain-activities
      MUST
      "Delivers activity with 'object' property if the Activity type is one of Create, Update, Delete, Follow, Add, Remove, Like, Block, Undo")
     (inbox:delivery:delivers-with-target-for-certain-activities
      MUST
      "Delivers activity with 'target' property if the Activity type is one of Add, Remove")
     (inbox:delivery:deduplicates-final-recipient-list
      MUST
      "Deduplicates final recipient list")
     (inbox:delivery:do-not-deliver-to-actor
      MUST
      "Does not deliver to recipients which are the same as the actor of the Activity being notified about")
     (inbox:delivery:do-not-deliver-block
      SHOULD
      "SHOULD NOT deliver Block Activities to their object.")
     (inbox:delivery:sharedInbox
      MAY
      "Delivers to sharedInbox endpoints to reduce the number of receiving actors delivered to by identifying all followers which share the same sharedInbox who would otherwise be individual recipients and instead deliver objects to said sharedInbox."
      #:subitems ((inbox:delivery:sharedInbox:deliver-to-inbox-if-no-sharedInbox
                   MUST
                   "(For servers which deliver to sharedInbox:) Deliver to actor inboxes and collections otherwise addressed which do not have a sharedInbox."))))))

(define server-inbox-accept
  (build-test-items
   `(;; MUST
     (inbox:accept:deduplicate
      MUST
      "Deduplicates activities returned by the inbox by comparing activity `id`s")
     (inbox:accept:special-forward
      MUST
      "Forwards incoming activities to the values of to, bto, cc, bcc, audience if and only if criteria in 7.1.2 are met.")
     (inbox:accept:special-forward:recurses
      SHOULD
      "Recurse through to, bto, cc, bcc, audience object values to determine whether/where to forward according to criteria in 7.1.2")
     (inbox:accept:special-forward:limits-recursion
      SHOULD
      "Limit recursion in this process")

     ;; Create
     (inbox:accept:create
      NON-NORMATIVE
      "Supports receiving a Create object in an actor's inbox")

     ;; Delete
     (inbox:accept:delete
      SHOULD
      "Assuming object is owned by sending actor/server, removes object's representation"
      #:subitems ((inbox:accept:delete:tombstone
                   MAY
                   "MAY replace object's representation with a Tombstone object")))

     ;; * Update
     (inbox:accept:update:is-authorized
      MUST
      "Take care to be sure that the Update is authorized to modify its object")
     (inbox:accept:update:completely-replace
      SHOULD
      "Completely replace its copy of the activity with the newly received value")

     ;; SHOULD
     (inbox:accept:dont-blindly-trust
      SHOULD
      "Don't trust content received from a server other than the content's origin without some form of verification.")
     ;; * Follow
     (inbox:accept:follow:add-actor-to-users-followers
      SHOULD
      "Add the actor to the object user's Followers Collection.")
     (inbox:accept:follow:generate-accept-or-reject
      SHOULD
      "Generates either an Accept or Reject activity with Follow as object and deliver to actor of the Follow")
     (inbox:accept:accept:add-actor-to-users-following
      SHOULD
      "If in reply to a Follow activity, adds actor to receiver's Following Collection")
     (inbox:accept:reject:does-not-add-actor-to-users-following
      MUST
      "If in reply to a Follow activity, MUST NOT add actor to receiver's Following Collection")
     ;; * Add
     (inbox:accept:add:to-collection
      SHOULD
      "Add the object to the Collection specified in the target property, unless not allowed to per requirements in 7.8")
     (inbox:accept:remove:from-collection
      SHOULD
      "Remove the object from the Collection specified in the target property, unless not allowed per requirements in 7.9")
     ;; * Like
     (inbox:accept:like:indicate-like-performed
      SHOULD
      "Perform appropriate indication of the like being performed (See 7.10 for examples)")
     (inbox:accept:announce:add-to-shares-collection
      SHOULD
      "Increments object's count of likes by adding the received activity to the 'shares' collection if this collection is present")
     (inbox:accept:undo
      NON-NORMATIVE
      "Performs Undo of object in federated context")
     ;; @@: The same as dont-blindly-trust...
     ;; (inbox:accept:validate-content
     ;;  SHOULD
     ;;  "Validate the content they receive to avoid content spoofing attacks.")
     )))

(define server-common-test-items
  (build-test-items
   `(;; Inbox Retrieval
     (server:inbox:responds-to-get
      NON-NORMATIVE
      "Server responds to GET request at inbox URL")
     (server:inbox:is-orderedcollection
      MUST
      "inbox is an OrderedCollection")
     (server:inbox:filtered-per-permissions
      SHOULD
      "Server filters inbox content according to the requester's permission")

     ;; @@: Does this one even make sense to test for?  It's implied by the others
     ;; Object retrieval
     (server:object-retrieval:get-id
      MAY
      "Allow dereferencing Object `id`s by responding to HTTP GET requests with a representation of the Object")
     ;; "if the above is true, the server"
     (server:object-retrieval:respond-with-as2-re-ld-json
      MUST
      "Respond with the ActivityStreams object representation in response to requests that primarily Accept the media type `application/ld+json; profile=\"https://www.w3.org/ns/activitystreams\"`")
     (server:object-retrieval:respond-with-as2-re-activity-json
      SHOULD
      "Respond with the ActivityStreams object representation in response to requests that primarily Accept the media type `application/activity+json`")
     (server:object-retrieval:deleted-object:tombstone
      MAY
      "Responds with response body that is an ActivityStreams Object of type `Tombstone` (if the server is choosing to disclose that the object has been removed)")
     (server:object-retrieval:deleted-object:410-status
      SHOULD
      "Respond with 410 Gone status code if Tombstone is in response body, otherwise responds with 404 Not Found")
     (server:object-retrieval:deleted-object:404-status
      SHOULD
      "Respond with 404 status code for Object URIs that have never existed")

     (server:object-retrieval:private-403-or-404
      SHOULD
      "Respond with a 403 Forbidden status code to all requests that access Objects considered Private (or 404 if the server does not want to disclose the existence of the object, or another HTTP status code if specified by the authorization method)")

     ;; Non-normative security considerations
     (server:security-considerations:actually-posted-by-actor
      NON-NORMATIVE
      ;; [B.1](https://w3c.github.io/activitypub/#security-verification)
      "Server verifies that the new content is really posted by the actor indicated in Objects received in inbox and outbox")
     (server:security-considerations:do-not-post-to-localhost
      NON-NORMATIVE
      "By default, implementation does not make HTTP requests to localhost when delivering Activities")
     (server:security-considerations:uri-scheme-whitelist
      NON-NORMATIVE
      "Implementation applies a whitelist of allowed URI protocols before issuing requests, e.g. for inbox delivery")
     (server:security-considerations:filter-incoming-content
      NON-NORMATIVE
      "Server filters incoming content both by local untrusted users and any remote users through some sort of spam filter")
     (server:security-considerations:sanitize-fields
      NON-NORMATIVE
      "Implementation takes care to santizie fields containing markup to prevent cross site scripting attacks"))))

(define client-test-items
  (build-test-items
   `(;; MUST
     (client:submission:discovers-url-from-profile
      MUST
      "Client discovers the URL of a user's outbox from their profile")
     (client:submission:submit-post-with-content-type
      MUST
      "Client submits activity by sending an HTTP post request to the outbox URL with the Content-Type of application/ld+json; profile=\"https://www.w3.org/ns/activitystreams\"")
     (client:submission:submit-objects
      MUST
      "Client submission request body is either a single Activity or a single non-Activity Object"
      #:subitems ((client:submission:submit-objects:provide-object
                   MUST
                   "Clients provide the object property when submitting the following activity types to an outbox: Create, Update, Delete, Follow, Add, Remove, Like, Block, Undo.")
                  (client:submission:submit-objects:provide-target
                   MUST
                   "Clients provide the target property when submitting the following activity types to an outbox: Add, Remove.")))
     (client:submission:authenticated
      MUST
      "Client sumission request is authenticated with the credentials of the user to whom the outbox belongs")
     ;; (client:submission:uploading-media
     ;;  MUST
     ;;  "Client supports [uploading media](https://www.w3.org/TR/activitypub/#uploading-media) by sending a multipart/form-data request body")

     (client:submission:recursively-add-targets
      SHOULD
      "Before submitting a new activity or object, Client infers appropriate target audience by recursively looking at certain properties (e.g. `inReplyTo`, See Section 7), and adds these targets to the new submission's audience."
      #:subitems ((client:submission:recursively-add-targets:limits-depth
                   SHOULD
                   "Client limits depth of this recursion.")))
     (client:retrieval:accept-header
      MUST
      "When retrieving objects, Client specifies an Accept header with the `application/ld+json; profile=\"https://www.w3.org/ns/activitystreams\"` media type ([3.2](https://w3c.github.io/activitypub/#retrieving-objects))"))))

(define* (flatten-test-items test-items)
  (define (flatten items onto)
    (fold (lambda (test-item prev)
            (flatten
             (test-item-subitems test-item)
             (cons test-item prev)))
          onto
          items))
  (reverse (flatten test-items '())))

(define all-test-items
  (flatten-test-items
   (append client-test-items
           c2s-server-items server-inbox-delivery
           server-inbox-accept
           server-common-test-items)))

(define all-test-items-hashed
  (let ((table (make-hash-table)))
    (let lp ((items all-test-items))
      (for-each (lambda (test-item)
                  (hashq-set! table (test-item-sym test-item) test-item)
                  ;; recursively add all subitems, if any
                  (lp (test-item-subitems test-item)))
                items))
    table))

(define (load-all-implementation-reports dir)
  (map
   (lambda (file)
     (call-with-input-file (string-append dir "/" file)
       (lambda (p)
         (read-json p))))
   (scandir dir (lambda (x)
                  (not (member x '("." "..")))))))

(define (report-url report)
  (jsobj-ref report "website"))
(define (report-name report)
  (jsobj-ref report "project-name"))
(define (report-notes report)
  (jsobj-ref report "notes"))
(define (report-result-ref report sym)
  (jsobj-ref
   (jsobj-ref report "results")
   (symbol->string sym)))

(define (render-implementation-reports reports)
  "Render all implementation reports as a table.

Reports is a sorted list of all implementation reports."
  (define num-reports
    (length reports))
  (define* (profile-row key name title
                        #:key last? odd?)
    (define number-of-yes
      (count (lambda (report)
               (jsobj-ref report key))
             reports))

    `(tr (@ (style ,(if odd?
                        "background: #f9f5ee; "
                        "background: #fcfaf7; ")))
         (th (@ (style "border-right: 2px solid black;")
                (title ,title))
             ,name)
         (td (@ (class ,(if (>= number-of-yes 2)
                            "result-cell result-yes"))
                (style "border-right: 2px solid grey;"))
             ,number-of-yes)
         ,@(map
            (lambda (report)
              (if (jsobj-ref report key)
                  '(td (@ (class "result-cell result-yes"))
                       "Yes")
                  '(td (@ (class "result-cell result-no"))
                       "No")))
            reports)))
  `(div
    (@ (class "impl-reports-box")
       (style "overflow-x: auto;"))
    (table
     (@ (style "font-size: 10pt; text-align: center;")
        (class "impl-reports"))
     ;; Render the names of each reports
     (tr
      (@ (class "impl-reports-header"))
      (td (@ (style "border-bottom: 2px solid black; border-right: 2px solid black;"))
          (i "(hover for description)"))
      (td (@ (style "border-bottom: 2px solid black; border-right: 2px solid grey;"))
          (b "# yes"))
      ,@(map
         (lambda (report)
           `(th (@ (style "border-bottom: 2px solid black;")
                   (class "report-name"))
                ,(if (report-url report)
                     `(a (@ (href ,(report-url report)))
                         ,(report-name report))
                     (report-name report))))
         reports))
     ,(profile-row "testing-client"
                   "Client-to-Server Client"
                   "Implements the Client end of the ActivityPub Client-to-Server protocol")
     ,(profile-row "testing-c2s-server"
                   "Client-to-Server Server"
                   "Implements the Server end of the ActivityPub Client-to-Server protocol"
                   #:odd? #t)
     ,(profile-row "testing-s2s-server"
                   "Federated (Server-to-Server) Server"
                   "Implements the ActivityPub Server-to-Server federation protocol"
                   #:last? #t)
     ,@(apply
        append
        (let ((dark? #f))
          (map
           (lambda (test-item)
             (define number-of-yes
               (count (lambda (report)
                        (define item
                          (report-result-ref
                           report (test-item-sym test-item)))
                        (and item
                             (equal? (jsobj-ref item "result")
                                     "yes")))
                      reports))
             (set! dark? (not dark?))  ; switch row color
             `(;; (tr
               ;;  (th (@ (column-span ,num-reports)
               ;;         (class "test-item-description"))
               ;;      ,(test-item-desc test-item)))
               (tr
                (@ (class ,(string-append "test-item-row "
                                          (if dark?
                                              "dark-row"
                                              "light-row"))))
                (th (@ (title ,(test-item-desc test-item))
                       (class "report-test-item-name")
                       (style "text-align: left; border-right: 2px solid black;"))
                    ,(symbol->string (test-item-sym test-item)))
                
                (td (@ (class ,(if (>= number-of-yes 2)
                                   "result-cell result-yes"))
                       (style "border-right: 2px solid grey;"))
                    ,number-of-yes)

                ,@(map (lambda (report)
                         (define result
                           (report-result-ref report (test-item-sym test-item)))
                         (define comment
                           (and result
                                (jsobj-ref result "comment")))
                         (define-values (text class)
                           (match (and result (jsobj-ref result "result"))
                             ("yes" (values "Yes" "result-yes"))
                             ("no" (values "No" "result-no"))
                             ("inconclusive" (values "Inconclusive" "result-inconclusive"))
                             ("not-applicable" (values "N/A" "result-not-applicable"))
                             ((or 'null #f) (values "Missing" "result-missing"))))
                         `(td (@ (class ,(string-append "result-cell " class))
                                 ,@(if comment
                                       `((title ,comment))
                                       '()))
                              ,text
                              ;; Add an asterisk if there's a comment-on-hover
                              ,(if comment
                                   "*" "")))
                       reports))))
           all-test-items))))))

(define-syntax-rule (& test body)
  "For use in quasiquoting with ,@... only conditionally include things if test
works.  Like:

  `(foo bar ,@(& (try-me) 'baz))

will resolve to '(foo bar baz) if (try-me) evaluates to true, or just
'(foo bar) if #f."
  (if test
      (list body)
      (list)))

(define (additional-report-notes reports)
  (define (render-report-table report)
    (define (render-bool val)
      (if val "yes" "no"))
    (define (render-link link)
      `(a (@ (href ,link))
          ,link))
    (define rows
      `(("homepage" "Homepage" ,render-link)
        ("repo" "Source Repo" ,render-link)
        ("developers" "Developers" ,commonmark->sxml)
        ("notes" "Notes / About" ,commonmark->sxml)
        ("interops-with" "Interoperability with other implementations"
         ,commonmark->sxml)
        ("publicly-accessible" "Publicly Accessible?" ,render-bool)
        ("foss" "Free/Libre/Open Source?" ,render-bool)
        ("license" "License" ,commonmark->sxml)
        ("programming-language" "Programming Language" ,commonmark->sxml)))
    `(table
      (@ (class impl-info)
         (style "font-size: 12pt;"))
      (tr (@ (class "impl-reports-header"))
          (th (@ (colspan 2)
                 (style "border-bottom: 2px solid #6d6d6d;"))
              ,(jsobj-ref report "project-name")))
      ,(fold-right
        (match-lambda*
          (((key name renderer) prev)
           (match (jsobj-ref report key 'nothing)
             ((or 'nothing "") prev)
             ((= renderer rendered)
              (cons
               `(tr (@ (class "impl-report-info"))
                    (th ,name)
                    (td ,rendered))
               prev)))))
        '()
        rows)))
  (match (filter report-notes reports)
    ;; None?  Then nothing to render
    (() '())
    (reports
     `((h3 "Implementation details")
       ,@(map render-report-table reports)))))
