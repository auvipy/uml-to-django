**This tool automatically generates the Django model and admin interface from a UML class diagram.**

## How does it look like? ##

uml-to-django can convert this diagram (drawn with [ArgoUML](http://argouml.tigris.org/)):

![http://uml-to-django.googlecode.com/files/FilmsDiagram.png](http://uml-to-django.googlecode.com/files/FilmsDiagram.png)

automatically into this Django admin interface:

http://uml-to-django.googlecode.com/files/films-index.PNG

![http://uml-to-django.googlecode.com/files/Change%20Film%20_%20Django%20site%20admin.png](http://uml-to-django.googlecode.com/files/Change%20Film%20_%20Django%20site%20admin.png)

No manual python/django coding was involved in this conversion, the default application is completely generated for you.

However you can customise it after conversion. Customisations won't be lost if you re-run uml-to-django to include new changes from your UML diagram to the django code.

It currently works from a class diagram saved as a XMI file. Most UML authoring tools (Visio, ArgoUML, , Altova UModel, Visual Paradigm...) can export their diagrams in that format.

**Note that the current project has only been tested with diagrams generated with [ArgoUML](http://argouml.tigris.org/) (version 0.26)**.

## Configuration ##

Please read the instructions for [setting up and running uml-to-django](Setup.md).

## Philosophy ##

**Promote collaborative and transparent data modeling**

The main motivation behind this tool is to allow (UML) data modeling **before** and **during** the implementation of the database editing interface and your website. Other tools already allow you to do the opposite (i.e. generate a diagram from a Django model) but the point of UML is to collaboratively discuss, design and transform a model in a graphical form first and then implement it into a logical or physical model, not the opposite.

Therefore the main advantage offered by this tool is that it allows you to always keep your diagram and your application synchronised; you don't need to manually update one each time the other has been modified since this process is fully automated and fast. This prevents the actual data model to be completely encapsulated and obscured by the technical implementation, typically making the developers the only people with the knowledge about the conceptualisation of the information system and its details.

**Rapid application development for dummies**

Another important advantage of this tool is that it lets people build and maintain an entire database and web-based interface without any programming or strong technical knowledge. If you are not too demanding regarding the aesthetics of the web interface you can go a long way simply by drawing your tables and fields on a diagram.

**Delegate tasks to non-programmers**

As a corollary it also allows developer to delegate some tasks (such as documenting the fields) to non-technical people since the information is not hard-coded into a source code with a strict syntax but easily accessible via a graphical interface.

## Comments and contributions ##

There is a [discussion group about UML to Django](http://groups.google.com/group/uml-to-django) for all your questions and constructive comments. I'll do my best to help however I cannot guarantee prompt responses.

Do not hesitate to let me know if you feel like contributing to the code to improve this tool.