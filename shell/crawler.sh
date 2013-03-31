#!/bin/sh

DATA_PATH=/exp/discovery/caofx/recommend_20111118
CODE_PATH=/global/exec/caofx/silmaril

# 抓取餐馆
$CODE_PATH/bin/odis.sh -wn 32 outfox.silmaril.crawler.RestCrawler -w $DATA_PATH -n nb064:6636 -t 7
if [[ $? -ne 0 ]]; then exit 1; fi

$CODE_PATH/bin/odis.sh -wn 32 outfox.silmaril.crawler.RestMerger -w $DATA_PATH -i $DATA_PATH/crawler/rest_crawl/restaurant
if [[ $? -ne 0 ]]; then exit 1; fi

$CODE_PATH/bin/odis.sh -wn 4 outfox.silmaril.crawler.RestStateMerger -w $DATA_PATH -i $DATA_PATH/crawler/rest_crawl/rest_state
if [[ $? -ne 0 ]]; then exit 1; fi

# 发现新餐馆
$CODE_PATH/bin/odis.sh -wn 32 outfox.silmaril.crawler.RestFinderFromPage -w $DATA_PATH
if [[ $? -ne 0 ]]; then exit 1; fi

$CODE_PATH/bin/odis.sh -wn 4 outfox.silmaril.crawler.RestStateMerger -w $DATA_PATH -i $DATA_PATH/crawler/rest_find
if [[ $? -ne 0 ]]; then exit 1; fi

# 再次抓取餐馆
$CODE_PATH/bin/odis.sh -wn 32 outfox.silmaril.crawler.RestCrawler -w $DATA_PATH -n nb064:6636 -t 7
if [[ $? -ne 0 ]]; then exit 1; fi

$CODE_PATH/bin/odis.sh -wn 32 outfox.silmaril.crawler.RestMerger -w $DATA_PATH -i $DATA_PATH/crawler/rest_crawl/restaurant
if [[ $? -ne 0 ]]; then exit 1; fi

$CODE_PATH/bin/odis.sh -wn 4 outfox.silmaril.crawler.RestStateMerger -w $DATA_PATH -i $DATA_PATH/crawler/rest_crawl/rest_state
if [[ $? -ne 0 ]]; then exit 1; fi

# 抓取评论
$CODE_PATH/bin/odis.sh -wn 32 outfox.silmaril.crawler.CommentCrawler -w $DATA_PATH -n nb064:6636 -t 7
if [[ $? -ne 0 ]]; then exit 1; fi

$CODE_PATH/bin/odis.sh -wn 32 outfox.silmaril.crawler.CommentMerger -w $DATA_PATH -i $DATA_PATH/crawler/comment_crawl/comment
if [[ $? -ne 0 ]]; then exit 1; fi

$CODE_PATH/bin/odis.sh -wn 4 outfox.silmaril.crawler.RestStateMerger -w $DATA_PATH -i $DATA_PATH/crawler/comment_crawl/rest_state
if [[ $? -ne 0 ]]; then exit 1; fi

