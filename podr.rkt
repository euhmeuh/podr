#lang racket/base

(require "libgpod.rkt")

(define ipod (open-ipod "/dev/ipod"))

(for-each
  (lambda (artist)
    (displayln artist))
  (list-albums ipod))
