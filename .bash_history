

# INITIAL setup

apt-get install libomp-dev
apt-get install libopenblas-dev
apt-get install libomp-dev
pip3 install git+https://github.com/informagi/REL
pip3 install faiss
pip3 install flair
pip3 uninstall torch
pip3 install torch==1.6
pip3 install wikipedia2vec
pip3 install gensim=>3.8.0 -U

mkdir ~/rel && cd ~/rel
mkdir -p wiki_latest/basic_data/anchor_files
mkdir -p wiki_latest/generated/old
mkdir -p wiki_latest/generated/test_train_data
wget -c http://gem.cs.ru.nl/generic.tar.gz
wget -c http://gem.cs.ru.nl/wiki_2019.tar.gz
wget -c http://gem.cs.ru.nl/ed-wiki-2019.tar.gz
gunzip generic.tar.gz 
gunzip ed-wiki-2019.tar.gz 
gunzip wiki_2019.tar.gz 
tar -xvf generic.tar
tar -xvf ed-wiki-2019.tar 
tar -xvf wiki_2019.tar 

#git clone https://github.com/informagi/REL.git
#pip uninstall REL
pip install git+https://github.com/informagi/REL

# This should work, test
nohup python3 rel.py &
python3 rel_test.py 
# kill above rel.py process when updating below. 



# UPDATING Wikipedia version: https://github.com/informagi/REL/tree/master/tutorials/deploy_REL_new_Wiki
#best to name folder wiki_latest, and then don't need to grep / sed all the py / bash files.. simply replace latest wiki dump

cd ~/rel
wget -c https://dumps.wikimedia.org/enwiki/20210901/enwiki-20210901-pages-articles-multistream.xml.bz2
#We will need both comressed and uncompressed versions
cp  enwiki-20210901-pages-articles-multistream.xml.bz2 enwiki-latest-pages-articles-multistream.xml.bz2
cp  enwiki-latest-pages-articles-multistream.xml.bz2 wiki_corpus.xml.bz2
bzip2 -dk enwiki-latest-pages-articles-multistream.xml.bz2 

#https://github.com/informagi/REL/blob/master/tutorials/deploy_REL_new_Wiki/04_01_Extracting_a_new_Wikipedia_corpus.md
cd REL/
find -name WikiExtractor.py
cp REL/scripts/WikiExtractor.py wiki_latest/basic_data/
mv enwiki-latest-pages-articles-multistream.xml wiki_latest/basic_data/
cd wiki_latest/basic_data/
mv enwiki-latest-pages-articles-multistream.xml wiki_corpus.xml
nohup python3 WikiExtractor.py ./wiki_corpus.xml --links --filter_disambig_pages --processes 1 --bytes 1G & 
mv wiki_corpus.xml anchor_files/

#can move this segment to initial setup above, as renamed from 2021 to latest
cd code_tutorials/
grep base_url *.py
sed -i 's/base_url = ""/base_url = "\/root\/rel\/"/g' *.py
sed -i 's/wiki_2019/wiki_latest/g' *.py
cd ~/rel/REL/scripts/code_tutorials/
grep -rn "base_url = " --include="*.py" /root/rel/
find /root/rel/ -type f | xargs sed -i 's/base_url = "\/Users\/vanhulsm\/Desktop\/projects\/data\/"/base_url = "\/root\/rel\/"/g'
find /root/rel/ -type f -name '*.py' | xargs sed -i 's/base_url = "\/Users\/vanhulsm\/Desktop\/projects\/data\/"/base_url = "\/root\/rel\/"/g'
find /root/rel/ -type f -name '*.py' | xargs sed -i 's/base_url = "\/users\/vanhulsm\/Desktop\/projects\/data\/"/base_url = "\/root\/rel\/"/g'
find /root/rel/ -type f -name '*.py' | xargs sed -i 's/base_url = "\/users\/vanhulsm\/Desktop\/projects\/data"/base_url = "\/root\/rel\/"/g'
find /root/rel/ -type f -name '*.py' | xargs sed -i 's/base_url = "C:\/Users\/mickv\/Desktop\/data_back\/"/base_url = "\/root\/rel\/"/g'
find /root/rel/ -type f -name '*.py' | xargs sed -i 's/base_url = "C:\/Users\/mickv\/desktop\/data_back\/"/base_url = "\/root\/rel\/"/g'
cd /usr/local/lib/python3.6/dist-packages/REL/
grep -rn "base_url = " --include="*.py" .
#move above this segment

cd /root/rel/REL/scripts/code_tutorials/
cd ~/rel/wiki_latest/basic_data/
mv wiki_corpus.xml ..
mv ../text/AA/wiki_* .
cd ~/rel/REL/scripts/code_tutorials/
python3 generate_p_e_m.py 
# now run py code from above link-graph, may be in generate_p_e_m.py.. have to check. 


#https://github.com/informagi/REL/blob/master/tutorials/deploy_REL_new_Wiki/04_02_training_your_own_embeddings.md
cd REL/scripts/w2v/
cat preprocess.sh | tr -d '\r' > preprocess2.sh
chmod +x preprocess2.sh 
cd ~/rel/wiki_latest/basic_data/
mv wiki_corpus.xml.bz2 enwiki-pages-articles.xml.bz2
chmod +w enwiki-pages-articles.xml.bz2 && chmod +x enwiki-pages-articles.xml.bz2 
cd ~/rel/REL/scripts/w2v
#commented out 1st command with joe
joe preprocess2.sh 
#that command line from preprocess2.sh manually
wikipedia2vec build-dump-db /root/rel/wiki_latest/basic_data/ wiki_corpus.xml.bz2
#rest
nohup ./preprocess2.sh &
#from train.sh, modified
nohup /root/.local/bin/wikipedia2vec train --min-entity-count 0 --disambi ~/rel/wiki_latest/basic_data/enwiki-pages-articles.xml.bz2 wikipedia2vec_trained &
nohup /root/.local/bin/wikipedia2vec train-embedding dump_file dump_dict wikipedia2vec_trained --link-graph dump_graph --mention-db dump_mention  --dim-size 300 &
nohup /root/.local/bin/wikipedia2vec save-text --out-format word2vec wikipedia2vec_trained wikipedia2vec_wv2vformat &
#now run py code from above link, replace enwiki_w2v_model with wikipedia2vec_wv2vformat


#https://github.com/informagi/REL/blob/master/tutorials/deploy_REL_new_Wiki/04_03_generating_training_test_files.md
cd ~/rel
grep -r -i  --include \*.py 'emb.load_word2emb' .
#i think i didn't edit anything here!
joe ./REL/REL/db/generic.py

#move this to initial setup above
cd ~/rel/generic/test_datasets/wned-datasets/wikipedia/RawText 
mv Harvard_Crimson_men_s_lacrosse "Harvard_Crimson_men's_lacrosse"
mv "Zielona_Gвra_(parliamentary_constituency)" "Zielona_Góra_(parliamentary_constituency)"
mv "Mary_O_Connor_(sportsperson)" "Mary_O'Connor_(sportsperson)"
mv "Florida_Gulf_Coast_Eagles_men_s_basketball" "Florida_Gulf_Coast_Eagles_men's_basketball"
mv "Chippenham_United_F.C_" "Chippenham_United_F.C."
mv Czech_Republic_men_s_national_ice_hockey_team "Czech_Republic_men's_national_ice_hockey_team"
mv Love_s_Welcome_at_Bolsover "Love's_Welcome_at_Bolsover"
mv Ya_akov_Riftin "Ya'akov_Riftin"
mv CA_Saint-Рtienne_Loire_Sud_Rugby "CA_Saint-Étienne_Loire_Sud_Rugby"
mv Jeanne_d_Рvreux "Jeanne_d'Évreux"
mv "Rбo_Verde,_Chile" "Río_Verde,_Chile"
mv "Law___Order_(season_16)" "Law_&_Order_(season_16)"
mv "Love___Life_(Mary_J._Blige_album)" "Love_&_Life_(Mary_J._Blige_album)"
mv WБrttemberger "Württemberger"
mv ChГteau_d_Oiron "Château_d'Oiron"
mv "Krasi,_Thalassa_Kai_T__Agori_Mou" "Krasi,_Thalassa_Kai_T'_Agori_Mou"
mv "Alfred_Conkling_Coxe,_Sr_" "Alfred_Conkling_Coxe,_Sr."
mv "Clara_NordstrФm" "Clara_Nordström"
mv "Hittin__the_Trail_for_Hallelujah_Land" "Hittin'_the_Trail_for_Hallelujah_Land"
mv JosВ_Evangelista "José_Evangelista"
mv Putin_s_rynda "Putin's_rynda"
#commenced out #"wned-clueweb",
joe /usr/local/lib/python3.6/dist-packages/REL/training_datasets.py
rm -rf /usr/local/lib/python3.6/dist-packages/REL/__pycache__
#move above this segment

#now run py code from above link

#https://github.com/informagi/REL/blob/master/tutorials/deploy_REL_new_Wiki/04_04_training_your_own_ED_model.md
#run py codes from above link

#this should work now with latest dump
nohup python3 rel.py &
python3 rel_test.py 
