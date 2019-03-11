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

(use-modules (guix packages)
             (guix licenses)
             (guix git-download)
             (guix build-system gnu)
             (gnu packages)
             (gnu packages autotools)
             (gnu packages guile)
             (gnu packages guile-xyz)
             (gnu packages pkg-config)
             (gnu packages texinfo))

(define aprocks-site
  (package
    (name "aprocks-site")
    (version "git")
    (source #f)
    (build-system gnu-build-system)
    (synopsis #f)
    (description #f)
    (license gpl3+)
    (home-page "http://activitypub.rocks")
    (inputs
     `(("guile" ,guile-2.2)
       ("haunt" ,haunt)
       ("guile-reader" ,guile-reader)
       ("guile-sjson" ,guile-sjson)
       ("guile-commonmark" ,guile-commonmark)))))

aprocks-site
