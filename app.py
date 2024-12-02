from flask import Flask, jsonify, request, render_template
import sqlite3

app = Flask(__name__)
DATABASE = 'database.db'


def get_db_connection():
    conn = sqlite3.connect(DATABASE)
    conn.row_factory = sqlite3.Row
    return conn


@app.route('/users', methods=['GET'])
def get_users():
    conn = get_db_connection()
    users = conn.execute('SELECT * FROM Users').fetchall()
    conn.close()
    return jsonify([dict(user) for user in users])


@app.route('/users/<int:uid>', methods=['GET'])
def get_user(uid):
    conn = get_db_connection()
    user = conn.execute('SELECT * FROM Users WHERE uid = ?', (uid,)).fetchone()
    conn.close()
    return jsonify(dict(user)) if user else ('', 404)


@app.route('/songs', methods=['GET'])
def get_songs():
    conn = get_db_connection()
    songs = conn.execute('SELECT * FROM Song').fetchall()
    conn.close()
    return jsonify([dict(song) for song in songs])


@app.route('/posts', methods=['GET'])
def get_posts():
    conn = get_db_connection()
    posts = conn.execute('SELECT * FROM Post').fetchall()
    conn.close()
    return jsonify([dict(post) for post in posts])


@app.route('/')
def index():
    return render_template('index.html')


if __name__ == '__main__':
    app.run(debug=True)
