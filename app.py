from flask import Flask, jsonify, request, render_template, session
import sqlite3
import hashlib

app = Flask(__name__)
app.secret_key = 'test_secret_key'

DATABASE = 'database.db'


def get_db_connection():
    conn = sqlite3.connect(DATABASE)
    conn.row_factory = sqlite3.Row
    return conn

# APIS for Login


@app.route('/add_user', methods=['POST'])
def add_user():
    username = request.form['username']
    password = request.form['password']
    hashed_password = hashlib.sha256(password.encode()).hexdigest()

    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        cursor.execute('INSERT INTO Users (username, password) VALUES (?, ?)', (username, hashed_password))
        cursor.execute('INSERT INTO UserProfile (uid) VALUES ((SELECT uid FROM Users WHERE username = ?))', (username,))
        conn.commit()
        return jsonify({'message': 'User added successfully!'}), 201
    except sqlite3.IntegrityError:
        return jsonify({'message': 'Username already exists!'}), 400
    finally:
        conn.close()


@app.route('/login', methods=['POST'])
def login():
    username = request.form['username']
    password = request.form['password']
    hashed_password = hashlib.sha256(password.encode()).hexdigest()

    conn = get_db_connection()
    user = conn.execute('SELECT * FROM Users WHERE username = ? AND password = ?',
                        (username, hashed_password)).fetchone()
    conn.close()

    if user:
        session['user_id'] = user['uid']
        return jsonify({'message': 'User logged in successfully!'}), 201
    else:
        return jsonify({'message': 'Invalid credentials!'}), 401


@app.route('/protected', methods=['GET'])
def protected():
    if 'user_id' not in session:
        return jsonify({"message": "Unauthorized"}), 401
    return jsonify({"message": f"Hello {session['user_id']}!"})


@app.route('/timeline', methods=['GET'])
def timeline():
    # Check if the user is authenticated
    if 'user_id' not in session:
        return jsonify({"message": "Unauthorized"}), 401

    uid = session['user_id']

    # SQL query to get posts from followed users ordered by timestamp (newest first)
    query = f"""
    SELECT p.pid, p.sid, p.caption
    FROM Post p
    JOIN FollowingList f ON p.uid = f.followed_uid
    WHERE f.following_uid = {uid}
    ORDER BY p.timestamp DESC;
    """

    conn = get_db_connection()
    posts = conn.execute(query).fetchall()
    conn.close()

    return jsonify(posts), 200

# TODO create an API to follow users


# Creates a Post


@app.route('/posts', methods=['POST'])
def create_post():
    if 'user_id' not in session:
        return jsonify({"error": "Unauthorized"}), 401

    uid = session['user_id']  # Ensure the post is created by the logged-in user
    sid = request.form['sid']
    caption = request.form['caption']

    if not sid or (caption and len(caption.strip()) == 0):
        return jsonify({"error": "Invalid input"}), 400

    conn = get_db_connection()
    try:
        conn.execute(
            'INSERT INTO Post (uid, sid, caption) VALUES (?, ?, ?)',
            (uid, sid, caption)
        )
        conn.commit()
        return jsonify({"message": "Post created successfully"}), 201
    except sqlite3.IntegrityError as e:
        return jsonify({"error": str(e)}), 400
    finally:
        conn.close()


# Gets Likes per Post


@app.route('/posts/<int:pid>/likes', methods=['GET'])
def get_likes_per_post(pid):
    conn = get_db_connection()
    likes = conn.execute(
        'SELECT COUNT(*) AS like_count FROM Like WHERE pid = ?', (pid,)
    ).fetchone()
    conn.close()

    if likes:
        return jsonify({"post_id": pid, "likes": likes['like_count']})
    else:
        return jsonify({"error": "Post not found"}), 404

# Gets # followers for logged-in user


@app.route('/users/followers', methods=['GET'])
def get_number_of_followers():
    if 'user_id' not in session:
        return jsonify({"error": "Unauthorized"}), 401

    uid = session['user_id']
    conn = get_db_connection()
    followers = conn.execute(
        'SELECT COUNT(*) AS follower_count FROM FollowingList WHERE followed_uid = ?', (uid,)
    ).fetchone()
    conn.close()

    return jsonify({"user_id": uid, "followers": followers['follower_count']})

# Updates User Profile


@app.route('/users/profile', methods=['PUT'])
def update_user_profile():
    if 'user_id' not in session:
        return jsonify({"error": "Unauthorized"}), 401

    bio = request.form['bio']
    location = request.form['location']
    uid = session['user_id']

    conn = get_db_connection()
    try:
        conn.execute(
            'UPDATE UserProfile SET bio = ?, location = ? WHERE uid = ?',
            (bio, location, uid)
        )
        conn.commit()
        return jsonify({"message": "Profile updated successfully"}), 200
    except sqlite3.IntegrityError as e:
        return jsonify({"error": str(e)}), 400
    finally:
        conn.close()

# Deletes a Post


@app.route('/posts/<int:pid>', methods=['DELETE'])
def delete_post(pid):
    if 'user_id' not in session:
        return jsonify({"error": "Unauthorized"}), 401

    uid = session['user_id']  # Get the logged-in user's ID

    conn = get_db_connection()
    # Verify the post belongs to the logged-in user
    post = conn.execute(
        'SELECT * FROM Post WHERE pid = ? AND uid = ?', (pid, uid)
    ).fetchone()

    if not post:
        conn.close()
        return jsonify({"error": "Post not found or you do not have permission to delete it"}), 404

    # Delete the post
    try:
        conn.execute('DELETE FROM Post WHERE pid = ?', (pid,))
        conn.commit()
        return jsonify({"message": "Post deleted successfully"}), 200
    except sqlite3.IntegrityError as e:
        return jsonify({"error": str(e)}), 400
    finally:
        conn.close()


@app.route('/')
def index():
    return render_template('index.html')


if __name__ == '__main__':
    app.run(debug=True)
