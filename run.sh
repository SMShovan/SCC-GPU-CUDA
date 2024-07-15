#!/bin/sh


artemis_path="/home/users/apandey/SCC-new"
tacc_path="/home/sskg8/SCC-dev1/Examples/"

if [ $1 = "baidu" ]; then
    ./a.out ${tacc_path}baiduKeyEdged.txt ${tacc_path}baidu_ME.txt ${tacc_path}scc_baidu.txt ${tacc_path}baidu_1_Map.txt ${tacc_path}baidu_1M_25 $2 $3
fi

if [ $1 = "test" ]; then
   ./a.out ${tacc_path}t.txt ${tacc_path}test_ME.txt ${tacc_path}test_CC1.txt ${tacc_path}test_map.txt ${tacc_path}test_change1.txt $2 $3
fi

if [ $1 = "dag" ]; then
   ./a.out ${tacc_path}dag.txt ${tacc_path}dagME.txt ${tacc_path}dagCC.txt ${tacc_path}dagMAP.txt ${tacc_path}dagCE.txt $2 $3 > out.txt
fi

if [ $1 = "baidu1" ]; then
    ./a.out ${tacc_path}/SCC-new/Datasets/KeyEdged/baidu ${tacc_path}/SCC-new/Datasets/Metagraphs/baidu ${tacc_path}/SCC-new/Datasets/SCCx/baidu ${tacc_path}/SCC-new/Datasets/Map/baidu ${tacc_path}/SCC-new/Datasets/ChangedEdges/baidu_ce/baidu_1M_25 $2 $3
fi

if [ $1 = "flickr" ]; then
    ./a.out ${tacc_path}/SCC-new/Datasets/KeyEdged/flickr ${tacc_path}/SCC-new/Datasets/Metagraphs/flickr ${tacc_path}/SCC-new/Datasets/SCCx/flickr ${tacc_path}/SCC-new/Datasets/Map/flickr ${tacc_path}/SCC-new/Datasets/ChangedEdges/flickr_ce/flickr_1M_25 $2 $3
fi

if [ $1 = "livejournal" ]; then
    ./a.out ${tacc_path}/SCC-new/Datasets/KeyEdged/livejournal ${tacc_path}/SCC-new/Datasets/Metagraphs/livejournal ${tacc_path}/SCC-new/Datasets/SCCx/livejournal ${tacc_path}/SCC-new/Datasets/Map/livejournal ${tacc_path}/SCC-new/Datasets/ChangedEdges/livejournal_ce/livejournal_1M_25 $2 $3
fi

if [ $1 = "pokec" ]; then
    ./a.out ${tacc_path}/SCC-new/Datasets/KeyEdged/pokec ${tacc_path}/SCC-new/Datasets/Metagraphs/pokec ${tacc_path}/SCC-new/Datasets/SCCx/pokec ${tacc_path}/SCC-new/Datasets/Map/pokec ${tacc_path}/SCC-new/Datasets/ChangedEdges/pokec_ce/pokec_1M_25 $2 $3
fi

if [ $1 = "wiki-com" ]; then
    ./a.out ${tacc_path}/SCC-new/Datasets/KeyEdged/wiki-com ${tacc_path}/SCC-new/Datasets/Metagraphs/wiki-com ${tacc_path}/SCC-new/Datasets/SCCx/wiki-com ${tacc_path}/SCC-new/Datasets/Map/wiki-com ${tacc_path}/SCC-new/Datasets/ChangedEdges/wiki-com_ce/wiki-com_1M_25 $2 $3
fi

if [ $1 = "wiki-en" ]; then
    ./a.out ${tacc_path}/SCC-new/Datasets/KeyEdged/wiki-en ${tacc_path}/SCC-new/Datasets/Metagraphs/wiki-en ${tacc_path}/SCC-new/Datasets/SCCx/wiki-en ${tacc_path}/SCC-new/Datasets/Map/wiki-en ${tacc_path}/SCC-new/Datasets/ChangedEdges/wiki-en_ce/wiki-en_1M_25 $2 $3
fi


if [ $1 = "artemis_baidu" ]; then
    ./a.out ${artemis_path}/Examples/baiduKeyEdged.txt ${artemis_path}/Examples/baidu_ME.txt ${artemis_path}/Examples/xbaidu ${artemis_path}/Examples/baidu_1_Map.txt ${artemis_path}/Examples/baidu_1M_25c $2 $3
fi

if [ $1 = "artemis_test" ]; then
   ./a.out ${artemis_path}/Examples/t.txt ${artemis_path}/Examples/test_ME.txt ${artemis_path}/Examples/test_CC1.txt ${artemis_path}/Examples/test_map.txt ${artemis_path}/Examples/test_change1.txt $2 $3
fi

if [ $1 = "artemis_dag" ]; then
   ./a.out ${artemis_path}/Examples/dag.txt ${artemis_path}/Examples/dagME.txt ${artemis_path}/Examples/dagCC.txt ${artemis_path}/Examples/dagMAP.txt ${artemis_path}/Examples/dagCE.txt $2 $3 > out.txt
fi

if [ $1 = "artemis_test" ]; then
   ./a.out ${artemis_path}/Examples/test_file1.txt ${artemis_path}/Examples/test_ME.txt ${artemis_path}/Examples/test_CC1.txt ${artemis_path}/Examples/test_map.txt ${artemis_path}/Examples/test_change1.txt $2 $3
fi

# baidu
