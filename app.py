from flask import Flask, render_template
from lxml import etree
import os

app = Flask(__name__)

ruta_xml = os.path.join('data', 'joger_castillo_ray_gonzalez.xml')
ruta_xsd = 'joger_castillo_ray_gonzalez.xsd'

def cargar_xml():
    if not os.path.exists(ruta_xml):
        return None
    return etree.parse(ruta_xml)

@app.route('/')
def inicio():
    arbol = cargar_xml()
    return render_template('principal.html', arbol=arbol)

@app.route('/empleados')
def empleados():
    arbol = cargar_xml()
    if arbol is None:
        return "No se encuentra el archivo XML", 404
    
    empleados_lista = []
    for emp in arbol.xpath('/empleados/empleado'):
        emp_data = {
            'id': emp.get('id'),
            'nombre': emp.xpath('string(nombre)'),
            'apellido': emp.xpath('string(apellido)'),
            'email': emp.xpath('string(email)'),
            'telefono': emp.xpath('string(telefono)'),
            'fecha_contratacion': emp.xpath('string(fecha_contratacion)'),
            'salario': emp.xpath('string(salario)'),
            'departamento': emp.xpath('string(departamento/nombre)'),
            'cargo': emp.xpath('string(cargo/titulo)')
        }
        empleados_lista.append(emp_data)
    
    return render_template('lista_empleados.html', empleados=empleados_lista)

@app.route('/departamentos')
def departamentos():
    arbol = cargar_xml()
    if arbol is None:
        return "No se encuentra el archivo XML", 404
    
    deptos = {}
    for emp in arbol.xpath('/empleados/empleado'):
        depto_id = emp.xpath('string(departamento/id)')
        depto_nombre = emp.xpath('string(departamento/nombre)')
        if depto_id not in deptos:
            deptos[depto_id] = {
                'id': depto_id,
                'nombre': depto_nombre,
                'empleados': []
            }
        deptos[depto_id]['empleados'].append({
            'id': emp.get('id'),
            'nombre': emp.xpath('string(nombre)'),
            'apellido': emp.xpath('string(apellido)')
        })
    
    return render_template('ver_departamentos.html', departamentos=deptos.values())

@app.route('/validar')
def validar():
    try:
        with open(ruta_xml, 'rb') as f:
            doc_xml = etree.parse(f)
        with open(ruta_xsd, 'rb') as f:
            doc_xsd = etree.parse(f)
        
        esquema = etree.XMLSchema(doc_xsd)
        esquema.assertValid(doc_xml)
        
        return render_template('validar_xsd.html', valido=True, mensaje="El XML es valido contra el XSD")
    except Exception as e:
        return render_template('validar_xsd.html', valido=False, mensaje=f"Error: {e}")

@app.route('/xquery')
def xquery():
    arbol = cargar_xml()
    if arbol is None:
        return "No se encuentra el archivo XML", 404
    
    resultados = {}
    
    # emp con salario > 10000
    resultados['salario_alto'] = []
    for emp in arbol.xpath('/empleados/empleado[salario > 10000]'):
        resultados['salario_alto'].append({
            'nombre': f"{emp.xpath('string(nombre)')} {emp.xpath('string(apellido)')}",
            'salario': emp.xpath('string(salario)')
        })
    
    # emp del depto IT (id 60)
    resultados['it_empleados'] = []
    for emp in arbol.xpath('/empleados/empleado[departamento/id = "60"]'):
        resultados['it_empleados'].append({
            'nombre': f"{emp.xpath('string(nombre)')} {emp.xpath('string(apellido)')}",
            'cargo': emp.xpath('string(cargo/titulo)')
        })
    
    # emp contratados antes de 1990
    resultados['antiguos'] = []
    for emp in arbol.xpath('/empleados/empleado[fecha_contratacion < "1990-01-01"]'):
        resultados['antiguos'].append({
            'nombre': f"{emp.xpath('string(nombre)')} {emp.xpath('string(apellido)')}",
            'fecha': emp.xpath('string(fecha_contratacion)')
        })
    
    # conteo por depto
    resultados['conteo_deptos'] = {}
    for depto in arbol.xpath('/empleados/empleado/departamento/nombre'):
        nombre_depto = depto.text
        if nombre_depto in resultados['conteo_deptos']:
            resultados['conteo_deptos'][nombre_depto] += 1
        else:
            resultados['conteo_deptos'][nombre_depto] = 1
    
    return render_template('ejemplos_xquery.html', resultados=resultados)

if __name__ == '__main__':
    app.run(debug=True)