.PHONY: ttl solr clean
.DEFAULT_GOAL := ttl

ttl: usvd.ttl
solr: usvd_solr.json

usvd_solr.json: usvd.ttl
	python ./tools/ttl2solr.py -v usvd.ttl usvd_solr.json

usvd.ttl: usvd.tmp.ttl
	rm -f skosify.log
	python ./tools/skosify-sort.py -b 'http://data.ub.uio.no/' -o usvd.ttl vocabulary.ttl usvd.tmp.ttl

usvd.tmp.ttl: usvd.rdf.xml
	rapper -i rdfxml -o turtle usvd.rdf.xml >| usvd.tmp.ttl

usvd.rdf.xml: tools usvd.xml
	cd tools && \
	git pull && \
	cd .. && \
    zorba -i tools/emneregister2rdf.xq -e "base:=usvd" -e "scheme:=http://data.ub.uio.no/usvd" -e "file:=../usvd.xml" >| usvd.rdf.xml

tools:
	git clone https://github.com/danmichaelo/ubdata-tools.git tools

#usvd.xml:
#	<eksporteres ikke automatisk fra bibsys enda>
#    wget -nv -O usvd.xml http://www.bibsys.no/files/out/humordsok/USVDregister.xml

clean:
	rm -f skosify.log
	rm -f usvd.rdf.xml
	rm -f usvd.ttl
	rm -f usvd.tmp.ttl
