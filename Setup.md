#Configuration instructions

## 1 Initial setup ##

  1. Prerequisites:
    1. you must have [python](http://www.python.org/), [django](http://www.djangoproject.com/) and [libxml2](http://xmlsoft.org/python.html) module installed. For windows users, [libxml2 can be obtained from xmlsoft.org's website](http://xmlsoft.org/sources/win32/python/).
    1. we assume that you have created a django project (let's call it PRJ) and an **empty** application (let's call it APP).
    1. We also assume that settings.py is correctly configured with a reference to a database and the admin and APP application are enabled. You also have successfully run 'python manage.py syncdb' and 'python manage.py runserver'.
  1. Download the zip file into your PRJ folder (the one that contains manage.py).
  1. Download & install [ArgoUML](http://argouml.tigris.org/).
  1. Open PRJ/uml2dj.zargo, rename it APP.zargo and draw a single class diagram (and nothing else in it).
  1. In ArgoUML, export your diagram as a XMI file: PRJ/APP.xmi
  1. Go to the command line, in the PRJ folder and type: 'python uml2dj APP'. This command will generate the models.py and admin.py files in your APP folder.
  1. In the PRJ/APP folder, rename `_`admin\_custom.py into admin\_custom.py and `_`models.py into models.py. (you only need to do this once).
  1. Commit the changes to the database: 'python manage.py syncdb'.
  1. Now run the server: 'python manage.py runserver'.
  1. Your new application should now be visible in the admin site.

## 2 Update the class diagram ##

  1. modify your diagram in ArgoUML and export it as PRJ/APP.xmi
  1. 'python uml2dj.py APP'
  1. Now your model has changed and the database needs to be resync'ed
    1. you can drop all the tables and resync the db from the app ('python uml2dj.py APP /d /s') OR
    1. if you want to preserve your data, you can use other tools to (semi-)automatically update your db schema. ([django-evolution](http://code.google.com/p/django-evolution/), [South](http://south.aeracode.org/) or this [database schema comparison utility](http://code.google.com/p/sql-dump-schema-diff/) made by myself)
  1. You'll probably need to restart your server ('python manage.py runserver').

## 3 Customise the model/admin files ##

You'll notice that the tool generate several admin and models files:
  * **admin.py**: this file is auto-generated, is should not be edited.
  * **`_`admin\_custom.py**: this file will contain your customisations of the admin.
  * **admin\_generic.py**: this file is auto-generated, is should not be edited.
  * **`_`models.py**: this file will contain your customisations of the models.
  * **models\_generic.py**: this file is auto-generated, is should not be edited.