;; https://www.alsa-project.org/alsa-doc/alsa-lib/pcm.html
(library (alsa pcm)
  (export
    ;; TODO snd-strerror belongs in (alsa error).
    snd-strerror

    snd-pcm-open
    snd-pcm-close

    snd-pcm-set-params

    snd-pcm-hw-params-mallocz
    snd-pcm-hw-params-free
    snd-pcm-hw-params-any
    snd-pcm-hw-params
    snd-pcm-hw-params-get-access
    snd-pcm-hw-params-set-access
    snd-pcm-hw-params-get-channels
    snd-pcm-hw-params-set-channels
    snd-pcm-hw-params-get-format
    snd-pcm-hw-params-set-format

    snd-pcm-hw-params-get-rate
    snd-pcm-hw-params-set-rate
    snd-pcm-hw-params-set-rate-near

    snd-pcm-stream
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
    snd-pcm-writei/bv
    snd-pcm-wait
    )
  (import
    (chezscheme)
    (alsa ftypes-util))

  (define load-lib
    (load-shared-object "libasound.so.2"))

  (define-ftype snd-pcm* void*)
  (define-ftype snd-pcm-hw-params* void*)

  (c-enum snd-pcm-stream
    [playback	0]
    capture)

  (c-bitmap snd-open-mode
    [nonblock		#x00001]
    [async		#x00002]
    [abort		#x08000]	; internal
    [no-auto-resample	#x10000]
    [no-auto-channels	#x20000]
    [no-auto-format	#x40000]
    [no-softvol		#x80000])

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
    [snd_pcm_hw_params_get_channels (snd-pcm-hw-params* (* int)) int]
    [snd-pcm-hw-params-set-channels (snd-pcm* snd-pcm-hw-params* int) int]
    [snd_pcm_hw_params_get_format (snd-pcm-hw-params* (* int)) int]
    [snd_pcm_hw_params_set_format (snd-pcm* snd-pcm-hw-params* int) int]

    [snd_pcm_hw_params_get_rate (snd-pcm-hw-params* (* unsigned) (* int)) int]
    [snd_pcm_hw_params_set_rate (snd-pcm* snd-pcm-hw-params* unsigned int) int]
    [snd_pcm_hw_params_set_rate_near (snd-pcm* snd-pcm-hw-params* (* unsigned) (* int)) int]

    ;; included mainly to test snd-pcm-format definitions..
    [snd-pcm-format-name (int) string]

    [snd-pcm-state (snd-pcm*) int]
    [snd-pcm-prepare (snd-pcm*) int]
    [snd-pcm-start (snd-pcm*) int]
    [snd-pcm-drop (snd-pcm*) int]
    [snd-pcm-drain (snd-pcm*) int]
    [snd-pcm-recover (snd-pcm* int int) int]
    [snd-pcm-writei (snd-pcm* void* unsigned-long) long]
    [snd-pcm-wait (snd-pcm* int) int]
    )

  (define snd-pcm-open
    (lambda (name stream mode)
      (alloc ([handle &handle snd-pcm* 1])
        (let ([rc (snd_pcm_open &handle name stream mode)])
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
    (lambda (handle hw-params rate dir)
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

  (define snd-pcm-hw-params-set-rate
    (lambda (handle hw-params rate dir)
      (snd_pcm_hw_params_set_rate handle hw-params rate dir)))

  (define snd-pcm-hw-params-mallocz
    (lambda ()
      (let ([sz (snd-pcm-hw-params-sizeof)])
        (bzero (foreign-alloc sz) sz))))

  (define snd-pcm-hw-params-free foreign-free)

  (define snd-pcm-writei/bv
    (lambda (handle bv frame-count)
      (let ([sz (bytevector-length bv)])
        (alloc ([buf &buf unsigned-8 sz])
          (bv->u8* bv buf sz)
          (snd-pcm-writei handle buf frame-count)))))
  )
