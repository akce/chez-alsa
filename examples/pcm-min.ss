#! /usr/bin/chez-scheme --script

;; Translation of test/pcm_min.c:
;; https://www.alsa-project.org/alsa-doc/alsa-lib/_2test_2pcm_min_8c-example.html

(import
  (rnrs)
  (only (chezscheme) random)
  (alsa pcm))

(define device "default")
(define bufsize (* 16 1024))

(define make-random-bytevector
  (lambda (size)
    (do ([bv (make-bytevector size)]
         [i 0 (+ i 1)])
      ((= i size) bv)
      (bytevector-u8-set! bv i (random 255)))))

(define main
  (lambda ()
    (let ([handle (snd-pcm-open device 'playback 0)])
      (snd-pcm-set-params handle (snd-pcm-format 'u8) (snd-pcm-access 'rw-interleaved) 1 48000 1 500000)
      (do ([i 0 (+ i 1)])
        ((= i 16))
        ;; TODO check for underruns.
        (snd-pcm-writei/bv handle (make-random-bytevector bufsize)))
      (snd-pcm-drain handle)
      (snd-pcm-close handle))))

(main)
