#Explanation of the reasons why this project is currently dependent on ArgoUML diagram.

ArgoUML's XMI file contains references to vernacular identifiers for the data types and other metadata information (e.g. documentation field for an attribute).

For instance, in the following sample, a reference to a tag with id = 'http://argouml.org/profiles/uml14/default-uml14.xmi#-84-17--56-5-43645a83:11466542d86:-8000:000000000000087C' is used to declare an attribute as an Integer:

```
 <UML:Attribute xmi.id = '-119-73-122--119-3dde34f2:120c7e8cce4:-8000:000000000000109F'
                name = 'my attribute name' visibility = 'public' 
                isSpecification = 'false' ownerScope = 'instance'
                changeability = 'changeable' targetScope = 'instance'>

                 [...]

                  <UML:StructuralFeature.type>
                    <UML:DataType href = 'http://argouml.org/profiles/uml14/default-uml14.xmi#-84-17--56-5-43645a83:11466542d86:-8000:000000000000087C'/>
                  </UML:StructuralFeature.type>
```

This application-dependent identifiers makes UML to django incompatible with other UML authoring tools (Visio, etc.). One solution would be to detect which app generated the XMI and branch out the code for each one to recognise their own ids.