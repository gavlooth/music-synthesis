;;;; music-synthesis.lisp

(in-package #:music-synthesis)
;(ql:quickload :cl-patterns)
;(ql:quickload :music-synthesis)
;(ql:quickload :metatilities)



(use-package :iterate)

(print sc:*sc-synth-program*)

(setf sc:*s* (sc:make-external-server "localhost" :port 48800))
(
 sc:server-boot sc:*s*)

(sc:jack-connect)

(defvar *synth*)

(defvar *sample-files*  "/usr/share/lmms/samples")


(defvar *wav-bass* (sc:buffer-read "/home/heefoo/lmms/raw/bass01.wav"))



(defvar *bass-ogg* (sc:buffer-read "/home/heefoo/collider/bass01.wav"))
; (loop for x in (uiop:directory-files (pathname (format nil "~a*sample-files* "basses/"))) do (print x))



(sc:defsynth drum ((freq 3000))
 (let* ((env (sc:env-gen.ar (sc:perc 0.001 0.1) :act :free))
        (sig (sc:lpf.ar (sc:white-noise.ar) (* freq env))))
   (sc:out.ar 0 (sc:pan2.ar sig 0 0.2))))


(sc:defsynth bass ((out 0) (freq 440) (amp 0.1) (gate 1) (cutoff 200) (rq 0.2) (pan 0.0) (drive 2.0) (filtertime 1))
  (let*  ((osc (sc:saw.ar freq))
          (oschiend (sc:mix (sc:saw.ar (loop for x in '(0.25 1 1.5)  collect (* x freq))))) (filterenv (sc:env-gen.ar (sc:adsr 0 0.5 0.2 0.2 ) :gate gate :time-scale filtertime :act :free))
          (filter (sc:rlpf.ar osc (* cutoff (+ 100 filterenv)) rq))
          (filterhiend* (sc:rlpf.ar oschiend (* cutoff (+ 100 filterenv)) rq))
          (filterhiend (* filterhiend* (drive (abs filterhiend*)) (+ (expt filterhiend* 2)  (* (abs filterhiend*) (- drive 1))  1))))
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


(sc:defsynth sample-bash ((buffer 0) (rate 1) (start 0) (amp 0.5) (out 0))
  (let ((sig (sc:play-buf.ar 2 buffer (* rate (sc:buf-rate-scale.ir buffer))
                             :start-pos (* start (sc:buf-frames.ir buffer))
                             :act :free)))
    (sc:out.ar out (* amp sig))))



(sc:defsynth sample-bass-2 ((buffer 0) (freq 440) (start 0) (amp 0.5) (out 0))
  (let ((sig (sc:play-buf.ar 2 buffer (*  (/ freq 440  ) (sc:buf-rate-scale.ir buffer))
                             :start-pos (* start (sc:buf-frames.ir buffer))
                             :act :free)))
    (sc:out.ar out (* amp sig))))

 ;; We can use a similar function to make a melody, but we don't need to schedule the callbacks
(defun make-melody (times n &optional (offset 0))
  (when (> n 0)
    (sc:at times (sc:synth 'saw-synth :note (+ offset (alexandria:random-elt '(62 65 69 72))))
      (let ((next-time (+ times (alexandria:random-elt '(0 1 2 1.5)))))
        (make-melody next-time (- n 1) offset)))))

(defvar *player*)


(setf  *player* (sc:play (sc:white-noise.ar 0.1)))

(setf  *player* (sc:play (sc:synth 'sample-bass-2 :buffer *bass-ogg* :freq 587.33 :amp 3)))



(sc:free *player*)

(sc:stop)

(defvar *the-buffer* (sc:buffer-alloc  65536 :server sc:*s*  :chanls 2))

(defvar music-notes
  (dict
    'D0	1879.69
    'E0	1674.62
    'F0	1580.63
    'G0	1408.18
    'A0	1254.55
    'B0	1117.67
    'C1	1054.94
    'D1	939.85
    'E1	837.31
    'F1	790.31
    'G1	704.09
    'A1	627.27
    'B1	558.84
    'C2	527.47
    'D2	469.92
    'E2	418.65
    'F2	395.16
    'G2	352.04
    'A2	313.64
    'B2	279.42
    'C3	263.74
    'D3	234.96
    'E3	209.33
    'F3	197.58
    'G3	176.02
    'A3	156.82
    'B3	139.71
    'C4	131.87
    'D4	117.48
    'E4	104.66
    'F4	98.79
    'G4	88.01
    'A4	78.41
    'B4	69.85
    'C5	65.93
    'D5	58.74
    'E5	52.33
    'F5	49.39
    'G5	44.01
    'A5	39.20
    'B5	34.93
    'C6	32.97
    'D6	29.37
    'E6	26.17
    'F6	24.70
    'G6	22.00
    'A6	19.60
    'B6	17.46
    'C7	16.48
    'D7	14.69
    'E7	13.08
    'F7	12.35
    'G7	11.00
    'A7	9.80
    'B7	8.73
    'C8	8.24
    'D8	7.34
    'E8	6.54
    'F8	6.17
    'G8	5.50
    'A8	4.90
    'B8	4.37


    'C#0 	1991.47
    'D#0 	1774.20
    'F#0 	1491.91
    'G#0 	1329.14
    'A#0 	1184.13
    'C#1 	995.73
    'D#1 	887.10
    'F#1 	745.96
    'G#1 	664.57
    'A#1 	592.07
    'C#2 	497.87
    'D#2 	443.55
    'F#2 	372.98
    'G#2 	332.29
    'A#2 	296.03
    'C#3 	248.93
    'D#3 	221.77
    'F#3 	186.49
    'G#3 	166.14
    'A#3 	148.02
    'C#4 	124.47
    'D#4 	110.89
    'F#4 	93.24
    'G#4 	83.07
    'A#4 	74.01
    'C#5 	62.23
    'D#5 	55.44
    'F#5 	46.62
    'G#5 	41.54
    'A#5 	37.00
    'C#6 	31.12
    'D#6 	27.72
    'F#6 	23.31
    'G#6 	20.77
    'A#6 	18.50
    'C#7 	15.56
    'D#7 	13.86
    'F#7 	11.66
    'G#7 	10.38
    'A#7 	9.25
    'C#8 	7.78
    'D#8 	6.93
    'F#8 	5.83
    'G#8 	5.19
    'A#8 	4.63
    'Db0 	1991.47
    'Eb0 	1774.20
    'Gb0 	1491.91
    'Ab0 	1329.14
    'Bb0 	1184.13
    'Db1 	995.73
    'Eb1 	887.10
    'Gb1 	745.96
    'Ab1 	664.57
    'Bb1 	592.07
    'Db2 	497.87
    'Eb2 	443.55
    'Gb2 	372.98
    'Ab2 	332.29
    'Bb2 	296.03
    'Db3 	248.93
    'Eb3 	221.77
    'Gb3 	186.49
    'Ab3 	166.14
    'Bb3 	148.02
    'Db4 	124.47
    'Eb4 	110.89
    'Gb4 	93.24
    'Ab4 	83.07
    'Bb4 	74.01
    'Db5 	62.23
    'Eb5 	55.44
    'Gb5 	46.62
    'Ab5 	41.54
    'Bb5 	37.00
    'Db6 	31.12
    'Eb6 	27.72
    'Gb6 	23.31
    'Ab6 	20.77
    'Bb6 	18.50
    'Db7 	15.56
    'Eb7 	13.86
    'Gb7 	11.66
    'Ab7 	10.38
    'Bb7 	9.25
    'Db8 	7.78
    'Eb8 	6.93
    'Gb8 	5.83
    'Ab8 	5.19
    'Bb8 	4.63
    ))
