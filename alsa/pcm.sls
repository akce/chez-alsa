;; https://www.alsa-project.org/alsa-doc/alsa-lib/pcm.html
(library (alsa pcm)
  (export
    ;; TODO snd-strerror belongs in (alsa error).
    snd-strerror

    pollfd pollfd-fd pollfd-events pollfd-revents
    poll-flags
    poll

    snd-pcm-open
    snd-pcm-close

    snd-pcm-set-params

    snd-pcm-hw-params-mallocz
    snd-pcm-hw-params-free
    snd-pcm-hw-params-any
    snd-pcm-hw-params
    snd-pcm-hw-params-get-access
    snd-pcm-hw-params-set-access
    snd-pcm-hw-params-get-buffer-size
    snd-pcm-hw-params-set-buffer-time-near
    snd-pcm-hw-params-get-channels
    snd-pcm-hw-params-set-channels
    snd-pcm-hw-params-get-format
    snd-pcm-hw-params-set-format
    snd-pcm-hw-params-get-period-size
    snd-pcm-hw-params-set-period-time-near

    snd-pcm-hw-params-get-rate
    snd-pcm-hw-params-set-rate
    snd-pcm-hw-params-set-rate-near

    snd-pcm-sw-params-mallocz snd-pcm-sw-params-free
    snd-pcm-sw-params
    snd-pcm-sw-params-current
    snd-pcm-sw-params-get-avail-min
    snd-pcm-sw-params-set-avail-min
    snd-pcm-sw-params-get-period-event
    snd-pcm-sw-params-set-period-event
    snd-pcm-sw-params-get-start-threshold
    snd-pcm-sw-params-set-start-threshold

    snd-pcm-stream-t
    snd-open-mode
    snd-pcm-access
    snd-pcm-format

    snd-pcm-format-name

    snd-pcm-state
    snd-pcm-state-t
    snd-pcm-prepare
    snd-pcm-start
    snd-pcm-drop
    snd-pcm-drain
    snd-pcm-recover
    snd-pcm-writei
    #;snd-pcm-writei/bv
    snd-pcm-wait
    snd-pcm-pause

    snd-pcm-poll-descriptors-count
    snd-pcm-poll-descriptors
    snd-pcm-poll-descriptors-revents
    snd-pcm-poll-descriptors-revents/flags
    snd-pcm-avail-update
    snd-pcm-poll-descriptors-alloc
    snd-pcm-poll-descriptors-free
    snd-pcm-stream
    snd-pcm-type
    )
  (import
    (chezscheme)
    (alsa ftypes-util))

  (define load-lib
    (load-shared-object "libasound.so.2"))

  (define-ftype snd-pcm* void*)
  (define-ftype snd-pcm-hw-params* void*)
  (define-ftype snd-pcm-sw-params* void*)
  (define-ftype snd-pcm-frames-t long)
  (define-ftype snd-pcm-uframes-t unsigned-long)

  (c-enum snd-pcm-type-t
    [hw		0]
    hooks
    multi
    file
    null
    shm
    inet
    copy
    linear
    alaw
    mulaw
    adpcm
    rate
    route
    plug
    share
    meter
    mix
    droute
    lbserver
    linear-float
    ladspa
    dmix
    jack
    dsnoop
    dshare
    iec958
    softvol
    ioplug
    extplug
    mmap-emul)

  (c-enum snd-pcm-stream-t
    [playback	0]
    capture)

  (c-bitmap snd-open-mode
    [nonblock		0]	; #x00001
    [async		1]	; #x00002
    [abort		15]	; #x08000 (internal)
    [no-auto-resample	16]	; #x10000
    [no-auto-channels	17]	; #x20000
    [no-auto-format	18]	; #x40000
    [no-softvol		19]	; #x80000
    )

  (c-enum snd-pcm-access
    [mmap-interleaved	0]
    mmap-noninterleaved
    mmap-complex
    rw-interleaved
    rw-noninterleaved)

  (c-enum snd-pcm-format
    [unknown	-1]
    [s8		0]
    u8
    s16-le
    s16-be
    u16-le
    u16-be
    s24-le
    s24-be
    u24-le
    u24-be
    s32-le
    s32-be
    u32-le
    u32-be
    float-le
    float-be
    float64-le
    float64-be
    iec958-subframe-le
    iec958-subframe-be
    mu-law
    a-law
    ima-adpcm
    mpeg
    gsm
    s20-le
    s20-be
    u20-le
    u20-be
    [special	31]
    [s24-3le	32]
    s24-3be
    u24-3le
    u24-3be
    s20-3le
    s20-3be
    u20-3le
    u20-3be
    s18-3le
    s18-3be
    u18-3le
    u18-3be
    g723-24
    g723-24-1b
    g723-40
    g723-40-1b
    dsd-u8
    dsd-u16-le
    dsd-u32-le
    dsd-u16-be
    dsd-u32-be)

  (c-enum snd-pcm-state-t
    [open	0]
    setup
    prepared
    running
    xrun
    draining
    paused
    suspended
    disconnected)

  ;; See poll(2). Here for convenience but really belongs in a separate os/poll library.
  (define-ftype pollfd
    (struct
      [fd	int]
      [events	short]
      [revents	short]))

  (define pollfd-fd
    (lambda (p idx)
      (ftype-ref pollfd (fd) p idx)))

  (define pollfd-events
    (lambda (p idx)
      (ftype-ref pollfd (events) p idx)))

  (define pollfd-revents
    (lambda (p idx)
      (ftype-ref pollfd (revents) p idx)))

  (c-bitmap poll-flags
    [in		0]
    [pri	1]
    [out	2]
    [err	3]
    [hup	4]
    [nval	5]
    ;; there are more but these will do for now.
    )

  (c-function
    [poll ((* pollfd) unsigned-long int) int])

  (c-function
    [snd-strerror (int) string]

    [snd_pcm_open ((* snd-pcm*) string int int) int]
    [snd-pcm-close (snd-pcm*) int]

    [snd-pcm-set-params (snd-pcm* int int unsigned unsigned int unsigned) int]
    ;; https://www.alsa-project.org/alsa-doc/alsa-lib/group___p_c_m___h_w___params.html
    [snd-pcm-hw-params-sizeof () size_t]
    [snd-pcm-hw-params-any (snd-pcm* snd-pcm-hw-params*) int]
    [snd-pcm-hw-params (snd-pcm* snd-pcm-hw-params*) int]
    [snd_pcm_hw_params_get_access (snd-pcm-hw-params* (* int)) int]
    [snd_pcm_hw_params_set_access (snd-pcm* snd-pcm-hw-params* int) int]
    [snd_pcm_hw_params_get_buffer_size (snd-pcm-hw-params* (* snd-pcm-uframes-t)) int]
    [snd_pcm_hw_params_set_buffer_time_near (snd-pcm* snd-pcm-hw-params* (* unsigned) (* int)) int]
    [snd_pcm_hw_params_get_channels (snd-pcm-hw-params* (* int)) int]
    [snd-pcm-hw-params-set-channels (snd-pcm* snd-pcm-hw-params* int) int]
    [snd_pcm_hw_params_get_format (snd-pcm-hw-params* (* int)) int]
    [snd_pcm_hw_params_set_format (snd-pcm* snd-pcm-hw-params* int) int]

    [snd_pcm_hw_params_get_period_size (snd-pcm-hw-params* (* snd-pcm-uframes-t) (* int)) int]
    [snd_pcm_hw_params_set_period_time_near (snd-pcm* snd-pcm-hw-params* (* unsigned) (* int)) int]
    [snd_pcm_hw_params_get_rate (snd-pcm-hw-params* (* unsigned) (* int)) int]
    [snd_pcm_hw_params_set_rate (snd-pcm* snd-pcm-hw-params* unsigned int) int]
    [snd_pcm_hw_params_set_rate_near (snd-pcm* snd-pcm-hw-params* (* unsigned) (* int)) int]

    ;; https://www.alsa-project.org/alsa-doc/alsa-lib/group___p_c_m___s_w___params.html
    [snd-pcm-sw-params-sizeof () size_t]
    [snd-pcm-sw-params (snd-pcm* snd-pcm-sw-params*) int]
    [snd-pcm-sw-params-current (snd-pcm* snd-pcm-sw-params*) int]
    [snd_pcm_sw_params_get_avail_min (snd-pcm-sw-params* (* snd-pcm-uframes-t)) int]
    [snd-pcm-sw-params-set-avail-min (snd-pcm* snd-pcm-sw-params* snd-pcm-uframes-t) int]
    [snd_pcm_sw_params_get_period_event (snd-pcm-sw-params* (* boolean)) int]
    [snd-pcm-sw-params-set-period-event (snd-pcm* snd-pcm-sw-params* boolean) int]
    [snd_pcm_sw_params_get_start_threshold (snd-pcm-sw-params* (* snd-pcm-uframes-t)) int]
    [snd-pcm-sw-params-set-start-threshold (snd-pcm* snd-pcm-sw-params* snd-pcm-uframes-t) int]

    ;; included mainly to test snd-pcm-format definitions..
    [snd-pcm-format-name (int) string]

    [snd_pcm_state (snd-pcm*) int]
    [snd-pcm-prepare (snd-pcm*) int]
    [snd-pcm-start (snd-pcm*) int]
    [snd-pcm-drop (snd-pcm*) int]
    [snd-pcm-drain (snd-pcm*) int]
    [snd-pcm-recover (snd-pcm* int int) int]
    [snd-pcm-writei (snd-pcm* (* unsigned-8) unsigned-long) long]
    [snd-pcm-wait (snd-pcm* int) int]
    [snd-pcm-pause (snd-pcm* boolean) int]

    [snd-pcm-poll-descriptors-count (snd-pcm*) int]
    [snd-pcm-poll-descriptors (snd-pcm* (* pollfd) unsigned) int]
    [snd_pcm_poll_descriptors_revents (snd-pcm* (* pollfd) unsigned (* unsigned-short)) int]

    [snd-pcm-avail-update (snd-pcm*) snd-pcm-frames-t]

    [snd_pcm_stream (snd-pcm*) int]
    [snd_pcm_type (snd-pcm*) int]
    )

  (define snd-pcm-open
    (lambda (name stream mode)
      (alloc ([handle &handle snd-pcm* 1])
        (let ([rc (snd_pcm_open &handle name (snd-pcm-stream-t stream) (if (number? mode) mode (snd-open-mode mode)))])
          (cond
            [(< rc 0)
             (error #f (snd-strerror rc) rc)]
            [else
              (ftype-ref snd-pcm* () &handle 0)])))))

  (define snd-pcm-hw-params-get-access
    (lambda (hw-params)
      (alloc ([access &access int 1])
        (let ([rc (snd_pcm_hw_params_get_access hw-params &access)])
          (snd-pcm-access (ftype-ref int () &access 0))))))

  (define snd-pcm-hw-params-set-access
    (lambda (handle hw-params access)
      (snd_pcm_hw_params_set_access handle hw-params (snd-pcm-access access))))

  (define snd-pcm-hw-params-get-buffer-size
    (lambda (hw-params)
      (alloc ([val &val snd-pcm-uframes-t 1])
        (let ([rc (snd_pcm_hw_params_get_buffer_size hw-params &val)])
          (ftype-ref snd-pcm-uframes-t () &val 0)))))

  (define snd-pcm-hw-params-set-buffer-time-near
    (lambda (handle hw-params val)
      (alloc ([val* &val unsigned 1]
              [dir* &dir int 1])
        (ftype-set! unsigned () &val val)
        (ftype-set! int () &dir 0)	; always request exact for now.
        (let ([rc (snd_pcm_hw_params_set_buffer_time_near handle hw-params &val &dir)])
          (cond
            [(< rc 0)
             (error #f (snd-strerror rc) rc)]
            [else
              ;; rate is in Hz.
              ;; dir: 0 == hw able to set requested rate, 1 == <, 2 == >.
              ;; I've yet to see any sample code use 'dir' yet. It's a candidate for ignoring.
              #;(cons (ftype-ref unsigned () &val 0) (ftype-ref int () &dir 0))
              (ftype-ref unsigned () &val)])))))

  (define snd-pcm-hw-params-get-channels
    (lambda (hw-params)
      (alloc ([channels &channels int 1])
        (let ([rc (snd_pcm_hw_params_get_channels hw-params &channels)])
          (ftype-ref int () &channels 0)))))

  (define snd-pcm-hw-params-get-format
    (lambda (hw-params)
      (alloc ([format &format int 1])
        (let ([rc (snd_pcm_hw_params_get_format hw-params &format)])
          (snd-pcm-format (ftype-ref int () &format 0))))))

  (define snd-pcm-hw-params-set-format
    (lambda (handle hw-params format)
      (snd_pcm_hw_params_set_format handle hw-params (snd-pcm-format format))))

  (define snd-pcm-hw-params-get-period-size
    (lambda (hw-params)
      (alloc ([val &val snd-pcm-uframes-t 1]
              [dir* &dir int 1])
        (ftype-set! int () &dir 0)	; request exact? docs don't say if this is used.
        (let ([rc (snd_pcm_hw_params_get_period_size hw-params &val &dir)])
          (ftype-ref snd-pcm-uframes-t () &val 0)))))

  (define snd-pcm-hw-params-set-period-time-near
    (lambda (handle hw-params val)
      (alloc ([val* &val unsigned 1]
              [dir* &dir int 1])
        (ftype-set! unsigned () &val val)
        (ftype-set! int () &dir 0)	; request exact? docs don't say if this is used.
        (let ([rc (snd_pcm_hw_params_set_period_time_near handle hw-params &val &dir)])
          (cond
            [(< rc 0)
             (error #f (snd-strerror rc) rc)]
            [else
              ;; rate is in Hz.
              ;; dir: 0 == hw able to set requested rate, 1 == <, 2 == >.
              ;; I've yet to see any sample code use 'dir' yet. It's a candidate for ignoring.
              #;(cons (ftype-ref unsigned () &val 0) (ftype-ref int () &dir 0))
              (ftype-ref unsigned () &val)])))))

  (define snd-pcm-hw-params-get-rate
    (lambda (hw-params)
      (alloc ([rate &rate unsigned 1]
              [dir &dir int 1])
        (ftype-set! int () &dir 0)	; just in case.
        (let ([rc (snd_pcm_hw_params_get_rate hw-params &rate &dir)])
          (cond
            [(< rc 0)
             (error #f (snd-strerror rc) rc)]
            [else
              ;; dir: 0 == hw set to requested rate, 1 == <, 2 == >.
              (cons (ftype-ref unsigned () &rate 0) (ftype-ref int () &dir 0))])))))

  (define snd-pcm-hw-params-set-rate-near
    (lambda (handle hw-params rate)
      (alloc ([rate* &rate unsigned 1]
              [dir* &dir int 1])
        (ftype-set! unsigned () &rate rate)
        (ftype-set! int () &dir 0)	; request exact.
        (let ([rc (snd_pcm_hw_params_set_rate_near handle hw-params &rate &dir)])
          (cond
            [(< rc 0)
             (error #f (snd-strerror rc) rc)]
            [else
              ;; rate is in Hz.
              ;; dir: 0 == hw able to set requested rate, 1 == <, 2 == >.
              ;; I've yet to see any sample code use 'dir' yet. It's a candidate for ignoring.
              (cons (ftype-ref unsigned () &rate 0) (ftype-ref int () &dir 0))])))))

  (define snd-pcm-state
    (lambda (handle)
      (snd-pcm-state-t (snd_pcm_state handle))))

  (define snd-pcm-hw-params-set-rate
    (lambda (handle hw-params rate dir)
      (snd_pcm_hw_params_set_rate handle hw-params rate dir)))

  (define snd-pcm-hw-params-mallocz
    (lambda ()
      (let ([sz (snd-pcm-hw-params-sizeof)])
        (bzero (foreign-alloc sz) sz))))

  (define snd-pcm-hw-params-free foreign-free)

  (define snd-pcm-sw-params-mallocz
    (lambda ()
      (let ([sz (snd-pcm-sw-params-sizeof)])
        (bzero (foreign-alloc sz) sz))))

  (define snd-pcm-sw-params-free foreign-free)

  (define snd-pcm-sw-params-get-avail-min
    (lambda (sw-params)
      (alloc ([val &val snd-pcm-uframes-t 1])
        (let ([rc (snd_pcm_sw_params_get_avail_min sw-params &val)])
          (ftype-ref snd-pcm-uframes-t () &val 0)))))

  (define snd-pcm-sw-params-get-period-event
    (lambda (sw-params)
      (alloc ([val &val boolean 1])
        (let ([rc (snd_pcm_sw_params_get_period_event sw-params &val)])
          (ftype-ref boolean () &val)))))

  (define snd-pcm-sw-params-get-start-threshold
    (lambda (sw-params)
      (alloc ([val &val snd-pcm-uframes-t 1])
        (let ([rc (snd_pcm_sw_params_get_start_threshold sw-params &val)])
          (ftype-ref snd-pcm-uframes-t () &val 0)))))

  ;; This is a convenience function, but slightly inefficient.
  (define snd-pcm-poll-descriptors-revents
    (lambda (handle pfd count)
      (alloc ([rev &rev unsigned-short 1])
        (snd_pcm_poll_descriptors_revents handle pfd count &rev)
        #;(poll-flags (ftype-ref unsigned-short () &rev))
        (ftype-ref unsigned-short () &rev))))

  ;; This is a convenience function, but slightly inefficient.
  (define snd-pcm-poll-descriptors-revents/flags
    (lambda (handle pfd count)
      (alloc ([rev &rev unsigned-short 1])
        (snd_pcm_poll_descriptors_revents handle pfd count &rev)
        (poll-flags (ftype-ref unsigned-short () &rev)))))

  (define snd-pcm-poll-descriptors-alloc
    (lambda (handle count)
      (make-ftype-pointer pollfd
        (foreign-alloc (* count (ftype-sizeof pollfd))))))

  (define snd-pcm-poll-descriptors-free
    (lambda (ptr)
      (foreign-free (ftype-pointer-address ptr))
      #;(unlock-object ptr)))

  ;; Unused for now. The u8 bytevector/frame-count disconnect makes this function a little awkward.
  #;(define snd-pcm-writei/bv
    (lambda (handle bv frame-count)
      (let ([sz (bytevector-length bv)])
        (alloc ([buf &buf unsigned-8 sz])
          (bv->u8* bv buf sz)
          (snd-pcm-writei handle buf frame-count)))))

    (define snd-pcm-stream
      (lambda (handle)
        (snd-pcm-stream-t (snd_pcm_stream handle))))

    (define snd-pcm-type
      (lambda (handle)
        (snd-pcm-type-t (snd_pcm_type handle))))
  )
