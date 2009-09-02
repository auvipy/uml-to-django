<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
								xmlns:UML="org.omg.xmi.namespace.UML"
								xmlns:xmidj="xmi2dj.cch.kcl.ac.uk"
								xmlns:fn="http://www.w3.org/2005/xpath-functions">
<xsl:import href="xmilib.xsl"/>

<xsl:output method="text" omit-xml-declaration="yes" indent="no" />

<xsl:key name="classes" match="//UML:Class" use="@xmi.id" />

<xsl:template match="/">
<xml:text># auto generated from an XMI file
# this file can be edit, 
# make sure it is renamed into "admin_custom.py" (without the underscore at the beginning)
from models import *
from admin_generic import *
from django.contrib import admin
 
</xml:text>
<xsl:apply-templates select="/XMI/XMI.content/UML:Model/UML:Namespace.ownedElement//UML:Association/UML:Association.connection"/>
<xsl:apply-templates select="//UML:Class[@name and @name != '' and not(starts-with(@name,'_'))]"/>
</xsl:template>

<xsl:template match="//UML:Class">
#
class <xsl:value-of select="translate(@name, ' ', '_')" />Admin(<xsl:value-of select="translate(@name, ' ', '_')" />Admin):
	pass
</xsl:template>

<xsl:template match="UML:Association.connection">
	<xsl:param name="className">
		<xsl:value-of select="translate(key('classes', UML:AssociationEnd[1]/UML:AssociationEnd.participant/UML:Class/@xmi.idref)/@name, ' ', '_')" />
		<xsl:text>_</xsl:text>
		<xsl:value-of select="translate(key('classes', UML:AssociationEnd[2]/UML:AssociationEnd.participant/UML:Class/@xmi.idref)/@name, ' ', '_')" />
	</xsl:param>
	<xsl:if test="UML:AssociationEnd[1]//UML:MultiplicityRange/@upper = '-1' and UML:AssociationEnd[2]//UML:MultiplicityRange/@upper = '-1'">

<xsl:text>
#
class </xsl:text><xsl:value-of select="$className"/><xsl:text>Inline(</xsl:text><xsl:value-of select="$className"/><xsl:text>Inline):
	pass
</xsl:text>
	</xsl:if>
</xsl:template>

</xsl:stylesheet>