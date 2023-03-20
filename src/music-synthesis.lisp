;;;; music-synthesis.lisp

(in-package #:music-synthesis)
;(ql:quickload :cl-collider)

;(ql:quickload :music-synthesis)

(print sc:*sc-synth-program*)

(setf sc:*s* (sc:make-external-server "localhost" :port 48800))

(sc:server-boot sc:*s*)

(sc:jack-connect)

(defvar *synth*)

(sc:defsynth drum ((freq 3000))
 (let* ((env (sc:env-gen.ar (sc:perc 0.001 0.1) :act :free))
        (sig (sc:lpf.ar (sc:white-noise.ar) (* freq env))))
   (sc:out.ar 0 (sc:pan2.ar sig 0 0.2))))


; (defsynth newsynth ((gate 1) (freq 440) (amp 0.5) (pan 0) (out 0))
;   (let* ((env (env-gen.kr (adsr 0.001 0.1 0.5 0.1) :gate gate :act :free))
;          (sig (saw.ar freq)))
;     (out.ar out (pan2.ar sig pan (* amp env)))))

;(setf *synth* (sc:play (sc:sin-osc.ar '(320 321) 0 .2)))

;(setf *synth* (sc:play (sc:white-noise.ar 0.1)))

(setf *synth* (sc:play (sc:synth 'drum :freq 3000)))

;(sc:free *synth*)

;(sc:server-quit sc:*s*)
