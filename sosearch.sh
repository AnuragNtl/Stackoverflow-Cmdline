#!/bin/bash
function transformResponse()
{
	node transformResponse.js "$1"
}
function sendRequest()
{
	if test $# -eq 1
		then
	curl --compressed -G $1
elif test $# -gt 1
	then
	curl --compressed -G -data-urlencode $1 $2
	fi
}
function showMsg()
{
	printf "Usage:\nsosearch Search_String\n"
}
if test $# -eq 0
	then
	showMsg
	exit
fi
resp=$(curl --compressed -G --data-urlencode "q=$1" 'https://api.stackexchange.com/2.2/search/advanced?order=desc&sort=relevance&site=stackoverflow')
declare -A titles
s1=$(echo $resp | node transformResponse.js "function(data){for(i in data['items']){console.log(data['items'][i].question_id+' '+data['items'][i].title);}}")
IFS="
"
declare -A opts
ct=0
for i in $s1
do
	k=$(echo $i | cut -f 1 -d " ")
	v=$(echo $i | cut -f 2- -d " ")
	titles[$k]=$v
	opts[$v]=$ct
	ct=$((ct+1))
	done
echo ${opts[@]}
select p in ${titles[@]}
do
	d=$(echo $resp | node transformResponse.js "function(data){var d=(data['items'][${opts[$p]}]);console.log(JSON.stringify(d));}")
	quesId=$(echo $d | transformResponse "function(q){console.log(q.question_id);}")
	link=$(echo $d | transformResponse "function(q){console.log(q.link);}")
	title=${titles[$quesId]}
	content=$(sendRequest 'https://api.stackexchange.com/2.2/questions/'$quesId'?order=desc&sort=activity&site=stackoverflow&filter=!9YdnSIaCy')
	content=$(echo $content | transformResponse "function(q){console.log(q.items[0].body);}")
	page=$(echo "<html><body><a href='$link'>$link</a><h1>$title</h1>$content</body></html>")
	echo "$page" | lynx --stdin
	#echo $p ${opts[$p]}
done
