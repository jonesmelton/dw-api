(import suresql :as sure)
(import joy)

(defn handle-search [req]
  (def qfns (sure/defqueries "src/sql/fly.sql"
                             {:connection (dyn :db/connection)}))
  (let [q (get-in req [:query-string :q] "")
        area (get-in req [:query-string :area-filter] "")
        finder (qfns :find-in-all)
        fts (qfns :find-by-any)]

    # fts tokenizer uses trigrams, fall back to
    # normal LIKE query if not enouch chars
    (var npcs (if (>= (length q) 3)
                (fts {:term q})
                (finder {:term q})))

    (def area-counts (as-> npcs _
                           (group-by |($ :area) _)
                           (tabseq [[k v] :pairs _] k (length v))))

    (when (not= area "")
      (set npcs (filter |(= area ($ :area)) npcs)))

    (def _loc-toggle `
         on click remove .selected from .npc-area
             then toggle .selected on me
             then set #area-filter @value to my @loc
             then trigger sendSearch on #search-input`)

    (defn area-count [name display-name]
      (def class (if (= area name)
                   "npc-area selected"
                   "npc-area"))

      [:div {:class class
             :loc name
             :_ _loc-toggle}
       [:p display-name]
       [:p (get area-counts name 0)]])

    (defn areas []
      [:div {:id "location-counts"}
       [:input {:id "area-filter" :type "hidden" :name "area-filter" :value area}]
       (area-count "am" "Ankh-Morpork")
       (area-count "bp" "Bes Pelargic")
       (area-count "djb" "Djelibeybi")
       (area-count "ephebe" "Ephebe")
       (area-count "genua" "Genua")
       (area-count "ramtops" "Ramtops")
       (area-count "sto plains" "Sto Plains")])

    [:div {:id "npc-search-results"}
     [:div {:id "npc-locations"} (areas)]
     [:table {:id "npc-table"}
      [:thead [:tr [:th "short name"] [:th "area"] [:th "location"] [:th "full name"]]]
      (map (fn [npc] [:tr
                      [:td (joy/raw (npc :short_name))]
                      [:td (npc :area)]
                      [:td (joy/raw (npc :location))]
                      [:td (joy/raw (npc :full_name))]]) npcs)]]))

(defn search-bar [request]
  [:div {:id "page-container"}
   [:div {:id "search-container"}
    [:div {:class "search-bar"}
     [:img {:class "htmx-indicator" :id "load-indicator"
            :height "40px" :width "40px"
            :src "/images/puff.svg"}]
     [:label {:for "q"} "flyable npc search"]
     [:input {:type "text" :name "q"
              :hx-get "/npcs/fly"
              :id "search-input"
              :hx-include "[name='area-filter']"
              :hx-trigger "keyup delay:80ms changed, sendSearch"
              :hx-select "#npc-search-results"
              :hx-target "#npc-search-results"
              :hx-swap "outerHTML"
              :placeholder "npc"}]]]
   (handle-search nil)])
