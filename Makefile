.DEFAULT_GOAL := rdf
.PHONY: rdf solr toolsupdate clean

gitmaster := ./tools/.git/refs/heads/master
basename = data/usvd

# If make does create b in order to update something else, it deletes
# b later on after it is no longer needed.
.INTERMEDIATE: $(basename).rdf.xml

rdf: toolsupdate $(basename).ttl
solr: toolsupdate solr/usvd.json

tools:
	git clone https://github.com/danmichaelo/ubdata-tools.git tools

toolsupdate: tools
	cd ./tools && git pull && cd ..
	# touch ./tools/.git/refs/heads/master

$(basename).ttl: $(basename).rdf.xml $(gitmaster)
	rm -f skosify.log
	python ./tools/skosify-sort.py -b 'http://data.ub.uio.no/' -o $@ vocabulary.ttl $(basename).rdf.xml

$(basename).rdf.xml: $(basename).xml $(gitmaster)
	zorba -i ./tools/emneregister2rdf.xq -e "base:=usvd" -e "scheme:=http://data.ub.uio.no/usvd" \
	  -e "file:=../$(basename).xml" >| $@

#$(basename).xml:
#	<eksporteres ikke automatisk fra bibsys enda>
#	curl -s -o ./$(basename).xml http://www.bibsys.no/files/out/usvdsok/USVDregister.xml

solr/usvd.json: $(basename).ttl $(gitmaster)
	python ./tools/ttl2solr.py -v $(basename).ttl $@

clean:
	rm -f skosify.log
	rm -f $(basename).rdf.xml
	rm -f $(basename).ttl
	rm -f $(basename).tmp.ttl
