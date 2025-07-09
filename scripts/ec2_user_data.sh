#!/bin/bash
set -e

# Обновляем систему и устанавливаем git
yum update -y
yum install git -y

# Клонируем репозиторий и переключаемся на ветку ec2
cd /home/ec2-user
git clone https://github.com/pufffikk/quiz_game_final_project.git
cd quiz_game_final_project
git checkout ec2

# Устанавливаем Python 3.12 и необходимые dev-пакеты
dnf install -y python3.12 postgresql-devel python3-devel
dnf groupinstall -y "Development Tools"

# Создаём и активируем виртуальное окружение (от имени ec2-user)
python3.12 -m venv venv
source venv/bin/activate

# Устанавливаем pip зависимости
pip install --upgrade pip
pip install fastapi uvicorn
pip install -r requirements.txt

cat > .env <<EOF
DATABASE_URL=postgresql+psycopg2://postgres:12345678@db.quizgameruslan.com:55433/postgres
DATABASE_URL_ASYNC=postgresql+asyncpg://postgres:12345678@db.quizgameruslan.com:55433/postgres
EOF

# Запускаем uvicorn (в фоне)
nohup uvicorn app.main:application --host 0.0.0.0 --port 8000 --reload &
