
(in-package #:music-synthesis)
;(ql:quickload :music-synthesis)
; (print sc:*sc-synth-program*)
(setf sc:*s* (sc:make-external-server "localhost" :port 48800))

(sc:server-boot sc:*s*)

(sc:jack-connect)

(defvar *synth*)

(defvar *sample-files*  "/usr/share/lmms/samples")

(defvar *bongo-sequence*    (map 'list #'(lambda  (x)(sc:buffer-read (format nil "/home/heefoo/lmms/raw/bongos/~a.wav" x))) (alexandria:iota 8 :start 1)))

(defvar *wav-bass* (sc:buffer-read "/home/heefoo/lmms/raw/bass01.wav"))

(defvar *guira-file* (sc:buffer-read "/home/heefoo/lmms/raw/guira_short.wav"))

(defvar *dance-monkey* (sc:buffer-cue-soundfile  "/home/heefoo/lmms/raw/Dance Monkey - Tones And I (Cover by Alexander Stewart) (152kbit_Opus).wav"))

(setf *dance-monkey* (sc:buffer-cue-soundfile  "/home/heefoo/lmms/raw/Dance Monkey - Tones And I (Cover by Alexander Stewart) (152kbit_Opus).wav"))

(sc:defsynth dancing-monkey  ()
    (sc:out.ar 0 (sc:disk-in.ar 2 *dance-monkey*)))


(sc:defsynth drum ((freq 3000))
  (let* ((env (sc:env-gen.ar (sc:perc 0.001 0.1) :act :free))
         (sig (sc:lpf.ar (sc:white-noise.ar) (* freq env))))
    (sc:out.ar 0 (sc:pan2.ar sig 0 0.2))))


(sc:defsynth sample-note ((buffer 0) (freq 440) (start 0) (amp 0.5) (out 0))
  (let ((sig (sc:play-buf.ar 2 buffer (*  (/ freq 440) (sc:buf-rate-scale.ir buffer))
                             :start-pos (* start (sc:buf-frames.ir buffer))
                             :act :free)))
    (sc:out.ar out (* amp sig))))


(defvar bass-one '('B4 'B4 'F5))

(defun default-beat (times n)
  (when (> n 0)
    (sc:at-beat 10
                (sc:synth 'sample-note :buffer *wav-bass* :freq 587.33 :amp 5)
                (default-beat (+ 1 times) (- n 1)))))

(setf *synth-definition-mode* :load)

(defparameter bass-list (map 'list #'(lambda (x) (gethash x music-notes))  '(:A3 :A3 :E4 :E4)))

; (defun bachata-loop (beat)
;    (loop for x in  bass-list
;          for y in '(0 1.5 2 3 4 5.5 6 7)
;          for z in '(0 1 2 3)
;       do (sc:at-beat (+ beat y) (sc:synth 'sample-note
;                                           :buffer *wav-bass*
;                                           :freq x
;                                           :amp 1))
;          (sc:at-beat (+ beat z) (sc:synth 'sample-note
;                                           :buffer *guira-file*
;                                           :freq 440
;                                           :amp 0.4))
;          (sc:at-beat (+ beat z 0.5) (sc:synth 'sample-note
;                                               :buffer *guira-file*
;                                               :freq 440
;                                               :amp 0.4)))
;   (sc:clock-add (+ beat 4)  'bachata-loop (+ beat 4)))
;
(defvar the-switch '(1))
; (setf the-switch '())


(defun bachata-loop (beat x)
  (loop for x in  bass-list
        for y in '(0 1.5 2 3)
        for z in '(0 1 2 3)
     do (sc:at-beat (+ beat y) (sc:synth 'sample-note
                                         :buffer *wav-bass*
                                         :freq x
                                         :amp 0.4))
        (sc:at-beat (+ beat z) (sc:synth 'sample-note
                                         :buffer *guira-file*
                                         :freq 440
                                         :amp 0.4))
        (sc:at-beat (+ beat z 0.5) (sc:synth 'sample-note
                                             :buffer *guira-file*
                                             :freq 440
                                             :amp 0.4)))
 (when (> x 0)
  (sc:callback (+ beat 4)  #'bachata-loop (+ beat 4) (- x 1))))



(defun play-bongos (beat)
  (loop for i in (alexandria:iota 8)
     do (sc:at-beat (+ i beat ) (sc:synth 'sample-note :buffer (nth i *bongo-sequence*) :amp 0.4))))


;(play-bongos (sc:clock-quant  0))
(sc:CLOCK-BPM 98)


(defvar *player*)

(setf  *player* (sc:play (sc:disk-in.ar 2  *dance-monkey*)))


(setf  *player* (sc:play (sc:synth  'dancing-monkey)))

(defun make-mix ()
  (sc:at-beat (sc:clock-quant  4) (sc:play (sc:disk-in.ar 2  *dance-monkey*)))
  (bachata-loop (sc:clock-quant  4) 8))


;(make-mix)

;  (setf  *player* (sc:play (sc:synth 'sample :buffer *guira-file*))))
(defun reset! ()
       (sc:free *player*)
       (sc:stop)
       (setf *dance-monkey* (sc:buffer-cue-soundfile  "/home/heefoo/lmms/raw/Dance Monkey - Tones And I (Cover by Alexander Stewart) (152kbit_Opus).wav")))
; (reset!)
; (loop for x in '(:B4 :B4 :F5)
;        collect (gethash x music-notes))

; (sc:stop)


;(bachata-loop (sc:clock-quant  4) 4)
;(bachata-loop-2 (sc:clock-quant  8))



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


