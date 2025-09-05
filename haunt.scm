;;; activitypub.rocks website
;;; Copyright © 2016 Christine Lemmer-Webber <cwebber@dustycloud.org>
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
             (haunt post)
             (haunt html)
             (haunt utils)
             (haunt builder blog)
             (haunt builder atom)
             (haunt builder assets)
             (haunt reader skribe)
             (haunt reader commonmark)
             (www reports))

(define %current-directory (getcwd))
(define %implementation-report-directory
  (string-append %current-directory
                 "/reports"))

(define* (base-tmpl site body #:key title)
  `((doctype "html")
    (head
     (meta (@ (charset "utf-8")))
     (title ,(if title
                 (string-append title " -- ActivityPub Rocks!")
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
      (header (@ (id "site-header"))
        (a (@ (href "/")
             ;; (style "margin-left: -25px;")
             )
          (img (@ (src "/static/images/ActivityPub-logo.svg"))))
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
        ,body)
      (footer
          (a (@ (href "https://github.com/swicg/activitypub.rocks/"))
             "Site contents")
          " dual licensed under "
          (a (@ (href "https://creativecommons.org/licenses/by-sa/4.0/"))
             "Creative Commons Attribution-Sharealike 4.0 International")
          " and "
          (a (@ (href "http://www.gnu.org/licenses/gpl-3.0.en.html"))
             "the GNU GPL, version 3 or any later version")
          ".  ActivityPub logo by mray, released into public domain under "
          (a (@ (href "https://creativecommons.org/publicdomain/zero/1.0/"))
             "CC0 1.0")
          ". Powered by "
          (a (@ (href "http://haunt.dthompson.us/"))
             "Haunt")
          "."))))

;;; Blog

(define (post-uri site post)
  (string-append "/news/" (site-post-slug site post) ".html"))

(define* (post-template post #:key post-link)
  `(div (@ (class "content-box blogpost"))
        (header (@ (class "post-title"))
                ,(if post-link
                     `(a (@ (href ,post-link))
                         ,(post-ref post 'title))
                     (post-ref post 'title)))
        (div (@ (class "post-about"))
             (span (@ (class "by-line"))
                   ,(post-ref post 'author))
             " -- " ,(date->string* (post-date post)))
        (div (@ (class "post-body"))
             ,(post-sxml post))))

(define (collection-template site title posts prefix)
  ;; In our case, we ignore the prefix argument because
  ;; the filename generated and the pathname might not be the same.
  ;; So we use (prefix-url) instead.
  (define (post-uri post)
    (string-append "/news/" (site-post-slug site post) ".html"))
  `((div (@ (class "news-header"))
         (h3 "recent news"))
    (div (@ (class "post-list"))
         ,@(map
            (lambda (post)
              (post-template post
                             #:post-link (post-uri post)))
            posts))))

(define aprocks-haunt-theme
  (theme #:name "ActivityPub Rocks"
         #:layout
         (lambda (site title body)
           (base-tmpl
            site body
            #:title title))
         #:post-template post-template
         #:collection-template collection-template))


;;; Index page

(define tutorial-image
  `(div (@ (style "text-align: center"))
        (a (@ (href "https://www.w3.org/TR/activitypub/#Overview"))
           (img (@ (src "/static/images/ActivityPub-tutorial-image.png")
                   (alt "ActivityPub tutorial image"))))))


(define read-it
  (let ((wrap-it
         (lambda (link name)
           `(p "==> "
               (a (@ (href ,link))
                  ,name)
               " <=="))))
    `(div (@ (class "read-it"))
          ,(wrap-it "https://www.w3.org/TR/activitypub/"
                    "Latest published version")
          ,(wrap-it "https://w3c.github.io/activitypub/"
                    "Latest editor's draft"))))

(define pitch
  `(div
    (@ (class "pitch"))
    (p "Don't you miss the days when the web really was the world's greatest "
       "decentralized network?  Before everything got locked down into a handful "
       "of walled gardens?  So do we.")

    ,tutorial-image

    ;; Main intro
    (p "Enter "
       (a (@ (href "https://www.w3.org/TR/activitypub/"))
          "ActivityPub")
       "!  ActivityPub is a decentralized social networking protocol "
       "based on the "
       (a (@ (href "https://www.w3.org/TR/activitystreams-core/"))
          "ActivityStreams 2.0")
       " data format. "
       "ActivityPub is an official W3C recommended standard published by the "
       (a (@ (href "https://www.w3.org/wiki/Socialwg"))
          "W3C Social Web Working Group")
       ".  "
       "It provides a client to server API for creating, updating and deleting "
       "content, as well as a federated server to server API for delivering "
       "notifications and subscribing to content.")

    ;; (p "Applications already having adopted or adopting ActivityPub include: "
    ;;    )

    ;; TODO: Mention existing applications adopting ActivityPub
    (p "Sounds exciting?  Dive in!")

    ,read-it

    (p "Or, are you a user looking for ActivityPub software to use? "
       "Check out this "
       (a (@ (href "https://socialhub.activitypub.rocks/pub/guide-for-activitypub-users"))
          "guide for ActivityPub users")
       " (community edited)!")
    ))

(define for-implementers
  `(div (@ (class "for-implementers-box"))
        (header "~= Hey, Implementers! =~")
        (p "We're so stoked to have you implementing ActivityPub!  "
           "To make sure ActivityPub implementations work together, we have:")
        (ul (li (strong (a (@ (href "https://socialhub.activitypub.rocks/pub/guide-for-new-activitypub-implementers"))
                           "Guide for new ActivityPub implementers:"))
                " Community edited and unofficial, but useful!"))
        (p "Looking to discuss implementing ActivityPub?  You can join the "
           (code "#social") " IRC channel on " (code "irc.w3.org") "! "
           "See also "
           (a (@ (href "https://socialhub.activitypub.rocks/"))
              "SocialHub")
           ", a community-run forum to discuss ActivityPub developments and ideas, "
           "and the "
           (a (@ (href "https://www.w3.org/wiki/SocialCG"))
              "Social CG")
           ", a W3C Community Group to continue the work of advancing the "
           "federated social web... including ActivityPub!")))

(define (posts-with-tag posts tag)
  (filter (lambda (p)
             (member tag (post-tags p)))
           posts ))

(define (posts-without-tag posts tag)
  (filter (lambda (p)
             (not (member tag (post-tags p))))
           posts ))

(define (news-feed site posts)
  `(div (@ (class "news-feed"))
        (header "-=* ActivityPub News *=-")
        (ul
         ,(map (lambda (post)
                 `(li (a (@ (href ,(post-uri site post)))
                         ,(post-ref post 'title))
                      (div (@ (class "news-feed-item-date"))
                           ,(date->string* (post-date post)))))
               (take-up-to 10 (posts/reverse-chronological (posts-without-tag posts "old")))))
        (p (@ (class "older"))
          (a (@ (href "/historic/news/index.html"))
              "Older News")
        )))

(define about
  `(div (@ (class "about-box"))
        (header "~= About this Site =~")
        (p "This site is maintained by the Web Task Force of the Social Community Group in the W3C,"
           " the current steward of the ActivityPub stack of standards.")
        (p "To learn more about the SocialCG and how to participate, go to its "
           (a (@ (href "https://www.w3.org/community/socialcg/")) "home page")
           ".")
        (p "To contribute to this website, come to a Task Force meeting (see "
           (a (@ (href "https://www.w3.org/groups/cg/socialcg/calendar/"))
              "SocialCG calendar")
           ") or submit an issue or pull request "
           (a (@ (href "https://github.com/swicg/activitypub.rocks")) "on Github")
           ".")))

(define historic-content
  `(div (@ (class "historic"))
        (p (@ (class "historic"))
          (a (@ (href "/historic/content/index.html"))
              "Historic Content"))))


(define (index-content site posts)
  `(div ,pitch
        ,for-implementers
        ,(news-feed site posts)
        ,about
        ,historic-content))

(define (index-page site posts)
  (make-page
   "index.html"
   (base-tmpl site
                (index-content site posts))
   sxml->html))


;;; Test and implementations report stub pages

(define (test-page-tmpl site)
  (define tmpl
    '(div
      (p "The original test suite is offline and only of historic interest.")
      (p "Test-related resources: to be added (work in progress, pardon our dust).")))
  (base-tmpl site tmpl))

(define (test-page site posts)
  (make-page
   "test/index.html"
   (test-page-tmpl site)
   sxml->html))


(define (impl-report-page-tmpl site)
  (define reports
    (load-all-implementation-reports
     %implementation-report-directory))
  (define tmpl
    `(div
      (p (@ (class "historic")) "(Of historic interest only)")
      (p (i "To submit an implementation report, use the "
            (s "ActivityPub test suite")
            " to generate an implementation report and then submit "
            "that report to the "
            (a (@ (href "https://github.com/w3c/activitypub/issues"))
               "ActivityPub issue tracker") ". "
            "(Or, file a PR directly to "
            (a (@ (href "https://gitlab.com/dustyweb/activitypub.rocks/tree/master/reports"))
               "this site's repository") ".)"))
      (h3 "Implementation reports")
      ,(render-implementation-reports reports)
      ,@(additional-report-notes reports)))
  (base-tmpl site tmpl))

(define (impl-report-page site posts)
  (make-page
   "implementation-report/index.html"
   (impl-report-page-tmpl site)
   sxml->html))

(define (historic-news-page-tmpl site posts)
  (define tmpl
    `(div
      (h1 "Historic News")
      (p "For current news, see the "
         (a (@ (href "/")) "home page."))
      (ul
       ,(map (lambda (post)
               `(li (a (@ (href ,(post-uri site post)))
                       ,(post-ref post 'title))
                    (div (@ (class "news-feed-item-date"))
                         ,(date->string* (post-date post)))))
              (posts/reverse-chronological (posts-with-tag posts "old"))))))
  (base-tmpl site tmpl))


(define (historic-news-page site posts)
  (make-page
   "historic/news/index.html"
   (historic-news-page-tmpl site posts)
   sxml->html))

(define (historic-content-page-tmpl site posts)
  (define tmpl
    `(div
      (h1 "Historic Content")
      (p "Content that may be of historical interest.")
      (ul
        (li (strong (a (@ (href "/implementation-report/"))
                       "Implementation reports:"))
            " See the implementation coverage of applications which implemented "
            "ActivityPub during the standardization process."))))
  (base-tmpl site tmpl))

(define (historic-content-page site posts)
  (make-page
   "historic/content/index.html"
   (historic-content-page-tmpl site posts)
   sxml->html))


;;; Site

(site #:title "ActivityPub Rocks!"
      #:domain "activitypub.rocks"
      #:default-metadata
      '((author . "Social Web Community Group (SWICG)"))
      #:readers (list commonmark-reader skribe-reader)
      #:builders (list (blog #:prefix "/news"
                             #:theme aprocks-haunt-theme)
                       index-page
                       test-page
                       impl-report-page
                       historic-news-page
                       historic-content-page
                       (atom-feed #:blog-prefix "/news")
                       (static-directory "static" "/static")
                       (atom-feeds-by-tag)))
