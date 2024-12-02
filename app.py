from flask import Flask, jsonify, request, render_template, session
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

# Creates a Post
@app.route('/posts', methods=['POST'])
def create_post():
    if 'user_id' not in session:
        return jsonify({"error": "Unauthorized"}), 401

    data = request.get_json()
    uid = session['user_id']  # Ensure the post is created by the logged-in user
    sid = data.get('sid')
    caption = data.get('caption')

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

    data = request.get_json()
    bio = data.get('bio')
    location = data.get('location')
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
