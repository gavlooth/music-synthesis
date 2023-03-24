
(in-package #:music-synthesis)
;(ql:quickload :music-synthesis)
; (print sc:*sc-synth-program*)

(setf sc:*s* (sc:make-external-server "localhost" :port 48800))
(sc:server-boot sc:*s*)

(sc:jack-connect)

(defvar *synth*)

(defvar *sample-files*  "/usr/share/lmms/samples")

(defvar *wav-bass* (sc:buffer-read "/home/heefoo/lmms/raw/bass01.wav"))

(defvar *bass-ogg* (sc:buffer-read "/home/heefoo/collider/bass01.wav"))

(sc:defsynth drum ((freq 3000))
  (let* ((env (sc:env-gen.ar (sc:perc 0.001 0.1) :act :free))
         (sig (sc:lpf.ar (sc:white-noise.ar) (* freq env))))
    (sc:out.ar 0 (sc:pan2.ar sig 0 0.2))))


(sc:defsynth sample-bass ((buffer 0) (freq 440) (start 0) (amp 0.5) (out 0))
  (let ((sig (sc:play-buf.ar 2 buffer (*  (/ freq 440) (sc:buf-rate-scale.ir buffer))
                             :start-pos (* start (sc:buf-frames.ir buffer))
                             :act :free)))
    (sc:out.ar out (* amp sig))))


(defvar bass-one '('B4 'B4 'F5))

(setf  *player* (sc:play (sc:synth 'sample-bass :buffer *bass-ogg* :freq 587.33 :amp 3)))

(sc:free *player*)

(defun default-beat (times n)
  (when (> n 0)
    (sc:at-beat 10
                (sc:synth 'sample-bass :buffer *bass-ogg* :freq 587.33 :amp 5)
                (default-beat (+ 1 times) (- n 1)))))

(setf *synth-definition-mode* :load)

(defparameter bass-list '(:B3 :B3 :G4 :G4))

(defun base (beat)
   (loop for x in  bass-list
         for y in '(0 1.5 2 3)
      do (sc:at-beat (+ beat y) (sc:synth 'sample-bass
                                          :buffer *bass-ogg*
                                          :freq (gethash x music-notes)
                                          :amp 1)))
   (sc:clock-add (+ beat 4)  'base (+ beat 4)))

(sc:CLOCK-BPM 120)


; (loop for x in '(:B4 :B4 :F5)
;        collect (gethash x music-notes))

; (sc:stop)


;(base (sc:clock-quant  4))



; (defun base (beat)
;   (sc:at-beat beat (sc:synth 'sample-bass :buffer *bass-ogg* :amp 1))
;   (sc:at-beat (+ beat 1) (sc:synth 'sample-bass
;                                    :buffer *bass-ogg*
;                                    :freq (gethash 'A#4 music-notes)
;                                    :amp 1))
;   (sc:at-beat (+ beat 2) (sc:synth 'sample-bass
;                                    :buffer *bass-ogg*
;                                    :freq (gethash 'B4 music-notes)
;                                    :amp 1))
;   (sc:at-beat (+ beat 3) (sc:synth 'sample-bass
;                                    :buffer *bass-ogg*
;                                    :freq (gethash 'C5 music-notes)
;                                    :amp 1))
;   (sc:clock-add (+ beat 5)  'base (+ beat 5)))
;

;


; (sc:stop)
; #|(defun make-melody (times n &optional (offset 0))
;    (when (> n 0)
;     (sc:at times
;       (let ((next-time (+ times )))
;         (make-melody next-time (- n 1) offset)))))
; (defun make-melody (times n &optional (offset 0))
;
;    (when (> n 0)
;     (sc:at times
;       (let ((next-time (+ times )))
;         (make-melody next-time (- n 1) offset)))))
; |#



