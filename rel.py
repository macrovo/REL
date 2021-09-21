base_url = '/root/rel/'
from http.server import HTTPServer
from REL.entity_disambiguation import EntityDisambiguation
from REL.ner import Cmns, load_flair_ner
from REL.server import make_handler
wiki_version = "wiki_2021"
config = {
     "mode": "eval",
     "model_path": "/root/rel/wiki_2021/generated/model"
	 }
model = EntityDisambiguation(base_url, wiki_version, config)
tagger_ner = load_flair_ner("ner-fast")
tagger_ngram = Cmns(base_url, wiki_version, n=10)
server_address = ("0.0.0.0", 1235)
server = HTTPServer(
     server_address,
     make_handler(
         base_url, wiki_version, model, tagger_ner#ngram
     ),
)
try:
    print("Ready for listening.")
    server.serve_forever()
except KeyboardInterrupt:
    exit(0)

