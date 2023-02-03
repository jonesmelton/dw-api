(def submit `
  on submit halt the event
then set input to the value of #command-bar
then js(input) window.mudc.postMessage(input) end
then set the value of #command-bar to ''
`)

(defn index [request]
  [:div {:id "mudclient"}
   [:div {:id "main-window"}
    [:pre]]
   [:form {:id "input-bar" :_ submit}
    [:input {:type "text" :name "command"
             :placeholder "send to mud"
             :id "command-bar"}]
    [:button {} "send"]]])
