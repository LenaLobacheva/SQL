
	1. Создание таблиц


CREATE TABLE teachers (
id INTEGER PRIMARY KEY AUTOINCREMENT,
name TEXT NOT NULL,
surname TEXT NOT NULL,
mail TEXT NOT NULL UNIQUE);

CREATE TABLE courses (
id INTEGER PRIMARY KEY AUTOINCREMENT,
title TEXT NOT NULL UNIQUE);

CREATE TABLE streams (
id INTEGER PRIMARY KEY AUTOINCREMENT,
course_id INTEGER NOT NULL,
number_streams INTEGER NOT NULL UNIQUE,
start_date TEXT NOT NULL,
number_students INTEGER NOT NULL UNIQUE,
FOREIGN KEY (course_id) REFERENCES course (id));

CREATE TABLE grades (
teachers_id INTEGER NOT NULL,
stream_id INTEGER NOT NULL,
grade REAL NOT NULL,
PRIMARY KEY(teachers_id, stream_id),
FOREIGN KEY (teachers_id) REFERENCES teachers(id),
FOREIGN KEY (stream_id) REFERENCES streams(id));


	2. Работа с данными


/* После создания таблиц необходимо выполнить следующее:
1. В таблице streams переименовать столбец даты начала обучения в started_at.
2. В таблице streams добавить столбец даты завершения обучения в finished_at.
3. Заполнить таблицы данными */

ALTER TABLE streams ADD COLUMN finished_at TEXT;
ALTER TABLE streams RENAME COLUMN number_students TO students_amount;
ALTER TABLE grades RENAME COLUMN grade TO perfomance;
ALTER TABLE courses RENAME COLUMN title TO name;
ALTER TABLE teachers RENAME COLUMN mail TO email;
ALTER TABLE streams RENAME COLUMN number_streams TO number;

INSERT INTO courses (id, name) VALUES
(1, 'Базы данных');
INSERT INTO courses (name) VALUES
('Основы Python'),
('Linux. Рабочая станция');
SELECT * FROM courses;

INSERT INTO teachers (id, name, surname, email) VALUES
(1, 'Николай', 'Савельев', 'saveliev.n@mail.ru');
INSERT INTO teachers (name, surname, email) VALUES
('Наталья', 'Петрова', 'petrova.n@mail.ru'),
('Елена', 'Малышева', 'malisheva.e@mail.ru');

INSERT INTO streams (id, course_id, number, started_at, students_amount) VALUES
(1, 3, 165, '18.08.2020', 34);
INSERT INTO streams (course_id, number, started_at, students_amount) VALUES
(2, 178, '02.10.2020', 37),
(1, 203, '12.11.2020', 35),
(1, 210, '03.12.2020', 41);

INSERT INTO grades (teachers_id, stream_id, perfomance) VALUES
(3, 1, 4.7);
INSERT INTO grades (teachers_id, stream_id, perfomance) VALUES
(2, 2, 4.9),
(1, 3, 4.8),
(1, 4, 4.9);

	Дополнительное задание
/*в таблице успеваемости изменить тип столбца «Ключ потока» на REAL. Выполнить задание на таблице с данными.*/

PRAGMA foreign_keys=off;
BEGIN TRANSACTION;
ALTER TABLE grades RENAME TO grades_old;
CREATE TABLE grades (
teachers_id INTEGER NOT NULL,
stream_id REAL NOT NULL,
grade REAL NOT NULL,
PRIMARY KEY(teachers_id, stream_id),
FOREIGN KEY (teachers_id) REFERENCES teachers(id),
FOREIGN KEY (stream_id) REFERENCES streams(id));
INSERT INTO grades (teachers_id, stream_id, perfomance) VALUES
(3, 1, 4.7);
INSERT INTO grades (teachers_id, stream_id, perfomance) VALUES
(2, 2, 4.9),
(1, 3, 4.8),
(1, 4, 4.9);
COMMIT;
PRAGMA foreign_keys=on;
.schema grades
SELECT * FROM grades;
DROP TABLE grades_old;

	3. Выборка и агрегация данных

/*
1. Преобразовать дату начала потока в таблице потоков к виду год-месяц-день. Используйте команду UPDATE.
2. Получите идентификатор и номер потока, запланированного на самую позднюю дату.
3. Покажите уникальные значения года по датам начала потоков обучения.
4. Найдите количество преподавателей в базе данных. Выведите искомое значение в столбец с именем total_teachers.
5. Покажите даты начала двух последних по времени потоков.
6. Найдите среднюю успеваемости учеников по потокам преподавателя с идентификатором равным 1.
7. Дополнительное задание (выполняется по желанию): найдите идентификаторы преподавателей, у которых средняя успеваемость по всем потокам меньше 4.8.*/

SELECT started_at FROM streams;

1. SELECT SUBSTR(started_at, 7, 4) || '-' || SUBSTR(started_at, 4, 2) || '-' || SUBSTR(started_at, 1, 2) FROM streams;

UPDATE streams SET started_at = SUBSTR(started_at, 7, 4) || '-' || SUBSTR(started_at, 4, 2) || '-' || SUBSTR(started_at, 1, 2);

.header on

2. SELECT id, number 
FROM streams 
ORDER BY started_at DESC
LIMIT 1;

3. SELECT started_at, COUNT(*) FROM streams GROUP BY started_at;

4. SELECT COUNT(id) FROM teachers AS 'total_teachers';

5. SELECT started_at
FROM streams 
ORDER BY started_at DESC
LIMIT 2;

6. SELECT teachers_id, AVG(perfomance)
FROM grades 
WHERE teachers_id = 1;


	Дополнительное задание

SELECT teachers_id
FROM grades 
GROUP BY teachers_id 
HAVING AVG(perfomance) < 4.8; 


	4. Вложенные запросы и объединение
/*
1. Найдите потоки, количество учеников в которых больше или равно 40. В отчет выведите номер потока, название курса и количество учеников.
2. Найдите два потока с самыми низкими значениями успеваемости. В отчет выведите номер потока, название курса, фамилию и имя преподавателя (одним столбцом), оценку успеваемости.
3. Найдите среднюю успеваемость всех потоков преподавателя Николая Савельева. В отчёт выведите идентификатор преподавателя и среднюю оценку по потокам.
4. Найдите потоки преподавателя Натальи Петровой, а также потоки, по которым успеваемость ниже 4.8. В отчёт выведите идентификатор потока, фамилию и имя преподавателя. В отчёте должно быть 3 столбца - идентификатор потока, фамилия преподавателя, имя преподавателя.
5. Дополнительное задание. Найдите разницу между средней успеваемостью преподавателя с наивысшим соответствующим значением и средней успеваемостью преподавателя с наименьшим значением. Средняя успеваемость считается по всем потокам преподавателя.*/

1.
SELECT number,
(SELECT name FROM courses WHERE id = streams.course_id)
AS course_name,
students_amount FROM streams
WHERE students_amount >= 40;

2.
SELECT 
(SELECT number FROM streams WHERE id =
(SELECT course_id FROM streams WHERE id = stream_id)) AS number,
(SELECT name FROM courses WHERE id = 
(SELECT course_id FROM streams WHERE id = stream_id)) AS course_name, 
(SELECT (name || ' ' || surname) FROM teachers WHERE id = teachers_id) AS fullname,
perfomance 
FROM grades ORDER BY perfomance ASC LIMIT 2;

3.
SELECT 
(SELECT id FROM teachers WHERE surname = 'Савельев' AND name = 'Николай') AS id,
AVG(perfomance)
FROM grades WHERE teachers_id = 1;

4.
SELECT 
stream_id,
(SELECT name FROM teachers WHERE id=teacher_id) AS teacher_name,
(SELECT surname FROM teachers WHERE id=teacher_id) AS teacher_surname
FROM grades WHERE teacher_id = (SELECT id FROM teachers WHERE surname = 'Петрова' AND name = 'Наталья')
UNION 
SELECT
stream_id,
(SELECT name FROM teachers WHERE id=teacher_id) AS teacher_name,
(SELECT surname FROM teachers WHERE id=teacher_id) AS teacher_surname
FROM grades WHERE performance < 4.8;


	5. Объединение JOIN

/*
1. Покажите информацию по потокам. В отчет выведите номер потока, название курса и дату начала занятий.
2. Найдите общее количество учеников для каждого курса. В отчёт выведите название курса и количество учеников по всем потокам курса.
3. Для всех учителей найдите среднюю оценку по всем проведённым потокам. В отчёт выведите идентификатор, фамилию и имя учителя, среднюю оценку по всем проведенным потокам. Важно чтобы учителя, у которых не было потоков, также попали в выборку.*/

1.
SELECT number, name, started_at FROM streams 
JOIN courses
ON courses.id = streams.course_id;

2.
SELECT name, SUM (students_amount) AS 'students_total' FROM streams 
JOIN courses
ON courses.id = streams.course_id
GROUP BY name;

3.
SELECT id, name, surname, AVG(perfomance)
FROM teachers 
LEFT JOIN grades
ON teachers.id = grades.teachers_id
GROUP BY teachers_id;

4.
SELECT 
(SELECT (name || ' ' || surname) FROM teachers WHERE id = teachers_id) AS fullname,
(SELECT min(perfomance) FROM grades)  AS min,
(SELECT max(perfomance) FROM grades)  AS max
FROM teachers
INNER JOIN grades
ON teachers.id = grades.teachers_id
INNER JOIN streams
ON grades.stream_id = streams.id
INNER JOIN courses (SELECT name FROM courses WHERE id = (SELECT course_id FROM streams WHERE id = stream_id)) AS course_name
ON streams.course_id = courses.id;


	6. Расширенные возможности SQL

/*
1. Создайте представление, которое для каждого курса выводит название, номер последнего потока, дату начала обучения последнего потока и среднюю успеваемость курса по всем потокам.
2. Удалите из базы данных всю информацию, которая относится к преподавателю с идентификатором, равным 3. Используйте транзакцию.
3. Создайте триггер для таблицы успеваемости, который проверяет значение успеваемости на соответствие диапазону чисел от 0 до 5 включительно.
4. Дополнительное задание. Создайте триггер для таблицы потоков, который проверяет, что дата начала потока больше текущей даты, а номер потока имеет наибольшее значение среди существующих номеров. При невыполнении условий необходимо вызвать ошибку с информативным сообщением.*/

1.
CREATE VIEW course_info AS
SELECT
courses.name AS course_name,
streams.number AS stream_number,
streams.started_at AS start_day,
AVG(grades.perfomance) AS AVG_grade
FROM streams 
LEFT JOIN grades
ON grades.stream_id = streams.id
LEFT JOIN courses
ON streams.course_id = courses.id
GROUP BY name;

2. 
BEGIN TRANSACTION;
DELEETE FROM grades WHERE teachers_id = 3;
DELETE FROM teachers WHERE id = 3;
COMMIT;

3.
CREATE TRIGGER trg_grade BEFORE INSERT
ON grades 
BEGIN
SELECT CASE 
WHEN
NEW.perfomance NOT BETWEEN 0 AND 5
THEN 
RAISE (ABORT, 'Incorrect value')
END;
END;

Проверка
INSERT INTO grades (perfomance) VALUES (6);
Error: stepping, Incorrect value (19)

4.
CREATE TRIGGER trg_streams BEFORE INSERT 
ON streams
BEGIN
SELECT CASE
WHEN 
(NEW.started_at > CURRENT_DATE ('2022-02-05'))
OR
(NEW.number MAX(number))
THEN
RAISE(ABORT, 'Ошибка! Проверьте данные!')
END;
END;


	7. Оконные функции, индексы

/*
1. Найдите общее количество учеников для каждого курса. В отчёт выведите название курса и количество учеников по всем потокам курса. Решите задание с применением оконных функций.
2. Найдите среднюю оценку по всем потокам для всех учителей. В отчёт выведите идентификатор, фамилию и имя учителя, среднюю оценку по всем проведённым потокам. Учителя, у которых не было потоков, также должны попасть в выборку. Решите задание с применением оконных функций.
3. Какие индексы надо создать для максимально быстрого выполнения представленного запроса?
SELECT
surname,
name,
number,
performance
FROM academic_performance
JOIN teachers
ON academic_performance.teacher_id = teachers.id
JOIN streams
ON academic_performance.stream_id = streams.id
WHERE number >= 200;

4. Дополнительное задание. Для каждого преподавателя выведите имя, фамилию, минимальное значение успеваемости по всем потокам преподавателя, название курса, который соответствует потоку с минимальным значением успеваемости, максимальное значение успеваемости по всем потокам преподавателя, название курса, соответствующий потоку с максимальным значением успеваемости. Выполните задачу с использованием оконных функций.*/

1.
SELECT DISTINCT 
name AS course_name,
SUM(students_amount) OVER(PARTITION BY course_id) AS total_students 
FROM streams
LEFT JOIN courses
ON streams.course_id = courses.id;

course_name             total_students
----------------------  --------------
Базы данных             76
Основы Python           37
Linux. Рабочая станция  34

2.
SELECT DISTINCT
id,
surname AS 'Фамилия', 
name AS 'Имя',
AVG(perfomance) OVER(PARTITION BY teachers_id) AS avg_grade
FROM grades
JOIN teachers
ON teachers.id = grades.teachers_id;

id  Фамилия   Имя      avg_grade
--  --------  -------  ---------
1   Савельев  Николай  4.85
2   Петрова   Наталья  4.9


3.
CREATE INDEX teachers_surname_name_idx ON teachers(surname, name);
или
CREATE INDEX teachers_surname_idx ON teachers(surname);
CREATE INDEX teachers_name_idx ON teachers(name);

5.
SELECT DISTINCT
(SELECT name FROM courses WHERE id = 
(SELECT course_id FROM streams WHERE id = stream_id)) AS 'Название курса', 
teachers.name AS 'Имя преподавателя',
teachers.surname AS 'Фамилия преподавателя',
MIN(perfomance) OVER(PARTITION BY id) AS 'min_grade',
MAX(perfomance) OVER(PARTITION BY id) AS max_grade
FROM teachers
LEFT JOIN grades
ON grades.teachers_id = teachers.id;