-- Создание базы данных (если её нет)
CREATE DATABASE IF NOT EXISTS mini_headhunter;
USE mini_headhunter;

-- 1. Таблица пользователей
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nickname VARCHAR(50) NOT NULL UNIQUE,
    surname VARCHAR(50) NOT NULL,
    name VARCHAR(50) NOT NULL,
    patronymic VARCHAR(50),
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('applicant', 'employer') NOT NULL DEFAULT 'applicant',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 2. Таблица компаний
CREATE TABLE IF NOT EXISTS companies (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    website VARCHAR(200),
    owner_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 3. Таблица вакансий
CREATE TABLE IF NOT EXISTS vacancies (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    description TEXT,
    salary INT,
    company_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 4. Таблица резюме
CREATE TABLE IF NOT EXISTS resumes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(150) NOT NULL,
    experience TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 5. Таблица навыков (справочник)
CREATE TABLE IF NOT EXISTS skills (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- 6. Таблица связи резюме и навыков (M:N)
CREATE TABLE IF NOT EXISTS resume_skills (
    resume_id INT NOT NULL,
    skill_id INT NOT NULL,
    PRIMARY KEY (resume_id, skill_id),
    FOREIGN KEY (resume_id) REFERENCES resumes(id) ON DELETE CASCADE,
    FOREIGN KEY (skill_id) REFERENCES skills(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 7. Таблица откликов на вакансии
CREATE TABLE IF NOT EXISTS applications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    vacancy_id INT NOT NULL,
    resume_id INT,
    status ENUM('pending', 'accepted', 'rejected') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (vacancy_id) REFERENCES vacancies(id) ON DELETE CASCADE,
    FOREIGN KEY (resume_id) REFERENCES resumes(id) ON DELETE SET NULL,
    UNIQUE KEY unique_application (user_id, vacancy_id)
) ENGINE=InnoDB;

-- ==========================================
-- ЗАПОЛНЕНИЕ ДАННЫМИ (INSERT)
-- ==========================================

-- Пользователи
INSERT INTO users (nickname, surname, name, patronymic, email, password_hash, role) VALUES
('ivan_p',  'Петров',   'Иван',    'Сергеевич',  'ivan@mail.ru',    'hash1', 'applicant'),
('maria_s', 'Сидорова', 'Мария',   'Алексеевна', 'maria@mail.ru',   'hash2', 'applicant'),
('roga_hr', 'Рога',     'ООО',     'и Копыта',   'hr@roga.ru',      'hash3', 'employer'),
('smirnov', 'Смирнов',  'ИП',      NULL,         'smirnov@mail.ru', 'hash4', 'employer'),
('alex_k',  'Козлов',   'Алексей', 'Петрович',   'alex@mail.ru',    'hash5', 'applicant');

-- Компании
INSERT INTO companies (name, description, website, owner_id) VALUES
('Рога и Копыта', 'Крупная IT-компания', 'https://roga.ru', 3),
('Смирнов и партнёры', 'Юридические услуги', 'https://smirnov.ru', 4);

-- Вакансии
INSERT INTO vacancies (title, description, salary, company_id) VALUES
('Python-разработчик', 'Разработка веб-приложений', 120000, 1),
('Frontend-разработчик', 'React, Vue', 100000, 1),
('Юрист', 'Работа с договорами', 80000, 2);

-- Резюме
INSERT INTO resumes (user_id, title, experience) VALUES
(1, 'Python Developer', '3 года опыта'),
(2, 'Frontend Developer', '2 года опыта'),
(5, 'Junior Python', 'Без опыта');

-- Навыки
INSERT INTO skills (name) VALUES
('Python'), ('Django'), ('Flask'),
('JavaScript'), ('React'), ('SQL'), ('HTML'), ('CSS');

-- Связи резюме и навыков
INSERT INTO resume_skills (resume_id, skill_id) VALUES
(1, 1), (1, 2), (1, 3),
(2, 4), (2, 5), (2, 7), (2, 8),
(3, 1), (3, 6);

-- Отклики
INSERT INTO applications (user_id, vacancy_id, resume_id, status) VALUES
(1, 1, 1, 'pending'),
(2, 2, 2, 'accepted'),
(5, 1, 3, 'pending');
