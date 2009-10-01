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
<xsl:output method="text" omit-xml-declaration="yes" indent="no" />

<!-- ========================== -->
<!-- 		ROOT TEMPLATE 		-->
<!-- ========================== -->

<xsl:template match="/">
<xml:text># -*- coding: utf-8 -*-
# auto generated from an XMI file
# from django.db import models
from models_generic import *

</xml:text>

</xsl:template>

</xsl:stylesheet>
