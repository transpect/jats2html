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

  <xsl:param name="debug" select="'yes'"/>
  <xsl:param name="debug-dir-uri" select="'debug'"/>
  <xsl:param name="srcpaths" select="'no'"/>

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

  <xsl:param name="divify-sections" select="'no'"/>
  <xsl:param name="divify-title-groups" select="'no'"/>
  <!-- Resolve Relative links to the parent directory against the following URI
       (for example, the source XML directory's URL in the code repository),
       empty string or unset param if no resolution required: -->
  <xsl:param name="rr" select="'doc/'"/>
  <!-- convention: if empty string, then concat($common-path, '/css/stylesheet.css') -->
  <xsl:param name="css-location" select="''"/>
  <!-- for calculating whether a table covers the whole width or only part of it: -->
  <xsl:param name="page-width" select="if (/book/book-meta/custom-meta-group/meta-name[. = 'type-area-width']) then concat(((/book/book-meta/custom-meta-group/meta-name[. = 'type-area-width']/meta-value) * 0.3527), 'mm') else '180mm'"/>
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
  
  <xsl:output method="xhtml" indent="no" 
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
    doctype-public="-//W3C//DTD XHTML 1.0//EN" 
    saxon:suppress-indentation="p li h1 h2 h3 h4 h5 h6 th td dd dt"/>
  
  <xsl:output method="xml" indent="yes" name="debug" exclude-result-prefixes="#all"/>

  <xsl:param name="lang" select="(/*/@xml:lang, 'en')[1]" as="xs:string"/>
  
  <xsl:variable name="l10n" select="document(concat('../l10n/l10n.', ($lang, 'en')[1], '.xml'))"
    as="document-node(element(l10n:l10n))"/>

  <xsl:key name="l10n-string" match="l10n:string" use="@id"/>

  <xsl:variable name="epub-alternatives">
    <xsl:apply-templates select="/" mode="epub-alternatives"/>
  </xsl:variable>
  
  <xsl:variable name="jats2html">
    <xsl:apply-templates select="$epub-alternatives" mode="jats2html"/>
  </xsl:variable>
  
  <xsl:variable name="clean-up">
    <xsl:apply-templates select="$jats2html" mode="clean-up"/>
  </xsl:variable>

  <xsl:template name="main">
    <xsl:sequence select="$clean-up"/>
  </xsl:template>
  
  <xsl:template match="* | @*" mode="expand-css clean-up table-widths epub-alternatives">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@* | node()" mode="#current" />  
    </xsl:copy>
  </xsl:template>
  
  <!-- collateral. Otherwise the generated IDs might differ due to temporary trees / variables 
    when transforming the content -->  
  <xsl:template match="index-term | xref | fn" mode="epub-alternatives">
    <xsl:copy copy-namespaces="no">
      <xsl:attribute name="id" select="generate-id()"/>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="html:span[not(@*)]" mode="clean-up">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template match="*" mode="jats2html" priority="-1">
    <xsl:if test="$debug eq 'yes'">
      <xsl:message>jats2html: unhandled: <xsl:apply-templates select="." mode="css:unhandled"/></xsl:message>
    </xsl:if>
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" mode="#current" />  
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="@*" mode="jats2html">
    <xsl:if test="$debug eq 'yes'">
      <xsl:message>jats2html: unhandled attr: <xsl:apply-templates select="." mode="css:unhandled"/></xsl:message>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="@dtd-version" mode="jats2html" />
  
  <xsl:template match="/*" mode="jats2html">
    <html>
      <xsl:apply-templates select="@xml:lang" mode="#current"/>
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
        <xsl:for-each select="$paths">
          <link rel="stylesheet" type="text/css" href="{concat(., 'css/overrides.css')}"/>
        </xsl:for-each>
        <title>
          <xsl:apply-templates select="book-meta/book-title-group/book-title/node() | front/article-meta/title-group/article-title/node()"
            mode="#current">
            <!-- suppress replicated target with id: -->
            <xsl:with-param name="in-toc" select="true()" tunnel="yes"/>
          </xsl:apply-templates>
        </title>
        <xsl:apply-templates select=".//custom-meta-group/css:rules" mode="hub2htm:css"/>
      </head>
      <body>
        <xsl:apply-templates mode="#current">
          <xsl:with-param name="footnote-ids" select="//fn/@id" as="xs:string*" tunnel="yes"/>
        </xsl:apply-templates>
      </body>
    </html>
  </xsl:template>
  
  <xsl:template match="book-meta | book-part-meta | journal-meta | article-meta" mode="jats2html">
    <xsl:call-template name="render-metadata-sections"/>
    <!-- to overwrite it more easily -->
  </xsl:template>
  
  <xsl:template name="render-metadata-sections">
    <div class="title">
      <xsl:apply-templates select="@srcpath, * except (custom-meta-group | abstract | contrib-group), contrib-group/contrib" mode="#current"/>
    </div>
    <xsl:apply-templates select="contrib-group/bio" mode="#current"/>
    <xsl:apply-templates select="abstract" mode="#current"/>
  </xsl:template>
  
  
  <xsl:variable name="default-structural-containers" as="xs:string+"
    select="('book-part', 'body', 'book-body', 'front-matter', 'front-matter-part', 'book-back', 'back', 'sec', 'ack', 'app', 'ref-list', 'dedication', 'foreword', 'preface', 'contrib-group')"/>
  
  <xsl:template match="*[name() = $default-structural-containers]" 
                mode="jats2html" priority="2">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <!-- everything that goes into a div (except footnote-like content): -->
  <xsl:template match="*[name() = $default-structural-containers][$divify-sections = 'yes']
    | fig | caption | abstract | verse-group | app | glossary" 
    mode="jats2html" priority="3">
    <div class="{string-join((name(), @book-part-type, @sec-type, @content-type), ' ')}">
      <xsl:next-match/>
    </div>
  </xsl:template>
  
  <xsl:variable name="default-title-containers" as="xs:string+" select="('book-title-group', 'title-group')"/>
  
  <xsl:template match="*[name() = $default-title-containers]" 
                 mode="jats2html" priority="3">
    <xsl:choose>
      <xsl:when test="$divify-title-groups = 'yes'">
        <div class="{name()}">
          <xsl:call-template name="css:content"/>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="node()" mode="#current"/>
      </xsl:otherwise>
    </xsl:choose>
   </xsl:template>
  
  <xsl:template match="body[not(descendant::body)] | named-book-part-body | app[not(ancestor::app-group)] | app-group | glossary" mode="jats2html" priority="1.5">
    <xsl:choose>
      <xsl:when test="$divify-sections = 'yes'">
        <div class="{name()}">
          <xsl:apply-templates mode="#current"/>
        </div>
        <xsl:call-template name="jats2html:footnotes"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="#current"/>
        <xsl:call-template name="jats2html:footnotes"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="jats2html:footnotes">
    <xsl:variable name="footnotes" select=".//fn" as="element(fn)*"/>
    <xsl:if test="$footnotes">
      <div class="notes">
        <xsl:apply-templates select="$footnotes" mode="notes"/>
      </div>  
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="book-meta/*[local-name()= ('book-id', 'isbn', 'permissions', 'book-volume-number', 'publisher')]" mode="jats2html">
    <div class="{local-name()}">
      <xsl:call-template name="css:content"/>
    </div>
  </xsl:template>
  
  <xsl:template match="subtitle | aff" mode="jats2html">
    <p class="{local-name()}">
      <xsl:call-template name="css:content"/>
    </p>
  </xsl:template>
  
  <xsl:template match="bio | permissions" mode="jats2html" >
    <div class="{name()}">
      <xsl:call-template name="css:content"/>
    </div>      
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
  <xsl:template match="p | array | table | caption | ref | mixed-citation | copyright-statement | styled-content | named-content|  italic | bold |
    underline | sub | sup | verse-line | verse-group | copyright-statement | surname | given-names | volume | source | year | issue | etal |
    date | string-date | fpage | lpage | article-title | chapter-title | pub-id | volume-series | series | person-group | edition | publisher-loc |
    publisher-name | edition | comment | role | collab | trans-title | trans-source | trans-subtitle | subtitle | comment | contrib-id |
    speech | boxed-text | prefix | suffix" mode="jats2html" priority="-0.25" >
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

  <xsl:template match="mixed-citation" mode="class-att" priority="2">
    <xsl:variable name="att" as="attribute(class)?">
      <xsl:next-match/>
    </xsl:variable>
    <xsl:attribute name="class" select="string-join((name(), @publication-type, $att), ' ')"/>
  </xsl:template>

  <xsl:template match="mixed-citation" mode="jats2html" priority="2"> 
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
  
  <xsl:template match="@srcpath" mode="jats2html">
    <xsl:if test="$srcpaths eq 'yes'">
      <xsl:copy/>  
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="@id" mode="class-att jats2html">
    <xsl:copy/>
  </xsl:template>

  <xsl:template match="table[@id = ../@id]/@id" mode="jats2html"/>
  
  <xsl:template match="@css:* | @xml:lang" mode="jats2html_DISABLED">
    <xsl:copy/>
  </xsl:template>
  
  <xsl:template match="@xml:lang" mode="jats2html">
    <xsl:if test="not(. = ancestor::*[@xml:lang][1]/@xml:lang)">
      <xsl:copy/>
      <xsl:attribute name="lang" select="."/>
    </xsl:if>
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
     
  <xsl:template match="target[@id]" mode="jats2html">
    <a id="{@id}"/>
  </xsl:template>
  
  <xsl:template match="boxed-text[@content-type eq 'marginalia']" mode="jats2html">
    <div>
      <xsl:next-match/>
    </div>   
  </xsl:template>

  <xsl:template match="speech" mode="jats2html">
    <div>
      <xsl:call-template name="css:other-atts"/>
      <xsl:apply-templates select="p"/>
    </div>
  </xsl:template>
  
  <xsl:template match="speech/p" mode="jats2html">
    <p>
      <xsl:call-template name="css:other-atts"/>
      <xsl:apply-templates select="preceding-sibling::*[1]/self::speaker" mode="#current"/>
      <xsl:apply-templates mode="#current"/>
    </p>   
  </xsl:template>
  
  <xsl:template match="speech/speaker" mode="jats2html">
    <span>
      <xsl:next-match/>
    </span>   
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


  <xsl:template match="*[fn]" mode="jats2html">
    <xsl:next-match/>
  </xsl:template>

  <xsl:template match="*" mode="notes">
    <xsl:param name="footnote-ids" tunnel="yes" as="xs:string*"/>
    <div class="{name()}" id="fn_{@id}">
      <span class="note-mark">
        <a href="#fna_{@id}">
          <sup>
            <xsl:value-of select="index-of($footnote-ids, @id)"/>
          </sup>
        </a>
      </span>
      <xsl:apply-templates mode="jats2html"/>
    </div>
  </xsl:template>

  <xsl:template match="fn" mode="jats2html">
    <xsl:param name="footnote-ids" tunnel="yes" as="xs:string*"/>
    <xsl:param name="in-toc" tunnel="yes" as="xs:boolean?"/>
    <xsl:if test="not($in-toc)">
      <span class="note-anchor" id="fna_{@id}">
        <a href="#fn_{@id}">
          <sup>
            <xsl:value-of select="index-of($footnote-ids, @id)"/>
          </sup>
        </a>
      </span>
    </xsl:if>
  </xsl:template>
 
  <xsl:template match="p[@specific-use = ('itemizedlist', 'orderedlist')]" mode="jats2html">
    <xsl:apply-templates mode="#current">
      <xsl:with-param name="former-list-type" as="xs:string" select="@specific-use"/>
    </xsl:apply-templates>
  </xsl:template>
    
  <xsl:template match="def-list" mode="jats2html">
    <xsl:param name="former-list-type" as="xs:string?"/>
    <xsl:choose>
      <xsl:when test="($former-list-type = 'itemizedlist') and (every $term in def-item/term satisfies $term = def-item[1]/term)">
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
   
  
  <xsl:template match="list[@list-type eq 'bullet']" mode="jats2html">
    <ul>
      <xsl:apply-templates mode="#current"/>
    </ul>
  </xsl:template>
  
  <xsl:template match="list[matches(@list-type, '^(order|alpha|roman)')]" mode="jats2html">
    <ol>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </ol>
  </xsl:template>
  
  <xsl:template match="@list-type" mode="jats2html">
    <xsl:choose>
      <xsl:when test=". = 'order'"/>
      <xsl:when test=". = 'alpha-lower'"><xsl:attribute name="class" select="'lower-alpha'"/></xsl:when>
      <xsl:when test=". = 'alpha-upper'"><xsl:attribute name="class" select="'upper-alpha'"/></xsl:when>
      <xsl:when test=". = 'roman-lower'"><xsl:attribute name="class" select="'lower-roman'"/></xsl:when>
      <xsl:when test=". = 'roman-upper'"><xsl:attribute name="class" select="'upper-roman'"/></xsl:when>
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

  <xsl:template match="disp-quote" mode="jats2html">
    <blockquote>
      <xsl:call-template name="css:content"/>
    </blockquote>
  </xsl:template>
  
  <xsl:template match="fig" mode="jats2html">
    <div>
      <xsl:call-template name="css:other-atts"/>
      <xsl:apply-templates select="* except (label | caption | permissions), caption, permissions" mode="#current"/>
    </div>
  </xsl:template>

  <xsl:template match="table-wrap | table-wrap-foot" mode="jats2html">
    <div class="{local-name()} {string(table/@content-type)}">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </div>
  </xsl:template>


<!-- special case when alternative images is rendered for epub-->  
  <xsl:template match="table-wrap[alternatives]" mode="jats2html" priority="3">
    <div class="{local-name()} {string(table/@content-type)} alt-image">
      <xsl:apply-templates select="@*, node() except table" mode="#current"/>
    </div>
  </xsl:template>
  
  <xsl:template match="@preformat-type" mode="jats2html">
    <xsl:attribute name="class" select="."/>
  </xsl:template>
  
  <xsl:variable name="frontmatter-parts" as="xs:string+" select="('title-page', 'frontispiz', 'copyright-page', 'about-contrib', 'about-book', 'series', 'additional-info')"/>
  
  <xsl:function name="tr:create-epub-type-attribute" as="attribute()?">
    <xsl:param name="context" as="element(*)"/>
    <xsl:choose>
      <xsl:when test="$context[self::*:pb]">
        <xsl:attribute name="epub:type" select="'pagebreak'"/>
      </xsl:when>
      <xsl:when test="$context[self::*:front-matter-part[@book-part-type][some $class in $frontmatter-parts satisfies matches($class, @book-part-type)]]">
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
      <xsl:when test="$context[self::*[local-name() = ('preface', 'foreword', 'dedication', 'glossary', 'index', 'toc')]]">
        <xsl:attribute name="epub:type" select="$context/local-name()"/>
      </xsl:when>
      <xsl:when test="$context[self::*:book-part[@book-part-type]]">
        <xsl:attribute name="epub:type" select="$context/@book-part-type"/>
      </xsl:when>
      <xsl:when test="$context[self::*:book-back[@book-part-type]]">
        <xsl:attribute name="epub:type" select="$context/@book-part-type"/>
      </xsl:when>
      <xsl:when test="$context[self::*:notes]">
        <xsl:attribute name="epub:type" select="'footnotes'"/>
      </xsl:when>
    </xsl:choose>
   </xsl:function>
  
  <xsl:variable name="jats2html:notoc-regex" as="xs:string" select="'_-_NOTOC'">
    <!-- Overwrite this regex in your adaptions to exclude titles containing this string in its content-type from being listed in the html toc -->
  </xsl:variable>
  
  <xsl:template match="toc" mode="jats2html">
    <div class="toc">
      <xsl:sequence select="tr:create-epub-type-attribute(.)"/>
      <xsl:choose>
        <xsl:when test="exists(* except title-group)">
          <!-- explicitly rendered toc -->
          <xsl:apply-templates mode="jats2html"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="title-group" mode="jats2html"/>
          <xsl:apply-templates
            select="//title[parent::sec[not(ancestor::boxed-text)] | parent::title-group | parent::app | parent::app-group | parent::ref-list | parent::glossary]
                           [not(ancestor::boxed-text or ancestor::toc)]
                           [jats2html:heading-level(.) le number((current()/@depth, 100)[1]) + 1]
                           [not(matches(@content-type, $jats2html:notoc-regex))]"
            mode="toc"/>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>
  
  <xsl:template match="title" mode="toc">
    <p class="toc{jats2html:heading-level(.)}">
      <a href="#{(@id, generate-id())[1]}">
        <xsl:if test="../label">
          <xsl:apply-templates select="../label/node()" mode="strip-indexterms-etc"/>
          <xsl:text>&#x2002;</xsl:text>
        </xsl:if>
        <xsl:apply-templates mode="jats2html">
          <xsl:with-param name="in-toc" select="true()" as="xs:boolean" tunnel="yes"/>
        </xsl:apply-templates>
      </a>
    </p>
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

  <xsl:template match="label" mode="jats2html"/>
  
  <xsl:template match="title | book-title |  article-title[ancestor::title-group]" mode="jats2html">
    <xsl:param name="in-toc" as="xs:boolean?" tunnel="yes"/>
    <xsl:variable name="level" select="jats2html:heading-level(.)" as="xs:integer?"/>
    <xsl:element name="{if ($level) then concat('h', $level) else 'p'}">
      <xsl:copy-of select="(../@id, parent::title-group/../../@id)[1][not($divify-sections = 'yes')]"/>
      <xsl:call-template name="css:other-atts"/>
      <xsl:variable name="label" as="element(label)?" select="(
                                                                 ../label[not(named-content[@content-type = 'post-identifier'])], 
                                                                parent::caption/../label[not(named-content[@content-type = 'post-identifier'])]
                                                               )[1]"/>
      <xsl:variable name="post-label" as="element(label)?" select="(
                                                                     ../label[named-content[@content-type = 'post-identifier']], 
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
                <xsl:text>&#x2002;</xsl:text>
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
<!--    <p class="{string-join((@contrib-type, local-name()), ' ')}">-->
      <xsl:apply-templates mode="#current"/>
<!--    </p>-->
  </xsl:template>

  <xsl:template match="string-name" mode="jats2html">
    <xsl:apply-templates mode="#current"/>
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
  
  <xsl:template match="sup | sub" mode="jats2html">
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
  
  <xsl:template match="named-content" mode="jats2html">
    <span class="{local-name()}">
      <xsl:next-match/>
    </span>
  </xsl:template>

  <xsl:template match="underline" mode="jats2html">
    <!-- §§§ html5 option? -->
    <span>
      <xsl:next-match/>
    </span>
  </xsl:template>
  
  <xsl:template match="underline" mode="hub2htm:css-style-overrides">
    <xsl:attribute name="css:text-decoration" select="'underline'"/>
  </xsl:template>
  
  
  <xsl:template match="ref | copyright-statement" mode="jats2html">
    <p class="{name()}">
      <xsl:next-match/>
    </p>
  </xsl:template>
  
  <xsl:template match="ref[@id]/node()[last()][$bib-backlink-type = 'letter']" mode="jats2html">
    <xsl:next-match/>
    <xsl:text>&#x2002;</xsl:text>
    <xsl:for-each select="key('by-rid', ../@id)">
      <a href="#xref_{@id}">
        <xsl:number format="a" value="position()"/>
      </a>
      <xsl:if test="position() ne last()">
        <xsl:text xml:space="preserve">, </xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="surname | given-names | volume | prefix | suffix | source | year | date | etal | issue | string-date | fpage | lpage | article-title | chapter-title | 
    pub-id | volume-series | series | person-group | edition | publisher-loc | publisher-name | edition | person-group| role | collab | trans-title | trans-source | trans-subtitle | comment" mode="jats2html"> 
    <span class="{local-name()}">
      <xsl:next-match/>
    </span> 
  </xsl:template>

  <xsl:template match="@person-group-type" mode="jats2html"/>

  <xsl:variable name="jats:index-symbol-heading" as="xs:string" select="'0'"/>
  
  <xsl:template match="index" mode="jats2html">
    <div class="{local-name()}">
    <xsl:apply-templates select="@*, node()" mode="#current"/>
      <xsl:for-each-group select="//index-term[not(parent::index-term)]"
        group-by="if (matches(substring(jats2html:strip-combining((@sort-key, term)[1]), 1, 1), '[A-z\p{IsLatin-1Supplement}]')) 
                                  then substring(jats2html:strip-combining((@sort-key, term)[1]), 1, 1) 
                                  else '0'"
        collation="http://saxon.sf.net/collation?lang={(/*/@xml:lang, 'de')[1]};strength=primary">
        <xsl:sort select="current-grouping-key()" 
          collation="http://saxon.sf.net/collation?lang={(/*/@xml:lang, 'de')[1]};strength=primary"/>
        <h4>
          <xsl:value-of select="if (matches(current-grouping-key(), '[A-z\p{IsLatin-1Supplement}]') and current-grouping-key() ne '0') 
                                then upper-case(current-grouping-key()) 
                                else $jats:index-symbol-heading"/>
        </h4>
        <xsl:call-template name="group-index-terms">
          <xsl:with-param name="level" select="1"/>
          <xsl:with-param name="index-terms" select="current-group()"/>
        </xsl:call-template>
      </xsl:for-each-group>
    </div>
  </xsl:template>
  
  <xsl:template name="group-index-terms">
    <xsl:param name="level" as="xs:integer"/>
    <xsl:param name="index-terms" as="element(index-term)*"/>
    <!-- §§§ We need to know a book’s main language! -->
    <xsl:for-each-group select="$index-terms" group-by="(@sort-key, term)[1]"
      collation="http://saxon.sf.net/collation?lang={(/*/@xml:lang, 'de')[1]};strength=identical">
      <xsl:sort select="current-grouping-key()" collation="http://saxon.sf.net/collation?lang={(/*/@xml:lang, 'de')[1]};strength=primary"/>
      <xsl:sort select="current-grouping-key()" collation="http://saxon.sf.net/collation?lang={(/*/@xml:lang, 'de')[1]};strength=identical"/>
      <xsl:call-template name="index-entry">
        <xsl:with-param name="level" select="$level"/>
      </xsl:call-template>
    </xsl:for-each-group>
  </xsl:template>
  
  <xsl:template name="index-entry">
    <xsl:param name="level" as="xs:integer"/>
    <p class="ie ie{$level}">
      <xsl:value-of select="current-grouping-key()"/>
      <xsl:text>&#x2002;</xsl:text>
      <xsl:for-each select="current-group()[not(index-term)]">
        <a href="#it_{@id}" id="ie_{@id}">
          <xsl:value-of select="position()"/>
        </a>
        <xsl:if test="position() ne last()">
          <xsl:text xml:space="preserve">, </xsl:text>
        </xsl:if>
      </xsl:for-each>
    </p>
    <xsl:call-template name="group-index-terms">
      <xsl:with-param name="index-terms" select="current-group()/index-term"/>
      <xsl:with-param name="level" select="$level + 1"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="index-term[not(parent::index-term)]" mode="jats2html">
    <xsl:param name="in-toc" as="xs:boolean?" tunnel="yes"/>
    <xsl:if test="not($in-toc)">
      <span class="indexterm" id="it_{descendant-or-self::index-term[last()]/@id}">
        <xsl:attribute name="title">
          <xsl:apply-templates mode="#current"/>
        </xsl:attribute>
        <a href="#ie_{descendant-or-self::index-term[last()]/@id}" class="it">
          <xsl:if test="$index-backlink-type = ('text-and-number', 'number')">
            <span class="it"/>
            <xsl:if test="$index-backlink-type = ('text-and-number')">
              <xsl:text xml:space="preserve"> </xsl:text>
              <xsl:apply-templates mode="#current"/>
            </xsl:if>
          </xsl:if>
        </a>
        <!--<xsl:text xml:space="preserve"> </xsl:text>
        <a href="#ie_{descendant-or-self::index-term[last()]/@id}" class="it"/>-->
      </span>
    </xsl:if>
  </xsl:template>
  
  <xsl:key name="by-id" match="*[@id]" use="@id"/>
  
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
    <xsl:text xml:space="preserve"> see </xsl:text>
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="see-also" mode="jats2html">
    <xsl:text xml:space="preserve"> see also </xsl:text>
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template match="p[boxed-text | fig | table-wrap]" mode="jats2html" priority="1.2">
    <xsl:for-each-group select="node()" group-adjacent="boolean(self::boxed-text | self::fig | self::table-wrap)">
      <xsl:choose>
        <xsl:when test="current-grouping-key()">
          <xsl:apply-templates select="current-group()" mode="#current"/>
        </xsl:when>
        <xsl:when test="every $item in current-group() satisfies ($item/self::text()[not(normalize-space())])"/>
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
    <img alt="{replace((@xlink:title, @xlink:href)[1], '^(.+)/([^/]+)$', '$2')}">
    	<xsl:apply-templates select="@srcpath, @xlink:href" mode="#current"/>
      <xsl:call-template name="css:content"/>
    </img>
  </xsl:template>
  
  <xsl:template match="*[local-name() = ('graphic', 'inline-graphic')]/@xlink:href" mode="jats2html">
    <xsl:attribute name="src" select="."/>
  </xsl:template>

  <xsl:template match="graphic/@css:*" mode="jats2html"/>

  <xsl:template match="*[local-name() = ('graphic', 'inline-graphic')]/@*[name() = ('css:width', 'css:height')]"
    mode="hub2htm:css-style-overrides"/>

  <xsl:template match="graphic/attrib" mode="jats2html"/>
  
  <!-- formulas -->
  
  <xsl:template match="disp-formula|inline-formula" mode="jats2html">
    <div class="{name()}">
      <xsl:apply-templates select="@srcpath, node()" mode="#current"/>
    </div>
  </xsl:template>
  
  <!-- strip ns prefix to meet mathjax requirements -->
  <xsl:template match="mml:math" mode="jats2html">
    <xsl:element name="{local-name()}" namespace="http://www.w3.org/1998/Math/MathML">
      <xsl:apply-templates select="@srcpath, node()" mode="#current"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="alternatives" mode="jats2html">
    <div class="{name()}">
      <xsl:apply-templates select="@srcpath, node()" mode="#current"/>
    </div>
  </xsl:template>
  
  <xsl:template match="table-wrap/alternatives[graphic] | boxed-text/alternatives[graphic]" mode="jats2html" priority="2">
    <xsl:for-each select="graphic">
      <img class="{local-name()}" src="{@xlink:href}" alt="Alternative image for table {@xlink:href}"/>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="tex-math" mode="jats2html">
    <div class="{name()}">
      <xsl:apply-templates select="@srcpath" mode="#current"/>
    </div>
  </xsl:template>
  
  <!-- tables -->
  
  <xsl:template match="tr | tbody | thead | tfoot | td | th | colgroup | col | *[name() = ('table', 'array')][not(matches(@css:width, 'pt$'))]" mode="jats2html">
    <xsl:element name="{local-name()}" exclude-result-prefixes="#all">
      <xsl:call-template name="css:content"/>
    </xsl:element>
  </xsl:template>  

  <xsl:template match="*[name() = ('table', 'array')][matches(@css:width, 'pt$')]" mode="jats2html">
    <xsl:variable name="conditional-percent-widths" as="element(*)">
      <xsl:apply-templates select="." mode="table-widths"/>
    </xsl:variable>
    <xsl:apply-templates select="$conditional-percent-widths" mode="#current">
      <xsl:with-param name="root" select="root(.)" tunnel="yes"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <!-- There should always be @css:width. @width is only decorational (will be valuable just in case 
    all @css:* will be stripped -->
  <xsl:template match="@width" mode="jats2html"/>

  <xsl:template match="*[name() = ('table', 'array')][@css:width]" mode="table-widths">
    <xsl:variable name="twips" select="tr:length-to-unitless-twip(@css:width)" as="xs:double?"/>
    <xsl:choose>
      <xsl:when test="$twips">
        <xsl:copy copy-namespaces="no">
          <xsl:apply-templates select="@*, node()" mode="#current">
            <xsl:with-param name="table-twips" select="$twips" tunnel="yes"/>
            <xsl:with-param name="table-percentage" select="jats2html:table-width-grid($twips, $page-width-twips)" tunnel="yes"/>
          </xsl:apply-templates>
        </xsl:copy>    
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
  
  <xsl:template match="ext-link|uri" mode="jats2html">
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
                           then resolve-uri(., $rr)
                           else ."/>
  </xsl:template>
  
  <xsl:template match="@ext-link-type" mode="jats2html"/>
  
  <xsl:template match="@xlink:type" mode="jats2html"/>
  
  <xsl:key name="by-id" match="*[@id]" use="@id"/>
  <xsl:key name="by-rid" match="*[@rid]" use="@rid"/>
  
  <xsl:variable name="root" select="/" as="document-node()"/>

  <xsl:template match="xref" mode="jats2html">
    <xsl:param name="in-toc" as="xs:boolean?" tunnel="yes"/>
    <xsl:variable name="linked-items" as="element(linked-item)*">
      <xsl:apply-templates select="key('by-id', tokenize(@rid, '\s+'), $root)" mode="linked-item"/>
    </xsl:variable>
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
              <!--<xsl:if test=". is (key('by-rid', $linked-items[1]/@id, $root))[1]">
                <xsl:attribute name="id" select="concat('xref_', $linked-items[1]/@id)"/>
              </xsl:if>-->
              <xsl:apply-templates mode="#current"/>
            </a>
            <xsl:if test="$linked-items[1]/@ref-type = 'ref'"><!-- bibliography entry -->
              <xsl:if test="$bib-backlink-type = 'letter'">
                <span class="cit">
                  <xsl:text>[</xsl:text>
                  <xsl:number format="a" value="index-of(for $xr in key('by-rid', @rid, $root) return $xr/@id, @id)"/>
                  <xsl:text>]</xsl:text>
                </span>
              </xsl:if>
            </xsl:if>
          </xsl:when>
          <xsl:when test="count($linked-items) eq 0">
            <xsl:apply-templates mode="#current"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message>Cannot link: multiple resolutions for xref with an explicit link text. <xsl:copy-of select="."/></xsl:message>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <!-- generate referring text -->
        <xsl:call-template name="render-rids">
          <xsl:with-param name="linked-items" select="$linked-items"/>
          <xsl:with-param name="in-toc" select="$in-toc" tunnel="yes"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="render-rids">
    <xsl:param name="linked-items" as="element(linked-item)*"/>
    <xsl:variable name="grouped-items" as="element(linked-items)" xmlns="">
      <linked-items>
        <xsl:for-each-group select="$linked-items" group-by="@ref-type">
          <ref-type-group type="{current-grouping-key()}">
            <xsl:for-each-group select="current-group()" group-adjacent="jats2html:link-rendering-type(., ('label', 'number', 'title', 'teaser'))">
              <rendering type="{current-grouping-key()}">
                <xsl:variable name="context" select="." as="element(*)"/>
                <xsl:for-each select="current-group()/(@* | *)[name() = current-grouping-key()]">
                  <item id="{$context/@id}">
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
    <xsl:text>&#xa0;</xsl:text>
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
        <a href="#{@id}">
          <xsl:apply-templates mode="#current"/>
        </a>    
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  
  <xsl:function name="jats2html:is-book-part-like" as="xs:boolean">
    <xsl:param name="elt" as="element(*)"/>
    <!-- add more: -->
    <xsl:sequence select="exists($elt/(self::toc | self::book-part | self::preface | self::foreword | self::dedication |
      self::front-matter-part))"/>
  </xsl:function>
  
  <xsl:function name="jats2html:heading-level" as="xs:integer?">
    <xsl:param name="elt" as="element(*)"/>
    <xsl:choose>
      <xsl:when test="$elt/ancestor::table-wrap"/>
      <xsl:when test="$elt/ancestor::verse-group"/>
      <xsl:when test="$elt/ancestor::fig"/>
      <xsl:when test="$elt/parent::book-title-group"><xsl:sequence select="1"/></xsl:when>
      <xsl:when test="$elt/parent::title-group">
        <xsl:sequence select="2"/>
        <!--<xsl:sequence select="count($elt/ancestor::*[jats2html:is-book-part-like(.)]) + 1"/>-->
      </xsl:when>
      <xsl:when test="$elt/parent::sec[ancestor::boxed-text]">
        <xsl:sequence select="count($elt/ancestor::*[ancestor::boxed-text]) + 3"/>
      </xsl:when>
      <xsl:when test="$elt/parent::*[local-name() = ('index')]">
        <xsl:sequence select="2"/>
      </xsl:when>
      <xsl:when test="$elt/parent::*[local-name() = ('ref-list', 'sec', 'abstract', 'ack', 'app', 'app-group', 'glossary', 'bio')]">
        <xsl:variable name="ancestor-title" select="$elt/../../(title | (. | ../book-part-meta)/title-group/title)" as="element(title)?"/>
        <xsl:sequence select="if (exists($ancestor-title)) 
                              then jats2html:heading-level($ancestor-title) + 1
                              else 2"/></xsl:when>
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
      
</xsl:stylesheet>