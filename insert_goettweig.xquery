xquery version "3.1";
declare default element namespace "http://www.tei-c.org/ns/1.0";
declare namespace atom = "http://www.w3.org/2005/Atom";
declare namespace cei = "http://www.monasterium.net/NS/cei";

let $doc := doc('goettweig_momified.xml')/TEI
let $facsimiles := $doc/facsimile
for $entry in $doc//ab
where $entry[normalize-space() != '']
let $page := $entry/preceding-sibling::pb[1]
let $facs := substring-after($page/@facs/data(), '#')
let $img := $facsimiles/surface[@xml:id = $facs]/graphic/@url/data()
let $charter-name := concat(substring-before(substring-after($img, 'OSB_'), '.jpg'), '.cei.xml')
let $charter-path := concat('/db/mom-data/metadata.charter.public/AT-StiAG/GoettweigOSB/', $charter-name)
let $charter := doc($charter-path)
let $old-tenor := $charter/atom:entry/atom:content/cei:text/cei:body/cei:tenor
let $new-tenor := <cei:tenor>{$entry//node()}</cei:tenor>
let $transcription-note := <cei:p type='transcription note'>Urkunden dieses Fonds wurden transkribiert von Gerlinde Gangl &amp; Johannes Laroche.</cei:p>
let $transcription-state := <cei:p type='transcription state'>Bearbeitungsstand: MITTEL</cei:p>
return if (exists($charter)) then (
    update delete $charter/atom:entry/atom:content/cei:text/cei:body/cei:chDesc/cei:diplomaticAnalysis/cei:p[@type='transcription note'],
    update insert $transcription-note into $charter/atom:entry/atom:content/cei:text/cei:body/cei:chDesc/cei:diplomaticAnalysis,
    update delete $charter/atom:entry/atom:content/cei:text/cei:body/cei:chDesc/cei:diplomaticAnalysis/cei:p[@type='transcription state'],
    update insert $transcription-state into $charter/atom:entry/atom:content/cei:text/cei:body/cei:chDesc/cei:diplomaticAnalysis,
    update delete $charter/atom:entry/atom:content/cei:text/cei:body/cei:tenor, 
    update insert $new-tenor following $charter/atom:entry/atom:content/cei:text/cei:body/cei:chDesc
    )
else concat($charter-path, ' does not exist!')