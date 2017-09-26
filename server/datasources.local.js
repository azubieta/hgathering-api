const mongoHost = process.env.MONGO_HOST || 'ds147034.mlab.com';
const mongoPort = process.env.MONGO_PORT || '47034'

module.exports = {
  db: {
    name: "db",
    connector: "memory"
  },
  mlab: {
    host: mongoHost,
    port: mongoPort,
    url: `mongodb://root:root@${mongoHost}:${mongoPort}/help_mx`,
    database: "help_mx",
    password: "root",
    name: "mlab",
    user: "root",
    connector: "mongodb"
  }
}
