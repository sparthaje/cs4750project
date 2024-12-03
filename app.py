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

'''
User Entity
'''
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


@app.route('/verify_auth', methods=['GET'])
def protected():
    if 'user_id' not in session:
        return jsonify({"message": "Unauthorized"}), 401
    return jsonify({"message": f"Hello {session['user_id']}!"})

@app.route('/get_users', methods=['GET'])
def users():
    conn = get_db_connection()
    users = conn.execute('SELECT * FROM Users').fetchall()
    conn.close()

    user_list = []
    for user in users:
        u = dict(user)
        user_list.append(u)

    return jsonify(user_list), 200

@app.route('/update_user', methods=['PUT'])
def update_user():
    if 'user_id' not in session:
        return jsonify({"error": "Unauthorized"}), 401

    uid = session['user_id']
    username = request.form.get('username')
    password = request.form.get('password')

    if not username and not password:
        return jsonify({"error": "No fields to update"}), 400

    conn = get_db_connection()
    try:
        # Update the username if provided
        if username:
            conn.execute('UPDATE Users SET username = ? WHERE uid = ?', (username, uid))

        # Update the password if provided
        if password:
            hashed_password = hashlib.sha256(password.encode()).hexdigest()
            conn.execute('UPDATE Users SET password = ? WHERE uid = ?', (hashed_password, uid))

        conn.commit()
        return jsonify({"message": "User updated successfully"}), 200
    except sqlite3.IntegrityError as e:
        return jsonify({"error": str(e)}), 400
    finally:
        conn.close()

@app.route('/delete_user', methods=['DELETE'])
def delete_user():
    if 'user_id' not in session:
        return jsonify({"error": "Unauthorized"}), 401

    uid = session['user_id']

    conn = get_db_connection()
    try:
        # Delete the user and all related records
        conn.execute('DELETE FROM UserProfile WHERE uid = ?', (uid,))
        conn.execute('DELETE FROM FollowingList WHERE following_uid = ? OR followed_uid = ?', (uid, uid))
        conn.execute('DELETE FROM Like WHERE uid = ?', (uid,))
        conn.execute('DELETE FROM SuperLike WHERE uid = ?', (uid,))
        conn.execute('DELETE FROM Post WHERE uid = ?', (uid,))
        conn.execute('DELETE FROM Users WHERE uid = ?', (uid,))
        conn.commit()

        # Clear the session after account deletion
        session.clear()
        return jsonify({"message": "User account deleted successfully"}), 200
    except sqlite3.IntegrityError as e:
        return jsonify({"error": str(e)}), 400
    finally:
        conn.close()



'''
FollowingList Entity
'''
@app.route('/follow', methods=['POST'])
def follow():
    if 'user_id' not in session:
        return jsonify({"message": "Unauthorized"}), 401

    following_uid = session['user_id']
    followed_uid = request.form['followed_uid']

    if following_uid == int(followed_uid):
        return jsonify({"message": "You cannot follow yourself!"}), 400

    conn = get_db_connection()
    try:
        conn.execute('INSERT INTO FollowingList (following_uid, followed_uid) VALUES (?, ?)',
                     (following_uid, followed_uid))
        conn.commit()
        return jsonify({"message": f"User {following_uid} followed User {followed_uid}!"}), 201
    except sqlite3.IntegrityError:
        return jsonify({"message": "Already following this user!"}), 400
    finally:
        conn.close()


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

#TODO: Test DELET API for FollowingList
@app.route('/unfollow', methods=['DELETE'])
def unfollow():
    if 'user_id' not in session:
        return jsonify({"error": "Unauthorized"}), 401

    following_uid = session['user_id']
    followed_uid = request.form.get('followed_uid')

    if not followed_uid:
        return jsonify({"error": "Followed user ID is required"}), 400

    conn = get_db_connection()
    try:
        # Delete the following relationship
        result = conn.execute(
            'DELETE FROM FollowingList WHERE following_uid = ? AND followed_uid = ?',
            (following_uid, followed_uid)
        )
        conn.commit()

        if result.rowcount == 0:
            return jsonify({"error": "You are not following this user"}), 404

        return jsonify({"message": f"User {following_uid} unfollowed User {followed_uid}"}), 200
    except sqlite3.IntegrityError as e:
        return jsonify({"error": str(e)}), 400
    finally:
        conn.close()

#TODO: Test PUT API for FollowingList
@app.route('/update_follow', methods=['PUT'])
def update_follow():
    if 'user_id' not in session:
        return jsonify({"error": "Unauthorized"}), 401

    following_uid = session['user_id']
    followed_uid = request.form.get('followed_uid')
    new_followed_uid = request.form.get('new_followed_uid')

    if not followed_uid or not new_followed_uid:
        return jsonify({"error": "Both followed user ID and new followed user ID are required"}), 400

    if int(following_uid) == int(new_followed_uid):
        return jsonify({"error": "You cannot follow yourself"}), 400

    conn = get_db_connection()
    try:
        # Check if the original relationship exists
        existing_follow = conn.execute(
            'SELECT * FROM FollowingList WHERE following_uid = ? AND followed_uid = ?',
            (following_uid, followed_uid)
        ).fetchone()

        if not existing_follow:
            return jsonify({"error": "Follow relationship does not exist"}), 404

        # Update the follow relationship
        conn.execute(
            'UPDATE FollowingList SET followed_uid = ? WHERE following_uid = ? AND followed_uid = ?',
            (new_followed_uid, following_uid, followed_uid)
        )
        conn.commit()

        return jsonify({
            "message": f"Follow relationship updated: {following_uid} now follows {new_followed_uid} instead of {followed_uid}"
        }), 200
    except sqlite3.IntegrityError as e:
        return jsonify({"error": str(e)}), 400
    finally:
        conn.close()



# Post Entity


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

@app.route('/posts/update_post/<int:pid>', methods=['PUT'])
def update_post(pid):
    if 'user_id' not in session:
        return jsonify({"error": "Unauthorized"}), 401

    uid = session['user_id']  # Get the logged-in user's ID
    sid = request.form['sid']
    caption = request.form['caption']


    conn = get_db_connection()
    # Verify the post belongs to the logged-in user
    try:
        existing_post = conn.execute(
            'SELECT * FROM Post WHERE uid = ? AND pid = ?',
            (uid, pid)
        ).fetchone()

        if not existing_post:
            conn.close()
            return jsonify({"error": "Post not found or you do not have permission to delete it"}), 404

        if sid and caption:
            conn.execute(
                'UPDATE Post SET sid = ?, caption = ? WHERE pid = ? AND uid = ?', (sid, caption, pid, uid)
            ).fetchone()
        elif caption:
            conn.execute(
                'UPDATE Post SET caption = ? WHERE pid = ? AND uid = ?', (caption, pid, uid)
            ).fetchone()

        conn.commit()
        return jsonify({"message": "Post updated successfully"}), 200
    except sqlite3.IntegrityError as e:
        return jsonify({"error": str(e)}), 400
    finally:
        conn.close()

@app.route('/get_posts', methods=['GET'])
def get_posts():
    conn = get_db_connection()
    posts = conn.execute('SELECT * FROM Post').fetchall()
    conn.close()

    post_list = []
    for post in posts:
        p = dict(post)
        post_list.append(p)

    return jsonify(post_list), 200

# Like Entity
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


@app.route('/posts/<int:pid>/like', methods=['DELETE'])
def delete_like(pid):
    if 'user_id' not in session:
        return jsonify({"error": "Unauthorized"}), 401

    uid = session['user_id']  # Get the logged-in user's ID

    conn = get_db_connection()
    # Verify the post belongs to the logged-in user
    post = conn.execute(
        'SELECT * FROM Like WHERE pid = ? AND uid = ?', (pid, uid)
    ).fetchone()

    if not post:
        conn.close()
        return jsonify({"error": "Post not liked by user"}), 404

    # Delete the like
    try:
        conn.execute('DELETE FROM Like WHERE pid = ? AND uid = ?', (pid, uid))
        conn.commit()
        return jsonify({"message": f"Like associated with user {uid} and the liked post {pid} is deleted successfully"}), 200
    except sqlite3.IntegrityError as e:
        return jsonify({"error": str(e)}), 400
    finally:
        conn.close()

@app.route('/posts/<int:pid>/like', methods=['POST'])
def make_like(pid):
    if 'user_id' not in session:
        return jsonify({"error": "Unauthorized"}), 401

    uid = session['user_id']  # Ensure the post is created by the logged-in user

    conn = get_db_connection()
    try:
        conn.execute(
            'INSERT INTO Like (pid, uid) VALUES (?, ?)',
            (pid, uid)
        )
        conn.commit()
        return jsonify({"message": f"Like made successfully on post {pid} by user {uid}"}), 201
    except sqlite3.IntegrityError as e:
        return jsonify({"error": str(e)}), 400
    finally:
        conn.close()


# User Profile Entity

# POST implemented in /add_user method

# TODO DELETE, PUT
@app.route('/users/profile', methods=['DELETE'])
def delete_user_profile():
    if 'user_id' not in session:
        return jsonify({"error": "Unauthorized"}), 401

    uid = session['user_id']

    conn = get_db_connection()
    try:
        user_profile = conn.execute('SELECT * FROM UserProfile WHERE uid = ?', (uid,)).fetchone()
        if not user_profile:
            return jsonify({"error": "User profile not found"}), 404
        conn.execute('DELETE FROM UserProfile WHERE uid = ?', (uid,))
        conn.commit()
        return jsonify({"message": f"Profile for user {uid} deleted successfully"}), 200
    except sqlite3.IntegrityError as e:
        return jsonify({"error": str(e)}), 400
    finally:
        conn.close()

@app.route('/users/profile', methods=['GET'])
def get_user_profile():
    if 'user_id' not in session:
        return jsonify({"error": "Unauthorized"}), 401

    uid = session['user_id']
    conn = get_db_connection()
    user_profile = conn.execute('SELECT * FROM UserProfile WHERE uid = ?', (uid,)).fetchone()
    conn.close()

    if user_profile:
        return jsonify(dict(user_profile)), 200
    else:
        return jsonify({"error": "User profile not found"}), 404

@app.route('/users/profile', methods=['PUT'])
def update_user_profile():
    if 'user_id' not in session:
        return jsonify({"error": "Unauthorized"}), 401

    bio = request.form['bio']
    location = request.form['location']
    uid = session['user_id']

    conn = get_db_connection()
    try:
        user_profile = conn.execute('SELECT * FROM UserProfile WHERE uid = ?', (uid,)).fetchone()
        if not user_profile:
            return jsonify({"error": "User profile not found"}), 404
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

@app.route('/users/profiles', methods=['POST'])
def create_user_profile():
    if 'user_id' not in session:
        return jsonify({"error": "Unauthorized"}), 401

    uid = session['user_id']
    bio = request.form['bio']
    location = request.form['location']

    conn = get_db_connection()
    try:
        user = conn.execute('SELECT * FROM User WHERE uid = ?', (uid,)).fetchone()
        if not user:
            return jsonify({"error": "User not found so cannot create profile for non-existent user"}), 404
        conn.execute(
            'INSERT INTO UserProfile (uid, bio, location) VALUES (?, ?, ?)',
            (uid, bio, location)
        )
        conn.commit()
        return jsonify({"message": "User profile created successfully"}), 201
    except sqlite3.IntegrityError as e:
        return jsonify({"error": str(e)}), 400
    finally:
        conn.close()


@app.route('/')
def index():
    return render_template('index.html')


if __name__ == '__main__':
    app.run(debug=True)
