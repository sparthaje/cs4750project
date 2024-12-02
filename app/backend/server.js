const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const port = 5000;

const { connect } = require('./db');

const app = express();
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

connect()
    .then(() => {
        console.log('Database connected');
    })
    .catch((err) => {
        console.log('Database connection failed');
        console.error(err);
    });

app.get('/', (req, res) => {
    console.log('Server running');
    res.send('Server running');
});

//User Registration Endpoint
app.post('/api/signup', async (req, res) => {
    const { username, email } = req.body;

    console.log(username, email);
    
    try {
        const pool = await connect();
        const emaill = "hheeelliullooo";
        
        const checkExisting = await pool.request().query(`
            SELECT * FROM dbo.Users 
            WHERE username = '${username}' OR email = '${email}';
        `);
        
        if (checkExisting.recordset.length > 0) {
            return res.status(400).json({ message: 'Username or email already exists' });
        }
        
        // Insert new user into Users table
        const result = await pool.request().query(`
            INSERT INTO Users (username, email)
            VALUES ('${username}', '${email}');
        `);

        const queryResult = await pool.request().query(`
            SELECT * FROM dbo.Users 
            WHERE username = '${username}' OR email = '${email}';
        `);
        console.log("Resulting uid: ", queryResult.recordset[0].uid);
        
        // Insert UserProfile info without bio and location
        await pool.request().query(`
            INSERT INTO UserProfile (uid, bio, location) 
            VALUES (${queryResult.recordset[0].uid}, '', 'Unknown')
        `);

        console.log('User registered successfully');
        
        res.status(201).json({ 
            message: 'User registered successfully', 
            uid: queryResult.recordset[0].uid 
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Server error during registration' });
    }
});

// User Login Endpoint
app.post('/api/signin', async (req, res) => {
    const { username, email } = req.body;
    
    try {
        console.log('Login attempt:', username, email);
        const pool = await connect();
        
        const result = await pool.request().query(`
            SELECT u.uid, u.username, u.email, up.bio, up.location 
            FROM Users u
            JOIN UserProfile up ON u.uid = up.uid
            WHERE u.username = '${username}' AND u.email = '${email}'
        `);

        console.log('Login result:', result.recordset);
        
        if (result.recordset.length <= 0) {
            console.log('Invalid credentials');
            return res.status(401).json({ message: 'Invalid credentials' });
        }
        
        console.log('User logged in successfully: ', result.recordset[0]);
        return res.status(200).json(result.recordset[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Server error during login' });
    }
});


// Just a test endpoint to retrieve all users
const getAllUsers = async () => {
    try {
        const pool = await connect();
        
        const result = await pool.request().query('SELECT * FROM Users');
        
        console.log('All Users:', result.recordset);
        return result.recordset;
    } catch (err) {
        console.error('Error retrieving users:', err);
        throw err;
    }
};
getAllUsers();

app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});