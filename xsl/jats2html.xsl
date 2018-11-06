<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  xmlns:css="http://www.w3.org/1996/css" 
  xmlns:saxon="http://saxon.sf.net/"
  xmlns:xlink="http://www.w3.org/1999/xlink" 
  xmlns:jats="http://jats.nlm.nih.gov"
  xmlns:jats2html="http://transpect.io/jats2html" 
  xmlns:hub2htm="http://transpect.io/hub2htm" 
  xmlns:l10n="http://transpect.io/l10n"
  xmlns:tr="http://transpect.io" 
  xmlns:epub="http://www.idpf.org/2007/ops"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="html tr xlink xs css saxon jats2html hub2htm l10n cx"
  version="2.0">

  <!-- If you see a message that an attribute cannot be created after a child of the containing
    element, see which 'unhandled' message comes before it and write a template for the unhandled. -->

  <!-- If you see a message telling you that something is unhandled, there is probably an xsl:next-match
       without a handler for it. You might add the element name to the matching pattern below 
       (search for 'Default handler')-->

  <xsl:import href="http://transpect.io/hub2html/xsl/css-rules.xsl"/>
  <xsl:import href="http://transpect.io/hub2html/xsl/css-atts2wrap.xsl"/>
  <xsl:import href="http://transpect.io/xslt-util/lengths/xsl/lengths.xsl"/>
  <xsl:import href="http://transpect.io/xslt-util/hex/xsl/hex.xsl"/>
  <xsl:import href="http://transpect.io/xslt-util/flat-list-to-tree/xsl/flat-list-to-tree.xsl"/>
  <xsl:import href="http://transpect.io/unwrap-mml/xsl/unwrap-mml.xsl"/>
	
  <xsl:param name="debug" select="'yes'"/>
  <xsl:param name="debug-dir-uri" select="'debug'"/>
  <xsl:param name="srcpaths" select="'no'"/>
  <xsl:param name="create-metadata-head" select="'yes'"/>
  <xsl:param name="render-metadata" select="'no'"/>
  <xsl:param name="xhtml-version" select="'1.0'"/><!-- supported values: '1.0', '5.0' -->

  <xsl:param name="s9y1-path" as="xs:string?"/>
  <xsl:param name="s9y2-path" as="xs:string?"/>
  <xsl:param name="s9y3-path" as="xs:string?"/>
  <xsl:param name="s9y4-path" as="xs:string?"/>
  <xsl:param name="s9y5-path" as="xs:string?"/>
  <xsl:param name="s9y6-path" as="xs:string?"/>
  <xsl:param name="s9y7-path" as="xs:string?"/>
  <xsl:param name="s9y8-path" as="xs:string?"/>
  <xsl:param name="s9y9-path" as="xs:string?"/>
  <xsl:param name="s9y1-role" as="xs:string?"/>
  <xsl:param name="s9y2-role" as="xs:string?"/>
  <xsl:param name="s9y3-role" as="xs:string?"/>
  <xsl:param name="s9y4-role" as="xs:string?"/>
  <xsl:param name="s9y5-role" as="xs:string?"/>
  <xsl:param name="s9y6-role" as="xs:string?"/>
  <xsl:param name="s9y7-role" as="xs:string?"/>
  <xsl:param name="s9y8-role" as="xs:string?"/>
  <xsl:param name="s9y9-role" as="xs:string?"/>
  
  <xsl:variable name="paths" as="xs:string*" 
    select="($s9y1-path, $s9y2-path, $s9y3-path, $s9y4-path, $s9y5-path, $s9y6-path, $s9y7-path, $s9y8-path, $s9y9-path)"/>
  <xsl:variable name="roles" as="xs:string*" 
    select="($s9y1-role, $s9y2-role, $s9y3-role, $s9y4-role, $s9y5-role, $s9y6-role, $s9y7-role, $s9y8-role, $s9y9-role)"/>
  <xsl:variable name="common-path" as="xs:string?" select="$paths[position() = index-of($roles, 'common')]"/>
  <xsl:variable name="work-path" as="xs:string?" select="$paths[position() = index-of($roles, 'work')]"/>
  <xsl:variable name="publisher-path" as="xs:string?" select="$paths[position() = index-of($roles, 'publisher')]"/>
  <xsl:variable name="series-path" as="xs:string?" select="$paths[position() = index-of($roles, 'production-line')]"/>
  
  <xsl:param name="subtitles-in-titles" select="'yes'"/>
  <!-- with $xhtml-version eq '5.0' <section> will be created instead of <div> -->
  <xsl:param name="divify-sections" select="'no'"/>
  <xsl:param name="divify-title-groups" select="'no'"/>
  <!-- Resolve Relative links to the parent directory against the following URI
       (for example, the source XML directory's URL in the code repository),
       empty string or unset param if no resolution required: -->
  <xsl:param name="rr" select="'doc/'"/>
  <!-- convention: if empty string, then concat($common-path, '/css/stylesheet.css') -->
  <xsl:param name="css-location" select="''"/>
  <!-- for calculating whether a table covers the whole width or only part of it: -->
  <xsl:param name="page-width" 
             select="if (/book/book-meta/custom-meta-group/custom-meta[meta-name[. = 'type-area-width']]
                                                                      [matches(meta-value, '\d')]) 
                     then concat(((/book/book-meta/custom-meta-group/custom-meta[meta-name[. = 'type-area-width']]/meta-value) * 0.3527), 'mm')
                     else '180mm'"/>
  <xsl:param name="page-width-twips" select="tr:length-to-unitless-twip($page-width)" as="xs:double"/>
  <!-- whether to create backlinks from index terms to index entries.
       text-and-number: link from index terms with their text and number
       number: link from index terms with their number
       none: go figure -->
  <xsl:param name="index-backlink-type" select="'text-and-number'"/>   
  <!-- whether to link from bibliography entries to citations in the text.
       letter: link from entry with a letter
       none: go figure -->
  <xsl:param name="bib-backlink-type" select="'letter'"/>
  <!-- change markup for indices -->
  <xsl:param name="index-symbol-heading"   as="xs:string"  select="'0'"/>
  <xsl:param name="index-generate-title"   as="xs:string"  select="'no'"/>
  <xsl:param name="index-fallback-title"    as="xs:string"  select="'Index'"/>
  <xsl:param name="index-heading-elt-name" as="xs:string"  select="'h4'"/>
  <xsl:param name="index-heading-class"    as="xs:string"  select="'index-subheading'"/>
  
  <xsl:output method="xhtml" indent="no" 
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
    doctype-public="-//W3C//DTD XHTML 1.0//EN" 
    saxon:suppress-indentation="p li h1 h2 h3 h4 h5 h6 th td dd dt"/>
  
  <xsl:output method="xml" indent="yes" name="debug" exclude-result-prefixes="#all"/>

  <xsl:param name="lang" select="(/*/@xml:lang, 'en')[1]" as="xs:string"/>
  
  <xsl:variable name="l10n" select="document(concat('../l10n/l10n.', ($lang, 'en')[1], '.xml'))"
    as="document-node(element(l10n:l10n))"/>

  <xsl:key name="l10n-string" match="l10n:string" use="@id"/>
  
  <xsl:template match="* | @*" mode="expand-css clean-up table-widths epub-alternatives">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@* | node()" mode="#current" />  
    </xsl:copy>
  </xsl:template>
  
  <!-- collateral. Otherwise the generated IDs might differ due to temporary trees / variables 
    when transforming the content -->  
  <xsl:template match="*[name() = ('index-term', 'xref', 'fn')][not(@id)]" mode="epub-alternatives">
    <xsl:copy copy-namespaces="no">
      <xsl:attribute name="id" select="generate-id()"/>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="html:span[not(@*)]" mode="clean-up">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template match="*" mode="jats2html" priority="-1">
    <xsl:if test="$debug eq 'yes' and not(self::html:*)">
      <xsl:message>jats2html: unhandled: <xsl:apply-templates select="." mode="css:unhandled"/></xsl:message>
    </xsl:if>
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" mode="#current" />  
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="@*" mode="jats2html">
    <xsl:if test="$debug eq 'yes'">
      <!--<xsl:message>jats2html: unhandled attr: <xsl:apply-templates select="." mode="css:unhandled"/></xsl:message>-->
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="@dtd-version" mode="jats2html" />
  
  <!-- A customizing of the following template may look like this:
  <xsl:template match="/*" mode="jats2html">
    <xsl:next-match>
      <xsl:with-param name="footnote-roots" tunnel="yes" 
        select="//(
                   book-part[not(every $c in body/* satisfies $c/self::book-part)]
                  |front-matter-part | foreword | preface | dedication[book-part-meta/title-group/node()]
                  |named-book-part-body
                  |body[not(descendant::body)] |  named-book-part-body | glossary | title-group | front-matter
                  |book/book-back/ref-list | book/book-back/glossary | front-matter/ack
                  |app[empty(ancestor::app-group | ancestor::app)]
                  |app-group
                  |index[$use-print-index]
                  )"/>
    </xsl:next-match>
  </xsl:template>
  List all matching patterns of templates that invoke jats2html:footnotes.
  jats2html:footnotes will make sure that no footnote div will be generated if all footnotes of the context element 
  are contained in a footnote root that it nested within the context element.
  -->
  
  <xsl:template match="/*" mode="jats2html">
    <xsl:param name="footnote-roots" tunnel="yes" select="//(ack
                                                            |body[not(ancestor::body)]
                                                            |named-book-part-body
                                                            |app[not(ancestor::app-group)]
                                                            |app-group
                                                            |glossary)"/>
    <html>
      <xsl:apply-templates select="@xml:*" mode="#current"/>
      <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
        <xsl:if test="@source-dir-uri">
          <meta name="source-dir-uri" content="{@source-dir-uri}"/>
        </xsl:if>
        <xsl:if test="$css-location ne ''">
          <link rel="stylesheet" type="text/css" href="{$css-location}"/>  
        </xsl:if>
        <xsl:if test="$css-location eq ''">
          <link rel="stylesheet" type="text/css" href="{concat($common-path, 'css/stylesheet.css')}"/>  
        </xsl:if>
        <xsl:for-each select="reverse($paths[not(position() = index-of($roles, 'common'))])">
          <link rel="stylesheet" type="text/css" href="{concat(., 'css/overrides.css')}"/>
        </xsl:for-each>
        <xsl:if test="$create-metadata-head eq 'yes'">
          <xsl:call-template name="create-meta-tags"/>  
        </xsl:if>
        <title>
          <xsl:apply-templates select="book-meta/book-title-group/book-title/node()
                                      |front/article-meta/title-group/article-title/node()"
                               mode="#current">
            <!-- suppress replicated target with id: -->
            <xsl:with-param name="in-toc" select="true()" tunnel="yes"/>
          </xsl:apply-templates>
        </title>
        <xsl:apply-templates select=".//custom-meta-group/css:rules" mode="hub2htm:css"/>
      </head>
      <body>
        <!-- Commented out because this template needs to be called in the context of metadata elements:
          <xsl:if test="$render-metadata eq 'yes'">
          <xsl:call-template name="render-metadata-sections"/>
        </xsl:if>-->
        <xsl:apply-templates mode="#current">
          <xsl:with-param name="footnote-ids" select="//fn/@id" as="xs:string*" tunnel="yes"/>
          <xsl:with-param name="root" select="root(.)" as="document-node()" tunnel="yes"/>
          <xsl:with-param name="footnote-roots" as="element(*)*" tunnel="yes" select="$footnote-roots"/>
        </xsl:apply-templates>
      </body>
    </html>
  </xsl:template>
  
  <xsl:template match="book-meta
                      |collection-meta
                      |front/journal-meta
                      |front/article-meta" mode="jats2html">
    <xsl:element name="{if($xhtml-version eq '5.0') 
                        then 'section' 
                        else 'div'}">
      <xsl:attribute name="class" select="local-name()"/>
      <xsl:apply-templates select="@*" mode="jats2html"/>
      <xsl:call-template name="create-title-pages"/>
      <xsl:call-template name="render-metadata-sections"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="book-part-meta" mode="jats2html">
    <xsl:call-template name="render-metadata-sections"/>
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="book-part-meta/*[not(self::title-group or self::contrib-group)]" mode="jats2html"/>
  
  <!-- override this if you want to specify which elements appear in what order -->
  <xsl:template name="create-title-pages">
    <xsl:apply-templates select="@*, node()" mode="jats2html-create-title"/>
  </xsl:template>
  
   <xsl:template match="sec" mode="epub-alternatives">
     <xsl:variable name="ordered-sec-meta-elements" select="label, 
                                                            title, 
                                                            subtitle, 
                                                            alt-title, 
                                                            sec-meta" as="element()*"/>
     <xsl:copy copy-namespaces="no">
       <xsl:variable name="sec-meta-elements" 
                     select="label, 
                             title, 
                             subtitle, 
                             alt-title, 
                             sec-meta " as="element()*"/>
       <!-- sec-meta elements are located in BITS as first child of the section, followed by the title. So we change the order here -->
       <xsl:apply-templates select="@*,
                                    $sec-meta-elements,
                                    node() 
                                    except $sec-meta-elements" mode="#current"/>
     </xsl:copy>
  </xsl:template>
  
  <xsl:template match="sec-meta" mode="epub-alternatives">
    <xsl:apply-templates select="node()" mode="#current"/>
  </xsl:template>
  
  <xsl:variable name="default-structural-containers" as="xs:string+"
                select="('abstract',
                         'ack',
                         'app',
                         'back',
                         'body',
                         'book-app',
                         'book-back',
                         'book-body',
                         'book-part',
                         'contrib-group',
                         'dedication',
                         'fn-group',
                         'foreword',
                         'front',
                         'front-matter',
                         'front-matter-part',
                         'glossary',
                         'named-book-part-body',
                         'preface',
                         'ref-list',
                         'sec')"/>
  
  <xsl:template match="*[local-name() = $default-structural-containers]" mode="jats2html" priority="2">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <!-- everything that goes into a div (except footnote-like content): -->
  <xsl:template match="*[local-name() = $default-structural-containers][$divify-sections = 'yes']
                      |abstract
                      |verse-group" 
                mode="jats2html" priority="3">
    <xsl:element name="{if($xhtml-version eq '5.0' 
                           and not(local-name() = ('abstract', 'verse-group'))) 
                        then 'section' 
                        else 'div'}">
      <xsl:if test="tr:create-epub-type-attribute(.)">
        <xsl:attribute name="epub:type" select="tr:create-epub-type-attribute(.)"/>
      </xsl:if>
      <xsl:attribute name="class" select="string-join((name(), @book-part-type, @sec-type, @content-type), ' ')"/>
      <xsl:next-match/>
    </xsl:element>
  </xsl:template>
  
  <xsl:variable name="default-title-containers" as="xs:string+" select="('book-title-group', 'title-group')"/>
  
  <xsl:template match="*[local-name() = $default-title-containers]" 
                mode="jats2html" priority="3">
    <xsl:choose>
      <xsl:when test="$divify-title-groups = 'yes'">
        <div class="{local-name()}">
          <xsl:call-template name="css:content"/>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="node()" mode="#current"/>
      </xsl:otherwise>
    </xsl:choose>
   </xsl:template>
  
  <xsl:template match="*" mode="jats2html" priority="5">
    <xsl:param name="footnote-roots" as="element(*)*" tunnel="yes"/>
    <xsl:next-match/>
    <xsl:if test="exists(. intersect $footnote-roots)">
      <xsl:call-template name="jats2html:footnotes"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="jats2html:footnotes">
    <xsl:param name="recount-footnotes" as="xs:boolean?" tunnel="yes"/>
    <xsl:param name="static-footnotes" as="xs:boolean?" tunnel="yes"/>
    <xsl:param name="footnote-roots" as="element(*)*" tunnel="yes"/>
    <xsl:variable name="context" as="element(*)" select="."/>
    <xsl:variable name="footnotes" 
      select=".//fn[not(some $fnroot in ($footnote-roots intersect current()/descendant::*) 
                        satisfies (exists($fnroot/descendant::* intersect .))
                       )]" as="element(fn)*"/>
    <xsl:if test="exists($footnotes)">
      <div class="footnotes">
        <xsl:if test="$recount-footnotes">
          <xsl:processing-instruction name="recount" select="'yes'"/>
        </xsl:if>
        <!--<xsl:comment select="'ancestor: ', name(../..), '/', name(..),'/', name(), @*, '          ', count($footnote-roots intersect current()/descendant::*), ' ;; ',
          count(.//fn[some $fnr in ($footnote-roots intersect current()/descendant::*) 
                        satisfies (exists($fnr/descendant::* intersect .))]), for $f in .//fn return ('  :: ', $f/ancestor::*/name()), 
                        '  ++  ', $footnote-roots/name()"></xsl:comment>-->
        <xsl:apply-templates select="$footnotes" mode="footnotes"/>
      </div>  
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="book-meta/*[local-name()= ('book-id', 'isbn', 'permissions', 'book-volume-number', 'publisher')]" mode="jats2html">
    <div class="{local-name()}">
      <xsl:call-template name="css:content"/>
    </div>
  </xsl:template>
  
  <xsl:template match="book-back" mode="jats2html" priority="7">
    <xsl:variable name="available-index-types"  as="xs:string*" select="distinct-values(//index-term/@index-type)"/>
    <xsl:variable name="pre-rendered-index-types"  as="xs:string*" select="index/@index-type"/>
    <xsl:element name="{if($xhtml-version eq '5.0') then 'section' else 'div'}">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:attribute name="class" select="local-name()"/>
      <xsl:for-each select="$available-index-types[not(. = $pre-rendered-index-types)]">
        <xsl:call-template name="create-index">
          <xsl:with-param name="context" select="()" as="element()?"/>
          <xsl:with-param name="root" select="$root" as="document-node()"/>
          <xsl:with-param name="index-type" select="." as="xs:string"/>
        </xsl:call-template>
      </xsl:for-each>
      <xsl:apply-templates mode="#current"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="subtitle|aff" mode="jats2html">
    <p class="{local-name()}">
      <xsl:call-template name="css:content"/>
    </p>
  </xsl:template>
  
  <xsl:template match="bio | permissions" mode="jats2html" >
    <div class="{local-name()}">
      <xsl:call-template name="css:content"/>
    </div>      
  </xsl:template>
  
  <xsl:template match="copyright-holder
                      |copyright-statement
                      |copyright-year" mode="jats2html">
    <span class="{local-name()}">
      <xsl:call-template name="css:content"/>
    </span>
  </xsl:template>
  
  <xsl:template match="contrib/string-name" mode="jats2html">
    <p class="author">
      <xsl:call-template name="css:content"/>
    </p>
  </xsl:template>

  <!-- Default handler for the content of para-like and phrase-like elements,
    invoked by an xsl:next-match for the same matching elements. Don't forget 
    to include the names of the elements that you want to handle here. Otherwise
    they'll be reported as unhandled.
    And don’t ever change the priority unless you’ve made sure that no other template
    relies on this value to be 0.25.
    -->
  <xsl:template match="p
                      |array 
                      |abbrev
                      |table 
                      |contrib
                      |mixed-citation
                      |element-citation
                      |styled-content
                      |named-content
                      |italic
                      |bold
                      |monospace
                      |sc
                      |label
                      |private-char
                      |underline
                      |sub
                      |sup
                      |string-name
                      |verse-line
                      |verse-group
                      |surname
                      |given-names
                      |volume
                      |source
                      |year
                      |issue
                      |etal
                      |date
                      |string-date
                      |fpage
                      |lpage
                      |article-title
                      |chapter-title
                      |pub-id
                      |volume-series
                      |series
                      |person-group
                      |edition
                      |publisher-loc
                      |publisher-name
                      |edition
                      |comment
                      |role
                      |collab
                      |trans-title
                      |trans-source
                      |trans-subtitle
                      |subtitle
                      |comment
                      |contrib-id
                      |uri[not(@xlink:href)]
                      |speech
                      |boxed-text
                      |disp-formula-group
                      |disp-formula
                      |inline-formula
                      |prefix
                      |suffix" mode="jats2html" priority="-0.25">
    <xsl:call-template name="css:content"/>
  </xsl:template>
  
  <xsl:template name="css:other-atts">
    <!-- In the context of an element with CSSa attributes -->
    <xsl:apply-templates select="." mode="class-att"/>
    <xsl:call-template name="css:remaining-atts">
      <xsl:with-param name="remaining-atts" 
        select="@*[not(css:map-att-to-elt(., ..))]"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:function name="jats2html:strip-combining" as="xs:string">
    <xsl:param name="input" as="xs:string"/>
    <xsl:sequence select="replace(normalize-unicode($input, 'NFKD'), '\p{Mn}', '')"/>
  </xsl:function>
  
  <xsl:template match="*" mode="class-att"/>

  <xsl:template match="*[@content-type | @style-type]" mode="class-att">
    <xsl:apply-templates select="@content-type | @style-type" mode="#current"/>
  </xsl:template>

  <xsl:template match="*[name() = ('verse-line', 'fig')]" mode="class-att" priority="2">
    <xsl:variable name="att" as="attribute(class)?">
      <xsl:next-match/>
    </xsl:variable>
    <xsl:attribute name="class" select="string-join((name(), $att), ' ')"/>
  </xsl:template>

  <xsl:template match="mixed-citation|element-citation" mode="class-att" priority="2">
    <xsl:variable name="att" as="attribute(class)?">
      <xsl:next-match/>
    </xsl:variable>
    <xsl:attribute name="class" select="string-join((name(), @publication-type, $att), ' ')"/>
  </xsl:template>

  <xsl:template match="mixed-citation|element-citation" mode="jats2html" priority="3"> 
    <span>
      <xsl:next-match/>
    </span>
  </xsl:template>

  <xsl:variable name="jats2html:ignore-style-name-regex-x"
    select="'^(NormalParagraphStyle|Hyperlink)$'"
    as="xs:string"/>

  <xsl:template match="@content-type[not(../@style-type)] | @style-type" mode="class-att">
    <xsl:if test="not(matches(., $jats2html:ignore-style-name-regex-x, 'x'))">
      <xsl:attribute name="class" select="replace(., ':', '_')"/>  
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="title[not($divify-sections = 'yes')]" mode="class-att" priority="2">
    <xsl:attribute name="class" select="(parent::title-group[not(ends-with(../name(), 'meta'))],
                                         ancestor::*[ends-with(name(), 'meta')], 
                                         .)[1]/../
                                                 (name(), @book-part-type)[last()]"/>
  </xsl:template>
    
  <xsl:template match="label | speech | speaker" mode="class-att">
    <xsl:attribute name="class" select="name()"/>
  </xsl:template>
  
  <xsl:template match="@srcpath" mode="jats2html jats2html-create-title">
    <xsl:if test="$srcpaths eq 'yes'">
      <xsl:copy/>  
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="@id" mode="class-att jats2html">
    <xsl:copy/>
  </xsl:template>

  <xsl:template match="table[@id = ../@id]/@id" mode="jats2html"/>
  
  <xsl:template match="@css:*" mode="jats2html_DISABLED">
    <xsl:copy/>
  </xsl:template>
  
  <xsl:template match="@xml:lang" mode="jats2html">
    <xsl:attribute name="lang" select="."/>
  </xsl:template>
  
  <xsl:template match="@xml:base" mode="jats2html">
    <xsl:attribute name="xml:base" select="replace(. , '\.[a-z]+$', '.html')"/>
  </xsl:template>
  
  <!-- will be handled by class-att mode -->
  <xsl:template match="@content-type | @style-type | @specific-use" mode="jats2html"/>

  <xsl:template match="contrib-id" mode="jats2html">
    <span>
      <xsl:next-match/>
    </span>
  </xsl:template>

  <xsl:template match="break" mode="jats2html">
    <xsl:param name="in-toc" as="xs:boolean?"/>
    <xsl:if test="not($in-toc)">
      <br/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="break[ancestor::*[self::*:book-title]]" priority="2" mode="jats2html">
    <xsl:choose>
    <xsl:when test="preceding-sibling::node()[1]/(self::text()) and matches(preceding-sibling::node()[1], '\s$') or
      following-sibling::node()[1]/(self::text()) and matches(following-sibling::node()[1], '^\s')"/>
      <xsl:otherwise><xsl:text>&#160;</xsl:text></xsl:otherwise>
    </xsl:choose>
  </xsl:template>
     
  <xsl:template match="target
                      |milestone-start" mode="jats2html">
    <a class="{local-name()}" id="{(@id, generate-id())[1]}"/>
  </xsl:template>
  
  <xsl:template match="milestone-end" mode="jats2html">
    <a class="{local-name()}" href="#{(preceding::milestone-start[1]/@id, preceding::milestone-start[1]/generate-id())[1]}"/>
  </xsl:template>
  
  <xsl:template match="boxed-text[@content-type eq 'marginalia']" mode="jats2html">
    <div>
      <xsl:next-match/>
    </div>   
  </xsl:template>

  <xsl:template match="speech" mode="jats2html">
    <div>
      <xsl:call-template name="css:other-atts"/>
      <xsl:apply-templates select="p" mode="#current"/>
    </div>
  </xsl:template>
  
  <xsl:template match="speech/p" mode="jats2html">
    <p>
      <xsl:call-template name="css:other-atts"/>
      <xsl:apply-templates select="preceding-sibling::*[1]/self::speaker" mode="#current"/>
      <xsl:apply-templates select="node()" mode="#current"/>
    </p>   
  </xsl:template>
  
  <xsl:template match="speech/speaker" mode="jats2html">
    <span>
      <xsl:call-template name="css:content"/>
    </span>
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>
  
  <xsl:template match="*[p[@specific-use eq 'EpubAlternative']]" mode="epub-alternatives" priority="2">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*, title | info | p[@specific-use eq 'EpubAlternative']" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="permissions[preceding-sibling::*/p[@specific-use eq 'EpubAlternative']]" mode="epub-alternatives"
                priority="2"/>

  <xsl:template match="*[@specific-use eq 'EOnly']" mode="epub-alternatives" priority="2">
    <xsl:copy copy-namespaces="no">
        <xsl:apply-templates select="@*, title | info | node()" mode="#current"/> 
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*[@specific-use eq 'PrintOnly']" mode="epub-alternatives" priority="2"/>
  
  <xsl:template match="table-wrap[exists(descendant::*[self::p])][every $child in .//p satisfies ($child/@specific-use = 'PrintOnly')]" mode="epub-alternatives"/>
  <xsl:template match="disp-quote[exists(descendant::*[self::p])][every $child in * satisfies ($child/@specific-use = 'PrintOnly')]" mode="epub-alternatives"/>

  <xsl:template match="*[fn]" mode="jats2html" priority="1">
    <xsl:next-match/>
  </xsl:template>

  <xsl:template match="fn" mode="footnotes">
    <xsl:param name="footnote-ids" tunnel="yes" as="xs:string*"/>
    <xsl:param name="static-footnotes" tunnel="yes" as="xs:boolean?"/>
    <div class="{name()}" id="fn_{@id}">
      <span class="note-mark">
        <xsl:choose>
          <xsl:when test="$static-footnotes">
            <xsl:value-of select="index-of($footnote-ids, @id)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="footnote-link"/>
          </xsl:otherwise>
        </xsl:choose>
      </span>
      <xsl:apply-templates mode="jats2html"/>
    </div>
  </xsl:template>

  <xsl:template name="footnote-link">
    <xsl:param name="footnote-ids" as="xs:string*" tunnel="yes"/>
    <a href="#fna_{@id}" class="fn-link">
      <xsl:value-of select="index-of($footnote-ids, @id)"/>
    </a>
  </xsl:template>

  <xsl:template match="fn" mode="jats2html">
    <xsl:param name="footnote-ids" tunnel="yes" as="xs:string*"/>
    <xsl:param name="in-toc" tunnel="yes" as="xs:boolean?"/>
    <xsl:param name="recount-footnotes" tunnel="yes" as="xs:boolean?"/>
    <xsl:if test="not($in-toc)">
      <span class="note-anchor" id="fna_{@id}"><xsl:if test="$recount-footnotes"><xsl:processing-instruction name="recount" select="'yes'"/></xsl:if>
        <a href="#fn_{@id}" class="fn-ref">
          <sup>
            <xsl:value-of select="index-of($footnote-ids, @id)"/>
          </sup>
        </a>
      </span>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="fn-group" mode="jats2html" priority="2.5">
    <xsl:apply-templates select="@*, title" mode="#current"/>
    <xsl:call-template name="jats2html:footnotes">
      <xsl:with-param name="recount-footnotes" select="true()" as="xs:boolean?" tunnel="yes"/>
      <xsl:with-param name="footnote-ids" select=".//fn/@id" as="xs:string*" tunnel="yes"/>
      <xsl:with-param name="static-footnotes" select="true()" as="xs:boolean?" tunnel="yes"/>
    </xsl:call-template>
  </xsl:template>
 
  <xsl:template match="xref[starts-with(@rid, 'id_endnote')]" mode="jats2html" priority="5">
    <!-- endnote markers (from InDesign CC)-->
    <xsl:param name="in-toc" tunnel="yes" as="xs:boolean?"/>
    <xsl:if test="not($in-toc)">
      <sup>
        <xsl:next-match/>
      </sup>
    </xsl:if>
  </xsl:template>

  <xsl:template match="target[starts-with(@id, 'id_endnote-')][. is ../node()[1]]" mode="jats2html" priority="5">
    <!-- endnote paras (from InDesign CC)-->
      <xsl:next-match/>
      <span class="endnote-anchor">
        <a href="#id_endnoteAnchor-{replace(@id, '^id_endnote-', '')}">
          <sup>
            <xsl:value-of select="replace(@id, '^id_endnote-', '')"/>
          </sup>
        </a>
      </span>
  </xsl:template>

  <xsl:template match="*[html:p[html:span[@class = 'endnote-anchor']]]" mode="clean-up" priority="5">
    <!-- group endnote paras (from InDesign CC)-->
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:element name="div">
        <xsl:attribute name="class" select="'endnotes'"/>
        <xsl:for-each-group select="node()" group-starting-with="html:p[html:span[@class = 'endnote-anchor']]">
          <xsl:choose>
            <xsl:when test="current-group()[self::html:p[html:span[@class = 'endnote-anchor']]]">
              <xsl:element name="div">
                <xsl:attribute name="class" select="'en'"/>
                <xsl:apply-templates select="current-group()[1]/html:a[. is ../*[1]]/@id, current-group()" mode="#current"/>
              </xsl:element>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="current-group()" mode="#current"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each-group>
      </xsl:element>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="html:p[html:span[@class = 'endnote-anchor']]" mode="clean-up" priority="5">
    <xsl:apply-templates select="html:span[@class = 'endnote-anchor']" mode="#current"/>
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*, node() except (*[1][self::html:a], html:span[@class = 'endnote-anchor'])" mode="#current"/>
    </xsl:copy>
  </xsl:template>
      
	<xsl:template match="p[@specific-use = ('itemizedlist', 'orderedlist', 'variablelist')]" mode="jats2html">
    <xsl:apply-templates mode="#current">
      <xsl:with-param name="former-list-type" as="xs:string" select="@specific-use"/>
    </xsl:apply-templates>
  </xsl:template>
    
  <xsl:template match="def-list" mode="jats2html">
    <xsl:param name="former-list-type" as="xs:string?"/>
    <xsl:choose>
      <xsl:when test="($former-list-type = 'itemizedlist') 
                       and (every $term in def-item/term satisfies $term = def-item[1]/term)">
        <ul>
          <xsl:call-template name="css:content">
            <xsl:with-param name="discard-term" as="xs:boolean" select="if (normalize-space($former-list-type)) then true() else false()" tunnel="yes"/>
          </xsl:call-template>
        </ul>
      </xsl:when>
      <xsl:when test="($former-list-type = 'orderedlist') and (matches(def-item[1]/term, '^[1a]\.$'))">
        <ol>
          <xsl:call-template name="css:content">
            <xsl:with-param name="discard-term" as="xs:boolean" select="if (normalize-space($former-list-type)) then true() else false()" tunnel="yes"/>
          </xsl:call-template>
        </ol>
      </xsl:when>
      <xsl:otherwise>
        <dl>
          <xsl:call-template name="css:content"/>
        </dl>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
    
  <xsl:template match="def-item" mode="jats2html">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template match="def-item/term" mode="jats2html">
    <xsl:param name="discard-term" as="xs:boolean?" tunnel="yes"/>
  <xsl:if test="not($discard-term)">
      <dt>
        <xsl:copy-of select="../@id"/>
        <xsl:call-template name="css:content"/>
      </dt>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="def-item/def" mode="jats2html">
    <xsl:param name="discard-term" as="xs:boolean?" tunnel="yes"/>
    <xsl:element name="{if ($discard-term) then 'li' else 'dd'}">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="*:dd/*:label" mode="clean-up"/>
   
  
  <xsl:template match="list[matches(@list-type, '^(simple|ndash|bullet)$')]" mode="jats2html">
    <ul>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </ul>
  </xsl:template>
  
  <xsl:template match="list[matches(@list-type, '^(order|alpha|roman|alpha-lower|alpha-upper|roman-lower|roman-upper)$')]" mode="jats2html">
    <ol>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </ol>
  </xsl:template>
  
  <xsl:template match="list[@list-type eq 'custom'][list-item[label]]" mode="jats2html">
    <dl>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </dl>
  </xsl:template>
  
  <xsl:template match="list[@list-type eq 'custom']/list-item" mode="jats2html">
    <dt>
      <xsl:apply-templates select="label" mode="#current"/>
    </dt>
    <dd>
      <xsl:apply-templates select="@*, node() except label" mode="#current"/>
    </dd>
  </xsl:template>
  
  <xsl:template match="@list-type" mode="jats2html">
    <xsl:choose>
      <xsl:when test=". = 'order'"/>
      <xsl:when test=". = 'alpha-lower'"><xsl:attribute name="class" select="'lower-alpha'"/></xsl:when>
      <xsl:when test=". = 'alpha-upper'"><xsl:attribute name="class" select="'upper-alpha'"/></xsl:when>
      <xsl:when test=". = 'roman-lower'"><xsl:attribute name="class" select="'lower-roman'"/></xsl:when>
      <xsl:when test=". = 'roman-upper'"><xsl:attribute name="class" select="'upper-roman'"/></xsl:when>
      <xsl:otherwise><xsl:attribute name="class" select="."/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="list-item" mode="jats2html">
    <li>
      <xsl:call-template name="css:content"/>
    </li>
  </xsl:template>
  
  <xsl:template match="preformat" mode="jats2html">
    <pre>
      <xsl:call-template name="css:content"/>
    </pre>
  </xsl:template>
  
  <xsl:template match="code" mode="jats2html">
    <code>
      <xsl:call-template name="css:content"/>
    </code>
  </xsl:template>

  <xsl:template match="disp-quote" mode="jats2html">
    <blockquote>
      <xsl:call-template name="css:content"/>
    </blockquote>
  </xsl:template>
  
  <xsl:template match="attrib" mode="jats2html">
    <p class="{local-name()}">
      <xsl:call-template name="css:content"/>
    </p>
  </xsl:template>
  
  <!-- please note that <notes> can include notes 
       which may represent notes from editors or other notabilities
       and shouldn't be confused with general notes or footnotes, 
       although this element can appear notelessly in the regular content. -->
  
  <xsl:template match="notes" mode="jats2html">
    <div class="{local-name()}">
      <xsl:call-template name="css:content"/>
    </div>
  </xsl:template>
  
  <xsl:template match="front-matter/notes" mode="jats2html">
    <xsl:element name="{if($xhtml-version eq '5.0') then 'section' else 'div'}">
      <xsl:attribute name="class" select="local-name()"/>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="statement|question-wrap|question|answer|explanation" mode="jats2html">
    <div class="{local-name()}">
      <xsl:call-template name="css:content"/>
    </div>
  </xsl:template>
  
  <xsl:template match="option" mode="jats2html">
    <div class="{local-name(), if(@correct) then concat('correct-', @correct) else ()}">
      <xsl:call-template name="css:content"/>
    </div>
  </xsl:template>
  
  <xsl:template match="option/label" mode="jats2html">
    <div class="{local-name()}">
      <xsl:call-template name="css:content"/>
    </div>
  </xsl:template>
  
  <xsl:template match="fig" mode="jats2html">
    <xsl:element name="{if($xhtml-version eq '5.0') then 'figure' else 'div'}">
      <xsl:attribute name="class" select="string-join((name(), @book-part-type, @sec-type, @content-type), ' ')"/>  
      <xsl:call-template name="css:other-atts"/>  
      <xsl:apply-templates select="* except (label | caption | permissions), caption, permissions" mode="#current"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="fig/caption[$xhtml-version eq '5.0']
                      |graphic/caption[$xhtml-version eq '5.0']" mode="jats2html" priority="7">
    <figcaption>
      <xsl:attribute name="class" select="string-join((name(), @book-part-type, @sec-type, @content-type), ' ')"/>
      <xsl:call-template name="css:content"/>
    </figcaption>
  </xsl:template>
  
  <xsl:template match="caption" mode="jats2html">
    <div>
      <xsl:attribute name="class" select="string-join(
                                            (
                                              name(), 
                                              @book-part-type, @sec-type, @content-type, 
                                              if(normalize-space(title) = '') then 'empty-title' else ''
                                            )[. != ''],
                                            ' ')"/>
      <xsl:call-template name="css:content"/>
    </div>
  </xsl:template>
  
  <xsl:template match="fig/alternatives" mode="jats2html">
    <xsl:apply-templates select="(media, graphic, inline-graphic)[1]" mode="#current"/>
  </xsl:template>

  <xsl:template match="table-wrap|table-wrap-foot" mode="jats2html">
    <div class="{local-name()} {distinct-values(table/@content-type)}">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </div>
  </xsl:template>

  <!-- special case when alternative images is rendered for epub-->  
  <xsl:template match="table-wrap[alternatives]" mode="jats2html" priority="3">
    <div class="{local-name()} {distinct-values(table/@content-type)} alt-image">
      <xsl:apply-templates select="@*, node() except table" mode="#current"/>
    </div>
  </xsl:template>
  
  <xsl:template match="@preformat-type" mode="jats2html">
    <xsl:attribute name="class" select="."/>
  </xsl:template>
  
  <xsl:variable name="frontmatter-parts" as="xs:string+" 
                select="('title-page', 
                         'frontispiz', 
                         'copyright-page', 
                         'about-contrib', 
                         'about-book', 
                         'series', 
                         'additional-info')"/>
  
  <xsl:function name="tr:create-epub-type-attribute" as="attribute()?">
    <xsl:param name="context" as="element(*)"/>
    <xsl:choose>
      <xsl:when test="$context[self::*:pb]">
        <xsl:attribute name="epub:type" select="'pagebreak'"/>
      </xsl:when>
      <xsl:when test="$context[self::*:front-matter-part[@book-part-type]
                              [some $class in $frontmatter-parts 
                               satisfies matches($class, @book-part-type)]]">
        <xsl:choose>
          <xsl:when test="matches($context/@content-type, 'title-page')">
            <xsl:attribute name="epub:type" select="'fulltitle'"/>
          </xsl:when>
          <xsl:when test="matches($context/@content-type, 'copyright-page')">
            <xsl:attribute name="epub:type" select="'copyright-page'"/>
          </xsl:when>
          <!-- additional Info in title -->
          <xsl:when test="matches($context/@content-type, 'additional-info')">
            <xsl:attribute name="epub:type" select="'tr:additional-info'"/>
          </xsl:when>
          <xsl:when test="matches($context/@content-type, 'series')">
            <xsl:attribute name="epub:type" select="'tr:additional-info'"/>
          </xsl:when>
          <xsl:when test="matches($context/@content-type, 'about-book')">
            <xsl:attribute name="epub:type" select="'tr:about-the-book'"/>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$context[self::*:ack]">
        <xsl:attribute name="epub:type" select="'acknowledgements'"/>
      </xsl:when>
      <xsl:when test="$context[self::*:bio]">
        <xsl:attribute name="epub:type" select="'tr:bio'"/>
      </xsl:when>
      <xsl:when test="$context[self::*:ref-list]">
        <xsl:attribute name="epub:type" select="'bibliograpy'"/>
      </xsl:when>
      <xsl:when test="$context[self::*[local-name() = ('preface', 'foreword', 'dedication', 'glossary', 'index', 'index-term', 'toc')]]">
        <xsl:attribute name="epub:type" select="$context/local-name()"/>
      </xsl:when>
      <xsl:when test="$context[self::*:book-part[@book-part-type]]">
        <xsl:attribute name="epub:type" select="$context/@book-part-type"/>
      </xsl:when>
      <xsl:when test="$context[self::*:book-back[@book-part-type]]">
        <xsl:attribute name="epub:type" select="$context/@book-part-type"/>
      </xsl:when>
      <xsl:when test="$context[self::*:book-app]">
        <xsl:attribute name="epub:type" select="'appendix'"/>
      </xsl:when>
      <xsl:when test="$context[self::*:notes]">
        <xsl:attribute name="epub:type" select="'footnotes'"/>
      </xsl:when>
      <xsl:when test="$context[self::*:front-matter]">
        <xsl:attribute name="epub:type" select="'frontmatter'"/>
      </xsl:when>
      <xsl:when test="$context[self::*:book-body]">
        <xsl:attribute name="epub:type" select="'bodymatter'"/>
      </xsl:when>
      <xsl:when test="$context[self::*:book-back]">
        <xsl:attribute name="epub:type" select="'backmatter'"/>
      </xsl:when>
    </xsl:choose>
   </xsl:function>
  
  <xsl:variable name="jats2html:notoc-regex" as="xs:string" select="'_-_NOTOC'">
    <!-- Overwrite this regex in your adaptions to exclude titles containing this string in its content-type from being listed in the html toc -->
  </xsl:variable>
  
  <!-- if no toc element is given, you can also invoke this with <xsl:call-template name="toc"/> -->
  
  <xsl:template match="toc" name="toc" mode="jats2html">
    <xsl:variable name="headlines" as="element(title)*"
                  select="//title[parent::sec[not(ancestor::boxed-text)]
                                 |parent::title-group
                                 |parent::app
                                 |parent::ack
                                 |parent::index-title-group
                                 |parent::app-group
                                 |parent::ref-list
                                 |parent::glossary]
                                 [not(   ancestor::boxed-text 
                                      or ancestor::toc 
                                      or ancestor::collection-meta
                                      or ancestor::book-meta)]
                                 [jats2html:heading-level(.) le number((current()/@depth, 100)[1]) + 1]
                                 [not(matches(@content-type, $jats2html:notoc-regex))]"/>
    <xsl:variable name="headlines-by-level" as="element()*">
      <xsl:apply-templates select="$headlines" mode="toc"/>
    </xsl:variable>
    <xsl:element name="{if($xhtml-version eq '5.0') then 'nav' else 'div'}">
      <xsl:attribute name="class" select="'toc'"/>
      <xsl:if test="$xhtml-version eq '5.0'">
        <xsl:attribute name="epub:type" select="'toc'"/>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="exists(self::toc/* except title-group)">
          <!-- explicitly rendered toc -->
          <xsl:apply-templates mode="jats2html"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="title-group" mode="jats2html"/>
          <xsl:choose>
            <xsl:when test="$xhtml-version eq '5.0'">
              <xsl:variable name="max-level" select="max(for $i in $headlines return jats2html:heading-level($i))"/>
              <xsl:variable name="toc-as-tree">
                <xsl:sequence select="jats2html:flat-toc-to-tree($headlines-by-level, 1, $max-level)"/>
              </xsl:variable>
              <xsl:variable name="patched-toc">
                <xsl:apply-templates select="$toc-as-tree" mode="patch-toc-for-epub3"/>
              </xsl:variable>
              <xsl:sequence select="$patched-toc"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="$headlines-by-level"/>    
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="html:li[following-sibling::*[1][self::html:ol]]" mode="patch-toc-for-epub3">
    <xsl:variable name="next-ol" select="following-sibling::*[1][self::html:ol]" as="element(html:ol)"/>
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
      <xsl:if test="$next-ol">
        <ol>
          <xsl:apply-templates select="$next-ol/@*, $next-ol/html:*" mode="#current"/>
        </ol>  
      </xsl:if>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="html:ol" mode="patch-toc-for-epub3">
    <xsl:if test="not(preceding-sibling::*[1][self::html:li])">
      <xsl:copy>
        <xsl:apply-templates select="@*, node()" mode="#current"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="@*|*" mode="patch-toc-for-epub3">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:function name="jats2html:flat-toc-to-tree" as="element()*">
    <xsl:param name="seq" as="element()*"/>
    <xsl:param name="level" as="xs:integer"/>
    <xsl:param name="max" as="xs:integer"/>
    <xsl:sequence select="tr:flat-list-to-tree($seq, 
                                               $level, 
                                               $max, 
                                               QName('http://www.w3.org/1999/xhtml', 'ol'), 
                                               'class', 
                                               '[a-z]+')"/>
  </xsl:function>
    
  <xsl:template match="title" mode="toc">
    <xsl:element name="{if($xhtml-version eq '5.0') then 'li' else 'p'}">
      <xsl:attribute name="class" select="concat('toc', jats2html:heading-level(.))"/>
      <a href="#{(@id, generate-id())[1]}" class="toc-link">
        <xsl:if test="../label">
          <xsl:apply-templates select="../label/node()" mode="strip-indexterms-etc"/>
          <xsl:text>&#x2002;</xsl:text>
        </xsl:if>
        <xsl:apply-templates mode="jats2html">
          <xsl:with-param name="in-toc" select="true()" as="xs:boolean" tunnel="yes"/>
        </xsl:apply-templates>
      </a>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="ext-link" mode="jats2html" priority="3">
    <xsl:param name="in-toc" tunnel="yes" as="xs:boolean?"/>
    <xsl:choose>
      <xsl:when test="$in-toc">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-match/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="target[@id] | inline-graphic" mode="jats2html" priority="2">
    <xsl:param name="in-toc" as="xs:boolean?" tunnel="yes"/>
    <xsl:if test="not($in-toc)">
      <xsl:next-match/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="label[../title union ../caption/title]" mode="jats2html">
    <xsl:param name="actually-process-it" as="xs:boolean?"/>
    <xsl:if test="$actually-process-it">
      <span>
        <xsl:call-template name="css:content"/>
      </span>
      <xsl:apply-templates select="." mode="label-sep"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="label[named-content[@content-type = 'post-identifier']]
                            [../title union ../caption/title]" mode="jats2html" priority="3">
    <xsl:param name="actually-process-it" as="xs:boolean?"/>
    <xsl:if test="$actually-process-it">
      <xsl:apply-templates select="." mode="label-sep"/>
      <span>
        <xsl:call-template name="css:content"/>
      </span>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*[local-name() = ('h7', 'h8')]" mode="clean-up" priority="3">
    <xsl:element name="h6">
      <xsl:apply-templates select="@* except @class" mode="#current"/>
       <xsl:attribute name="class" select="concat(@class, ' ', local-name(current()))"/>
      <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:variable name="subtitle-separator-in-ncx" as="xs:string?" select="'&#x2002;'"/>

  <xsl:template match="title
                      |book-title
                      |article-title[ancestor::title-group]" mode="jats2html">
    <xsl:param name="in-toc" as="xs:boolean?" tunnel="yes"/>
    <xsl:variable name="level" select="jats2html:heading-level(.)" as="xs:integer?"/>
    <xsl:element name="{if ($level) then concat('h', $level) else 'p'}">
      <xsl:copy-of select="(../@id, parent::title-group/../../@id)[1][not($divify-sections = 'yes')]"/>
      <xsl:call-template name="css:other-atts"/>
      <xsl:variable name="label" as="element(label)?" 
                    select="(../label[not(named-content[@content-type = 'post-identifier'])], 
                             parent::caption/../label[not(named-content[@content-type = 'post-identifier'])]
                             )[1]"/>
      <xsl:variable name="post-label" as="element(label)?" 
                    select="(../label[named-content[@content-type = 'post-identifier']], 
                             parent::caption/../label[named-content[@content-type = 'post-identifier']]
                             )[1]"/>
      <xsl:attribute name="title">
        <xsl:apply-templates select="$label" mode="strip-indexterms-etc"/>
        <xsl:apply-templates select="$label" mode="label-sep"/>
        <xsl:variable name="stripped" as="text()">
          <xsl:value-of>
            <xsl:apply-templates mode="strip-indexterms-etc"/>
            <xsl:if test="$subtitles-in-titles = 'yes'">
              <xsl:if test="../subtitle[matches(., '\S')]">
                <xsl:value-of select="$subtitle-separator-in-ncx"/>
              </xsl:if>
              <xsl:apply-templates select="../subtitle/node()" mode="strip-indexterms-etc"/>
            </xsl:if>
          </xsl:value-of>
        </xsl:variable>
        <xsl:sequence select="replace($stripped, '^[\p{Zs}\s]*(.+?)[\p{Zs}\s]*$', '$1')"/>
        <xsl:if test="$post-label">
          <xsl:apply-templates select="$post-label" mode="label-sep"/>
          <xsl:apply-templates select="$post-label" mode="strip-indexterms-etc"/>
        </xsl:if>
      </xsl:attribute>
      <xsl:apply-templates select="$label" mode="#current">
        <xsl:with-param name="actually-process-it" select="true()"/>
      </xsl:apply-templates>
      <xsl:if test="not($in-toc)">
        <a id="{generate-id()}" />  
      </xsl:if>
      <xsl:apply-templates mode="#current"/>
      <xsl:apply-templates select="$post-label" mode="#current">
        <xsl:with-param name="actually-process-it" select="true()"/>
      </xsl:apply-templates>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="index-term | fn" mode="strip-indexterms-etc"/>
  
  <xsl:template match="html:a[@href]
                             [html:span[@class = 'indexterm']]" mode="clean-up">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:sequence select="node() except html:span[@class = 'indexterm']"/>
    </xsl:copy>
    <xsl:sequence select="html:span[@class = 'indexterm']"/>
  </xsl:template>
  
  <!-- Discard certain css markup on titles that would otherwise survive on paras: -->
  <xsl:template match="title/@css:*[matches(local-name(), '^(margin-|text-align)')]" mode="jats2html"/>
  
  <xsl:template match="table-wrap/label" mode="label-sep">
    <xsl:text>&#x2002;</xsl:text>
  </xsl:template>
  
  <xsl:template match="label" mode="label-sep">
    <xsl:text>&#x2002;</xsl:text>
  </xsl:template>
  
  <xsl:template match="contrib-group/contrib" mode="jats2html">
    <div>
      <xsl:next-match/>
    </div>
  </xsl:template>

  <xsl:template match="string-name" mode="jats2html">
    <span>
      <xsl:next-match/>
    </span>
  </xsl:template>
  
  <xsl:template match="p" mode="jats2html">
    <p>
      <xsl:next-match/>
    </p>
  </xsl:template>
  
  <xsl:template match="verse-line" mode="jats2html">
    <p>
      <xsl:next-match/>
    </p>
  </xsl:template>
  
  <xsl:template match="styled-content" mode="jats2html">
    <span>
      <xsl:next-match/>
    </span>
  </xsl:template>
  
  <xsl:template match="sup|sub" mode="jats2html">
    <xsl:element name="{name()}">
      <xsl:next-match/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="italic" mode="jats2html">
    <i>
      <xsl:next-match/>
    </i>
  </xsl:template>
  
  <xsl:template match="bold" mode="jats2html">
    <b>
      <xsl:next-match/>
    </b>
  </xsl:template>
  
  <xsl:template match="abbrev" mode="jats2html">
    <abbr>
      <xsl:next-match/>
    </abbr>
  </xsl:template>
  
  <xsl:template match="monospace|named-content|underline|sc|private-char|label" mode="jats2html">
    <span class="{local-name()}">
      <xsl:next-match/>
    </span>
  </xsl:template>
  
  <xsl:template match="underline" mode="hub2htm:css-style-overrides">
    <xsl:attribute name="css:text-decoration" select="'underline'"/>
  </xsl:template>
  
  <xsl:template match="monospace" mode="hub2htm:css-style-overrides">
    <xsl:attribute name="css:font-family" select="'monospace'"/>
  </xsl:template>
  
  <xsl:template match="sc" mode="hub2htm:css-style-overrides">
    <xsl:attribute name="css:font-variant" select="'small-caps'"/>
  </xsl:template>
  
  <xsl:template match="ref" mode="jats2html" priority="7">
    <p class="{name()}">
      <xsl:next-match/>
    </p>
  </xsl:template>

  <xsl:template match="ref[@id]/*[last()][$bib-backlink-type = 'letter']" mode="jats2html" priority="2">
    <xsl:variable name="ref-id" select="(parent::*/@id, generate-id(parent::*))[1]" as="xs:string"/>
    <xsl:next-match/>
    <xsl:text>&#x2002;</xsl:text>
    <xsl:for-each select="key('by-rid', parent::ref/@id)">
      <a href="#xref_{@id}" id="{$ref-id}">
        <xsl:number format="a" value="position()"/>
      </a>
      <xsl:if test="position() ne last()">
        <xsl:text xml:space="preserve">, </xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="ref" mode="jats2html" priority="1.5">
    <xsl:apply-templates select="(mixed-citation, element-citation)[1]" mode="#current"/>
  </xsl:template>

  <xsl:template match="surname
                      |given-names
                      |volume
                      |prefix
                      |suffix
                      |source
                      |year
                      |date
                      |etal
                      |issue
                      |string-date
                      |fpage
                      |lpage
                      |article-title
                      |chapter-title
                      |uri[not(@xlink:href)]
                      |pub-id
                      |volume-series
                      |series
                      |person-group
                      |edition
                      |publisher-loc
                      |publisher-name
                      |edition
                      |person-group
                      |role
                      |collab
                      |trans-title
                      |trans-source
                      |trans-subtitle
                      |comment
                      |kwd
                      |nested-kwd
                      |country" mode="jats2html"> 
    <span class="{local-name()}">
      <xsl:next-match/>
    </span> 
  </xsl:template>

  <xsl:template match="@person-group-type" mode="jats2html"/>

  <!--  *
        * index 
        * -->

  <!--  BITS can contain two ways markup an index:
        (1) There are index-terms embedded in the main body and we generate an index from these.
        (2) A list of index-entry elements already exists which is not linked. Most likely, you
            would just take these with their given order. -->
  
  <xsl:variable name="jats:index-symbol-heading"   as="xs:string"  select="$index-symbol-heading"/>
  <xsl:variable name="jats:index-generate-title"   as="xs:string"  select="$index-generate-title"/>
  <xsl:variable name="jats:index-fallback-title"   as="xs:string"  select="$index-fallback-title"/>
  <xsl:variable name="jats:index-heading-elt-name" as="xs:string"  select="$index-heading-elt-name"/>
  <xsl:variable name="jats:index-heading-class"    as="xs:string"  select="$index-heading-class"/>
  
  <!-- this template either renders an existing index 
       or is invoked with call-template to create a new index -->
  
  <xsl:template match="index" name="create-index" mode="jats2html">
    <xsl:param name="context" select="."              as="element()?"/>
    <xsl:param name="root" select="/"                 as="document-node()"/>
    <xsl:param name="index-type" select="@index-type" as="xs:string?"/>
    <xsl:element name="{if($xhtml-version eq '5.0') then 'section' else 'div'}">
      <xsl:variable name="index-type" select="$index-type" as="xs:string?"/>
      <xsl:attribute name="class" select="string-join(('index', $index-type), ' ')"/>
      <xsl:attribute name="epub:type" select="'index'"/>
      <!-- if a rendered index exists, we don't generate a new one from index-terms -->
      <xsl:choose>
        <xsl:when test="$context/index-entry">
          <xsl:call-template name="group-index-entries"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="$context/@*" mode="#current"/>
          <xsl:if test="$jats:index-generate-title">
            <xsl:call-template name="create-index-title-group">
              <xsl:with-param name="context" as="element(index-title-group)">
                <index-title-group xmlns="">
                  <title><xsl:value-of select="(concat(upper-case(substring($index-type, 1, 1)), substring($index-type, 2)),
                                                $jats:index-fallback-title)[1]"/></title>
                </index-title-group>
              </xsl:with-param>
              <xsl:with-param name="root" select="$root" as="document-node()" tunnel="yes"/>
            </xsl:call-template>
          </xsl:if>
          <xsl:for-each-group select="$root//index-term[not(parent::index-term)]
                                                       [if(@index-type) then @index-type eq $index-type else true()]"
                              group-by="if (matches(substring(jats2html:strip-combining((@sort-key, term)[1]), 1, 1), 
                                                    '[A-z\p{IsLatin-1Supplement}]')) 
                                        then substring(jats2html:strip-combining((@sort-key, term)[1]), 1, 1) 
                                        else '0'"
                              collation="http://saxon.sf.net/collation?lang={($root/*/@xml:lang, 'de')[1]};strength=primary">
            <xsl:sort select="current-grouping-key()" 
                      collation="http://saxon.sf.net/collation?lang={($root/*/@xml:lang, 'de')[1]};strength=primary"/>
            <xsl:element name="{$jats:index-heading-elt-name}">
              <xsl:attribute name="class" select="$jats:index-heading-class"/>
              <xsl:value-of select="if (matches(current-grouping-key(), '[A-z\p{IsLatin-1Supplement}]') and current-grouping-key() ne '0') 
                                    then upper-case(current-grouping-key()) 
                                    else $jats:index-symbol-heading"/>
            </xsl:element>
            <xsl:call-template name="group-index-terms">
              <xsl:with-param name="level" select="1"/>
              <xsl:with-param name="index-terms" select="current-group()"/>
            </xsl:call-template>
          </xsl:for-each-group>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="index-title-group" name="create-index-title-group" mode="jats2html">
    <xsl:param name="context" select="." as="element(index-title-group)"/>
    <xsl:apply-templates select="$context/node()" mode="jats2html"/>
  </xsl:template>
  
  <xsl:template name="group-index-entries">
    <xsl:for-each-group select="index-entry|index-title-group" group-adjacent="local-name()">
      <xsl:choose>
        <xsl:when test="current-grouping-key() eq 'index-entry'">
          <ul class="index-entry-list" epub:type="index-entry-list">
            <xsl:for-each select="current-group()">
              <li class="index-entry" epub:type="index-entry">          
                <xsl:apply-templates mode="rendered-index-entry"/>
              </li>
            </xsl:for-each>
          </ul>
        </xsl:when>
        <xsl:when test="current-grouping-key() eq 'index-title-group'">
          <xsl:apply-templates select="current-group()" mode="#current"/>
        </xsl:when>
      </xsl:choose>
    </xsl:for-each-group>
  </xsl:template>
  
  <xsl:template match="term" mode="rendered-index-entry">
    <span class="indexterm" epub:type="index-term">
      <xsl:apply-templates mode="jats2html"/>
    </span>
  </xsl:template>
  
  <xsl:template name="group-index-terms">
    <xsl:param name="level" as="xs:integer"/>
    <xsl:param name="index-terms" as="element(index-term)*"/>
    <!-- §§§ We need to know a book’s main language! -->
    <xsl:if test="count($index-terms) gt 0">
      <ul class="index-entry-list" epub:type="index-entry-list">
        <xsl:for-each-group select="$index-terms" group-by="(@sort-key, term)[1]"
                            collation="http://saxon.sf.net/collation?lang={(/*/@xml:lang, 'de')[1]};strength=identical">
          <xsl:sort select="current-grouping-key()" collation="http://saxon.sf.net/collation?lang={(/*/@xml:lang, 'de')[1]};strength=primary"/>
          <xsl:sort select="current-grouping-key()" collation="http://saxon.sf.net/collation?lang={(/*/@xml:lang, 'de')[1]};strength=identical"/>
          <xsl:call-template name="index-entry">
            <xsl:with-param name="level" select="$level"/>
          </xsl:call-template>
        </xsl:for-each-group>
      </ul>  
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="index-entry">
    <xsl:param name="level" as="xs:integer"/>
    <li class="ie ie{$level}" epub:type="index-entry">
      <span class="index-term" epub:type="index-term">
        <xsl:value-of select="current-group()[1]/term"/>
      </span>
      <xsl:text>&#x2002;</xsl:text>
      <xsl:for-each select="current-group()[exists(index-term | see)
                                            or
                                            jats2html:contains-token(@content-type, 'hub:not-placed-on-page')]">
        <a id="ie_{@id}"/>
      </xsl:for-each>
      <xsl:for-each select="current-group()[empty(index-term | see)]
                                           [not(jats2html:contains-token(@content-type, 'hub:not-placed-on-page'))]">
        <a href="#it_{@id}" id="ie_{@id}" class="index-link" epub:type="index-locator">
          <xsl:value-of select="position()"/>
        </a>
        <xsl:if test="position() ne last()">
          <xsl:text xml:space="preserve">, </xsl:text>
        </xsl:if>
      </xsl:for-each>
      <xsl:for-each-group select="current-group()//see" group-by="string(.)">
        <xsl:value-of select="if($root/*/@xml:lang = 'de') then ' siehe ' else ' see '" xml:space="preserve"/>
        <xsl:call-template name="potentiallly-link-to-see-target"/>
        <xsl:if test="not(position() = last())">
          <xsl:text>;</xsl:text>
        </xsl:if>
      </xsl:for-each-group>
      <xsl:if test="current-group()//see and current-group()//see-also">
        <xsl:text xml:space="preserve">;</xsl:text>
      </xsl:if>
      <xsl:for-each-group select="current-group()//see-also" group-by="string(.)">
        <xsl:value-of select="if($root/*/@xml:lang = 'de') then ' siehe auch ' else ' see also'" xml:space="preserve"/>
        <xsl:call-template name="potentiallly-link-to-see-target"/>
        <xsl:if test="not(position() = last())">
          <xsl:text>;</xsl:text>
        </xsl:if>
      </xsl:for-each-group>
      <xsl:call-template name="group-index-terms">
        <xsl:with-param name="index-terms" select="current-group()/index-term"/>
        <xsl:with-param name="level" select="$level + 1"/>
      </xsl:call-template>
    </li>
  </xsl:template>

  <xsl:key name="jats2html:by-indext-term" match="index-term" 
    use="term, string-join((parent::index-term/term, term), ', ')"/>
  
  <xsl:template name="potentiallly-link-to-see-target">
    <xsl:param name="root" as="document-node()" tunnel="yes"/>
    <!-- Context: see or see-also -->
    <xsl:variable name="target" as="element(index-term)?"
      select="(key('by-id', @id, $root)/self::index-term,
               key('jats2html:by-indext-term', concat(., ' (', ../term, ')'), $root),
               key('jats2html:by-indext-term', ., $root))[1]"/>
    <xsl:choose>
      <xsl:when test="exists($target)">
        <a href="#ie_{$target/@id}">
          <xsl:value-of select="."/>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <xsl:template match="index-term[empty(parent::index-term)]
                                 [empty(see)]" mode="jats2html">
    <xsl:param name="in-toc" as="xs:boolean?" tunnel="yes"/>
    <xsl:if test="not($in-toc)">
      <span class="indexterm" id="it_{descendant-or-self::index-term[last()]/@id}">
        <xsl:attribute name="title">
          <xsl:apply-templates mode="#current"/>
        </xsl:attribute>
        <xsl:if test="$index-backlink-type = ('text-and-number', 'number')">
          <a href="#ie_{descendant-or-self::index-term[last()]/@id}" class="it">
            <span class="it"/>
            <xsl:if test="$index-backlink-type = ('text-and-number')">
              <xsl:text xml:space="preserve"> </xsl:text>
              <xsl:apply-templates mode="#current"/>
            </xsl:if>
          </a>
        </xsl:if>
        <!--<xsl:text xml:space="preserve"> </xsl:text>
        <a href="#ie_{descendant-or-self::index-term[last()]/@id}" class="it"/>-->
      </span>
    </xsl:if>
  </xsl:template>

  <xsl:template match="index-term[empty(parent::index-term)]
                                 [exists(see)]" mode="jats2html"/>

  <!-- <index-term-range-end> is a marker to specify the range of an index-term.
       Its @rid must match the @id of a previous <index-term>. -->
  
  <xsl:template match="index-term-range-end" mode="jats2html">
    <a class="{local-name()}" id="{@rid}"/>
  </xsl:template>
  
  <!-- for index terms -->
  <xsl:template match="html:span[@class eq 'it']" mode="clean-up">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:text>(</xsl:text>
      <xsl:value-of select="key('by-id', substring-after(../@href, '#'))"/>
      <xsl:text>)</xsl:text>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="index-term/term" mode="jats2html">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template match="index-term[parent::index-term]" mode="jats2html">
    <xsl:text xml:space="preserve">, </xsl:text>
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="see" mode="jats2html">
    <xsl:value-of select="if($root/*/@xml:lang = 'de') then ' siehe ' else ' see '" xml:space="preserve"/>
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="see-also" mode="jats2html">
    <xsl:value-of select="if($root/*/@xml:lang = 'de') then ' siehe auch ' else ' see also '" xml:space="preserve"/>
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:variable name="block-element-names" as="xs:string+" 
                select="'boxed-text',
                        'def-list',
                        'disp-formula',
                        'disp-formula-group',
                        'fig',
                        'list',
                        'table-wrap'"/>

  <xsl:template match="p[*[local-name() = $block-element-names]]" mode="jats2html" priority="1.2">
    <xsl:for-each-group select="node()" 
                        group-adjacent="boolean(self::*[local-name() = $block-element-names])">
      <xsl:choose>
        <xsl:when test="current-grouping-key()">
          <xsl:apply-templates select="current-group()" mode="#current"/>
        </xsl:when>
        <xsl:when test="every $item in current-group() 
                        satisfies ($item/self::text()[not(normalize-space())])"/>
        <xsl:otherwise>
          <xsl:element name="{name(..)}">
            <xsl:for-each select="..">
              <xsl:call-template name="css:other-atts"/>
            </xsl:for-each>
            <xsl:apply-templates select="current-group()" mode="#current"/>
          </xsl:element>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each-group>
  </xsl:template>
  
  <xsl:template match="boxed-text" mode="jats2html">
    <xsl:choose>
      <xsl:when test="alternatives">
        <!-- If alternative images for the box have been defined only those will be displayed -->
        <div class="box {@content-type} alt-image">
          <xsl:apply-templates select="alternatives" mode="#current"/>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <div class="box {@content-type}">
          <xsl:apply-templates select="@* except @content-type, node()" mode="#current"/>
        </div>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- graphics -->
  
  <xsl:template match="graphic | inline-graphic" mode="jats2html">
    <img alt="{(alt-text, replace((@xlink:title, @xlink:href)[1], '^(.+)/([^/]+)$', '$2'))[1]}">
      <xsl:apply-templates select="@srcpath, @xlink:href" mode="#current"/>
      <xsl:apply-templates select="." mode="class-att"/>
    </img>
    <xsl:apply-templates select="* except alt-text" mode="#current"/>
  </xsl:template>
  
  <xsl:template match="graphic[caption and not(parent::fig)][$xhtml-version eq '5.0']" mode="jats2html" priority="5">
    <figure class="{local-name()}">
      <xsl:next-match/>
    </figure>
  </xsl:template>
  
  <xsl:template match="alt-text" mode="jats2html"/>

  <xsl:template match="*[local-name() = ('graphic', 'inline-graphic')]/@xlink:href" mode="jats2html">
    <xsl:attribute name="src" select="."/>
  </xsl:template>

  <xsl:template match="graphic/@css:*" mode="jats2html"/>

  <xsl:template match="*[local-name() = ('graphic', 'inline-graphic')]/@*[name() = ('css:width', 'css:height')]"
    mode="hub2htm:css-style-overrides"/>

  <xsl:template match="graphic/attrib" mode="jats2html"/>
  
  <!-- media -->
  
  <xsl:template match="media" mode="jats2html">
    <xsl:variable name="media-type" as="xs:string"
                  select="if(matches(@mimetype, '^audio')) then 'audio' else 'video'" />
    <xsl:element name="{$media-type}">
      <source src="{@xlink:href}" type="{@mimetype}"/>
      <xsl:apply-templates select="alt-text, long-desc" mode="#current"/>
      <xsl:value-of select="concat('Your browser or device does not support ', $media-type)"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="object-id" mode="jats2html">
    <a class="{string-join((local-name(), 
                            for $i in @*[not(local-name() = 'id')] 
                            return concat($i/local-name(), '__', $i)
                            ), ' ')}" 
       title="{normalize-space(.)}">
      <xsl:apply-templates select="@id" mode="#current"/>
    </a>
  </xsl:template>
  
  <!-- formulas -->
  
  <xsl:template match="disp-formula-group|disp-formula" mode="jats2html">
    <div class="{local-name()}">
      <xsl:next-match/>
    </div>
  </xsl:template>
  
  <xsl:template match="inline-formula" mode="jats2html">
    <span class="{name()}">
      <xsl:apply-templates select="@srcpath, node()" mode="#current"/>
    </span>
  </xsl:template>
  
  <xsl:template match="disp-formula/alternatives
                      |inline-formula/alternatives" mode="jats2html">
    <span class="{local-name()}">
      <xsl:apply-templates select="@*, (mml:math, tex-math, media, (graphic|inline-graphic))[1]" mode="#current"/>  
    </span>
  </xsl:template>
  
  <xsl:template match="mml:math" mode="jats2html">
    <xsl:variable name="altimg" as="attribute(xlink:href)?"
                  select="parent::alternatives/*[local-name() = ('graphic', 'inline-graphic')]/@xlink:href"/>
    <xsl:element name="{local-name()}" namespace="http://www.w3.org/1998/Math/MathML">
      <!-- Unlike HTML, EPUB 3.0 requires an alttext attribute. -->
      <xsl:attribute name="alttext">
        <xsl:if test="tr:unwrap-mml-boolean(.)">
          <xsl:apply-templates mode="unwrap-mml"/>
        </xsl:if>
      </xsl:attribute>
      <xsl:if test="$altimg">
        <xsl:attribute name="altimg" select="$altimg"/>
      </xsl:if>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:element>
  </xsl:template>
  
  <!-- strip ns prefix, mathjax and some browsers have issues with xml namespaces -->
  
  <xsl:template match="mml:*" mode="jats2html">
    <xsl:element name="{local-name()}" namespace="http://www.w3.org/1998/Math/MathML">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="table-wrap/alternatives[graphic]
                      |boxed-text/alternatives[graphic]" mode="jats2html" priority="2">
    <xsl:for-each select="graphic">
      <img>
        <xsl:attribute name="class" select="local-name()"/>
        <xsl:attribute name="src" select="@xlink:href"/>
        <xsl:attribute name="alt" select="concat('Alternative image for table ', @xlink:href)"/>
        <xsl:apply-templates select="@srcpath" mode="#current"/>
      </img>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="tex-math" mode="jats2html">
    <xsl:element name="{if(ancestor::disp-formula) then 'div' else 'span'}">
      <xsl:attribute name="class" select="local-name()"/>
      <xsl:apply-templates select="@srcpath" mode="#current"/>
    </xsl:element>
  </xsl:template>
  
  <!-- tables -->
  
  <xsl:template match="tr 
                      |tbody
                      |thead
                      |tfoot
                      |td
                      |th
                      |colgroup
                      |col
                      |table[not(matches(@css:width, 'pt$'))]" mode="jats2html">
    <xsl:element name="{local-name()}" exclude-result-prefixes="#all">
      <xsl:call-template name="css:content"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="array" mode="jats2html">
    <table class="{local-name()}">
      <xsl:call-template name="css:content"/>
    </table>
  </xsl:template>

  <xsl:template match="*[name() = ('table', 'array')][matches(@css:width, 'pt$')]" mode="jats2html">
    <xsl:variable name="conditional-percent-widths" as="element(*)">
      <xsl:apply-templates select="." mode="table-widths"/>
    </xsl:variable>
    <xsl:apply-templates select="$conditional-percent-widths" mode="#current">
      <xsl:with-param name="root" select="root(.)" as="document-node()" tunnel="yes"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <!-- There should always be @css:width. @width is only decorational (will be valuable just in case 
    all @css:* will be stripped -->
  <xsl:template match="@width" mode="jats2html"/>

  <xsl:template match="*[name() = ('table', 'array')][@css:width]" mode="table-widths">
    <xsl:variable name="twips" select="tr:length-to-unitless-twip(@css:width)" as="xs:double?"/>
    <xsl:choose>
      <xsl:when test="$twips">
        <table xmlns="">
          <xsl:if test="local-name() eq 'array'">
            <xsl:attribute name="class" select="'array'"/>
          </xsl:if>
          <xsl:apply-templates select="@*, node()" mode="#current">
            <xsl:with-param name="table-twips" select="$twips" tunnel="yes"/>
            <xsl:with-param name="table-percentage" select="jats2html:table-width-grid($twips, $page-width-twips)" tunnel="yes"/>
          </xsl:apply-templates>
        </table>
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-match/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>  
  
  <xsl:template match="*[name() = ('table', 'array')]/@css:width" mode="table-widths">
    <xsl:param name="table-twips" as="xs:double?" tunnel="yes"/>
    <xsl:param name="table-percentage" as="xs:integer?" tunnel="yes"/>
    <xsl:choose>
      <xsl:when test="not($table-twips) or not($table-percentage)">
        <xsl:copy/>
      </xsl:when>
      <xsl:when test="$table-percentage eq 0">
        <xsl:copy/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="css:width" select="concat($table-percentage, '%')"/>    
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="  *[name() = ('table', 'array')][not(col | colgroup)][@css:width]/*/tr/*/@css:width
                       | *[name() = ('table', 'array')][exists(col | colgroup)][@css:width]//col/@width" mode="table-widths">
    <xsl:param name="table-twips" as="xs:double?" tunnel="yes"/>
    <xsl:param name="table-percentage" as="xs:integer?" tunnel="yes"/>
    <xsl:choose>
      <xsl:when test="not($table-twips) or not($table-percentage)">
        <xsl:attribute name="css:width" select="."/>
      </xsl:when>
      <xsl:when test="$table-percentage eq 0">
        <xsl:attribute name="css:width" select="."/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="css:width" 
          select="concat(string(xs:integer(1000 * (tr:length-to-unitless-twip(.) div $table-twips)) * 0.1), '%')"/>    
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="*[name() = ('table', 'array')][exists(col | colgroup)]/*/tr/*/@css:width" mode="table-widths"/>
    
  <!-- will be discarded -->
  <xsl:variable name="jats2html:masterpageobjects-para-regex" select="'tr_(pagenumber|columntitle)'" as="xs:string"/>
  
  <xsl:template match="*[matches(@role, $jats2html:masterpageobjects-para-regex)]" mode="jats2html"/>

  <xsl:template match="@colspan | @rowspan" mode="jats2html">
    <xsl:copy/>
  </xsl:template>
  
  <xsl:template match="ext-link|uri[@xlink:href]" mode="jats2html">
    <a>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
      <xsl:if test="not(node())">
        <xsl:value-of select="@xlink:href"/>
      </xsl:if>
    </a>
  </xsl:template>

  <xsl:template match="@xlink:href" mode="jats2html">
    <xsl:attribute name="{if (contains(../name(), 'graphic')) then 'src' else 'href'}" 
                   select="if ($rr and matches(., '^\.\./'))
                           then resolve-uri(., resolve-uri($rr))
                           else tr:escape-html-uri(.)"/>
  </xsl:template>
  
  <xsl:template match="@ext-link-type" mode="jats2html"/>
  
  <xsl:template match="@xlink:type" mode="jats2html"/>

  <xsl:key name="by-id" match="*[@id]" use="@id"/>
  <xsl:key name="by-rid" match="*[@rid]" use="@rid"/>
  <xsl:key name="rule-by-name" match="css:rule" use="@name"/> 
  
  <xsl:variable name="root" select="/" as="document-node()"/>
  
  <!--<xsl:template match="xref" mode="jats2html">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>-->

  <xsl:template match="xref" mode="jats2html">
    <xsl:param name="in-toc" as="xs:boolean?" tunnel="yes"/>
    <xsl:variable name="linked-items" as="element(linked-item)*">
      <xsl:apply-templates select="key('by-id', tokenize(@rid, '\s+'), $root)" mode="linked-item"/>
    </xsl:variable>
    <xsl:variable name="xref-id" select="(@id, generate-id())[1]" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="node()">
        <!-- explicit referring text -->
        <xsl:choose>
          <xsl:when test="$in-toc">
            <xsl:apply-templates mode="#current"/>
          </xsl:when>
          <xsl:when test="count($linked-items) eq 1">
            <a href="#{$linked-items[1]/@id}">
              <xsl:if test="@id">
                <!-- in some cases an xref does not have an @id, so we will not create dulicate @id="xref_" attributes -->
                <xsl:attribute name="id" select="concat('xref_', @id)"/>  
              </xsl:if>
              <xsl:apply-templates select="@srcpath, node()" mode="#current"/>
            </a>
            <xsl:if test="$linked-items[1]/@ref-type = 'ref' and $bib-backlink-type = 'letter'"><!-- bibliography entry -->
              <span class="cit">
                <xsl:apply-templates select="@srcpath" mode="#current"/>
                <xsl:text>[</xsl:text>
                <xsl:number format="a" value="index-of(for $xr in key('by-rid', @rid, $root) return $xr/@id, @id)"/>
                <xsl:text>]</xsl:text>
              </span>
            </xsl:if>
          </xsl:when>
          <xsl:when test="count($linked-items) eq 0">
            <a>
              <xsl:apply-templates select="@srcpath" mode="#current"/>
            </a>
            <xsl:apply-templates mode="#current"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message>Cannot link: multiple resolutions for xref with an explicit link text. <xsl:copy-of select="."/></xsl:message>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <!-- generate referring text -->
        <a>
          <xsl:apply-templates select="@srcpath" mode="#current"/>
        </a>
        <xsl:call-template name="render-rids">
          <xsl:with-param name="linked-items" select="$linked-items"/>
          <xsl:with-param name="in-toc" select="$in-toc" tunnel="yes"/>
          <xsl:with-param name="xref-id" select="$xref-id" tunnel="yes"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="render-rids">
    <xsl:param name="linked-items" as="element(linked-item)*"/>
    <xsl:param name="xref-id" as="xs:string" tunnel="yes"/>
    <xsl:variable name="grouped-items" as="element(linked-items)" xmlns="">
      <linked-items>
        <xsl:for-each-group select="$linked-items" group-by="@ref-type">
          <ref-type-group type="{current-grouping-key()}">
            <xsl:for-each-group select="current-group()" group-adjacent="jats2html:link-rendering-type(., ('label', 'number', 'title', 'teaser'))">
              <rendering type="{current-grouping-key()}">
                <xsl:variable name="context" select="." as="element(*)"/>
                <xsl:for-each select="current-group()/(@* | *)[name() = current-grouping-key()]">
                  <item id="{$context/@id}" xref-id="{$xref-id}">
                    <xsl:apply-templates select="." mode="render-xref"/>
                  </item>
                </xsl:for-each>
              </rendering>
            </xsl:for-each-group>  
          </ref-type-group>
        </xsl:for-each-group>
      </linked-items>
    </xsl:variable>
    <xsl:apply-templates select="$grouped-items" mode="render-xref"/>
  </xsl:template>

  <xsl:function name="jats2html:ref-type" as="xs:string">
    <xsl:param name="elt" as="element(*)"/>
    <xsl:choose>
      <xsl:when test="$elt/self::book-part">
        <xsl:sequence select="($elt/@book-part-type, $elt/name())[1]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$elt/name()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>


  <!-- Example:
       <linked-item number="4.2" label="Figure 4.2.">
         <title>Title, potentially including markup. If there is an alt-title[@alt-title-type eq 'xref'], it should be used</title>
         <teaser>The beginning of the contents, without index terms and footnotes</teaser>
       </linked-item>
  -->
  <xsl:template match="*" mode="linked-item" xmlns="">
    <linked-item>
      <xsl:copy-of select="@id"/>
      <xsl:attribute name="ref-type" select="jats2html:ref-type(.)"/>
      <xsl:variable name="title-container" as="element(*)">
        <xsl:choose>
          <xsl:when test="self::book-part">
            <xsl:sequence select="book-part-meta/title-group"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="."/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:for-each select="$title-container/alt-title[@alt-title-type eq 'number']">
        <xsl:attribute name="number" select="."/>
      </xsl:for-each>
      <xsl:for-each select="$title-container/label">
        <xsl:attribute name="label" select="."/>
      </xsl:for-each>
      <xsl:apply-templates select="($title-container/(title, alt-title[@alt-title-type eq 'xref']))[last()]" mode="#current"/>
      <teaser>
        <xsl:apply-templates mode="render-xref"/>
      </teaser>
    </linked-item>
  </xsl:template>
  
  <xsl:template match="title | alt-title[@alt-title-type eq 'xref']" mode="linked-item" xmlns="">
    <title>
      <xsl:apply-templates mode="render-xref"/>
    </title>
  </xsl:template>
  
  <xsl:function name="jats2html:link-rendering-type" as="xs:string">
    <xsl:param name="elt" as="element(linked-item)"/>
    <!-- preference: sequence of 'number', 'title', 'label', 'teaser' --> 
    <xsl:param name="preference" as="xs:string*"/>
    <xsl:sequence select="(for $p in $preference return $elt/(@* | *)[name() eq $p]/name(), '')[1]"/>
  </xsl:function>

  <xsl:template match="linked-items | ref-type-group" mode="render-xref">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="ref-type-group[@type = ('sec', 'part', 'chapter')]/rendering[@type = ('title', 'number')]" mode="render-xref">
    <xsl:value-of select="key('l10n-string', if(count(item) gt 1) then ../@type else concat(../@type, 's'), $l10n)"/>
    <xsl:text>&#xa;</xsl:text>
    <xsl:for-each select="item">
      <xsl:apply-templates select="." mode="#current"/>
      <xsl:if test="position() lt last()">
        <xsl:text xml:space="preserve">, </xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="ref-type-group/rendering/item" mode="render-xref">
    <xsl:param name="in-toc" as="xs:boolean?" tunnel="yes"/>
    <xsl:choose>
      <xsl:when test="$in-toc">
        <xsl:apply-templates mode="#current"/>
      </xsl:when>
      <xsl:otherwise>
        <a href="#{@id}" id="xref_{@xref-id}">
          <xsl:apply-templates mode="#current"/>
        </a>    
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:function name="jats2html:is-book-part-like" as="xs:boolean">
    <xsl:param name="elt" as="element(*)"/>
    <!-- add more: -->
    <xsl:sequence select="$elt/local-name() = ('toc', 
                                               'book-part', 
                                               'preface', 
                                               'foreword', 
                                               'dedication', 
                                               'front-matter-part',
                                               'book-app')"/>
  </xsl:function>
  
  <xsl:function name="jats2html:heading-level" as="xs:integer?">
    <xsl:param name="elt" as="element(*)"/>
    <xsl:choose>
      <xsl:when test="$elt/ancestor::table-wrap"/>
      <xsl:when test="$elt/ancestor::verse-group"/>
      <xsl:when test="$elt/ancestor::fig"/>
      <xsl:when test="$elt/parent::book-title-group">
        <xsl:sequence select="1"/>
      </xsl:when>
      <xsl:when test="$elt/parent::title-group
                   or $elt/parent::index
                   or $elt/parent::index-title-group
                   or $elt/parent::fn-group">
        <xsl:sequence select="2"/>
      </xsl:when>
      <xsl:when test="$elt/parent::sec[ancestor::boxed-text]">
        <xsl:sequence select="count($elt/ancestor::*[ancestor::boxed-text]) + 3"/>
      </xsl:when>
      <xsl:when test="$elt/parent::abstract
                   or $elt/parent::trans-abstract
                   or $elt/parent::ack
                   or $elt/parent::app
                   or $elt/parent::app-group 
                   or $elt/parent::bio
                   or $elt/parent::glossary
                   or $elt/parent::sec
                   or $elt/parent::ref-list
                   or $elt/parent::statement">
        <xsl:variable name="ancestor-title" select="$elt/../../(title
                                                               |(. | ../book-part-meta)/title-group/title)" as="element(title)?"/>
        <xsl:variable name="heading-level" select="if(exists($ancestor-title))
                                                   then jats2html:heading-level($ancestor-title) + 1
                                                   else ()" as="xs:integer?"/>
        <xsl:sequence select="((if($heading-level gt 6) then 6 else $heading-level), 2)[1]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>No heading level for <xsl:copy-of select="$elt/.."/></xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="jats2html:table-width-grid" as="xs:integer">
    <!-- returns 0, 50, or 100. It should be interpreted and used as a width
      percentage, except when it’s 0. Then the original widths should be kept. -->
    <xsl:param name="page-width-twip" as="xs:double"/>
    <xsl:param name="object-width-twip" as="xs:double"/>
    <xsl:choose>
      <xsl:when test="$object-width-twip gt 0.75 * $page-width-twip">
        <xsl:sequence select="100"/>
      </xsl:when>
      <xsl:when test="$object-width-twip gt 0.4 * $page-width-twip">
        <xsl:sequence select="50"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="0"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!-- map alignment to CSS -->
  <xsl:template match="@valign" mode="hub2htm:css-style-overrides">
    <xsl:attribute name="css:vertical-align" select="."/>
  </xsl:template>

  <xsl:template match="@align" mode="hub2htm:css-style-overrides">
    <xsl:attribute name="css:text-align" select="."/>
  </xsl:template>
  
  <!-- if you want to omit metadata in your output, set the param $render-metadata to 'no' -->
  
  <xsl:template match="front" mode="jats2html" priority="5">
    <h1>
      <xsl:value-of select="article-meta/article-id" separator=" "/>
    </h1>
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <!--  *
        * JATS/BITS metadata for <head> section
        * -->
  
  <!-- override this template in your importing stylesheet if you don't 
       want to enrich the HTML head with additional meta tags -->
  
  <xsl:template name="create-meta-tags">
    <xsl:apply-templates select="(collection-meta, book-meta)
                                |(front/journal-meta, front/article-meta)" mode="jats2html-create-meta-tags"/>
  </xsl:template>
  
  <xsl:template match="collection-meta|book-meta|journal-meta|article-meta" mode="jats2html-create-meta-tags">
    <xsl:apply-templates select="*" mode="jats2html-create-meta-tags"/>
  </xsl:template>
  
  <xsl:template match="pub-date[@publication-format]" mode="jats2html-create-meta-tags">
    <meta name="{concat(local-name(), '-', @publication-format)}" content="{concat(year, '-', month, '-', day)}"/>
  </xsl:template>
  
  <xsl:template match="pub-date[not(@publication-format)]" mode="jats2html-create-meta-tags">
    <meta name="{local-name()}" content="{concat(year, '-', month, '-', day)}"/>
  </xsl:template>
  
  <xsl:template match="*[local-name() = ('issn', 'issn-l')][@publication-format]" mode="jats2html-create-meta-tags">
    <meta name="{concat(local-name(), '-', @publication-format)}" content="{.}"/>
  </xsl:template>
  
  <xsl:template match="*[local-name() = ('issn', 'issn-l')][not(@publication-format)]" mode="jats2html-create-meta-tags">
    <meta name="{local-name()}" content="{.}"/>
  </xsl:template>
  
  <!-- Dublin Core metadata -->
  
  <xsl:template match="collection-meta/title-group/title
                      |collection-meta/title-group/subtitle
                      |book-title-group/book-title
                      |book-title-group/subtitle
                      |title-group/article-title
                      |title-group/subtitle
                      |trans-title-group/trans-title
                      |trans-title-group/trans-subtitle" mode="jats2html-create-meta-tags">
    <meta name="DCTERMS.title" content="{.}" />
  </xsl:template>
  
  <xsl:template match="publisher-name" mode="jats2html-create-meta-tags">
    <meta name="DCTERMS.publisher" content="{.}" />
  </xsl:template>
  
  <xsl:template match="contrib" mode="jats2html-create-meta-tags">
    <meta name="DCTERMS.contributor" content="{(string-name, 
                                                string-join((name/surname, name/given-names), ' '))[1]}" />
  </xsl:template>
  
  <xsl:template match="abstract|trans-abstract" mode="jats2html-create-meta-tags">
    <meta name="DCTERMS.abstract" content="{.}" />
  </xsl:template>
  
  <xsl:template match="subject" mode="jats2html-create-meta-tags">
    <meta name="DCTERMS.subject" content="{.}" />
  </xsl:template>
  
  <xsl:template match="isbn" mode="jats2html-create-meta-tags" priority="1">
    <meta name="DCTERMS.identifier" content="{.}"/>
  </xsl:template>
  
  <xsl:template match="article-id[@pub-id-type eq 'doi']
                      |book-id[@book-id-type eq 'doi']" mode="jats2html-create-meta-tags">
    <meta name="DCTERMS.identifier" content="{.}"/> 
  </xsl:template>
  
  <xsl:template match="article-categories" mode="jats2html-create-meta-tags">
    <meta name="DCTERMS.type" content="{.}"/> 
  </xsl:template>
  
  <xsl:template match="copyright-statement" mode="jats2html-create-meta-tags">
    <meta name="DCTERMS.rights" content="{.}"/>
  </xsl:template>
  
  <xsl:template match="copyright-year" mode="jats2html-create-meta-tags"/>
  
  <xsl:template match="copyright-holder" mode="jats2html-create-meta-tags">
    <meta name="DCTERMS.holder" content="{.}"/>
  </xsl:template>
  
  <xsl:template match="license" mode="jats2html-create-meta-tags">
    <xsl:apply-templates select="@xlink:href, @license-type, *" mode="#current"/>
  </xsl:template>
  
  <xsl:template match="license-p" mode="jats2html-create-meta-tags">
    <meta name="DCTERMS.license" content="{.}"/>
  </xsl:template>
  
  <xsl:template match="license/@xlink:href" mode="jats2html-create-meta-tags">
    <meta name="DCTERMS.license" content="{.}"/>
  </xsl:template>
  
  <xsl:template match="license/@license-type" mode="jats2html-create-meta-tags">
    <meta name="DCTERMS.accessRights" content="{.}"/>
  </xsl:template>
  
  <!-- drop metadata which is not applicable for meta tags -->
  
  <xsl:template match="aff
                      |aff-alternatives
                      |author-notes
                      |conference
                      |counts
                      |custom-meta-group
                      |funding-group
                      |history
                      |kwd-group
                      |notes
                      |supplementary-material
                      |x" mode="jats2html-create-meta-tags"/>
  
  <!-- default handler for meta-tags -->
  
  <xsl:template match="*" mode="jats2html-create-meta-tags" priority="-1">
    <xsl:choose>
      <xsl:when test="*">
        <xsl:apply-templates select="*" mode="#current"/>    
      </xsl:when>
      <xsl:when test="@xlink:href">
        <link rel="{concat(parent::*/local-name(), '-', local-name())}" href="{@xlink:href}"/>
      </xsl:when>
      <xsl:when test="text()">
        <meta name="{concat(parent::*/local-name(), '-', local-name())}" content="{.}"/>    
      </xsl:when>
      <xsl:otherwise>
        <xsl:message select="'jats2html: unmapped element:', local-name()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!--  *
        * JATS/BITS metadata to be rendered in <body>s
        * -->
  
  <!-- resolve metadata wrappers -->
  
  <xsl:template name="render-metadata-sections">
    <xsl:apply-templates select="collection-meta
                                |book-meta
                                |book-part-meta
                                |front/journal-meta
                                |front/article-meta" mode="jats2html-render-metadata"/>
  </xsl:template>
  
  <xsl:template match="collection-meta
                      |book-meta
                      |book-part-meta
                      |journal-meta
                      |article-meta" mode="jats2html-render-metadata">
    <div class="{local-name()} jats-meta">
      <xsl:apply-templates select="@*, *" mode="#current"/>
    </div>
  </xsl:template>
  
  <!-- default handler for rendering all metadata -->
  
  <xsl:template match="*" mode="jats2html-render-metadata" priority="-1">
    <div class="{local-name()} jats-meta">
      <xsl:choose>
        <xsl:when test="*">
          <xsl:apply-templates select="@*, node()" mode="#current"/>
        </xsl:when>
        <xsl:when test="text()">
          <span class="{local-name()} jats-meta-name">
            <xsl:value-of select="local-name()"/>
          </span>
          <xsl:text>&#x20;</xsl:text>
          <span class="{local-name()} jats-meta-value">
            <xsl:apply-templates mode="#current"/>
          </span>
        </xsl:when>
        <xsl:when test="not(text()) and @*">
          <div class="{local-name()} jats-meta-attlist">
            <xsl:for-each select="@*">
              <span class="{local-name()} jats-meta-attname">
                <xsl:value-of select="."/>
              </span>
              <span class="{local-name()} jats-meta-attvalue">
                <xsl:value-of select="."/>
              </span>
            </xsl:for-each>  
          </div>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates mode="#current"/>
        </xsl:otherwise>
      </xsl:choose>  
    </div>
  </xsl:template>
  
  <!--  *
        * render content metadata
        * -->
  
  <xsl:template match="collection-meta/title-group
                      |book-title-group" mode="jats2html-create-title">
    <div class="{local-name()}">
      <h1 class="{if(self::book-title-group) then 'book-title' else 'collection-title'}">
        <xsl:apply-templates select="@*, label, title, book-title" mode="#current"/>
      </h1>
      <xsl:apply-templates select="* except (label|title|book-title)" mode="#current"/>
    </div>
  </xsl:template>
  
  <xsl:template match="subtitle" mode="jats2html-create-title">
    <h2 class="{if(ancestor::collection-meta) then 'collection-subtitle' else local-name()}">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </h2>
  </xsl:template>
  
  <xsl:template match="trans-title-group/title
                      |trans-title-group/trans-title" mode="jats2html-create-title">
    <h3 class="{local-name()}">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </h3>
  </xsl:template>
  
  <xsl:template match="trans-title-group/subtitle
                      |trans-title-group/trans-subtitle" mode="jats2html-create-title">
    <h4 class="{local-name()}">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </h4>
  </xsl:template>
  
  <xsl:template match="alt-title" mode="jats2html-create-title">
    <h5 class="{local-name()}">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </h5>
  </xsl:template>
  
  <xsl:template match="contrib-group" mode="jats2html-create-title">
    <div class="{local-name()}">
      <xsl:for-each-group select="contrib" group-by="@contrib-type">
        <xsl:sort select="jats2html:sort-contrib(current-grouping-key())"/>
        <div class="{current-grouping-key()}">
          <xsl:apply-templates select="current-group()" mode="#current"/>
        </div>
      </xsl:for-each-group>
      <xsl:apply-templates select="* except contrib" mode="#current"/>
    </div>
  </xsl:template>
  
  <xsl:function name="jats2html:sort-contrib" as="xs:integer">
    <xsl:param name="contrib-type" as="xs:string?"/>
    <xsl:sequence select="     if(matches($contrib-type, 'editor', 'i')) then 2 
                          else if(matches($contrib-type, 'author', 'i')) then 1
                          else 0"/>
  </xsl:function>
  
  <xsl:template match="contrib" mode="jats2html-create-title">
    <div class="{concat(local-name(), ' ', @contrib-type)}">
      <xsl:apply-templates select="anonymous, (string-name, name)[1]" mode="#current"/>
      <xsl:apply-templates select="xref" mode="#current"/>
    </div>
  </xsl:template>
  
  <xsl:template match="contrib/xref" mode="jats2html-create-title">
    <xsl:variable name="ref" select="@rid" as="attribute(rid)"/>
    <xsl:variable name="aff" select="ancestor::contrib-group/aff[@id eq $ref]" as="element(aff)?"/>
    <xsl:if test="$aff">
      <p class="aff">
        <span class="{local-name()}">
          <xsl:apply-templates select="@*, $aff" mode="#current"/>  
        </span>
      </p>  
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="aff" mode="jats2html-create-title">
    <xsl:analyze-string select="string-join(.//text(), '')" regex="([,;])">
      <xsl:matching-substring>
        <xsl:value-of select="regex-group(1)"/><br/>
      </xsl:matching-substring>
      <xsl:non-matching-substring>
        <xsl:value-of select="."/>
      </xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:template>
  
  <xsl:template match="name" mode="jats2html-create-title">
    <p class="{local-name()}">
      <xsl:apply-templates select="@*, given-names" mode="#current"/>
      <xsl:text>&#xa;</xsl:text>
      <xsl:apply-templates select="surname" mode="#current"/>
    </p>
  </xsl:template>
  
  <xsl:template match="abstract|trans-abstract" mode="jats2html-create-title">
    <div class="{local-name()}">
      <xsl:apply-templates select="@*, node()" mode="jats2html"/>      
    </div>
  </xsl:template>
  
  <xsl:template match="volume-in-collection" mode="jats2html-create-title">
    <p class="{local-name()}">
      <xsl:apply-templates select="volume-title" mode="jats2html-create-title"/>
      <xsl:text>&#xa;</xsl:text>
      <xsl:apply-templates select="volume-number" mode="jats2html-create-title"/>
    </p>
  </xsl:template>
  
  <xsl:template match="publisher-name" mode="jats2html-create-title">
    <p class="{local-name()}">
      <xsl:apply-templates select="@*, node()" mode="jats2html"/>
    </p>
  </xsl:template>
  
  <!-- default handler for creating simple divs and spans with *[@class eq local-name()]-->
  
  <xsl:template match="award-group
                      |funding-group
                      |funding-source
                      |funding-statement
                      |fn-group
                      |funding-group
                      |publisher
                      |string-name
                      |trans-title-group" mode="jats2html-create-title">
    <div class="{local-name()}">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </div>
  </xsl:template>
  
  <xsl:template match="collection-meta/title-group/title
                      |book-title-group/book-title
                      |collection-meta/title-group/label
                      |book-title-group/label
                      |anonymous
                      |given-names
                      |surname
                      |volume-title
                      |volume-number" mode="jats2html-create-title">
    <span class="{local-name()}">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </span>
  </xsl:template>
  
  <xsl:template match="isbn|issn|issn-l" mode="jats2html-create-title">
    <div class="{local-name()}">
      <xsl:apply-templates select="@*" mode="#current"/>
      <span class="{local-name()}-name">
        <xsl:value-of select="upper-case(local-name())"/>
      </span>
      <xsl:text>&#xa;</xsl:text>
      <span class="{local-name()}-value">
        <xsl:apply-templates mode="#current"/>
      </span>
    </div>
  </xsl:template>
  
  <!-- Drop stuff that is mentioned already in the metadata. Override this if you want to render this -->
  
  <xsl:template match="award-id
                      |collection-id
                      |book-id
                      |orcid-id
                      |funding-id
                      |subj-group
                      |object-id
                      |pub-date
                      |notes
                      |kwd-group
                      |funding-source/award-group" mode="jats2html-create-title"/>
  
  <!-- drop all attributes which are not matched by other templates -->
  
  <xsl:template match="@*" mode="jats2html-create-title"/>

  <xsl:function name="jats2html:contains-token" as="xs:boolean">
    <xsl:param name="string" as="xs:string?"/>
    <xsl:param name="token" as="xs:string"/>
    <xsl:sequence select="tokenize($string, '\s+') = $token"/>
  </xsl:function>
</xsl:stylesheet>
