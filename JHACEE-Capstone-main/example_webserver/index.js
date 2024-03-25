/**
 * A quick webserver that connects to an sqlite database
 */

const sqlite3 = require("sqlite3");
const http = require("http");
const fs = require("fs");
const crypto = require("crypto");

const networkInterfaces = require("os").networkInterfaces();
const ipAddr = networkInterfaces["wlan0"][0]["address"]

const PORT = process.env.PORT || 8080;
const ROOT = process.env.ROOT || "./public";

const CONTENT_TYPE_MAP = {
  "html": "text/html",
  "css": "text/css",
  "txt": "text/plain",
  "js": "application/javascript",
  "json": "application/json",
  "svg": "image/svg+xml",
  "png": "image/png",
  "jpg": "image/jpg",
  "jpeg": "image/jpg",
  "webp": "image/webp",
}

let db;

initDB();
http.createServer(onRequest).listen(PORT);
console.log(`[info] started server on http://${ipAddr}:${PORT}`);

function onRequest(request, response){
  let url = new URL(request.url, "http://"+request.headers.host);
  console.log(`[info] (${new Date}) request made to ${url.pathname}`);

  if(url.pathname.substr(0,7) === "/images" && !!url.pathname.substr(7)){
    getImage(url.pathname.substr(7), response);
    return;
  }

  if(url.pathname.substr(0, 15) === "/api/v0/beacon/" && !!url.pathname.substr(15)){
    queryBeacon(url.pathname.substr(15), response);
    return;
  }

  if(url.pathname === "/api/v0/beacon") {
    queryAll(response);
    return;
  }

  if(url.pathname === "/api/v0/mapping") {
    getBeaconAisleMap(response);
    return;
  }

  response.writeHead(404, {"Content-Type": "text/html"});
  response.write("<h2>Error 404</h2><br /></i>Page cannot be found</i>");
  response.end();
}

function getBeaconAisleMap(response) {
  db.all(`
    SELECT
      aisle_num, beacon_id
    FROM
      aisles;
  `, (err, rows) => {
      if(err) {
        response.writeHead(500, {"Content-Type" : "text/html"});
        response.write(`<h2>Error 500</h2><br /><i>Something went wrong</i><br /><pre>${err}</pre>`);
        response.end();
        return;
      }

      if(rows.length == 0){
        response.writeHead(404, {"Content-Type": "text/html"});
        response.write("<h2>Error 404</h2><br /></i>Page cannot be found</i>");
        response.end();
        return;
      }

      response.writeHead(200, {"Content-Type": "application/json"});
      response.write(JSON.stringify(rows));
      response.end();
  });
}

function queryAll(response) {
  db.all(`
    SELECT
      p.name, p.price, p.imgurl, p.sale_price, p.stock, p.aisle, p.id, a.beacon_id
    FROM
      products AS p INNER JOIN aisles AS a ON a.aisle_num = p.aisle;
  `, (err, rows) => {
    if(err) {
      response.writeHead(500, {"Content-Type" : "text/html"});
      response.write(`<h2>Error 500</h2><br /><i>Something went wrong</i><br /><pre>${err}</pre>`);
      response.end();
      return;
    }

      if(rows.length == 0){
        response.writeHead(404, {"Content-Type": "text/html"});
        response.write("<h2>Error 404</h2><br /></i>Page cannot be found</i>");
        response.end();
        return;
      }

      response.writeHead(200, {"Content-Type": "application/json"});
      response.write(JSON.stringify(rows));
      response.end();
  });
}

function getImage(imgpath, response) {
  let filepath = `${ROOT}/images/${imgpath}`

  if(filepath.includes("..")) {
    response.writeHead(403, {"Content-Type": "text/html"});
    response.write("<h2>Error 403</h2><br /></i>pls no lfi</i>");
    response.end();
    return;
  }

  if(!fs.existsSync(filepath)) {
    response.writeHead(404, {"Content-Type": "text/html"});
    response.write("<h2>Error 404</h2><br /></i>Image cannot be found</i>");
    response.end();
    return;
  }

  let filetype = imgpath.split('.').slice(-1);

  fs.readFile(filepath, (err, data) => {
    if(err) {
      response.writeHead(500, {"Content-Type": "text/html"});
      response.write("<h2>Error 500</h2><br /></i>Image cannot be found</i>");
      response.end();
      return;
    }

    response.writeHead(200, {"Content-Type": CONTENT_TYPE_MAP[filetype]});
    response.write(data);
    response.end();
  });
}

function queryBeacon(beaconId, response){
  db.all(`SELECT
            p.name, p.price, p.stock, p.aisle, p.id
          FROM
            products AS p JOIN aisles AS a ON a.aisle_num = p.aisle
          WHERE a.beacon_id = ?;`,
    [beaconId],
    (err,rows) => {
      if(err){
        response.writeHead(500, {"Content-Type": "text/html"});
        response.write(`<h2>Error 500</h2><br /><i>Something went wrong</i><br /><pre>${err}</pre>`);
        response.end();
        return;
      }

      if(rows.length == 0){
        response.writeHead(404, {"Content-Type": "text/html"});
        response.write("<h2>Error 404</h2><br /></i>Page cannot be found</i>");
        response.end();
        return;
      }

      response.writeHead(200, {"Content-Type": "application/json"});
      response.write(JSON.stringify(rows));
      response.end();
  });
}

// create a database, based off
// https://www.linode.com/docs/guides/getting-started-with-nodejs-sqlite/
function initDB(){
  /*/
  db = new sqlite3.Database("./store.db",
    sqlite3.OPEN_READWRITE, (err) => {
      if(err && err.code == "SQLITE_CANTOPEN"){
        // database file does not exist (for some reason)
        createDatabase();
        return;
      }

      if(err){
        console.error(`[err] could not connect to database\n${err}`);
        return;
      }

      console.log(`[info] succesfully connected to database`);
  }); // */
  fs.unlinkSync("./store.db");
  db = createDatabase();
}

function createDatabase(){
  var newdb = new sqlite3.Database("store.db", (err) => {
    if(err){
        console.error(`[err] could not create database\n${err}`);
        return;
    }

    let query = `
      PRAGMA foreign_keys = ON;

      CREATE TABLE aisles (
        aisle_num   INTERGER PRIMARY KEY NOT NULL,
        beacon_id   TEXT
      );

      CREATE TABLE products (
        id          INTERGER PRIMARY KEY NOT NULL,
        name        TEXT NOT NULL,
        imgurl      TEXT,
        aisle       INTERGER,
        price       REAL NOT NULL,
        sale_price  REAL,
        stock       INTERGER,
        FOREIGN KEY (aisle) REFERENCES aisles (aisle_num)
      );

      INSERT INTO aisles (aisle_num, beacon_id) VALUES
        (1,   "F2:53:74:ED:E2:25"),
        (2,   "CE:B3:11:25:9A:80"),
        (3,   "C3:A8:B1:38:F2:B4"),
        (4,   "FA:AD:61:17:52:8E"),
        (5,   "A3:2C:22:9B:3A:A0"),
        (6,   "CC:9F:99:DF:04:70");

      INSERT INTO products (id, name, aisle, price, sale_price, stock, imgurl) VALUES
        ("${crypto.randomUUID()}", "Apple",             1,  1.48,  0.00, 53, "http://${ipAddr}:${PORT}/images/apple.jpeg"),
        ("${crypto.randomUUID()}", "Banana",            1,  0.87,  0.00, 71, "http://${ipAddr}:${PORT}/images/banana.jpeg"),
        ("${crypto.randomUUID()}", "Cantaloupe",        1,  3.99,  0.00, 42, "http://${ipAddr}:${PORT}/images/canteloupe.jpeg"),
        ("${crypto.randomUUID()}", "Cherry",            1,  6.49,  0.00, 50, "http://${ipAddr}:${PORT}/images/cherry.jpeg"),
        ("${crypto.randomUUID()}", "Dragon Fruit",      1,  7.49,  7.00, 29, "http://${ipAddr}:${PORT}/images/dragonfruit.jpg"),
        ("${crypto.randomUUID()}", "Durian",            1, 12.99,  0.00, 36, "http://${ipAddr}:${PORT}/images/durian.jpg"),
        ("${crypto.randomUUID()}", "Pears",             1,  1.24,  0.00, 68, "http://${ipAddr}:${PORT}/images/pears.jpg"),
        ("${crypto.randomUUID()}", "Longan",            1,  7.49,  6.50, 28, "http://${ipAddr}:${PORT}/images/longan.jpg"),
        ("${crypto.randomUUID()}", "Lychee",            1,  8.74,  0.00, 32, "http://${ipAddr}:${PORT}/images/lychee.jpg"),
        ("${crypto.randomUUID()}", "Pineapple",         1,  9.99,  8.00, 12, "http://${ipAddr}:${PORT}/images/pineapple.jpg"),
        ("${crypto.randomUUID()}", "Anchovies",         2,  8.49,  6.49, 59, "http://${ipAddr}:${PORT}/images/anchovies.jpg"),
        ("${crypto.randomUUID()}", "Canned Corn",       2,  4.49,  0.00, 48, "http://${ipAddr}:${PORT}/images/cannedcorn.jpg"),
        ("${crypto.randomUUID()}", "Canned Peaches",    2,  3.49,  0.00, 57, "http://${ipAddr}:${PORT}/images/cannedpeach.jpg"),
        ("${crypto.randomUUID()}", "Canned Peas",       2,  3.49,  0.00, 49, "http://${ipAddr}:${PORT}/images/cannedpeas.jpg"),
        ("${crypto.randomUUID()}", "Canned Jackfruit",  2,  4.99,  0.00, 61, "http://${ipAddr}:${PORT}/images/cannedjackfruit.jpg"),
        ("${crypto.randomUUID()}", "Canned Soup",       2,  3.29,  0.00, 42, "http://${ipAddr}:${PORT}/images/cannedsoup.png"),
        ("${crypto.randomUUID()}", "Beef Broth",        2,  5.99,  4.99, 58, "http://${ipAddr}:${PORT}/images/beef-broth.jpg"),
        ("${crypto.randomUUID()}", "Chicken Broth",     2,  5.99,  4.99, 19, "http://${ipAddr}:${PORT}/images/chickenbroth.jpg"),
        ("${crypto.randomUUID()}", "Vegetable Broth",   2,  4.99,  3.99, 28, "http://${ipAddr}:${PORT}/images/vegetablebroth.jpg"),
        ("${crypto.randomUUID()}", "Chips",             3,  3.50,  0.00, 56, "http://${ipAddr}:${PORT}/images/chips.jpeg"),
        ("${crypto.randomUUID()}", "Cheddar Crackers",  3,  5.49,  0.00, 74, "http://${ipAddr}:${PORT}/images/cheddarcrackers.jpg"),
        ("${crypto.randomUUID()}", "Wheat Crackers",    3,  4.49,  0.00, 59, "http://${ipAddr}:${PORT}/images/wheatcracker.jpg"),
        ("${crypto.randomUUID()}", "Graham Crackers",   3,  7.49,  5.99, 28, "http://${ipAddr}:${PORT}/images/grahamcrackers.jpg"),
        ("${crypto.randomUUID()}", "Soda",              3,  2.49,  0.00, 63, "http://${ipAddr}:${PORT}/images/cola.jpeg"),
        ("${crypto.randomUUID()}", "Iced Tea",          3,  3.49,  3.00, 48, "http://${ipAddr}:${PORT}/images/icedtea.png"),
        ("${crypto.randomUUID()}", "Orange Juice",      3,  6.44,  0.00, 53, "http://${ipAddr}:${PORT}/images/orangejuice.jpg"),
        ("${crypto.randomUUID()}", "Earl Grey Tea",     3,  3.99,  0.00, 48, "http://${ipAddr}:${PORT}/images/earlgreytea.jpg"),
        ("${crypto.randomUUID()}", "Black Tea",         3,  4.49,  0.00, 32, "http://${ipAddr}:${PORT}/images/blacktea.jpg"),
        ("${crypto.randomUUID()}", "Coffee",            3,  5.99,  0.00, 48, "http://${ipAddr}:${PORT}/images/coffee.jpg"),
        ("${crypto.randomUUID()}", "Cereal",            4,  7.50,  0.00, 27, "http://${ipAddr}:${PORT}/images/cereal.jpeg"),
        ("${crypto.randomUUID()}", "Jasmine Rice",      4, 32.50,  0.00, 15, "http://${ipAddr}:${PORT}/images/rice.jpeg"),
        ("${crypto.randomUUID()}", "Flour",             4, 14.99,  0.00, 58, "http://${ipAddr}:${PORT}/images/flourIswear.jpg"),
        ("${crypto.randomUUID()}", "Spaghetti",         4,  6.99,  0.00, 49, "http://${ipAddr}:${PORT}/images/spaghetti.jpg"),
        ("${crypto.randomUUID()}", "Ramen",             4,  0.99,  0.00, 61, "http://${ipAddr}:${PORT}/images/ramen.jpeg"),
        ("${crypto.randomUUID()}", "Sunflower Seeds",   4,  4.99,  0.00, 59, "http://${ipAddr}:${PORT}/images/sunflowerseeds.jpg"),
        ("${crypto.randomUUID()}", "Chia Seeds",        4,  5.99,  0.00, 49, "http://${ipAddr}:${PORT}/images/chiaseeds.jpg"),
        ("${crypto.randomUUID()}", "Bread",             5,  1.49,  0.00, 39, "http://${ipAddr}:${PORT}/images/bread.jpeg"),
        ("${crypto.randomUUID()}", "Bagels",            5,  2.30,  0.00, 12, "http://${ipAddr}:${PORT}/images/bagel.jpeg"),
        ("${crypto.randomUUID()}", "Pita Bread",        5,  3.74,  0.00, 52, "http://${ipAddr}:${PORT}/images/pitabread.jpeg"),
        ("${crypto.randomUUID()}", "Oatmeal",           5,  4.39,  0.00, 48, "http://${ipAddr}:${PORT}/images/oatmeal.jpg"),
        ("${crypto.randomUUID()}", "Bread Roll",        5,  0.99,  0.00, 29, "http://${ipAddr}:${PORT}/images/breadroll.jpg"),
        ("${crypto.randomUUID()}", "Cupcakes",          5,  4.99,  0.00, 34, "http://${ipAddr}:${PORT}/images/cupcakes.jpg"),
        ("${crypto.randomUUID()}", "Cake",              5, 13.99, 10.00, 29, "http://${ipAddr}:${PORT}/images/cake.jpg"),
        ("${crypto.randomUUID()}", "Dog Food",          6, 14.99,  0.00, 12, "http://${ipAddr}:${PORT}/images/dogfood.jpeg"),
        ("${crypto.randomUUID()}", "Cat Food",          6, 19.49,  0.00, 18, "http://${ipAddr}:${PORT}/images/catfood.jpg"),
        ("${crypto.randomUUID()}", "Toy Ball",          6,  3.99,  0.00, 30, "http://${ipAddr}:${PORT}/images/dogball.jpg"),
        ("${crypto.randomUUID()}", "Scratch Post",      6, 42.99,  0.00, 19, "http://${ipAddr}:${PORT}/images/scratchpost.jpg"),
        ("${crypto.randomUUID()}", "Broom",             6, 12.99,  0.00, 29, "http://${ipAddr}:${PORT}/images/broom.jpg"),
        ("${crypto.randomUUID()}", "Lint Roller",       6,  3.49,  0.00, 32, "http://${ipAddr}:${PORT}/images/lintroller.jpg"),
        ("${crypto.randomUUID()}", "Collar and Leash",  6, 10.49,  0.00, 29, "http://${ipAddr}:${PORT}/images/collarandleash.jpg"),
        ("${crypto.randomUUID()}", "Litter",            6, 24.99,  0.00, 21, "http://${ipAddr}:${PORT}/images/litter.jpg");
      `

    newdb.exec(query); /// TODO: replace MAC addresses with actual beacon ids, add more
          /// products
          // also, uuid doesn't really matter as long as they're unique, thus go ham
  });

  db = newdb;
  console.log(`[info] succesfully created and connected to database`);

  return db;
}
