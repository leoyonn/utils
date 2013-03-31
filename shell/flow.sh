#!/bin/sh

#使用时请按需修改三个path
DATA_PATH=/exp/discovery/silmaril/global
CODE_PATH=/global/exec/discovery/silmaril
INDEX_PATH=/disk2/discovery/temp_index
# $CODE_PATH/bin/odis.sh -wn 16 outfox.silmaril.importer.CrawlerRestaurantImporter -w $DATA_PATH
# if [[ $? -ne 0 ]]; then exit 1; fi

# $CODE_PATH/bin/odis.sh -wn 16 outfox.silmaril.importer.CrawlerCommentImporter -w $DATA_PATH
# if [[ $? -ne 0 ]]; then exit 1; fi

## 基础相似度分析
$CODE_PATH/bin/odis.sh -wn 32 outfox.silmaril.importer.UserPlaceImporter -w $DATA_PATH
if [[ $? -ne 0 ]]; then exit 1; fi

$CODE_PATH/bin/odis.sh -wn 32 outfox.silmaril.flow.StaticSimilarAnalyzer -w $DATA_PATH
if [[ $? -ne 0 ]]; then exit 1; fi

$CODE_PATH/bin/odis.sh -wn 32 outfox.silmaril.flow.UserItemAnalyzer -w $DATA_PATH
if [[ $? -ne 0 ]]; then exit 1; fi

$CODE_PATH/bin/odis.sh -wn 32 outfox.silmaril.flow.DynamicSimilarAnalyzer -w $DATA_PATH
if [[ $? -ne 0 ]]; then exit 1; fi

$CODE_PATH/bin/odis.sh -wn 32 outfox.silmaril.flow.SimilarDataMerger -w $DATA_PATH
if [[ $? -ne 0 ]]; then exit 1; fi

## 连锁店数据分析
$CODE_PATH/bin/odis.sh -wn 16 outfox.silmaril.flow.ChainRestGenerator -w $DATA_PATH
if [[ $? -ne 0 ]]; then exit 1; fi

$CODE_PATH/bin/odis.sh -wn 16 outfox.silmaril.flow.ChainSimilarAnalyzer -w $DATA_PATH
if [[ $? -ne 0 ]]; then exit 1; fi

## 喜欢该餐馆的用户还喜欢哪些餐馆
$CODE_PATH/bin/odis.sh -cw local -wn 1 outfox.silmaril.flow.RelatedRestGenerator -w $DATA_PATH

## 榜单生成
$CODE_PATH/bin/odis.sh -wn 32 outfox.silmaril.flow.RegionBoardGenerator -w $DATA_PATH
if [[ $? -ne 0 ]]; then exit 1; fi

## 查询索引
$CODE_PATH/bin/odis.sh -wn 16 outfox.silmaril.flow.RestaurantIndexer -w $DATA_PATH -t $INDEX_PATH
if [[ $? -ne 0 ]]; then exit 1; fi
