#!/usr/bin/env bb

;; Example query results
;; $ echo '!JRADB' | nc nrtm.radb.net 43
;; A526
;; {
;;     "RADB": {
;;         "source_type": "regular",
;;         "authoritative": false,
;;         "object_class_filter": null,
;;         "rpki_rov_filter": false,
;;         "scopefilter_enabled": false,
;;         "route_preference": null,
;;         "local_journal_kept": true,
;;         "serial_oldest_journal": 4554272,
;;         "serial_newest_journal": 4632467,
;;         "serial_last_export": null,
;;         "serial_newest_mirror": 4632467,
;;         "last_update": "2026-02-21T13:59:07.056912+00:00",
;;         "synchronised_serials": true
;;     }
;; }
;; C

(require '[babashka.cli :as cli])
(require '[cheshire.core :as json])
(import '[java.net Socket])

(def cli-spec 
    { :spec
        { :primary {
                :desc "Primary NRTM hostname"
                :default "nrtm.radb.net"
                :required true}
        :mirror {
                :desc "Mirror NRTM hostname"
                :default "whois.radb.net"
                :required true}
        :source {
                :desc "Source database to compare (e.g. RADB)"
                :default "RADB"
                :required true}
        :drift {
                :desc "How far can the serials of the source and mirror drift"
                :default 30
                :required true
                }}})

(defn show-help
  [spec]
  (cli/format-opts (merge spec {:order (vec (keys (:spec spec)))})))

(def nrtm "nrtm.radb.net")
(def whois "whois.radb.net")
(def db "RADB")

(defn query-whois!
  "Using the `!J<SOURCE>` query get the current NRTM status."
  [host source]
    (with-open [sock (Socket. host 43)
        writer (io/writer sock)
        reader (io/reader sock)]
        (.write writer (str "!J" source "\r\n"))
        (.flush writer)
        (doall (line-seq reader))))

(defn get-nrtm-status
  "Parse the response from whois into a json map."
  [host source]
  (let [response (query-whois! host source)
        result (drop-last 1 (drop 1 response))
        status (json/parse-string (apply str result) true)]
  ((keyword source) status)))

(defn get-current-serial
  ""
  [host source]
  (let [status (get-nrtm-status host source)]
    (:serial_newest_mirror status)))

;; (println (get-current-serial nrtm db))
;; (println (get-current-serial whois db))

(defn -main
  [args]
  (let [opts (cli/parse-opts args cli-spec)]
    (if (or (:help opts) (:h opts))
      (println (show-help cli-spec))
      (println opts))))

(-main *command-line-args*)
