-- 1. Lista de profesores con su sueldo, indicando si son o no profesores jefe y los alumnos de su jefatura, si corresponde.

SELECT 
    e.nombre AS nombre_profesor,
    e.apellido AS apellido_profesor,
    e.sueldo,
    COALESCE(cp.esprofejefe, FALSE) AS es_profesor_jefe,
    COALESCE(STRING_AGG(a.nombre || ' ' || a.apellido, ', '), 'No aplica') AS alumnos_jefatura
FROM profesor p
JOIN empleado e ON e.id = p.id_empleado
LEFT JOIN curso_profesor cp ON cp.id_profesor = p.id AND cp.esprofejefe = TRUE
LEFT JOIN alumno a ON a.id_curso = cp.id_curso
GROUP BY e.id, e.nombre, e.apellido, e.sueldo, cp.esprofejefe
ORDER BY e.apellido, e.nombre;


-- 2. Lista de alumnos por curso con más inasistencias por mes en el año 2019.
WITH inasistencias_2019 AS (
    SELECT 
        a.id AS id_alumno,
        a.nombre || ' ' || a.apellido AS nombre_alumno,
        c.id AS id_curso,
        c.nombre AS nombre_curso,
        asist.fecha AS fecha,
        EXTRACT(MONTH FROM asist.fecha) AS mes
    FROM asistencia asist
    JOIN alumno a ON asist.id_alumno = a.id
    JOIN curso c ON a.id_curso = c.id
    WHERE asist.estado = false
      AND asist.fecha BETWEEN '2019-01-01' AND '2019-12-31'
),
conteo_por_mes AS (
    SELECT 
        id_alumno,
        nombre_alumno,
        id_curso,
        nombre_curso,
        mes,
        COUNT(*) AS total_inasistencias
    FROM inasistencias_2019
    GROUP BY id_alumno, nombre_alumno, id_curso, nombre_curso, mes
),
ranking AS (
    SELECT *,
           RANK() OVER (PARTITION BY id_curso, mes ORDER BY total_inasistencias DESC) AS rnk
    FROM conteo_por_mes
)
SELECT
    nombre_curso,
    mes,
    nombre_alumno,
    total_inasistencias
FROM ranking
WHERE rnk = 1
ORDER BY id_curso, mes;



-- 3. Lista de empleados identificando su rol, sueldo y comuna de residencia. Debe estar ordenada por comuna y sueldo.
SELECT 
    e.nombre || ' ' || e.apellido AS nombre_empleado,
    e.rol,
    e.sueldo,
    c.nombre AS comuna
FROM empleado e
JOIN comuna c ON e.id_comuna = c.id
ORDER BY comuna, sueldo DESC;

-- 4. Curso con menos alumnos por año.

SELECT DISTINCT ON (año)
    año,
    nombre_curso,
    nombre_colegio,
    cantidad_alumnos
FROM (
    SELECT
        EXTRACT(YEAR FROM a.fecha) AS año,
        c.nombre AS nombre_curso,
        col.nombre AS nombre_colegio,
        COUNT(DISTINCT al.id) AS cantidad_alumnos
    FROM curso c
    JOIN colegio col ON c.id_colegio = col.id
    JOIN alumno al ON al.id_curso = c.id
    JOIN franjahoraria f ON f.id_curso = c.id
    JOIN asistencia a ON a.id_franja = f.id AND a.id_alumno = al.id
    GROUP BY año, c.id, c.nombre, col.nombre
    ORDER BY año, cantidad_alumnos ASC
) sub
ORDER BY año, cantidad_alumnos ASC;


-- 5. Identificar por curso a los alumnos que no han faltado nunca.
SELECT
    c.nombre AS nombre_curso,
    col.nombre AS nombre_colegio,
    al.nombre AS nombre_alumno,
    al.apellido AS apellido_alumno,
    al.rut,
    0 AS inasistencias
FROM alumno al
JOIN curso c ON al.id_curso = c.id
JOIN colegio col ON c.id_colegio = col.id
WHERE NOT EXISTS (
    SELECT 1
    FROM asistencia a
    WHERE a.id_alumno = al.id
    AND a.estado = FALSE
)
AND EXISTS (
    SELECT 1
    FROM asistencia a
    WHERE a.id_alumno = al.id
)
ORDER BY c.nombre, al.apellido, al.nombre;

-- 6.  Profesor con más horas de clases y mostrar su sueldo.
SELECT 
    p.id AS id_profesor,
    e.nombre,
    e.apellido,
    COUNT(fh.id) AS cantidad_horas_clase,
    e.sueldo
FROM profesor p
JOIN empleado e ON p.id_empleado = e.id
JOIN franjahoraria fh ON fh.id_profesor = p.id
GROUP BY p.id, e.nombre, e.apellido, e.sueldo
ORDER BY cantidad_horas_clase DESC
LIMIT 1;

-- 7. Profesor con menos horas de clases y mostrar su sueldo.

SELECT 
    p.id AS id_profesor,
    e.nombre,
    e.apellido,
    COUNT(fh.id) AS cantidad_horas_clase,
    e.sueldo
FROM profesor p
JOIN empleado e ON p.id_empleado = e.id
LEFT JOIN franjahoraria fh ON fh.id_profesor = p.id
GROUP BY p.id, e.nombre, e.apellido, e.sueldo
ORDER BY cantidad_horas_clase ASC
LIMIT 1;

-- 8. Listado de alumnos por curso, donde el apoderado no es su padre o madre.

SELECT 
    c.nombre AS curso,
    a.nombre AS nombre_alumno,
    a.apellido AS apellido_alumno,
    ap.nombre AS nombre_apoderado,
    ap.apellido AS apellido_apoderado,
    ap.parentesco
FROM alumno a
JOIN curso c ON a.id_curso = c.id
JOIN apoderado ap ON a.id_apoderado = ap.id
WHERE LOWER(ap.parentesco) NOT IN ('padre', 'madre')
ORDER BY c.nombre, a.apellido;



-- 9. Colegio con mayor promedio de asistencia el año 2019, identificando la comuna.

SELECT 
    c.nombre AS colegio,
    com.nombre AS comuna,
    ROUND(AVG(CASE WHEN a.estado THEN 1 ELSE 0 END) * 100, 2) AS porcentaje_asistencia
FROM colegio c
JOIN comuna com ON c.id_comuna = com.id
JOIN curso cur ON cur.id_colegio = c.id
JOIN alumno al ON al.id_curso = cur.id
JOIN asistencia a ON a.id_alumno = al.id
WHERE EXTRACT(YEAR FROM a.fecha) = 2019
GROUP BY c.id, com.nombre
ORDER BY porcentaje_asistencia DESC
LIMIT 1;



-- 10. Lista de colegios con mayor número de alumnos por año.

SELECT DISTINCT ON (anio)
    anio,
    nombre_colegio,
    cantidad_alumnos
FROM (
    SELECT
        EXTRACT(YEAR FROM a.fecha) AS anio,
        col.nombre AS nombre_colegio,
        COUNT(DISTINCT alu.id) AS cantidad_alumnos
    FROM asistencia a
    JOIN alumno alu ON a.id_alumno = alu.id
    JOIN curso c ON alu.id_curso = c.id
    JOIN colegio col ON c.id_colegio = col.id
    GROUP BY EXTRACT(YEAR FROM a.fecha), col.nombre
) AS subquery
ORDER BY anio, cantidad_alumnos DESC;