#NOTE: all files will be downloaded to current folder

# Install package
pip install wikipedia2vec --user

echo --------------------------------------
echo Where is the Wikipedia dump stored?
read varname
echo User entered: $varname

# Preprocess wikipedia
#/root/.local/bin/wikipedia2vec build-dump-db $varname dump_file

/root/.local/bin/wikipedia2vec build-dictionary dump_file dump_dict --min-entity-count 0 

/root/.local/bin/wikipedia2vec build-link-graph dump_file dump_dict dump_graph

/root/.local/bin/wikipedia2vec build-mention-db dump_file dump_dict dump_mention
