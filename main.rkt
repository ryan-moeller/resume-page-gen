#lang racket/base

;; ISC License
;;
;; Copyright (c) 2018, Ryan Moeller
;;
;; Permission to use, copy, modify, and/or distribute this software for any
;; purpose with or without fee is hereby granted, provided that the above
;; copyright notice and this permission notice appear in all copies.
;;
;; THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
;; WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
;; MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
;; ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
;; WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
;; ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
;; OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.


;; Resume page generator
;;
;; Outputs my resume as index.html in the current directory.
;;
;; An existing index.html will be overwritten, so be careful!
;;
;; The output is not nicely formatted, but you can use browser
;; dev tools for manually checking the generated HTML.

(require css-expr
         net/url
         racket/format
         racket/string
         txexpr)


;;
;; External Resources
;;

(define uikit-version "3.19.1")

(define (cdnjs-href relative)
  (path->string
   (build-path "https://cdnjs.cloudflare.com" relative)))

(define (uikit-cdnjs-path relative)
  (build-path "ajax/libs/uikit" uikit-version relative))

(define uikit-css-href
  (cdnjs-href (uikit-cdnjs-path "css/uikit.min.css")))
(define uikit-js-src
  (cdnjs-href (uikit-cdnjs-path "js/uikit.min.js")))
(define uikit-icons-js-src
  (cdnjs-href (uikit-cdnjs-path "js/uikit-icons.min.js")))

(define firasans-css-href
  "https://fonts.googleapis.com/css?family=Fira+Sans:500")
(define firacode-css-href
  "https://cdn.rawgit.com/tonsky/FiraCode/cf405dd6/distr/fira_code.css")

(define fontawesome-js-src
  (cdnjs-href "ajax/libs/font-awesome/6.5.1/js/all.min.js"))
(define fontawesome-js-integrity
  "sha512-GWzVrcGlo0TxTRvz9ttioyYJ+Wwk9Ck0G81D+eO63BaqHaJ3YZX9wuqjwgfcV/MrB2PhaVX9DkYVhbFpStnqpQ==")


;;
;; Embedded stylesheet
;;

(define embedded-css
  (let ([shadow-color '\#333])
    (css-expr->css
     (css-expr
      [.topbg
       #:background-image (apply url "images/top.jpg")]
      [(> .pop li a)
       #:font (#:family "Fira Sans" sans-serif
               #:size large)
       #:text (#:shadow (0px 0px 3px ,shadow-color)
               #:transform lowercase)]
      [.myname
       #:font (#:family "Fira Sans" sans-serif
               #:size xx-large)
       #:text-shadow (0px 0px 6px ,shadow-color)
       #:color white
       #:margin 0]
      [.mykind
       #:font-family "Fira Code" monospace
       #:text-shadow (0px 0px 4px ,shadow-color)
       #:margin-top 0
       #:padding-bottom 1rem]
      [.uk-heading-divider
       #:font (#:family "Fira Sans" sans-serif
               #:size x-large)]
      [.uk-section
       #:padding (#:top 2rem
                  #:bottom 2rem)]
      [(> .uk-heading-divider span)
       #:font (#:family "Fira Code" monospace
               #:size small)
       #:padding-left 2rem
       #:color \#aaa]
      [@media print
              [nav
               #:display none !important]
              [p.myname
               #:font-size x-large]
              [p.mykind
               #:font-size medium #:padding-bottom 0]
              [.uk-heading-divider
               #:font-size large]
              [div.uk-section
               #:padding (#:top 0 #:bottom 1rem)]
              [ul.uk-nav
               #:width 100%]
              [(> ul.uk-nav li)
               #:display inline-block
               #:padding-right 2rem]]
      ))))


;;
;; UIkit elements
;;

(define (uk-section attrs content)
  (attr-join (txexpr 'div attrs content)
             'class "uk-section"))
(define (uk-container-small attrs content)
  (attr-join (txexpr 'div attrs content)
             'class "uk-container uk-container-small"))
(define (uk-heading-divider attrs content)
  (attr-join (txexpr 'h2 attrs content)
             'class "uk-heading-divider"))


;;
;; Custom elements
;;

(define (topbar section-names)
  (define (nav-link section)
    `(li (a ([href ,(string-append "#" section)]) ,section)))
  `(div ([class "topbg
                 uk-panel uk-text-center uk-light
                 uk-background-cover uk-background-primary
                 uk-background-blend-difference"])
        (nav ([class "uk-navbar-container uk-navbar-transparent"]
              [uk-navbar "true"])
             (div ([class "uk-navbar-center"])
                  (ul ([class "uk-navbar-nav pop"])
                      . ,(map nav-link section-names))))
        (p ([class "myname"]) "Ryan Moeller")
        (p ([class "mykind"]) ">developer_")))

(define (section-container attrs content)
  (uk-section attrs (list (uk-container-small '() content))))

(define (section-heading name comment)
  (uk-heading-divider '() `(,name (span ,(~a "<!-- " comment " -->")))))

(define (nav-list items)
  (define (nav-item icon href ident location)
    (define (nav-icon icon-classes)
      (attr-join
       '(i ([class "fa-lg uk-transition-scale-up uk-transition-opaque"]))
       'class icon-classes))
    `(li ([class "uk-transition-toggle"] [tabindex "0"])
         (a ([href ,href]) ,(nav-icon icon) 'ensp (em ,ident) ,location)))
  (txexpr 'ul '([class "uk-nav uk-nav-default uk-width-1-3@m"])
          (map (λ (item) (apply nav-item item)) items)))


;;
;; Content
;;

(define body-content
  (list

   (topbar '(".io" ".me" ".codes" ".edu" ".jobs"))

   (let ([section ".io"]
         [description "contact info"]
         [email "fas fa-envelope"])
     (section-container
      `([id ,section])
      (list (section-heading section description)
            (nav-list `([,email
                         "mailto:ryan-moeller@att.net"
                         "ryan-moeller@att.net" " by email"]))
            )))

   (let ([section ".me"]
         [description "about me"])
     (section-container
      `([id ,section])
      `(,(section-heading section description)
        (p "Over 15 years of programming experience in embedded hardware and
          software, operating system kernel and userland utilities, web
          development, system administration, and data visualization.")
        (p "Diverse language skills, including C, C++, JavaScript, Python, Java,
          Rust, Racket (Scheme), Clojure/ClojureScript, Scala, OCaml, Lua, C#,
          F#, Haskell, PureScript, Verilog, (Bourne/Korn) Shell, AWK, Erlang/OTP,
          Elixir, Lisp Flavored Erlang (LFE), and more...")
        (p "Specialized experience in systems programming, automated testing,
          foreign function interfaces (FFI), and functional programming.")
	(p "Contributes to open source software projects including the FreeBSD
          operating system, OpenZFS, and public personal projects.")
        )))

   (let ([section ".codes"]
         [description "projects"]
         [github "fab fa-github"])
     (section-container
      `([id ,section])
      (list (section-heading section description)
            (nav-list `([,github
                         "https://github.com/ryan-moeller"
                         "ryan-moeller" " on GitHub"]
			))
            )))

   (let ([section ".edu"]
         [description "education"])
     (section-container
      `([id ,section])
      `(,(section-heading section description)
        (p "Bachelor of Science in Computer Science, Minor in Mathematics,
          awarded by Sonoma State University")
        )))

   (let ([section ".jobs"]
         [description "work experience"])
     (section-container
      `([id ,section])
      `(,(section-heading section description)
        (ul
         (li "Operating system engineer @ iXsystems")
         (li "FreeBSD operating system development intern @ iXsystems")
         (li "Freelance web developer and system administrator")
         (li "Graphic designer")
         (li "Developer of live music visualizations")
         (li "Event production director (technical director, assistant director)")
         (li "Event production designer (lighting, sound, set)")
         (li "Event production technician (lighting, sound, video)")
         ))))))

(define doc
  `(html
    (head (title "Ryan Moeller - Resume")

          (meta ([charset "utf-8"]))
          (meta ([name "viewport"]
                 [content "width=device-width, initial-scale=1"]))

          ;; UIkit CSS
          (link ([href ,uikit-css-href] [rel "stylesheet"]))
          ;; UIkit JS
          (script ([src ,uikit-js-src]))
          (script ([src ,uikit-icons-js-src]))

          ;; Fira Sans
          (link ([href ,firasans-css-href] [rel "stylesheet"]))
          ;; Fira Code
          (link ([href ,firacode-css-href] [rel "stylesheet"]))

          ;; Font Awesome
          (script ([src ,fontawesome-js-src]
                   [integrity ,fontawesome-js-integrity]
                   [crossorigin "anonymous"]
                   [defer "true"]))

          (style ,embedded-css))
    (body . ,body-content)))


;;
;; Generation
;;

(define index-html (open-output-file "index.html" #:exists 'truncate))
(displayln "<!DOCTYPE html>" index-html)
(display (xexpr->html doc) index-html)
(close-output-port index-html)
