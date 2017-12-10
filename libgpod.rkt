#lang racket/base

(provide
  find-mount-points
  open-ipod
  list-artists
  list-albums
  list-tracks)

(require ffi/unsafe
         ffi/unsafe/define
         ffi/unsafe/define/conventions)
 
(define-ffi-definer define-gpod (ffi-lib "libgpod")
                    #:make-c-id convention:hyphen->underscore)

(define _GQuark (make-ctype _uint32 #f #f))

(define-cstruct _GError ([domain _GQuark]
                         [code _int]
                         [message _string]))

(define-cstruct _GList ([data _pointer]
                        [next _GList-pointer]
                        [previous _GList-pointer]))

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

(define-gpod itdb-parse
             (_fun _string
                   (err : (_ptr io _GError-pointer/null))
                   -> (db : _Itdb_iTunesDB-pointer/null)
                   -> (values db err)))

(struct ipod (mount-point name database))

(define (find-mount-points)
  (list "/dev/ipod"))

(define (open-ipod mount-point)
  (define-values (db err) (itdb-parse mount-point #f))
  (if (not err)
    (ipod mount-point "Ipod" db)
    (error 'open "Unable to open database. ~a" (GError-message err))))

(define (list-artists ipod)
  (list))

(define (list-albums ipod)
  (list))

(define (list-tracks ipod)
  (Itdb_iTunesDB-tracks (ipod-database ipod)))
