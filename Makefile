.PHONY: rdf solr clean
.DEFAULT_GOAL := rdf

rdf: data/usvd.ttl
solr: solr/usvd.json

tools:
	git clone https://github.com/danmichaelo/ubdata-tools.git tools

toolsupdate:
	# Use this as an order-only prerequisite
	cd tools && git pull && cd ..

data/usvd.ttl: data/usvd.rdf.xml tools/.git/refs/heads/master | toolsupdate
	rm -f skosify.log
	python ./tools/skosify-sort.py -b 'http://data.ub.uio.no/' -o ./data/usvd.ttl vocabulary.ttl ./data/usvd.rdf.xml

data/usvd.rdf.xml: data/usvd.xml tools tools/.git/refs/heads/master | toolsupdate
	zorba -i ./tools/emneregister2rdf.xq -e "base:=usvd" -e "scheme:=http://data.ub.uio.no/usvd" -e "file:=../data/usvd.xml" >| ./data/usvd.rdf.xml

#data/usvd.xml:
#	<eksporteres ikke automatisk fra bibsys enda>
#	curl -s -o ./data/usvd.xml http://www.bibsys.no/files/out/usvdsok/USVDregister.xml

solr/usvd.json: rdf tools/.git/refs/heads/master | toolsupdate
	python ./tools/ttl2solr.py -v ./data/usvd.ttl ./solr/usvd.json

clean:
	rm -f ./skosify.log
	rm -f ./data/usvd.rdf.xml
	rm -f ./data/usvd.ttl
	rm -f ./data/usvd.tmp.ttl
