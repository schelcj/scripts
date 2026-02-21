#!/usr/bin/env bb

(:require '[cheshire.core :as json])

(def export "/home/schelcj/tmp/export.json")

;; (with-open [r (io/reader export)]
;;   (println (->> (json/parse-stream r true)
;;        :roas
;;        (some #(when (= (:prefix %) "1.0.0.0/24"))))))

;; (with-open [r (io/reader export)]
;;   (println (some #(= (:prefix %) "1.0.0.0/24")
;;     (json/parsed-seq r true))))

(with-open [r (io/reader export)]
  (println (reduce (fn [_ x]
            (when (and (map? x)
                       (= (:prefix x) "1.0.0.0/24"))
              (reduced x)))
          nil
          (json/parsed-seq r true))))
