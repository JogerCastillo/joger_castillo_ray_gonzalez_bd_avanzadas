-- Consultas XPath mediante XMLTABLE


-- Todos los empleados con su departamento y salario
SELECT x.id_emp, x.nombre, x.apellido, x.salario, x.departamento
FROM empleados_xml e,
     XMLTABLE('/empleados/empleado'
       PASSING e.datos
       COLUMNS
         id_emp       NUMBER        PATH '@id',
         nombre       VARCHAR2(50)  PATH 'nombre',
         apellido     VARCHAR2(50)  PATH 'apellido',
         salario      NUMBER        PATH 'salario',
         departamento VARCHAR2(100) PATH 'departamento/nombre'
     ) x;


-- Empleados del departamento IT
SELECT x.nombre, x.apellido, x.cargo
FROM empleados_xml e,
     XMLTABLE('/empleados/empleado[departamento/id = 60]'
       PASSING e.datos
       COLUMNS
         nombre   VARCHAR2(50)  PATH 'nombre',
         apellido VARCHAR2(50)  PATH 'apellido',
         cargo    VARCHAR2(100) PATH 'cargo/titulo'
     ) x;


-- Empleados con salario superior a 10000
SELECT x.nombre, x.apellido, x.salario
FROM empleados_xml e,
     XMLTABLE('/empleados/empleado[salario > 10000]'
       PASSING e.datos
       COLUMNS
         nombre   VARCHAR2(50) PATH 'nombre',
         apellido VARCHAR2(50) PATH 'apellido',
         salario  NUMBER       PATH 'salario'
     ) x;


-- Verificar si existe un empleado con cargo de Presidente
SELECT e.id_registro,
       CASE
         WHEN XMLEXISTS('/empleados/empleado[cargo/id = "AD_PRES"]'
                        PASSING e.datos)
         THEN 'Sí'
         ELSE 'No'
       END AS tiene_presidente
FROM empleados_xml e;


-- Nombre completo y fecha de contratación del empleado id=100
SELECT x.nombre_completo, x.fecha_contratacion
FROM empleados_xml e,
     XMLTABLE('/empleados/empleado[@id = 100]'
       PASSING e.datos
       COLUMNS
         nombre_completo    VARCHAR2(100) PATH 'concat(nombre, " ", apellido)',
         fecha_contratacion VARCHAR2(20)  PATH 'fecha_contratacion'
     ) x;


-- Consultas XQuery mediante XMLQUERY


-- Empleados ordenados por salario de mayor a menor
SELECT XMLQUERY(
  'for $e in /empleados/empleado
   order by xs:decimal($e/salario) descending
   return <empleado id="{$e/@id}">
            {$e/nombre}
            {$e/apellido}
            {$e/salario}
          </empleado>'
  PASSING e.datos
  RETURNING CONTENT
) AS resultado
FROM empleados_xml e;


-- Empleados del departamento Sales
SELECT XMLQUERY(
  'for $e in /empleados/empleado
   where $e/departamento/nombre = "Sales"
   return <vendedor id="{$e/@id}">
            <nombre_completo>{$e/nombre/text()} {$e/apellido/text()}</nombre_completo>
            {$e/cargo/titulo}
            {$e/salario}
          </vendedor>'
  PASSING e.datos
  RETURNING CONTENT
) AS resultado
FROM empleados_xml e;


-- Empleados contratados antes del año 2000, ordenados por fecha
SELECT XMLQUERY(
  'for $e in /empleados/empleado
   where $e/fecha_contratacion < "2000-01-01"
   order by $e/fecha_contratacion ascending
   return <empleado_antiguo>
            <nombre>{$e/nombre/text()} {$e/apellido/text()}</nombre>
            <contratacion>{$e/fecha_contratacion/text()}</contratacion>
          </empleado_antiguo>'
  PASSING e.datos
  RETURNING CONTENT
) AS resultado
FROM empleados_xml e;


-- Empleados agrupados por departamento
SELECT XMLQUERY(
  'let $deps := distinct-values(/empleados/empleado/departamento/nombre)
   for $dep in $deps
   order by $dep ascending
   return <departamento nombre="{$dep}">
     {
       for $e in /empleados/empleado[departamento/nombre = $dep]
       return <empleado id="{$e/@id}">{$e/nombre/text()} {$e/apellido/text()}</empleado>
     }
   </departamento>'
  PASSING e.datos
  RETURNING CONTENT
) AS resultado
FROM empleados_xml e;


-- Total de empleados por departamento
SELECT XMLQUERY(
  'let $deps := distinct-values(/empleados/empleado/departamento/nombre)
   for $dep in $deps
   let $total := count(/empleados/empleado[departamento/nombre = $dep])
   order by $total descending
   return <conteo>
            <departamento>{$dep}</departamento>
            <total>{$total}</total>
          </conteo>'
  PASSING e.datos
  RETURNING CONTENT
) AS resultado
FROM empleados_xml e;
