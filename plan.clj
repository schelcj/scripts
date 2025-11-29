#!/usr/bin/env bb

(require '[babashka.fs :as fs])
(require '[babashka.http-client :as http])
(require '[babashka.process :refer [shell]])
(require '[clojure.java.io :as io])

(defn parse-netrc [path]
  (let [lines (->> (slurp path)
                   (clojure.string/split-lines)
                   (map clojure.string/trim)
                   (remove empty?))
        machines
        (loop [ls lines
               m {}]
          (if (empty? ls)
            m
            (let [[l & rest] ls]
              (if (clojure.string/starts-with? l "machine ")
                (let [machine (second (clojure.string/split l #" "))
                      login-line (first rest)
                      password-line (second rest)
                      login (second (clojure.string/split login-line #" "))
                      password (second (clojure.string/split password-line #" "))]
                  (recur (drop 2 rest)
                         (assoc m machine {:login login :password password})))
                (recur rest m)))))]

    machines))

(defn -main
  [& args]
    (let [credentials (parse-netrc (str (System/getenv "HOME") "/.netrc"))
        username (:login (get credentials "plan.cat"))
        password (:password (get credentials "plan.cat"))
        tmp (str (fs/create-temp-file {:prefix ".plan-" :suffix ".txt"}))
        plan (:body (http/get (str "https://plan.cat/~" username)))
        editor (or (System/getenv "EDITOR") "vim")]
    (spit (fs/file tmp) plan)
    (shell [editor tmp] {:inherit true})
    (http/post "https://plan.cat/stdin" {:form-params {"plan" (slurp (io/file tmp))} :basic-auth [username password]})))

(when (= *file* (System/getProperty "babashka.file"))
  (apply -main *command-line-args*))
