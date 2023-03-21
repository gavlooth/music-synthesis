;;;; music-synthesis.lisp

(in-package #:music-synthesis)
;(ql:quickload :cl-patterns)

;(ql:quickload :music-synthesis)

;(ql:quickload :metatilities)
(use-package :metatilities)
(use-package :iterate)

(print sc:*sc-synth-program*)

(setf sc:*s* (sc:make-external-server "localhost" :port 48800))

(sc:server-boot sc:*s*)

(sc:jack-connect)

(defvar *synth*)

(sc:defsynth drum ((freq 3000))
 (let* ((env (sc:env-gen.ar (sc:perc 0.001 0.1) :act :free))
        (sig (sc:lpf.ar (sc:white-noise.ar) (* freq env))))
   (sc:out.ar 0 (sc:pan2.ar sig 0 0.2))))



;  SynthDef(\bass,{|out= 0 freq = 440 amp = 0.1 gate=1 cutoff= 1000 rq=0.2 pan=0.0 drive = 2.0, filtertime=1 |

; (loop for x in '(0.25 1 1.5)  collect (* x 3))

(sc:defsynth bass ((out 0) (freq 440) (amp 0.1) (gate 1) (cutoff 200) (rq 0.2) (pan 0.0) (drive 2.0) (filtertime 1))
  (let*  ((osc (sc:saw.ar freq))
          (oschiend (sc:mix (sc:saw.ar (loop for x in '(0.25 1 1.5)  collect (* x freq))))) (filterenv (sc:env-gen.ar (sc:adsr 0 0.5 0.2 0.2 ) :gate gate :time-scale filtertime :act :free))
          (filter (sc:rlpf.ar osc (* cutoff (+ 100 filterenv)) rq))
          (filterhiend* (sc:rlpf.ar oschiend (* cutoff (+ 100 filterenv)) rq))
          (filterhiend (* filterhiend* (/ (+ drive (abs filterhiend*)) (+ (expt filterhiend* 2)  (* (abs filterhiend*) (- drive 1))  1))))
          (env  (sc:env-gen.ar (sc:adsr 0.01 0 0.9 0.05) :gate gate :act :free))
          (sig (* filter env amp 2))
          (sighiend (* filterhiend env amp 2)))
         (sc:out.ar  out (sc:pan2.ar (* filter env amp 2) pan))))


(sc:defsynth bass-warsaw ((out 0) (freq 440) (amp 0.5) (gate 1) (pan 0) (att 0.01)
                                  (dec 0.3) (sus 0.5)  (rel 0.1) (slide-time 0.17)
                                  (cutoff 1100) (width 0.15) (detune 1.004) (preamp 4))
  (let* ((env   (sc:env-gen.kr (sc:adsr att dec sus rel) :gate gate :act :free))
         (freq* (sc:lag.kr freq slide-time))
         (snd*  (* env (sc:distort (sc:mix (sc:var-saw.ar (list freq* (* freq* detune )) 0  width preamp)))))
         (snd   (sc:lpf.ar snd* cutoff amp)))

    (sc:out.ar out (sc:pan2.ar snd pan))))


(sc:defsynth acidO-to-3092 ((out 0) (freq 440) (amp 0.1) (att 0.001) (rel 0.5) (pan 0)  (lag-time 0.12)  (filter-range 6) (width 0.51) (rq 0.3))
  (let* ((pitch (sc:cpsmidi freq))
         (amp-env (sc:env-gen.kr (sc:perc att rel (* 12 filter-range)) :act :free))
         (filter-env (sc:env-gen.kr (sc:perc att rel (* 12 filter-range))))
         (snd*  (sc:range (sc:pulse.ar  (sc:midicps  pitch) 0  width ) -1 1))
         (snd   (* amp-env (sc:distort (sc:rlpf.ar  snd* (sc:midicps (+ pitch filter-env)) rq)))))
    (sc:out.ar out (sc:pan2.ar snd pan))))

; LFPulse.ar(freq: 440.0, iphase: 0.0, width: 0.5, mul: 1.0, add: 0.0)
; (setf *synth* (sc:play (sc:synth 'acidO-to-3092 :freq 440)))

; (setf *synth* (sc:play (sc:synth 'bass-warsaw)))

; (sc:stop)

;(sc:free *synth*)

;(sc:server-quit sc:*s*)




