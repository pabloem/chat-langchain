# A script that downloads all SO questions for a given tag
# Dependencies:
#   - pup - a Golang utility to parse HTML with the command line
#   - jq  - a utility to parse JSON with the command line
#   - curl - the well known unix tool curl

URL="https://api.stackexchange.com/2.3/questions?pagesize=100&tagged=apache-beam&site=stackoverflow"

function getQuestions() {
  PAGE=0
  while true; do
    PAGE=$((PAGE + 1))
      echo "Fetching page ${PAGE}"
      curl --compressed "${URL}&page=${PAGE}" > tmp_response.json
      jq -r ".items[].link" tmp_response.json >> question_links.txt
      HAS_MORE=`jq ".has_more" tmp_response.json`
      if [[ "$HAS_MORE" != "true" ]]; then
        echo "Done after ${PAGE} pages. Has more is ${HAS_MORE}"
        break
      fi
  done
}

function getTextFromQuestions() {
  FILES=0
  mkdir stackoverflow
  file="question_links.txt"
  while read line; do
    FILES=$((FILES + 1))
    echo "curling ${line} - file # ${FILE}"
    filename=`echo ${line} | cut -d "/" -f 6`
    curl "${line}" | pup "#question-header,#mainbar text{}" >> stackoverflow/${filename}-q-${FILES}
    sleep 5
  done < "$file"
}

echo "Getting questions"
getQuestions

echo "Got `wc question_links.txt` questions. Now fetching text..."
getTextFromQuestions
