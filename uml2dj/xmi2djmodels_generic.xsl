<?xml version="1.0" encoding="UTF-8"?>
<!--
UML to Django

@author: Goffer Looney (glooney)
@doc: http://code.google.com/p/uml-to-django/
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
								xmlns:ArgoUML="org.omg.xmi.namespace.UML"
								xmlns:StarUML="href://org.omg/UML/1.3"
								xmlns:UML="org.omg.xmi.namespace.UML"
								xmlns:fn="http://www.w3.org/2005/xpath-functions"
								xmlns:xmidj="xmi2dj"
								>
<xsl:import href="xmilib.xsl"/>

<xsl:output method="text" omit-xml-declaration="yes" indent="no" />

<xsl:key name="datatypes" match="//UML:DataType[@xmi.id]" use="@xmi.id" />
<xsl:key name="classes" match="//UML:Class[@xmi.id]" use="@xmi.id" />
<xsl:key name="stereotypes" match="//UML:Stereotype[@xmi.id]" use="@xmi.id" />
<xsl:key name="tags" match="//UML:TagDefinition[@xmi.id]" use="@xmi.id" />
<!-- xsl:key name="associationEnd" match="//UML:AssociationEnd.participant/UML:Class" use="@xmi.idref" / -->

<!-- ========================== -->
<!-- 		ROOT TEMPLATE 		-->
<!-- ========================== -->

<xsl:template match="/">
<xml:text># -*- coding: utf-8 -*-
# auto generated from an XMI file
from django.db import models
</xml:text>
<xsl:if test="count(key('datatypes', //@xmi.idref)[@name = 'FuzzyDate']) > 0" >
from <xsl:value-of select="/XMI/XMI.content[1]/UML:Model[1]/@name" />.cch.fuzzydate import fields
</xsl:if>
from django.utils.encoding import force_unicode

def getUnicode(object):
	if (object == None):
		return u""
	else:
		return force_unicode(object)
		
<!-- xsl:apply-templates select="/XMI/XMI.content/UML:Model/UML:Namespace.ownedElement/UML:Package/UML:Namespace.ownedElement/UML:Class[@name and @name != '' and substring(@name,1,1) != '_']"/ -->
<!-- Make sure we declare the base classes first otherwise Python will not compile our code -->
<!-- note that the following method doesn't work multiple level of inheritence -->
<xsl:for-each select="/XMI/XMI.content/UML:Model/UML:Namespace.ownedElement/UML:Package/UML:Namespace.ownedElement/UML:Class[@xmi.id]">
	<xsl:if test="count(//UML:Generalization.parent/UML:Class[@xmi.idref = current()/@xmi.id]) > 0">
		<xsl:apply-templates select="." />
	</xsl:if>
</xsl:for-each>
<xsl:for-each select="/XMI/XMI.content/UML:Model/UML:Namespace.ownedElement/UML:Package/UML:Namespace.ownedElement/UML:Class[@xmi.id]">
	<xsl:if test="count(//UML:Generalization.parent/UML:Class[@xmi.idref = current()/@xmi.id]) = 0">
		<xsl:apply-templates select="." />
	</xsl:if>
</xsl:for-each>
# Many To Many Tables 
<xsl:apply-templates select="/XMI/XMI.content/UML:Model/UML:Namespace.ownedElement//UML:Association/UML:Association.connection"/>
<xsl:apply-templates select="/XMI/XMI.content/UML:Model/UML:Namespace.ownedElement//UML:AssociationClass/UML:Association.connection"/>
</xsl:template>

<!-- ========================== -->
<!-- 	CONNECTION TEMPLATE 	-->
<!-- ========================== -->

<xsl:template match="UML:Association.connection">
<xsl:if test="UML:AssociationEnd[1]//UML:MultiplicityRange/@upper = '-1' and UML:AssociationEnd[2]//UML:MultiplicityRange/@upper = '-1'">
<xsl:text>
#
class </xsl:text>
	<xsl:call-template name="getDjIdentifier"><xsl:with-param name="name" select="key('classes', UML:AssociationEnd[1]/UML:AssociationEnd.participant/UML:Class/@xmi.idref)/@name"/></xsl:call-template>
	<xsl:text>_</xsl:text>
	<xsl:call-template name="getDjIdentifier"><xsl:with-param name="name" select="key('classes', UML:AssociationEnd[2]/UML:AssociationEnd.participant/UML:Class/@xmi.idref)/@name"/></xsl:call-template>
	<xsl:text>(models.Model):
</xsl:text>

	<xsl:for-each select=".//UML:AssociationEnd.participant/UML:Class" >
		<xsl:text><![CDATA[	]]></xsl:text>
		<xsl:call-template name="getDjIdentifierL"><xsl:with-param name="name" select="key('classes', @xmi.idref)/@name"/></xsl:call-template> = models.ForeignKey('<xsl:call-template name="getDjIdentifier"><xsl:with-param name="name" select="key('classes', @xmi.idref)/@name"/></xsl:call-template>
		<xsl:text>')
</xsl:text>
	</xsl:for-each>

<xsl:if test="count(../UML:Classifier.feature/UML:Attribute) > 0" >
	<xsl:text>
	# association fields 
</xsl:text>
	<xsl:apply-templates select="../UML:Classifier.feature/UML:Attribute" />
</xsl:if>

</xsl:if>
</xsl:template>

<!-- ========================== -->
<!-- 		CLASS TEMPLATE 		-->
<!-- ========================== -->

<xsl:template match="UML:Class">
<xsl:variable name="classid" select="@xmi.id" />
#
class <xsl:call-template name="getDjIdentifier"><xsl:with-param name="name" select="@name"/></xsl:call-template>(<xsl:call-template name="getParentModel" ><xsl:with-param name="childid" select="@xmi.id"/></xsl:call-template>):
<xsl:apply-templates select="UML:Classifier.feature/UML:Attribute" />

<xsl:call-template name="ConvertClassAssociations"><xsl:with-param name="classid" select="@xmi.id"/></xsl:call-template>
	class Meta:
		verbose_name = '<xsl:value-of select="@name" />'
		verbose_name_plural = '<xsl:call-template name="getPlural"><xsl:with-param name="name" select="@name"/></xsl:call-template>'
		<xsl:if test="UML:Classifier.feature/UML:Attribute[UML:ModelElement.stereotype/UML:Stereotype[key('stereotypes', @xmi.idref)/@name = 'PK']]">
			<xsl:text>unique_together = (( </xsl:text>
			<xsl:for-each select="UML:Classifier.feature/UML:Attribute[UML:ModelElement.stereotype/UML:Stereotype[key('stereotypes', @xmi.idref)/@name = 'PK']]" >
				<xsl:text>'</xsl:text><xsl:call-template name="getDjIdentifierL"><xsl:with-param name="name" select="@name"/></xsl:call-template>
				<xsl:text>', </xsl:text>
			</xsl:for-each>
			<xsl:for-each select="/.//UML:Association/UML:Association.connection/UML:AssociationEnd[key('stereotypes', UML:ModelElement.stereotype/UML:Stereotype/@xmi.idref)/@name = 'PK'][UML:AssociationEnd.participant/UML:Class/@xmi.idref = $classid]" >
				<xsl:text>'</xsl:text><xsl:call-template name="getDjIdentifierL"><xsl:with-param name="name" select="key('classes', ..//UML:Class[@xmi.idref != $classid]/@xmi.idref)/@name"/></xsl:call-template>
				<xsl:text>', </xsl:text>
			</xsl:for-each>
			<xsl:text>),)</xsl:text>
		</xsl:if>
	
	<xsl:variable name="idFields" select="UML:Classifier.feature/UML:Attribute[UML:ModelElement.stereotype/UML:Stereotype[key('stereotypes', @xmi.idref)/@name = 'PK']]" />
	<xsl:if test="count($idFields) > 0">
	
	def __unicode__(self):
		return <xsl:for-each select="$idFields" >
			<xsl:if test="$idFields[1]/@name != @name" >+', '+</xsl:if>
			<xsl:text>getUnicode(self.</xsl:text>
			<xsl:call-template name="getDjIdentifierL"><xsl:with-param name="name" select="@name"/></xsl:call-template>
			<xsl:text>)</xsl:text>
		</xsl:for-each>
	</xsl:if>

	table_group = '<xsl:choose>
		<xsl:when test="UML:ModelElement.taggedValue/UML:TaggedValue[key('tags', UML:TaggedValue.type/UML:TagDefinition/@xmi.idref)/@name = 'Table Group']">
			<xsl:value-of select="UML:ModelElement.taggedValue/UML:TaggedValue[key('tags', UML:TaggedValue.type/UML:TagDefinition/@xmi.idref)/@name = 'Table Group']/UML:TaggedValue.dataValue/text()" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:if test="UML:ModelElement.stereotype/UML:Stereotype[key('stereotypes', @xmi.idref)/@name = 'Reference']">Reference</xsl:if>
		</xsl:otherwise>
	</xsl:choose>'

</xsl:template>

<!-- ========================== -->
<!-- 		FK TEMPLATE 		-->
<!-- ========================== -->

<xsl:template name="ConvertClassAssociations">
<!-- Converts 1-n or n-n associations into ForeignKey fields in the class -->
<!-- [classid] if the xmi.id of the class we are currently converting into django -->
<xsl:param name="classid" />
<!-- find all the end of all the 1-n or n-n associations, the end point to this class -->
<xsl:for-each select="//UML:Association/UML:Association.connection/UML:AssociationEnd[descendant::UML:MultiplicityRange/@upper = '-1'][UML:AssociationEnd.participant/UML:Class/@xmi.idref = $classid]
						| //UML:AssociationClass[UML:Association.connection/UML:AssociationEnd[descendant::UML:MultiplicityRange/@upper = '-1']/UML:AssociationEnd.participant/UML:Class/@xmi.idref = $classid]">
	<!-- name of the ending to this class -->
	<xsl:variable name="endName" select="@name" />
	<!-- Find the class at other end -->
	<!-- xsl:for-each select="descendant::UML:AssociationEnd.participant/UML:Class[@xmi.idref != $classid]" -->
	<xsl:for-each select="../UML:AssociationEnd[@xmi.id != current()/@xmi.id]" >
		<xsl:variable name="otherClassid" select="UML:AssociationEnd.participant/UML:Class/@xmi.idref" />
		<!-- Continue if that end is 1 
			OR 
			it is the first end (a way to choose an arbitrary model where we declare the many2many key) -->
		<xsl:if test="(descendant::UML:MultiplicityRange/@upper = '1') or ($otherClassid = ../UML:AssociationEnd[1]/UML:AssociationEnd.participant/UML:Class/@xmi.idref)">
		<xsl:text><![CDATA[	]]></xsl:text>
		<!-- todo: foreign key name should be the name of an end of the association, if absent then we must use the name of the foreign table -->
		<!-- todo: the association name should be used for the joint table -->
		<!-- xsl:value-of select="xmidj:getDjIdentifierL(@name)" / -->
		<xsl:variable name="fieldName">
			<xsl:choose>
				<!-- if 1-n AND there is a name for that end of the connection then use it -->
				<!-- xsl:when test="$endName != '' and descendant::UML:MultiplicityRange/@upper = '1'" -->
				<xsl:when test="$endName != ''"><xsl:value-of select="$endName"/></xsl:when>
				<!-- Otherwise just use the other class name -->
				<xsl:otherwise><xsl:value-of select="key('classes', $otherClassid)/@name"/></xsl:otherwise>
			</xsl:choose> 
		</xsl:variable>
		<xsl:variable name="fieldNameDj">
			<xsl:call-template name="getDjIdentifierL"><xsl:with-param name="name" select="$fieldName"/></xsl:call-template>
		</xsl:variable>
		<xsl:value-of select="$fieldNameDj" />
		
		<xsl:text> = models.</xsl:text>
		<xsl:choose>
			<xsl:when test="descendant::UML:MultiplicityRange/@upper = '1'">ForeignKey</xsl:when>
			<xsl:otherwise>ManyToManyField</xsl:otherwise>
		</xsl:choose>
	 	<xsl:text>(</xsl:text>
 			<!-- self reference? -->
 			<xsl:choose>
				<xsl:when test="$classid = $otherClassid">'self', </xsl:when>
				<xsl:otherwise>'<xsl:call-template name="getDjIdentifier"><xsl:with-param name="name" select="key('classes', $otherClassid)/@name"/></xsl:call-template>', </xsl:otherwise>
			</xsl:choose>
	 		<xsl:if test="descendant::UML:MultiplicityRange/@lower = '0'">blank=True, null=True, </xsl:if>
	 		<xsl:if test="descendant::UML:MultiplicityRange/@lower = '1'">blank=False, null=False, default=<xsl:call-template name="getDefaultValue"><xsl:with-param name="associationid"><xsl:value-of select="../../@xmi.id"/></xsl:with-param></xsl:call-template>, </xsl:if>
	 		<xsl:if test="descendant::UML:MultiplicityRange/@upper != '1'">
	 			<xsl:text>through='</xsl:text>
	 			<xsl:call-template name="getDjIdentifier"><xsl:with-param name="name" select="key('classes', ../UML:AssociationEnd[1]/UML:AssociationEnd.participant/UML:Class/@xmi.idref)/@name"/></xsl:call-template>
	 			<xsl:text>_</xsl:text>
	 			<xsl:call-template name="getDjIdentifier"><xsl:with-param name="name" select="key('classes', ../UML:AssociationEnd[2]/UML:AssociationEnd.participant/UML:Class/@xmi.idref)/@name"/></xsl:call-template>
	 			<xsl:text>', </xsl:text>
	 		</xsl:if>
			<xsl:choose>
		 		<xsl:when test="@name != ''">
		 			<xsl:text>related_name='</xsl:text>
		 			<xsl:call-template name="getDjIdentifier"><xsl:with-param name="name" select="@name"/></xsl:call-template>
		 			<xsl:text>', </xsl:text>
		 		</xsl:when>
		 		<xsl:when test="$endName != ''">
		 			<xsl:text>related_name='%(class)s_</xsl:text>
		 			<xsl:call-template name="getDjIdentifier"><xsl:with-param name="name" select="$endName"/></xsl:call-template>
		 			<xsl:text>', </xsl:text>
		 		</xsl:when>
			</xsl:choose>
			<xsl:for-each select="../../UML:ModelElement.taggedValue/UML:TaggedValue[UML:TaggedValue.type/UML:TagDefinition/@href = 'http://argouml.org/profiles/uml14/default-uml14.xmi#.:000000000000087C']">
				<xsl:call-template name="getHelpText">
					<xsl:with-param name="text" select="UML:TaggedValue.dataValue"/>
					<xsl:with-param name="fieldName" select="$fieldName"/>
				</xsl:call-template>
			</xsl:for-each>
	 	<xsl:text>)
 </xsl:text>
	 	</xsl:if>
	</xsl:for-each>	
</xsl:for-each>
</xsl:template>

<!-- ========================== -->
<!-- 	ATTRIBUTE TEMPLATE 		-->
<!-- ========================== -->

<xsl:template match="UML:Classifier.feature/UML:Attribute">
	<xsl:variable name="optional">
		<xsl:choose>
			<xsl:when test="UML:ModelElement.stereotype/UML:Stereotype[key('stereotypes', @xmi.idref)/@name = 'N']">
				<xsl:text>True</xsl:text>
			</xsl:when>
			<xsl:when test="UML:ModelElement.stereotype/UML:Stereotype[key('stereotypes', @xmi.idref)/@name = 'PK' or key('stereotypes', @xmi.idref)/@name = 'NN']">
				<xsl:text>False</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>True</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<!-- field_name = models.CharField(max_length = 128, unique = True) -->
	<xsl:if test="UML:StructuralFeature.type/UML:DataType/@href='http://argouml.org/profiles/uml14/default-uml14.xmi#-84-17--56-5-43645a83:11466542d86:-8000:000000000000087E'">
		<xsl:text><![CDATA[	]]># WARNING: use "Char X" Data Type instead of "String" to have more control over the length of this field
</xsl:text>
	</xsl:if>

	<xsl:variable name="fieldName" select="@name" />
	<xsl:variable name="fieldNameDj"><xsl:call-template name="getDjIdentifierL"><xsl:with-param name="name" select="$fieldName"/></xsl:call-template></xsl:variable>

	<![CDATA[	]]><xsl:value-of select="$fieldNameDj" />
	
	<xsl:variable name="datatype" select="key('datatypes', UML:StructuralFeature.type/UML:DataType/@xmi.idref)" />
	<xsl:choose>
		<xsl:when test="count($datatype) = 1 and $datatype/@name = 'FuzzyDate'">
			<xsl:text> = fields.</xsl:text>
		</xsl:when>
		<xsl:otherwise>
			<xsl:text> = models.</xsl:text>
		</xsl:otherwise>
	</xsl:choose>

	<!-- Type -->
	<xsl:if test="count($datatype) > 0">
		<xsl:for-each select="$datatype">
			<xsl:choose>
				<xsl:when test="@name='Char 8'" >CharField(max_length=8, null=False, default="", blank=<xsl:value-of select="$optional" />, </xsl:when>
				<xsl:when test="@name='Char 32'" >CharField(max_length=32, null=False, default="", blank=<xsl:value-of select="$optional" />, </xsl:when>
				<xsl:when test="@name='Char 128'" >CharField(max_length=128, null=False, default="", blank=<xsl:value-of select="$optional" />, </xsl:when>
				<xsl:when test="@name='Char 255'" >CharField(max_length=255, null=False, default="", blank=<xsl:value-of select="$optional" />, </xsl:when>
				<xsl:when test="@name='Char 1024'" >CharField(max_length=1024, null=False, default="", blank=<xsl:value-of select="$optional" />, </xsl:when>
				<xsl:when test="@name='TEI'" >XMLField(null=False, default="", blank=<xsl:value-of select="$optional" />, </xsl:when>
				<xsl:otherwise>
					<!-- let other django compatible types go through, eg. Integer, Float -->
					<!-- Need to detect them anyway because we need to set a default value eg. float => 0.0-->
					<xsl:value-of select="@name" /><xsl:text>Field(</xsl:text>
					<xsl:if test="@name = 'FuzzyDate'">null=<xsl:value-of select="$optional" />, modifier=True, blank=<xsl:value-of select="$optional" />, </xsl:if>
					<xsl:if test="@name = 'Date'">null=<xsl:value-of select="$optional" />, blank=<xsl:value-of select="$optional" />, </xsl:if>
					<xsl:if test="@name = 'DateTime'">null=<xsl:value-of select="$optional" />, blank=<xsl:value-of select="$optional" />, </xsl:if>
					<xsl:if test="@name = 'Time'">null=<xsl:value-of select="$optional" />, blank=<xsl:value-of select="$optional" />, </xsl:if>
					<xsl:if test="@name = 'Float'">null=<xsl:value-of select="$optional" />, blank=<xsl:value-of select="$optional" />, </xsl:if>
					<xsl:if test="@name = 'Text'">null=False, default="", blank=<xsl:value-of select="$optional" />, </xsl:if>
					<xsl:if test="@name = 'Integer'">null=<xsl:value-of select="$optional" />, blank=<xsl:value-of select="$optional" />, <xsl:if test="$optional = 'False'">default=0, </xsl:if></xsl:if>
					<xsl:if test="@name = 'Email'">null=<xsl:value-of select="$optional" />, blank=<xsl:value-of select="$optional" />, </xsl:if>
					<xsl:if test="@name = 'XML'">null=False, default="", blank=<xsl:value-of select="$optional" />, </xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:if>
	<xsl:if test="count($datatype) = 0">
		<!-- here we deal with core UML data types-->
		<xsl:choose>
			<!-- Support for UML Primitive Types expressed with ArgoUML ids. -->
			<!-- Support for UML primitive is important because it helps for quick prototyping without having to use the specific Data Types -->
			<!-- However the corresponding Django data type for UML "String" is arbitrary and may not be satisfactory in some cases -->
			<!-- Integer -->
			<xsl:when test="UML:StructuralFeature.type/UML:DataType/@href='http://argouml.org/profiles/uml14/default-uml14.xmi#-84-17--56-5-43645a83:11466542d86:-8000:000000000000087C'" >
				<xsl:text>IntegerField(null=</xsl:text><xsl:value-of select="$optional" />
				<xsl:text>, blank=</xsl:text><xsl:value-of select="$optional" />
				<xsl:if test="$optional = 'False'">, default=0</xsl:if>
				<xsl:text>, </xsl:text>
			</xsl:when>
			<!-- String -->
			<xsl:when test="UML:StructuralFeature.type/UML:DataType/@href='http://argouml.org/profiles/uml14/default-uml14.xmi#-84-17--56-5-43645a83:11466542d86:-8000:000000000000087E'" >
				<xsl:text>CharField(max_length=128, null=False, default="", blank=</xsl:text>
				<xsl:value-of select="$optional" />
				<xsl:text>, </xsl:text>
			</xsl:when>
			<!-- Boolean -->
			<xsl:when test="UML:StructuralFeature.type/UML:Enumeration/@href='http://argouml.org/profiles/uml14/default-uml14.xmi#-84-17--56-5-43645a83:11466542d86:-8000:0000000000000880'" >
				<xsl:text>BooleanField(default=False, null=False, blank=False, </xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>UnknownType(</xsl:text>
				# WARNING: Could not convert this <xsl:if test="UML:StructuralFeature.type/UML:DataType/@href">Data Type:</xsl:if><xsl:if test="UML:StructuralFeature.type/UML:Enumeration/@href">Enumeration:</xsl:if>
				# <xsl:value-of select="UML:StructuralFeature.type/UML:DataType/@href"/><xsl:value-of select="UML:StructuralFeature.type/UML:Enumeration/@href"/>
				#
			</xsl:otherwise>
		</xsl:choose>
	</xsl:if>
	<!-- Unique -->
	<!-- xsl:text>unique = True</xsl:text -->
	<!-- Match ArgoUML documentation to help_text
		 TODO: support tagged value with key named "documentation"
	-->
	<xsl:for-each select="UML:ModelElement.taggedValue/UML:TaggedValue[UML:TaggedValue.type/UML:TagDefinition/@href = 'http://argouml.org/profiles/uml14/default-uml14.xmi#.:000000000000087C']">
		<xsl:call-template name="getHelpText">
			<xsl:with-param name="text" select="UML:TaggedValue.dataValue"/>
			<xsl:with-param name="fieldName" select="$fieldName"/>
		</xsl:call-template>
	</xsl:for-each>
	<!-- xsl:text>help_text="</xsl:text><xsl:value-of select="" /><xsl:text>", </xsl:text -->
	<xsl:text>)
</xsl:text>
</xsl:template>

</xsl:stylesheet>
