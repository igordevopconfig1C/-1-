from flask import Flask
import mysql.connector

app = Flask(__name__)

DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': '12344321',
    'database': 'mini_headhunter'
}


def get_db_connection():
    return mysql.connector.connect(**DB_CONFIG)


def query(sql, params=None):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute(sql, params or ())
    rows = cursor.fetchall()
    cursor.close()
    conn.close()
    return rows


BASE_HTML = '''
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <title>{title}</title>
    <style>
        body {{ font-family: Arial, sans-serif; margin: 40px; background: #f9f9f9; }}
        h1 {{ color: #2c3e50; }}
        nav {{ margin-bottom: 20px; }}
        nav a {{
            display: inline-block;
            margin-right: 15px;
            padding: 8px 14px;
            background: #3498db;
            color: white;
            text-decoration: none;
            border-radius: 4px;
        }}
        nav a:hover {{ background: #2980b9; }}
        table {{ border-collapse: collapse; width: 100%; background: white; }}
        th, td {{ border: 1px solid #ddd; padding: 10px; text-align: left; }}
        th {{ background: #34495e; color: white; }}
        tr:nth-child(even) {{ background: #f2f2f2; }}
    </style>
</head>
<body>
    <h1>{title}</h1>
    <nav>
        <a href="/">Пользователи</a>
        <a href="/companies">Компании</a>
        <a href="/vacancies">Вакансии</a>
        <a href="/resumes">Резюме</a>
        <a href="/applications">Отклики</a>
    </nav>
    {content}
</body>
</html>
'''


def render(title, table_html):
    return BASE_HTML.format(title=title, content=table_html)


def build_table(headers, rows):
    html = '<table><tr>'
    for h in headers:
        html += f'<th>{h}</th>'
    html += '</tr>'
    for row in rows:
        html += '<tr>'
        for cell in row:
            html += f'<td>{cell if cell is not None else "—"}</td>'
        html += '</tr>'
    html += '</table>'
    return html


ROLE_RU = {
    'applicant': 'Соискатель',
    'employer': 'Работодатель'
}

STATUS_RU = {
    'pending': 'На рассмотрении',
    'accepted': 'Принят',
    'rejected': 'Отклонён'
}


@app.route('/')
def index():
    rows = query("""
        SELECT
            id,
            nickname,
            surname,
            name,
            patronymic,
            email,
            role
        FROM users
    """)
    rows = [(r[0], r[1], r[2], r[3], r[4], r[5], ROLE_RU.get(r[6], r[6])) for r in rows]
    table = build_table(
        ['ID', 'Ник', 'Фамилия', 'Имя', 'Отчество', 'Email', 'Роль'],
        rows
    )
    return render('Пользователи', table)


@app.route('/companies')
def companies():
    rows = query("""
        SELECT
            c.id,
            c.name,
            c.website,
            u.surname,
            u.name,
            u.patronymic
        FROM companies c
        JOIN users u ON c.owner_id = u.id
    """)
    table = build_table(
        ['ID', 'Компания', 'Сайт', 'Фамилия', 'Имя', 'Отчество'],
        rows
    )
    return render('Компании', table)


@app.route('/vacancies')
def vacancies():
    rows = query("""
        SELECT v.id, v.title, v.salary, c.name
        FROM vacancies v
        JOIN companies c ON v.company_id = c.id
    """)
    rows = [(r[0], r[1], f'{r[2]} ₽', r[3]) for r in rows]
    table = build_table(['ID', 'Вакансия', 'Зарплата', 'Компания'], rows)
    return render('Вакансии', table)


@app.route('/resumes')
def resumes():
    rows = query("""
        SELECT
            r.id,
            r.title,
            r.experience,
            u.surname,
            u.name,
            u.patronymic,
            GROUP_CONCAT(s.name SEPARATOR ', ') AS skills
        FROM resumes r
        JOIN users u ON r.user_id = u.id
        LEFT JOIN resume_skills rs ON r.id = rs.resume_id
        LEFT JOIN skills s ON rs.skill_id = s.id
        GROUP BY r.id, r.title, r.experience, u.surname, u.name, u.patronymic
    """)
    table = build_table(
        ['ID', 'Резюме', 'Опыт', 'Фамилия', 'Имя', 'Отчество', 'Навыки'],
        rows
    )
    return render('Резюме', table)


@app.route('/applications')
def applications():
    rows = query("""
        SELECT
            a.id,
            u.surname,
            u.name,
            u.patronymic,
            v.title AS vacancy,
            r.title AS resume,
            a.status
        FROM applications a
        JOIN users u ON a.user_id = u.id
        JOIN vacancies v ON a.vacancy_id = v.id
        LEFT JOIN resumes r ON a.resume_id = r.id
    """)
    rows = [(r[0], r[1], r[2], r[3], r[4], r[5] if r[5] else '—', STATUS_RU.get(r[6], r[6])) for r in rows]
    table = build_table(
        ['ID', 'Фамилия', 'Имя', 'Отчество', 'Вакансия', 'Резюме', 'Статус'],
        rows
    )
    return render('Отклики на вакансии', table)


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
