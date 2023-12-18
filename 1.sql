-- Таблица "Автомобиль"
CREATE TABLE Car (
    car_id SERIAL PRIMARY KEY,
    booking_id INT,
    status VARCHAR(50),
    brand VARCHAR(100),
    model VARCHAR(100),
    year_of_purchase INT,
    color VARCHAR(50),
    license_plate VARCHAR(20),
    last_service DATE
);

-- Таблица "Пользователь"
CREATE TABLE "User" (
    user_id SERIAL PRIMARY KEY,
    passport_id INT,
    drivers_license_id INT,
    last_name VARCHAR(255),
    first_name VARCHAR(255),
    otchestvo VARCHAR(255),
    username VARCHAR(100),
    email VARCHAR(100),
    phone_number VARCHAR(50),
    date_of_birth DATE,
    address VARCHAR(255)
);

-- Таблица "Паспорт"
CREATE TABLE Passport (
    passport_id SERIAL PRIMARY KEY,
    passport_series VARCHAR(50),
    passport_number VARCHAR(50),
    place_of_birth VARCHAR(100),
    issue_date DATE,
    division_code VARCHAR(50),
    issued_by VARCHAR(100),
    photo_scan BYTEA,
    photo_format VARCHAR(10)
);

-- Таблица "Водительское удостоверение"
CREATE TABLE DriversLicense (
    drivers_license_id SERIAL PRIMARY KEY,
    license_series_number VARCHAR(20),
    issue_date DATE,
    traffic_department_number VARCHAR(20),
    category VARCHAR(10),
    photo_scan BYTEA,
    photo_format VARCHAR(10)
);

-- Таблица "Бронь"
CREATE TABLE Booking (
    booking_id SERIAL PRIMARY KEY,
    user_id INT,
    car_id INT,
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    status VARCHAR(50)
);

-- Таблица "Поездка"
CREATE TABLE Ride (
    ride_id SERIAL PRIMARY KEY,
    user_id INT,
    car_id INT,
    status VARCHAR(50),
    start_address VARCHAR(255),
    start_time TIMESTAMP,
    end_address VARCHAR(255),
    end_time TIMESTAMP,
    ride_time TIME,
    distance INT
);

-- Таблица "Оплата"
CREATE TABLE Payment (
    payment_id SERIAL PRIMARY KEY,
    booking_id INT,
    user_id INT,
    payment_method_id INT,
    tariff_id INT,
    trip_duration INTERVAL,
    trip_distance INT,
    amount DECIMAL(10, 2),
    payment_date DATE
);

-- Таблица "Способ оплаты"
CREATE TABLE PaymentMethod (
    payment_method_id SERIAL PRIMARY KEY,
    user_id INT,
    type VARCHAR(50),
    card_number VARCHAR(20),
    expiration_date DATE,
    cardholder_name VARCHAR(255),
    cardholder_address VARCHAR(255)
);

-- Таблица "Тариф"
CREATE TABLE Tariff (
    tariff_id SERIAL PRIMARY KEY,
    time_rate DECIMAL(10, 2),
    distance_rate DECIMAL(10, 2)
);


--a1 Создание брони--
INSERT INTO Booking (user_id, car_id, start_time, end_time, status)
VALUES (1, 101, '2022-01-01 12:00:00', '2022-01-02 12:00:00', 'активное');

--a2 Создание поездки--
INSERT INTO Ride (user_id, car_id, start_address, start_time, end_address, end_time)
VALUES (1, 101, 'ул. Ленина, 10', '2022-01-02 12:00:00', 'пл. Победы, 5', '2022-01-02 14:00:00');

--a3 Оплата заказа--
INSERT INTO Payment (booking_id, user_id, payment_method_id, tariff_id, trip_duration, trip_distance, amount, payment_date)
VALUES (1, 1, 1, 1, '2 hours', 100, 1000.00, '2022-01-02');

--a4 Отмена брони--
UPDATE Booking
SET status = 'завершенное'
WHERE booking_id = 1;

--b1 Создание нового пользователя
INSERT INTO "User" (passport_id, drivers_license_id, last_name, first_name, otchestvo, username, email, phone_number, date_of_birth, address)
VALUES (1, 1, 'Иванов', 'Иван', 'Иванович', 'ivanov_ivan', 'ivanov@example.com', '1234567890', '1990-01-01', 'ул. Пушкина, д.10');

--b2 Редактирование данных пользователя
UPDATE "User"
SET email = 'new_email@example.com'
WHERE user_id = 1;

--b3 Удаление пользователя
DELETE FROM "User"
WHERE user_id = 1;

--b4 Блокировка пользователя
UPDATE "User"
SET status = 'blocked'
WHERE user_id = 1;

--b5 Внесение паспортных данных
INSERT INTO Passport (passport_series, passport_number, place_of_birth, issue_date, division_code, issued_by, photo_scan, photo_format)
VALUES ('1234', '567890', 'г. Москва', '2010-01-01', '123-456', 'УФМС РФ', BYTEA_CONTENT, 'jpeg');

--b6 Внесение данных водительского удостоверения
INSERT INTO DriversLicense (license_series_number, issue_date, traffic_department_number, category, photo_scan)
VALUES ('1234 567890', '2010-01-01', '123456', 'B', BYTEA_CONTENT, 'jpeg');

--c1 Добавление нового автомобиля
INSERT INTO Car (booking_id, status, brand, model, year_of_purchase, color, license_plate, last_service)
VALUES (NULL, 'active', 'Toyota', 'Corolla', 2018, 'black', 'A123BC', '2022-01-01');

--c2 Вывод из эксплуатации автомобиля
UPDATE Car
SET status = 'out_of_service'
WHERE car_id = 1;

--c3 Изменение статуса автомобиля
UPDATE Car
SET status = 'under_maintenance'
WHERE car_id = 1;

--d Сохранение и просмотр истории заказов --
--Таблица "История заказов"
CREATE TABLE OrderHistory (
    order_id SERIAL PRIMARY KEY,
    booking_id INT,
    user_id INT,
    car_id INT,
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    status VARCHAR(50),
    action VARCHAR(50),
    action_timestamp TIMESTAMP
);

-- Триггер для отслеживания изменений в таблице "Booking"
CREATE OR REPLACE FUNCTION log_booking_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO OrderHistory (booking_id, user_id, car_id, start_time, end_time, status, action, action_timestamp)
        VALUES (NEW.booking_id, NEW.user_id, NEW.car_id, NEW.start_time, NEW.end_time, NEW.status, 'INSERT', CURRENT_TIMESTAMP);
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO OrderHistory (booking_id, user_id, car_id, start_time, end_time, status, action, action_timestamp)
        VALUES (NEW.booking_id, NEW.user_id, NEW.car_id, NEW.start_time, NEW.end_time, NEW.status, 'UPDATE', CURRENT_TIMESTAMP);
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO OrderHistory (booking_id, user_id, car_id, start_time, end_time, status, action, action_timestamp)
        VALUES (OLD.booking_id, OLD.user_id, OLD.car_id, OLD.start_time, OLD.end_time, OLD.status, 'DELETE', CURRENT_TIMESTAMP);
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Привязка триггера к таблице "Booking"
CREATE TRIGGER booking_changes_trigger
AFTER INSERT OR UPDATE OR DELETE ON Booking
FOR EACH ROW
EXECUTE FUNCTION log_booking_changes();

--e Финансовый отчет--
SELECT
    b.car_id,
    c.brand,
    c.model,
    COUNT(b.booking_id) AS rental_count,
    SUM(EXTRACT(DAY FROM (b.end_time - b.start_time))) AS total_rental_days,
    SUM(t.time_rate * EXTRACT(HOUR FROM (b.end_time - b.start_time)) + t.distance_rate * r.distance) AS total_rental_cost
FROM
    Booking b
INNER JOIN Car c ON b.car_id = c.car_id
LEFT JOIN Ride r ON b.booking_id = r.booking_id
LEFT JOIN Tariff t ON b.car_id = t.tariff_id
WHERE
    b.start_time >= '2022-01-01' AND b.end_time <= '2022-12-31'
GROUP BY
    b.car_id, c.brand, c.model;

--f1 Расчет количества автомобилей в автопарке
SELECT COUNT(car_id) AS total_cars_in_fleet
FROM Car;

--f2 Расчет количества автомобилей, прошедших ТО в 2022 году
SELECT COUNT(car_id) AS total_cars_serviced_in_2022
FROM Car
WHERE EXTRACT(YEAR FROM last_service) = 2022;