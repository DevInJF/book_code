;---
; Excerpted from "Mastering Clojure Macros",
; published by The Pragmatic Bookshelf.
; Copyrights apply to this code. It may not be used to create training material, 
; courses, books, articles, and the like. Contact us if you are in doubt.
; We make no guarantees that this code is fit for any purpose. 
; Visit http://www.pragmaticprogrammer.com/titles/cjclojure for more book information.
;---
(do
  (fancy-assert
    (= __ true)
    "We shall contemplate truth by testing reality, via equality")

  (fancy-assert
    (= __ (+ 1 1))
    "To understand reality, we must compare our expectations against reality"))
