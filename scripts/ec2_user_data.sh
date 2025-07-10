#!/bin/bash
set -e

yum update -y
yum install git nc -y

cd /home/ec2-user
git clone https://github.com/pufffikk/quiz_game_final_project.git
cd quiz_game_final_project
git checkout ec2

dnf install -y python3.12 postgresql-devel python3-devel
dnf groupinstall -y "Development Tools"

python3.12 -m venv venv
source venv/bin/activate

pip install --upgrade pip
pip install fastapi uvicorn
pip install -r requirements.txt

DB_HOST="db.quizgameruslan.com"

cat > .env <<EOF
DATABASE_URL=postgresql+psycopg2://postgres:12345678@db.quizgameruslan.com:5432/postgres
DATABASE_URL_ASYNC=postgresql+asyncpg://postgres:12345678@db.quizgameruslan.com:5432/postgres
EOF

for i in {1..30}; do
  echo "⏳ Waiting for PostgreSQL at ${DB_HOST}:5432... ($i)"
  nc -z ${DB_HOST} 5432 && echo "✅ DB is reachable!" && break
  sleep 10
done

nohup uvicorn app.main:application --host 0.0.0.0 --port 8000 --reload &
