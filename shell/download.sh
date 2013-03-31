#!/bin/sh

# download data to local

DATE=`date +%Y%m%d%H%M`
ODFS_PATH=/exec/silmaril/global
LOCAL_PATH=/disk3/discovery/recommend_$DATE
LINK_PATH=/disk3/discovery/recommend_latest

rm -fr $LOCAL_PATH
mkdir -p $LOCAL_PATH

## 餐馆信息
./bin/odis.sh odfs mirror $ODFS_PATH/restaurant $LOCAL_PATH
if [[ $? -ne 0 ]]; then exit 1; fi

## 连锁店
./bin/odis.sh odfs mirror $ODFS_PATH/chain_rest $LOCAL_PATH
if [[ $? -ne 0 ]]; then exit 1; fi

## 查询索引(包括相似数据)
./bin/odis.sh odfs mirror $ODFS_PATH/index $LOCAL_PATH
if [[ $? -ne 0 ]]; then exit 1; fi

## 榜单
./bin/odis.sh odfs mirror $ODFS_PATH/region_board $LOCAL_PATH
if [[ $? -ne 0 ]]; then exit 1; fi

## 菜品相似的信息
./bin/odis.sh odfs mirror $ODFS_PATH/dish/merged_similar $LOCAL_PATH/dish/merged_similar

## 特色菜数据
./bin/odis.sh odfs get $ODFS_PATH/special_dish/sdish_rests.dat $LOCAL_PATH/sdish_rests.dat

## 相关餐馆信息
./bin/odis.sh odfs mirror $ODFS_PATH/related_rest $LOCAL_PATH/related_rest

rm -f $LINK_PATH
ln -s $LOCAL_PATH $LINK_PATH
