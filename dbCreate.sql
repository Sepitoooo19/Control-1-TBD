
-- CREACIÓN DE BASE DE DATOS --
-- Crear base de datos --
CREATE DATABASE colegio;



-- CREACIÓN DE TABLAS --

-- Tabla comuna --
CREATE TABLE comuna (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

-- Tabla colegio --
CREATE TABLE colegio (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    id_comuna INT NOT NULL,
    direccion VARCHAR(100),
    FOREIGN KEY (id_comuna) REFERENCES comuna(id) ON DELETE CASCADE
);


-- Tabla empleado --
CREATE TABLE empleado (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    rut VARCHAR(10) NOT NULL,
    sueldo FLOAT,
    id_colegio INT,
    id_comuna INT,
    rol VARCHAR(100) NOT NULL,
    FOREIGN KEY (id_colegio) REFERENCES colegio(id) ON DELETE CASCADE,
    FOREIGN KEY (id_comuna) REFERENCES comuna(id) ON DELETE CASCADE
);


-- Tabla profesor --
CREATE TABLE profesor (
    id SERIAL PRIMARY KEY,
    especialidad VARCHAR(100) NOT NULL,
    id_empleado INT,
    FOREIGN KEY (id_empleado) REFERENCES empleado(id) ON DELETE CASCADE
);


-- Tabla curso --
CREATE TABLE curso (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(20) NOT NULL,
    contenido_curso VARCHAR(100),
    id_colegio INT NOT NULL,
    FOREIGN KEY (id_colegio) REFERENCES colegio(id) ON DELETE CASCADE
);


-- Tabla curso_profesor --
CREATE TABLE curso_profesor (
    id_curso INT,
    id_profesor INT,
    esprofejefe BOOL,
    PRIMARY KEY (id_curso, id_profesor),
    FOREIGN KEY (id_curso) REFERENCES curso(id),
    FOREIGN KEY (id_profesor) REFERENCES profesor(id)
);


-- Tabla apoderado --
CREATE TABLE apoderado (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    rut VARCHAR(10) NOT NULL,
    id_comuna INT,
    parentesco VARCHAR(100) NOT NULL,
    FOREIGN KEY (id_comuna) REFERENCES comuna(id) ON DELETE CASCADE
);


-- Tabla alumno --
CREATE TABLE alumno (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    rut VARCHAR(10) NOT NULL,
    id_comuna INT,
    id_apoderado INT,
    id_curso INT,
    FOREIGN KEY (id_comuna) REFERENCES comuna(id),
    FOREIGN KEY (id_apoderado) REFERENCES apoderado(id),
    FOREIGN KEY (id_curso) REFERENCES curso(id)
);




-- Tabla franjahoraria --
CREATE TABLE franjahoraria (
    id SERIAL PRIMARY KEY,
    horario VARCHAR(100),
    id_curso INT,
    id_profesor INT,
    FOREIGN KEY (id_curso, id_profesor) REFERENCES curso_profesor(id_curso, id_profesor) ON DELETE CASCADE
);


-- Tabla asistencia --
CREATE TABLE asistencia (
    id SERIAL PRIMARY KEY,
    id_alumno INT,
    fecha DATE,
    estado BOOL,
    id_franja INT,
    FOREIGN KEY (id_alumno) REFERENCES alumno(id) ON DELETE CASCADE,
    FOREIGN KEY (id_franja) REFERENCES franjahoraria(id) ON DELETE CASCADE
);
