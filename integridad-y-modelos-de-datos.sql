-- Prueba módulo SQL(
--  INTEGRIDAD y MODELOS,
--  de DATOS
--);

DROP DATABASE IF EXISTS "desafio4-lorenzo-chacano-124";
CREATE DATABASE "desafio4-lorenzo-chacano-124";
\c "desafio4-lorenzo-chacano-124"

-- 1. Crea el modelo (revisa bien cuál es el tipo de relación antes de crearlo), respeta las claves primarias, foráneas y tipos de datos

DROP TABLE IF EXISTS "peliculas";
CREATE TABLE "peliculas" (
    "id" SERIAL PRIMARY KEY,
    "nombre" VARCHAR (255),
    "anno" INT
);

DROP TABLE IF EXISTS "tags";
CREATE TABLE "tags" (
    "id" SERIAL PRIMARY KEY,
    "tag" VARCHAR (32)
);

DROP TABLE IF EXISTS "peliculas_tags";
CREATE TABLE "peliculas_tags" (
    "id" SERIAL PRIMARY KEY,
    "pelicula_id" INT DEFAULT NULL,
    "tag_id" INT DEFAULT NULL
);

ALTER TABLE "peliculas_tags" ADD FOREIGN KEY ("pelicula_id") REFERENCES "peliculas" ("id");
ALTER TABLE "peliculas_tags" ADD FOREIGN KEY ("tag_id") REFERENCES "tags" ("id");

-- 2. Inserta 5 películas y 5 tags,

INSERT INTO "peliculas" ("nombre", "anno") VALUES ('The Godfather', 1972);
INSERT INTO "peliculas" ("nombre", "anno") VALUES ('The Return of the King', 2003);
INSERT INTO "peliculas" ("nombre", "anno") VALUES ('The Dark Knight', 2008);
INSERT INTO "peliculas" ("nombre", "anno") VALUES ('2001: A Space Oddysey', 1968);
INSERT INTO "peliculas" ("nombre", "anno") VALUES ('The Shawshank Redemption', 1994);

INSERT INTO "tags" ("tag") VALUES ('Drama');
INSERT INTO "tags" ("tag") VALUES ('Crime');
INSERT INTO "tags" ("tag") VALUES ('Action');
INSERT INTO "tags" ("tag") VALUES ('Sci-Fi');
INSERT INTO "tags" ("tag") VALUES ('Adventure');

-- la primera película tiene que tener 3 tags asociados, 
-- la segunda película debe tener dos tags asociados.

INSERT INTO "peliculas_tags" ("pelicula_id", "tag_id") VALUES (1, 1);
INSERT INTO "peliculas_tags" ("pelicula_id", "tag_id") VALUES (1, 2);
INSERT INTO "peliculas_tags" ("pelicula_id", "tag_id") VALUES (1, 3);
INSERT INTO "peliculas_tags" ("pelicula_id", "tag_id") VALUES (2, 1);
INSERT INTO "peliculas_tags" ("pelicula_id", "tag_id") VALUES (2, 5);

-- 3. Cuenta la cantidad de tags que tiene cada película. 
-- Si una película no tiene tags debe mostrar 0.

SELECT p.id, p.nombre, count(pt.id) as tags 
FROM "peliculas" p 
LEFT JOIN "peliculas_tags" pt 
ON p.id = pt.pelicula_id 
GROUP BY p.id, p.nombre
ORDER BY p.id;

-- 4. Crea las tablas respetando los nombres, tipos, claves primarias y foráneas y tipos de datos.

DROP TABLE IF EXISTS "preguntas";
CREATE TABLE "preguntas" (
    "id" SERIAL PRIMARY KEY,
    "pregunta" VARCHAR(255) DEFAULT NULL,
    "respuesta_correcta" VARCHAR
);

DROP TABLE IF EXISTS "usuarios";
CREATE TABLE "usuarios" (
    "id" SERIAL PRIMARY KEY,
    "nombre" VARCHAR(255) DEFAULT NULL,
    "edad" INT
);

DROP TABLE IF EXISTS "respuestas";
CREATE TABLE "respuestas" (
    "id" SERIAL PRIMARY KEY,
    "respuesta" VARCHAR(255) DEFAULT NULL,
    "pregunta_id" INT,
    "usuario_id" INT
);

ALTER TABLE "respuestas" ADD FOREIGN KEY ("pregunta_id") REFERENCES "preguntas" ("id");
ALTER TABLE "respuestas" ADD FOREIGN KEY ("usuario_id") REFERENCES "usuarios" ("id");

-- 5. Agrega datos, 5 usuarios y 5 preguntas, 

INSERT INTO "preguntas" ("pregunta", "respuesta_correcta") VALUES ('No quiero soñar mil veces las', 'mismas cosas');
INSERT INTO "preguntas" ("pregunta", "respuesta_correcta") VALUES ('Es que este amor es azul como el', 'mar azul');
INSERT INTO "preguntas" ("pregunta", "respuesta_correcta") VALUES ('Ya viene la fuerza, la voz de', 'los 80');
INSERT INTO "preguntas" ("pregunta", "respuesta_correcta") VALUES ('La mano arriba, cintura sola, da media vuelta', 'danza kuduro');
INSERT INTO "preguntas" ("pregunta", "respuesta_correcta") VALUES ('He barrido el sol de este', 'lugar');

INSERT INTO "usuarios" ("nombre", "edad") VALUES ('Tomás', 30);
INSERT INTO "usuarios" ("nombre", "edad") VALUES ('Esteban', 54);
INSERT INTO "usuarios" ("nombre", "edad") VALUES ('Mariana', 28);
INSERT INTO "usuarios" ("nombre", "edad") VALUES ('Javiera', 22);
INSERT INTO "usuarios" ("nombre", "edad") VALUES ('Marcelo', 43);

-- la primera pregunta debe estar contestada dos veces correctamente por distintos usuarios, 

INSERT INTO "respuestas" ("respuesta", "pregunta_id", "usuario_id") VALUES ('mismas cosas', 1, 1);
INSERT INTO "respuestas" ("respuesta", "pregunta_id", "usuario_id") VALUES ('mismas cosas', 1, 2);

-- la pregunta 2 debe estar contestada tres veces: correctamente sólo por un usuario

INSERT INTO "respuestas" ("respuesta", "pregunta_id", "usuario_id") VALUES ('mar azul', 2, 3);

-- y las otras 2 respuestas deben estar incorrectas.

INSERT INTO "respuestas" ("respuesta", "pregunta_id", "usuario_id") VALUES ('cielo', 2, 4);
INSERT INTO "respuestas" ("respuesta", "pregunta_id", "usuario_id") VALUES ('cielo', 2, 5);

-- 6. Cuenta la cantidad de respuestas correctas totales por usuario (independiente de la pregunta)

SELECT u.nombre, count(r.id) as respuestas_correctas
FROM usuarios u
INNER JOIN respuestas r ON u.id = r.usuario_id
INNER JOIN preguntas p ON p.id = r.pregunta_id
WHERE p.respuesta_correcta = r.respuesta
GROUP BY u.nombre
ORDER BY u.nombre;

-- 7. Por cada pregunta, en la tabla preguntas, cuenta cuántos usuarios tuvieron la respuesta correcta.

SELECT p.pregunta, p.respuesta_correcta, count(r.id) as respuestas_correctas
FROM preguntas p
LEFT JOIN respuestas r ON p.id = r.pregunta_id
GROUP BY p.id
ORDER BY p.id;

-- 8. Implementa borrado en cascada de las respuestas al borrar un usuario

ALTER TABLE "respuestas" DROP CONSTRAINT "respuestas_usuario_id_fkey";
ALTER TABLE "respuestas" ADD CONSTRAINT "respuestas_usuario_id_fkey" FOREIGN KEY ("usuario_id") REFERENCES "usuarios" ("id") ON DELETE CASCADE;

-- y borrar el primer usuario para probar la implementación

DELETE FROM usuarios WHERE id = 1;

SELECT * FROM usuarios;
SELECT * FROM respuestas;

-- 9. Crea una restricción que impida insertar usuarios menores de 18 años en la base de datos.

ALTER TABLE usuarios 
ADD CONSTRAINT edad_mayor_a_18 CHECK (edad >= 18);

INSERT INTO usuarios (nombre, edad) VALUES ('Lorenzo', 17);

-- 10. Altera la tabla existente de usuarios agregando el campo email con la restricción de único.

ALTER TABLE usuarios 
ADD COLUMN email VARCHAR(255) UNIQUE;

INSERT INTO usuarios (nombre, edad, email) VALUES ('Usuario', 20, 'usuario@gmail.com');

INSERT INTO usuarios (nombre, edad, email) VALUES ('Usuario 2', 40, 'usuario@gmail.com');
