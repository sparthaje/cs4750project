const sql = require('mssql');

const config = {
    user: 'AppUser',
    password: 'hello',
    server: 'desktop-i4i2uoj', // or your server IP
    port: 1433,
    database: 'MusicSocial',
    options: {
        encrypt: false,
        instanceName: 'SQLEXPRESS01',
    }
};

module.exports = {
    connect: () => sql.connect(config),
    sql,
};