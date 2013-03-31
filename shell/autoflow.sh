#!/bin/sh

## ================= 使用时请按需修改三个path ====================
DATA_ROOT=/exp/discovery/silmaril
CODE_PATH=/global/exec/discovery/silmaril
INDEX_PATH=/disk2/discovery/temp_index
## ===============================================================

RELEASE_PATH=$DATA_ROOT/release
SERVE_PATH=$DATA_ROOT/global

## 基础相似度分析
$CODE_PATH/bin/odis.sh -wn 32 outfox.silmaril.importer.UserPlaceImporter -w $SERVE_PATH
if [[ $? -ne 0 ]]; then exit 1; fi

$CODE_PATH/bin/odis.sh -wn 32 outfox.silmaril.flow.UserItemAnalyzer -w $SERVE_PATH
if [[ $? -ne 0 ]]; then exit 1; fi

$CODE_PATH/bin/odis.sh -wn 32 outfox.silmaril.flow.DynamicSimilarAnalyzer -w $SERVE_PATH
if [[ $? -ne 0 ]]; then exit 1; fi

$CODE_PATH/bin/odis.sh -wn 32 outfox.silmaril.flow.SimilarDataMerger -w $SERVE_PATH
if [[ $? -ne 0 ]]; then exit 1; fi

$CODE_PATH/bin/odis.sh -wn 16 outfox.silmaril.flow.ChainSimilarAnalyzer -w $SERVE_PATH
if [[ $? -ne 0 ]]; then exit 1; fi

$CODE_PATH/bin/odis.sh -wn 16 outfox.silmaril.flow.RestaurantIndexer -w $SERVE_PATH -t $INDEX_PATH
if [[ $? -ne 0 ]]; then exit 1; fi

$CODE_PATH/bin/odis.sh odfs ln $SERVE_PATH $RELEASE_PATH/`date +%Y%m%d`
if [[ $? -ne 0 ]]; then exit 1; fi
