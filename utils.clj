(ns utils
  "Various utility functions."
  (:require [clojure.string :as str]))

(defn parse-netrc [path]
  (let [lines (->> (slurp path)
                   (str/split-lines)
                   (map str/trim)
                   (remove empty?))
        machines
        (loop [ls lines
               m {}]
          (if (empty? ls)
            m
            (let [[l & rest] ls]
              (if (str/starts-with? l "machine ")
                (let [machine (second (str/split l #" "))
                      login-line (first rest)
                      password-line (second rest)
                      login (second (str/split login-line #" "))
                      password (second (str/split password-line #" "))]
                  (recur (drop 2 rest)
                         (assoc m machine {:login login :password password})))
                (recur rest m)))))]

    machines))

