/* Если результирующий запрос возвращает одну запись, поместить результаты в локальную переменную, можно при помощи оператора SELECT ... INTO ... FROM ...;
Однако результирующие таблицы чаще всего содержат несколько записей, поэтому использование такого запроса совместно с оператором SELECT ... INTO приводит к ошибке.

В данный момент в таблице catalogs более 1 записии, поэтому вызов хранимой процедуры catalog_id приведёт к ошибке (мы не можем поместить более 1-й записи в переменную total).
Избежать ошибки можно при помощи LIMIT 1 или назначить обработчик ошибок.

Иногда требуется обработать именно многострочную результирующую таблицу, решить эту задачу можно используя курсоры, который представляет собой своеобразные циклы,
специально предназначенные для обхода результирующих таблиц.

Этапы работы с курсорами:
  * DECLARE CURSOR - Объявление;
      В нём мы задаём имя курсора и связываем его с выполняемым запросом.
  * OPEN - открытие;
      Выполняет запрос свзяанный с курсором и устанавливает курсор на первые записи результирующей таблицы.
  * FETCH - чтение;
      Перемещает курсор на первую запись результирующей таблицы и извлекает данные из записи. Повторый вызов команды FETCH
      приводит перемещение курсора к следующей записи и так до конца всех записей. Эту операцию удобно выполнять в цикле.
  * CLOSE - закрытие.
	  Прекращает доступ к результирующей таблице и ликвидирует связь между курсором и таблицей.
*/
 
 USE shop;
 
-- Создадим копию таблицы shop под названием upcase_catalogs, учебной БД shop
DROP TABLE IF EXISTS upcase_catalogs;
CREATE TABLE upcase_catalogs (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название раздела'
) COMMENT = 'Разделы интернет-магазина';

-- Создадим процедуру copy_catalogs, которая будет копировать данные из таблицы catalogs в таблицу upcase_catalogs

DELIMITER //

DROP PROCEDURE IF EXISTS copy_catalogs//
CREATE PROCEDURE copy_catalogs ()
BEGIN
  DECLARE id INT;  -- Локальная переменная
  DECLARE is_end INT DEFAULT 0;  -- Локальная переменная
  DECLARE name TINYTEXT;  -- Локальная переменная

  DECLARE curcat CURSOR FOR SELECT * FROM catalogs;  -- Объявляем курсор
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET is_end = 1;  -- Обработчик ситуации, когда курсор достигает конца результирующей таблицы

  OPEN curcat;  -- Открываем курсор

  cycle : LOOP  -- В цикле:
    FETCH curcat INTO id, name;  -- Читаем данные из курсора и формируем запись для таблицы upcase_catalogs
    IF is_end THEN LEAVE cycle; -- Когда is_end = 1 Срабатывает IF условие и мы выходим их цикла при помощи LEAVE
    END IF;
    INSERT INTO upcase_catalogs VALUES(id, UPPER(name));  -- Вставляем запись при помощи оператора INSERT 
  END LOOP cycle;  -- Покинув цикл мы продолжаем шатное выполнение команд хранимой процедуры

  CLOSE curcat;  -- В конце процедуры закрываем курсор
END//

-- Запускаем процедуру на выполнение
CALL copy_catalogs()//

-- Проверяем таблицу upcase_catalogs
SELECT * FROM upcase_catalogs//
-- Получаем копию таблицы catalogs в верхнем регистре