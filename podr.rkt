#lang racket/base

(require "libgpod.rkt")

(define ipod (open-ipod (car (find-mount-points))))

(list-artists ipod)
