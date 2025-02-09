## UBOs emneregister til Dewey

### Innhold

Universitetsbiblioteket i Oslos emneregister til Dewey, også kjent
som UBOs kjederegister til Dewey, tidligere kjent som UBO/SV's kjederegister
til Dewey, derav akronymet USVD som fremdeles brukes.

Registeret er søkbart på <http://wgate.bibsys.no/search/pub?base=USVDEMNE>.
Frem til juni 2019 ble det vedlikeholdt i BIBSYS' emnemodul.
Vi har fått uregelmessige XML-eksporter derfra (`src/usvd.xml`) på epost.
Da basen ble stengt ned i juni 2019 fikk vi en siste eksport.

* `src/usvd.xml` : Source data from BIBSYS' emnemodul.
* `dist/usvd.ttl` : Converted to RDF Turtle.
* `dist/usvd.marc21.ttl` : Converted to MARC21 XML.


### Conversion

Authority data is currently maintained in Bibsys and converted to
JSON (RoaldIII data model) using [RoaldIII](https://github.com/realfagstermer/roald).
RoaldIII is also used to mix in mappings before exporting
RDF/SKOS and MARC21.

* `pip install -r requirements.txt` to install dependencies needed for the conversion.
* `doit build` to do the actual conversion. This only runs if any of the source files
have changed or any of the target files are missing. To force a conversion even if no
files have changed, run `doit forget build && doit build` (useful during development).

Please see the RoaldIII repo for more details on the conversion.

The RoaldIII JSON data is found in `usvd.json`.
Complete, distributable RDF/SKOS and MARC21 files are found in the
`dist` folder.


### Konverteringsprosessen

I registerfilen er hver term angitt som et `<post>`-element. Dette har
underelementer som `<term-id>`, `<hovedemnefrase>`, osv. Under vises
vår foreløpige modell for mapping av disse elementene til RDF, som
implementert i `convert.xq`. Vi bruker hovedsakelig
[SKOS-vokabularet](http://www.w3.org/2004/02/skos/core.html).

    if <se-id> then

      <http://data.ub.uio.no/usvd/<se-id> a skos:Concept
        skos:altLabel "<hovedemnefrase> (<kvalifikator>)"@nb

    else:

      <http://data.ub.uio.no/usvd/<term-id> a skos:Concept
        skos:prefLabel "<hovedemnefrase> : <kjede>"@nb
        dcterms:identifier "<term-id>"
        dcterms:modified "<dato>"^^xs:date
        skos:notation "<signatur>"^^<http://dewey.info/schema-terms/Notation>
        skos:definition "<definisjon>"@nb
        skos:editorialNote "<noter>"@nb
        skos:editorialNote "Lukket bemerkning: <lukket-bemerkning>"@nb
        skos:scopeNote "Se også: <gen-se-ogsa-henvisning>"@nb
        skos:broader <http://data.ub.uio.no/usvd/<overordnetterm-id>
        skos:broader <http://data.ub.uio.no/usvd/<ox-id>
        skos:related <http://data.ub.uio.no/usvd/<se-ogsa-id>

#### Foreløpig håndtering av klassifikasjonskoder (Dewey-notasjon)

* Klassifikasjonskode (Dewey-notasjon) legges foreløpig i `skos:notation`, med
  datatype `<http://dewey.info/schema-terms/Notation>`.
  Det kan være det hadde vært bedre å modellere disse som mappinger, men
  hvis de skal mappes til siste utgave av Dewey bør vi nok ta en gjennomgang
  av dem, siden det er brukt ulike utgaver av Dewey, og det er generelt ikke
  registrert hvilken utgave som er brukt (i noen poster er det ført inn i notefeltet).

* Alle tegn utenom tall, punktum og bindestrek fjernes.
  Eksempelvis blir «005.133Basi» konvertert til «005.133»
  ([USVD00332](http://wgate.bibsys.no/gate1/SHOW?objd=USVD00332&base=USVDEMNE)),
  «b 394.109411» til «394.109411»
  ([USVD45296](http://wgate.bibsys.no/gate1/SHOW?objd=USVD45296&base=USVDEMNE)),
  og «372.1103/kl» til «372.1103»
  ([USVD45366](http://wgate.bibsys.no/gate1/SHOW?objd=USVD45366&base=USVDEMNE)).
  Hvis færre enn tre gyldige tegn gjenstår, utelates feltet.
  Dette er sannsynligvis feilinnførsler. Se f.eks.
  [USVD34368](http://wgate.bibsys.no/gate1/SHOW?objd=USVD34368&base=USVDEMNE)
  der «Tai språk (språkgruppe)» er fylt inn i feltet for klassifikasjonskode.

* I noen poster blir feltet gjentatt, f.eks.
  [USVD00007](http://wgate.bibsys.no/gate1/SHOW?objd=USVD00007&base=USVDEMNE).
  Vi bruker kun den første (gyldige) verdien, og ignorerer påfølgende verdier.
  Dette gjelder 58 poster, som er listet opp
  [her](https://gist.github.com/danmichaelo/7abb4bc60bce75e7b93c) så vi kan
  sjekke konsekvensene av dette (Listen er generert av
  `list_multiple_signatures.xq`).

* Feltet kan inneholde rekker, som «011-016»
  ([USVD00393](http://wgate.bibsys.no/gate1/SHOW?objd=USVD00393&base=USVDEMNE)).
  Disse beholdes som de er, selv om de ikke kan brukes i mappingprosjektet.
  Hvis de fører til støy kan vi evt. fjerne dem.

#### Andre merknader

* Se-henvisninger mappes til skos:altLabel. De beholder ikke egne identifikatorer.
  Vi *kan* beholde disse ved å bruke SKOS-XL, men foreløpig seg jeg ikke noe poeng
  med det. Må diskuteres!

* Elementet `<underemnefrase>` ignoreres. Jeg er usikker på feltets betydning,
  og det er bare [brukt 22 ganger](https://gist.github.com/danmichaelo/fb3afc5ab9a161dfae7d)
  (Listen er generert av `list_underemnefrase.xq`).

### Lisens

Dataene ble lagt ut i forbindelse med prosjektet
[tesaurus-mapping](http://www.ub.uio.no/om/prosjekter/tesaurus/)
høsten 2014.
De er tilgjengelige under [CC0 1.0](//creativecommons.org/publicdomain/zero/1.0/deed.no).
