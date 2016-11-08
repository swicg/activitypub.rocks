;;; activitypub.rocks website
;;; Copyright © 2016 Christopher Allan Webber <cwebber@dustycloud.org>
;;;
;;; This program is free software: you can redistribute it and/or modify
;;; it under the terms of the GNU General Public License as published by
;;; the Free Software Foundation, either version 3 of the License, or
;;; (at your option) any later version.
;;;
;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

(use-modules (haunt asset)
             (haunt site)
             (haunt page)
             (haunt html)
             (haunt builder blog)
             (haunt builder atom)
             (haunt builder assets)
             (haunt reader skribe))

(define* (base-layout site body
                      #:key title big-logo)
  `((doctype "html")
    (head
     (meta (@ (charset "utf-8")))
     (title ,(if title
                 (string-append title " -- 8sync")
                 (site-title site)))
     ;; css
     (link (@ (rel "stylesheet")
              (href "/static/css/main.css")))
     ;; atom feed
     (link (@ (rel "alternate")
              (title "ActivityPub news")
              (type "application/atom+xml")
              (href "/feed.xml"))))
    (body
     (div (@ (class "main-wrapper"))
          (header (@ (id "site-header"))
                  (a (@ (href "/"))
                     "ActivityPub Rocks!")
                  ;; ;; Header menu
                  ;; (div (@ ,(if big-logo
                  ;;              '(class "navbar-menu big-navbar")
                  ;;              '(class "navbar-menu small-navbar")))
                  ;;      ,@(map
                  ;;         (lambda (item)
                  ;;           (match item
                  ;;             ((name url)
                  ;;              `(div
                  ;;                (a (@ (href url))
                  ;;                   ,name)))))
                  ;;         header-menu))
                  )
          (div (@ (class "site-main-content"))
               ,body))
     ;; TODO: Link to source.
     (div (@ (class "footer"))
          (a (@ (href "https://notabug.org/cwebber/8sync-website"))
             "Site contents")
          " dual licensed under "
          (a (@ (href "https://creativecommons.org/licenses/by-sa/4.0/"))
             "Creative Commons 4.0 International")
          " and "
          (a (@ (href "http://www.gnu.org/licenses/gpl-3.0.en.html"))
             "the GNU GPL, version 3 or any later version")
          ".  Powered by "
          (a (@ (href "http://haunt.dthompson.us/"))
             "Haunt")
          "."))))



;;; Index page

(define pitch
  '(div
    (@ (class "pitch"))
    (p "Don't you miss the days when the web really was the world's greatest "
       "decentralized network?  Before everything got locked down into a handful "
       "of walled gardens?  So do we.")

    ;; Main intro
    (p "Enter "
       (a (@ (href "https://www.w3.org/TR/activitypub/"))
          "ActivityPub")
       "!  ActivityPub is a decentralized social networking protocol"
       "based on the "
       (a (@ (href "https://www.w3.org/TR/activitystreams-core/"))
          "ActivityStreams 2.0")
       " data format and is being developed as part of the "
       (a (@ (href "https://www.w3.org/wiki/Socialwg"))
          "W3C Social Web Working Group")
       ".  "
       "It provides a client to server API for creating, updating and deleting "
       "content, as well as a federated server to server API for delivering "
       "notifications and subscribing to content.")

    (p "Sounds exciting?  Dive in!")))

(define read-it
  (let ((wrap-it
         (lambda (link name)
           `(p "* ==> "
               (a (@ (href ,link))
                  ,name)
               " <== *"))))
    `(div (@ (class "read-it"))
          ,(wrap-it "https://www.w3.org/TR/activitypub/"
                    "Latest published version")
          ,(wrap-it "https://www.w3.org/TR/activitypub/"
                    "Latest editor's draft"))))

(define (index-content posts)
  `(div ,pitch ,read-it))

(define (index-page site posts)
  (make-page
   "index.html"
   (base-layout site
                (index-content posts)
                #:big-logo #t)
   sxml->html))


;;; Site

(site #:title "ActivityPub Rocks!"
      #:domain "activitypub.rocks"
      #:default-metadata
      '((author . "Christopher Allan Webber"))
      #:readers (list skribe-reader)
      #:builders (list (blog #:prefix "/news")
                       index-page
                       (atom-feed #:blog-prefix "/news")
                       (static-directory "static" "static")
                       (atom-feeds-by-tag)))
