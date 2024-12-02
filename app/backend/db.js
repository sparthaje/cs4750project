const sql = require('mssql');

const config = {
    user: 'user',
    password: 'pass',
    server: 'server-name', // or your server IP
    port: 1433,
    database: 'db_name',
    options: {
        encrypt: false,
        instanceName: 'instance_name',
    }
};

module.exports = {
    connect: () => sql.connect(config),
    sql,
};
