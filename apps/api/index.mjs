import http from "http";
import express from "express";
import pg from "pg";
import GracefulShutdown from "http-graceful-shutdown";
import cors from "cors";

const PORT = 8080;

const DB_HOST = process.env["DB_HOST"] ?? "localhost";
const DB_PORT = process.env["DB_PORT"] ?? 15432;
const DB_NAME = process.env["DB_NAME"] ?? "api-db";
const DB_USER = process.env["DB_USER"] ?? "api-user";
const DB_PASSWORD = process.env["DB_PASSWORD"] ?? "api-password";

export const app = express();
app.use(cors());

app.get("/hello", (request, response) => {
  console.log("GET /hello");
  const name = request.query?.name;
  console.log("Test", name);
  return response.json({ message: `hello, ${name ?? "world"}` });
});

app.get("/hello-pg", async (_, response) => {
  try {
    console.log("GET /hello-pg");

    const client = new pg.Client({
      connectionString: `postgres://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}`,
    });
    await client.connect();

    const res = await client.query("SELECT $1::text as message", [
      "hello world from postgres",
    ]);
    const message = res.rows[0].message;

    await client.end();

    response.json({ message });
  } catch (err) {
    console.log("GET /hello-pg failed", err.message);
    response.json({ message: `request failed` });
  }
});

GracefulShutdown(app);

http.createServer(app).listen(PORT, "0.0.0.0", () => {
  console.log(`🚀 server running on localhost:8080`);
});
