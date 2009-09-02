<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
								xmlns:ArgoUML="org.omg.xmi.namespace.UML"
								xmlns:StarUML="href://org.omg/UML/1.3"
								xmlns:UML="org.omg.xmi.namespace.UML"
								xmlns:fn="http://www.w3.org/2005/xpath-functions"
								xmlns:xmidj="xmi2dj.cch.kcl.ac.uk"
								>
<xsl:output method="text" omit-xml-declaration="yes" indent="no" />

<!-- ========================== -->
<!-- 		FUNCTIONS 			-->
<!-- ========================== -->

<!-- Here's how to do a replace() in xpath 1.0!!! -->
<xsl:template name="getQuotedText">
	<xsl:param name="text"/>
	<xsl:variable name="dquote">"</xsl:variable>
	<xsl:variable name="dquoteEscaped">\"</xsl:variable>
    <xsl:choose>
      <xsl:when test="contains($text, $dquote)">
        <xsl:variable name="bufferBefore" select="substring-before($text,$dquote)"/>
        <xsl:variable name="newBuffer" select="substring-after($text,$dquote)"/>
        <xsl:value-of select="$bufferBefore"/><xsl:value-of select="$dquoteEscaped"/>
        <xsl:call-template name="getQuotedText">
          <xsl:with-param name="text" select="$newBuffer"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$text"/>
      </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="getReplacedText">
	<xsl:param name="text"/>
	<xsl:param name="source"/>
	<xsl:param name="target"/>
    <xsl:choose>
      <xsl:when test="contains($text, $source)">
        <xsl:variable name="bufferBefore" select="substring-before($text,$source)"/>
        <xsl:variable name="newBuffer" select="substring-after($text,$source)"/>
        <xsl:value-of select="$bufferBefore"/>
        <xsl:value-of select="$target"/>
        <xsl:call-template name="getReplacedText">
			<xsl:with-param name="text" select="$newBuffer"/>
			<xsl:with-param name="source" select="$source"/>
			<xsl:with-param name="target" select="$target"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$text"/>
      </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="getPlural">
	<xsl:param name="name"/>
	<xsl:choose>
		<xsl:when test="substring($name, string-length($name), 1) = 'y'"><xsl:value-of select="concat(substring($name, 1, string-length($name) - 1), 'ies')"/></xsl:when>
		<xsl:when test="substring($name, string-length($name), 1) = 's'"><xsl:value-of select="concat($name, 'es')"/></xsl:when>
		<xsl:otherwise><xsl:value-of select="$name"/>s</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="getDjIdentifier">
	<xsl:param name="name"/>
	<xsl:value-of select="translate($name, ' ', '_')" />
</xsl:template>

<xsl:template name="getDjIdentifierL">
	<xsl:param name="name"/>
	<xsl:value-of select="translate($name, ' ABCDEFGHIJKLMNOPQRSTUVWXYZ', '_abcdefghijklmnopqrstuvwxyz')" />
</xsl:template>

<!-- use template instead of a function because we need the calling context (key and select...) -->
<xsl:template name="getParentModel">
	<xsl:param name="childid"/>
	<xsl:variable name="parentClass" select="//UML:Generalization[UML:Generalization.child/UML:Class/@xmi.idref = $childid]/UML:Generalization.parent/UML:Class" />
	<xsl:choose>
		<!-- xsl:when test="$parentClass"><xsl:value-of select="xmidj:getDjIdentifier(key('classes', $parentClass/@xmi.idref)/@name)" /></xsl:when -->
		<xsl:when test="$parentClass"><xsl:value-of select="key('classes', $parentClass/@xmi.idref)/@name" /></xsl:when>
		<xsl:otherwise>models.Model</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="getShortDocQuoted">
	<xsl:param name="text"/>
	<xsl:call-template name="getQuotedText">
		<xsl:with-param name="text">
			<xsl:call-template name="getShortDoc"><xsl:with-param name="text" select="$text"/></xsl:call-template>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template name="getShortDoc">
	<!-- returns the first line of a text. If the first line starts with [, returns nothing. -->
	<xsl:param name="text"/>
	<xsl:variable name="eol"><xsl:text>&#xA;</xsl:text></xsl:variable>
	<xsl:if test="not(starts-with($text, '['))">
		<xsl:choose>
			<xsl:when test="contains($text, $eol)"><xsl:value-of select="substring-before($text, $eol)" /></xsl:when>
			<xsl:otherwise><xsl:value-of select="$text" /></xsl:otherwise>
		</xsl:choose>
	</xsl:if>
</xsl:template>

<xsl:template name="getLongDoc">
	<!-- removes the comments from a text and the first line if its not a comment. -->
	<xsl:param name="text"/>
	<xsl:variable name="eol"><xsl:text>&#xA;</xsl:text></xsl:variable>

	<xsl:variable name="longDoc">
		<!-- remove the first line if its not a comment. prepend a newline otherwise. -->
		<xsl:choose>
			<xsl:when test="starts-with($text, '[')"><xsl:text>&#xA;</xsl:text><xsl:value-of select="$text" /></xsl:when>
			<xsl:otherwise><xsl:value-of select="substring-after($text, $eol)" /></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<!-- convert the new lines into br -->
	<xsl:call-template name="getReplacedText">
		<xsl:with-param name="text">
			<!-- remove all the commented lines -->
			<xsl:call-template name="getTextWithoutComments"><xsl:with-param name="text" select="$longDoc"/></xsl:call-template>
		</xsl:with-param>
		<xsl:with-param name="source" select="$eol"/>
		<xsl:with-param name="target"><![CDATA[<br/>]]></xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template name="getTextWithoutComments">
	<!-- removes all the comments from a text. Comments always starts a line with [ and ends at the next ] -->
	<xsl:param name="text"/>
	<xsl:variable name="comment"><xsl:text>&#xA;[</xsl:text></xsl:variable>
    <xsl:choose>
      <xsl:when test="contains($text, $comment)">
        <xsl:variable name="bufferBefore" select="substring-before($text,$comment)"/>
        <xsl:variable name="newBufferTemp" select="substring-after($text,$comment)"/>
        <xsl:variable name="newBuffer" select="substring-after($newBufferTemp,']')"/>
        <xsl:value-of select="$bufferBefore"/>
        <xsl:call-template name="getTextWithoutComments">
          <xsl:with-param name="text" select="$newBuffer"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$text"/>
      </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="getHelpText">
	<!-- returns the help_text attribute for a field in the model. -->
	<xsl:param name="text"/>
	<xsl:param name="fieldName"/>
	<xsl:variable name="fieldNameDj"><xsl:call-template name="getDjIdentifierL"><xsl:with-param name="name" select="$fieldName"/></xsl:call-template></xsl:variable>
	<xsl:variable name="longDoc"><xsl:call-template name="getLongDoc"><xsl:with-param name="text" select="$text"/></xsl:call-template></xsl:variable>
	
	<xsl:text>help_text=ur'''</xsl:text>
	<xsl:call-template name="getShortDoc"><xsl:with-param name="text" select="$text"/></xsl:call-template>
	<xsl:if test="string-length(normalize-space($longDoc)) > 1">
		<![CDATA[<img src="/media/img/admin/icon-unknown.gif" class="long-doc-link" onclick="showLongDoc(']]><xsl:value-of select="$fieldName"/><![CDATA[', ']]><xsl:value-of select="$fieldNameDj"/><![CDATA[-doc-id');" /><span style="display:none;" id="]]><xsl:value-of select="$fieldNameDj"/><![CDATA[-doc-id">]]><xsl:value-of select="$longDoc"/><![CDATA[</span>]]>
	</xsl:if>
	<xsl:text>''', </xsl:text>

</xsl:template>

<xsl:template name="getDefaultValue">
	<xsl:param name="associationid" />
	<!-- find the id of the default tag -->
	<xsl:variable name="tagid"><xsl:value-of select="key('tags', 'default')/@xmi.id" /></xsl:variable>
	<xsl:variable name="result"><xsl:value-of select="//*[@xmi.id=$associationid]/UML:ModelElement.taggedValue/UML:TaggedValue[UML:TaggedValue.type/UML:TagDefinition/@xmi.idref = '-119-73-122--119-283b2ec6:122ef60c3b8:-8000:00000000000011EF']/UML:TaggedValue.dataValue/text()"></xsl:value-of></xsl:variable>
	<xsl:choose>
		<xsl:when test="string-length($result)"><xsl:value-of select="$result" /></xsl:when>
		<xsl:otherwise>1</xsl:otherwise>
	</xsl:choose>
</xsl:template>

</xsl:stylesheet>
