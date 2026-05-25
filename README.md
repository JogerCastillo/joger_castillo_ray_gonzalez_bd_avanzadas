# Laboratorio #1 - Almacenamiento y validación de ficheros XML

**AlumnoS:** Joger Gabriel Castillo Quitian Y Ray Sebastian De Jesús González Puello
**Asignatura:** Bases de Datos Avanzadas  

## Contenido del repositorio

- `data/joger_castillo_ray_gonzalez.xml` - Documento XML con datos de empleados, departamentos y cargos (esquema HR)
- `joger_castillo_ray_gonzalez.xsd` - Esquema XSD para validar el XML
- `joger_castillo_ray_gonzalez.xq` - Consultas XPath y XQuery (sintaxis para Oracle)
- `consulta_sql_xml.sql` - Consulta SQL/XML que genera el XML desde Oracle
- `registro_y_validacion.sql` - Registro del esquema e inserciones en Oracle
- `app.py` - Aplicación web en Flask que lee el XML y muestra los datos
- `templates/` - Plantillas HTML para la interfaz web
- `static/` - Archivos CSS
- `requirements.txt` - Dependencias de Python

## Cómo ejecutar la aplicación web

1. Tener Python 3.7 o superior instalado
2. Instalar las dependencias:  
   `pip install -r requirements.txt`
3. Ejecutar:  
   `python app.py`
4. Abrir en el navegador: `http://127.0.0.1:5000`

## Funcionalidades de la aplicación

- Lista de todos los empleados en formato tabla
- Departamentos con los empleados que pertenecen a cada uno
- Validación del XML contra el XSD usando lxml
- Ejemplos de consultas XQuery ejecutadas sobre el XML

## Notas

El archivo XML fue generado a partir del esquema HR de Oracle. Para la validación y consultas se utilizaron herramientas ligeras (Flask, lxml) que demuestran los mismos conceptos de validación y consulta sobre documentos XML.