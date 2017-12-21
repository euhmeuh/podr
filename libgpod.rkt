#lang racket/base

(provide
  open-ipod
  close-ipod
  ipod-info
  list-artists
  list-albums
  list-tracks
  push-track
  delete-track)

(require racket/list
         ffi/unsafe
         ffi/unsafe/define
         ffi/unsafe/define/conventions)
 
(define-ffi-definer define-gpod (ffi-lib "libgpod")
                    #:make-c-id convention:hyphen->underscore)

(define _GQuark (make-ctype _uint32 #f #f))

(define-cstruct _GError ([domain _GQuark]
                         [code _int]
                         [message _string]))

(define-cstruct _GList ([data _pointer]
                        [next _GList-pointer/null]
                        [previous _GList-pointer/null]))

(define (walk-glist glist)
  (if glist
    (cons (GList-data glist)
          (walk-glist (GList-next glist)))
    '()))

(define _GHashTable-pointer (make-ctype _pointer #f #f))

(define-cstruct _SysInfoIpodProperties
  ([build_id _string]
   [connected_bus _string]
   [max_transfer_speed _int]
   [family_id _int]
   [product_type _string]
   [firewire_guid _string]
   [firewire_version _string]
   [artwork_formats _GList-pointer]
   [photo_formats _GList-pointer]
   [chapter_image_formats _GList-pointer]
   [podcasts_supported _bool]
   [min_itunes_version _string]
   [playlist_folders_supported _bool]
   [serial_number _string]
   [updater_family_id _int]
   [visible_build_id _string]
   [oem_id _int]
   [oem_u _int]
   [db_version _int]
   [shadowdb_version _int]
   [min_build_id _string]
   [language _string]
   [voice_memos_supported _bool]
   [update_method _int]
   [max_fw_blocks _int]
   [fw_part_size _int]
   [auto_reboot_after_firmware_update _bool]
   [volume_format _string]
   [forced_disk_mode _bool]
   [bang_folder _bool]
   [corrupt_data_partition _bool]
   [corrupt_firmware_partition _bool]
   [can_flash_backlight _bool]
   [can_hibernate _bool]
   [came_with_cd _bool]
   [supports_sparse_artwork _bool]
   [max_thumb_file_size _int]
   [ram _int]
   [hotplug_state _int]
   [battery_poll_interval _int]
   [sort_fields_supported _bool]
   [vcard_with_jpeg_supported _bool]
   [max_file_size_in_gb _int]
   [max_tracks _int]
   [games_platform_id _int]
   [games_platform_version _int]
   [rental_clock_bias _int]
   [sqlite_db _bool]))

(define-cstruct _Itdb_Device
  ([mountpoint _string]
   [musicdirs _int]
   [byte_order _uint]
   [sysinfo _GHashTable-pointer]
   [sysinfo_extended _SysInfoIpodProperties-pointer]
   [sysinfo_changed _bool]
   [timezone_shift _int]
   [iphone_sync_context _pointer]
   [iphone_sync_nest_level _int]))

(define _Itdb_iTunesDB_Private-pointer (make-ctype _pointer #f #f))
(define _ItdbUserDataDuplicateFunc (make-ctype _pointer #f #f))
(define _ItdbUserDataDestroyFunc (make-ctype _pointer #f #f))

(define-cstruct _Itdb_iTunesDB
  ([tracks _GList-pointer]
   [playlists _GList-pointer]
   [filename _string]
   [device _Itdb_Device-pointer]
   [version _uint32]
   [id _uint64]
   [tzoffset _int32]
   [reserved_int2 _int32]
   [priv _Itdb_iTunesDB_Private-pointer]
   [reserved2 _pointer]
   [usertype _uint64]
   [userdata _pointer]
   [userdata_duplicate _ItdbUserDataDuplicateFunc]
   [userdata_destroy _ItdbUserDataDestroyFunc]))

(define _Itdb_Chapterdata-pointer (make-ctype _pointer #f #f))
(define _Itdb_Artwork-pointer (make-ctype _pointer #f #f))
(define _Itdb_Track_Private-pointer (make-ctype _pointer #f #f))
(define _time (make-ctype _int32 #f #f))

(define-cstruct _Itdb_Track
  ([itdb _Itdb_iTunesDB-pointer]
   [title _string]
   [ipod_path _string]
   [album _string]
   [artist _string]
   [genre _string]
   [filetype _string]
   [comment _string]
   [category _string]
   [composer _string]
   [grouping _string]
   [description _string]
   [podcasturl _string]
   [podcastrss _string]
   [chapterdata _Itdb_Chapterdata-pointer]
   [subtitle _string]
   [tvshow _string]
   [tvepisode _string]
   [tvnetwork _string]
   [albumartist _string]
   [keywords _string]
   [sort_artist _string]
   [sort_title _string]
   [sort_album _string]
   [sort_albumartist _string]
   [sort_composer _string]
   [sort_tvshow _string]
   [id _uint32]
   [size _uint32]
   [tracklen _int32]
   [cd_nr _int32]
   [cds _int32]
   [track_nr _int32]
   [tracks _int32]
   [bitrate _int32]
   [samplerate _uint16]
   [samplerate_low _uint16]
   [year _int32]
   [volume _int32]
   [soundcheck _uint32]
   [time_added _time]
   [time_modified _time]
   [time_played _time]
   [bookmark_time _uint32]
   [rating _uint32]
   [playcount _uint32]
   [playcount2 _uint32]
   [recent_playcount _uint32]
   [transferred _bool]
   [BPM _int16]
   [app_rating _uint8]
   [type1 _uint8]
   [type2 _uint8]
   [compilation _uint8]
   [starttime _uint32]
   [stoptime _uint32]
   [checked _uint8]
   [dbid _uint64]
   [drm_userid _uint32]
   [visible _uint32]
   [filetype_marker _uint32]
   [artwork_count _uint16]
   [artwork_size _uint32]
   [samplerate2 _float]
   [unk126 _uint16]
   [unk132 _uint32]
   [time_released _time]
   [unk144 _uint16]
   [explicit_flag _uint16]
   [unk148 _uint32]
   [unk152 _uint32]
   [skipcount _uint32]
   [recent_skipcount _uint32]
   [last_skipped _uint32]
   [has_artwork _uint8]
   [skip_when_shuffling _uint8]
   [remember_playback_position _uint8]
   [flag4 _uint8]
   [dbid2 _uint64]
   [lyrics_flag _uint8]
   [movie_flag _uint8]
   [mark_unplayed _uint8]
   [unk179 _uint8]
   [unk180 _uint32]
   [pregap _uint32]
   [samplecount _uint64]
   [unk196 _uint32]
   [postgap _uint32]
   [unk204 _uint32]
   [mediatype _uint32]
   [season_nr _uint32]
   [episode_nr _uint32]
   [unk220 _uint32]
   [unk224 _uint32]
   [unk228 _uint32]
   [unk232 _uint32]
   [unk236 _uint32]
   [unk240 _uint32]
   [unk244 _uint32]
   [gapless_data _uint32]
   [unk252 _uint32]
   [gapless_track_flag _uint16]
   [gapless_album_flag _uint16]
   [obsolete _uint16]
   [artwork _Itdb_Artwork-pointer]
   [mhii_link _uint32]
   [reserved_int1 _int32]
   [reserved_int2 _int32]
   [reserved_int3 _int32]
   [reserved_int4 _int32]
   [reserved_int5 _int32]
   [reserved_int6 _int32]
   [priv _Itdb_Track_Private-pointer]
   [reserved2 _pointer]
   [reserved3 _pointer]
   [reserved4 _pointer]
   [reserved5 _pointer]
   [reserved6 _pointer]
   [usertype _uint64]
   [userdata _pointer]
   [userdata_duplicate _ItdbUserDataDuplicateFunc]
   [userdata_destroy _ItdbUserDataDestroyFunc]))

(define-cstruct _Itdb_SPLPref
  ([liveupdate _uint8]
   [checkrules _uint8]
   [checklimits _uint8]
   [limittype _uint32]
   [limitsort _uint32]
   [limitvalue _uint32]
   [matchcheckedonly _uint8]
   [reserved_int1 _int32]
   [reserved_int2 _int32]
   [reserved1 _pointer]
   [reserved2 _pointer]))

(define-cstruct _Itdb_SPLRules
  ([unk004 _uint32]
   [match_operator _uint32]
   [rules _GList-pointer]
   [reserved_int1 _int32]
   [reserved_int2 _int32]
   [reserved1 _pointer]
   [reserved2 _pointer]))

(define _Itdb_Playlist_Private-pointer (make-ctype _pointer #f #f))

(define-cstruct _Itdb_Playlist
  ([itdb _Itdb_iTunesDB-pointer]
   [name _string]
   [type _uint8]
   [flag1 _uint8]
   [flag2 _uint8]
   [flag3 _uint8]
   [num _int]
   [members _GList-pointer]
   [is_spl _bool]
   [timestamp _time]
   [id _uint64]
   [sortorder _uint32]
   [podcastflag _uint32]
   [splpref _Itdb_SPLPref]
   [splrules _Itdb_SPLRules]
   [reserved100 _pointer]
   [reserved101 _pointer]
   [reserved_int1 _int32]
   [reserved_int2 _int32]
   [priv _Itdb_Playlist_Private-pointer]
   [reserved2 _pointer]
   [usertype _uint64]
   [userdata _pointer]
   [userdata_duplicate _ItdbUserDataDuplicateFunc]
   [userdata_destroy _ItdbUserDataDestroyFunc]))

(define-gpod itdb-parse
             (_fun _string
                   (err : (_ptr io _GError-pointer/null))
                   -> (db : _Itdb_iTunesDB-pointer/null)
                   -> (values db err)))

(define-gpod itdb-write
             (_fun _Itdb_iTunesDB-pointer
                   (err : (_ptr io _GError-pointer/null))
                   -> (result : _bool)
                   -> (values result err)))

(define-gpod itdb-free
             (_fun _Itdb_iTunesDB-pointer -> _void))

(define-gpod itdb-track-new
             (_fun -> _Itdb_Track-pointer))

(define-gpod itdb-track-add
             (_fun _Itdb_iTunesDB-pointer
                   _Itdb_Track-pointer
                   _int32
                   -> _void))

(define-gpod itdb-track-remove
             (_fun _Itdb_Track-pointer -> _void))

(define-gpod itdb-track-unlink
             (_fun _Itdb_Track-pointer -> _void))

(define-gpod itdb-track-free
             (_fun _Itdb_Track-pointer -> _void))

;; get the master playlist from a database
(define-gpod itdb-playlist-mpl
             (_fun _Itdb_iTunesDB-pointer -> _Itdb_Playlist-pointer))

(define-gpod itdb-playlist-add-track
             (_fun _Itdb_Playlist-pointer
                   _Itdb_Track-pointer
                   _int32
                   -> _void))

(define-gpod itdb-playlist-remove-track
             (_fun _Itdb_Playlist-pointer
                   _Itdb_Track-pointer
                   -> _void))

(define-gpod itdb-playlist-contains-track
             (_fun _Itdb_Playlist-pointer
                   _Itdb_Track-pointer
                   -> _bool))

(struct ipod (mount-point name database))

(define (open-ipod mount-point)
  (define-values (db err) (itdb-parse mount-point #f))
  (if (not err)
    (ipod mount-point "Ipod" db)
    (raise-user-error 'open "Unable to open database. ~a" (GError-message err))))

(define (close-ipod)
  (itdb-free (ipod-database ipod)))

(define (ipod-info ipod)
  (SysInfoIpodProperties->list
    (Itdb_Device-sysinfo_extended
      (Itdb_iTunesDB-device (ipod-database ipod)))))

(define (list-artists ipod)
  (order-asc
    (group-by-name
      (filter-map Itdb_Track-artist
                  (get-tracks ipod)))))

(define (list-albums ipod)
  (order-asc
    (group-by-name
      (filter-map Itdb_Track-album
                  (get-tracks ipod)))))

(define (list-tracks ipod)
  (order-asc
    (group-by-name
      (filter-map Itdb_Track-title
                  (get-tracks ipod)))))

(define (push-track ipod track) (format "push-track ~a" track))

(define (delete-track ipod id) (format "delete-track ~a" id))

(define (get-tracks ipod)
  (filter-map (lambda (track)
                (ptr-ref track _Itdb_Track))
              (walk-glist (Itdb_iTunesDB-tracks (ipod-database ipod)))))

(define (order-asc l)
  (sort l string<?))

(define (order-dsc l)
  (sort l string>?))

(define (group-by-name l)
  (remove-duplicates l string=?))
