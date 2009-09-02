'''
uml2dj.py

Run without arguments to see the documentation

@author: Goffer Looney

TODO:
    detect failures of external command calls (e.g. mysql, python)
    ...

'''

import libxml2
import libxslt
import sys
import re
import os

def start():
    if (len(sys.argv) < 2):
        print """Converts a XMI file to a models.py and admin.py files

%s application [/d] [/s] [/r]

  /d            drop all the tables used by that application, USE WITH CAUTION!
  /s            run syncdb
  /r            run django web server

XMI file must be in the current directory and its name is [application].xmi
""" % sys.argv[0]
    else:
        import settings
        import os
        prj_name = os.getcwd().rpartition(os.sep)[2]
        app_name = sys.argv[1]
        if '%s.%s' % (prj_name, app_name) not in settings.INSTALLED_APPS:
            print 'Application not installed %s.%s' % (prj_name, app_name)
            exit(1)
        if not os.path.exists("%s/__init__.py" % app_name):
            print '%s module not found' % (app_name)
            exit(1)
        if not os.path.exists("%s.xmi" % app_name):
            print '%s.xmi not found' % (app_name)
            exit(1)
        
        allchars = ''
        for arg in sys.argv[1:]:
            if (re.match('^/\w$', arg)):
                allchars += arg[1:2]
        pass
    
        if 'd' in allchars:
            print 'Drop tables'
            run_command('python manage.py sqlclear %s > droptables.sql' % app_name)
            run_command('mysql -u %s --password=%s %s < droptables.sql' % (settings.DATABASE_USER, settings.DATABASE_PASSWORD, settings.DATABASE_NAME))
            
        print 'Generate code'
        generate_code(app_name)
            
        if 's' in allchars:
            print 'Sync DB'
            import settings
            result = run_command('python manage.py syncdb')

        if 'r' in allchars:
            print 'Run Server'
            result = run_command('python manage.py runserver')

def generate_code(app_name):
    xmi_file = '%s.xmi' % app_name
    transform('xmi2djmodels.xsl', xmi_file, app_name+'/_models.py')
    transform('xmi2djmodels_generic.xsl', xmi_file, app_name+'/models_generic.py')
    transform('xmi2djadmin.xsl', xmi_file, app_name+'/admin.py')
    transform('xmi2djadmin_custom.xsl', xmi_file, app_name+'/_admin_custom.py')
    transform('xmi2djadmin_generic.xsl', xmi_file, app_name+'/admin_generic.py')

def run_command(command):
#    args = re.split('\s+', command.strip())
#    import subprocess
#    ret = subprocess.call(args)
#    return ret
    import os
    ret = os.system(command)
    return ret

def transform(xslt, source, target):
    styledoc = libxml2.parseFile(xslt)
    style = libxslt.parseStylesheetDoc(styledoc)
    doc = libxml2.parseFile(source)
    result = style.applyStylesheet(doc, None)
    style.saveResultToFilename(target, result, 0)
    style.freeStylesheet()
    doc.freeDoc()
    result.freeDoc()

start()