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
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="html tr xlink xs cx css saxon jats2html hub2htm l10n"
  version="2.0">
  
  <xsl:import href="http://transpect.io/jats2html/xsl/jats2html.xsl"/>


  <xsl:param name="css-location" select="'css/stylesheet.css'"/>
 

  <xsl:template match="html:span[not(@*)]" mode="clean-up">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="@dtd-version" mode="jats2html" />
  
  <xsl:template match="book-meta" mode="jats2html">
    <div class="title">
      <xsl:apply-templates select="* except (custom-meta-group | abstract | contrib-group), contrib-group/contrib" mode="#current"/>
    </div>
    <xsl:apply-templates select="contrib-group/bio" mode="#current"/>
    <xsl:apply-templates select="abstract" mode="#current"/>
  </xsl:template>
  
  <xsl:template match="book-meta/*[local-name()= ('book-id', 'isbn', 'permissions', 'book-volume-number', 'publisher')]" mode="jats2html"/>
  
  <xsl:template match="book-title-group" mode="jats2html">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="subtitle" mode="jats2html">
    <p class="{local-name()}">
      <xsl:call-template name="css:content"/>
    </p>
  </xsl:template>
  
  <xsl:template match="aff" mode="jats2html">
    <p class="{local-name()}" id="{@id}">
      <span class="inline-title">Affiliation: </span>
      <xsl:call-template name="css:content"/>
    </p>
  </xsl:template>
  
  <xsl:template match="author-notes/corresp" mode="jats2html">
    <p class="{local-name()}" id="{@id}" srcpath="{@srcpath}">
      <span class="inline-title">Corresponding Author Address: </span>
      <xsl:apply-templates mode="#current"/>
    </p>
  </xsl:template>
  
  <xsl:template match="bio | permissions" mode="jats2html" >
    <div class="{name()}">
      <xsl:apply-templates mode="#current"/>
    </div>      
  </xsl:template>
  
  <xsl:template match="contrib/name" mode="jats2html">
    <p class="author">
      <span class="inline-title">Author: </span>
      <xsl:apply-templates select="surname" mode="#current"/>,<xsl:apply-templates select="given-names" mode="#current"/>&#160;
      <xsl:apply-templates select="following-sibling::degrees" mode="#current">
        <xsl:with-param name="process" select="true()"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="* except (surname| given-names| following-sibling::degrees)" mode="#current"/>
      <xsl:apply-templates select="following-sibling::xref" mode="#current">
        <xsl:with-param name="process" as="xs:boolean?" select="true()"/>
      </xsl:apply-templates>
    </p>
  </xsl:template>
  
  <xsl:template match="article-meta | journal-meta" mode="jats2html">
    <div id="{local-name()}">
      <span class="inline-title">Meta-Information: </span>
      <xsl:apply-templates mode="#current"/>
    </div>
  </xsl:template>
  
  <xsl:template match="pub-date"  mode="jats2html" >
    <span class="inline-title">Article Publication: </span>
    <xsl:apply-templates select="year | volume | issue | fpage | lpage" mode="#current"/>
  </xsl:template>
  
  <xsl:template match="year | volume | issue | fpage | lpage" mode="jats2html">
    <span class="{local-name()}">
    <span class="inline-title"><xsl:value-of select="concat(local-name(), ':')"/></span>
       <xsl:apply-templates mode="#current"/>
    </span>
  </xsl:template>

  <!-- Default handler for the content of para-like and phrase-like elements,
    invoked by an xsl:next-match for the same matching elements. Don't forget 
    to include the names of the elements that you want to handle here. Otherwise
    they'll be reported as unhandled.
    And don’t ever change the priority unless you’ve made sure that no other template
    relies on this value to be 0.25.
    -->
  <xsl:template match="email | pub-date | corresp | author-notes  | abstract |  
     degrees | journal-meta | journal-id  | journal-title-group | journal-title | address | addr-line | article-meta | article-categories | subj-group | subject | subj-group-type |
    date | string-date | contrib | alt-text | contrib-group | contrib-type" mode="jats2html" priority="-0.25" >
    <xsl:call-template name="css:content"/>
  </xsl:template>
 
  
  <xsl:template match="@srcpath" mode="jats2html">
<!--    <xsl:if test="$srcpaths eq 'yes'">-->
      <xsl:copy/>  
    <!--</xsl:if>-->
  </xsl:template>
  
  <xsl:template match="@id" mode="class-att">
    <xsl:copy/>
  </xsl:template>
  
    <xsl:template match="@frame" mode="class-att">
    <xsl:copy/>
  </xsl:template>

  <xsl:template match="@xml:lang" mode="jats2html">
    <xsl:if test="not(. = ancestor::*[@xml:lang][1]/@xml:lang)">
      <xsl:copy/>
      <xsl:attribute name="lang" select="."/>
    </xsl:if>
  </xsl:template>

 
  <!-- will be handled by class-att mode -->
  <xsl:template match="@content-type | @style-type | @specific-use | @journal-id-type | @subj-group-type | @id | @frame" mode="jats2html"/>

  <xsl:variable name="default-structural-containers" as="xs:string+"
    select="('book-part', 'front', 'front-matter-part', 'sec', 'ack', 'ref-list', 'dedication', 'abstract', 'foreword', 'preface', 'contrib-group')"/>

 
  
  <xsl:template match="book-part  | front-matter-part | foreword | preface | dedication" mode="jats2html">
    <xsl:apply-templates select="book-part-meta | front | front-matter | book-body | body | book-back | back | named-book-part-body" mode="jats2html"/>
  </xsl:template>
  
  <xsl:template match="body | book-body | title-group | book-part-meta | front | front-matter | book-back | back | app[ancestor::app-group]" mode="jats2html">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  
  <xsl:template match="contrib-group/contrib" mode="jats2html">
<!--    <p class="{string-join((@contrib-type, local-name()), ' ')}">-->
      <xsl:apply-templates mode="#current"/>
    <!--</p>-->
  </xsl:template>

  <xsl:template match="name" mode="jats2html">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
 

  <xsl:template match="surname | given-names | prefix| source | date | etal | string-date   | chapter-title |  address  | email |
    pub-id | volume-series | series | person-group | edition | publisher-loc | publisher-name | edition | person-group | contrib | role | collab | trans-title | trans-source | trans-subtitle | subtitle |comment" mode="jats2html"> 
    <span class="{local-name()}">
      <xsl:next-match/>
    </span> 
  </xsl:template>

  
  <xsl:template match="subject | journal-title | journal-id" mode="jats2html"> 
    <p class="{local-name()}">
      <xsl:next-match/>
    </p> 
  </xsl:template>
  
   <xsl:template match="degrees" mode="jats2html"> 
    <xsl:param name="process"/>
    <xsl:if test="$process">
     <span class="{local-name()}">
      <xsl:next-match/>
      </span> 
    </xsl:if>
  </xsl:template>

  <xsl:template match="addr-line" mode="jats2html">
    <br /><span class="{local-name()}">
    <xsl:next-match/>
  </span>
</xsl:template>

  <xsl:template match="@person-group-type" mode="jats2html"/>

  
  <!-- tables -->
  
  <xsl:template match="tr | tbody | thead | tfoot | td | th | colgroup | col | *[name() = ('table', 'array')][not(matches(@css:width, 'pt$'))]" mode="jats2html">
    <xsl:element name="{local-name()}" exclude-result-prefixes="#all">
      <xsl:if test="./@frame">
        <xsl:attribute name="frame">
          <xsl:value-of select="./@frame"/>
        </xsl:attribute>
        <xsl:attribute name="rules">
          <xsl:value-of select="'all'"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:call-template name="css:content"/>
    </xsl:element>
  </xsl:template>  

  
  <xsl:template match="xref" mode="jats2html">
    <xsl:param name="process" as="xs:boolean?"/>
    <xsl:if test="$process">
    <a href="#{./@rid}">
      <xsl:value-of select="replace(./@rid, '^\w+(\d+)' , '$1')"/>
    </a>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="corresp/@id" mode="jats2html"/>
  <xsl:template match="aff/@id" mode="jats2html"/>

  <xsl:function name="jats2html:heading-level" as="xs:integer?">
    <xsl:param name="elt" as="element(*)"/>
    <xsl:choose>
      <xsl:when test="$elt/ancestor::table-wrap"/>
      <xsl:when test="$elt/ancestor::verse-group"/>
      <xsl:when test="$elt/ancestor::fig"/>
      <xsl:when test="$elt/parent::article-title-group"><xsl:sequence select="1"/></xsl:when>
      <xsl:when test="$elt/parent::article"><xsl:sequence select="1"/></xsl:when>
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
        <xsl:message>No heading level for <xsl:copy-of select="$elt"/> 
          (parent name: '<xsl:value-of select="$elt/../name()"/>')</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
      
</xsl:stylesheet>